module VertexFactory

import EcmaScript;
import util::Maybe;
import ParseTree;
import IO;

import DataStructures;

public Vertex createVertex(element, symbolTableMap) {
	
	private Vertex processId(Id id) = processId(unparse(id));
	
	//If \(pi, x)is the uith parameter of the function declared at pi' then V(x at Pi) = Parm(pi', i)
	//Maybe make an identifier type for both normal declarations and parameters?
	private Vertex processId(str id) {
		SymbolTable elementSymbolTable = symbolTableMap[elementLocation];
		Maybe[Identifier] foundId = find(id, elementSymbolTable);
		if (!isRootSymbolTable(elementSymbolTable) && just(declaration(location)) := foundId) {
			return Variable(id, location);
		} else if (just(parameter(enclosingFunctionLocation, index)) := foundId) {
			return Parameter(enclosingFunctionLocation, index);
		}
		return Property(id);
	}
	
	loc elementLocation = element@\loc;
	switch(element) {
		case (Id)`<Id id>`: return processId(id);
		case (Expression)`<Id id>`: return processId(id);
		case (Expression)`this`: return processId("this");
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