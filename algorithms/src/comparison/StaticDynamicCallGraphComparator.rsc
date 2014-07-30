module comparison::StaticDynamicCallGraphComparator

import ValueIO;
import dynamicanalysis::DynamicCallGraphReader;
import staticanalysis::DataStructures;
import analysis::graphs::Graph;
import IO;
import Set;
import String;
import util::Math;
import utils::GraphUtils;
import staticanalysis::Configuration;
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

public real calculatePrecision(Graph[str] staticCG, Graph[str] dynamicCG) = calculateMetric(staticCG, dynamicCG, true);
public real calculateRecall(Graph[str] staticCG, Graph[str] dynamicCG) = calculateMetric(dynamicCG, staticCG, false);

private real calculateMetric(Graph[str] first, Graph[str] second, bool firstIsStatic) {
	if (filterNativeFunctions) {
		first = filterNatives(first);
		second = filterNatives(second);
	}
	
	if (compareCoveredCodeOnly) {
		println("Filtering out code not covered in the dynamic call graph!");
		set[str] dynamicCallees = firstIsStatic ? domain(second) : domain(first);
		first = {tup | tuple[str callee, str target] tup <- first, tup.callee in dynamicCallees};
	}

	real intersectionSize, firstSize;
	if (compareCallTargetsOnly) {
		set[str] firstrange = range(first), secondrange = range(second);
		intersectionSize = toReal(size(firstrange & secondrange));
		firstSize = toReal(size(firstrange));
	} else {
		intersectionSize = toReal(size(first & second));
		firstSize = toReal(size(first));
	}
	
	return intersectionSize / firstSize * 100;
}

	
public real calculatePrecisionPerCallsite(Graph[str] staticCG, Graph[str] dynamicCG) = calculateMetricPerCallSite(staticCG, dynamicCG, true);
public real calculateRecallPerCallsite(Graph[str] staticCG, Graph[str] dynamicCG) = calculateMetricPerCallSite(dynamicCG, staticCG, false);

private real calculateMetricPerCallSite(Graph[str] first, Graph[str] second, bool leftIsStatic) {
	real cumulative = 0.0;
	int numberOfCallSites = 0;
	set[str] theDomain = leftIsStatic ? domain(second) : domain(first);
	for (str callSite <- theDomain) {
		set[str] firstTargets = first[callSite], secondTargets = second[callSite];
		numberOfCallSites += 1;
		if (size(firstTargets) != 0)
		cumulative += toReal(size(firstTargets & secondTargets)) / size(firstTargets);
	}
	println("Cumulative: <cumulative> divider: <numberOfCallSites>");
	return cumulative / numberOfCallSites * 100;
}