module dynamicgraph::DynamicCallGraphReader

import IO;
import String;
import lang::json::\syntax::JSON;
import lang::json::ast::Implode;
import lang::json::ast::JSON;
import DataStructures;
import analysis::graphs::Graph;
import ParseTree;
import utils::GraphUtils;
import NativeFlow;

public Graph[str] convertJsonToGraph(loc jsonFile) {
	set[str] createBuiltinNodes(str string) {
		if (isNativeTarget(string)) return { "Builtin(<key>)" | key <- getKeysByValue(string) };
		list[str] splitted = split(".", string);
		int maxIndex = size(splitted);
		for (i <- [1..maxIndex]) {
			str joined = intercalate(".", splitted[i..]);
			if (isNativeTarget(joined)) return { "Builtin(<key>)" | key <- getKeysByValue(joined) };
		}
		if (isNativeBase(string)) return {"Builtin(<nativeFlows[string]>)"};
		println("WARNING - Cannot extract call to native function from <string> for json file <jsonFile>");
		return {};
	}

	Graph[str] callGraph = {};
	JSONText cst = parse(#JSONText, jsonFile);
	Value ast = buildAST(cst);
	if (object(map[str memberName, Value memberValue] members) := ast) {
		for (str base <- members) {
			if (array(list[Value] targetValues) := members[base]) {
				for (Value targetValue <- targetValues) {
					if (string(target) := targetValue) {
						if (!isEmpty(target)) {
							str callee = "Callee(<base>)";
							if (matchesNativeElement(target)) {
								//Create builtin nodes.
								callGraph += { <callee, builtin> | builtin <- createBuiltinNodes(target) };
							} else {
								str target = "Func(<target>)";
								callGraph += <callee, target>;
							}
						}
					} else throw "<targetValue> is not a string";
				}
			} else throw "<targetValueArray> is not an array";
		}
	} else throw "Not a valid call map!";
	return callGraph;
}

private JSONText parse(loc jsonFile) = parse(#JSONText, readFile(jsonFile));