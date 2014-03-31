module VertexFactory

import EcmaScript;
import util::Maybe;

import DataStructures;

public Vertex createVertex(element) {
	
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
	return Expression(element@\loc);
}

private Vertex createVariableVertex(element) {
	return Variable(element@\loc);
}

private Vertex createPropertyVertex(element) {
	return Property(unparse(element));
}