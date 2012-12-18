class World extends FWorld {
  
  color backgroundColor;
  Vector<Thing> things;
  PGraphics heatMap;
//  PGraphics heatMapBuffer;
//  PGraphics blackMap;
  //PShader blur;

  World(color backgroundColor) {
    this.backgroundColor = backgroundColor;
    things = new Vector<Thing>();
    
    blur = loadShader("blur.glsl");
    blur.set("blurSize", 9);
    blur.set("sigma", 5.0f);

    heatMap = createGraphics(WINDOW_WIDTH, WINDOW_HEIGHT);
//    heatMapBuffer = createGraphics(WINDOW_WIDTH, WINDOW_HEIGHT);
    heatMap.beginDraw();
    heatMap.colorMode(RGB);
    heatMap.background(0);
    heatMap.endDraw();
  }
  
  void addThing(Thing t) {
    super.add(t);
    things.add(t);
  }
  
  void removeThing(Thing t) {
    super.remove(t);
    things.remove(t);
  }
  
  Vector<Thing> getThingsInArea(float x, float y, float radius) {
    Vector<Thing> inArea = new Vector<Thing>();
    for (Thing t : things) {
      if (circleCollision(x, y, radius, t.x(), t.y(), t.size() * 0.5))
        inArea.add(t);
    }
    return inArea;
  }
  
  void step() {
    Collections.sort(things);
    Collections.reverse(things); // sort from biggest to smallest

    heatMap.beginDraw();
    heatMap.colorMode(RGB);
    heatMap.noStroke();
    
    for (Thing t : things) {
      t.step(this);
      
      int col = t.getColor();
      for (int i=0; i<10; i++) {
        col = color(red(col), green(col), blue(col), i);
        heatMap.fill(col);
        heatMap.ellipse(t.x(), t.y(), t.size()*(10-i), t.size()*(10-i));
      }
      
//      heatMap.fill(col);
//      heatMap.ellipse(t.x(), t.y(), t.size()*10, t.size()*10);
//      heatMapBuffer.beginDraw();
//      heatMapBuffer.colorMode(RGB);
//      heatMapBuffer.background(0);
//      heatMapBuffer.fill(t.getColor());
//      heatMapBuffer.ellipse(t.x(), t.y(), t.size()*2, t.size()*2);
//      heatMapBuffer.endDraw();

//      heatMap.blend(heatMapBuffer, 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, ADD);
    }
    //heatMap.filter(BLUR, 3);
    heatMap.filter(blur);
    
    float HEATMAP_DEC = 0.99f;
    heatMap.loadPixels();
    for (int i=0; i<heatMap.pixels.length; i++) {
      int col = heatMap.pixels[i];
      float r = red(col);
      float g = green(col);
      float b = blue(col);
      r = max(r*HEATMAP_DEC, 0);
      g = max(g*HEATMAP_DEC, 0);
      b = max(b*HEATMAP_DEC, 0);
      heatMap.pixels[i] = color(r, g, b);
    }
    heatMap.updatePixels();
    
    Vector<Thing> splitted = new Vector<Thing>();
    Vector<Thing> dead     = new Vector<Thing>();
    for (Thing t: things) {

      // Clean.
      if (t.isDead()) {
        dead.add(t);
      }
      
      // Split.
      else if (t instanceof Munchkin) {
        Munchkin m = (Munchkin) t;
        if (m.size() <= 0) {
          dead.add(t);
        }
        else if (m.getHeat() >= 0.9f && random(0,1) < 0.05f) {
          splitted.add(m.split());
        }
      }
    }

    for (Thing t: dead)
      remove(t);

    for (Thing t: splitted)
      addThing(t);

    super.step();
    heatMap.endDraw();
  }

  void draw() {
    background(backgroundColor);
    image(heatMap, 0, 0);
    super.draw();
  }
 
  /**
   * Check if two circle collide
   * x_1, y_1, radius_1 defines the first circle
   * x_2, y_2, radius_2 defines the second circle
   * From: http://wiki.processing.org/w/Circle-Circle_intersection
   */
  boolean circleCollision(float x_1, float y_1, float radius_1, float x_2, float y_2, float radius_2)
  {
    return dist(x_1, y_1, x_2, y_2) < radius_1 + radius_2;
  }
}
