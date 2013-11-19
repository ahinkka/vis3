part of vis3_entity_system;

class MovementSystem extends EntityProcessingSystem {
  ComponentMapper<Position> positionMapper;
  ComponentMapper<Velocity> velocityMapper;

  MovementSystem() : super(Aspect.getAspectForAllOf([Position, Velocity]));

  void initialize() {
    positionMapper = new ComponentMapper<Position>(Position, world);
    velocityMapper = new ComponentMapper<Velocity>(Velocity, world);
  }

  void processEntity(Entity entity) {
    Position position = positionMapper.get(entity);
    Velocity vel = velocityMapper.get(entity);
    
    if (vel.vec.length < 0.000025) {
      return;
    }
    
    position.vec.add(vel.vec * this.world.delta.toDouble());
  }
}


class RepulsionSystem extends EntityProcessingSystem {
  ComponentMapper<Position> positionMapper;
  ComponentMapper<Weight> weightMapper;
  ComponentMapper<Force> forceMapper;
  
  RepulsionSystem() : super(Aspect.getAspectForAllOf([Position, Weight, Force]));

  void initialize() {
    positionMapper = new ComponentMapper<Position>(Position, world);
    weightMapper = new ComponentMapper<Weight>(Weight, world);
    forceMapper = new ComponentMapper<Force>(Force, world);
  }
  
  void processEntities(ReadOnlyBag<Entity> entities) {
    for (int i=0; i<entities.size; i++) {
      Entity e1 = entities[i];
      
      for (int j=0; j<entities.size; j++) {
        if (i == j) {
          continue;
        }
        
        Entity e2 = entities[j];
        
        Vector2 pos1 = positionMapper.get(e1).vec;
        Vector2 pos2 = positionMapper.get(e2).vec;
        double w1 = weightMapper.get(e1).value;
        double w2 = weightMapper.get(e2).value;
        
        forceMapper.get(e1).vec = _force(pos1, w1, pos2, w2);
      }
    }
  }
  
  Vector2 _force(Vector2 pos1, double w1, Vector2 pos2, double w2) {
    Vector2 distance = pos1 - pos2;
    double magnitude = w1 * w2 / distance.length2;
    return distance.normalize() * magnitude;
  }
  
  void processEntity(Entity entity) {
    // NOP
  }
}


class SpringSystem extends EntityProcessingSystem {
  ComponentMapper<Position> positionMapper;
  ComponentMapper<Force> forceMapper;
  ComponentMapper<CEdge> edgeMapper;
  
  double _k = 0.5;
  double _len = 15.0;
  
  SpringSystem() : super(Aspect.getAspectForAllOf([Position, Force, CEdge]));

  void initialize() {
    positionMapper = new ComponentMapper<Position>(Position, world);
    forceMapper = new ComponentMapper<Force>(Force, world);
    edgeMapper = new ComponentMapper<CEdge>(CEdge, world);
  }
  
  void processEntities(ReadOnlyBag<Entity> entities) {
    for (int i=0; i<entities.size; i++) {
      Entity e = entities[i];
      Edge edge = edgeMapper.get(e).edge;
      
      Entity from = edge.from.entity;
      Entity to = edge.to.entity;

      Vector2 ePos = positionMapper.get(e).vec;
      Vector2 n1Pos = positionMapper.get(from).vec;
      Vector2 n2Pos = positionMapper.get(to).vec;
      
      forceMapper.get(from).vec.add(_force(n1Pos, ePos));
      forceMapper.get(e).vec.add(_force(ePos, n1Pos));
      
      forceMapper.get(to).vec.add(_force(n2Pos, ePos));
      forceMapper.get(e).vec.add(_force(ePos, n2Pos));
    }
  }
  
  Vector2 _force(pos1, pos2) {
    Vector2 path = pos2 - pos1;
    double distance = path.length;

    if (distance < 0.1) {
      distance = 0.1;
    }

    double dk = (distance - _len);
    double scale = (-dk * _k) / distance;
    
    return path.scaled(scale);
  }
  
  void processEntity(Entity entity) {
    // NOP
  }
}


class ForceMovementSystem extends EntityProcessingSystem {
  ComponentMapper<Force> forceMapper;
  ComponentMapper<Velocity> velocityMapper;

  ForceMovementSystem() : super(Aspect.getAspectForAllOf([Force, Velocity]));

  void initialize() {
    forceMapper = new ComponentMapper<Force>(Force, world);
    velocityMapper = new ComponentMapper<Velocity>(Velocity, world);
  }

  void processEntity(Entity entity) {
    Force force = forceMapper.get(entity);
    Velocity vel = velocityMapper.get(entity);
    
    // vel.vec.scale(0.1);
    vel.vec = force.vec * ((this.world.delta.toDouble() / 1000) / 10000);
  }
}