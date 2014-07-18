module Main

import analysis::graphs::Graph;

import DataStructures;
import GraphBuilder;

public Graph[Vertex] createIntraProceduralFlowGraph(source) = newGraph(source, [withIntraproceduralFlow]);
public Graph[Vertex] createIntraProceduralFlowGraphNF(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow]);
public Graph[Vertex] createPessimisticFlowGraph(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withPessimisticInterproceduralFlow]);
public Graph[Vertex] createPessimisticFlowGraphWithoutNatives(source) = newGraph(source, [withIntraproceduralFlow, withPessimisticInterproceduralFlow]);
public Graph[Vertex] createPessimisticFlowGraphTC(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withPessimisticInterproceduralFlow, withOptimisticTransitiveClosure]);
public tuple[Graph[Vertex] calls, set[Vertex] escaping, set[Vertex] unresolved] createPessimisticCallGraph(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withPessimisticInterproceduralFlow, withOptimisticTransitiveClosure], andExtractPessimisticCallGraph);

public Graph[Vertex] createCommonFlowGraph(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withCommonInterproceduralFlow]);
public Graph[Vertex] createCommonFlowGraphWithoutNatives(source) = newGraph(source, [withIntraproceduralFlow, withCommonInterproceduralFlow]);

public Graph[Vertex] createOptimisticFlowGraph(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withOptimisticInterproceduralFlow]);
public Graph[Vertex] createOptimisticFlowGraphWithoutNatives(source) = newGraph(source, [withIntraproceduralFlow, withOptimisticInterproceduralFlow]);

public Graph[Vertex] createOptimisticFlowGraphTC(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withOptimisticInterproceduralFlow, withOptimisticTransitiveClosure]);
public Graph[Vertex] createOptimisticCallGraph(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withOptimisticInterproceduralFlow, withOptimisticTransitiveClosure, andExtractOptimisticCallGraph]);