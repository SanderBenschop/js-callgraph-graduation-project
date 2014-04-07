module IntraproceduralFlow

import util::Maybe;

import IO;
import String;
import EcmaScript;
import ParseTree;
import analysis::graphs::Graph;
import VertexFactory;

import DataStructures;

public Graph[Vertex] getIntraproceduralFlow(Tree tree, SymbolTableMap symbolTableMap) {
	Graph[Vertex] graph = {};
	visit (tree) {
		//TODO: remove duplication
		case assignment:(VariableDeclarationNoIn)`<Id l> = <Expression r>`: {
			graph += <createVertex(r, symbolTableMap), createVertex(l, symbolTableMap)>;
			graph += <createVertex(r, symbolTableMap), createExpressionVertex(assignment)>;
		}
		case assignment:(VariableDeclaration)`<Id l> = <Expression r>`: {
			graph += <createVertex(r, symbolTableMap), createVertex(l, symbolTableMap)>;
			graph += <createVertex(r, symbolTableMap), createExpressionVertex(assignment)>;
		}
		case Tree assignment: //TODO: refactor back to normal labelled patterns when Rascal bug is fixed.
		  if (variableAssignment(Expression l, Expression r) := assignment) {
		  		graph += <createVertex(r, symbolTableMap), createVertex(l, symbolTableMap)>;
				graph += <createVertex(r, symbolTableMap), createExpressionVertex(assignment)>;
		  } else if (variableAssignmentNoSemi(Expression l, Expression r) := assignment) {
				graph += <createVertex(r, symbolTableMap), createVertex(l, symbolTableMap)>;
				graph += <createVertex(r, symbolTableMap), createExpressionVertex(assignment)>;
		  } else if(variableAssignmentLoose(Expression l, Expression r) := assignment) {
		  		graph += <createVertex(r, symbolTableMap), createVertex(l, symbolTableMap)>;
				graph += <createVertex(r, symbolTableMap), createExpressionVertex(assignment)>;
		  } else if(variableAssignmentBlockEnd(Expression l, Expression r) := assignment) {
		  		graph += <createVertex(r, symbolTableMap), createVertex(l, symbolTableMap)>;
				graph += <createVertex(r, symbolTableMap), createExpressionVertex(assignment)>;
		  } else fail;
		//TODO: multiple declarations: i = 1, j = 2.
		case orExpr:(Expression)`<Expression l> || <Expression r>`: {
			graph += <createVertex(l, symbolTableMap), createExpressionVertex(orExpr)>;
			graph += <createVertex(r, symbolTableMap), createExpressionVertex(orExpr)>;
		}
		case ternary:(Expression)`<Expression _> ? <Expression l> : <Expression r>`: {
			graph += <createVertex(l, symbolTableMap), createExpressionVertex(ternary)>;
			graph += <createVertex(r, symbolTableMap), createExpressionVertex(ternary)>;
		}
		case andExpr:(Expression)`<Expression _> && <Expression r>`: {
			graph += <createVertex(r, symbolTableMap), createExpressionVertex(andExpr)>;
		}
		case propAssign:(Expression)`{ <{PropertyAssignment ","}* props> }`: {
			for(PropertyAssignment prop <- props) {
				if ((PropertyAssignment)`<PropertyName f> : <Expression e>` := prop) {
					graph += <createVertex(e, symbolTableMap), createPropertyVertex(f)>;
				}
			}
		}
		case functionExprNameless:(Expression)`function (<{Id ","}* _>) <Block _>`: {
			graph += <createFunctionVertex(functionExprNameless), createExpressionVertex(functionExprNameless)>;
		}
		case functionExprNamed:(Expression)`function <Id id> (<{Id ","}* _>) <Block _>`: {
			graph += <createFunctionVertex(functionExprNamed), createExpressionVertex(functionExprNamed)>;
			graph += <createFunctionVertex(functionExprNamed), createVariableVertex(id, functionExprNamed)>;
		}
		case functionDecl:(FunctionDeclaration)`function <Id id> (<{Id ","}* _>) <Block _> <ZeroOrMoreNewLines _>`: {
			graph += <createFunctionVertex(functionDecl), createVariableVertex(id, functionDecl)>;
		}
	}
	return graph;
}