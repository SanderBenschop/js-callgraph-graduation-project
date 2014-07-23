module CommonInterproceduralFlow

import util::Maybe;

import IO;
import String;
import EcmaScript;
import ParseTree;
import analysis::graphs::Graph;
import VertexFactory;
import utils::Utils;
import utils::GraphUtils;

import DataStructures;

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
			//TODO: rename all these cases, they are not params but arguments. Also they don't all make sense.
			case newFunctionCallParams:(Expression)`new <Expression e> ( <{ Expression!comma ","}+ args> )`: processR8(newFunctionCallParams, e, args);
			case newFunctionCallNoParams:(Expression)`new <Expression e>()`: processR8(newFunctionCallNoParams, e, []);
			case newNoParams:(Expression)`new <Expression e>`: processR8(newNoParams, e, []);
	
			case propertyCallParams:(Expression)`<Expression r>.<Id p>( <{ Expression!comma ","}+ args> )`: processR9(propertyCallParams, r, p, args);
			case propertyCallEmptyParams:(Expression)`<Expression r>.<Id p>()`: processR9(propertyCallEmptyParams, r, p, []);
			
			case wrappedFunctionCallParams:(Expression)`(<Expression e>) ( <{ Expression!comma ","}+ args> )`: processR8(wrappedFunctionCallParams, e, args);
			case wrappedFunctionCallNoParams:(Expression)`(<Expression e>)()`: processR8(wrappedFunctionCallNoParams, e, []);
			
			case functionCallParams:(Expression)`<Expression e> ( <{ Expression!comma ","}+ args> )`: processR8(functionCallParams, e, args);
			case functionCallNoParams:(Expression)`<Expression e>()`: processR8(functionCallNoParams, e, []);
					
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