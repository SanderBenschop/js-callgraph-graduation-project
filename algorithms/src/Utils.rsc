module Utils

import List;
import ParseTree;
import EcmaScript;
import analysis::graphs::Graph;

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

public list[Tree] extractArguments(call) {
	if ((Expression)`<Expression e>()` := call) {
		return [];
	} else if ((Expression)`<Expression e> ( <{ Expression!comma ","}+ args> )` := call) {
		return iterableToTreeList(args);
	}
	throw "Not a call";
}

public list[Tree] extractParameters(function) {
	if ((Expression)`function (<{Id ","}* params>) <Block _>` := function 
		|| (Expression)`function <Id _> (<{Id ","}* params>) <Block _>` := function
		|| (FunctionDeclaration)`function <Id _> (<{Id ","}* params>) <Block _> <ZeroOrMoreNewLines _>` := function) {
		return iterableToTreeList(params);
	}
	throw "Not a function";
}

public Graph[&U] mapper(Graph[&T] graph, tuple[&U, &U] (tuple[&T, &T]) fn) {
    return {fn(elm) | tuple[&T, &T] elm <- graph};
}