module dynamicanalysis::StaticDynamicCallGraphComparator

import ValueIO;
import dynamicanalysis::DynamicCallGraphReader;
import DataStructures;
import analysis::graphs::Graph;
import IO;
import Set;
import String;
import util::Math;
import utils::GraphUtils;
import Configuration;
import Relation;

public Graph[str] filterNatives(Graph[str] graph) = { tup | tuple[str base, str target] tup <- graph, !startsWith(tup.target, "Builtin") };

public void printStatistics(Graph[Vertex] staticCG, loc dynamicCallMapLoc) {
	Graph[str] stringGraph = convertVertexGraphToStringGraph(staticCG);
	printStatistics(stringGraph, dynamicCallMapLoc);
}

public void printStatistics(Graph[str] staticCG, loc dynamicCallMapLoc) {
	Graph[str] dynamicCG = convertJsonToGraph(dynamicCallMapLoc);
	printStatistics(staticCG, dynamicCG);
}

public void printStatistics(Graph[str] staticCG, Graph[str] dynamicCG) {
	if (compareCallTargetsOnly) println("WARNING - Only call targets are compared!");
	println("The precision is <calculatePrecision(staticCG, dynamicCG)>%");
	println("The recall is <calculateRecall(staticCG, dynamicCG)>%");
}

public real calculatePrecision(Graph[str] staticCG, Graph[str] dynamicCG) {
	if (filterNativeFunctions) {
		staticCG = filterNatives(staticCG);
		dynamicCG = filterNatives(dynamicCG);
	}
	
	if (compareCoveredCodeOnly) {
		println("Filtering out code not covered in the dynamic call graph!");
		set[str] dynamicCallees = domain(dynamicCG);
		staticCG = {tup | tuple[str callee, str target] tup <- staticCG, tup.callee in dynamicCallees};
	}

	real intersection, staticCallGraphSize;
	if (compareCallTargetsOnly) {
		set[str] staticrange = range(staticCG), dynamicrange = range(dynamicCG);
		intersection = toReal(size(dynamicrange & staticrange));
		staticCallGraphSize = toReal(size(staticrange));
	} else {
		intersection = toReal(size(dynamicCG & staticCG));
		staticCallGraphSize = toReal(size(staticCG));
	}
	
	return intersection / staticCallGraphSize * 100;
}

//Recall can be calculated by switching around the static and dynamic graph as the calculation is exactly the same.
public real calculateRecall(Graph[str] staticCG, Graph[str] dynamicCG) = calculatePrecision(dynamicCG, staticCG);