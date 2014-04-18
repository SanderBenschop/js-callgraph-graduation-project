module dynamicgraph::DynamicCallgraphRewriter

import util::Maybe;

import IO;
import String;
import EcmaScript;
import ParseTree;
import analysis::graphs::Graph;
import VertexFactory;
import utils::Utils;
import utils::FileUtils;
import NativeFlow;

import DataStructures;

public void rewrite(loc location) {
	tuple[list[str] functions, list[str] calls] result = isDirectory(location) ? rewriteFolder(location) : rewriteFile(location);
	writeFile(|project://JavaScript%20cg%20algorithms/src/dynamicgraph/filedump/instrumentationCode.js|, getInstrumentationCode(result));
}
public tuple[list[str] functions, list[str] calls] rewriteFolder(loc folderLoc) = rewriteFiles(folderLoc.ls, folderLoc);
public tuple[list[str] functions, list[str] calls] rewriteFile(loc file) = rewriteFiles([file], file.parent);

public tuple[list[str] functions, list[str] calls] rewriteFiles(list[loc] files, loc sourceFolderLoc) {
	loc targetFolder = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/filedump/|;
	list[str] combinedFunctionNames = [], combinedCallNames = [];
	for (loc fileLoc <- files) {
		int sourceFolderNameSize = size(sourceFolderLoc.uri);
		str targetFolderSuffix = substring(fileLoc.uri, sourceFolderNameSize);
		if (isDirectory(fileLoc)) {
			println("Recursing into directory <fileLoc>");
			tuple[list[str] functions, list[str] calls] recursive = rewriteFiles(fileLoc.ls, sourceFolderLoc);
			combinedFunctionNames += recursive.functions;
			combinedCallNames += recursive.calls;
		} else if (fileLoc.extension == "js") {
			println("Rewriting file <fileLoc>");
			Tree parseTree = parse(fileLoc);
			tuple[list[str] allFunctionNames, list[str] allCallNames, str rewrittenSource] output = rewriteForDynamicCallGraph(parseTree);
			writeFile(targetFolder + targetFolderSuffix, output.rewrittenSource);
			combinedFunctionNames += output.allFunctionNames;
			combinedCallNames += output.allCallNames;
		} else {
			println("Copying item <fileLoc> without altering as it is not a JavaScript file");
			copyFile(fileLoc, targetFolder + targetFolderSuffix);
		}
	}
	return <combinedFunctionNames, combinedCallNames>;
}

public tuple[list[str] allFunctionNames, list[str] allCallNames, str rewrittenSource] rewriteForDynamicCallGraph(Tree tree) {
	list[Tree] nestedExpressions = getExpressionsNestedInNewExpression(tree);
	list[str] allFunctionLocations = [], allCallLocations = [];
		
	private str addFunctionLocToBody(str body, loc location) {
		str formattedLoc = formatLoc(location);
		allFunctionLocations += ("\"<formattedLoc>\"");
		return replaceFirst(body, "{", "{
			  //Function augmented
			  var THISREFERENCE = this;
			  var FUNCTION_LOC = \"<formattedLoc>\";
			  if(COVERED_FUNCTIONS.indexOf(FUNCTION_LOC) === -1) COVERED_FUNCTIONS.push(FUNCTION_LOC);
			  if (LAST_CALL_LOC !== undefined) ADD_DYNAMIC_CALL_GRAPH_EDGE(LAST_CALL_LOC, FUNCTION_LOC);
			");
	}

	private str addNativeCallInformation(Tree nestedCall, loc location, str nativeFunctionName) {
		str formattedLoc = formatLoc(location);
		allCallLocations += ("\"<formattedLoc>\"");
		return "(function() {
		//Native call augmented
		var location = \"<formattedLoc>\";
		if(COVERED_CALLS.indexOf(location) === -1) COVERED_CALLS.push(location);
		ADD_DYNAMIC_CALL_GRAPH_EDGE(location, \"<nativeFunctionName>\");
		return <unparse(nestedCall)>;
		}())";
	}

	private str addLastCallInformation(Tree nestedCall, loc location) {
		str formattedLoc = formatLoc(location);
		allCallLocations += ("\"<formattedLoc>\"");
		return "(function() {
		//Call augmented
	  	var OLD_LAST_CALL_LOC = LAST_CALL_LOC;
	  	LAST_CALL_LOC = \"<formattedLoc>\";
	  	if(COVERED_CALLS.indexOf(LAST_CALL_LOC) === -1) COVERED_CALLS.push(LAST_CALL_LOC);
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
		str newUnparsedCall = isNativeElement(functionName) ? addNativeCallInformation(functionCall, callLoc, functionName) : addLastCallInformation(functionCall, callLoc);
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
		
		case newExpression:(Expression)`new <Expression e>` => markCall(e, newExpression)
		
		case functionCallParams:(Expression)`<Expression e> ( <{ Expression!comma ","}+ _> )` => markCall(e, functionCallParams)
		case functionCallNoParams:(Expression)`<Expression e>()` => markCall(e, functionCallNoParams)
	};
	
	return <allFunctionLocations, allCallLocations, unparse(replacedTree)>;
}

public list[Tree] getExpressionsNestedInNewExpression(Tree tree) {
	list[Tree] nestedExpressions = [];
	visit(tree) {
		case newExpression:(Expression)`new <Expression e>` : nestedExpressions += e;
	}
	return nestedExpressions;
}

private str getInstrumentationCode(tuple[list[str] functions, list[str] calls] information) {
	str allFunctionsJoined = intercalate(",", information.functions), allCallsJoined = intercalate(",", information.calls);;
	return "
	/** START OF GENERATED VARIABLES AND FUNCTIONS **/
	var THISREFERENCE = this, LAST_CALL_LOC = undefined, CALL_MAP = {}, ALL_FUNCTIONS = [<allFunctionsJoined>], COVERED_FUNCTIONS = [], ALL_CALLS = [<allCallsJoined>], COVERED_CALLS = [];
	
	function GET_UNCOVERED_FUNCTIONS() {
	    return ALL_FUNCTIONS.filter(function(func) {
	        return COVERED_FUNCTIONS.indexOf(func) === -1;
	    });
	}
	function GET_FUNCTION_COVERAGE_PERCENTAGE() {
		return COVERED_FUNCTIONS.length / ALL_FUNCTIONS.length * 100;
	}
	
	function GET_UNCOVERED_CALLS() {
	    return ALL_CALLS.filter(function(call) {
	        return COVERED_CALLS.indexOf(call) === -1;
	    });
	}
	function GET_CALL_COVERAGE_PERCENTAGE() {
		return COVERED_CALLS.length / ALL_CALLS.length * 100;
	}
	
	function ADD_DYNAMIC_CALL_GRAPH_EDGE(base, target) {
	    if (CALL_MAP[base] === undefined) CALL_MAP[base] = [];
	    if (CALL_MAP[base].indexOf(target) === -1) {
	    	CALL_MAP[base].push(target);
	    }
	}
	/** END OF GENERATED VARIABLES AND FUNCTIONS **/\n";
}