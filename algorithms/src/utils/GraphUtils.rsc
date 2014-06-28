module utils::GraphUtils

import analysis::graphs::Graph;
import DataStructures;
import PrettyPrinter;
import String;
import List;
import NativeFlow;
import IO;

public Graph[Vertex] filterFrameworkEdges(Graph[Vertex] graph, set[str] patterns) {
	return {tup | tuple[Vertex callee, Vertex target] tup <- graph, !matchesAPattern(tup.callee, patterns)};
}

public Graph[str] filterFrameworkEdges(Graph[str] graph, set[str] patterns) {
	return {tup | tuple[str callee, str target] tup <- graph, !matchesAPattern(tup.callee, patterns)};
}

public Graph[Vertex] filterNativeEdges(Graph[Vertex] graph) {
	return {tup | tuple[Vertex lhs, Vertex rhs] tup <- graph, Builtin(_) !:= tup.lhs && Builtin(_) !:= tup.rhs};
}

public Graph[str] filterNativeEdges(Graph[str] graph) {
	return {tup | tuple[str callee, str target] tup <- graph, !matchesNativeElement(tup.target)};
}

public Graph[str] filterFrameworkEdgesInclusive(Graph[str] graph, set[str] patterns) {
	return {tup | tuple[str callee, str target] tup <- graph, matchesAPattern(tup.callee, patterns) && matchesAPattern(tup.target, patterns)};
}

public Graph[str] filterTargets(Graph[str] graph, set[str] patterns) {
	return {tup | tuple[str callee, str target] tup <- graph, matchesAPattern(tup.target, patterns)};
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

//TODO: move somewhere more appropriately
public set[str] createBuiltinNodes(str string) {
	if (isNativeTarget(string)) return { "Builtin(<key>)" | key <- getKeysByValue(string) };
	list[str] splitted = split(".", string);
	int maxIndex = size(splitted);
	for (i <- [1..maxIndex]) {
		str joined = intercalate(".", splitted[i..]);
		if (isNativeTarget(joined)) return { "Builtin(<key>)" | key <- getKeysByValue(joined) };
	}
	if (isNativeBase(string)) return {"Builtin(<nativeFlows[string]>)"};
	println("WARNING - Cannot extract call to native function from <string>.");
	return {};
}

public bool matchesNativeElement(str string) = !contains(string, "@");

public Graph[&T] reverseGraphDirection(Graph[&T] originalGraph) {
	return {<tup.from, tup.to> | tuple[&T to, &T from] tup <- originalGraph};
}