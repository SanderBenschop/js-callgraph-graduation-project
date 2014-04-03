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

public str rewriteForDynamicCallGraph(Tree tree) {
	
	private Tree markCall(functionCall, callLoc) {
		str unparsedCall = unparse(functionCall), newUnparsedCall = addLastCallInformation(unparsedCall, callLoc);
		return parse(newUnparsedCall);
	}
	
	private Tree markFunctionDeclLoc(id, params, body, nl, functionLoc) {
		str unparsedBody = unparse(body), newUnparsedBody = addFunctionLocToBody(unparsedBody, functionLoc);
		Tree newBody = parse(#Block, newUnparsedBody);
		return (FunctionDeclaration)`function <Id id> (<{Id ","}* params>) <Block newBody> <ZeroOrMoreNewLines nl>`;
	}

	str globals = "var LAST_CALL_LOC = undefined, CALL_MAP = {};\n\t";

	return globals + unparse(visit(tree) {
		case func:(FunctionDeclaration)`function <Id id> (<{Id ","}* params>) <Block body> <ZeroOrMoreNewLines nl>` => markFunctionDeclLoc(id, params, body, nl, func@\loc) 
		case functionCallParams:(Expression)`<Expression _> ( <{ Expression!comma ","}+ _> )` => markCall(functionCallParams, functionCallParams@\loc)
		case functionCallNoParams:(Expression)`<Expression _>()` => markCall(functionCallNoParams, functionCallNoParams@\loc)
	});
}

public str addFunctionLocToBody(str body, loc location) {
	return replaceFirst(body, "{", "{ var FUNCTION_LOC = \"<formatLoc(location)>\"; 
		  if (LAST_CALL_LOC !== undefined) {
		    if (CALL_MAP[LAST_CALL_LOC] === undefined) CALL_MAP[LAST_CALL_LOC] = [];
            CALL_MAP[LAST_CALL_LOC].push(FUNCTION_LOC);
          }
		");
}

public str addLastCallInformation(str call, loc location) {
	return "(function(){
  	var OLD_LAST_CALL_LOC = LAST_CALL_LOC;
  	LAST_CALL_LOC = \"<formatLoc(location)>\";
  	var result = <call>
    LAST_CALL_LOC = OLD_LAST_CALL_LOC;
    return result;
    }())";
}
