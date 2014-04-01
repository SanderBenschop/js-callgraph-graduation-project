module PrettyPrinter

import analysis::graphs::Graph;
import Relation;
import IO;
import List;

import DataStructures;

public str prettyPrintGraph(Graph[Vertex] graph) = prettyPrintGraph(graph, false);
public str prettyPrintGraph(Graph[Vertex] graph, bool sortIt) {
	list[str] lines = [];
	for (Vertex base <- domain(graph)) {
		set[Vertex] targets = graph[base];
		for (Vertex target <- targets) {
			lines += "\"<formatVertex(base)>\" -\> \"<formatVertex(target)>\"";
		}
	}
	if (sortIt) lines = sort(lines);
	str joined = intercalate("\n", lines);
	println(joined);
	return joined;
}

private str formatVertex(Vertex vertex) {
	switch(vertex) {
		case Expression(loc position) : {
			return "Expr(<formatLoc(position)>)";
		}
		case Variable(loc position) : {
			return "Var(<formatLoc(position)>)";
		}
		case Property(str name) : {
			return "Prop(<name>)";
		}
		case Function(loc position) : {
			return "Func(<formatLoc(position)>)";
		}
		default: throw "Pretty print not implemented for vertex <vertex>";
	}
}

private str formatLoc(loc location) {
	try file = location.file; catch : file = "mockup.nojs";	
	int lineNumber = location.begin.line;
	int columnStart = location.offset;
	//The tool used by the original authors doesn't show multiple lines but just puts it one one big line like this.
	int columnEnd = columnStart + location.length;
	return "<file>@<lineNumber>:<columnStart>-<columnEnd>";
}