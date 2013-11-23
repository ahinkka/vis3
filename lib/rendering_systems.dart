part of vis3_entity_system;

class NodeRenderingSystem extends EntityProcessingSystem {
  CanvasQuery canvas;
  static const num _roundingRatio = 1 / 3.5;
  
  ComponentMapper<LayoutOptions> positionMapper;
  ComponentMapper<CNode> nodeMapper;
  
  NodeRenderingSystem(this.canvas) : super(Aspect.getAspectForAllOf([LayoutOptions, CNode]));
  
  void initialize() {
    positionMapper = new ComponentMapper<LayoutOptions>(LayoutOptions, world);
    nodeMapper = new ComponentMapper<CNode>(CNode, world);
  }
  
  void processEntity(Entity entity) {
    LayoutOptions opts = positionMapper.get(entity);
    CNode cNode = nodeMapper.get(entity);
    Node node = cNode.node;
    
    num centerX = canvas.canvas.width / 2;
    num centerY = canvas.canvas.height /2;
    
    num x = centerX + opts.pos.x;
    num y = centerY + opts.pos.y;

    Rectangle textBounds = _textBounds(node, x, y);
    Rectangle bounds = _bounds(node, x, y);
    
    canvas.save();
    canvas.translate(x, y);
    _renderBackground(bounds, opts.highlight);
    _renderText(node, textBounds);
    canvas.restore();
    
    opts.bounds = new Rectangle(bounds.left + x, bounds.top + y, bounds.width, bounds.height);
  }
  
  void _renderText(Node node, bounds) {
    canvas.save();
    _setNodeTextOptions();
    canvas..fillStyle = '#000000'
        ..fillText(node.name, bounds.left, bounds.top);
    canvas.restore();
  }

  void _renderBackground(Rectangle bounds, highlight) {
    num r = bounds.width * _roundingRatio;
    num left = bounds.left;
    num right = bounds.left + bounds.width;
    num top = bounds.top;
    num bottom = bounds.top + bounds.height;
    
    String fill;    
    if (!highlight) {
      fill = '#d3f7a9';
    } else {
      fill = '#cccccc';
    }
    
    canvas.save();
    canvas..fillStyle = fill
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
  
  Rectangle _textBounds(Node node, num x, num y) {
    canvas.save();
    _setNodeTextOptions();
    Rectangle b = canvas.textBoundaries(node.name);
    canvas.restore();
    
    return new Rectangle(-b.width / 2, -b.height / 2, b.width, b.height);
  }
  
  Rectangle _bounds(Node node, num x, num y) {
    Rectangle b = _textBounds(node, x, y);
    
    num r = b.width * _roundingRatio;
    num left = -b.width / 2 - r;
    num right = b.width / 2 + r;
    num top = -b.height / 2 - r;
    num bottom = b.height / 2 + r;

    return new Rectangle(left, top, b.width + 2 * r, b.height + 2 * r);
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
  
  ComponentMapper<LayoutOptions> positionMapper;
  ComponentMapper<CEdge> edgeMapper;
  
  EdgeRenderingSystem(this.canvas) : super(Aspect.getAspectForAllOf([LayoutOptions, CEdge]));

  void initialize() {
    positionMapper = new ComponentMapper<LayoutOptions>(LayoutOptions, world);
    edgeMapper = new ComponentMapper<CEdge>(CEdge, world);
  }
  
  void processEntity(Entity entity) {
    LayoutOptions pos = positionMapper.get(entity);
    CEdge cEdge = edgeMapper.get(entity);
    Edge edge = cEdge.edge;
    
    Entity from = edge.from.entity;
    Entity to = edge.to.entity;

    Vector2 n1Pos = positionMapper.get(from).pos;
    Vector2 n2Pos = positionMapper.get(to).pos;

    double centerX = canvas.canvas.width / 2;
    double centerY = canvas.canvas.height / 2;
    
    _renderBezierVector(pos.pos + new Vector2(centerX, centerY),
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