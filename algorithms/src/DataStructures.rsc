module DataStructures

//Graph is represented as an adjacency set in original paper.
//I could just use a relation here, which also makes it easy to compute the transitive closure.
//But it make make it very slow.

//When flows through UNKNOWN are to be ignored, these should be filtered and THEN the transitive closure can be calculated.

import util::Maybe;

data Vertex
	//Intraprocedural flow
	= Expression(loc position)
	| Variable(str name, loc position)
	| Property(str name)
	| Function(loc position)
	//Interprocedural flow
	| Callee(loc position)
	| Argument(loc position, int index)
	| Parameter(loc position, int index)
	| Return(loc position)
	| Result(loc position)
	//Unknown vertex represents interprocedural flow not modelled in the pessimistic algorithm.
	| Unknown()
	//Native vertex represents a native JavaScript function
	| Builtin(str name)
	;

alias SymbolTableMap = map[loc, SymbolTable];

data SymbolTable 
	= root(SymbolMap symbolMap)
	| child(SymbolMap symbolMap, SymbolTable parent)
	;

alias SymbolMap = map[str, Identifier];

data Identifier 
	= declaration(loc location) 
	| parameter(loc enclosingFunctionLocation, int index)
	;

public Maybe[Identifier] find(str name, child(map[str, Identifier] symbolMap, SymbolTable parent)) {
	if (name in symbolMap) {
		return just(symbolMap[name]);
	} else {
		return find(name, parent);
	}
}

public Maybe[Identifier] find(str name, root(map[str, Identifier] symbolMap)) {
	if (name in symbolMap) {
		return just(symbolMap[name]);
	} else {
		return nothing();
	}
}

public bool isRootSymbolTable(root(_)) = true;
public default bool isRootSymbolTable(SymbolTable _) = false;