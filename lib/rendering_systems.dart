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
    
    int centerX = canvas.canvas.width ~/ 2;
    int centerY = canvas.canvas.height ~/2;
    
    int x = centerX + pos.vec.x.toInt();
    int y = centerY + pos.vec.y.toInt();
    
    Rectangle bounds = _bounds(node, x, y);
    _renderBackground(bounds);
    _renderText(node, bounds);
  }
  
  void _renderText(Node node, Rectangle bounds) {
    canvas.save();
    _setNodeTextOptions();
    canvas..fillStyle = '#000000'
        ..fillText(node.name, bounds.left + _padding, bounds.top + _padding);
    canvas.restore();
  }

  int _roundRadius = 15;
  void _renderBackground(Rectangle bounds) {
    int r = _roundRadius;
    int left = bounds.left;
    int right = bounds.left + bounds.width;
    int top = bounds.top;
    int bottom = bounds.top + bounds.height;
    
    canvas.save();
    canvas..fillStyle = '#ff0000'
        ..beginPath()
        ..moveTo(left + r, top)
        ..lineTo(right - r, top)
        ..arcTo(right, top, right, top + r, r)
        ..lineTo(right, bottom - r)
        ..arcTo(right, bottom, right - r, bottom, r)
        ..lineTo(left + r, bottom)
        ..arcTo(left, bottom, left, bottom - r, r)
        ..lineTo(left, top + r)
        ..arcTo(left, top, left + r, top, r)
        ..closePath()
        ..fill();
    canvas.restore();
  }
  
  int _padding = 10;
  Rectangle _bounds(Node node, int x, int y) {
    canvas.save();
    _setNodeTextOptions();
    Rectangle textBounds = canvas.textBoundaries(node.name);
    canvas.restore();
    
    int width = textBounds.width.toInt() + 2 * _padding;
    int height = textBounds.height.toInt() + 2 * _padding;
    
    int left = x - width ~/ 2;
    int top = y - height ~/ 2;
    return new Rectangle(left, top, width, height);
  }
  
  void _setNodeTextOptions() {
    canvas..textBaseline = "top"
        ..lineWidth = 10
        ..strokeStyle = 'black'
        ..font = '16pt Arial';
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
    
    Entity from = edge.from.entity;
    Entity to = edge.to.entity;

    Vector2 n1Pos = positionMapper.get(from).vec;
    Vector2 n2Pos = positionMapper.get(to).vec;

    _renderEdge(pos.vec, n1Pos, n2Pos);
  }
  
  _renderEdge(Vector2 edgeCenter, Vector2 node1Position, Vector2 node2Position) {
    int centerX = canvas.canvas.width ~/ 2;
    int centerY = canvas.canvas.height ~/ 2;
    
    int x = centerX + edgeCenter.x.toInt();
    int y = centerY + edgeCenter.y.toInt();
    
    canvas.save();
    
    canvas
      ..fillStyle = '#000000'
      ..beginPath()
      ..moveTo(centerX + node1Position.x.toInt(), centerY + node1Position.y.toInt())
      ..lineTo(centerX + node2Position.x.toInt(), centerY + node2Position.y.toInt())
      ..closePath()
      ..stroke();
    
    canvas.restore();

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