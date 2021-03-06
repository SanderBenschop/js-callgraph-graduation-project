module staticanalysis::IntraproceduralFlow

import EcmaScript;
import ParseTree;
import analysis::graphs::Graph;

import staticanalysis::VertexFactory;
import staticanalysis::DataStructures;

public Graph[Vertex] getIntraproceduralFlow(trees, SymbolTableMap symbolTableMap) {
	Graph[Vertex] graph = {};
	visit (trees) {
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
			SymbolTable symbolTable = symbolTableMap[functionExprNamed@\loc];
			graph += <createFunctionVertex(functionExprNamed), createExpressionVertex(functionExprNamed)>;
			graph += <createFunctionVertex(functionExprNamed), createFunctionTargetVertex(id, functionExprNamed, symbolTable)>;
		}
		case functionDecl:(FunctionDeclaration)`function <Id id> (<{Id ","}* _>) <Block _> <ZeroOrMoreNewLines _>`: {
			SymbolTable symbolTable = symbolTableMap[functionDecl@\loc];
			graph += <createFunctionVertex(functionDecl), createFunctionTargetVertex(id, functionDecl, symbolTable)>;
		}
	}
	return graph;
}