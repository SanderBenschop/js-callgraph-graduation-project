module ScopeAnalysis

import ParseTree;
import util::Maybe;

import DataStructures;
import EcmaScript;
import IO;

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
public SymbolTableMap createSymbolTableMap(Tree tree) {
	return createSymbolTableMap(tree, nothing());
}

private SymbolTableMap createSymbolTableMap(tree, SymbolTable parent) = createSymbolTableMap(tree, just(parent));
private SymbolTableMap createSymbolTableMap(Tree tree, Maybe[SymbolTable] parent) {
	println("Creating symbol table map");
	SymbolTableMap symbolTableMap = ();
	
	println("Creating symbol map");
	SymbolMap symbolMap = ();
	
	private void annotateVariableDecl(VariableDeclaration va, Id id) {
		println("Annotation variableDeclaration <va> with scope.");
		str name = unparse(id);
		symbolMap += (name : identifier(name, id@\loc));
		symbolTableMap += (va@\loc : createSymbolTable(symbolMap, parent));
	}
	
	private void annotateElementWithCurrentScope(Tree element) {
		println("Annotating <element> with current scope");
		symbolTableMap += (element@\loc : createSymbolTable(symbolMap, parent));
	}
	
	top-down-break visit(tree) {
		case varDecl:(VariableDeclaration)`<Id id>` : annotateVariableDecl(varDecl, id);
		case varDecl:(VariableDeclaration)`<Id id> = <Expression _>` : annotateVariableDecl(varDecl, id);
		case (Expression)`<Id id>` : annotateElementWithCurrentScope(id);
		case this:(Expression)`this` : annotateElementWithCurrentScope(this);
		
		//TODO: why don't they make a difference in the js thing between function expressions and decls?
		//If you have a decl it is treated as both.
		case functionDecl:(FunctionDeclaration)`function <Id id> (<{Id ","}* params>) <Block body> <ZeroOrMoreNewLines nl>` : {
			println("Adding func decl <id> to symbolMap.");
			str name = unparse(id);
			symbolMap += (name : identifier(name, id@\loc));
			//TODO: add scope 
			
			//TODO: remove duplication
			for (Id param <- params) {
				str name = unparse(param);
				symbolMap += (name : identifier(name, param@\loc));
			}
					
			println("Recursing into body of functionDecl <id>");
			symbolTableMap += createSymbolTableMap(body, createSymbolTable(symbolMap, parent));
		}
	}
	
	return symbolTableMap;
}

private SymbolTable createSymbolTable(SymbolMap symbolMap, Maybe[SymbolTable] optionalParent) {
	if (just(SymbolTable parent) := optionalParent) {
		return child(symbolMap, parent);
	} else {
		return root(symbolMap);
	}
}