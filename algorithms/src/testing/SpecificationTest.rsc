module testing::SpecificationTest

import analysis::graphs::Graph;

import testing::SpecificationTestGenerator;
import Main;
import DataStructures;
import Relation;
import IO;
import String;

public test bool nRandomTests() {
	for (int i <- [0..1000]) {
		randomTest();
	}
	return true;
}

public void randomTest() {
	tuple[str code, Graph[Expectation] expectations] generatedProgram = arbProgram();
	
	Graph[Vertex] flowGraph;
	try 
		flowGraph = createFlowGraph(generatedProgram.code);
	catch ParseError : {
		println("A parse error occured. Source:");
		println(generatedProgram.code);
		throw "Parse error occured";
	}
	
	if (countNumberOfEdges(flowGraph) != countNumberOfEdges(generatedProgram.expectations)) {
		throw "There is a mismatch between the number of actual edges and the number of expected edges. Actual: <flowGraph>. Expected: <generatedProgram.expectations>";
	}
	
	for (Expectation base <- domain(generatedProgram.expectations)) {
		set[Expectation] targets = generatedProgram.expectations[base];
		for (Expectation target <- targets) {
			if (!thereExistsVertex(base, target, flowGraph, generatedProgram.code)) {
				throw "There is no edge from <base> to <target> for source <generatedProgram.code>";
			}
		}
	}
}

private bool thereExistsVertex(Expectation from, Expectation to, Graph[Vertex] flowGraph, str program) {
	for (Vertex base <- domain(flowGraph)) {
		set[Vertex] targets = flowGraph[base];
		for (Vertex target <- targets) {
			if (expectation(fromType, fromValue) := from && expectation(toType, toValue) := to) {
				ExpectationType leftType = getExpectationType(base), rightType = getExpectationType(target);
				str leftValue = getVertexValue(program, base), rightValue = getVertexValue(program, target);
				if (fromType == leftType && removeLayout(fromValue) == removeLayout(leftValue)
					&& toType == rightType && removeLayout(toValue) == removeLayout(rightValue)) {
					return true;	
				}
			}
		}
	}
	return false;
}

public str removeLayout(str source) {
	str trimmed = replaceAll(source, "\n", "");
	trimmed = replaceAll(trimmed, "\t", "");
	return trimmed;
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

public str getTextInString(str source, loc location) {
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