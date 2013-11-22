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
    canvas..fillStyle = '#d3f7a9'
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

    double centerX = canvas.canvas.width / 2;
    double centerY = canvas.canvas.height / 2;
    
    _renderBezierVector(pos.vec + new Vector2(centerX, centerY),
        n1Pos + new Vector2(centerX, centerY),
        n2Pos + new Vector2(centerX, centerY));
  }
  
  _renderLine(Vector2 center, Vector2 from, Vector2 to) {
    canvas.save();
    
    canvas
      ..fillStyle = '#000000'
      ..beginPath()
      ..moveTo(from.x, from.y)
      ..lineTo(center.x, center.y)
      ..lineTo(to.x, to.y)
      ..closePath()
      ..stroke();
    
    canvas.restore();
  }
  
  Vector2 _normal(Vector2 vec) {
    return new Vector2(-vec.y, vec.x);
  }
  
  _renderBezierVector(Vector2 center, Vector2 from, Vector2 to) {
    double px = 2 * (center.x - 0.25 * from.x - 0.25 * to.x);
    double py = 2 * (center.y - 0.25 * from.y - 0.25 * to.y);

    Vector2 endNormal = _normal(to.scaled(1 / to.length));
    Vector2 endLeft = to -  endNormal.scaled(3.0);
    Vector2 endRight = to + endNormal.scaled(3.0);
    
    canvas.save();
    
    CanvasGradient gradient = canvas.createLinearGradient(from.x, from.y, to.x, to.y);
    gradient.addColorStop(0, '#ccc');
    gradient.addColorStop(1, '#000');
    
    canvas
      ..fillStyle = gradient
      ..beginPath()
      ..moveTo(from.x, from.y)
      ..bezierCurveTo(px, py, endLeft.x, endLeft.y, endLeft.x, endLeft.y)
      ..lineTo(endRight.x, endRight.y)
      ..bezierCurveTo(px, py, from.x, from.y, from.x, from.y)
      ..closePath()
      ..fill();
    canvas.restore();
  }
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