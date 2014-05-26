module OptimisticInterproceduralFlow2

//TODO: remove weird dependency to PessimisticInterproceduralFlow
import PessimisticInterproceduralFlow;
//TODO: see if this can be done at the last part.
import CallGraphExtractor;

import OptimisticTransitiveClosure;

import IO;
import EcmaScript;
import ParseTree;
import analysis::graphs::Graph;
import VertexFactory;
import utils::Utils;
import Set;

import DataStructures;

//Alternative interprocedural flow algorithm, this is pretty much how Jorryt interpreted it. Want to see if the same results are produced.
//This immediately produces a Call Graph however, not a Flow Graph.
public Graph[Vertex] getOptimisticInterproceduralFlow2(trees, Graph[Vertex] flowGraph) {
	Graph[Vertex] callGraph = {};
	set[Tree] unresolvedEdgeList = {};
	set[Tree] escapingEdgeList = {};
	bool fixpoint = false;
	int iterationsHACK = 0;
	while(!fixpoint) {
		println("ALTERNATIVE - Visiting the tree, looking for function calls.");
		
		Graph[Vertex] oldCallGraph = callGraph;
		Graph[Vertex] oldFlowGraph = flowGraph;
		set[Tree] oldunresolvedEdgeList = unresolvedEdgeList;
		set[Tree] oldescapingEdgeList = escapingEdgeList;
		
		tuple[lrel[Tree, Tree] oneShot, list[Tree] unresolved, list[Tree] functionsInsideClosures] callSites = analyseCallSites(flowGraph);
		flowGraph += oneShotClosureEdges(callSites.oneShot);
		unresolvedEdgeList += toSet(callSites.unresolved);
		list[Tree] escaping = getEscapingFunctions(trees, callSites.functionsInsideClosures);	
		escapingEdgeList += toSet(escaping);
		
		//Graph[Vertex] flowGraphTransitiveClosure = flowGraph+;
		Graph[Vertex] optimisticTransitiveClosure = getOptimisticTransitiveClosure(flowGraph);
		callGraph = extractOptimisticCallGraph(optimisticTransitiveClosure);
		
		iterationsHACK += 1;
		
		//ITERATIONSHACK WERKT NIET, BLIJVEN ER 8?
		fixpoint = iterationsHACK == 5 && oldCallGraph == callGraph && oldunresolvedEdgeList == unresolvedEdgeList && oldescapingEdgeList == escapingEdgeList;
	}
	return callGraph;
}