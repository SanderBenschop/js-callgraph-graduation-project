module testing::FlowGraphTest

import analysis::graphs::Graph;
import IO;

import Main;
import DataStructures;

public test bool testOneOrTwo() {
	Graph[Vertex] flowGraph = createIntraProceduralFlowGraph(|project://JavaScript%20cg%20algorithms/src/testing/snippets/oneOrTwo.js|);
	return flowGraph == {
		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/oneOrTwo.js|(5,1,<1,5>,<1,6>)),Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/oneOrTwo.js|(0,6,<1,0>,<1,6>))>,
		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/oneOrTwo.js|(0,1,<1,0>,<1,1>)),Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/oneOrTwo.js|(0,6,<1,0>,<1,6>))>
	};
}

public test bool testOneAndTwo() {
	Graph[Vertex] flowGraph = createIntraProceduralFlowGraph(|project://JavaScript%20cg%20algorithms/src/testing/snippets/oneAndTwo.js|);
	println(flowGraph);
	return flowGraph == {
		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/oneAndTwo.js|(5,1,<1,5>,<1,6>)),Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/oneAndTwo.js|(0,6,<1,0>,<1,6>))>
	};
}

public test bool testTernary() {
	Graph[Vertex] flowGraph = createIntraProceduralFlowGraph(|project://JavaScript%20cg%20algorithms/src/testing/snippets/ternary.js|);
	return flowGraph == {
		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/ternary.js|(11,1,<1,11>,<1,12>)), Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/ternary.js|(0,12,<1,0>,<1,12>))>,
		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/ternary.js|(7,1,<1,7>,<1,8>)),Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/ternary.js|(0,12,<1,0>,<1,12>))>
	};
}

//Should pass when properties are implemented
public test bool testObjectAssignment() {
	Graph[Vertex] flowGraph = createIntraProceduralFlowGraph(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignObjectToVariable.js|);
  	return flowGraph == {
		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignObjectToVariable.js|(4,30,<1,4>,<1,34>)),Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignObjectToVariable.js|(0,34,<1,0>,<1,34>))>,
		<Property("value2"),Property("key2")>,
		<Property("value1"),Property("key1")>,
		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignObjectToVariable.js|(4,30,<1,4>,<1,34>)),Property("a")>
	};
}

public test bool testAssignNamedFunctionExpr() {
	Graph[Vertex] flowGraph = createIntraProceduralFlowGraph(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignNamedFunctionExpr.js|);
	return flowGraph == {
		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignNamedFunctionExpr.js|(4,14,<1,4>,<1,18>)),Property("a")>,
		<Function(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignNamedFunctionExpr.js|(4,14,<1,4>,<1,18>)),Variable("f", |project://JavaScript%20cg%20algorithms/src/testing/snippets/assignNamedFunctionExpr.js|(4,14,<1,4>,<1,18>))>,
		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignNamedFunctionExpr.js|(4,14,<1,4>,<1,18>)),Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignNamedFunctionExpr.js|(0,18,<1,0>,<1,18>))>,
		<Function(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignNamedFunctionExpr.js|(4,14,<1,4>,<1,18>)),Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignNamedFunctionExpr.js|(4,14,<1,4>,<1,18>))>
	};
}

public test bool testAssignNamelessFunctionExpr() {
	Graph[Vertex] flowGraph = createIntraProceduralFlowGraph(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignNamelessFunctionExpr.js|);
	return flowGraph == {
 		<Function(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignNamelessFunctionExpr.js|(4,12,<1,4>,<1,16>)),Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignNamelessFunctionExpr.js|(4,12,<1,4>,<1,16>))>,
		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignNamelessFunctionExpr.js|(4,12,<1,4>,<1,16>)),Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignNamelessFunctionExpr.js|(0,16,<1,0>,<1,16>))>,
		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignNamelessFunctionExpr.js|(4,12,<1,4>,<1,16>)),Property("a")>
	};
}

public test bool testFunctionDeclaration() {
	Graph[Vertex] flowGraph = createIntraProceduralFlowGraph(|project://JavaScript%20cg%20algorithms/src/testing/snippets/functionDecl.js|);
	return flowGraph == {
		<Function(|project://JavaScript%20cg%20algorithms/src/testing/snippets/functionDecl.js|(0,21,<1,0>,<3,1>)),Variable("test", |project://JavaScript%20cg%20algorithms/src/testing/snippets/functionDecl.js|(0,21,<1,0>,<3,1>))>
	};
}

public test bool testAssignOneToVarX() {
	Graph[Vertex] flowGraph = createIntraProceduralFlowGraph(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToVarX.js|);
	return flowGraph == {
 		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToVarX.js|(24,1,<2,9>,<2,10>)),Variable("x", |project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToVarX.js|(20,1,<2,5>,<2,6>))>,
  		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToVarX.js|(24,1,<2,9>,<2,10>)),Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToVarX.js|(20,5,<2,5>,<2,10>))>,
  		<Function(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToVarX.js|(0,27,<1,0>,<3,1>)),Variable("f", |project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToVarX.js|(0,27,<1,0>,<3,1>))>
	};
}

public test bool testAssignOneToX() {
	Graph[Vertex] flowGraph = createIntraProceduralFlowGraph(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToX.js|);
	return flowGraph == {
  		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToX.js|(20,1,<2,5>,<2,6>)),Property("x")>,
  		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToX.js|(20,1,<2,5>,<2,6>)),Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToX.js|(16,5,<2,1>,<2,6>))>,
  		<Function(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToX.js|(0,23,<1,0>,<3,1>)),Variable("f", |project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToX.js|(0,23,<1,0>,<3,1>))>
	};
}

public test bool testAssignOneToXOneLiner() {
	Graph[Vertex] flowGraph = createIntraProceduralFlowGraph(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToXOneLiner.js|);
	return flowGraph == {
 		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToXOneLiner.js|(19,1,<1,19>,<1,20>)),Property("x")>,
  		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToXOneLiner.js|(19,1,<1,19>,<1,20>)),Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToXOneLiner.js|(15,5,<1,15>,<1,20>))>,
  		<Function(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToXOneLiner.js|(0,22,<1,0>,<1,22>)),Variable("f", |project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToXOneLiner.js|(0,22,<1,0>,<1,22>))>	
  	};
}

public test bool testAssignOneToPropY() {
	Graph[Vertex] flowGraph = createIntraProceduralFlowGraph(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToPropY.js|);
	return flowGraph == {
	  	<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToPropY.js|(6,1,<1,6>,<1,7>)),Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToPropY.js|(0,7,<1,0>,<1,7>))>,
		<Expression(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToPropY.js|(6,1,<1,6>,<1,7>)),Property("b")>
	};
}