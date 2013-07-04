class World extends FWorld
{
  color backgroundColor;
  Vector<Thing> things = new Vector<Thing>();
  PFont font = createFont("Arial", 16, true); // Arial, 16 point, anti-aliasing on
  Vector<Donut> donutsToRemove = new Vector<Donut>();

  // This is a dynamic hash table of donuts identified by their ID
  HashMap<Integer, Donut> donuts = new HashMap<Integer, Donut>();

  World(color backgroundColor)
  {
    this.backgroundColor = backgroundColor;
    
    if (DONUT_MOUSE_SIMULATION)
    {
      // Prepopulate with one donut
      int i = 0;
      Donut d = new Donut(i);
      donuts.put(i, d);
      super.add(d);
    }
  }
  
  void addThing(Thing t)
  {
    synchronized(things)
    {
      super.add(t);
      things.add(t);
    }
  }
  
  void removeThing(Thing t)
  {
    synchronized(things)
    {
      super.remove(t);
      things.remove(t);
    }
  }
  
  Vector<Thing> getThings()
  {
    return things;
  }
  
  void addDonut(Donut d)
  {
    synchronized(donuts)
    {
      donuts.put(d.ID, d);
      addThing(d);
    }
  }
  
  void removeDonut(Donut d)
  {
    synchronized(donuts)
    {
      donuts.remove(d.ID);
      super.remove(d);
    }
  }
  
  void removeDonuts()
  {
    synchronized(donutsToRemove)
    {
      for (Donut d : donutsToRemove)
      {
        removeDonut(d);
        println("Donut " + d.ID + " has just logged out");
      }
      donutsToRemove.clear();
    }
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
      Donut cursorControlledDonut = donuts.get(new Integer(0));
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
        if (m.size() >= MUNCHKIN_EXPLODE_SIZE_THRESHOLD)
        {
          float explodeProbability = (m.size() - MUNCHKIN_EXPLODE_SIZE_THRESHOLD) * MUNCHKIN_EXPLODE_BASE_PROBABILITY;
          if (random(0,1) < explodeProbability)
            m.explode();
        }
      }
    }

    // Make sure we respect boundaries.
    for (Thing t: things)
    {
      t.setPosition( constrain(t.getX(), 5, width-5), constrain(t.getY(), 5, height-5) );
    }
    
    // Remove idle donuts
    synchronized(donuts)
    {
      Iterator it = donuts.entrySet().iterator();
      while (it.hasNext())
      {
        Map.Entry me = (Map.Entry)it.next();
        Donut d = (Donut)me.getValue();
        // Determine how long has elapsed since the last target position was received
        int msElapsed = millis() - d.msLastTargetPosition;
        if (msElapsed > DONUT_THRESHOLD_LIFETIME_MS)
        {
          if (donuts.size() > DONUT_THRESHOLD_COUNT && !d.soundLoggedOut)
          {
            d.soundLoggedOut = true;
            // Tell the sound system that this donut should log out (the sound system keeps a max number of donut-related voices per booth)
          }
          if (msElapsed > DONUT_IDLE_LIFETIME_MS)
          {
            // This donut should be removed
            donutsToRemove.add(d);
            println("The donut with ID " + d.ID + " has been scheduled for deletion");
          }
        }
      }
    }
  }

  void draw()
  {
    background(backgroundColor);
    textFont(font, 16);
    fill(255, 50);
    
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
