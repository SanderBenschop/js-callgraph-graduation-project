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
	if (callSiteAnalysis) println("INFO - Call site analysis comparison");
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
	
	real intersectionSize, firstSize;
	if (callSiteAnalysis) {
		return calculateMetricPerCallSite(first, second, firstIsStatic);
	} else {
		if (compareCoveredCodeOnly) {
			println("Filtering out code not covered in the dynamic call graph!");
			set[str] dynamicCallees = firstIsStatic ? domain(second) : domain(first);
			
			if (firstIsStatic) first = {tup | tuple[str callee, str target] tup <- first, tup.callee in dynamicCallees};
			else second = {tup | tuple[str callee, str target] tup <- second, tup.callee in dynamicCallees};
		}
	
		intersectionSize = toReal(size(first & second));
		firstSize = toReal(size(first));
		return intersectionSize / firstSize * 100;
	}	
}

	
public real calculatePrecisionPerCallsite(Graph[str] staticCG, Graph[str] dynamicCG) = calculateMetricPerCallSite(staticCG, dynamicCG, true);
public real calculateRecallPerCallsite(Graph[str] staticCG, Graph[str] dynamicCG) = calculateMetricPerCallSite(dynamicCG, staticCG, false);

private real calculateMetricPerCallSite(Graph[str] first, Graph[str] second, bool firstIsStatic) {
	map[int, int] count = ();
	
	int total100 = 0, singleCallSite100 = 0;	
	
	real cumulative = 0.0;
	set[str] theDomain = firstIsStatic ? domain(second) : domain(first);
	for (str callSite <- theDomain) {
		set[str] firstTargets = first[callSite], secondTargets = second[callSite];
		if (size(firstTargets) != 0) {
			real thisMetric = toReal(size(firstTargets & secondTargets)) / size(firstTargets);
			cumulative += thisMetric;
			
			int rounded = round(thisMetric * 100);
			if (rounded notin count) count += (rounded : 1);
			else count[rounded] = count[rounded] + 1;
			
			if (rounded == 100) {
				total100 += 1;
				if (size(firstTargets) == 1) singleCallSite100 += 1;
			}
		}
	}
	int divisor = averageOverIntersection ? size(domain(first) & domain(second)) : size(theDomain);
	println("Cumulative: <cumulative> divisor: <divisor>");
	println("Rounded precision occurences (key is rounded percentage, value is occurences):");
	println(count);
	println("Of the total <total100> call sites with 100% score, <singleCallSite100> had a single target.");
	return cumulative / divisor * 100;
}