module dynamicgraph::StaticDynamicCallGraphComparator

import ValueIO;
import dynamicgraph::DynamicCallGraphReader;
import DataStructures;
import analysis::graphs::Graph;
import IO;
import Set;
import util::Math;

public void printStatistics(Graph[Vertex] staticCG, loc dynamicCallMapLoc, SourceLocationMapping sourceLocationMapping) {
	Graph[Vertex] dynamicCG = convertJsonToGraph(dynamicCallMapLoc, sourceLocationMapping);
	printStatistics(staticCG, dynamicCG, sourceLocationMapping);
}

public void printStatistics(loc staticCG, loc dynamicCallMapLoc, SourceLocationMapping sourceLocationMapping) {
	Graph[Vertex] staticCG = readTextValueFile(Graph[Vertex], staticCallGraphLog);
	Graph[Vertex] dynamicCG = convertJsonToGraph(dynamicCallMapLoc, sourceLocationMapping);
	printStatistics(staticCG, dynamicCG, sourceLocationMapping);
}

public void printStatistics(Graph[Vertex] staticCG, Graph[Vertex] dynamicCG, SourceLocationMapping sourceLocationMapping) {
	println("The precision is <calculatePrecision(staticCG, dynamicCG)>%");
	println("The recall is <calculateRecall(staticCG, dynamicCG)>%");
}

private real calculatePrecision(Graph[Vertex] staticCG, Graph[Vertex] dynamicCG) {
	real intersection = toReal(size(dynamicCG & staticCG));
	real staticCallGraphSize = toReal(size(staticCG));
	return intersection / staticCallGraphSize * 100;
}

private real calculateRecall(Graph[Vertex] staticCG, Graph[Vertex] dynamicCG) {
	real intersection = toReal(size(dynamicCG & staticCG));
	real dynamicCallGraphSize = toReal(size(dynamicCG));
	return intersection / dynamicCallGraphSize * 100;
}