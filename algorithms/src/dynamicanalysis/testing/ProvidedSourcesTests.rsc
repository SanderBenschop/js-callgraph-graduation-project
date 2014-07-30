module dynamicanalysis::testing::ProvidedSourcesTests

import dynamicanalysis::DynamicCallGraphReader;
import analysis::graphs::Graph;
import comparison::StaticDynamicCallGraphComparator;
import util::Math;
import utils::GraphUtils;
import IO;
import Set;
import Relation;

public real tolerance = 0.1;
public bool doFrameworkFiltering = false;

public test bool testPacmanPessimistic() {
	loc staticLoc = |project://JavaScript%20cg%20algorithms/src/dynamicanalysis/testing/snippets/provided/pacman/pessimistic.json|;
	loc dynamicLoc = |project://JavaScript%20cg%20algorithms/src/dynamicanalysis/testing/snippets/provided/pacman/dynamic.json|;
	return numbersAreCorrect(staticLoc, dynamicLoc, 93.9, 100.0, {});
	//Precision: 93.942099567056200, recall : 100.0
}

public test bool testPacmanOptimistic() {
	loc staticLoc = |project://JavaScript%20cg%20algorithms/src/dynamicanalysis/testing/snippets/provided/pacman/optimistic.json|;
	loc dynamicLoc = |project://JavaScript%20cg%20algorithms/src/dynamicanalysis/testing/snippets/provided/pacman/dynamic.json|;
	return numbersAreCorrect(staticLoc, dynamicLoc, 80.9, 94.2, {});
	//Precision: 91.7748917749000, recall : 97.7272727300		
}

public test bool test3dModelPessimistic() {
	loc staticLoc = |project://JavaScript%20cg%20algorithms/src/dynamicanalysis/testing/snippets/provided/3dmodel/pessimistic.json|;
	loc dynamicLoc = |project://JavaScript%20cg%20algorithms/src/dynamicanalysis/testing/snippets/provided/3dmodel/dynamic.json|;
	return numbersAreCorrect(staticLoc, dynamicLoc, 93.3, 100.0, {});
}

public test bool test3dModelOptimistic() {
	loc staticLoc = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/testing/snippets/provided/3dmodel/optimistic.json|;
	loc dynamicLoc = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/testing/snippets/provided/3dmodel/dynamic.json|;
	return numbersAreCorrect(staticLoc, dynamicLoc, 93.3, 100.0, {});
}

public test bool testMarkItUpPessimistic() {
	loc staticLoc = |project://JavaScript%20cg%20algorithms/src/dynamicanalysis/testing/snippets/provided/markitup/pessimistic.json|;
	loc dynamicLoc = |project://JavaScript%20cg%20algorithms/src/dynamicanalysis/testing/snippets/provided/markitup/dynamic.json|;
	return numbersAreCorrect(staticLoc, dynamicLoc, 82.4, 93.9, {"jquery-1.6.2"});
	//Precision: 60.13997160377400, recall : 71.5341959300
}

public test bool testMarkItUpOptimistic() {
	loc staticLoc = |project://JavaScript%20cg%20algorithms/src/dynamicanalysis/testing/snippets/provided/markitup/optimistic.json|;
	loc dynamicLoc = |project://JavaScript%20cg%20algorithms/src/dynamicanalysis/testing/snippets/provided/markitup/dynamic.json|;
	return numbersAreCorrect(staticLoc, dynamicLoc, -1.0, -1.0, {"jquery-1.6.2"});
	//precision: 56.55995133638400, recall : 68.4842883500
}

public test bool testBeslimedPessimistic() {
	loc staticLoc = |project://JavaScript%20cg%20algorithms/src/dynamicanalysis/testing/snippets/provided/beslimed/pessimistic.json|;
	loc dynamicLoc = |project://JavaScript%20cg%20algorithms/src/dynamicanalysis/testing/snippets/provided/beslimed/dynamic.json|;
	return numbersAreCorrect(staticLoc, dynamicLoc, -1.0, -1.0, {"jquery-1.3.2"});
	//Precision: 65.33860363169800, recall : 84.5013477100
}

public test bool testBeslimedOptimistic() {
	loc staticLoc = |project://JavaScript%20cg%20algorithms/src/dynamicanalysis/testing/snippets/provided/beslimed/optimistic.json|;
	loc dynamicLoc = |project://JavaScript%20cg%20algorithms/src/dynamicanalysis/testing/snippets/provided/beslimed/dynamic.json|;
	return numbersAreCorrect(staticLoc, dynamicLoc, -1.0, -1.0, {"jquery-1.3.2"});
	//Precision: 61.745945149662800, recall : 89.4878706200
}

public test bool testHtmlEditPessimistic() {
	loc staticLoc = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/testing/snippets/provided/htmledit/pessimistic.json|;
	loc dynamicLoc = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/testing/snippets/provided/htmledit/dynamic.json|;
	return numbersAreCorrect(staticLoc, dynamicLoc, 80.9, 94.2, {"jquery-1.3.2"});
}

public bool numbersAreCorrect(loc staticGraphJson, loc dynamicGraphJson, real expectedPrecision, real expectedRecall, set[str] frameworkFunctions) {
	Graph[str] staticGraph = convertJsonToGraph(staticGraphJson, false), dynamicGraph = convertJsonToGraph(dynamicGraphJson, false);
	println("Edges in static: <size(staticGraph)> edges in dynamic: <size(dynamicGraph)>");
	if (doFrameworkFiltering) {
		println("filtering");
		staticGraph = filterFrameworkEdges(staticGraph, frameworkFunctions);
		dynamicGraph = filterFrameworkEdges(dynamicGraph, frameworkFunctions);
		println("After filtering: Edges in static: <size(staticGraph)> edges in dynamic: <size(dynamicGraph)>");
	}
	real precision = calculatePrecisionPerCallsite(staticGraph, dynamicGraph), recall = calculateRecallPerCallsite(staticGraph, dynamicGraph);
	println("Precision: <precision>, recall : <recall>");
	return abs(expectedPrecision - precision) < tolerance && abs(expectedRecall - recall) < tolerance;
}