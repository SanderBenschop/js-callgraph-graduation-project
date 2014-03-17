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
	private VariableDeclaration addScopeToVariableDeclaration(VariableDeclaration original) {
		println("Annotating original");
		Id id = getIdFromVariableDeclaration(original);
		symbolMap += (unparse(id) : Variable(id@\loc));
		println("Added id at loc to symbol map.");
		original@scope = createSymbolTable(symbolMap, parent);
		return original;
	}
	
	SymbolMap symbolMap = ();
	return top-down-break visit(tree) {
		case (Statement)`var <{VariableDeclaration ","}+ a>`: {
			throw "Unimplemented";
		}
		//case (Statement)`var <{VariableDeclaration ","}+ variableDeclarations>;`: {
		//	for (VariableDeclaration variableDeclaration <- variableDeclarations) {
		//		//TODO: make prop when globally scoped.
		//		Id id = getIdFromVariableDeclaration(variableDeclaration);
		//		symbolMap += (unparse(id) : Variable(id@\loc));
		//		println("Added id at loc to symbol map.");
		//		variableDeclaration@scope = createSymbolTable(symbolMap, parent);
		//	}
		//}
		case varDecl:(VariableDeclaration)`<Id id> = <Expression e>` => addScopeToVariableDeclaration(varDecl)
	}
}

private SymbolTable createSymbolTable(SymbolMap symbolMap, Maybe[SymbolTable] optionalParent) {
	if (just(SymbolTable parent) := optionalParent) {
		return child(symbolMap, parent);
	} else {
		return root(symbolMap);
	}
}

private Id getIdFromVariableDeclaration(VariableDeclaration variableDecl) {
	if ((VariableDeclaration)`<Id i>` := variableDecl) {
		return i;
	} else if ((VariableDeclaration)`<Id i> = <Expression e>` := variableDecl) {
		return i;
	}
	throw "Cannot find Id in VariableDeclaration.";
}