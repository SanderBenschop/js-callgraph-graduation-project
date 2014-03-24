module Main

import EcmaScript;
import ParseTree;
import analysis::graphs::Graph;

import DataStructures;
import NativeFlow;
import IntraproceduralFlow;
import ScopeAnalysis;

public Graph[Vertex] createPessimisticCallGraph(loc source) {
	Graph[Vertex] graph = createFlowGraph(source);
	//graph = addInterproceduralFlow
	return graph;
}

public Graph[Vertex] createFlowGraph(loc source) {
	Graph[Vertex] graph = createNativeFlowGraph();
	Tree tree = parse(source);
	SymbolTableMap symbolTableMap = createSymbolTableMap(tree);
	parseAndView(tree);
	return addIntraproceduralFlow(graph, tree, symbolTableMap);
}