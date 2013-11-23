part of vis3_entity_system;


class MouseInputSystem extends EntityProcessingSystem {
  CanvasQuery canvas;
  
  ComponentMapper<LayoutOptions> positionMapper;
  ComponentMapper<CNode> nodeMapper;
  
  bool down = false;
  bool over = false;
  num x = 0;
  num y = 0;
  
  MouseInputSystem(this.canvas) : super(Aspect.getAspectForAllOf([LayoutOptions, CNode]));
  
  void initialize() {
    positionMapper = new ComponentMapper<LayoutOptions>(LayoutOptions, world);
    nodeMapper = new ComponentMapper<CNode>(CNode, world);
    
    canvas.canvas.onMouseDown.listen(handleMouseDown);
    canvas.canvas.onMouseUp.listen(handleMouseUp);
    canvas.canvas.onMouseOver.listen(handleMouseOver);
    canvas.canvas.onMouseOut.listen(handleMouseOut);
    canvas.canvas.onMouseMove.listen(handleMouseMove);
  }
  
  void processEntity(Entity entity) {
    LayoutOptions opts = positionMapper.get(entity);
    CNode node = nodeMapper.get(entity);
    
    Point pointer = new Point(x.toDouble(), y.toDouble());
    print("${opts.bounds}; ${pointer}");
    if (opts.bounds.containsPoint(pointer)) {
      opts.highlight = true;
    } else {
      opts.highlight = false;
    }
  }
  
  void handleMouseDown(MouseEvent event) {
    down = true;
  }
  
  void handleMouseUp(MouseEvent event) {
    down = false;
  }
  
  void handleMouseOver(MouseEvent event) {
    over = true;
  }

  void handleMouseOut(MouseEvent event) {
    over = false;
  }

  void handleMouseMove(MouseEvent event) {
    Rectangle canvasBounds = canvas.canvas.getBoundingClientRect();
    x = event.client.x - canvasBounds.left - canvasBounds.width / 2;
    y = event.client.y - canvasBounds.top - canvasBounds.height / 2;
  }
}