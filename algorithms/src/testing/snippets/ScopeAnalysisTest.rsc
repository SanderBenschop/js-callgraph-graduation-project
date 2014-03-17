module testing::snippets::ScopeAnalysisTest

import EcmaScript;
import ParseTree;
import IO;
import Node;

import DataStructures;
import ScopeAnalysis;

public test bool testScopeIsAssignedToVar() {
	Tree tree = parse(|project://JavaScript%20cg%20algorithms/src/testing/snippets/assignOneToX.js|);
	tree = addScopingInformationToTree(tree);
	visit(tree) {
		//case (Statement)`var <{VariableDeclaration ","}+ vs>;`: {
		//	println("Found var decls");
		//	for (VariableDeclaration v <- vs) {
		//		println("Checking id: <v>");
		//		v@scope = root(());
		//		map[str, value] annotations = getAnnotations(v);
		//		println(annotations);
		//		//if ("scope" notin annotations) throw "Didn not find a scope annotation on variableDecl.";
		//	}
		//}
		case v:(VariableDeclaration)`<Id id> = <Expression e>`: {
			println("Checking id: <id>");
			//v@scope = root(());
			map[str, value] annotations = getAnnotations(v);
			println(getAnnotations(v));
			println(getAnnotations(id));
		}
	}
	return true;
}