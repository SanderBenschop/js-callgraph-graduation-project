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
import Utils;

public Graph[Vertex] newGraph(source, list[Graph[Vertex] (Graph[Vertex], Tree, SymbolTableMap)] intermediateOperations) = newGraph(source, intermediateOperations, andDoNothing);
public &T newGraph(source, list[Graph[Vertex] (Graph[Vertex], Tree, SymbolTableMap)] intermediateOperations, &T (Graph[Vertex]) finalOperation) {
	Tree tree = parse(source);
	SymbolTableMap symbolTableMap = createSymbolTableMap(tree);
	
	Graph[Vertex] graph = {};
	for (intermediateOperation <- intermediateOperations) {
		graph = intermediateOperation(graph, tree, symbolTableMap);
	}
	return finalOperation(graph);
}

public Graph[Vertex] withNativeFlow(Graph[Vertex] graph, Tree _, SymbolTableMap _) = graph + createNativeFlowGraph();
public Graph[Vertex] withIntraproceduralFlow(Graph[Vertex] graph, Tree tree, SymbolTableMap symbolTableMap) = graph + getIntraproceduralFlow(tree, symbolTableMap);
public Graph[Vertex] withOptimisticInterproceduralFlow(Graph[Vertex] graph, Tree tree, SymbolTableMap symbolTableMap) =  getOptimisticInterproceduralFlow(tree, (graph + getCommonInterproceduralFlow(tree, symbolTableMap)));
public Graph[Vertex] withPessimisticInterproceduralFlow(Graph[Vertex] graph, Tree tree, SymbolTableMap symbolTableMap) = graph + getPessimisticInterproceduralFlow(tree) + getCommonInterproceduralFlow(tree, symbolTableMap);
public Graph[Vertex] withCommonInterproceduralFlow(Graph[Vertex] graph, Tree tree, SymbolTableMap symbolTableMap) = graph + getCommonInterproceduralFlow(tree, symbolTableMap);

public Graph[Vertex] withOptimisticTransitiveClosure(Graph[Vertex] graph, Tree _, SymbolTableMap _) = getOptimisticTransitiveClosure(graph);

public tuple[Graph[Vertex] calls, set[Vertex] escaping, set[Vertex] unresolved] andExtractPessimisticCallGraph(Graph[Vertex] graph) = extractPessimisticCallGraph(graph);
public Graph[Vertex] andExtractOptimisticCallGraph(Graph[Vertex] graph, Tree _, SymbolTableMap _) = extractOptimisticCallGraph(graph);
public Graph[Vertex] andDoNothing(Graph[Vertex] graph) = graph;

//TODO: move.
public Graph[Vertex] andRemoveTreeAnnotations(Graph[Vertex] graph, Tree _, SymbolTableMap _) = mapper(graph, removeTreeAnnotations);
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