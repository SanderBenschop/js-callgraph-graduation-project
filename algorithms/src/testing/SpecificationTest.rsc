module testing::SpecificationTest

import analysis::graphs::Graph;
import util::Math;
import List;

import DataStructures;

private list[str] letters = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"];

public tuple[str, Graph[Vertex]] getRandomProgram() {

}

public str generateRandomContent() {
	switch(arbInt(2)) {
		case 0: return arbVariableDeclaration();
		case 1: return arbFunctionDeclaration();
	}
}

public str arbVariableDeclaration() {
	str name = arbIdentifier();
	str val = arbExpression();
	str variableDecl = "var <name> = <val>";
	return arbReal() > 0.5 ? variableDecl + ";": variableDecl;
}

public str arbExpression() {
	if (arbReal() > 0.3) {
		return "<arbInt()>";
	}

	switch(arbInt(4)) {
		case 0: return "<arbInt()> + <arbExpression()>";
		case 1: return "<arbInt()> - <arbExpression()>";
		case 2: return "<arbInt()> * <arbExpression()>";
		case 3: return "<arbInt()> / <arbExpression()>";
	}
}

public str arbFunctionDeclaration() {
	str name = arbIdentifier();
	str params = arbParams();
	str content = arbReal() > 0.3 ? generateRandomContent() : "";
	return "
	function <name>(<params>) {
		<content>
	}
	";
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