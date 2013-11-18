library vis3;

import 'dart:html' show querySelector;
import 'package:game_loop/game_loop_html.dart';
import '../lib/vis_graph.dart';

void main() {
  VNode foo = new VNode("foo");
  VNode bar = new VNode("bar");
  VNode baz = new VNode("baz");
  VEdge spam = new VEdge(foo, bar, 1.0);
  foo.edges.add(spam);
  bar.edges.add(spam);
  
  VGraph g = new VGraph();
  g.nodes.add(foo);
  g.nodes.add(bar);
  g.nodes.add(baz);
  
  var canvas = querySelector("#visCanvas");
  
  print(g);
  
  GameLoopHtml gameLoop = new GameLoopHtml(canvas);
  gameLoop.onUpdate = ((gameLoop) {
    // Update game logic here.
    // print('${gameLoop.frame}: ${gameLoop.gameTime} [dt = ${gameLoop.dt}].');
    g.update(gameLoop.dt);
  });
  gameLoop.onRender = ((gameLoop) {
    // Draw game into canvasElement using WebGL or CanvasRenderingContext here.
    // The interpolation factor can be used to draw correct inter-frame
    // print('Interpolation factor: ${gameLoop.renderInterpolationFactor}');
    g.draw(canvas);
  });
  gameLoop.start();
}