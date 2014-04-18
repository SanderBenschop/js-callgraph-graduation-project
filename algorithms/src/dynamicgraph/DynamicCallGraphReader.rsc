module dynamicgraph::DynamicCallGraphReader

import IO;
import String;
import lang::json::\syntax::JSON;
import lang::json::ast::Implode;
import lang::json::ast::JSON;
import DataStructures;
import analysis::graphs::Graph;
import ParseTree;
import NativeFlow;

public Graph[Vertex] convertJsonToGraph(loc jsonFile, SourceLocationMapping sourceLocationMapping) {
	SourceMapping sourceMapping = createSourceMapping(sourceLocationMapping);
	Graph[Vertex] callGraph = {};
	JSONText cst = parse(#JSONText, jsonFile);
	Value ast = buildAST(cst);
	if (object(map[str memberName, Value memberValue] members) := ast) {
		for (str base <- members) {
			if (array(list[Value] targetValues) := members[base]) {
				for (Value targetValue <- targetValues) {
					if (string(target) := targetValue) {
						callGraph += <parseCallee(base, sourceLocationMapping, sourceMapping), parseFunction(target, sourceLocationMapping, sourceMapping)>;
					} else throw "<targetValue> is not a string";
				}
			} else throw "<targetValueArray> is not an array";
		}
	} else throw "Not a valid call map!";
	return callGraph;
}

private JSONText parse(loc jsonFile) = parse(#JSONText, readFile(jsonFile));

public Vertex parseCallee(str stringValue, SourceLocationMapping sourceLocationMapping, SourceMapping sourceMapping) = Callee(parseLocation(stringValue, sourceLocationMapping, sourceMapping));

public Vertex parseFunction(str stringValue, SourceLocationMapping sourceLocationMapping, SourceMapping sourceMapping) {
	if (isNativeElement(stringValue)) return Builtin(convertNativeName(stringValue));
	else return Function(parseLocation(stringValue, sourceLocationMapping, sourceMapping));
}

public loc parseLocation(str stringValue, SourceLocationMapping sourceLocationMapping, SourceMapping sourceMapping) {
	if (/<fileName:.*>\.js@<lineNumber:\d+>:<startColumn:\d+>-<endColumn:\d+>/ := stringValue) {
		int startColumnInt = toInt(startColumn), endColumnInt = toInt(endColumn), lineNumberInt = toInt(lineNumber);
		str source = sourceMapping[fileName];
		//str firstChar = stringChar(charAt(source, startColumnInt)), lastChar = stringChar(charAt(source, endColumnInt));
		str subString = substring(source, startColumnInt, endColumnInt);
		int endLine = extractEndline(lineNumberInt, subString);
		str firstLine = extractLine(source, lineNumberInt), lastLine = extractLine(source, endLine);
		str lastLineSubstring = extractLastLine(subString);
		int overallStartColumn = findFirst(firstLine, extractFirstLine(subString)), overallEndColumn = findLast(lastLine, lastLineSubstring) + size(lastLineSubstring);
		overallEndColumn = overallEndColumn != -1 ? overallEndColumn : size(subString) - 1;
		int length = endColumnInt - startColumnInt;
		loc sourceLocation = sourceLocationMapping[fileName];
		return sourceLocation(startColumnInt, length, <lineNumberInt, overallStartColumn>, <endLine,overallEndColumn>);
	} else throw "Not a valid call graph location";
}

public int extractEndline(int startLine, str subString) {
	return startLine + countLines(subString) - 1;
}

public alias SourceLocationMapping = map[str, loc];
public alias SourceMapping = map[str, str];

public SourceMapping createSourceMapping(map[str, loc] sourceLocationMapping) {
	SourceMapping sourceMapping = ();
	for (str fileName <- sourceLocationMapping) {
	    loc sourceLocation = sourceLocationMapping[fileName];
	    str source = readFile(sourceLocation);
	    sourceMapping += (fileName : source);
	}
	return sourceMapping;
}

public str extractFirstLine(str source) = extractLine(source, 1);
public str extractLastLine(str source) {
	int lastLine = countLines(source);
	return extractLine(source, lastLine);
}

public str extractLine(str source, int lineNumber) {
	list[str] lines = split("\n", source);
	return lines[lineNumber - 1];
}

public int countLines(str source) {
	return size(findAll(source, "\n")) + 1;
}