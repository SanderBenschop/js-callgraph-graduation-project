module PrettyPrinter

import analysis::graphs::Graph;
import Relation;
import IO;
import List;

import DataStructures;
import Utils;

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
		case Variable(str name, loc position) : {
			return "Var(<name>, <formatLoc(position)>)";
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