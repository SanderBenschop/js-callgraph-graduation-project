module utils::GraphUtils

import analysis::graphs::Graph;
import DataStructures;
import PrettyPrinter;
import String;
import List;

public Graph[Vertex] filterFrameworkEdges(Graph[Vertex] graph, set[str] patterns) {
	return {tup | tuple[Vertex callee, Vertex target] tup <- graph, !matchesAPattern(tup.callee, patterns)};
}

public Graph[Vertex] filterNativeEdges(Graph[Vertex] graph) {
	return {tup | tuple[Vertex callee, Vertex target] tup <- graph, Builtin(_) !:= tup.target};
}

public Graph[str] filterFrameworkEdgesInclusive(Graph[str] graph, set[str] patterns) {
	return {tup | tuple[str callee, str target] tup <- graph, matchesAPattern(tup.callee, patterns) && matchesAPattern(tup.target, patterns)};
}

public bool matchesAPattern(Vertex callee, set[str] patterns) {
	if (Callee(location) := callee) {
		return matchesAPattern(location.uri, patterns);
	}
	throw "Not a callee";
}

public bool matchesAPattern(loc location, set[str] patterns) = matchesAPattern(location.uri, patterns);
public bool matchesAPattern(str uri, set[str] patterns) {
	for (str pattern <- patterns) {
		if (/<pattern>/ := uri) return true;
	}
	return false;
}

public Graph[str] convertVertexGraphToStringGraph(Graph[Vertex] vertexGraph) {
	//TODO: maybe do this in a more straight-forward way.
	Graph[str] stringGraph = {};
	str prettyPrinted = prettyPrintGraph(vertexGraph, false, true);
	list[str] lines = split("\n", prettyPrinted);
	for (str line <- lines) {
		str formattedLine = replaceAll(line, "\"", "");
		formattedLine = replaceAll(formattedLine, " ", "");
		list[str] splitted = split("-\>", formattedLine);
		if (size(splitted) == 2) {
			stringGraph += { <splitted[0], splitted[1]> };
		} else throw "Line <line> is not a valid call graph line";
	}
	return stringGraph;
}