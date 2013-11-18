library vis3_layoutable_graph;

import 'dart:html' show CanvasElement;
import 'package:canvas_query/canvas_query.dart' show cq, CanvasQuery;
import 'graph.dart' show Node, Edge, Graph;
import 'layout.dart' show Layoutable;
import 'drawable.dart' show Drawable;
import 'updateable.dart' show Updateable;


class VNode extends Node with Layoutable, Drawable {
  VNode(String name) : super(name);

  String toString() {
    return super.toString() + " " + this.location.toString() + "; "
        + this.velocity.toString();
  }

  void draw(CanvasElement canvas) {
    int width = canvas.width;
    int height = canvas.height;
    
    int x = (width * this.location.x).toInt();
    int y = (height * this.location.y).toInt();
    
    cq(canvas)..fillStyle = '#ff0000'
        ..fillText(this.name, x, y);
  }
  
  void update(double deltaSecs) {
    for (var e in this.edges) {
      e.update(deltaSecs);
    }
  }
}


class VEdge extends Edge with Layoutable, Drawable {
  VEdge(VNode from, VNode to, double weight) : super(from, to, weight);

  String toString() {
    return super.toString() + " " + this.location.toString() + "; "
        + this.velocity.toString();
  }

  void draw(CanvasElement canvas) {
    // Vector2 from = this.from.canvasLocation();
    // Vector2 to = this.to.canvasLocation();
  }
  
  void update(double deltaSecs) {
    
  }
}


class VGraph extends Graph with Layoutable, Drawable, Updateable {
  VGraph() : super() {
    this.zero();
  }

  void draw(CanvasElement canvas) {
    int width = canvas.width;
    int height = canvas.height;
    
    int centerX = width ~/ 2;
    int centerY = height ~/ 2;
    
    cq(canvas)..fillStyle = '#ff0000'
        ..wrappedText("Graph center", centerX, centerY, 200);
    
    for (var n in this.nodes) {
      n.draw(canvas);
    }
  }

  void update(double deltaTime) {
    for (var n in this.nodes) {
      n.update(deltaTime);
    }
  }
}