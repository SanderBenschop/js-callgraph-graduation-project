module utils::DynamicGraphFilteringUtils

import EcmaScript;
import analysis::graphs::Graph;
import DataStructures;
import utils::Utils;
import ParseTree;
import ScopeAnalysis;

//Functions can either be directly put as arguments or refered to by name or property.
//Or it could be the result of another call...
public Graph[str] generatePossibleIncorrectCallbackEdges(locs) {
	trees = parseAll(locs);
	SymbolTableMap symbolTableMap = createSymbolTableMap(trees);

	Graph[str] stringGraph = {};
	set[loc] functionLocs = getFunctionLocations(trees);
	visit(trees) {
		case exp:(Expression)`<Expression _> ( <{ Expression!comma ","}+ args> )` : {
			for (arg <- args) {
				if (arg@\loc in functionLocs) {
					stringGraph += <formatLoc(exp@\loc), formatLoc(arg@\loc)>;
				}
				else if ((Expression)`<Id id>` := arg) {
					str name = unparse(id);
					SymbolTable symbolTable = symbolTableMap[arg@\loc];
					if(just(tuple[Identifier id, bool _] pair) := find(name, symbolTable)) {
						if (declaration(loc location) := pair.id) {
							if (location in functionLocs) {
								stringGraph += <"Callee(<formatLoc(exp@\loc)>)", "Func(<formatLoc(location)>)">;
							}
						}
					}
				}
			}
		}
	}
	return stringGraph;
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