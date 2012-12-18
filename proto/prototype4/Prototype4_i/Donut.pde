class Donut extends Thing {
  int[] nEaten;
  
  Donut() {
    super(random(width), random(height), 1);
    setFillColor(#ff0000);
    nEaten = new int[3];
  }
  
  // Implement abstract methods.
  int getNation() {
    return Thing.WHITE;
//    int preyNation = getMaxNationEaten();
//    return getPredatorNationOf(preyNation);
  }
  
  float getHeat() { return 0.5f; } // dummy
  
/*
  int getMaxNationEaten() {
    int maxEaten = -1;
    int maxNation = -1;
    for (int i=0; i<nEaten.length; i++) {
      if (nEaten[i] > maxEaten) {
        maxNation = i;
        maxEaten = nEaten[i];
      }
    }
    return maxNation;
  }*/
  
/*  boolean isPredatorOf(Thing o) {
    if (o instanceof Munchkin) {
      println("My nation is " + getNation() + " / predator is " + getPredatorNationOf(getNation()) + " / other is " + o.getNation() + " / will return " + !o.isPredatorOf(this));
//      return o.getNation() != Thing.RED;
      return !o.isPredatorOf(this); // cannot attack its predator but CAN attack its siblings
    }
    else
      return super.isPredatorOf(o);
  }*/
  
  /*
  int size() {
    int size = 1;
    for (int i=0; i<nEaten.length; i++) {
      size += (int) 4*log(nEaten[i]+1);
      print(nEaten[i] + " ");
    }
    println();
    return size;
  }*/
  
//  int x() { return mouseX; }
//  int y() { return mouseY; }
  /*
  void eat(Thing o) {
    if (o.isPredatorOf(this)) {
      println("Trying to eat predator wtf!!!");
      return;
    }
    int nationIdx = o.getNation();
    if (nationIdx == Thing.WHITE)
      nationIdx = (int) random(3);
    nEaten[nationIdx]++;
    
    if (o instanceof Munchkin) {
      ((Munchkin)o).size--;
    } else {
      int preyIdx = getPreyNationOf(nationIdx);
      ((Donut)o).nEaten[preyIdx] = max(((Donut)o).nEaten[preyIdx] - 1, 0);
    }
  }*/

  // Override parent.
  /*int getColor() {
    if (nEaten[0] == 0 && nEaten[1] == 0 && nEaten[2] == 0)
      return #000000; // default is black
    else {
      float[] prop = getProportionEaten();
      int r = 0, g = 0, b = 0;
      for (int i=0; i<Thing.N_NATIONS; i++) {
        int predatorColor = nationToColor(getPredatorNationOf(i));
        r += (int) (prop[i] * red(predatorColor));
        g += (int) (prop[i] * green(predatorColor));
        b += (int) (prop[i] * blue(predatorColor));
      }
      return color(r, g, b);
    }
  }*/
  
  // Override.
  boolean isDead() { return false; }
  
  void step(World world) {
    
  }
  
  /*
  void draw() {
    ellipseMode(CENTER);
    noStroke();
    int col = getColor();
    fill(col);
    stroke(#ffffff);
    strokeWeight(1);
    int size = size()+3;
    smooth();
    ellipse(mouseX, mouseY, size, size);
  }
  
  float[] getProportionEaten() {
    float total = 0;
    for (int i=0; i<nEaten.length; i++)
      total += nEaten[i];
    float[] prop = new float[nEaten.length];
    for (int i=0; i<nEaten.length; i++)
      prop[i] = nEaten[i] / total;
    return prop;
  }*/
    
}
