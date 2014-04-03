module VertexFactory

import EcmaScript;
import util::Maybe;
import ParseTree;
import IO;

import DataStructures;

public Vertex createVertex(element, symbolTableMap) {
	
	private Vertex processId(Id id) {
		//If \(pi, x)is the uith parameter of the function declared at pi' then V(x at Pi) = Parm(pi', i)
		//Maybe make an identifier type for both normal declarations and parameters?
		str propName = unparse(id);
		SymbolTable elementSymbolTable = symbolTableMap[elementLocation];
		Maybe[Identifier] foundId = find(propName, elementSymbolTable);
		if (!isRootSymbolTable(elementSymbolTable) && just(identifier(location)) := foundId) {
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
			if (just(identifier(location)) := find("this", elementSymbolTable)) {
				return Variable("this", location);
			}
			return Expression(elementLocation);
		}
		case (Expression)`<Expression _> . <Id propName>`: return createPropertyVertex(propName);
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