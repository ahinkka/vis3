part of vis3_entity_system;

class NodeRenderingSystem extends EntityProcessingSystem {
  CanvasQuery canvas;
  
  ComponentMapper<Position> positionMapper;
  ComponentMapper<CNode> nodeMapper;
  
  NodeRenderingSystem(this.canvas) : super(Aspect.getAspectForAllOf([Position, CNode]));
  
  void initialize() {
    positionMapper = new ComponentMapper<Position>(Position, world);
    nodeMapper = new ComponentMapper<CNode>(CNode, world);
  }
  
  void processEntity(Entity entity) {
    Position pos = positionMapper.get(entity);
    CNode cNode = nodeMapper.get(entity);
    Node node = cNode.node;
    
    int width = canvas.canvas.width;
    int height = canvas.canvas.height;
    
    int x = (width * pos.vec.x).toInt();
    int y = (height * pos.vec.y).toInt();
    
    cq(canvas)..fillStyle = '#ff0000'
        ..fillText(node.name, x, y);
  }
}

class EdgeRenderingSystem extends EntityProcessingSystem {
  CanvasQuery canvas;
  
  ComponentMapper<Position> positionMapper;
  ComponentMapper<CEdge> edgeMapper;
  
  EdgeRenderingSystem(this.canvas) : super(Aspect.getAspectForAllOf([Position, CEdge]));

  void initialize() {
    positionMapper = new ComponentMapper<Position>(Position, world);
    edgeMapper = new ComponentMapper<CEdge>(CEdge, world);
  }
  
  void processEntity(Entity entity) {
    Position pos = positionMapper.get(entity);
    CEdge cEdge = edgeMapper.get(entity);
    Edge edge = cEdge.edge;
  }

  /*
  void processEntity(Entity entity) {
    Position pos = positionMapper.get(entity);
    CircularBody body = bodyMapper.get(entity);
    Status status = statusMapper.getSafe(entity);

    context.save();

    try {
      context.lineWidth = 0.5;
      context.fillStyle = body.color;
      context.strokeStyle = body.color;
      if (null != status && status.invisible) {
        if (status.invisiblityTimer % 600 < 300) {
          context.globalAlpha = 0.4;
        }
      }

      drawCirle(pos, body);

      if (pos.x + body.radius > MAXWIDTH) {
        drawCirle(pos, body, offsetX : -MAXWIDTH);
      } else if (pos.x - body.radius < 0) {
        drawCirle(pos, body, offsetX : MAXWIDTH);
      }
      if (pos.y + body.radius > MAXHEIGHT) {
        drawCirle(pos, body, offsetY : -MAXHEIGHT);
      } else if (pos.y - body.radius < 0) {
        drawCirle(pos, body, offsetY : MAXHEIGHT);
      }


      context.stroke();
    } finally {
      context.restore();
    }
  }

  void drawCirle(Position pos, CircularBody body, {int offsetX : 0, int offsetY : 0}) {
    context.beginPath();

    context.arc(pos.x + offsetX, pos.y + offsetY, body.radius, 0, PI * 2, false);

    context.closePath();
    context.fill();
  } */
}


class BackgroundRenderingSystem extends VoidEntitySystem {
  CanvasQuery canvas;
  
  BackgroundRenderingSystem(this.canvas);

  void processSystem() {
    canvas.save();
    try {
      canvas.fillStyle = "white";
      canvas.beginPath();
      canvas.rect(0, 0, canvas.canvas.width, canvas.canvas.height);
      canvas.closePath();
      canvas.fill();
    } finally {
      canvas.restore();
    }
  }
}