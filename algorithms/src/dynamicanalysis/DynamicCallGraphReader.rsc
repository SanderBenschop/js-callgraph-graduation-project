module dynamicanalysis::DynamicCallGraphReader

import IO;
import String;
import lang::json::\syntax::JSON;
import lang::json::ast::Implode;
import lang::json::ast::JSON;
import staticanalysis::DataStructures;
import analysis::graphs::Graph;
import ParseTree;
import utils::GraphUtils;
import staticanalysis::NativeFlow;

public Graph[str] convertJsonToGraph(loc jsonFile) {
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