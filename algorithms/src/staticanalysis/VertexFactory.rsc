module staticanalysis::VertexFactory

import EcmaScript;
import util::Maybe;
import ParseTree;
import IO;
import staticanalysis::Configuration;
import staticanalysis::DataStructures;

public Vertex createVertex(element, symbolTableMap) {
	
	private Vertex processId(Id id) = processId(unparse(id));
	
	private Vertex processId(str id) {
		try 
			SymbolTable elementSymbolTable = symbolTableMap[elementLocation];
		catch e: {
			println("There is no symbolTableMap for loc <elementLocation>");
			throw e;
		}
		Maybe[tuple[Identifier id, bool globalScope]] foundId = find(id, elementSymbolTable);
		if (just(<declaration(location), false>) := foundId) {
			return Variable(id, location);
		} else if (just(<parameter(enclosingFunctionLocation, index), _>) := foundId) {
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

public Vertex createFunctionTargetVertex(name, element, SymbolTable symbolTable) {
	if (globalFunctionAsProperties && root(_) := symbolTable) {
		return createPropertyVertex(name);
	}
	return createVariableVertex(name, element);
}

public Vertex createVariableVertex(name, element) {
	return Variable(unparse(name), element@\loc);
}

public Vertex createPropertyVertex(element) {
	return Property(unparse(element));
}

public Vertex createCalleeVertex(element) {
	Vertex callee = Callee(element@\loc);
	callee@tree = element;
	return callee;
}