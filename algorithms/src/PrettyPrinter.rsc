module PrettyPrinter

import analysis::graphs::Graph;
import Relation;
import IO;

import DataStructures;

public void prettyPrintGraph(Graph[Vertex] graph) {
	for (Vertex base <- domain(graph)) {
		set[Vertex] targets = graph[base];
		for (Vertex target <- targets) {
			println("\"<formatVertex(base)>\" -\> \"<formatVertex(target)>\"");
		}
	}
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