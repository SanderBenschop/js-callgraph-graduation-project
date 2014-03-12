module IntraproceduralFlow

import IO;
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
			graph += <createVertex(l), createVertex(orExpr)>;
			graph += <createVertex(r), createVertex(orExpr)>;
		}
		case ternary:(Expression)`<Expression _> ? <Expression l> : <Expression r>`: {
			graph += <createVertex(l), createVertex(ternary)>;
			graph += <createVertex(r), createVertex(ternary)>;
		}
		case andExpr:(Expression)`<Expression _> && <Expression r>`: {
			graph += <createVertex(r), createVertex(andExpr)>;
		}
		case propAssign:(Expression)`{ <{PropertyAssignment ","}* props> }`: {
			for(PropertyAssignment prop <- props) {
				if ((PropertyAssignment)`<PropertyName f> : <Expression e>` := prop) {
					graph += <createVertex(e), createVertex(f)>;
				}
			}
		}
	}
	return graph;
}

private Vertex createVertex(element) {
	switch(element) {
		//case (Expression)`<Id id>`: {
		//	//TODO: either varVertex or propVertex.
		//	return Property("MOCKUP");
		//}
		//Different cases
		
		//Default case is an expression
		default: {
			return Expression(element@\loc);
		}
	}
}