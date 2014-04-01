module VertexFactory

import EcmaScript;
import util::Maybe;
import ParseTree;
import IO;

import DataStructures;

public Vertex createVertex(element, symbolTableMap) {
	
	private Vertex processId(Id id) {
		str propName = unparse(id);
		SymbolTable elementSymbolTable = symbolTableMap[elementLocation];
		Maybe[Identifier] foundId = find(propName, elementSymbolTable);
		if (!isRootSymbolTable(elementSymbolTable) && just(identifier(_, location)) := foundId) {
			return Variable(propName, location);
		}
		return Property(propName);
	}
	
	loc elementLocation = element@\loc;
	switch(element) {
		case (Id)`<Id id>`: return processId(id);
		case (Expression)`<Id id>`: return processId(id);
		case (Expression)`this`: {
			SymbolTable elementSymbolTable = symbolTableMap[elementLocation];
			if (just(identifier(_, location)) := find("this", elementSymbolTable)) {
				return Variable("this", location);
			}
			return Expression(elementLocation);
		}
		case (Expression)`<Expression _> . <Id propName>`: return createPropertyVertex(propName);
		//case (Expression)`function <Id? id> (<{Id ","}* _>) <Block _>`: return Function(elementLocation); //TODO: check if correct.
		default: return createExpressionVertex(element);
	}
}

public Vertex createFunctionVertex(element) {
	return Function(element@\loc);
}

public Vertex createExpressionVertex(element) {
	return Expression(element@\loc);
}

public Vertex createVariableVertex(name, element) {
	return Variable(unparse(name), element@\loc);
}

public Vertex createPropertyVertex(element) {
	return Property(unparse(element));
}