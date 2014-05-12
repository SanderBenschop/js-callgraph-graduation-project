module dynamicgraph::StaticDynamicCallGraphComparator

import ValueIO;
import dynamicgraph::DynamicCallGraphReader;
import DataStructures;
import analysis::graphs::Graph;
import IO;
import Set;
import String;
import util::Math;
import utils::GraphUtils;
import Configuration;
import Relation;

public void printStatisticsWithoutNatives(Graph[str] staticCG, Graph[str] dynamicCG) {
	Graph[str] filteredStaticCG = filterNatives(staticCG);
	Graph[str] filteredDynamicCG = filterNatives(dynamicCG);
	printStatistics(filteredStaticCG, filteredDynamicCG);
}

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
	real intersection, staticCallGraphSize;
	if (compareCallTargetsOnly) {
		set[str] staticDomain = domain(staticCG), dynamicDomain = domain(dynamicCG);
		intersection = toReal(size(dynamicDomain & staticDomain));
		staticCallGraphSize = toReal(size(staticDomain));
	} else {
		intersection = toReal(size(dynamicCG & staticCG));
		staticCallGraphSize = toReal(size(staticCG));
	}
		
	return intersection / staticCallGraphSize * 100;
}

//Recall can be calculated by switching around the static and dynamic graph as the calculation is exactly the same.
public real calculateRecall(Graph[str] staticCG, Graph[str] dynamicCG) = calculatePrecision(dynamicCG, staticCG);

/*
function countEdges(graph) {
	var i = 0;
	for (base in graph) {
	    var arr = graph[base];
	    arr.forEach(function()	{
	        i++;
	    });
	}
	return i;
}

*/