module staticanalysis::PessimisticInterproceduralFlow

import util::Maybe;

import IO;
import String;
import EcmaScript;
import ParseTree;
import analysis::graphs::Graph;
import staticanalysis::VertexFactory;
import utils::Utils;

import staticanalysis::DataStructures;

public Graph[Vertex] getPessimisticInterproceduralFlow(trees) {
	tuple[lrel[Tree, Tree] oneShotClosures, list[Tree] unresolved, list[Tree] functionsInsideClosures] callSites = analyseCallSites(trees);
	list[Tree] escaping = getEscapingFunctions(trees, callSites.functionsInsideClosures);	
	Graph[Vertex] graph = {};
	graph += oneShotClosureEdges(callSites.oneShotClosures);
	graph += unresolvedEdges(callSites.unresolved);
	graph += escapingEdges(escaping);
	return graph;
}

private Graph[Vertex] oneShotClosureEdges(lrel[Tree, Tree] oneShotClosures) {
	Graph[Vertex] oneShotClosureEdges = {};
	//TODO: rename call as this is actually the part before the call and it's confusing
	for (tuple[Tree call, Tree closure] oneShotClosure <- oneShotClosures) {
		Tree nestedFunction = extractNestedExpression(oneShotClosure.call);
		loc oneShotClosureLocation = oneShotClosure.closure@\loc, nestedFunctionLocation = nestedFunction@\loc;
		int i = 1;
		for (tuple[Tree parameter, Tree argument] pa <- unbalancedZip(extractParameters(nestedFunction), extractArguments(oneShotClosure.closure))) {
			oneShotClosureEdges += <Argument(oneShotClosureLocation, i), Parameter(nestedFunctionLocation, i)>;
			i += 1;
		}
		oneShotClosureEdges += <Return(nestedFunctionLocation), Result(oneShotClosureLocation)>;
	}
	return oneShotClosureEdges;
}

private Graph[Vertex] unresolvedEdges(list[Tree] unresolvedCallSites) {
	Graph[Vertex] unresolvedEdges = {};
	for (Tree unresolvedCallSite <- unresolvedCallSites) {
		loc callSiteLocation = unresolvedCallSite@\loc;
		int i = 1;
		for (Tree arg <- extractArguments(unresolvedCallSite)) {
			unresolvedEdges += <Argument(callSiteLocation, i), Unknown()>;
			i += 1;
		}
		unresolvedEdges += <Unknown(), Result(callSiteLocation)>;
	}
	return unresolvedEdges;
}

private Graph[Vertex] escapingEdges(list[Tree] escapingFunctions) {
	Graph[Vertex] escapingEdges = {};
	for (Tree escapingFunction <- escapingFunctions) {
		loc escapingFunctionLocation = escapingFunction@\loc;
		int i = 1;
		println("Unparsed: <unparse(escapingFunction)>");
		for (Tree param <- extractParameters(escapingFunction)) {
			escapingEdges += <Unknown(), Parameter(escapingFunctionLocation, i)>;
			i += 1;
		}
		escapingEdges += <Return(escapingFunctionLocation), Unknown()>;
	}
	return escapingEdges;
}

private tuple[lrel[Tree, Tree] oneShot, list[Tree] unresolved, list[Tree] functionsInsideClosures] analyseCallSites(trees) {
	lrel[Tree, Tree] oneShot = [];
	list[Tree] unresolved = [], functionsInsideClosures = [];
	private void analyseCall(call, closure) {
		println("Found call: <call>");
		if ((Expression)`(function (<{Id ","}* _>) <Block _>)` := call || (Expression)`(function <Id _> (<{Id ","}* _>) <Block _>)` := call) {
			println("Which is a one-shot closure");
			oneShot += <call, closure>;
			functionsInsideClosures += extractNestedExpression(call);
		} else {
			println("Which is an unresolved call site");
			unresolved += closure;
		}
	}
	visit(trees) {
		case functionCallParams:(Expression)`<Expression e> ( <{ Expression!comma ","}+ _> )`: analyseCall(e, functionCallParams);
		case functionCallNoParams:(Expression)`<Expression e>()`: analyseCall(e, functionCallNoParams);
	}
	return <oneShot, unresolved, functionsInsideClosures>;
}

private list[Tree] getEscapingFunctions(trees, list[Tree] functionsInsideClosures) {
	list[Tree] escaping = [];
	visit(trees) {
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

private Tree extractNestedExpression(nestingExpression) {
	if ((Expression)`(<Expression nestedExpression>)` := nestingExpression) {
		return nestedExpression;
	}
	throw "Passed expression is not a nesting expression.";
}