module dynamicgraph::StaticDynamicCallGraphComparator

import ValueIO;
import dynamicgraph::DynamicCallGraphReader;
import DataStructures;
import analysis::graphs::Graph;
import IO;
import Set;
import util::Math;
import utils::GraphUtils;

public void printStatistics(Graph[Vertex] staticCG, loc dynamicCallMapLoc) {
	Graph[str] stringGraph = convertVertexGraphToStringGraph(staticCG);
	printStatistics(stringGraph, dynamicCallMapLoc);
}

public void printStatistics(Graph[str] staticCG, loc dynamicCallMapLoc) {
	Graph[str] dynamicCG = convertJsonToGraph(dynamicCallMapLoc);
	printStatistics(staticCG, dynamicCG);
}

public void printStatistics(Graph[str] staticCG, Graph[str] dynamicCG) {
	println("The precision is <calculatePrecision(staticCG, dynamicCG)>%");
	println("The recall is <calculateRecall(staticCG, dynamicCG)>%");
}

public real calculatePrecision(Graph[str] staticCG, Graph[str] dynamicCG) {
	real intersection = toReal(size(dynamicCG & staticCG));
	real staticCallGraphSize = toReal(size(staticCG));
	return intersection / staticCallGraphSize * 100;
}

public real calculateRecall(Graph[str] staticCG, Graph[str] dynamicCG) {
	real intersection = tdoReal(size(dynamicCG & staticCG));
	real dynamicCallGraphSize = toReal(size(dynamicCG));
	return intersection / dynamicCallGraphSize * 100;
}

/*

var i = 0;
for (base in stat) {
    var arr = stat[base];
    arr.forEach(function(){
        i++;
    });
}
console.log(i);

*/