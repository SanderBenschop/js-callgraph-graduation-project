module CommonInterproceduralFlow

import util::Maybe;

import IO;
import String;
import EcmaScript;
import ParseTree;
import analysis::graphs::Graph;
import VertexFactory;
import utils::Utils;

import DataStructures;

public Graph[Vertex] getCommonInterproceduralFlow(Tree tree, SymbolTableMap symbolTableMap) {
	Graph[Vertex] graph = {};
	map [loc, loc] returnToFunctionMap = getEnclosingFunctionLocations(tree);
	
	private void processR8(Tree \node, Tree function, arguments) {
		loc nodeLoc = \node@\loc;
		graph += <createVertex(function, symbolTableMap), createCalleeVertex(\node)>;
		int i = 1;
		for (argument <- arguments) {
			graph += <createVertex(argument, symbolTableMap), Argument(nodeLoc, i)>;
			i += 1;
		}
		graph += <Result(nodeLoc), Expression(nodeLoc)>;
		
		//TODO: optimize, this is to get the largest expressions
		doVisit(\function);
		for (argument <- arguments) {
			doVisit(argument);
		}
	}
	
	private void processR9(Tree \node, Tree r, Id p, arguments) {
		println("Processing R9 on node <\node> with arguments : <arguments>. R: <r> P: <p>");
		Tree function = (Expression)`<Expression r>.<Id p>`;
		processR8(\node, function, arguments);
		graph += <createVertex(r, symbolTableMap), Argument(\node@\loc, 0)>;
		
		//TODO: optimize
		doVisit(r);
		doVisit(p);
		for (argument <- arguments) {
			doVisit(argument);
		}
	}
	
	private void processR10(Tree element, Tree e) {
		//Innermost enclosing function containing the return statement.
		loc enclosingFunctionLocation = returnToFunctionMap[element@\loc];
		graph += <createVertex(e, symbolTableMap), Return(enclosingFunctionLocation)>;
		
		doVisit(e);
	}
	
	private void doVisit(parseTree) {
		top-down-break visit(parseTree) {
			//TODO: rename all these cases, they are not params but arguments. Also they don't all make sense.
			//TODO: new a.b() ??
			//TODO: here it matches new <Expression e> but in the paper it shows a call to a function specifically. Maybe this should be fixed?
			case newFunctionCallParams:(Expression)`new <Expression e> ( <{ Expression!comma ","}+ args> )`: processR8(newFunctionCallParams, e, args);
			case newFunctionCallNoParams:(Expression)`new <Expression e>()`: processR8(newFunctionCallNoParams, e, []);
			case newNoParams:(Expression)`new <Expression e>`: processR8(newNoParams, e, []);
	
			case propertyCallParams:(Expression)`<Expression r>.<Id p>( <{ Expression!comma ","}+ args> )`: processR9(propertyCallParams, r, p, args);
			case propertyCallEmptyParams:(Expression)`<Expression r>.<Id p>()`: processR9(propertyCallEmptyParams, r, p, []);
			
			case wrappedFunctionCallParams:(Expression)`(<Expression e>) ( <{ Expression!comma ","}+ args> )`: processR8(wrappedFunctionCallParams, e, args);
			case wrappedFunctionCallNoParams:(Expression)`(<Expression e>)()`: processR8(wrappedFunctionCallNoParams, e, []);
			
			case functionCallParams:(Expression)`<Expression e> ( <{ Expression!comma ","}+ args> )`: processR8(functionCallParams, e, args);
			case functionCallNoParams:(Expression)`<Expression e>()`: processR8(functionCallNoParams, e, []);
					
			// Return statements
			case returnExpSemi:(Statement)`return <Expression e>;`: processR10(returnExpSemi, e);
			case returnExpNoSemi:(Statement)`return <Expression e>`: processR10(returnExpNoSemi, e);
		}
	}
	doVisit(tree);
	
	return graph;
}

//Returns a map of the location of the  statement with expressions to the inner-most function enclosing them.
private map [loc, loc] getEnclosingFunctionLocations(Tree tree) {
	map [loc, loc] returnToFunctionMap = ();
	loc lastSeenFunction = |nothing:///|;
	
	private void markFunction(function, body) {
		println("Marking function <function>");
		loc oldLastSeen = lastSeenFunction;
		lastSeenFunction = function@\loc;
		doVisit(body);
		lastSeenFunction = oldLastSeen;
	}
	
	private void markReturn(returnStatement, expression) {
		println("Marking return <returnStatement> to last seen function <lastSeenFunction>");
		returnToFunctionMap += (returnStatement@\loc : lastSeenFunction);
		doVisit(expression);
	}
	
	private void doVisit(parseTree) {
		top-down-break visit(parseTree) {
			case func:(FunctionDeclaration)`function <Id id> (<{Id ","}* params>) <Block body> <ZeroOrMoreNewLines _>` : markFunction(func, body); 
			case func:(Expression)`function <Id id> (<{Id ","}* params>) <Block body>`: markFunction(func, body);
			case func:(Expression)`function (<{Id ","}* params>) <Block body>`: markFunction(func, body);
			case returnExpSemi:(Statement)`return <Expression e>;`: markReturn(returnExpSemi, e);
			case returnExpNoSemi:(Statement)`return <Expression e>`: markReturn(returnExpNoSemi, e);
		}
	}
	
	doVisit(tree);
	
	return returnToFunctionMap;
}