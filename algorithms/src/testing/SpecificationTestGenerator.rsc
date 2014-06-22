module testing::SpecificationTestGenerator

import analysis::graphs::Graph;
import util::Math;
import List;
import IO;
import String;
import Boolean;

import DataStructures;
import util::Benchmark;

private int MAX_INTEGER = 2147483647;

public tuple[str, Graph[Expectation]] arbProgram() = arbProgram(false);
public tuple[str, Graph[Expectation]] arbProgram(bool isNested) = arbProgram(isNested, 1 + arbInt(5));
public tuple[str, Graph[Expectation]] arbProgram(bool isNested, int length) {
	str code = "";
	Graph[Expectation] expectations = {};
	
	for (_ <- [0..length]) {
		switch(arbInt(2)) {
			case 0: {
				tuple[str code, Graph[Expectation] expectations] generated = arbVariableDeclaration(isNested);
				code += generated.code;
				expectations += generated.expectations;
			}
			case 1: {
				tuple[str code, Graph[Expectation] expectations] generated = arbFunctionDeclaration(isNested);
				code += generated.code;
				expectations += generated.expectations;
			}
		}
	}
	return <code, expectations>;
}

public tuple[str, Graph[Expectation]] arbVariableDeclaration(bool isNested) {
	str name = arbIdentifier();
	tuple[str code, ExpectationType sourceType, Graph[Expectation] innerExpectations] generatedExpression = arbToplevelExpression(isNested);
	str val = generatedExpression.code;
	str variableDecl = "var <name> = <val>";
	str source = arbReal() > 0.5 ? variableDecl + ";": variableDecl + "
	";
	
	ExpectationType sourceType = generatedExpression.sourceType, targetType = isNested ? variable() : property();
	Graph[Expectation] expectations = {
		<expectation(sourceType, val), expectation(targetType, name)>,
		<expectation(sourceType, val), expectation(expression(), "<name> = <val>")>
	};
	
	return <source, expectations + generatedExpression.innerExpectations>;
}

public tuple[str code, ExpectationType expectationType, Graph[Expectation] innerExpectations] arbToplevelExpression(bool isNested) {
	switch(arbInt(4)) {
		case 0: return arbExpression(isNested);
		case 1: {
			//Or expression, cannot be nested in another expression or it won't reach the entire expression.
			tuple[str code, ExpectationType expectationType, Graph[Expectation] expectations] lhs = arbExpression(isNested);
			tuple[str code, ExpectationType expectationType, Graph[Expectation] expectations] rhs = arbExpression(isNested);
			str source = lhs.code + " " + "||" + " " + rhs.code;
			Graph[Expectation] expectations = {
				<expectation(lhs.expectationType, lhs.code), expectation(expression(), source)>,
				<expectation(rhs.expectationType, rhs.code), expectation(expression(), source)>
			};
			return <source, expression(), expectations + lhs.expectations + rhs.expectations>;
		}
		case 2: {
			//And expression, cannot be nested in another expression or it won't reach the entire expression.
			tuple[str code, ExpectationType expectationType, Graph[Expectation] expectations] lhs = arbExpression(isNested);
			tuple[str code, ExpectationType expectationType, Graph[Expectation] expectations] rhs = arbExpression(isNested);
			str source = lhs.code + " " + "&&" + " " + rhs.code;
			Graph[Expectation] expectations = {
				<expectation(rhs.expectationType, rhs.code), expectation(expression(), source)>
			};
			return <source, expression(), expectations + lhs.expectations + rhs.expectations>;
		}
		case 3: {
			//Ternary expression, cannot be nested in another expression or it won't reach the entire expression.
			tuple[str code, ExpectationType expectationType, Graph[Expectation] expectations] condition = arbExpression(isNested);
			tuple[str code, ExpectationType expectationType, Graph[Expectation] expectations] lhs = arbExpression(isNested);
			tuple[str code, ExpectationType expectationType, Graph[Expectation] expectations] rhs = arbExpression(isNested);
			str source = "<condition.code> ? <lhs.code> : <rhs.code>";
			Graph[Expectation] expectations = {
				<expectation(lhs.expectationType, lhs.code), expectation(expression(), source)>,
				<expectation(rhs.expectationType, rhs.code), expectation(expression(), source)>
			};
			return <source, expression(), expectations + condition.expectations + lhs.expectations + rhs.expectations>;
		}
		//TODO: test nested and/or/ternary.
	}
}

public tuple[str code, ExpectationType expectationType, Graph[Expectation] innerExpectations] arbExpression(bool isNested) {
	if (arbReal() > 0.3) {
		//TODO: remove limit so negative numbers can also occur when filtering bug is fixed.
		return <toString(arbInt(MAX_INTEGER)), expression(), {}>;
	}

	switch(arbInt(3)) {
		case 0: {
			//Binary arithmetic expression.
			tuple[str code, ExpectationType expectationType, Graph[Expectation] expectations] lhs = arbExpression(isNested);
			tuple[str code, ExpectationType expectationType, Graph[Expectation] expectations] rhs = arbExpression(isNested);
			str source = lhs.code + " " + arbBinaryArithmeticOperator() + " " + rhs.code;
			return <source, expression(), lhs.expectations + rhs.expectations>;
		}
		case 1: {
			//Property.
			Graph[Expectation] expectations = {};
			list[str] randomProps = [];
			int numProps = arbInt(4);
			for (_ <- [0..numProps]) {
				str name = arbIdentifier();
				tuple[str code, ExpectationType expectationType, Graph[Expectation] expectations] val = arbExpression(isNested);
				
				expectations += val.expectations;
				expectations += <expectation(val.expectationType, val.code), expectation(property(), name)>;
				randomProps += "<name> : <val.code>";
			}
			str merged = "{" + intercalate(", ", randomProps) + "}";
			return <merged, expression(), expectations>;
		}
		case 2: {
			tuple[str source, Graph[Expectation] expectations] functionExpr = arbFunctionExpression(isNested);
			return <functionExpr.source, expression(), functionExpr.expectations>;
		}
	}
}

public str arbBinaryArithmeticOperator() {
	switch(arbInt(3)) {
		case 0: return "+";
		case 1: return "-";
		case 2: return "*";
		//case 3: return "/"; //TODO: re-add when ambiguity with regex is resolved.
	}
}

public tuple[str, Graph[Expectation]] arbFunctionDeclaration(bool isNested) {
	tuple[str source, Graph[Expectation] expectation] content = arbFunctionContent();
	tuple[str name, str body] generatedFunction = arbFunction(true, content.source);
	
	Graph[Expectation] expectations = {};
	if (isNested) expectations += <expectation(function(), generatedFunction.body), expectation(variable(), generatedFunction.body)>;
	else expectations += <expectation(function(), generatedFunction.body), expectation(property(), generatedFunction.name)>;
	
	return <generatedFunction.body, expectations + content.expectation>;
}

public tuple[str, Graph[Expectation]] arbFunctionExpression(bool isNested) {
	tuple[str source, Graph[Expectation] expectation] content = arbFunctionContent();
	bool hasName = arbReal() > 0.2 ? true : false;
	tuple[str name, str body] generatedFunction = arbFunction(hasName, content.source);
	
	Graph[Expectation] expectations = {
		<expectation(function(), generatedFunction.body), expectation(expression(), generatedFunction.body)>
	};
	
	if (hasName && isNested) {
		expectations += <expectation(function(), generatedFunction.body), expectation(variable(), generatedFunction.body)>;
	} else if (hasName) {
		expectations += <expectation(function(), generatedFunction.body), expectation(property(), generatedFunction.name)>;
	}
	
	expectations += content.expectation;	
	return <generatedFunction.body, expectations>;
}

private tuple[str name, str content] arbFunction(bool hasName, str content) {
	str name = hasName ? arbIdentifier() : "";
	str params = arbParams();
	
	return <name, "
	function <name>(<params>) {
		<content>
	}
	">;
}

public tuple[str, Graph[Expectation]] arbFunctionContent() {
	return arbReal() > 0.8 ? arbProgram(true) : <"", {}>;
}

public str arbParams() {
	int numberOfParams = arbInt(5);
	list[str] params = [arbIdentifier() | int n <- [0..numberOfParams], n < numberOfParams];
	return isEmpty(params) ? "" : (params[0] | it + ", " + param| str param <- tail(params)); 
}

public str arbIdentifier() {
	str identifier = "";
	int identifierLength = 4 + arbInt(20);
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
	
data Expectation = expectation(ExpectationType expectationType, str content, int id);
public Expectation expectation(ExpectationType expectationType, str content) {
	return expectation(expectationType, content, cpuTime());
}

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