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

public Graph[Vertex] convertJsonToGraph(loc jsonFile, SourceMapping sourceMapping) {
	Graph[Vertex] callGraph = {};
	JSONText cst = parse(#JSONText, jsonFile);
	Value ast = buildAST(cst);
	if (object(map[str memberName, Value memberValue] members) := ast) {
		for (str base <- members) {
			if (array(list[Value] targetValues) := members[base]) {
				for (Value targetValue <- targetValues) {
					if (string(target) := targetValue) {
						callGraph += <parseCallee(base, sourceMapping), parseFunction(target, sourceMapping)>;
					} else throw "<targetValue> is not a string";
				}
			} else throw "<targetValueArray> is not an array";
		}
	} else throw "Not a valid call map!";
	return callGraph;
}

private JSONText parse(loc jsonFile) = parse(#JSONText, readFile(jsonFile));

public Vertex parseCallee(str stringValue, SourceMapping sourceMapping) = Callee(parseLocation(stringValue, sourceMapping));

public Vertex parseFunction(str stringValue, SourceMapping sourceMapping) {
	if (isNativeTarget(stringValue)) return Builtin(stringValue);
	else return Function(parseLocation(stringValue, sourceMapping));
}

public loc parseLocation(str stringValue, SourceMapping sourceMapping) {
	if (/<fileName:.*>\.js@<lineNumber:\d+>:<startColumn:\d+>-<endColumn:\d+>/ := stringValue) {
		int startColumnInt = toInt(startColumn), endColumnInt = toInt(endColumn), lineNumberInt = toInt(lineNumber);
		loc sourceLocation = sourceMapping[fileName];
		int length = endColumnInt - startColumnInt;
		int endLine = extractEndline(sourceLocation, lineNumberInt, startColumnInt, endColumnInt);
		return sourceLocation(startColumnInt, length, <lineNumberInt, startColumnInt>, <endLine,endColumnInt>);
	} else throw "Not a valid call graph location";
}

public int extractEndline(loc sourceLocation, int startLine, int startColumn, int endColumn) {
	str content = readFile(sourceLocation);
	str subString = substring(content, startColumn, endColumn);
	return startLine + size(findAll(subString, "\n"));
}

public alias SourceMapping = map[str, loc];
