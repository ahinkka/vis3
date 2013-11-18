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


class ForceSystem extends EntityProcessingSystem {
  ComponentMapper<Position> positionMapper;
  ComponentMapper<Weight> weightMapper;
  ComponentMapper<Force> forceMapper;
  
  ForceSystem() : super(Aspect.getAspectForAllOf([Position, Weight, Force]));

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