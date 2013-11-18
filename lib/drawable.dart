library vis3_drawable;

import 'dart:html' show CanvasElement;

abstract class Drawable {
  void draw(CanvasElement canvas);
}