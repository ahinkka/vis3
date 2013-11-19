library vis3;

import 'dart:math' show Random;
import 'dart:html' show querySelector, window;

import 'package:canvas_query/canvas_query.dart';
import 'package:dartemis/dartemis.dart' show World, Entity;
import 'package:vector_math/vector_math.dart' show Vector2;

import '../lib/entity_system.dart';
import '../lib/graph.dart' show Node, Edge;

Random _rng = new Random(22);

Vector2 rndVec() {
  return new Vector2(_rng.nextDouble(), _rng.nextDouble());
}


DateTime _lastTime = new DateTime.now();
World _world;

void gameLoop(num now) {
  DateTime now = new DateTime.now();
  _world.delta = now.millisecondsSinceEpoch - _lastTime.millisecondsSinceEpoch;
  _lastTime = now;
  
  _world.process();
  
  window.animationFrame.then(gameLoop);
}

void createNode(Node node, Vector2 pos) {
  Entity result = _world.createEntity();
  result.addComponent(new Position(pos));
  result.addComponent(new Velocity(new Vector2(0.0, 0.0)));
  result.addComponent(new Force(new Vector2(0.0, 0.0)));
  result.addComponent(new Weight(1.0));
  result.addComponent(new CNode(node));
  result.addToWorld();
  node.entity = result;
}

void createEdge(Edge edge, Vector2 pos) {
  Entity result = _world.createEntity();
  result.addComponent(new Position(pos));
  result.addComponent(new Velocity(new Vector2(0.0, 0.0)));
  result.addComponent(new Force(new Vector2(0.0, 0.0)));
  result.addComponent(new Weight(1.0));
  result.addComponent(new CEdge(edge));
  result.addToWorld();
  edge.entity = result;
}

void main() {
  var canvas = cq(querySelector("#visCanvas"));  
  _world = new World();

  Node foo = new Node("foo");
  Node bar = new Node("bar");
  Node baz = new Node("baz");

  Edge spam = new Edge(foo, bar, 1.0);
  foo.edges.add(spam);
  bar.edges.add(spam);

  Edge ham = new Edge(bar, baz, 1.0);
  bar.edges.add(ham);
  baz.edges.add(ham);
  
  /*
  Graph g = new Graph();
  g.nodes.add(foo);
  g.nodes.add(bar);
  g.nodes.add(baz);
  */

  createNode(foo, new Vector2(0.0, 0.1));
  createNode(bar, new Vector2(0.0, 0.2));
  createNode(baz, new Vector2(0.0, 0.3));
  
  createEdge(spam, new Vector2(0.0, 0.15));
  createEdge(ham, new Vector2(0.0, 0.25));
  
  _world.addSystem(new MovementSystem());
  _world.addSystem(new RepulsionSystem());
  // _world.addSystem(new SpringSystem());
  _world.addSystem(new ForceMovementSystem());
  
  _world.addSystem(new BackgroundRenderingSystem(canvas));
  _world.addSystem(new NodeRenderingSystem(canvas));
  _world.addSystem(new EdgeRenderingSystem(canvas));
  _world.initialize();
  

  _world.delta = 0;
  gameLoop(0);
}