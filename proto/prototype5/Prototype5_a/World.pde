class World extends FWorld
{
  color backgroundColor;
  Vector<Thing> things;
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
    // Inform logic of donut logout at this booth
    oscLogic.sendBoothLogin(d, false);
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
            
      Iterator it = donuts.entrySet().iterator();
      while (it.hasNext())
      {
        Map.Entry me = (Map.Entry)it.next();
        Donut val = (Donut)me.getValue();
        //println("Looking at donut with key " + me.getKey() + " and position X=" + val.posX + " Y=" + val.posY);
        affectedThings.addAll(getThingsInArea(val.getX(), val.getY(), val.getSize()/2));
        val.step(this);
      }      
      
      for (Thing t : affectedThings)
      {
        t.setHeat(t.getHeat() + DONUT_HEAT_INCREASE);
      }
    }
    
    for (Thing t : things)
    {      
      t.step(this);
    }

    for (Thing t: things)
    {
      // Explode.
      if (t instanceof Munchkin)
      {
        Munchkin m = (Munchkin) t;
        if (m.size() >= 10 && random(0,1) < 0.05f)
        {
          m.explode();
        }
      }
    }

    // Make sure we respect boundaries.
    for (Thing t: things)
    {
      t.setPosition( constrain(t.getX(), 5, width-5), constrain(t.getY(), 5, height-5) );
    }
    
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
