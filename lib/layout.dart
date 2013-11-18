library vis3_layout;

import 'dart:math';
import 'package:vector_math/vector_math.dart';

Random _rng = new Random(22);


class Layoutable {
  Vector2 location = new Vector2(_rng.nextDouble(),
      _rng.nextDouble());
  
  Vector2 velocity = new Vector2(0.0, 0.0);
  double weight = 1.0;
  
  Vector2 _force(Layoutable other) {
    Vector2 distance = this.location.clone() - other.location;
    double magnitude = this.weight * other.weight / distance.length2;
    return distance.normalize() * magnitude;
  }
  
  Vector2 updateVelocity(Layoutable other, double deltaSecs) {
    this.velocity + _force(other) * deltaSecs;
  }

  void zero() {
    this.velocity = new Vector2(0.0, 0.0);
    this.location = new Vector2(0.0, 0.0);
  }
}
