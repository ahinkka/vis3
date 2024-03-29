library vis3_graph;

import 'package:dartemis/dartemis.dart' show Entity;


class Node {
  String name;
  List<Edge> edges = new List();
  
  Entity entity;
  
  Node(this.name);

  String toString() {
    return "Node ${this.name} (${edges.length})";
  }
}


class Edge {
  Node from;
  Node to;
  double weight;
  
  Entity entity;
  
  Edge(this.from, this.to, this.weight);
  
  String toString() {
    return "Edge [${this.from} => ${this.to}]";
  }
}


class Graph {
  List<Node> nodes = new List();
  
  Graph();
  
  String toString() {
    return "Graph [${this.hashCode}] (${this.nodes.length})";
  }
}
