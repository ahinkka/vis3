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

void createNode(Node node) {
  Entity result = _world.createEntity();
  result.addComponent(new Position(rndVec()));
  result.addComponent(new Velocity(new Vector2(0.0, 0.0)));
  result.addComponent(new Force(new Vector2(0.0, 0.0)));
  result.addComponent(new Weight(1.0));
  result.addComponent(new CNode(node));
  result.addToWorld();
}

void createEdge(Edge edge) {
  Entity result = _world.createEntity();
  result.addComponent(new Position(rndVec()));
  result.addComponent(new Velocity(new Vector2(0.0, 0.0)));
  result.addComponent(new Force(new Vector2(0.0, 0.0)));
  result.addComponent(new Weight(1.0));
  result.addComponent(new CEdge(edge));
  result.addToWorld();
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
  
  /*
  Graph g = new Graph();
  g.nodes.add(foo);
  g.nodes.add(bar);
  g.nodes.add(baz);
  */

  createNode(foo);
  createNode(bar);
  createNode(baz);
  
  createEdge(spam);
  
  _world.addSystem(new MovementSystem());
  _world.addSystem(new ForceSystem());
  _world.addSystem(new ForceMovementSystem());
  
  _world.addSystem(new BackgroundRenderingSystem(canvas));
  _world.addSystem(new NodeRenderingSystem(canvas));
  _world.addSystem(new EdgeRenderingSystem(canvas));
  _world.initialize();
  

  _world.delta = 0;
  gameLoop(0);
}