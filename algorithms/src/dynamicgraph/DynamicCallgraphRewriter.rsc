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
import utils::StringUtils;
import utils::GraphUtils;
import NativeFlow;	
import Node;

import DataStructures;

anno Tree Tree @ original;

public void rewrite(loc location) = rewrite(location, {}, {});
public void rewrite(loc location, set[str] excludePatterns, set[str] frameworkPatterns) {
	tuple[list[str] functions, list[str] calls] result = isDirectory(location) ? rewriteFolder(location, excludePatterns, frameworkPatterns) : rewriteFile(location, excludePatterns, frameworkPatterns);
	writeFile(|project://JavaScript%20cg%20algorithms/src/dynamicgraph/filedump/instrumentationCode.js|, getInstrumentationCode(result));
}
public tuple[list[str] functions, list[str] calls] rewriteFolder(loc folderLoc, set[str] excludePatterns, set[str] frameworkPatterns) = rewriteFiles(folderLoc.ls, folderLoc, excludePatterns, frameworkPatterns);
public tuple[list[str] functions, list[str] calls] rewriteFile(loc file, set[str] excludePatterns, set[str] frameworkPatterns) = rewriteFiles([file], file.parent, excludePatterns, frameworkPatterns);

public tuple[list[str] functions, list[str] calls] rewriteFiles(list[loc] files, loc sourceFolderLoc, set[str] excludePatterns, set[str] frameworkPatterns) {
	loc targetFolder = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/filedump/|;
	list[str] combinedFunctionNames = [], combinedCallNames = [];
	for (loc fileLoc <- files) {
		int sourceFolderNameSize = size(sourceFolderLoc.uri);
		str targetFolderSuffix = substring(fileLoc.uri, sourceFolderNameSize);
		if (isDirectory(fileLoc)) {
			println("Recursing into directory <fileLoc>");
			tuple[list[str] functions, list[str] calls] recursive = rewriteFiles(fileLoc.ls, sourceFolderLoc, excludePatterns, frameworkPatterns);
			combinedFunctionNames += recursive.functions;
			combinedCallNames += recursive.calls;
		} else if (fileLoc.extension == "js" && !matchesAPattern(fileLoc.uri, excludePatterns)) {
			println("Rewriting file <fileLoc>");
			Tree parseTree = parse(fileLoc);
			bool isFrameworkFile = matchesAPattern(fileLoc.uri, frameworkPatterns);
			if (isFrameworkFile) println("WARNING - File <fileLoc.uri> is treated as a framework file. Only call targets will be placed. Coverage will not be counted.");
			tuple[list[str] allFunctionNames, list[str] allCallNames, str rewrittenSource] output = rewriteForDynamicCallGraph(parseTree, isFrameworkFile);
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

public tuple[list[str] allFunctionNames, list[str] allCallNames, str rewrittenSource] rewriteForDynamicCallGraph(Tree tree, bool isFrameworkFile) {
	list[Tree] nestedExpressions = getExpressionsNestedInNewExpression(tree);
	list[str] allFunctionLocations = [], allCallLocations = [];
		
	private str addFunctionLocToBody(str body, loc location) {
		str formattedLoc = formatLoc(location);
		if (!isFrameworkFile) allFunctionLocations += ("\"<formattedLoc>\"");
		return replaceFirst(body, "{", "{
			  //Function augmented
			  var THISREFERENCE = this;
			  var FUNCTION_LOC = \"<formattedLoc>\";
			  CALL_STACK.push(FUNCTION_LOC);
			  if(<!isFrameworkFile> && COVERED_FUNCTIONS.indexOf(FUNCTION_LOC) === -1) COVERED_FUNCTIONS.push(FUNCTION_LOC);
			  if (LAST_CALL_LOC !== undefined) ADD_DYNAMIC_CALL_GRAPH_EDGE(LAST_CALL_LOC, FUNCTION_LOC);
			");
	}

	private str addLastCallInformation(Tree nestedCall, loc location, Tree functionExpression) {
		str formattedLoc = formatLoc(location);
		allCallLocations += ("\"<formattedLoc>\"");
		str call = unparse(nestedCall);
		str functionExpressionString = unparse(functionExpression);
		return "(function() {
		//Call augmented
	  	var OLD_LAST_CALL_LOC = LAST_CALL_LOC;
	  	LAST_CALL_LOC = \"<formattedLoc>\";
	  	if(COVERED_CALLS.indexOf(LAST_CALL_LOC) === -1) COVERED_CALLS.push(LAST_CALL_LOC);
	  	var LENGTH_BEFORE = CALL_STACK.length;
	  	var result = <call>;
	  	if (CALL_STACK.length === LENGTH_BEFORE) {
	  		ADD_DYNAMIC_CALL_GRAPH_EDGE(LAST_CALL_LOC, \'<convertToDynamicTarget(functionExpressionString)>\');
	  	} else {
	  		CALL_STACK.pop();
	  	}
	    LAST_CALL_LOC = OLD_LAST_CALL_LOC;
	    return result;
	    }())";
	}
	
	private Tree markCall(functionExpression, functionCall) {
		if (isFrameworkFile) {
			println("Call <functionCall> is a framework call and will thus not be wrapped.");
			return functionCall;
		} else if ("original" in getAnnotations(functionCall) && functionCall@original in nestedExpressions) {
			println("Call <functionCall> is nested and will thus not be wrapped.");
			return functionCall;
		}
		str functionName = unparse(functionExpression);
		loc callLoc = functionCall@\loc;
		str newUnparsedCall = addLastCallInformation(functionCall, callLoc, functionExpression);
		try 
			return parse(newUnparsedCall);
		catch e: {
			println("Error parsing next snippet:");
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
		
	Tree annotatedTree = visit(tree) {
		case newE:(Expression)`new <Expression e>` => addOriginalToExpression(e, newE@\loc)
	};
	
	Tree replacedTree = visit(annotatedTree) { 
		case (Expression)`this` => (Expression)`THISREFERENCE` 
	};
	
	Tree markedTree = visit(replacedTree) {
		case func:(Expression)`function (<{Id ","}* params>) <Block body>` => markNamelessFunctionExpressionLoc(params, body, func@\loc)
		case func:(Expression)`function <Id id> (<{Id ","}* params>) <Block body>` => markNamedFunctionExpressionLoc(id, params, body, func@\loc)
		case func:(FunctionDeclaration)`function <Id id> (<{Id ","}* params>) <Block body> <ZeroOrMoreNewLines nl>` => markFunctionDeclLoc(id, params, body, nl, func@\loc) 
		
		case newExpression:(Expression)`new <Expression e>` => markCall(e, newExpression)
		
		case functionCallParams:(Expression)`<Expression e> ( <{ Expression!comma ","}+ _> )` => markCall(e, functionCallParams)
		case functionCallNoParams:(Expression)`<Expression e>()` => markCall(e, functionCallNoParams)
	};
	
	return <allFunctionLocations, allCallLocations, unparse(markedTree)>;
}

public Tree addOriginalToExpression(Tree e, loc newELoc) {
	Tree replacedE = e;
	replacedE@original = e;
	replacedE@\loc = e@\loc;
	
	Tree replacedNewE = (Expression)`new <Expression replacedE>`;
	replacedNewE@\loc = newELoc;
	return replacedNewE;
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
	str template = readFile(|project://JavaScript%20cg%20algorithms/src/dynamicgraph/defaultFunctionsTemplate.js|);
	str filledTemplate = replaceAll(template, "$$allFunctionsJoined$$", allFunctionsJoined);
	filledTemplate = replaceAll(filledTemplate, "$$allCallsJoined$$", allCallsJoined);
	return filledTemplate;
}