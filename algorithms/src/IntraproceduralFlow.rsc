module IntraproceduralFlow

import util::Maybe;

import IO;
import String;
import EcmaScript;
import ParseTree;
import analysis::graphs::Graph;

import DataStructures;

public Graph[Vertex] addIntraproceduralFlow(Graph[Vertex] graph, Tree tree, SymbolTableMap symbolTableMap) {

	private Vertex createVertex(element) {
		loc elementLocation = element@\loc;
		switch(element) {
			case (Id)`<Id id>`: {
				str propName = unparse(id);
				SymbolTable elementSymbolTable = symbolTableMap[elementLocation];
				Maybe[Identifier] foundId = find(propName, elementSymbolTable);
				if (!isRootSymbolTable(elementSymbolTable) && just(identifier(_, location)) := foundId) {
					return Variable(location);
				}
				return Property(propName);
			}
			//Different cases
			
			case (Expression)`function <Id? id> (<{Id ","}* _>) <Block _>`: return Function(elementLocation);
			default: return createExpressionVertex(element);
		}
	}
	
	private Vertex createFunctionVertex(element) {
		return Function(element@\loc);
	}
	
	private Vertex createExpressionVertex(element) {
		return Expression(element@\loc);
	}
	
	private Vertex createVariableVertex(element) {
		return Variable(element@\loc);
	}

	visit (tree) {
		case assignment:(VariableDeclaration)`<Id l> = <Expression r>`: { //Is varDecl correct here? Shouldn't it just be expression?
			graph += <createVertex(r), createVertex(l)>;
		}
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
			graph += <createFunctionVertex(functionExpr), createExpressionVertex(functionExpr)>;
			if (!isEmpty(unparse(name))) { //opt(lex("Id")) also if filled
				graph += <createFunctionVertex(functionExpr), createVariableVertex(functionExpr)>;
			}
		}
		case functionDecl:(FunctionDeclaration)`function <Id _> (<{Id ","}* _>) <Block _>`: {
			graph += <createFunctionVertex(functionDecl), createVariableVertex(functionDecl)>;
		}
	}
	return graph;
}