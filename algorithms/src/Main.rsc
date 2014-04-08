module Main

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
import ScopeAnalysis;
import PrettyPrinter;

public int NO_INTERPROCEDURAL_FLOW = 0;
public int PESSIMISTIC_INTERPROCEDURAL_FLOW = 1;

public Graph[Vertex] createPessimisticCallGraph(source) {
	Graph[Vertex] vertex = createFlowGraph(source, PESSIMISTIC_INTERPROCEDURAL_FLOW, true);
	Graph[Vertex] closure = getOptimisticTransitiveClosure(vertex);
	//Extract CG from transitive closure.
	return closure;
}

public Graph[Vertex] createFlowGraph(source) = createFlowGraph(source, NO_INTERPROCEDURAL_FLOW, true);

public Graph[Vertex] createFlowGraph(source, interProceduralFlowStrategy, addNativeFlow) {
	Graph[Vertex] graph = addNativeFlow ? createNativeFlowGraph() : {};
	
	Tree tree = parse(source);
	SymbolTableMap symbolTableMap = createSymbolTableMap(tree);
	
	//Figure 4 of paper
	graph += getIntraproceduralFlow(tree, symbolTableMap);
	
	switch(interProceduralFlowStrategy) {
		case NO_INTERPROCEDURAL_FLOW: println("ADDING NO INTERPROCEDURAL FLOW");
		case PESSIMISTIC_INTERPROCEDURAL_FLOW: {
			//Algorithm 1 & 2 of paper
			println("ADDING PESSIMISTIC INTERPROCEDURAL FLOW");
			graph += getPessimisticInterproceduralFlow(tree);
		}
		default: throw "Invalid interprocedural flow strategy";
	}
	
	graph += getCommonInterproceduralFlow(tree, symbolTableMap);
	
	return graph;
}