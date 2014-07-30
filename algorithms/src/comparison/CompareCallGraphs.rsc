module comparison::CompareCallGraphs

import comparison::StaticDynamicCallGraphComparator;
import IO;
import ValueIO;
import analysis::graphs::Graph;
import staticanalysis::DataStructures;
import dynamicanalysis::DynamicCallGraphReader;

public void showInformation() {
	loc rootFolder = |project://JavaScript%20cg%20algorithms/src/callgraphs|;
	for (loc subFolder <- rootFolder.ls) {
		println("---------------------------------------");
		println("Processing <subFolder.file>");
		try printPessimisticInfo(subFolder);
		catch _: {
			println("Something went wrong during pessimistic analysis.");
		}
		try printOptimisticInfo(subFolder);
		catch _: {
			println("Something went wrong during optimistic analysis.");
		}
		println("---------------------------------------");
		print("\n\n\n\n\n\n\n\n");
	}
}

private void printPessimisticInfo(loc folder) {
	println("Pessimistic analysis");
	loc pessimisticFile = folder + "pessimistic.bin";
	loc dynamicFile = folder + "dynamic.json";
	tuple[Graph[Vertex] calls, set[Vertex] escaping, set[Vertex] unresolved] pessCG = readBinaryValueFile(#tuple[Graph[Vertex], set[Vertex] ,set[Vertex]], pessimisticFile);
	printStatistics(pessCG.calls, dynamicFile);
}

private void printOptimisticInfo(loc folder) {
	println("Optimistic analysis");
	loc optimisticFile = folder + "optimistic.bin";
	loc dynamicFile = folder + "dynamic.json";
	Graph[Vertex] optCG = readBinaryValueFile(#Graph[Vertex], optimisticFile);
	printStatistics(optCG, dynamicFile);
}