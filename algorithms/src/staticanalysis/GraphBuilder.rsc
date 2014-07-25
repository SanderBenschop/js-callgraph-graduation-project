module staticanalysis::GraphBuilder

import EcmaScript;
import ParseTree;
import analysis::graphs::Graph;

import staticanalysis::DataStructures;
import staticanalysis::NativeFlow;
import staticanalysis::IntraproceduralFlow;
import staticanalysis::CommonInterproceduralFlow;
import staticanalysis::PessimisticInterproceduralFlow;
import staticanalysis::OptimisticInterproceduralFlow;
import staticanalysis::OptimisticTransitiveClosure;
import staticanalysis::CallGraphExtractor;
import staticanalysis::ScopeAnalysis;
import utils::Utils;
import utils::GraphUtils;

public Graph[Vertex] newGraph(source, list[Graph[Vertex] (Graph[Vertex], Tree, SymbolTableMap)] intermediateOperations) = newGraph(source, intermediateOperations, andDoNothing);

public &T newGraph(list[Tree] trees, list[Graph[Vertex] (Graph[Vertex], value, SymbolTableMap)] intermediateOperations, &T (Graph[Vertex]) finalOperation) {
	SymbolTableMap symbolTableMap = createSymbolTableMap(trees);
	Graph[Vertex] graph = {};
	for (intermediateOperation <- intermediateOperations) {
		graph = intermediateOperation(graph, trees, symbolTableMap);
	}
	graph = removeTreeAnnotationsFromGraph(graph);
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