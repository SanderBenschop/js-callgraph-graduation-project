module Main

import analysis::graphs::Graph;

import DataStructures;
import GraphBuilder;

private set[str] noFilter = {};

//Intraprocedural flow
public Graph[Vertex] createIntraProceduralFlowGraph(source) = newGraph(source, noFilter, [withIntraproceduralFlow]);
public Graph[Vertex] createIntraProceduralFlowGraphWithNatives(source) = newGraph(source, noFilter, [withNativeFlow, withIntraproceduralFlow]);

//Interprocedural flow
public Graph[Vertex] createCommonFlowGraph(source) = newGraph(source, noFilter, [withIntraproceduralFlow, withCommonInterproceduralFlow, andRemoveTreeAnnotations]);

public Graph[Vertex] createPessimisticFlowGraph(source) = newGraph(source, noFilter, [withNativeFlow, withIntraproceduralFlow, withPessimisticInterproceduralFlow]);
public Graph[Vertex] createPessimisticFlowGraphTC(source) = newGraph(source, noFilter, [withNativeFlow, withIntraproceduralFlow, withPessimisticInterproceduralFlow, withOptimisticTransitiveClosure]);

public Graph[Vertex] createOptimisticFlowGraph(source) = newGraph(source, noFilter, [withNativeFlow, withIntraproceduralFlow, withOptimisticInterproceduralFlow]);
public Graph[Vertex] createOptimisticFlowGraphTC(source) = newGraph(source, noFilter, [withNativeFlow, withIntraproceduralFlow, withOptimisticInterproceduralFlow, withOptimisticTransitiveClosure]);

//Call graphs
public tuple[Graph[Vertex] calls, set[Vertex] escaping, set[Vertex] unresolved] createPessimisticCallGraph(source) = createPessimisticCallGraph(source, noFilter);
public tuple[Graph[Vertex] calls, set[Vertex] escaping, set[Vertex] unresolved] createPessimisticCallGraph(source, frameworkPatterns) = newGraph(source, frameworkPatterns, [withNativeFlow, withIntraproceduralFlow, withPessimisticInterproceduralFlow, withOptimisticTransitiveClosure, andRemoveTreeAnnotations], andExtractPessimisticCallGraph);

public Graph[Vertex] createOptimisticCallGraph(source) = createOptimisticCallGraph(source, noFilter);
public Graph[Vertex] createOptimisticCallGraph(source, set[str] frameworkPatterns) = newGraph(source, frameworkPatterns, [withNativeFlow, withIntraproceduralFlow, withOptimisticInterproceduralFlow, withOptimisticTransitiveClosure, andExtractOptimisticCallGraph, andRemoveTreeAnnotations]);