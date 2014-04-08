module CallGraphExtractor

import analysis::graphs::Graph;
import DataStructures;
import Relation;

public tuple[Graph[Vertex] calls, set[Vertex] escaping, set[Vertex] unresolved] extractCallGraph(Graph[Vertex] flowGraph) {
	Graph[Vertex] calls = {};
	set[Vertex] escaping = {}, unresolved = {};
	for (Vertex base <- domain(flowGraph)) {
		if (Function(_) := base) {
			calls += { <target, base> | target <- flowGraph[base], Callee(_) := target };
			escaping += Unknown() in flowGraph[base] ? base : {};
		} else if (Unknown() := base) {
			unresolved += { target | target <- flowGraph[base], Callee(_) := target };
		}
	}
	return <calls, escaping, unresolved>;
}