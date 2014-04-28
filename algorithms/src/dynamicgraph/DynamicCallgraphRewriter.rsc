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
import NativeFlow;
 import Node;
 
import DataStructures;

anno Tree Tree @ original;

public void rewrite(loc location) = rewrite(location, {});
public void rewrite(loc location, set[str] excludePatterns) {
	tuple[list[str] functions, list[str] calls] result = isDirectory(location) ? rewriteFolder(location, excludePatterns) : rewriteFile(location, excludePatterns);
	writeFile(|project://JavaScript%20cg%20algorithms/src/dynamicgraph/filedump/instrumentationCode.js|, getInstrumentationCode(result));
}
public tuple[list[str] functions, list[str] calls] rewriteFolder(loc folderLoc, set[str] excludePatterns) = rewriteFiles(folderLoc.ls, folderLoc, excludePatterns);
public tuple[list[str] functions, list[str] calls] rewriteFile(loc file, set[str] excludePatterns) = rewriteFiles([file], file.parent, excludePatterns);

public tuple[list[str] functions, list[str] calls] rewriteFiles(list[loc] files, loc sourceFolderLoc, set[str] excludePatterns) {
	loc targetFolder = |project://JavaScript%20cg%20algorithms/src/dynamicgraph/filedump/|;
	list[str] combinedFunctionNames = [], combinedCallNames = [];
	for (loc fileLoc <- files) {
		int sourceFolderNameSize = size(sourceFolderLoc.uri);
		str targetFolderSuffix = substring(fileLoc.uri, sourceFolderNameSize);
		if (isDirectory(fileLoc)) {
			println("Recursing into directory <fileLoc>");
			tuple[list[str] functions, list[str] calls] recursive = rewriteFiles(fileLoc.ls, sourceFolderLoc, excludePatterns);
			combinedFunctionNames += recursive.functions;
			combinedCallNames += recursive.calls;
		} else if (fileLoc.extension == "js" && !excluded(fileLoc.uri, excludePatterns)) {
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

public bool excluded(str uri, set[str] patterns) {
	for (str pattern <- patterns) {
		if (/<pattern>/ := uri) return true;
	}
	return false;
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

	private str addLastCallInformation(Tree nestedCall, loc location, Tree functionExpression) {
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
		if ("original" in getAnnotations(functionCall) && functionCall@original in nestedExpressions) {
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
	Tree replacedTree = annotateOriginalTreesForNewExpression(tree);
	replacedTree = replaceThisOccurences(replacedTree);
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

public Tree annotateOriginalTreesForNewExpression(Tree tree) {
	return visit(tree) {
		case newExpression:(Expression)`new <Expression e>` => addOriginalToExpression(e)
	}
}

public Tree addOriginalToExpression(Tree expression) {
	expression@original = expression;
	return expression;
}

//Needs to be first to prevent var THISREFERENCE = THISREFERENCE;
//But this causes the wrapping of nested elements to be wrong.
//So I just compare against the original trees.
public Tree replaceThisOccurences(Tree tree) {
	return visit(tree) { 
		case (Expression)`this` => (Expression)`THISREFERENCE` 
	};
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


//public Maybe[Tree] extractFunctionFromCall(Tree call) = extractFunctionFromCall(call, false);
//public Maybe[Tree] extractFunctionFromCall(Tree call, bool returnSelf) {
//	top-down visit(call) {
//		case newExpression:(Expression)`new <Expression e>` : return extractFunctionFromCall(e, true);
//		case functionCallParams:(Expression)`<Id e> ( <{ Expression!comma ","}+ _> )` : return just(e);
//		case functionCallNoParams:(Expression)`<Id e>()` : return just(e);
//		case functionCallParams:(Expression)`<Expression e1>.<Id e2> ( <{ Expression!comma ","}+ _> )` : {
//			Tree e = (Expression)`<Expression e1>.<Id e2>`;
//			return just(e);
//		}
//		case functionCallNoParams:(Expression)`<Expression e1>.<Id e2>()` : {
//			Tree e = (Expression)`<Expression e1>.<Id e2>`;
//			return just(e);
//		}
//	}
//	return returnSelf ? just(call) : nothing();
//}

//private bool f(Tree tree) {
//	return (Expression)`function (<{Id ","}* params>) <Block body>` := tree ||
//		   (Expression)`function <Id id> (<{Id ","}* params>) <Block body>` := tree;
//}