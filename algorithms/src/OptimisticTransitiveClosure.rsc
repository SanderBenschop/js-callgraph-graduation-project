module OptimisticTransitiveClosure

import analysis::graphs::Graph;
import IO;

import DataStructures;

//Paths through Unknown nodes are not considered.
public Graph[Vertex] getOptimisticTransitiveClosure(Graph graph) {
    Graph[Vertex] unknownNodes = {tup | tuple[Vertex from, Vertex to] tup <- graph, isUnknown(tup.from) || isUnknown(tup.to) };
    Graph[Vertex] knownNodes = graph - unknownNodes;
   	Graph[Vertex] knownTransitiveClosure = knownNodes+;
    return knownTransitiveClosure + unknownNodes;
}

private bool isUnknown(Vertex vertex) = vertex := Unknown();