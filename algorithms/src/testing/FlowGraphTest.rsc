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
		<Property("value2"),Property("key2")>,
		<Property("value1"),Property("key1")>,
		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignObjectToVariable.js|(4,30,<1,4>,<1,34>)),Property("a")>
	};
}

public test bool testAssignNamedFunctionExpr() {
	Graph[Vertex] flowGraph = createFlowGraph(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignNamedFunctionExpr.js|);
	return flowGraph == {
	  <Function(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignNamedFunctionExpr.js|(4,14,<1,4>,<1,18>)),Variable(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignNamedFunctionExpr.js|(4,14,<1,4>,<1,18>))>,
	  <Function(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignNamedFunctionExpr.js|(4,14,<1,4>,<1,18>)),Property("a")>,
	  <Function(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignNamedFunctionExpr.js|(4,14,<1,4>,<1,18>)),Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignNamedFunctionExpr.js|(4,14,<1,4>,<1,18>))>
	};
}

public test bool testAssignNamelessFunctionExpr() {
	Graph[Vertex] flowGraph = createFlowGraph(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignNamelessFunctionExpr.js|);
	return flowGraph == {
		  <Function(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignNamelessFunctionExpr.js|(4,12,<1,4>,<1,16>)),Property("a")>,
		<Function(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignNamelessFunctionExpr.js|(4,12,<1,4>,<1,16>)),Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignNamelessFunctionExpr.js|(4,12,<1,4>,<1,16>))>
	};
}

public test bool testFunctionDeclaration() {
	Graph[Vertex] flowGraph = createFlowGraph(|project://JavaScript%20cg%20algorithms/src/testing/snippets/functionDecl.js|);
	return flowGraph == {
		<Function(|project://JavaScript%20cg%20algorithms/src/testing/snippets/functionDecl.js|(0,21,<1,0>,<3,1>)),Variable(|project://JavaScript%20cg%20algorithms/src/testing/snippets/functionDecl.js|(0,21,<1,0>,<3,1>))>
	};
}

public test bool testAssignOneToVarX() {
	Graph[Vertex] flowGraph = createFlowGraph(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToVarX.js|);
	return flowGraph == {
 		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToVarX.js|(24,1,<2,9>,<2,10>)),Variable(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToVarX.js|(20,1,<2,5>,<2,6>))>,
  		<Function(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToVarX.js|(0,27,<1,0>,<3,1>)),Variable(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToVarX.js|(0,27,<1,0>,<3,1>))>
	};
}

public test bool testAssignOneToX() {
	Graph[Vertex] flowGraph = createFlowGraph(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToX.js|);
	return flowGraph == {
  		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToX.js|(20,1,<2,5>,<2,6>)),Property("x")>,
  		<Function(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToX.js|(0,23,<1,0>,<3,1>)),Variable(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToX.js|(0,23,<1,0>,<3,1>))>
	};
}