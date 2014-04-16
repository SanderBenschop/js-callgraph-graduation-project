module OptimisticInterproceduralFlow

import IO;
import EcmaScript;
import ParseTree;
import analysis::graphs::Graph;
import VertexFactory;
import utils::Utils;
import Set;

import DataStructures;

public Graph[Vertex] getOptimisticInterproceduralFlow(Tree tree, Graph[Vertex] graph) {
	
	println("Processing optimistic interprocedural flow");
	bool changed = false;
	Graph[Vertex] reachabilityGraph = {};

	private void processFunction(Tree function) {
		if (isEmpty(reachabilityGraph) || changed) reachabilityGraph = graph+;
		Vertex functionVertex = Function(function@\loc);
		for (Vertex calleeVertex <- reachabilityGraph[functionVertex], Callee(_) := calleeVertex) {
			Tree callee = calleeVertex@tree;
			//Ret -> Res
			tuple[Vertex, Vertex] candidateTuple = <Return(function@\loc), Result(callee@\loc)>;
			if (candidateTuple notin graph) {
				graph += candidateTuple;
				changed = true;
			}
			//Arg -> Parm
			int i = 1;
			for (tuple[Tree parameter, Tree argument] pa <- unbalancedZip(extractParameters(function), extractArguments(callee))) {
				tuple[Vertex, Vertex] candidateTuple = <Argument(callee@\loc, i), Parameter(function@\loc, i)>;
				if (candidateTuple notin graph) {
					graph += candidateTuple;
					changed = true;
				}
				i += 1;
			}
		}
	}

	do {
		println("Visiting the tree, looking for function calls.");
		changed = false;
		visit(tree) {
			case func:(Expression)`function (<{Id ","}* _>) <Block _>`: processFunction(func);
			case func:(Expression)`function <Id id> (<{Id ","}* _>) <Block _>`: processFunction(func);
			case func:(FunctionDeclaration)`function <Id id> (<{Id ","}* _>) <Block _> <ZeroOrMoreNewLines _>`: processFunction(func);
		}
	} while(changed);

	return graph;
}