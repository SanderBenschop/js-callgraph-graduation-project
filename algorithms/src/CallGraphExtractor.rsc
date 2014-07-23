module CallGraphExtractor

import IO;
import Set;
import analysis::graphs::Graph;
import DataStructures;
import Relation;

public tuple[Graph[Vertex] calls, set[Vertex] escaping, set[Vertex] unresolved] extractPessimisticCallGraph(Graph[Vertex] flowGraph) {
	println("Extracting call graph");
	Graph[Vertex] calls = { <tup.target, tup.base> | tuple[Vertex base, Vertex target] tup <- flowGraph, isValidBase(tup.base), isValidTarget(tup.target) };
	set[Vertex] escaping = { convertToFunction(edge.base) | tuple[Vertex base, Vertex target] edge <- flowGraph, Return(_) := edge.base && Unknown() := edge.target };
	set[Vertex] unresolved = { convertToCallee(edge.target) | tuple[Vertex base, Vertex target] edge <- flowGraph, Unknown() := edge.base && Result(_) := edge.target };
	return <calls, escaping, unresolved>;
}

public Graph[Vertex] extractOptimisticCallGraph(Graph[Vertex] flowGraph) = extractPessimisticCallGraph(flowGraph).calls;

private bool isValidBase(Vertex base) = Function(_) := base || Builtin(_) := base;
private bool isValidTarget(Vertex target) = Callee(_) := target;

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