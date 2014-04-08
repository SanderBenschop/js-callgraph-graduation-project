module GraphBuilder

import EcmaScript;
import ParseTree;
import analysis::graphs::Graph;
import IO;

import DataStructures;
import NativeFlow;
import IntraproceduralFlow;
import PessimisticInterproceduralFlow;
import CommonInterproceduralFlow;
import OptimisticTransitiveClosure;
import CallGraphExtractor;
import ScopeAnalysis;
import PrettyPrinter;

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
public Graph[Vertex] withPessimisticInterproceduralFlow(Graph[Vertex] graph, Tree tree, SymbolTableMap symbolTableMap) = graph + getPessimisticInterproceduralFlow(tree) + getCommonInterproceduralFlow(tree, symbolTableMap);
public Graph[Vertex] withOptimisticTransitiveClosure(Graph[Vertex] graph, Tree _, SymbolTableMap _) = getOptimisticTransitiveClosure(graph);

public tuple[Graph[Vertex] calls, set[Vertex] escaping, set[Vertex] unresolved] andExtractCallGraph(Graph[Vertex] graph) = extractCallGraph(graph);
public Graph[Vertex] andDoNothing(Graph[Vertex] graph) = graph;