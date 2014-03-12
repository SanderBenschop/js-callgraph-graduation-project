module testing::FlowGraphTest

import analysis::graphs::Graph;
import IO;

import Main;
import DataStructures;

public test bool testOneOrTwo() {
	Graph[Vertex] flowGraph = createFlowGraph(|project://JavaScript%20cg%20algorithms/src/testing/snippets/oneOrTwo.js|);
	return flowGraph == {
		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/oneOrTwo.js|(5,1,<1,5>,<1,6>)),Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/oneOrTwo.js|(0,6,<1,0>,<1,6>))>,
		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/oneOrTwo.js|(0,1,<1,0>,<1,1>)),Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/oneOrTwo.js|(0,6,<1,0>,<1,6>))>
	};
}

public test bool testOneAndTwo() {
	Graph[Vertex] flowGraph = createFlowGraph(|project://JavaScript%20cg%20algorithms/src/testing/snippets/oneAndTwo.js|);
	println(flowGraph);
	return flowGraph == {
		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/oneAndTwo.js|(5,1,<1,5>,<1,6>)),Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/oneAndTwo.js|(0,6,<1,0>,<1,6>))>
	};
}

public test bool testTernary() {
	Graph[Vertex] flowGraph = createFlowGraph(|project://JavaScript%20cg%20algorithms/src/testing/snippets/ternary.js|);
	return flowGraph == {
		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/ternary.js|(11,1,<1,11>,<1,12>)), Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/ternary.js|(0,12,<1,0>,<1,12>))>,
		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/ternary.js|(7,1,<1,7>,<1,8>)),Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/ternary.js|(0,12,<1,0>,<1,12>))>
	};
}

//Should pass when properties are implemented
public test bool testObjectAssignment() {
	Graph[Vertex] flowGraph = createFlowGraph(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignObjectToVariable.js|);
  	return flowGraph == {
		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignObjectToVariable.js|(12,6,<1,12>,<1,18>)),Property("key1")>,
		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignObjectToVariable.js|(27,6,<1,27>,<1,33>)),Property("key2")>
	};
}