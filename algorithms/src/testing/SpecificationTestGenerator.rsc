module testing::SpecificationTestGenerator

import analysis::graphs::Graph;
import util::Math;
import List;
import IO;
import String;

import DataStructures;

public tuple[str, Graph[Expectation]] arbProgram() = arbProgram(false);
public tuple[str, Graph[Expectation]] arbProgram(bool isNested) {
	switch(arbInt(2)) {
		case 0: return arbVariableDeclaration(isNested);
		case 1: return arbFunctionDeclaration();
	}
}

public tuple[str, Graph[Expectation]] arbVariableDeclaration(bool isNested) {
	str name = arbIdentifier();
	str val = arbExpression();
	str variableDecl = "var <name> = <val>";
	str source = arbReal() > 0.5 ? variableDecl + ";": variableDecl;
	
	ExpectationType targetType = isNested ? variable() : property();
	Graph[Expectation] expectations = {
		<expectation(expression(), val), expectation(targetType, name)>,
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
	tuple[str source, Graph[Expectation] expectation] content = arbReal() > 0.8 ? arbProgram(true) : <"", {}>;
	
	str completeFunction = "
	function <name>(<params>) {
		<content.source>
	}
	";
	
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
	int identifierLength = 5 + arbInt(20);
	for (int i <- [0..identifierLength]) {
		identifier += getOneFrom(letters);
	}
	//If the generated identifier is a reserved keyword, try again.
	return identifier notin reserved ? identifier : arbIdentifier();
}

data ExpectationType 
	= expression()
	| variable()
	| property()
	| function()
	;
	
data Expectation = expectation(ExpectationType expectationType, str content);

private list[str] letters = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"];

private list[str] reserved = [
    "break",
    "case",
    "catch",
    "continue",
    "debugger",
    "default",
    "delete",
    "do",
    "else",
    "finally",
    "for",
    "function",
    "if",
    "instanceof",
    "in",
    "new",
    "return",
    "switch",
    "this",
    "throw",
    "try",
    "typeof",
    "var",
    "void",
    "while",
    "with",
    "abstract",
    "boolean",
    "byte",
    "char",
    "class",
    "const",
    "double",
    "enum",
    "export",
    "extends",
    "final",
    "float",
    "goto",
    "implements",
    "import",
    "interface",
    "int",
    "long",
    "native",
    "package",
    "private",
    "protected",
    "public",
    "short",
    "static",
    "super",
    "synchronized",
    "throws",
    "transient",
    "volatile",
    "null",
    "true",
    "false"];