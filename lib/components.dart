part of vis3_entity_system;

class LayoutOptions extends ComponentPoolable {
  Vector2 pos;
  Rectangle bounds;
  bool highlight = false;

  LayoutOptions._();
  factory LayoutOptions(Vector2 position) {
    LayoutOptions result = new Poolable.of(LayoutOptions, _constructor);
    result.pos = position;
    result.bounds = new Rectangle(0, 0, 0, 0);
    return result;
  }
  static LayoutOptions _constructor() => new LayoutOptions._();
}


class Velocity extends ComponentPoolable {
  Vector2 vec;

  Velocity._();
  factory Velocity(Vector2 position) {
    Velocity result = new Poolable.of(Velocity, _constructor);
    result.vec = position;
    return result;
  }
  static Velocity _constructor() => new Velocity._();
}


class Force extends ComponentPoolable {
  Vector2 vec;

  Force._();
  factory Force(Vector2 position) {
    Force result = new Poolable.of(Force, _constructor);
    result.vec = position;
    return result;
  }
  static Force _constructor() => new Force._();
}


class Weight extends ComponentPoolable {
  double value;

  Weight._();
  factory Weight(double weight) {
    Weight result = new Poolable.of(Weight, _constructor);
    result.value = weight;
    return result;
  }
  static Weight _constructor() => new Weight._();
}
