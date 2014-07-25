module staticanalysis::testing::ScopeAnalysisTest

import EcmaScript;
import ParseTree;
import IO;
import Node;

import staticanalysis::DataStructures;
import staticanalysis::ScopeAnalysis;

public test bool testDoublyNested() {
	Tree tree = parse(|project://JavaScript%20cg%20algorithms/src/testing/snippets/doublyNested.js|);	
	SymbolTableMap symbolTableMap = createSymbolTableMap(tree);

	iprintln(symbolTableMap);
	SymbolTable scopeA = symbolTableMap[|project://JavaScript%20cg%20algorithms/src/testing/snippets/doublyNested.js|(35,1,<4,5>,<4,6>)],
				scopeX = symbolTableMap[|project://JavaScript%20cg%20algorithms/src/testing/snippets/doublyNested.js|(4,1,<1,4>,<1,5>)],
				scopeY = symbolTableMap[|project://JavaScript%20cg%20algorithms/src/testing/snippets/doublyNested.js|(27,1,<3,5>,<3,6>)],
				scopeZ = symbolTableMap[|project://JavaScript%20cg%20algorithms/src/testing/snippets/doublyNested.js|(60,1,<5,6>,<5,7>)];
		
	assert countSymbolTableDepth(scopeA) == 2;
	assert countSymbolTableDepth(scopeX) == 1;
	assert countSymbolTableDepth(scopeY) == 2;
	assert countSymbolTableDepth(scopeZ) == 3;
	
	assert !isRootSymbolTable(scopeA);
	assert isRootSymbolTable(scopeX);
	assert !isRootSymbolTable(scopeY);
	assert !isRootSymbolTable(scopeZ);
	
	assert isInScope("a", scopeA);
	assert isInScope("x", scopeA);
	assert isInScope("y", scopeA);
	assert !isInScope("z", scopeA);
	
	assert !isInScope("a", scopeX);
	assert isInScope("x", scopeX);
	assert !isInScope("y", scopeX);
	assert !isInScope("z", scopeX);
	
	assert !isInScope("a", scopeY);
	assert isInScope("x", scopeY);
	assert isInScope("y", scopeY);
	assert !isInScope("z", scopeY);
	
	assert isInScope("a", scopeZ);
	assert isInScope("x", scopeZ);
	assert isInScope("y", scopeZ);
	assert isInScope("z", scopeZ);
	
	return true;
}

private int countSymbolTableDepth(child(symbolMap, parent)) = 1 + countSymbolTableDepth(parent);
private int countSymbolTableDepth(root(_)) = 1;

private bool isInScope(str name, SymbolTable symbolTable) = just(_) := find(name, symbolTable);