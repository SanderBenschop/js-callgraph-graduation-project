module ScopeAnalysis

import ParseTree;
import util::Maybe;

import DataStructures;
import EcmaScript;
import IO;

anno SymbolTable Tree @ scope;
anno SymbolTable Id @ scope;
anno SymbolTable SourceElement @ scope;
anno SymbolTable VariableDeclaration @ scope;

public Tree addScopingInformationToTree(Tree tree) {
	return addScopingInformationToTree(tree, nothing());
}

private Tree addScopingInformationToTree(Tree tree, Maybe[SymbolTable] parent) {
	SymbolMap symbolMap = ();
	
	private VariableDeclaration annotateVariableDecl(VariableDeclaration va, Id id) {
		symbolMap += (unparse(id) : Variable(id@\loc));
		va@scope = createSymbolTable(symbolMap, parent);
		return va;
	}
	
	return top-down-break visit(tree) {
		case varDecl:(VariableDeclaration)`<Id id>` => annotateVariableDecl(varDecl, id)
		case varDecl:(VariableDeclaration)`<Id id> = <Expression _>` => annotateVariableDecl(varDecl, id)
	}
}

private SymbolTable createSymbolTable(SymbolMap symbolMap, Maybe[SymbolTable] optionalParent) {
	if (just(SymbolTable parent) := optionalParent) {
		return child(symbolMap, parent);
	} else {
		return root(symbolMap);
	}
}