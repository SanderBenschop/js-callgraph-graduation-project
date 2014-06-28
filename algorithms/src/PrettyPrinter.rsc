module PrettyPrinter

import analysis::graphs::Graph;
import Relation;
import IO;
import List;

import DataStructures;
import utils::Utils;

public void writePrettyPrintedGraph(Graph[Vertex] graph) = writePrettyPrintedGraph(graph, true, true);

public void writePrettyPrintedGraph(Graph[Vertex] graph, bool sortIt, bool flowGraphStyle) {
    str prettyPrinted = prettyPrintGraph(graph, sortIt, flowGraphStyle);
    writeFile(|project://JavaScript%20cg%20algorithms/src/testing/filedump/prettyPrinted.log|, prettyPrinted);
}

public str prettyPrintGraphVizExport(Graph[Vertex] graph) {
	list[str] vertices = [], edges = [];
	
	for (Vertex vertex <- domain(graph) + range(graph)) {
		vertices += "<graphVizFormatVertex(vertex)> [label=\"<flowGraphFormatVertex(vertex)>\"]";
	}
	
	for (Vertex base <- domain(graph)) {
		set[Vertex] targets = graph[base];
		for (Vertex target <- targets) {
			edges += "<graphVizFormatVertex(base)> -\> <graphVizFormatVertex(target)>";
		}
	}
	
	return "
	digraph G {
		{
			<joinStringList(vertices)>
		}
			<joinStringList(edges)>
	}";
}

private str joinStringList(list[str] stringList) = ("" | it + stringElem + "\n" | str stringElem <- stringList);

public str prettyPrintGraph(Graph[Vertex] graph) = prettyPrintGraph(graph, false, true);
public str prettyPrintGraph(Graph[Vertex] graph, bool sortIt, bool flowGraphStyle) {
	str (Vertex) formatter = flowGraphStyle ? flowGraphFormatVertex : callGraphFormatVertex;
	str brackets = flowGraphStyle ? "\"" : "";
	list[str] lines = [];
	for (Vertex base <- domain(graph)) {
		set[Vertex] targets = graph[base];
		for (Vertex target <- targets) {
			lines += "<brackets><formatter(base)><brackets> -\> <brackets><formatter(target)><brackets>";
		}
	}
	if (sortIt) lines = sort(lines);
	str joined = intercalate("\n", lines);
	println(joined);
	return joined;
}

//TODO: Remove duplication
public str prettyPrintGraph(Graph[str] graph, bool sortIt) {
	list[str] lines = [];
		for (str base <- domain(graph)) {
		set[str] targets = graph[base];
		for (str target <- targets) {
			lines += "<base> -\> <target>";
		}
	}
	if (sortIt) lines = sort(lines);
	str joined = intercalate("\n", lines);
	println(joined);
	return joined;
}

private str flowGraphFormatVertex(Vertex vertex) {
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
		
		default: throw "FlowGraph pretty print not implemented for vertex <vertex>";
	}
}

private str callGraphFormatVertex(Vertex vertex) {
	switch(vertex) {
		case Function(loc position) : {
			return formatLoc(position);
		}
		case Builtin(str name) : {
			return name;
		}
		case Callee(loc position) : {
			return formatLoc(position);
		}
		default: throw "CallGraph pretty print not implemented for vertex <vertex>";
	}
}

private str graphVizFormatVertex(Vertex vertex) {
	switch(vertex) {
		case Function(loc position) : {
			return formatGVLoc("func", position);
		}
		case Builtin(str name) : {
			return name;
		}
		case Callee(loc position) : {
			return formatGVLoc("callee", position);
		}
		case Expression(loc position) : {
			return formatGVLoc("exp", position);
		}
		case Argument(loc position, int index) : {
			return formatGVLoc("arg<index>", position);
		}
		case Parameter(loc position, int index) : {
			return formatGVLoc("parm<index>", position);
		}
		case Return(loc position) : {
			return formatGVLoc("return", position);
		}
		
		case Result(loc position) : {
			return formatGVLoc("result", position);
		}
		
		case Variable(_, loc position) : {
			return formatGVLoc("variable", position);
		}
		
		case Property(str name) : {
			return "prop_<name>";
		}
		
		case Unknown() : {
			return "unknown";
		}
		
		default: throw "GraphViz pretty print not implemented for vertex <vertex>";
	}
}