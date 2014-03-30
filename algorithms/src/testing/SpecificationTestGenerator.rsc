module testing::SpecificationTestGenerator

import analysis::graphs::Graph;
import util::Math;
import List;
import IO;
import String;

import DataStructures;

private list[str] letters = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"];

public tuple[str, Graph[Expectation]] arbProgram() {
	switch(arbInt(1)) {
		case 0: return arbVariableDeclaration();
		//case 1: return arbFunctionDeclaration(); TODO: readd
	}
}

public tuple[str, Graph[Expectation]] arbVariableDeclaration() {
	str name = arbIdentifier();
	str val = arbExpression();
	str variableDecl = "var <name> = <val>";
	str source = arbReal() > 0.5 ? variableDecl + ";": variableDecl;
	
	Graph[Expectation] expectations = {
		<expectation(expression(), val), expectation(property(), name)>,
		<expectation(expression(), val), expectation(expression(), "<name> = <val>")>
	};
	
	return <source, expectations>;
}

public str arbExpression() {
	if (arbReal() > 0.3) {
		return "<arbInt()>";
	}

	switch(arbInt(4)) {
		case 0: return "<arbExpression()> + <arbExpression()>";
		case 1: return "<arbExpression()> - <arbExpression()>";
		case 2: return "<arbExpression()> * <arbExpression()>";
		case 3: return "<arbExpression()> / <arbExpression()>";
	}
}

public tuple[str, Graph[Expectation]] arbFunctionDeclaration() {
	str name = arbIdentifier();
	str params = arbParams();
	tuple[str source, Graph[Expectation] expectation] content = arbReal() > 0.3 ? generateRandomContent() : <"", {}>;
	
	str completeFunction = "function <name>(<params>) {
		<content.source>
	}";
	
	Graph[Expectation] expectations = {
		<expectation(function(), completeFunction), expectation(variable(), completeFunction)>
	};
	
	return <completeFunction, expectations + content.expectation>;
}

public str arbParams() {
	int numberOfParams = arbInt(5);
	list[str] params = [arbIdentifier() | int n <- [0..numberOfParams], n < numberOfParams];
	return isEmpty(params) ? "" : (params[0] | it + ", " + param| str param <- tail(params)); 
}

public str arbIdentifier() {
	str identifier = "";
	int identifierLength = 1 + arbInt(14);
	for (int i <- [0..identifierLength]) {
		identifier += getOneFrom(letters);
	}
	return identifier;
}

data ExpectationType 
	= expression()
	| variable()
	| property()
	| function()
	;
	
data Expectation = expectation(ExpectationType expectationType, str content);