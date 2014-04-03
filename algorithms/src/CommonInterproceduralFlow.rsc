module CommonInterproceduralFlow

import util::Maybe;

import IO;
import String;
import EcmaScript;
import ParseTree;
import analysis::graphs::Graph;
import VertexFactory;
import Utils;

import DataStructures;

public Graph[Vertex] getCommonInterproceduralFlow(Tree tree, SymbolTableMap symbolTableMap) {
	Graph[Vertex] graph = {};
	map [loc, loc] returnToFunctionMap = getEnclosingFunctionLocations(tree);
	
	private void processR8(Tree element, arguments) {
		loc elementLoc = element@\loc;
		graph += <createVertex(element, symbolTableMap), Callee(elementLoc)>;
		int i = 1;
		for (argument <- arguments) {
			graph += <createVertex(argument, symbolTableMap), Argument(elementLoc, i)>;
			i += 1;
		}
		graph += <Result(elementLoc), Expression(elementLoc)>;
	}
	
	private void processR9(Tree element, Tree r, arguments) {
		processR8(element, arguments);
		graph += <createVertex(r, symbolTableMap), Argument(element@\loc, 0)>;
	}
	
	private void processR10(Tree element, Tree e) {
		//Innermost enclosing function containing the return statement.
		loc enclosingFunctionLocation = returnToFunctionMap[element@\loc];
		graph += <createVertex(e, symbolTableMap), Return(enclosingFunctionLocation)>;
	}
	
	top-down-break visit(tree) {
		//TODO: rename all these cases, they are not params but arguments. Also they don't all make sense.
		//TODO: new a.b() ??
		case functionCallParams:(Expression)`<Expression _> ( <{ Expression!comma ","}+ args> )`: processR8(functionCallParams, args);
		case functionCallNoParams:(Expression)`<Expression _>()`: processR8(functionCallNoParams, []);
		case newFunctionCallParams:(Expression)`new <Expression e> ( <{ Expression!comma ","}+ args> )`: processR8(newFunctionCallParams, args);
		case newFunctionCallNoParams:(Expression)`new <Expression e>()`: processR8(newFunctionCallNoParams, []);
		case newNoParams:(Expression)`new <Expression args>`: processR8(newNoParams, args);
		case propertyCallEmptyParams:(Expression)`<Expression r>.<Id _>()`: processR9(propertyCallEmptyParams, r, []);
		case propertyCallParams:(Expression)`<Expression r>.<Id _>( <{ Expression!comma ","}+ args> )`: processR9(propertyCallParams, r, args);
		// Return statements
		case returnExpSemi:(Statement)`return <Expression e>;`: processR10(returnExpSemi, e);
		case returnExpNoSemi:(Statement)`return <Expression e>`: processR10(returnExpNoSemi, e);
	}
	return graph;
}

//Returns a map of the location of the  statement with expressions to the inner-most function enclosing them.
private map [loc, loc] getEnclosingFunctionLocations(Tree tree) {
	map [loc, loc] returnToFunctionMap = ();
	loc lastSeenFunction = |nothing:///|;
	
	private void markFunction(function, body) {
		loc oldLastSeen = lastSeenFunction;
		lastSeenFunction = function@\loc;
		doVisit(body);
		lastSeenFunction = oldLastSeen;
	}
	
	private void markReturn(returnStatement) {
		returnToFunctionMap += (returnStatement@\loc : lastSeenFunction);
	}
	
	private void doVisit(parseTree) {
		top-down-break visit(parseTree) {
			case func:(FunctionDeclaration)`function <Id id> (<{Id ","}* params>) <Block body> <ZeroOrMoreNewLines _>` : markFunction(func, body); 
			case func:(Expression)`function <Id id> (<{Id ","}* params>) <Block body>`: markFunction(func, body);
			case func:(Expression)`function (<{Id ","}* params>) <Block body>`: markFunction(func, body);
			case returnExpSemi:(Statement)`return <Expression _>;`: markReturn(returnExpSemi);
			case returnExpNoSemi:(Statement)`return <Expression _>`: markReturn(returnExpNoSemi);
		}
	}
	
	doVisit(tree);
	
	return returnToFunctionMap;
}