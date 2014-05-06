module ScopeAnalysis

import ParseTree;
import util::Maybe;

import DataStructures;
import EcmaScript;
import IO;
import String;

/*
	TODO: make function declaration order unimportant.
	This will print "Hello World":
	
	y();
	function y() {
	    console.log("Hello World");
	}
	
	But this won't:
	y();
	y = function() {
	    console.log("Hello World");
	}
*/

//TODO: Rewrite to fold
public SymbolTableMap createSymbolTableMap(list[Tree] trees) {
	SymbolTableMap mergedMap = ();
	for (Tree tree <- trees) {
		mergedMap += createSymbolTableMap(tree);
	}
	return mergedMap;
}
public SymbolTableMap createSymbolTableMap(Tree tree) {
	return createSymbolTableMap(tree, nothing());
}

private SymbolTableMap createSymbolTableMap(tree, SymbolTable parent) = createSymbolTableMap(tree, just(parent));
private SymbolTableMap createSymbolTableMap(Tree tree, Maybe[SymbolTable] parent) {
	println("Creating symbol table map");
	SymbolTableMap symbolTableMap = ();
	
	println("Creating symbol map");
	SymbolMap symbolMap = ();
	
	private void annotateVariableDecl(id, expression) {
		annotateVariableDecl(id);
		doVisit(expression);
	}
	
	private void annotateVariableDecl(id) {
		str name = unparse(id);
		symbolMap += (name : declaration(id@\loc));
		symbolTableMap += (id@\loc : createSymbolTable(symbolMap, parent));
	}
	
	private void annotateVariableDeclarations(variableDeclarations) {
		for (element <- variableDeclarations) {
			if ((VariableDeclaration)`<Id id>` := element) {
				annotateVariableDecl(id);
			} else if ((VariableDeclaration)`<Id id> = <Expression expression>` := element) {
				annotateVariableDecl(id, expression);
			}
		}
	}
	
	private void annotateVariableDeclarationsNoIn(variableDeclarationsNoIn) {
		for (element <- variableDeclarationsNoIn) {
			if ((VariableDeclarationNoIn)`<Id id>` := element) {
				annotateVariableDecl(id);
			} else if ((VariableDeclarationNoIn)`<Id id> = <Expression expression>` := element) {
				annotateVariableDecl(id, expression);
			}
		}
	}
	
	private void annotateElementWithCurrentScope(Tree element) = annotateElementWithCurrentScope(element@\loc);
	
	private void annotateElementWithCurrentScope(loc elementLoc) {
		println("Annotating element at loc <elementLoc> with current scope");
		symbolTableMap += (elementLoc : createSymbolTable(symbolMap, parent));
	}

	private void annotateFunction(str optId, loc functionLoc, params, body) {		
		if (!isEmpty(optId)) {
			println("Adding function <optId> to symbolMap.");
			symbolMap += (optId : declaration(functionLoc));
		}
		
		SymbolMap oldSymbolMap = symbolMap;
		int i = 1;
		for (Id param <- params) {
			str name = unparse(param);
			symbolMap += (name : parameter(functionLoc, i));
			i += 1;
		}
		
		symbolMap += ("this" : parameter(functionLoc, 0));
		
		println("Recursing into body of function");
		symbolTableMap += createSymbolTableMap(body, createSymbolTable(symbolMap, parent));
		println("Finished recursing into function body, restoring symbol map.");
		symbolMap = oldSymbolMap;
		
		//Add the scope to the function so the algorithm can see if a function is in global scope or not.
		annotateElementWithCurrentScope(functionLoc);
	}
	
	private void doVisit(visitTree) {
		top-down-break visit(visitTree) {
			
			case varDeclNoSemi: (Statement)`var <{VariableDeclaration ","}+ declarations>` : annotateVariableDeclarations(declarations);
			case varDeclSemi: (Statement)`var <{VariableDeclaration ","}+ declarations>;` : annotateVariableDeclarations(declarations);
			
			case forDoDeclarations:(Statement)`for ( var <{VariableDeclarationNoIn ","}+ declarations> ; <{Expression ","}* conditions> ; <{Expression ","}* loopOperations> ) <Statement statements>` : {
				annotateVariableDeclarationsNoIn(declarations);
				doVisit(conditions);
				doVisit(loopOperations);
				doVisit(statements);
			}
			case forInDeclaration:(Statement)`for ( var <Id id> in <Expression expression> ) <Statement statements>` : {
				annotateVariableDecl(id);
				doVisit(expression);
				doVisit(statements);
			}
			
			//TODO: if they aren't declarations with a var statement, still they need the scope map.
			
			case (Expression)`<Id id>` : annotateElementWithCurrentScope(id);
			case this:(Expression)`this` : annotateElementWithCurrentScope(this);
			
			case varDecl:(VariableDeclaration)`<Id id>` : annotateElementWithCurrentScope(id);
			case varDecl:(VariableDeclarationNoIn)`<Id id>` : annotateElementWithCurrentScope(id);
			case varDecl:(VariableDeclaration)`<Id id> = <Expression expression>` : {
				annotateElementWithCurrentScope(id);
				doVisit(expression);
			}
			case varDecl:(VariableDeclarationNoIn)`<Id id> = <Expression expression>` : {
				annotateElementWithCurrentScope(id);
				doVisit(expression);
			}
			
			case func:(FunctionDeclaration)`function <Id id> (<{Id ","}* params>) <Block body> <ZeroOrMoreNewLines _>` : annotateFunction(unparse(id), func@\loc, params, body); 
			case func:(Expression)`function <Id id> (<{Id ","}* params>) <Block body>`: annotateFunction(unparse(id), func@\loc, params, body);
			case func:(Expression)`function (<{Id ","}* params>) <Block body>`: annotateFunction("", func@\loc, params, body);
		}
	}
	
	doVisit(tree);

	return symbolTableMap;
}

private SymbolTable createSymbolTable(SymbolMap symbolMap, Maybe[SymbolTable] optionalParent) {
	if (just(SymbolTable parent) := optionalParent) {
		return child(symbolMap, parent);
	}
	return root(symbolMap);
}