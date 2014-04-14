module CallGraphExtractor

import Set;
import analysis::graphs::Graph;
import DataStructures;
import Relation;

public tuple[Graph[Vertex] calls, set[Vertex] escaping, set[Vertex] unresolved] extractPessimisticCallGraph(Graph[Vertex] flowGraph) {
	Graph[Vertex] calls = { <target, base> | base <- domain(flowGraph), target <- flowGraph[base], isValidBase(base) && isValidTarget(target) };
	set[Vertex] escaping = { convertToFunction(edge.base) | tuple[Vertex base, Vertex target] edge <- flowGraph, Return(_) := edge.base && Unknown() := edge.target };
	set[Vertex] unresolved = { convertToCallee(edge.target) | tuple[Vertex base, Vertex target] edge <- flowGraph, Unknown() := edge.base && Result(_) := edge.target };
	return <calls, escaping, unresolved>;
}

private bool isValidBase(Vertex base) = Function(_) := base || Builtin(_) := base;
private bool isValidTarget(Vertex target) = Callee(_) := target;

public Graph[Vertex] extractOptimisticCallGraph(Graph[Vertex] flowGraph) {
	tuple[Graph[Vertex] calls, set[Vertex] escaping, set[Vertex] unresolved] res = extractPessimisticCallGraph(flowGraph);
	assert isEmpty(res.escaping) : "Optimistic call graph should not contain escaping edges.";
	assert isEmpty(res.unresolved) : "Optimistic call graph should not contain unresolved call sites.";
	return res.calls;
}

private Vertex convertToFunction(Vertex returnVertex) {
	if (Return(position) := returnVertex) {
		return Function(position);
	}
	throw "Not a Return vertex";
}

private Vertex convertToCallee(Vertex resultVertex) {
	if (Result(position) := resultVertex) {
		return Callee(position);
	}
	throw "Not a Result vertex";
}