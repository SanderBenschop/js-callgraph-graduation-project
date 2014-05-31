module CodeStatistics

import EcmaScript;
import ParseTree;
import IO;

public void printCodeStatistics(list[loc] sources) {
	int totalCalls = 0, totalFunctions = 0;
	for (loc source <- sources) {
		tuple[int calls, int functions] sourceInfo = printCodeStatistics(source);
		totalCalls += sourceInfo.calls;
		totalFunctions += sourceInfo.functions;
	}
	println("Total calls: <totalCalls>, total functions: <totalFunctions>");
}

public tuple[int, int] printCodeStatistics(loc source) {
	Tree tree = parse(source);
	println("Analyzing <source>");
	int calls = countCalls(tree), function = countFunctions(tree);
	println("Number of calls: <calls>");
	println("Number of functions: <function>");
	return <calls, function>;
}

public int countCalls(tree) {
	int calls = 0;
	top-down-break visit(tree) {
		case newFunctionCallParams:(Expression)`new <Expression e> ( <{ Expression!comma ","}+ _> )`: calls += 1 + countCalls(e);
		case newFunctionCallNoParams:(Expression)`new <Expression e>()`: calls += 1 + countCalls(e);
		case newNoParams:(Expression)`new <Expression e>`: calls += 1;
		
		case functionCallParams:(Expression)`<Expression e> ( <{ Expression!comma ","}+ _> )`: calls += 1 + countCalls(e);
		case functionCallNoParams:(Expression)`<Expression e>()`: calls += 1 + countCalls(e);
	}
	return calls;
}

public int countFunctions(tree) {
	int functions = 0;
	visit(tree) {
		case func:(FunctionDeclaration)`function <Id id> (<{Id ","}* params>) <Block body> <ZeroOrMoreNewLines _>` : functions += 1; 
		case func:(Expression)`function <Id id> (<{Id ","}* params>) <Block body>`: functions += 1;
		case func:(Expression)`function (<{Id ","}* params>) <Block body>`: functions += 1;
		
	}
	return functions;
}