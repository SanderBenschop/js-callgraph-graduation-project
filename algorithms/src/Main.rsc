module Main

import analysis::graphs::Graph;

import DataStructures;
import GraphBuilder;

public Graph[Vertex] createIntraProceduralFlowGraph(source) = newGraph(source, [withIntraproceduralFlow]);
public Graph[Vertex] createIntraProceduralFlowGraphNF(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow]);
public Graph[Vertex] createPessimisticFlowGraph(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withPessimisticInterproceduralFlow]);
public Graph[Vertex] createPessimisticFlowGraphTC(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withPessimisticInterproceduralFlow, withOptimisticTransitiveClosure]);
public tuple[Graph[Vertex] calls, set[Vertex] escaping, set[Vertex] unresolved] createPessimisticCallGraph(source) = newGraph(source, [withNativeFlow, withIntraproceduralFlow, withPessimisticInterproceduralFlow, withOptimisticTransitiveClosure], andExtractCallGraph); 