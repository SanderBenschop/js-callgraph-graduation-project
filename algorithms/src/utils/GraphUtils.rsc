module utils::GraphUtils

import analysis::graphs::Graph;
import DataStructures;

public Graph[Vertex] filterFrameworkEdges(Graph[Vertex] graph, set[str] patterns) {
	return {tup | tuple[Vertex callee, Vertex target] tup <- graph, !matchesAPattern(tup.callee, patterns)};
}

public bool matchesAPattern(Vertex callee, set[str] patterns) {
	if (Callee(location) := callee) {
		return matchesAPattern(location.uri, patterns);
	}
	throw "Not a callee";
}

public bool matchesAPattern(str uri, set[str] patterns) {
	for (str pattern <- patterns) {
		if (/<pattern>/ := uri) return true;
	}
	return false;
}