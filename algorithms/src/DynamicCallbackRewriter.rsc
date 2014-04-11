module DynamicCallbackRewriter

import util::Maybe;

import IO;
import String;
import EcmaScript;
import ParseTree;
import analysis::graphs::Graph;
import VertexFactory;
import Utils;

import DataStructures;

public void rewriteToFile(source) = rewriteToFile(source, |project://JavaScript%20cg%20algorithms/src/testing/filedump/rewritten.js|);
public void rewriteToFile(source, loc target) = writeFile(target, rewriteForDynamicCallGraph(parse(source)));

public str rewriteForDynamicCallGraph(Tree tree) {
	list[str] allFunctionLocations = [];
		
	private str addFunctionLocToBody(str body, loc location) {
		str formattedLoc = formatLoc(location);
		allFunctionLocations += ("\"<formattedLoc>\"");
		return replaceFirst(body, "{", "{
			  //Function augmented
			  var THISREFERENCE = this;
			  var FUNCTION_LOC = \"<formattedLoc>\";
			  COVERED_FUNCTIONS.push(FUNCTION_LOC);
			  if (LAST_CALL_LOC !== undefined) {
			    if (CALL_MAP[LAST_CALL_LOC] === undefined) CALL_MAP[LAST_CALL_LOC] = [];
	            console.log(\"Adding edge \" + LAST_CALL_LOC + \" --\> <formattedLoc> \");
	            CALL_MAP[LAST_CALL_LOC].push(FUNCTION_LOC);
	          }
			");
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
	
	private Tree markCall(functionCall) {
		loc callLoc = functionCall@\loc;
		str newUnparsedCall = addLastCallInformation(functionCall, callLoc);
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
		
		//case newFunctionCallParams:(Expression)`new <Expression _> ( <{ Expression!comma ","}+ _> )` => markCall(newFunctionCallParams)
		//case newFunctionCallNoParams:(Expression)`new <Expression _>()` => markCall(newFunctionCallNoParams)
		//case newNoParams:(Expression)`new <Expression _>` => markCall(newNoParams)
		
		case functionCallParams:(Expression)`<Expression _> ( <{ Expression!comma ","}+ _> )` => markCall(functionCallParams)
		case functionCallNoParams:(Expression)`<Expression _>()` => markCall(functionCallNoParams)
	};
	
	str allFunctionsJoined = intercalate(",", allFunctionLocations);
	str globals = "
	/** START OF GENERATED VARIABLES AND FUNCTIONS **/
	var THISREFERENCE = this, LAST_CALL_LOC = undefined, CALL_MAP = {}, ALL_FUNCTIONS = [<allFunctionsJoined>], COVERED_FUNCTIONS = [];
	function getUncoveredFunctions() {
	    return ALL_FUNCTIONS.filter(function(func) {
	        return COVERED_FUNCTIONS.indexOf(func) == -1;
	    });
	}
	function getCoveragePercentage() {
		return COVERED_FUNCTIONS.length / ALL_FUNCTIONS.length * 100;
	}
	/** END OF GENERATED VARIABLES AND FUNCTIONS **/\n";
	return globals + unparse(replacedTree);
}