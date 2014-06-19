module utils::Utils

import IO;
import List;
import ParseTree;
import EcmaScript;
import analysis::graphs::Graph;
import String;

list[tuple[&T first, &U second]] unbalancedZip(list[&T] a, list[&U] b) {
	int sizeA = size(a), sizeB = size(b);
	if (sizeA > sizeB) {
		return zip(a[0..sizeB], b);
	} else if (sizeA < sizeB) {
		return zip(a, b[0..sizeA]);
	}
	return zip(a, b);
}

public list[Tree] iterableToTreeList(elements) = [element | element <- elements];

public str formatLoc(loc location) {
	try file = location.file; catch : file = "mockup.nojs";	
	int lineNumber = location.begin.line;
	int columnStart = location.offset;
	//The tool used by the original authors doesn't show multiple lines but just puts it one one big line like this.
	int columnEnd = columnStart + location.length;
	return "<file>@<lineNumber>:<columnStart>-<columnEnd>";
}

//TODO: remove duplication
public str formatGVLoc(str prefix, loc location) {
	try str file = replaceLast(location.file, ".js", ""); catch : str file = "Mockup";	
	int lineNumber = location.begin.line;
	int columnStart = location.offset;
	int columnEnd = columnStart + location.length;
	return "<prefix>FILE<file>LINE<lineNumber>COLSTART<columnStart>COLEND<columnEnd>";
}

public list[Tree] extractArguments(call) {
	if ((Expression)`<Expression e>()` := call) {
		return [];
	} else if ((Expression)`<Expression e> ( <{ Expression!comma ","}+ args> )` := call) {
		return iterableToTreeList(args);
	} else if ((Expression)`new <Expression e>` := call) {
		return ((Expression)`<Expression _> ( <{ Expression!comma ","}+ args> )` := e) ? iterableToTreeList(args) : [];
	}
	throw "Passed arugment <call> is not a call";
}

public list[Tree] extractParameters(function) {
	if ((Expression)`function (<{Id ","}* params>) <Block _>` := function 
		|| (Expression)`function <Id _> (<{Id ","}* params>) <Block _>` := function
		|| (FunctionDeclaration)`function <Id _> (<{Id ","}* params>) <Block _> <ZeroOrMoreNewLines _>` := function) {
		return iterableToTreeList(params);
	}
	throw "Passed argument <function> is not a function";
}

public Graph[&U] mapper(Graph[&T] graph, tuple[&U, &U] (tuple[&T, &T]) fn) {
    return {fn(elm) | tuple[&T, &T] elm <- graph};
}