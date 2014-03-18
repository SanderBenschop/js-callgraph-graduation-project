module testing::snippets::ScopeAnalysisTest

import EcmaScript;
import ParseTree;
import IO;
import Node;

import DataStructures;
import ScopeAnalysis;

public test bool testDoublyNested() {
	Tree tree = parse(|project://JavaScript%20cg%20algorithms/src/testing/snippets/doublyNested.js|);	
	SymbolTableMap symbolTableMap = createSymbolTableMap(tree);

	SymbolTable scopeX = symbolTableMap[|project://JavaScript%20cg%20algorithms/src/testing/snippets/doublyNested.js|(4,1,<1,4>,<1,5>)],
				scopeY = symbolTableMap[|project://JavaScript%20cg%20algorithms/src/testing/snippets/doublyNested.js|(27,1,<3,5>,<3,6>)],
				scopeZ = symbolTableMap[|project://JavaScript%20cg%20algorithms/src/testing/snippets/doublyNested.js|(52,1,<5,6>,<5,7>)];
		
	assert countSymbolTableDepth(scopeX) == 1;
	assert countSymbolTableDepth(scopeY) == 2;
	assert countSymbolTableDepth(scopeZ) == 3;
	
	assert isInScope("x", scopeX);
	assert !isInScope("y", scopeX);
	assert !isInScope("z", scopeX);
	
	assert isInScope("x", scopeY);
	assert isInScope("y", scopeY);
	assert !isInScope("z", scopeY);
	
	assert isInScope("x", scopeZ);
	assert isInScope("y", scopeZ);
	assert isInScope("z", scopeZ);
	
	return true;
}

private int countSymbolTableDepth(child(symbolMap, parent)) = 1 + countSymbolTableDepth(parent);
private int countSymbolTableDepth(root(_)) = 1;

private bool isInScope(str name, SymbolTable symbolTable) = just(_) := find(name, symbolTable);