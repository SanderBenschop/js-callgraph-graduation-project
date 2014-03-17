module testing::snippets::ScopeAnalysisTest

import EcmaScript;
import ParseTree;
import IO;
import Node;

import DataStructures;
import ScopeAnalysis;

public test bool testAssignOneToX() = assertDeclaredVariablesHaveScope(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToX.js|);
public test bool testDeclareX() = assertDeclaredVariablesHaveScope(|project://JavaScript%20cg%20algorithms/src/testing/snippets/declareX.js|);
public test bool testDeclareXdeclareY() = assertDeclaredVariablesHaveScope(|project://JavaScript%20cg%20algorithms/src/testing/snippets/declareXdeclareY.js|);
public test bool testDeclareFunctionX() =  assertDeclaredVariablesHaveScope(|project://JavaScript%20cg%20algorithms/src/testing/snippets/declareFX.js|);
public test bool testId() = assertDeclaredVariablesHaveScope(|project://JavaScript%20cg%20algorithms/src/testing/snippets/id.js|);
public test bool testThis() = assertDeclaredVariablesHaveScope(|project://JavaScript%20cg%20algorithms/src/testing/snippets/this.js|);

public bool assertDeclaredVariablesHaveScope(loc location) {
	Tree tree = parse(location);
	tree = addScopingInformationToTree(tree);

	bool visitedSomething = false;

	private void checkElement(Tree element) {
		visitedSomething = true;
		println("Checking element: <element>");
		map[str, value] annotations = getAnnotations(element);
		if ("scope" notin annotations) throw "Did not find a scope annotation on element <element>.";
	}
	
	visit(tree) {
		case v:(VariableDeclaration)`<Id _>`: checkElement(v);
		case v:(VariableDeclaration)`<Id _> = <Expression _>`: checkElement(v);
		case (Expression)`<Id id>`: checkElement(id);
		case this:(Expression)`this`: checkElement(this);
		
	}
	
	if (!visitedSomething) throw "Did not visit anything";
	return true;
}