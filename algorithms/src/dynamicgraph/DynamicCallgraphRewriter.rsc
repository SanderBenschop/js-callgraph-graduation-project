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
	tuple[list[str] functions, list[str] calls, map[str,Tree] functionExpressions] result = isDirectory(location) ? rewriteFolder(location) : rewriteFile(location);
	writeFile(|project://JavaScript%20cg%20algorithms/src/dynamicgraph/filedump/instrumentationCode.js|, getInstrumentationCode(result));
}
public tuple[list[str] functions, list[str] calls, map[str,Tree] functionExpressions] rewriteFolder(loc folderLoc) = rewriteFiles(folderLoc.ls, folderLoc);
public tuple[list[str] functions, list[str] calls, map[str,Tree] functionExpressions] rewriteFile(loc file) = rewriteFiles([file], file.parent);

public tuple[list[str] functions, list[str] calls, map[str,Tree] functionExpressions] rewriteFiles(list[loc] files, loc sourceFolderLoc) {
	loc targetFolder = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/filedump/|;
	list[str] combinedFunctionNames = [], combinedCallNames = [];
	map[str,Tree] combinedFunctionExpressions = ();
	for (loc fileLoc <- files) {
		int sourceFolderNameSize = size(sourceFolderLoc.uri);
		str targetFolderSuffix = substring(fileLoc.uri, sourceFolderNameSize);
		if (isDirectory(fileLoc)) {
			println("Recursing into directory <fileLoc>");
			tuple[list[str] functions, list[str] calls, map[str,Tree] functionExpressions] recursive = rewriteFiles(fileLoc.ls, sourceFolderLoc);
			combinedFunctionNames += recursive.functions;
			combinedCallNames += recursive.calls;
			combinedFunctionExpressions += recursive.functionExpressions;
		} else if (fileLoc.extension == "js") {
			println("Rewriting file <fileLoc>");
			Tree parseTree = parse(fileLoc);
			tuple[list[str] allFunctionNames, list[str] allCallNames, map[str,Tree] allFunctionExpressions, str rewrittenSource] output = rewriteForDynamicCallGraph(parseTree);
			writeFile(targetFolder + targetFolderSuffix, output.rewrittenSource);
			combinedFunctionNames += output.allFunctionNames;
			combinedCallNames += output.allCallNames;
			combinedFunctionExpressions += output.allFunctionExpressions;
		} else {
			println("Copying item <fileLoc> without altering as it is not a JavaScript file");
			copyFile(fileLoc, targetFolder + targetFolderSuffix);
		}
	}
	return <combinedFunctionNames, combinedCallNames, combinedFunctionExpressions>;
}

public tuple[list[str] allFunctionNames, list[str] allCallNames, map[str,Tree] functionExpressions, str rewrittenSource] rewriteForDynamicCallGraph(Tree tree) {
	list[Tree] nestedExpressions = getExpressionsNestedInNewExpression(tree);
	list[str] allFunctionLocations = [], allCallLocations = [];
	map[str, Tree] allFunctionExpressions = ();
		
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

	private str addLastCallInformation(Tree nestedCall, loc location, Tree functionExpression) {
		str formattedLoc = formatLoc(location);
		allCallLocations += ("\"<formattedLoc>\"");
		return "(function() {
		//Call augmented
	  	var OLD_LAST_CALL_LOC = LAST_CALL_LOC;
	  	LAST_CALL_LOC = \"<formattedLoc>\";
	  	if(COVERED_CALLS.indexOf(LAST_CALL_LOC) === -1) COVERED_CALLS.push(LAST_CALL_LOC);
	  	try {
	  		var FUNCTION_EXPRESSION = ALL_FUNCTION_EXPRESSIONS[LAST_CALL_LOC];
	  		var EVALUATED = eval(FUNCTION_EXPRESSION);
		  	if(IS_NATIVE_FUNCTION(EVALUATED)) {
		  		ADD_DYNAMIC_CALL_GRAPH_EDGE(LAST_CALL_LOC, FUNCTION_EXPRESSION);
		  	}
	  	} catch(e) {
	  		console.log(\"Error trying to parse expression: \" + e);
	  	}
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
		loc callLoc = functionCall@\loc;
		str newUnparsedCall = addLastCallInformation(functionCall, callLoc, functionExpression);
		try return parse(newUnparsedCall);
		catch e: {
			println("The following snippet caused an error while parsing");
			println(newUnparsedCall);
			throw e;
		}
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
	
	private void addFunctionExpression(functionExpression, functionCall) {
		loc callLoc = functionCall@\loc;
		str formattedLoc = formatLoc(callLoc);
		allFunctionExpressions += (formattedLoc : functionExpression);
	}
	
	visit(tree) {
		case newExpression:(Expression)`new <Expression e>` : addFunctionExpression(e, newExpression);
		case functionCallParams:(Expression)`<Id e> ( <{ Expression!comma ","}+ _> )` : addFunctionExpression(e, functionCallParams);
		case functionCallNoParams:(Expression)`<Id e>()` : addFunctionExpression(e, functionCallNoParams);
		case functionCallParams:(Expression)`<Expression e1>.<Id e2> ( <{ Expression!comma ","}+ _> )` : {
			Tree e = (Expression)`<Expression e1>.<Id e2>`;
			addFunctionExpression(e, functionCallParams);
		}
		case functionCallNoParams:(Expression)`<Expression e1>.<Id e2>()` : {
			Tree e = (Expression)`<Expression e1>.<Id e2>`;
			addFunctionExpression(e, functionCallNoParams);
		}
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
	
	return <allFunctionLocations, allCallLocations, allFunctionExpressions, unparse(replacedTree)>;
}

public list[Tree] getExpressionsNestedInNewExpression(Tree tree) {
	list[Tree] nestedExpressions = [];
	visit(tree) {
		case newExpression:(Expression)`new <Expression e>` : nestedExpressions += e;
	}
	return nestedExpressions;
}

private str getInstrumentationCode(tuple[list[str] functions, list[str] calls, map[str,Tree] functionExpressions] information) {
	str allFunctionsJoined = intercalate(",", information.functions), allCallsJoined = intercalate(",", information.calls);;
	str template = readFile(|project://JavaScript%20cg%20algorithms/src/dynamicgraph/defaultFunctionsTemplate.js|);
	str filledTemplate = replaceAll(template, "$$allFunctionsJoined$$", allFunctionsJoined);
	filledTemplate = replaceAll(filledTemplate, "$$allCallsJoined$$", allCallsJoined);
	
	list[str] functionExpressionJson = [];
	for (str key <- information.functionExpressions) {
		Tree val = information.functionExpressions[key];
		str unparsedVal = unparse(val);
		str unparsedEscapedVal = replaceAll(unparsedVal, "\"", "\\\"");
		functionExpressionJson += "\"<key>\" : \"<unparsedEscapedVal>\"";
	}
	str allFunctionExpressionsJoined = intercalate(",", functionExpressionJson);
	
	filledTemplate = replaceAll(filledTemplate, "$$allFunctionExpressions$$", allFunctionExpressionsJoined);
	
	return filledTemplate;
}