class World extends FWorld {
  
  color backgroundColor;
  Vector<Thing> things;
  PGraphics heatMap;
//  PShader blur;

  Donut donut;

  World(color backgroundColor) {
    this.backgroundColor = backgroundColor;
    things = new Vector<Thing>();
    
    donut = new Donut();
    //blur = loadShader("blur.glsl");
    //blur.set("blurSize", 9);
    //blur.set("sigma", 5.0f);

    heatMap = createGraphics(WINDOW_WIDTH, WINDOW_HEIGHT);
//    heatMap = createGraphics(WINDOW_WIDTH, WINDOW_HEIGHT, P2D);
//    heatMapBuffer = createGraphics(WINDOW_WIDTH, WINDOW_HEIGHT);
    heatMap.beginDraw();
    heatMap.colorMode(GRAY, 1.0f);
    heatMap.noStroke();
    heatMap.background(HEAT_MAP_INITIAL_HEAT);
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
  
  Vector<Thing> getThings() {
    return things;
  }
  
  float getHeatAt(float x, float y) {
    x = constrain(x, 0, WINDOW_WIDTH-1);
    y = constrain(y, 0, WINDOW_HEIGHT-1);
    //println(red(heatMap.pixels[(int)x + ((int)y)*WINDOW_WIDTH]));
    return (float) red(heatMap.pixels[(int)x + ((int)y)*WINDOW_WIDTH]) / 255.0f;
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
    try {
      super.step();
    } catch (ArrayIndexOutOfBoundsException e) {
      println("----------- Thing stopped working -----------");
      println(e);
      e.printStackTrace();
      
      // dump data
      for (Thing t : things) {
        if (Double.isNaN(t.getForceX()) || Double.isNaN(t.getForceY())) {
          println("Bad force");
          t.resetForces();
        }
      }
    }
    
    heatMap.beginDraw();
    Collections.sort(things);
    Collections.reverse(things); // sort from biggest to smallest

    // Add the heat from the donut.
    if (mousePressed) {
      Vector<Thing> affectedThings = getThingsInArea(mouseX, mouseY, donut.size()/2);
      for (Thing t : affectedThings) {
        t.setHeat(t.getHeat() + DONUT_HEAT_INCREASE);
      }
      heatMap.fill(DONUT_HEAT_INCREASE, HEAT_MAP_SPREAD_FACTOR);
      heatMap.ellipse(mouseX, mouseY, donut.size(), donut.size());
      //circleGradient(heatMap, mouseX, mouseY, donut.size(), 0, 1.0f, DONUT_HEAT_INCREASE);
      /*
      heatMap.blendMode(ADD);
      heatMap.fill(1.0f, DONUT_HEAT_INCREASE);
      heatMap.ellipse(mouseX, mouseY, donut.size(), donut.size());
      heatMap.ellipse(mouseX, mouseY, donut.size()/2, donut.size()/2);*/
    }
    
    heatMap.loadPixels();
    
    for (Thing t : things) {
      
      t.step(this);

      final int HEAT_MAP_GRADIENT_STEPS = 10;
      final float HEAT_MAP_GRADIENT_FACTOR = 1.0f / HEAT_MAP_GRADIENT_STEPS;
      float heat      = t.getHeat();
      float heatOnMap = getHeatAt(t.x(), t.y());
      float deltaHeat = (heat - heatOnMap);
      deltaHeat *= (deltaHeat >= 0 ? HEAT_MAP_DISSIPATION_FACTOR : HEAT_MAP_ABSORPTION_FACTOR);
      t.setHeat( t.getHeat() - deltaHeat );
      
      //deltaHeat *= HEAT_MAP_SPREAD_FACTOR;
      int traceSize = (int) ( t.size() * HEAT_TRACE_SIZE_FACTOR );
      if (traceSize > 0) {
        heatMap.fill(t.getHeat(), HEAT_MAP_SPREAD_FACTOR);
        heatMap.ellipse((int)t.x(), (int)t.y(), traceSize, traceSize);
        //circleGradient(heatMap, (int)t.x(), (int)t.y(), traceSize, 0, t.getHeat(), HEAT_MAP_SPREAD_FACTOR);

/*
        PGraphics g = createGraphics(traceSize, traceSize);
        g.beginDraw();
        g.colorMode(GRAY, 1.0f);
        g.background(0);
        g.smooth();
        g.noStroke();
        g.ellipseMode(CENTER);
        
        float i=0;
        for (int s=traceSize; s>=1; s--) {
          g.fill(lerp(0, abs(deltaHeat), s / (float)traceSize));
          g.ellipse(traceSize/2, traceSize/2, s, s);
        }
        
        g.endDraw();
       */
      }
     
//      heatMap.blend(g, 0, 0, g.width, g.height, (int)t.x() - t.size()/2, (int)t.y() - t.size()/2, t.size(), t.size(), (deltaHeat >= 0 ? ADD : SUBTRACT));
      /*for (int i=0; i<HEAT_MAP_GRADIENT_STEPS; i++) {
        heatMap.fill(deltaHeat, HEAT_MAP_GRADIENT_FACTOR);
        heatMap.ellipse(t.x(), t.y(), t.size()*(HEAT_MAP_GRADIENT_STEPS-i), t.size()*(HEAT_MAP_GRADIENT_STEPS-i));
      }*/
    }

    //heatMap.blendMode(REPLACE);
    heatMap.fill(0.0f, HEAT_MAP_DECREASE_FACTOR);
    heatMap.rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
    //heatMap.filter(blur);

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
          Thing s = m.split();
          if (s != null)
            splitted.add(s);
        }
      }
    }

    //for (Thing t: dead)
    //  remove(t);

    for (Thing t: splitted)
      addThing(t);

    // Make sure we respect boundaries.
    for (Thing t: things) {
      t.setPosition( constrain(t.getX(), 5, width-5), constrain(t.getY(), 5, height-5) );
    }
    
    heatMap.endDraw();
  }

  void draw() {
    background(backgroundColor);
    //heatMap.blendMode(BLEND);
    
    //image(heatMap, 0, 0);
    donut.draw();
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
