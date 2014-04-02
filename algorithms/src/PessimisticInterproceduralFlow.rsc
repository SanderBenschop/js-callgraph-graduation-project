module PessimisticInterproceduralFlow

import util::Maybe;

import IO;
import String;
import EcmaScript;
import ParseTree;
import analysis::graphs::Graph;
import VertexFactory;
import Utils;

import DataStructures;

//C = one shot closures
//E = escaping functions = other functions 
//U = unresolved call sites = calls that are not one shot closures.
public Graph[Vertex] addPessimisticInterproceduralFlow(Graph[Vertex] graph, Tree tree, SymbolTableMap symbolTableMap) {
	tuple[lrel[Tree, Tree] oneShotClosures, list[Tree] unresolved, list[Tree] functionsInsideClosures] callSites = analyseCallSites(tree);
	list[Tree] escaping = getEscapingFunctions(tree, callSites.functionsInsideClosures);	
	
	println("Functions inside closures: <callSites.functionsInsideClosures>");
	println("One shot closures: <callSites.oneShotClosures>");
	println("Unresolved: <callSites.unresolved>");
	println("Escaping: <escaping>");
	
	graph += oneShotClosureEdges(callSites.oneShotClosures);
	graph += unresolvedEdges(callSites.unresolved);
	graph += escapingEdges(escaping);
	
	return graph;
}

public Graph[Vertex] oneShotClosureEdges(lrel[Tree, Tree] oneShotClosures) {
	Graph[Vertex] oneShotClosureEdges = {};
	//TODO: rename call as this is actually the part before the call and it's confusing
	for (tuple[Tree call, Tree closure] oneShotClosure <- oneShotClosures) {
		Tree nestedFunction = extractNestedExpression(oneShotClosure.call);
		loc oneShotClosureLocation = oneShotClosure.closure@\loc, nestedFunctionLocation = nestedFunction@\loc;
		int i = 0;
		for (tuple[Tree parameter, Tree argument] pa <- unbalancedZip(extractParameters(nestedFunction), extractArguments(oneShotClosure.closure))) {
			println("Parameter: <unparse(pa.parameter)> argument: <unparse(pa.argument)>");
			oneShotClosureEdges += <Argument(oneShotClosureLocation, i), Parameter(nestedFunctionLocation, i)>;
			i += 1;
		}
		oneShotClosureEdges += <Return(nestedFunctionLocation), Result(oneShotClosureLocation)>;
	}
	return oneShotClosureEdges;
}

public Graph[Vertex] unresolvedEdges(list[Tree] unresolvedCallSites) {
	Graph[Vertex] unresolvedEdges = {};
	for (Tree unresolvedCallSite <- unresolvedCallSites) {
		int i = 0;
	}
	return unresolvedEdges;
}

public Graph[Vertex] escapingEdges(list[Tree] escapingFunctions) {
	Graph[Vertex] escapingEdges = {};
	for (Tree escapingFunction <- escapingFunctions) {
		int i = 0;
	}
	return escapingEdges;
}

public list[Tree] extractArguments(call) {
	if ((Expression)`<Expression e>()` := call) {
		return [];
	} else if ((Expression)`<Expression e> ( <{ Expression!comma ","}+ args> )` := call) {
		return [arg | arg <- args];
	}
	throw "Not a call";
}

public list[Tree] extractParameters(function) {
	if ((Expression)`function (<{Id ","}* params>) <Block _>` := function || (Expression)`function <Id _> (<{Id ","}* params>) <Block _>` := function) {
		return [param | param <- params];
	}
	throw "Not a function";
}

public tuple[lrel[Tree, Tree] oneShot, list[Tree] unresolved, list[Tree] functionsInsideClosures] analyseCallSites(Tree tree) {
	lrel[Tree, Tree] oneShot = [];
	list[Tree] unresolved = [], functionsInsideClosures = [];
	private void analyseCall(call, closure) {
		println("Found call: <call>");
		//TODO: turn into one production when Id? bug is fixed.
		if ((Expression)`(function (<{Id ","}* _>) <Block _>)` := call || (Expression)`(function <Id _> (<{Id ","}* _>) <Block _>)` := call) {
			println("Which is a one-shot closure");
			oneShot += <call, closure>;
			functionsInsideClosures += extractNestedExpression(call);
		} else {
			println("Which is an unresolved call site");
			unresolved += call;
		}
	}
	visit(tree) {
		case functionCallParams:(Expression)`<Expression e> ( <{ Expression!comma ","}+ _> )`: analyseCall(e, functionCallParams);
		case functionCallNoParams:(Expression)`<Expression e>()`: analyseCall(e, functionCallNoParams);
	}
	return <oneShot, unresolved, functionsInsideClosures>;
}

public list[Tree] getEscapingFunctions(Tree tree, list[Tree] functionsInsideClosures) {
	list[Tree] escaping = [];
	visit(tree) {
		case functionExprNameless:(Expression)`function (<{Id ","}* _>) <Block _>`: {
			if (functionExprNameless notin functionsInsideClosures) escaping += functionExprNameless;
		}
		case functionExprNamed:(Expression)`function <Id id> (<{Id ","}* _>) <Block _>`: {
			if (functionExprNamed notin functionsInsideClosures) escaping += functionExprNamed;
		}
		case functionDecl:(FunctionDeclaration)`function <Id id> (<{Id ","}* _>) <Block _> <ZeroOrMoreNewLines _>`: {
			escaping += functionDecl;
		}
	}
	return escaping;
}

public Tree extractNestedExpression(nestingExpression) {
	if ((Expression)`(<Expression nestedExpression>)` := nestingExpression) {
		return nestedExpression;
	}
	throw "Passed expression is not a nesting expression.";
}