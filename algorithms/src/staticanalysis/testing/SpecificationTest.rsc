module staticanalysis::testing::SpecificationTest

import analysis::graphs::Graph;
import util::Maybe;

import testing::SpecificationTestGenerator;
import staticanalysis::Main;
import staticanalysis::DataStructures;
import Relation;
import IO;
import String;
import Set;
import staticanalysis::PrettyPrinter;

private loc GENERATED_SNIPPET_FOLDER = |project://JavaScript%20cg%20algorithms/src/staticanalysis/testing/snippets/generated|;

public void generateNRandomSnippets(int n) {
	loc generatedFolder = GENERATED_SNIPPET_FOLDER;
	int parsedWithErrors = 0;
	for (int i <- [0..n]) {
		try {
			str program = randomTest();
			loc target = GENERATED_SNIPPET_FOLDER + "snippet-<i>.js";
			writeFile(target, program);
		}
		catch _: parsedWithErrors += 1;
	}
	println("Of the total <n> planned executions, <parsedWithErrors> failed due to parse errors.");
}

public bool nRandomTests() = nRandomTests(1000);
public bool nRandomTests(int n) {
	int parsedWithErrors = 0;
	for (int i <- [0..n]) {
		try
			randomTest();
		catch ParseError(_) : parsedWithErrors += 1;
	}
	println("Of the total <n> planned executions, <parsedWithErrors> failed due to parse errors.");
	return true;
}

public str randomTest() {
	tuple[str code, Graph[Expectation] expectations] generatedProgram = arbProgram();
	
	Graph[Vertex] flowGraph;
	try 
		flowGraph = createIntraProceduralFlowGraph(generatedProgram.code);
	catch e: {
		println("A parse error occured. Source:");
		println(generatedProgram.code);
		throw e;
	}
	
	Graph[Vertex] matchedEdges = {};
	for (Expectation base <- domain(generatedProgram.expectations)) {
		set[Expectation] targets = generatedProgram.expectations[base];
		for (Expectation target <- targets) {
			Maybe[tuple[Vertex, Vertex]] soughtVertex = thereExistsVertex(base, target, flowGraph, generatedProgram.code);
			if (just(tuple[Vertex, Vertex] matchedEdge) := soughtVertex) {
				matchedEdges += matchedEdge;
			} else {
				println("There is no edge from <base> to <target>");
				println("Source: \n <generatedProgram.code>");
				println("Flow graph: \n <flowGraph>");
				throw "MissingEdge";
			}
		}
	}
	
	if (countNumberOfEdges(flowGraph) != countNumberOfEdges(matchedEdges)) {
		println("There is a mismatch between the number of actual edges and the number of expected edges");
		println("Total number of actual edges: <countNumberOfEdges(flowGraph)>");
		println("Total number of expected edges: <countNumberOfEdges(generatedProgram.expectations)>");
		println("Actual:\n <mapper(flowGraph, replaceTupleLocs)>");
		println("Expectations:\n <generatedProgram.expectations>");
		println("Source:\n <generatedProgram.code>");
		println("Unmatched edges:");
		Graph[Vertex] unmatchedEdges = flowGraph - matchedEdges;
		writeFile(|project://JavaScript%20cg%20algorithms/src/testing/filedump/dump.js|, generatedProgram.code);
		for (Vertex base <- domain(unmatchedEdges)) {
			for (Vertex target <- unmatchedEdges[base]) {
				ExpectationType baseType = getExpectationType(base), targetType = getExpectationType(target);
				str baseValue = getVertexValue(generatedProgram.code, base), targetValue = getVertexValue(generatedProgram.code, target);
				println("<expectation(baseType, baseValue)> -\> <expectation(targetType, targetValue)>");
				println("Created from vertex <replaceLocs(base)> to <replaceLocs(target)>");
			}
		}
		throw "EdgeExpectationMismatch";
	}
	
	return generatedProgram.code;
}

public tuple[Vertex, Vertex] replaceTupleLocs(tuple[Vertex left, Vertex right] oldTuple) = <replaceLocs(oldTuple.left), replaceLocs(oldTuple.right)>;

private Vertex replaceLocs(Vertex vertex) {
	switch(vertex) {
		case Expression(position) : return Expression(replaceLoc(position));
		case Variable(name,position) : return Variable(name, replaceLoc(position));
		case property:Property(_) : return property;
		case Function(position) : return Function(replaceLoc(position));
	}
	throw "Unsupported type <vertex>";
}

public loc replaceLoc(loc original) {
	int O = original.offset, L = original.length, 
		BL = original.begin.line, BC = original.begin.column,
		EL = original.end.line, EC = original.end.column;
	return |project://JavaScript%20cg%20algorithms/src/testing/filedump/dump.js|(O, L, <BL, BC> , <EL,EC>);
}

private Maybe[tuple[Vertex, Vertex]] thereExistsVertex(Expectation from, Expectation to, Graph[Vertex] flowGraph, str program) {
	for (Vertex base <- domain(flowGraph)) {
		set[Vertex] targets = flowGraph[base];
		for (Vertex target <- targets) {
			if (expectation(fromType, fromValue, _) := from && expectation(toType, toValue, _) := to) {
				ExpectationType leftType = getExpectationType(base), rightType = getExpectationType(target);
				str leftValue = getVertexValue(program, base), rightValue = getVertexValue(program, target);
				if (fromType == leftType && removeLayout(fromValue) == removeLayout(leftValue)
					&& toType == rightType && removeLayout(toValue) == removeLayout(rightValue)) {
					return just(<base, target>);
				}
			}
		}
	}
	return nothing();
}

public str removeLayout(str source) {
	str trimmed = replaceAll(source, "\n", "");
	trimmed = replaceAll(trimmed, "\t", "");
	trimmed = replaceAll(trimmed, " ", "");
	return trimmed;
}

private str getVertexValue(str source, Vertex vertex) {
	switch(vertex) {
		case Expression(position) : return getTextInString(source, position);
		case Variable(_,position) : return getTextInString(source, position);
		case Property(name) : return name;
		case Function(position) : return getTextInString(source, position);
	}
	throw "Unsupported type <vertex>";
}

private ExpectationType getExpectationType(Vertex vertex) {
	switch(vertex) {
		case Expression(_) : return expression();
		case Variable(_,_) : return variable();
		case Property(_) : return property();
		case Function(_) : return function();
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