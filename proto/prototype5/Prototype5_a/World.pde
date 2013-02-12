class World extends FWorld {
  
  color backgroundColor;
  Vector<Thing> things;
  PGraphics heatMap;
  PFont font = createFont("Arial",16,true); // Arial, 16 point, anti-aliasing on

  // This is a dynamic hash table of donuts identified by their ID
  HashMap<Integer, Donut> donuts = new HashMap<Integer, Donut>();

  World(color backgroundColor)
  {
    this.backgroundColor = backgroundColor;
    things = new Vector<Thing>();
    
    if (DONUT_MOUSE_SIMULATION)
    {
      // Prepopulate with one donut
      int i = (BOOTHID-1)*N_QUALIA_AGENTS;
      Donut d = new Donut(i);
      donuts.put(i, d);
      super.add(d);
    }
    
    heatMap = createGraphics(WINDOW_WIDTH, WINDOW_HEIGHT);
    heatMap.beginDraw();
    heatMap.colorMode(GRAY, 1.0f);
    heatMap.noStroke();
    heatMap.background(HEAT_MAP_INITIAL_HEAT);
    heatMap.endDraw();
  }
  
  void addThing(Thing t)
  {
    super.add(t);
    things.add(t);
  }
  
  void removeThing(Thing t)
  {
    super.remove(t);
    things.remove(t);
  }
  
  Vector<Thing> getThings()
  {
    return things;
  }
  
  void addDonut(Donut d)
  {
    donuts.put(d.ID, d);
    super.add(d);
    println("Donut " + d.ID + " has just logged in at booth " + BOOTHID);
    // Inform logic and sound of donut logon at this booth
    oscLogic.sendBoothLogin(d, true);
    oscSound.sendBoothLogin(d, true);
  }
  
  void removeDonut(Donut d)
  {
    super.remove(d);
    donuts.remove(d.ID);
    println("Donut " + d.ID + " has just logged out of booth " + BOOTHID);
    // Inform logic and sound of donut logout at this booth
    oscLogic.sendBoothLogin(d, false);
    oscSound.sendBoothLogin(d, false);
  }
  
  float getHeatAt(float x, float y)
  {
    x = constrain(x, 0, WINDOW_WIDTH-1);
    y = constrain(y, 0, WINDOW_HEIGHT-1);
    return (float) red(heatMap.pixels[(int)x + ((int)y)*WINDOW_WIDTH]) / 255.0f;
  }
  
  Vector<Thing> getThingsInArea(float x, float y, float radius)
  {
    Vector<Thing> inArea = new Vector<Thing>();
    for (Thing t : things)
    {
      if (circleCollision(x, y, radius, t.x(), t.y(), t.size() * 0.5))
      {
        inArea.add(t);
      }
    }
    return inArea;
  }
  
  void step()
  {
    try
    {
      super.step();
    }
    catch (ArrayIndexOutOfBoundsException e)
    {
      println("----------- Thing stopped working -----------");
      println(e);
      e.printStackTrace();
      
      // dump data
      for (Thing t : things)
      {
        if (Double.isNaN(t.getForceX()) || Double.isNaN(t.getForceY()))
        {
          println("Bad force");
          t.resetForces();
        }
      }
    }
    
    heatMap.beginDraw();
    Collections.sort(things);
    Collections.reverse(things); // sort from biggest to smallest
    
    if (DONUT_MOUSE_SIMULATION)
    {
      // The cursor-controlled donut is the first donut of this booth
      Donut cursorControlledDonut = donuts.get(new Integer((BOOTHID-1)*N_QUALIA_AGENTS));
      if (cursorControlledDonut.getX() < 0 || cursorControlledDonut.getY() < 0)
      {
        println("Resetting donut position!");
        cursorControlledDonut.setPosition(width/2, height/2); 
      }
      else
      {
        cursorControlledDonut.step(this);
      }
    }
    
    // Add the heat from the donut.
    if (cursorAction)
    {
      Vector<Thing> affectedThings = new Vector<Thing>();
      heatMap.fill(DONUT_HEAT_INCREASE, HEAT_MAP_SPREAD_FACTOR);
            
      Iterator it = donuts.entrySet().iterator();
      while (it.hasNext())
      {
        Map.Entry me = (Map.Entry)it.next();
        Donut val = (Donut)me.getValue();
        //println("Looking at donut with key " + me.getKey() + " and position X=" + val.posX + " Y=" + val.posY);
        affectedThings.addAll(getThingsInArea(val.getX(), val.getY(), val.getSize()/2));
        heatMap.ellipse(val.getX(), val.getY(), val.getSize(), val.getSize());
        val.step(this);
      }      
      
      for (Thing t : affectedThings)
      {
        t.setHeat(t.getHeat() + DONUT_HEAT_INCREASE);
      }
    }
    
    heatMap.loadPixels();
    
    for (Thing t : things)
    {      
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
      if (traceSize > 0)
      {
        heatMap.fill(t.getHeat(), HEAT_MAP_SPREAD_FACTOR);
        heatMap.ellipse((int)t.x(), (int)t.y(), traceSize, traceSize);
      }
    }

    //heatMap.blendMode(REPLACE);
    heatMap.fill(0.0f, HEAT_MAP_DECREASE_FACTOR);
    heatMap.rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
    //heatMap.filter(blur);

    Vector<Thing> splitted = new Vector<Thing>();
    Vector<Thing> dead     = new Vector<Thing>();
    for (Thing t: things)
    {
      // Clean.
      if (t.isDead())
      {
        dead.add(t);
      }
      
      // Split.
      else if (t instanceof Munchkin)
      {
        Munchkin m = (Munchkin) t;
        if (m.size() <= 0)
        {
          dead.add(t);
        }
        else if (m.getHeat() >= 0.9f && random(0,1) < 0.05f)
        {
          Thing s = m.split();
          if (s != null)
          {
            splitted.add(s);
          }
        }
      }
    }

    for (Thing t: splitted)
    {
      addThing(t);
    }

    // Make sure we respect boundaries.
    for (Thing t: things)
    {
      t.setPosition( constrain(t.getX(), 5, width-5), constrain(t.getY(), 5, height-5) );
    }
    
    heatMap.endDraw();
    
    // Delete dead donuts
    Iterator it = donuts.entrySet().iterator();
    while (it.hasNext())
    {
      Map.Entry me = (Map.Entry)it.next();
      Donut d = (Donut)me.getValue();
      // Determine how long has elapsed since the last target position was received
      int msElapsed = millis() - d.msLastTargetPosition;
      if (msElapsed > DONUT_IDLE_LIFETIME_MS)
      {
        removeDonut(d);
      }
    }
  }

  void draw()
  {
    background(backgroundColor);
    //heatMap.blendMode(BLEND);
    textFont(font, 16);
    fill(255, 50);
    text("Booth " + BOOTHID, 20, 20);
    
    //image(heatMap, 0, 0);
    Iterator it = donuts.entrySet().iterator();
    while (it.hasNext())
    {
      Map.Entry me = (Map.Entry)it.next();
      Donut donut = (Donut)me.getValue();
    }
    super.draw();
    
    // Draw indicator point.
    color(255,0,0);
    ellipse(mouseX, mouseY, 3, 3);
  }
 
  /**
   * Check if two circles collide
   * x_1, y_1, radius_1 defines the first circle
   * x_2, y_2, radius_2 defines the second circle
   * From: http://wiki.processing.org/w/Circle-Circle_intersection
   */
  boolean circleCollision(float x_1, float y_1, float radius_1, float x_2, float y_2, float radius_2)
  {
    return dist(x_1, y_1, x_2, y_2) < radius_1 + radius_2;
  }
}
