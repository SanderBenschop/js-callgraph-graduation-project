module testing::snippets::ScopeAnalysisTest

import EcmaScript;
import ParseTree;
import IO;
import Node;

import DataStructures;
import ScopeAnalysis;

public test bool testAssignOneToX() = assertDeclaredVariablesHaveScope(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToX.js|);
public test bool testDeclareX() = assertDeclaredVariablesHaveScope(|project://JavaScript%20cg%20algorithms/src/testing/snippets/declareX.js|);

private bool assertDeclaredVariablesHaveScope(loc location) {
	Tree tree = parse(location);
	tree = addScopingInformationToTree(tree);
	visit(tree) {
		case v:(VariableDeclaration)`<Id id> = <Expression e>`: {
			println("Checking id: <id>");
			map[str, value] annotations = getAnnotations(v);
			if ("scope" notin annotations) throw "Did not find a scope annotation on variableDecl.";
		}
	}
	return true;
}