module CallGraphExtractor

import Set;
import analysis::graphs::Graph;
import DataStructures;
import Relation;

public tuple[Graph[Vertex] calls, set[Vertex] escaping, set[Vertex] unresolved] extractPessimisticCallGraph(Graph[Vertex] flowGraph) {
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

public Graph[Vertex] extractOptimisticCallGraph(Graph[Vertex] flowGraph) {
	tuple[Graph[Vertex] calls, set[Vertex] escaping, set[Vertex] unresolved] res = extractPessimisticCallGraph(flowGraph);
	assert isEmpty(res.escaping) : "Optimistic call graph should not contain escaping edges.";
	assert isEmpty(res.unresolved) : "Optimistic call graph should not contain unresolved call sites.";
	return res.calls;
}