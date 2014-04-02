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
	
	private void processR8(Tree element, arguments) {
		loc elementLoc = element@\loc;
		graph += <createVertex(element, symbolTableMap), Callee(elementLoc)>;
		int i = 0;
		for (argument <- arguments) {
			graph += <createVertex(argument, symbolTableMap), Argument(elementLoc, i)>;
			i += 1;
		}
		println("elementloc : <elementLoc>");
		graph += <Result(elementLoc), Expression(elementLoc)>;
	}
	
	top-down-break visit(tree) {
		case functionCallParams:(Expression)`<Expression _> ( <{ Expression!comma ","}+ args> )`: processR8(functionCallParams, args);
		case functionCallNoParams:(Expression)`<Expression _>()`: processR8(functionCallNoParams, []);
		case newFunctionCallParams:(Expression)`new <Expression e> ( <{ Expression!comma ","}+ args> )`: processR8(newFunctionCallParams, args);
		case newFunctionCallNoParams:(Expression)`new <Expression e>()`: processR8(newFunctionCallNoParams, []);
		case newNoParams:(Expression)`new <Expression args>`: processR8(newNoParams, args);
	}
	return graph;
}