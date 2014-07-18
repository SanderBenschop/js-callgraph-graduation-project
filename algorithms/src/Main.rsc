module Main

import analysis::graphs::Graph;

import DataStructures;
import GraphBuilder;

//TODO: factor out andRemoveTreeAnnotations as we always want to do this.
public Graph[Vertex] createIntraProceduralFlowGraph(source) = newGraph(source, [withIntraproceduralFlow]);
public Graph[Vertex] createIntraProceduralFlowGraphNF(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow]);
public Graph[Vertex] createPessimisticFlowGraph(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withPessimisticInterproceduralFlow, andRemoveTreeAnnotations]);
public Graph[Vertex] createPessimisticFlowGraphWithoutNatives(source) = newGraph(source, [withIntraproceduralFlow, withPessimisticInterproceduralFlow, andRemoveTreeAnnotations]);
public Graph[Vertex] createPessimisticFlowGraphTC(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withPessimisticInterproceduralFlow, withOptimisticTransitiveClosure, andRemoveTreeAnnotations]);
public tuple[Graph[Vertex] calls, set[Vertex] escaping, set[Vertex] unresolved] createPessimisticCallGraph(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withPessimisticInterproceduralFlow, withOptimisticTransitiveClosure], andExtractPessimisticCallGraph);
public tuple[Graph[Vertex] calls, set[Vertex] escaping, set[Vertex] unresolved] createCleanPessimisticCallGraph(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withPessimisticInterproceduralFlow, withOptimisticTransitiveClosure, andRemoveTreeAnnotations], andExtractPessimisticCallGraph);
public tuple[Graph[Vertex] calls, set[Vertex] escaping, set[Vertex] unresolved] createCleanPessimisticCallGraphWithoutTC(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withPessimisticInterproceduralFlow, andRemoveTreeAnnotations], andExtractPessimisticCallGraph);

public Graph[Vertex] createCommonFlowGraph(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withCommonInterproceduralFlow]);
public Graph[Vertex] createCommonFlowGraphWithoutNatives(source) = newGraph(source, [withIntraproceduralFlow, withCommonInterproceduralFlow, andRemoveTreeAnnotations]);

public Graph[Vertex] createOptimisticFlowGraph(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withOptimisticInterproceduralFlow]);
public Graph[Vertex] createOptimisticFlowGraphWithoutNatives(source) = newGraph(source, [withIntraproceduralFlow, withOptimisticInterproceduralFlow]);

public Graph[Vertex] createOptimisticFlowGraphTC(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withOptimisticInterproceduralFlow, withOptimisticTransitiveClosure]);
public Graph[Vertex] createOptimisticCallGraph(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withOptimisticInterproceduralFlow, withOptimisticTransitiveClosure, andExtractOptimisticCallGraph]);
public Graph[Vertex] createCleanOptimisticCallGraph(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withOptimisticInterproceduralFlow, withOptimisticTransitiveClosure, andExtractOptimisticCallGraph, andRemoveTreeAnnotations]);
public Graph[Vertex] createCleanOptimisticCallGraphWithoutTC(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withOptimisticInterproceduralFlow, andExtractOptimisticCallGraph, andRemoveTreeAnnotations]);