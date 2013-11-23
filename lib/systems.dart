part of vis3_entity_system;

class MovementSystem extends EntityProcessingSystem {
  ComponentMapper<LayoutOptions> layoutMapper;
  ComponentMapper<Velocity> velocityMapper;
  MouseInputSystem mouseInputSystem;
  Entity _dragged = null;

  MovementSystem(this.mouseInputSystem) : super(Aspect.getAspectForAllOf([LayoutOptions, Velocity]));

  void initialize() {
    layoutMapper = new ComponentMapper<LayoutOptions>(LayoutOptions, world);
    velocityMapper = new ComponentMapper<Velocity>(Velocity, world);
  }

  void processEntity(Entity entity) {
    LayoutOptions position = layoutMapper.get(entity);
    Velocity vel = velocityMapper.get(entity);
    
    if (position.highlight) {
      if (mouseInputSystem.down) {
        if (_dragged == null || _dragged == entity) {
          position.pos.x = mouseInputSystem.x;
          position.pos.y = mouseInputSystem.y;          
          _dragged = entity;
        }
      } else {
        _dragged = null;
      }
    } else {
      position.pos.add(vel.vec * this.world.delta.toDouble());
    }
  }
}


class RepulsionSystem extends EntityProcessingSystem {
  ComponentMapper<LayoutOptions> layoutMapper;
  ComponentMapper<Weight> weightMapper;
  ComponentMapper<Force> forceMapper;
  
  double _forceMultiplier = 25.0;
  
  RepulsionSystem() : super(Aspect.getAspectForAllOf([LayoutOptions, Weight, Force]));

  void initialize() {
    layoutMapper = new ComponentMapper<LayoutOptions>(LayoutOptions, world);
    weightMapper = new ComponentMapper<Weight>(Weight, world);
    forceMapper = new ComponentMapper<Force>(Force, world);
  }
  
  void processEntities(ReadOnlyBag<Entity> entities) {
    // First reset all
    for (int i=0; i<entities.size; i++) {
      forceMapper.get(entities[i]).vec.setValues(0.0, 0.0);
    }

    // Start adding forces, one by one, iterating all components
    for (int i=0; i<entities.size; i++) {
      Entity e1 = entities[i];
      
      for (int j=0; j<entities.size; j++) {
        if (i == j) {
          continue;
        }
        
        Entity e2 = entities[j];
        
        Vector2 pos1 = layoutMapper.get(e1).pos;
        Vector2 pos2 = layoutMapper.get(e2).pos;
        double w1 = weightMapper.get(e1).value;
        double w2 = weightMapper.get(e2).value;
        
        Vector2 e1Vec = forceMapper.get(e1).vec;
        Vector2 force = _force(pos1, w1, pos2, w2);
        e1Vec.add(force);
      }
    }
  }
  
  Vector2 _force(Vector2 pos1, double w1, Vector2 pos2, double w2) {
    Vector2 distance = pos1 - pos2;
    double magnitude = w1 * w2 / distance.length2;
    return distance.normalize() * magnitude * _forceMultiplier;
  }

  
  void processEntity(Entity entity) {
    // NOP
  }
}


class SpringSystem extends EntityProcessingSystem {
  ComponentMapper<LayoutOptions> layoutMapper;
  ComponentMapper<Force> forceMapper;
  ComponentMapper<CEdge> edgeMapper;
  
  SpringSystem() : super(Aspect.getAspectForAllOf([LayoutOptions, Force, CEdge]));

  void initialize() {
    layoutMapper = new ComponentMapper<LayoutOptions>(LayoutOptions, world);
    forceMapper = new ComponentMapper<Force>(Force, world);
    edgeMapper = new ComponentMapper<CEdge>(CEdge, world);
  }
  
  void processEntities(ReadOnlyBag<Entity> entities) {
    for (int i=0; i<entities.size; i++) {
      Entity e = entities[i];
      Edge edge = edgeMapper.get(e).edge;
      
      Entity from = edge.from.entity;
      Entity to = edge.to.entity;

      Vector2 ePos = layoutMapper.get(e).pos;
      Vector2 n1Pos = layoutMapper.get(from).pos;
      Vector2 n2Pos = layoutMapper.get(to).pos;
      
      forceMapper.get(from).vec.add(_force(n1Pos, ePos));
      forceMapper.get(e).vec.add(_force(ePos, n1Pos));
      
      forceMapper.get(to).vec.add(_force(n2Pos, ePos));
      forceMapper.get(e).vec.add(_force(ePos, n2Pos));
    }
  }
  
  double _k = 0.01;
  double _len = 75.0;
  
  /**
   * F = –kx
   *  where
   *   the minus sign shows that this force is in the opposite direction of
   *   the force that’s stretching or compressing the spring
   *   
   *   k is called spring constant, which measures how stiff and strong the
   *   spring is
   *   
   *   x is the distance the spring is stretched or compressed away from its
   *   equilibrium or rest position
   */
  Vector2 _force(pos1, pos2) {
    Vector2 direction = pos1 - pos2;
    double distance = direction.length;

    if (distance < _len) {
      return new Vector2(0.0, 0.0);
    }
    
    double deltaLength = distance - _len;
    double scale = deltaLength * _k;

    Vector2 result = direction.normalize().scale(-1.0).scaled(scale);
    return result;
  }
  
  void processEntity(Entity entity) {
    // NOP
  }
}


class ForceMovementSystem extends EntityProcessingSystem {
  ComponentMapper<Force> forceMapper;
  ComponentMapper<Velocity> velocityMapper;
  
  double _minVelocity = 0.015;
  double _maxVelocity = 0.25;

  ForceMovementSystem() : super(Aspect.getAspectForAllOf([Force, Velocity]));

  void initialize() {
    forceMapper = new ComponentMapper<Force>(Force, world);
    velocityMapper = new ComponentMapper<Velocity>(Velocity, world);
  }

  void processEntity(Entity entity) {
    Force force = forceMapper.get(entity);
    Velocity vel = velocityMapper.get(entity);
    
    vel.vec.scale(0.75);
    vel.vec = vel.vec.add(force.vec * this.world.delta.toDouble() / 100.0);
    
    // Upper bound for velocity
    if (vel.vec.length > _maxVelocity) {
      vel.vec.normalize().scale(_maxVelocity);
    } else if (vel.vec.length < _minVelocity) {
      vel.vec.setValues(0.0, 0.0);
    }
  }
}