module PrettyPrinter

import analysis::graphs::Graph;
import Relation;
import IO;
import List;

import DataStructures;
import Utils;

public void writePrettyPrintedGraph(Graph[Vertex] graph, bool sortIt) {
    str prettyPrinted = prettyPrintGraph(graph, sortIt);
    writeFile(|project://JavaScript%20cg%20algorithms/src/testing/filedump/prettyPrinted.log|, prettyPrinted);
}

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

		case Callee(loc position) : {
			return "Callee(<formatLoc(position)>)";
		}
		
		case Argument(loc position, int index) : {
			return "Arg(<formatLoc(position)>, <index>)";
		}
		
		case Parameter(loc position, int index) : {
			return "Parm(<formatLoc(position)>, <index>)";
		}
		
		case Return(loc position) : {
			return "Ret(<formatLoc(position)>)";
		}
		
		case Result(loc position) : {
			return "Res(<formatLoc(position)>)";
		}
		
		case Unknown() : {
			return "Unknown";
		}
		
		case Builtin(str name) : {
			return "Builtin(<name>)";
		}
		
		default: throw "Pretty print not implemented for vertex <vertex>";
	}
}