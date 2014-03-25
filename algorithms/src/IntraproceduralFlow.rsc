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
		
		private Vertex processId(Id id) {
			str propName = unparse(id);
			SymbolTable elementSymbolTable = symbolTableMap[elementLocation];
			Maybe[Identifier] foundId = find(propName, elementSymbolTable);
			if (!isRootSymbolTable(elementSymbolTable) && just(identifier(_, location)) := foundId) {
				return Variable(location);
			}
			return Property(propName);
		}
		
		loc elementLocation = element@\loc;
		switch(element) {
			case (Id)`<Id id>`: return processId(id);
			case (Expression)`<Id id>`: return processId(id);
			case (Expression)`this`: { //Nothing about this in the paper? Possibly it's the stuff about 'this' being the 0th parameter.
				SymbolTable elementSymbolTable = symbolTableMap[elementLocation];
				if (just(identifier(_, location)) := find("this", elementSymbolTable)) {
					return Variable(location);
				}
				return Expression(elementLocation);
			}
			case (Expression)`<Expression _> . <Id propName>`: return createPropertyVertex(propName);
			case (Expression)`function <Id? id> (<{Id ","}* _>) <Block _>`: return Function(elementLocation);
			default: return createExpressionVertex(element);
		}
	}
	
	private Vertex createFunctionVertex(element) {
		return Function(element@\loc);
	}
	
	private Vertex createExpressionVertex(element) {
		println(element);
		return Expression(element@\loc);
	}
	
	private Vertex createVariableVertex(element) {
		return Variable(element@\loc);
	}
	
	private Vertex createPropertyVertex(element) {
		return Property(unparse(element));
	}

	visit (tree) {
		case assignment:(VariableDeclaration)`<Id l> = <Expression r>`: {
			graph += <createVertex(r), createVertex(l)>;
			graph += <createVertex(r), createExpressionVertex(assignment)>;
		}
		case Tree assignment: //TODO: refactor back to normal labelled patterns when Rascal bug is fixed.
		  if (variableAssignment(Expression l, Expression r) := assignment) {
		  		graph += <createVertex(r), createVertex(l)>;
				graph += <createVertex(r), createExpressionVertex(assignment)>;
		  } else if (variableAssignmentNoSemi(Expression l, Expression r) := assignment) {
				graph += <createVertex(r), createVertex(l)>;
				graph += <createVertex(r), createExpressionVertex(assignment)>;
		  } else if(variableAssignmentLoose(Expression l, Expression r) := assignment) {
		  		graph += <createVertex(r), createVertex(l)>;
				graph += <createVertex(r), createExpressionVertex(assignment)>;
		  } else if(variableAssignmentBlockEnd(Expression l, Expression r) := assignment) {
		  		graph += <createVertex(r), createVertex(l)>;
				graph += <createVertex(r), createExpressionVertex(assignment)>;
		  } else fail;
		//TODO: multiple declarations: i = 1, j = 2.
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
					graph += <createVertex(e), createPropertyVertex(f)>;
				}
			}
		}
		case functionExpr:(Expression)`function <Id? name> (<{Id ","}* _>) <Block _>`: {
			graph += <createFunctionVertex(functionExpr), createExpressionVertex(functionExpr)>;
			iprintln(name);
			
			println("is opt: </\opt(_) := name>");
			println("present: <name is present>");
			println("absent: <name is absent>");
			
			if (!isEmpty(unparse(name))) {
				graph += <createFunctionVertex(functionExpr), createVariableVertex(functionExpr)>;
			}
		}
		case functionDecl:(FunctionDeclaration)`function <Id _> (<{Id ","}* _>) <Block _>`: {
			graph += <createFunctionVertex(functionDecl), createVariableVertex(functionDecl)>;
		}
	}
	return graph;
}