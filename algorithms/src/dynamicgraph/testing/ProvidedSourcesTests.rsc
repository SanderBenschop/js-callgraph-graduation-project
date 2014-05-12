module dynamicgraph::testing::ProvidedSourcesTests

import dynamicgraph::DynamicCallGraphReader;
import analysis::graphs::Graph;
import dynamicgraph::StaticDynamicCallGraphComparator;
import util::Math;
import IO;

public real tolerance = 0.1;

public test bool testPacmanPessimistic() {
	loc staticLoc = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/testing/snippets/provided/pacman/pessimistic.json|;
	loc dynamicLoc = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/testing/snippets/provided/pacman/dynamic.json|;
	return numbersAreCorrect(staticLoc, dynamicLoc, 93.9, 100.0);
}

public test bool testPacmanOptimistic() {
	loc staticLoc = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/testing/snippets/provided/pacman/optimistic.json|;
	loc dynamicLoc = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/testing/snippets/provided/pacman/dynamic.json|;
	return numbersAreCorrect(staticLoc, dynamicLoc, 80.9, 94.2);
}

public test bool test3dModelPessimistic() {
	loc staticLoc = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/testing/snippets/provided/3dmodel/pessimistic.json|;
	loc dynamicLoc = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/testing/snippets/provided/3dmodel/dynamic.json|;
	return numbersAreCorrect(staticLoc, dynamicLoc, 93.3, 100.0);
}

public test bool test3dModelOptimistic() {
	loc staticLoc = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/testing/snippets/provided/3dmodel/optimistic.json|;
	loc dynamicLoc = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/testing/snippets/provided/3dmodel/dynamic.json|;
	return numbersAreCorrect(staticLoc, dynamicLoc, 93.3, 100.0);
}

public bool numbersAreCorrect(loc staticGraphJson, loc dynamicGraphJson, real expectedPrecision, real expectedRecall) {
	Graph[str] staticGraph = convertJsonToGraph(staticGraphJson), dynamicGraph = convertJsonToGraph(dynamicGraphJson);
	real precision = calculatePrecision(staticGraph, dynamicGraph), recall = calculateRecall(staticGraph, dynamicGraph);
	println("Precision: <precision>, recall : <recall>");
	return abs(expectedPrecision - precision) < tolerance && abs(expectedRecall - recall) < tolerance;
}