module dynamicgraph::testing::ProvidedSourcesTests

import dynamicgraph::DynamicCallGraphReader;
import analysis::graphs::Graph;
import dynamicgraph::StaticDynamicCallGraphComparator;
import util::Math;
import utils::GraphUtils;
import IO;
import Set;
import Relation;

public real tolerance = 0.1;
public bool doFrameworkFiltering = false;

public test bool testPacmanPessimistic() {
	loc staticLoc = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/testing/snippets/provided/pacman/pessimistic.json|;
	loc dynamicLoc = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/testing/snippets/provided/pacman/dynamic.json|;
	return numbersAreCorrect(staticLoc, dynamicLoc, 93.9, 100.0, {});
}

public test bool testPacmanOptimistic() {
	loc staticLoc = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/testing/snippets/provided/pacman/optimistic.json|;
	loc dynamicLoc = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/testing/snippets/provided/pacman/dynamic.json|;
	return numbersAreCorrect(staticLoc, dynamicLoc, 80.9, 94.2, {});
}

public test bool test3dModelPessimistic() {
	loc staticLoc = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/testing/snippets/provided/3dmodel/pessimistic.json|;
	loc dynamicLoc = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/testing/snippets/provided/3dmodel/dynamic.json|;
	return numbersAreCorrect(staticLoc, dynamicLoc, 93.3, 100.0, {});
}

public test bool test3dModelOptimistic() {
	loc staticLoc = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/testing/snippets/provided/3dmodel/optimistic.json|;
	loc dynamicLoc = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/testing/snippets/provided/3dmodel/dynamic.json|;
	return numbersAreCorrect(staticLoc, dynamicLoc, 93.3, 100.0, {});
}

public test bool testMarkItUpPessimistic() {
	loc staticLoc = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/testing/snippets/provided/markitup/pessimistic.json|;
	loc dynamicLoc = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/testing/snippets/provided/markitup/dynamic.json|;
	return numbersAreCorrect(staticLoc, dynamicLoc, 82.4, 93.9, {"jquery-1.6.2"});
}

public test bool testHtmlEditPessimistic() {
	loc staticLoc = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/testing/snippets/provided/htmledit/pessimistic.json|;
	loc dynamicLoc = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/testing/snippets/provided/htmledit/dynamic.json|;
	return numbersAreCorrect(staticLoc, dynamicLoc, 80.9, 94.2, {"jquery-1.3.2"});
}

public bool numbersAreCorrect(loc staticGraphJson, loc dynamicGraphJson, real expectedPrecision, real expectedRecall, set[str] frameworkFunctions) {
	Graph[str] staticGraph = convertJsonToGraph(staticGraphJson), dynamicGraph = convertJsonToGraph(dynamicGraphJson);
	println("Edges in static: <size(staticGraph)> edges in dynamic: <size(dynamicGraph)>");
	if (doFrameworkFiltering) {
		println("filtering");
		staticGraph = filterFrameworkEdges(staticGraph, frameworkFunctions);
		dynamicGraph = filterFrameworkEdges(dynamicGraph, frameworkFunctions);
		println("After filtering: Edges in static: <size(staticGraph)> edges in dynamic: <size(dynamicGraph)>");
	}
	real precision = calculatePrecision(staticGraph, dynamicGraph), recall = calculateRecall(staticGraph, dynamicGraph);
	println("Precision: <precision>, recall : <recall>");
	return abs(expectedPrecision - precision) < tolerance && abs(expectedRecall - recall) < tolerance;
}