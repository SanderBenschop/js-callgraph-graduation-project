module CodeStatistics

import EcmaScript;
import ParseTree;
import IO;
import utils::FileUtils;

public void printCodeStatistics(list[loc] sources) {
	int totalCalls = 0, totalFunctions = 0, totalSloc = 0;
	for (loc source <- sources) {
		tuple[int calls, int functions, int sloc] sourceInfo = printCodeStatistics(source);
		totalCalls += sourceInfo.calls;
		totalFunctions += sourceInfo.functions;
		totalSloc += sourceInfo.sloc;
	}
	println("Total calls: <totalCalls>, total functions: <totalFunctions>, total sloc: <totalSloc>");
}

public tuple[int, int, int] printCodeStatistics(loc source) {
	Tree tree = parse(source);
	println("Analyzing <source>");
	int calls = countCalls(tree), function = countFunctions(tree), sloc = countSloc(source);
	println("Number of calls: <calls>");
	println("Number of functions: <function>");
	println("SLOC: <sloc>");
	return <calls, function, sloc>;
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