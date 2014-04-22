module dynamicgraph::StaticDynamicCallGraphComparator

import ValueIO;
import dynamicgraph::DynamicCallGraphReader;
import DataStructures;
import analysis::graphs::Graph;


public void printStatistics(loc staticCallGraphLog, loc dynamicCallMapLoc, SourceLocationMapping sourceLocationMapping) {
	Graph[Vertex] staticCG = readTextValueFile(Graph[Vertex], staticCallGraphLog);
	Graph[Vertex] dynamicCG = convertJsonToGraph(dynamicCallMapLoc, sourceLocationMapping);
	println("The precision is <calculatePrecision(staticCG, dynamicCG)>%");
	println("The recall is <calculateRecall(staticCG, dynamicCG)>%");
}

private real calculatePrecision(Graph[Vertex] staticCG, Graph[Vertex] dynamicCG) {
	int intersection = size(dynamicCG & staticCG);
	return intersection / size(staticCG);
}

private real calculateRecall(Graph[Vertex] staticCG, Graph[Vertex] dynamicCG) {
	int intersection = size(dynamicCG & staticCG);
	return intersection / size(dynamicCG);
}