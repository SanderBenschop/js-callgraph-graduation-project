module utils::DynamicGraphFilteringUtils

import EcmaScript;
import staticanalysis::Main;
import analysis::graphs::Graph;
import staticanalysis::DataStructures;
import utils::Utils;
import utils::GraphUtils;
import utils::StringUtils;
import ParseTree;
import staticanalysis::ScopeAnalysis;
import staticanalysis::GraphBuilder;
import Relation;
import IO;
import staticanalysis::NativeFlow;
import String;

public Graph[str] generatePossibleIncorrectCallbackEdges(sources) {
	trees = parseAll(sources);
	Graph[Vertex] flowGraph = createOptimisticFlowGraph(trees);
	Graph[Vertex] reversedFlowGraph = reverseGraphDirection(flowGraph);

	Graph[str] stringGraph = {};
	set[loc] functionLocs = getFunctionLocations(trees);
	visit(trees) {
		case exp:(Expression)`<Expression _> ( <{ Expression!comma ","}+ args> )` : {
			int argIndex = 1;
			for (arg <- args) {
				if (arg@\loc in functionLocs) {
					stringGraph += <"Callee(<formatLoc(exp@\loc)>)", "Func(<formatLoc(arg@\loc)>)">;
				}
				else {
					Vertex argVertex = Argument(exp@\loc, argIndex);
					for(Vertex reachableFunction <- reach(reversedFlowGraph, { argVertex }), Function(location) := reachableFunction) {
						stringGraph += <"Callee(<formatLoc(exp@\loc)>)", "Func(<formatLoc(location)>)">;
					}
				}
				argIndex += 1;
			}
		}
	}
	return stringGraph;
}

public Graph[str] generatePossibleMissingEdges(Graph[str] possibleIncorrectCallbackEdges, map[str, str] sources) {
	Graph[str] possibleMissingEdges = {};
	for(str base <- domain(possibleIncorrectCallbackEdges)) {
		if (/Callee\(<file:.*>@\d+:<indexStart:\d+>-<indexEnd:\d+>\)/ := base) {
			str source = sources[file];
			str call = substring(source, toInt(indexStart), toInt(indexEnd));
			str strippedCall = convertToDynamicTarget(call);
			possibleMissingEdges += {<base, nativeTarget> | str nativeTarget <- createBuiltinNodes(strippedCall)};
		} else throw "Not a valid callee";
	}
	return possibleMissingEdges;
}

private set[loc] getFunctionLocations(trees) {
	set[loc] functionLocations = {};
	visit(trees) {
		case func:(Expression)`function (<{Id ","}* _>) <Block _>`: functionLocations += func@\loc;
		case func:(Expression)`function <Id id> (<{Id ","}* _>) <Block _>`: functionLocations += func@\loc;
		case func:(FunctionDeclaration)`function <Id id> (<{Id ","}* _>) <Block _> <ZeroOrMoreNewLines _>`: functionLocations += func@\loc;
	}
	return functionLocations;
}