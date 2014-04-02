module Main

import EcmaScript;
import ParseTree;
import analysis::graphs::Graph;
import IO;

import DataStructures;
import NativeFlow;
import IntraproceduralFlow;
import PessimisticInterproceduralFlow;
import ScopeAnalysis;
import PrettyPrinter;

private int NO_INTERPROCEDURAL_FLOW = 0;
private int PESSIMISTIC_INTERPROCEDURAL_FLOW = 1;

public Graph[Vertex] createPessimisticCallGraph(source) {
	Graph[Vertex] graph = createFlowGraph(source, PESSIMISTIC_INTERPROCEDURAL_FLOW);
	return graph;
}

public Graph[Vertex] createFlowGraph(source) = createFlowGraph(source, NO_INTERPROCEDURAL_FLOW);
public Graph[Vertex] createFlowGraph(source, interProceduralFlowStrategy) {
	Graph[Vertex] graph = createNativeFlowGraph();
	Tree tree = parse(source);
	SymbolTableMap symbolTableMap = createSymbolTableMap(tree);
	graph = addIntraproceduralFlow(graph, tree, symbolTableMap);
	
	switch(interProceduralFlowStrategy) {
		case NO_INTERPROCEDURAL_FLOW: {
			println("ADDING NO INTERPROCEDURAL FLOW");
		}
		case PESSIMISTIC_INTERPROCEDURAL_FLOW: {
			println("ADDING PESSIMISTIC INTERPROCEDURAL FLOW");
			graph = addPessimisticInterproceduralFlow(graph, tree, symbolTableMap);
		}
		default: throw "Invalid interprocedural flow strategy";
	}
	return graph;
}