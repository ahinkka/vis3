part of vis3_entity_system;


class CNode extends ComponentPoolable {
  Node node;
  
  CNode._();
  factory CNode(Node node) {
    CNode result = new Poolable.of(CNode, _constructor);
    result.node = node;
    return result;
  }
  
  static CNode _constructor() => new CNode._();
}


class CEdge extends ComponentPoolable {
  Edge edge;
  
  CEdge._();
  factory CEdge(Edge edge) {
    CEdge result = new Poolable.of(CEdge, _constructor);
    result.edge = edge;
    return result;
  }
  
  static CEdge _constructor() => new CEdge._();
}


