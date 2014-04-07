module ScopeAnalysis

import ParseTree;
import util::Maybe;

import DataStructures;
import EcmaScript;
import IO;
import String;

/* TODO: find out if all the implementations in the JS impl are correct and implement myself:
 * CatchClause
 * MemberExpression
 * Property
 * Add THIS references in functions
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
	
	private void annotateVariableDecl(va, id, expression) {
		annotateVariableDecl(va, id);
		doVisit(expression);
	}
	
	private void annotateVariableDecl(va, id) {
		println("Annotation variableDeclaration <va> with scope.");
		str name = unparse(id);
		symbolMap += (name : declaration(id@\loc));
		symbolTableMap += (id@\loc : createSymbolTable(symbolMap, parent));
	}
	
	private void annotateElementWithCurrentScope(Tree element) {
		println("Annotating <element> with current scope");
		symbolTableMap += (element@\loc : createSymbolTable(symbolMap, parent));
	}
	

	private void annotateFunction(str optId, loc optIdLoc, loc functionLoc, params, body) {
		if (!isEmpty(optId)) {
			println("Adding function <optId> to symbolMap.");
			symbolMap += (optId : declaration(optIdLoc));
		}
		
		//Add 'this' to scope.
		symbolMap += ("this" : parameter(functionLoc, 0));

		int i = 1;
		for (Id param <- params) {
			str name = unparse(param);
			symbolMap += (name : parameter(functionLoc, i));
			i += 1;
		}
				
		println("Recursing into body of function");
		symbolTableMap += createSymbolTableMap(body, createSymbolTable(symbolMap, parent));
	}
	
	private void doVisit(visitTree) {
		top-down-break visit(visitTree) {
			case varDecl:(VariableDeclaration)`<Id id>` : annotateVariableDecl(varDecl, id);
			case varDecl:(VariableDeclaration)`<Id id> = <Expression expression>` : annotateVariableDecl(varDecl, id, expression);
			case varDecl:(VariableDeclarationNoIn)`<Id id>` : annotateVariableDecl(varDecl, id);
			case varDecl:(VariableDeclarationNoIn)`<Id id> = <Expression expression>` : annotateVariableDecl(varDecl, id, expression);

			case (Expression)`<Id id>` : annotateElementWithCurrentScope(id);
			case this:(Expression)`this` : annotateElementWithCurrentScope(this);

			case func:(FunctionDeclaration)`function <Id id> (<{Id ","}* params>) <Block body> <ZeroOrMoreNewLines _>` : annotateFunction(unparse(id), id@\loc, func@\loc, params, body); 
			case func:(Expression)`function <Id id> (<{Id ","}* params>) <Block body>`: annotateFunction(unparse(id), id@\loc, func@\loc, params, body);
			case func:(Expression)`function (<{Id ","}* params>) <Block body>`: annotateFunction("", |nothing:///|, func@\loc, params, body);
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