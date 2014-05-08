module dynamicgraph::StaticDynamicCallGraphComparator

import ValueIO;
import dynamicgraph::DynamicCallGraphReader;
import DataStructures;
import analysis::graphs::Graph;
import IO;
import Set;
import util::Math;
import utils::GraphUtils;

public void printStatistics(Graph[Vertex] staticCG, loc dynamicCallMapLoc, SourceLocationMapping sourceLocationMapping) {
	Graph[str] stringGraph = convertVertexGraphToStringGraph(staticCG);
	printStatistics(stringGraph, dynamicCallMapLoc, sourceLocationMapping);
}

public void printStatistics(Graph[str] staticCG, loc dynamicCallMapLoc, SourceLocationMapping sourceLocationMapping) {
	Graph[str] dynamicCG = convertJsonToGraph(dynamicCallMapLoc, sourceLocationMapping);
	printStatistics(staticCG, dynamicCG, sourceLocationMapping);
}

public void printStatistics(Graph[str] staticCG, Graph[str] dynamicCG, SourceLocationMapping sourceLocationMapping) {
	println("The precision is <calculatePrecision(staticCG, dynamicCG)>%");
	println("The recall is <calculateRecall(staticCG, dynamicCG)>%");
}

private real calculatePrecision(Graph[str] staticCG, Graph[str] dynamicCG) {
	real intersection = toReal(size(dynamicCG & staticCG));
	real staticCallGraphSize = toReal(size(staticCG));
	return intersection / staticCallGraphSize * 100;
}

private real calculateRecall(Graph[str] staticCG, Graph[str] dynamicCG) {
	real intersection = toReal(size(dynamicCG & staticCG));
	real dynamicCallGraphSize = toReal(size(dynamicCG));
	return intersection / dynamicCallGraphSize * 100;
}