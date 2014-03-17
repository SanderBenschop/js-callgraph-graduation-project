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
 * Add THIS references in functions
 * See why in the JS they see a function decl as both an expression and a decl.
 * Add function scoping (visit id, properties and body) --> For both expression and decl?
 */ 
public Tree addScopingInformationToTree(Tree tree) {
	return addScopingInformationToTree(tree, nothing());
}

private Tree addScopingInformationToTree(tree, SymbolTable parent) = addScopingInformationToTree(tree, just(parent));
private Tree addScopingInformationToTree(Tree tree, Maybe[SymbolTable] parent) {
	println("Creating symbol map");
	SymbolMap symbolMap = ();
	
	private VariableDeclaration annotateVariableDecl(VariableDeclaration va, Id id) {
		println("Annotation variableDeclaration <va> with scope.");
		str name = unparse(id);
		symbolMap += (name : identifier(name, id@\loc));
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
		
		//TODO: why don't they make a difference in the js thing between function expressions and decls?
		//If you have a decl it is treated as both.
		case functionDecl:(FunctionDeclaration)`function <Id id> (<{Id ","}* params>) <Block body>` => {
			println("Adding func decl <id> to symbolMap.");
			str name = unparse(id);
			symbolMap += (name : identifier(name, id@\loc));
			//TODO: add scope 
			
			//TODO: remove duplication
			for (Id param <- params) {
				str name = unparse(param);
				symbolMap += (name : identifier(name, param@\loc));
			}
					
			//I probably don't have to backup the symbolMap as we just create a new one when recursing. TODO: CHECK!
			println("Recursing into body of functionDecl <id>");
			return addScopingInformationToTree(body, createSymbolTable(symbolMap, parent)); //Is this correct?
		}
	}
}

private SymbolTable createSymbolTable(SymbolMap symbolMap, Maybe[SymbolTable] optionalParent) {
	if (just(SymbolTable parent) := optionalParent) {
		return child(symbolMap, parent);
	} else {
		return root(symbolMap);
	}
}