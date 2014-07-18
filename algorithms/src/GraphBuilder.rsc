module GraphBuilder

import EcmaScript;
import ParseTree;
import analysis::graphs::Graph;

import DataStructures;
import NativeFlow;
import IntraproceduralFlow;
import CommonInterproceduralFlow;
import PessimisticInterproceduralFlow;
import OptimisticInterproceduralFlow;
import OptimisticTransitiveClosure;
import CallGraphExtractor;
import ScopeAnalysis;
import utils::Utils;

public Graph[Vertex] newGraph(source, list[Graph[Vertex] (Graph[Vertex], Tree, SymbolTableMap)] intermediateOperations) = newGraph(source, intermediateOperations, andDoNothing);

public &T newGraph(list[Tree] trees, list[Graph[Vertex] (Graph[Vertex], value, SymbolTableMap)] intermediateOperations, &T (Graph[Vertex]) finalOperation) {
	SymbolTableMap symbolTableMap = createSymbolTableMap(trees);
	Graph[Vertex] graph = {};
	for (intermediateOperation <- intermediateOperations) {
		graph = intermediateOperation(graph, trees, symbolTableMap);
	}
	graph = andRemoveTreeAnnotations(graph);
	return finalOperation(graph);
}

public &T newGraph(list[&U] source, list[Graph[Vertex] (Graph[Vertex], value, SymbolTableMap)] intermediateOperations, &T (Graph[Vertex]) finalOperation) {
	list[Tree] trees = parseAll(source);
	return newGraph(trees, intermediateOperations, finalOperation);
}

public &T newGraph(source, list[Graph[Vertex] (Graph[Vertex], value, SymbolTableMap)] intermediateOperations, &T (Graph[Vertex]) finalOperation) = newGraph([source], intermediateOperations, finalOperation);

public Graph[Vertex] withNativeFlow(Graph[Vertex] graph, _, SymbolTableMap _) = graph + createNativeFlowGraph();
public Graph[Vertex] withIntraproceduralFlow(Graph[Vertex] graph, trees, SymbolTableMap symbolTableMap) = graph + getIntraproceduralFlow(trees, symbolTableMap);
public Graph[Vertex] withOptimisticInterproceduralFlow(Graph[Vertex] graph, trees, SymbolTableMap symbolTableMap) =  getOptimisticInterproceduralFlow(trees, (graph + getCommonInterproceduralFlow(trees, symbolTableMap)));
public Graph[Vertex] withPessimisticInterproceduralFlow(Graph[Vertex] graph, trees, SymbolTableMap symbolTableMap) = graph + getPessimisticInterproceduralFlow(trees) + getCommonInterproceduralFlow(trees, symbolTableMap);
public Graph[Vertex] withCommonInterproceduralFlow(Graph[Vertex] graph, trees, SymbolTableMap symbolTableMap) = graph + getCommonInterproceduralFlow(trees, symbolTableMap);

public Graph[Vertex] withOptimisticTransitiveClosure(Graph[Vertex] graph, _, SymbolTableMap _) = getOptimisticTransitiveClosure(graph);

public tuple[Graph[Vertex] calls, set[Vertex] escaping, set[Vertex] unresolved] andExtractPessimisticCallGraph(Graph[Vertex] graph) = extractPessimisticCallGraph(graph);
public Graph[Vertex] andExtractOptimisticCallGraph(Graph[Vertex] graph, _, SymbolTableMap _) = extractOptimisticCallGraph(graph);
public Graph[Vertex] andDoNothing(Graph[Vertex] graph) = graph;

//TODO: move.
public Graph[Vertex] andRemoveTreeAnnotations(Graph[Vertex] graph) = mapper(graph, removeTreeAnnotations);
private tuple[Vertex, Vertex] removeTreeAnnotations(tuple[Vertex from, Vertex to] tup) = <cleanVertex(tup.from), cleanVertex(tup.to)>;
private Vertex cleanVertex(Vertex annotatedVertex) {
	switch(annotatedVertex) {
		case Expression(loc position) : return Expression(position);
		case Variable(str name, loc position) : return Variable(name, position);
		case Property(str name) : return Property(name);
		case Function(loc position) : return Function(position);
	
		case Callee(loc position) : return Callee(position);
		case Argument(loc position, int index) : return Argument(position, index);
		case Parameter(loc position, int index) : return Parameter(position, index);
		case Return(loc position) : return Return(position);
		case Result(loc position) : return Result(position);
		
		case Unknown() : return Unknown();
		case Builtin(str name) : return Builtin(name);
	}
}