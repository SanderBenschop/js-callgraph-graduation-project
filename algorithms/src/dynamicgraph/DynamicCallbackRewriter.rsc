module dynamicgraph::DynamicCallbackRewriter

import util::Maybe;

import IO;
import String;
import EcmaScript;
import ParseTree;
import analysis::graphs::Graph;
import VertexFactory;
import Utils;
import NativeFlow;

import DataStructures;

public void rewriteToFile(source) = rewriteToFile(source, |project://JavaScript%20cg%20algorithms/src/testing/filedump/rewritten.js|);
public void rewriteToFile(source, loc target) = writeFile(target, rewriteForDynamicCallGraph(parse(source)));

public str rewriteForDynamicCallGraph(Tree tree) {
	list[Tree] nestedExpressions = getExpressionsNestedInNewExpression(tree);
	list[str] allFunctionLocations = [];
		
	private str addFunctionLocToBody(str body, loc location) {
		str formattedLoc = formatLoc(location);
		allFunctionLocations += ("\"<formattedLoc>\"");
		return replaceFirst(body, "{", "{
			  //Function augmented
			  var THISREFERENCE = this;
			  var FUNCTION_LOC = \"<formattedLoc>\";
			  if(COVERED_FUNCTIONS.indexOf(FUNCTION_LOC) === -1) COVERED_FUNCTIONS.push(FUNCTION_LOC);
			  if (LAST_CALL_LOC !== undefined) addDynamicCallGraphEdge(LAST_CALL_LOC, FUNCTION_LOC);
			");
	}

	private str addNativeCallInformation(Tree nestedCall, loc location, str nativeFunctionName) {
		return "(function() {
		//Native call augmented
		addDynamicCallGraphEdge(\"<formatLoc(location)>\", \"<nativeFunctionName>\");
		return <unparse(nestedCall)>;
		}())";
	}

	private str addLastCallInformation(Tree nestedCall, loc location) {
		return "(function() {
		//Call augmented
	  	var OLD_LAST_CALL_LOC = LAST_CALL_LOC;
	  	LAST_CALL_LOC = \"<formatLoc(location)>\";
	  	var result = <unparse(nestedCall)>;
	    LAST_CALL_LOC = OLD_LAST_CALL_LOC;
	    return result;
	    }())";
	}
	
	private Tree markCall(functionExpression, functionCall) {
		if (functionCall in nestedExpressions) {
			println("Call <functionCall> is nested and will thus not be wrapped.");
			return functionCall;
		}
		str functionName = unparse(functionExpression);
		loc callLoc = functionCall@\loc;
		str newUnparsedCall = isNativeTarget(functionName) ? addNativeCallInformation(functionCall, callLoc, functionName) : addLastCallInformation(functionCall, callLoc);
		return parse(newUnparsedCall);
	}
	
	private Tree markFunctionDeclLoc(id, params, body, nl, functionLoc) {
		str unparsedBody = unparse(body), newUnparsedBody = addFunctionLocToBody(unparsedBody, functionLoc);
		Tree newBody = parse(#Block, newUnparsedBody);
		return (FunctionDeclaration)`function <Id id> (<{Id ","}* params>) <Block newBody> <ZeroOrMoreNewLines nl>`;
	}
	
	private Tree markNamelessFunctionExpressionLoc(params, body, functionLoc) {
		str unparsedBody = unparse(body), newUnparsedBody = addFunctionLocToBody(unparsedBody, functionLoc);
		Tree newBody = parse(#Block, newUnparsedBody);
		return (Expression)`function (<{Id ","}* params>) <Block newBody>`;
	}
	
	private Tree markNamedFunctionExpressionLoc(id, params, body, functionLoc) {
		str unparsedBody = unparse(body), newUnparsedBody = addFunctionLocToBody(unparsedBody, functionLoc);
		Tree newBody = parse(#Block, newUnparsedBody);
		return (Expression)`function <Id id> (<{Id ","}* params>) <Block newBody>`;
	}
	
	Tree replacedTree = visit(tree) { 
		case (Expression)`this` => (Expression)`THISREFERENCE` 
	};
	
	replacedTree = visit(replacedTree) {
		case func:(Expression)`function (<{Id ","}* params>) <Block body>` => markNamelessFunctionExpressionLoc(params, body, func@\loc)
		case func:(Expression)`function <Id id> (<{Id ","}* params>) <Block body>` => markNamedFunctionExpressionLoc(id, params, body, func@\loc)
		case func:(FunctionDeclaration)`function <Id id> (<{Id ","}* params>) <Block body> <ZeroOrMoreNewLines nl>` => markFunctionDeclLoc(id, params, body, nl, func@\loc) 
		
		case newExpression:(Expression)`new <Expression _>` => markCall(newExpression)
		
		case functionCallParams:(Expression)`<Expression e> ( <{ Expression!comma ","}+ _> )` => markCall(e, functionCallParams)
		case functionCallNoParams:(Expression)`<Expression e>()` => markCall(e, functionCallNoParams)
	};
	
	str allFunctionsJoined = intercalate(",", allFunctionLocations);
	str globals = "
	/** START OF GENERATED VARIABLES AND FUNCTIONS **/
	var THISREFERENCE = this, LAST_CALL_LOC = undefined, CALL_MAP = {}, ALL_FUNCTIONS = [<allFunctionsJoined>], COVERED_FUNCTIONS = [];
	function getUncoveredFunctions() {
	    return ALL_FUNCTIONS.filter(function(func) {
	        return COVERED_FUNCTIONS.indexOf(func) === -1;
	    });
	}
	function getCoveragePercentage() {
		return COVERED_FUNCTIONS.length / ALL_FUNCTIONS.length * 100;
	}
	function addDynamicCallGraphEdge(base, target) {
	    if (CALL_MAP[base] === undefined) CALL_MAP[base] = [];
	    if (CALL_MAP[base].indexOf(target) === -1) {
	    	CALL_MAP[base].push(target);
	    }
	}
	/** END OF GENERATED VARIABLES AND FUNCTIONS **/\n";
	return globals + unparse(replacedTree);
}

public list[Tree] getExpressionsNestedInNewExpression(Tree tree) {
	list[Tree] nestedExpressions = [];
	visit(tree) {
		case newExpression:(Expression)`new <Expression e>` : nestedExpressions += e;
	}
	return nestedExpressions;
}