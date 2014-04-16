module Main

import analysis::graphs::Graph;

import DataStructures;
import GraphBuilder;

public Graph[Vertex] createIntraProceduralFlowGraph(source) = newGraph(source, [withIntraproceduralFlow]);
public Graph[Vertex] createIntraProceduralFlowGraphNF(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow]);
public Graph[Vertex] createPessimisticFlowGraph(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withPessimisticInterproceduralFlow]);
public Graph[Vertex] createPessimisticFlowGraphTC(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withPessimisticInterproceduralFlow, withOptimisticTransitiveClosure]);
public tuple[Graph[Vertex] calls, set[Vertex] escaping, set[Vertex] unresolved] createPessimisticCallGraph(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withPessimisticInterproceduralFlow, withOptimisticTransitiveClosure], andExtractPessimisticCallGraph);
public tuple[Graph[Vertex] calls, set[Vertex] escaping, set[Vertex] unresolved] createCleanPessimisticCallGraph(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withPessimisticInterproceduralFlow, withOptimisticTransitiveClosure, andRemoveTreeAnnotations], andExtractPessimisticCallGraph);

public Graph[Vertex] createCommonFlowGraph(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withCommonInterproceduralFlow]);

public Graph[Vertex] createOptimisticFlowGraph(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withOptimisticInterproceduralFlow]);
public Graph[Vertex] createOptimisticCallGraph(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withOptimisticInterproceduralFlow, withOptimisticTransitiveClosure, andExtractOptimisticCallGraph]);
public Graph[Vertex] createCleanOptimisticCallGraph(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withOptimisticInterproceduralFlow, withOptimisticTransitiveClosure, andExtractOptimisticCallGraph, andRemoveTreeAnnotations]);