module staticanalysis::CommonInterproceduralFlow

import util::Maybe;

import IO;
import String;
import EcmaScript;
import ParseTree;
import analysis::graphs::Graph;
import utils::Utils;
import utils::GraphUtils;

import staticanalysis::VertexFactory;
import staticanalysis::DataStructures;

public Graph[Vertex] getCommonInterproceduralFlow(trees, SymbolTableMap symbolTableMap) {
	Graph[Vertex] graph = {};
	
	private void processR8(Tree \node, Tree function, arguments) {
		loc nodeLoc = \node@\loc;
		graph += <createVertex(function, symbolTableMap), createCalleeVertex(\node)>;
		int i = 1;
		for (argument <- arguments) {
			graph += <createVertex(argument, symbolTableMap), Argument(nodeLoc, i)>;
			i += 1;
		}
		graph += <Result(nodeLoc), Expression(nodeLoc)>;
		
		//This is to get the largest expressions
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
		
		doVisit(r);
		doVisit(p);
		for (argument <- arguments) {
			doVisit(argument);
		}
	}
	
	private void processR10(Tree returnStatement, Tree e) {
		//Innermost enclosing function containing the return statement.
		SymbolTable symbolTable = symbolTableMap[returnStatement@\loc];
		Maybe[tuple[Identifier id, bool globalScope]] thisReference = find("this", symbolTable);
		
		if (just(<Identifier id, _>) := thisReference) {
			if (parameter(loc enclosingFunctionLocation, _) := id) {
				graph += <createVertex(e, symbolTableMap), Return(enclosingFunctionLocation)>;
				doVisit(e);
			} else throw "\'This\' reference is not a parameter";
		} else throw "\'This\' reference not found on symbol map when looking for enclosing function of <returnStatement>.";
	}
	
	private void doVisit(parseTrees) {
		top-down-break visit(parseTrees) {
			case newWithArguments:(Expression)`new <Expression e> ( <{ Expression!comma ","}+ args> )`: processR8(newWithArguments, e, args);
			case newWithoutArguments:(Expression)`new <Expression e>()`: processR8(newWithoutArguments, e, []);
			case newWithoutParentheses:(Expression)`new <Expression e>`: processR8(newWithoutParentheses, e, []);
	
			case propertyCallWithArguments:(Expression)`<Expression r>.<Id p>( <{ Expression!comma ","}+ args> )`: processR9(propertyCallWithArguments, r, p, args);
			case propertyCallWithoutArguments:(Expression)`<Expression r>.<Id p>()`: processR9(propertyCallWithoutArguments, r, p, []);
			
			case wrappedCallWithArguments:(Expression)`(<Expression e>) ( <{ Expression!comma ","}+ args> )`: processR8(wrappedCallWithArguments, e, args);
			case wrappedCallWithoutArguments:(Expression)`(<Expression e>)()`: processR8(wrappedCallWithoutArguments, e, []);
			
			case callWithArguments:(Expression)`<Expression e> ( <{ Expression!comma ","}+ args> )`: processR8(callWithArguments, e, args);
			case callWithoutArguments:(Expression)`<Expression e>()`: processR8(callWithoutArguments, e, []);
					
			case returnExpSemi:(Statement)`return <Expression e>;`: processR10(returnExpSemi, e);
			case returnExpNoSemi:(Statement)`return <Expression e>`: processR10(returnExpNoSemi, e);
			case Statement s: {
				if (returnExpNoSemiBlockEnd(Expression e, _) := s) {
					processR10(s, e);
				} else fail;
			}
		}
	}
	doVisit(trees);
	
	return graph;
}