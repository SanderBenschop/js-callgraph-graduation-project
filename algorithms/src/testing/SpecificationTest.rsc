module testing::SpecificationTest

import analysis::graphs::Graph;

import testing::SpecificationTestGenerator;
import Main;
import DataStructures;
import Relation;
import IO;
import String;

public void randomTest() {
	tuple[str code, Graph[Expectation] expectations] generatedProgram = arbProgram();
	Graph[Vertex] flowGraph = createFlowGraph(generatedProgram.code);
	
	if (countNumberOfEdges(flowGraph) != countNumberOfEdges(generatedProgram.expectations)) {
		throw "There is a mismatch between the number of actual edges and the number of expected edges. Actual: <flowGraph>. Expected: <generatedProgram.expectations>";
	}
	
	for (Vertex base <- domain(flowGraph)) {
		set[Vertex] targets = flowGraph[base];
		for (Vertex target <- targets) {
			ExpectationType leftType = getExpectationType(base), rightType = getExpectationType(target);
			str leftValue = getVertexValue(generatedProgram.code, base), rightValue = getVertexValue(generatedProgram.code, target);
			Expectation left = expectation(leftType, leftValue), right = expectation(rightType, rightValue);
			if (!thereExistsEdge(left, right, generatedProgram.expectations)) {
				throw "There is no expectation edge from <left> to <right>";
			}
		}
	}
}

private bool thereExistsEdge(Expectation from, Expectation to, Graph[Expectation] expectations) {
	println(expectations);
	for (Expectation base <- domain(expectations)) {
		set[Expectation] targets = expectations[base];
		for (Expectation target <- targets) {
			if (base == from && target == to) return true;
		}
	}
	return false;
}

private str getVertexValue(str source, Vertex vertex) {
	switch(vertex) {
		case Expression(position) : return getTextInString(source, position);
		case Variable(position) : return getTextInString(source, position);
		case Property(name) : return name;
		case Function(position) : return getTextInString(source, position);
	}
	throw "Unsupported type <vertex>";
}

private ExpectationType getExpectationType(Vertex vertex) {
	switch(vertex) {
		case Expression(position) : return expression();
		case Variable(position) : return variable();
		case Property(name) : return property();
		case Function(position) : return function();
	}
	throw "Unsupported type <vertex>";
}

private str getTextInString(str source, loc location) {
	int begin = location.offset, end = begin + location.length;
	return substring(source, begin, end);
}

private int countNumberOfEdges(graph) {
	int count = 0;
	for (base <- domain(graph)) {
		targets = graph[base];
		for (target <- targets) {
			count += 1;
		}
	}
	return count;
}