module Main

import EcmaScript;
import ParseTree;
import analysis::graphs::Graph;
import IO;

import DataStructures;
import NativeFlow;
import IntraproceduralFlow;
import ScopeAnalysis;
import PrettyPrinter;

public Graph[Vertex] createPessimisticCallGraph(source) {
	Graph[Vertex] graph = createFlowGraph(source);
	//graph = addInterproceduralFlow
	println("Pretty printed:");
	prettyPrintGraph(graph);
	return graph;
}

public Graph[Vertex] createFlowGraph(source) {
	Graph[Vertex] graph = createNativeFlowGraph();
	Tree tree = parse(source);
	SymbolTableMap symbolTableMap = createSymbolTableMap(tree);
	return addIntraproceduralFlow(graph, tree, symbolTableMap);
}