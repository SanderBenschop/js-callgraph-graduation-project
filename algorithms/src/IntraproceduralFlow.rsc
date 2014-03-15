module IntraproceduralFlow

import IO;
import String;
import EcmaScript;
import ParseTree;
import analysis::graphs::Graph;

import DataStructures;

public Graph[Vertex] addIntraproceduralFlow(Graph[Vertex] graph, Tree tree) {
	visit (tree) {
		//case assignment:(Expression)`<Id id> = <Expression e>`: {
		//	var i = 0;
		//}
		case orExpr:(Expression)`<Expression l> || <Expression r>`: {
			graph += <createVertex(l), createExpressionVertex(orExpr)>;
			graph += <createVertex(r), createExpressionVertex(orExpr)>;
		}
		case ternary:(Expression)`<Expression _> ? <Expression l> : <Expression r>`: {
			graph += <createVertex(l), createExpressionVertex(ternary)>;
			graph += <createVertex(r), createExpressionVertex(ternary)>;
		}
		case andExpr:(Expression)`<Expression _> && <Expression r>`: {
			graph += <createVertex(r), createExpressionVertex(andExpr)>;
		}
		case propAssign:(Expression)`{ <{PropertyAssignment ","}* props> }`: {
			for(PropertyAssignment prop <- props) {
				if ((PropertyAssignment)`<PropertyName f> : <Expression e>` := prop) {
					graph += <createVertex(e), createVertex(f)>;
				}
			}
		}
		case functionExpr:(Expression)`function <Id? name> (<{Id ","}* _>) <Block _>`: {
			graph += <createVertex(functionExpr), createExpressionVertex(functionExpr)>;
			if (!isEmpty(unparse(name))) { //opt(lex("Id")) also if filled
				graph += <createVertex(functionExpr), createVariableVertex(functionExpr)>;
			}
		}
	}
	return graph;
}

private Vertex createVertex(element) {
	loc elementLocation = element@\loc;
	switch(element) {
		//case (Expression)`<Id id>`: {
		//	//TODO: either varVertex or propVertex.
		//	return Property("MOCKUP");
		//}
		//Different cases
		
		case (Expression)`function <Id? id> (<{Id ","}* _>) <Block _>`: return Function(elementLocation);
		default: return createExpressionVertex(element);
	}
}

private Vertex createExpressionVertex(element) {
	return Expression(element@\loc);
}

private Vertex createVariableVertex(element) {
	return Variable(element@\loc);
}