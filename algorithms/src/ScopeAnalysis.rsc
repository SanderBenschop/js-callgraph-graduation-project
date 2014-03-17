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

/* TODO: find out if all the implementations in the JS impl are correct and implement myself:
 * FunctionDeclaration
 * FunctionExpression
 * CatchClause
 * MemberExpression
 * Property
 */ 
public Tree addScopingInformationToTree(Tree tree) {
	return addScopingInformationToTree(tree, nothing());
}

private Tree addScopingInformationToTree(Tree tree, Maybe[SymbolTable] parent) {
	SymbolMap symbolMap = ();
	
	private VariableDeclaration annotateVariableDecl(VariableDeclaration va, Id id) {
		println("Annotation variableDeclaration <va> with scope.");
		symbolMap += (unparse(id) : Variable(id@\loc));
		va@scope = createSymbolTable(symbolMap, parent);
		return va;
	}
	
	private Tree annotateElementWithCurrentScope(Tree element) {
		println("Annotating <element> with current scope");
		element@scope = createSymbolTable(symbolMap, parent);
		return element;
	}
	
	return top-down-break visit(tree) {
		case varDecl:(VariableDeclaration)`<Id id>` => annotateVariableDecl(varDecl, id)
		case varDecl:(VariableDeclaration)`<Id id> = <Expression _>` => annotateVariableDecl(varDecl, id)
		case (Expression)`<Id id>` => annotateElementWithCurrentScope(id)
		case this:(Expression)`this` => annotateElementWithCurrentScope(this)
	}
}

private SymbolTable createSymbolTable(SymbolMap symbolMap, Maybe[SymbolTable] optionalParent) {
	if (just(SymbolTable parent) := optionalParent) {
		return child(symbolMap, parent);
	} else {
		return root(symbolMap);
	}
}