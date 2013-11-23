part of vis3_entity_system;


class MouseInputSystem extends EntityProcessingSystem {
  CanvasQuery canvas;
  
  ComponentMapper<LayoutOptions> positionMapper;
  ComponentMapper<CNode> nodeMapper;
  
  bool down = false;
  bool over = false;
  int x = -1;
  int y = -1;
  
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
    if (opts.bounds.containsPoint(pointer)) {
      opts.highlight = true;
    } else {
      opts.highlight = false;
    }
    // print("Down: ${down}");
    // print("Over: ${over}");
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
    x = event.client.x;
    y = event.client.y;
    
    // print("Mouse pos: (${x}, ${y}");
    /*
    print("Event: ${event}");
    print("Client: ${event.client}");
    print("Type: ${event.type}");
    */    
  }
}