import java.util.Map;

Table pmapConfig;
ArrayList<PMAP> pmaps;
HashMap<String, PGraphics> project;


boolean showEdge = false;
float minArea = 300;

void generatePMAP() {
  pmapConfig = loadTable("projection_config.csv", "header");
  pmaps = new ArrayList<PMAP>();
  project = new HashMap<String, PGraphics>();
  float xpos = 50;
  float ypos = 50;
  int counter = 0;
  for (TableRow row : pmapConfig.rows()) {
    String n = row.getString("name");
    int w = row.getInt("width");
    int h = row.getInt("height");
    float x1 = row.getFloat("x1");
    float y1 = row.getFloat("y1");
    float x2 = row.getFloat("x2");
    float y2 = row.getFloat("y2");
    float x3 = row.getFloat("x3");
    float y3 = row.getFloat("y3");
    float x4 = row.getFloat("x4");
    float y4 = row.getFloat("y4");
    if (Float.isNaN(x1) || Float.isNaN(y1) || Float.isNaN(x2) || Float.isNaN(y2) || Float.isNaN(x3) || Float.isNaN(y3) || Float.isNaN(x4) || Float.isNaN(y4)) {
      pmaps.add(new PMAP(n, new PVector(xpos, ypos), new PVector(xpos+100, ypos), new PVector(xpos+100, ypos+100), new PVector(xpos, ypos+100), w, h, minArea));
      xpos = xpos + 100;
    } else {
      pmaps.add(new PMAP(n, new PVector(x1, y1), new PVector(x2, y2), new PVector(x3, y3), new PVector(x4, y4), w, h, minArea));
    }
    project.put(n, pmaps.get(counter).graphic);
    counter++;
  }
}

void updatePMAP() {
  int counter = 0;
  for (TableRow row : pmapConfig.rows()) {
    row.setFloat("x1", pmaps.get(counter).corners[0].x);
    row.setFloat("y1", pmaps.get(counter).corners[0].y);
    row.setFloat("x2", pmaps.get(counter).corners[1].x);
    row.setFloat("y2", pmaps.get(counter).corners[1].y);
    row.setFloat("x3", pmaps.get(counter).corners[2].x);
    row.setFloat("y3", pmaps.get(counter).corners[2].y);
    row.setFloat("x4", pmaps.get(counter).corners[3].x);
    row.setFloat("y4", pmaps.get(counter).corners[3].y);
    counter++;
  }
  try {
    saveTable(pmapConfig, "data/projection_config.csv");
  } 
  catch (Exception e) {
    println(e);
  }
}


class PMAP {

  String name;
  PVector[] corners = new PVector[4];
  ArrayList<Quad> quads = new ArrayList<Quad>();
  float areaThres;
  boolean selected = false;
  int ptToMove = -1;
  float largestQuadSize = 0;
  PGraphics graphic;

  PMAP(String n, PVector topleft, PVector topright, PVector botright, PVector botleft, int w, int h, float aT) {
    name = n;
    corners[0] = topleft;
    corners[1] = topright;
    corners[2] = botright;
    corners[3] = botleft;
    graphic = createGraphics(w, h);
    graphic.beginDraw();
    graphic.background(100);
    graphic.endDraw();
    areaThres = aT;
  }

  void cal_quads() {
    boolean smallEnough = false;    
    ArrayList<Quad> quadsBuffer1 = new ArrayList<Quad>(0);
    quadsBuffer1.add(new Quad(corners[0], corners[1], corners[2], corners[3], 0, 1, 0, 1));
    while (!smallEnough) {
      int count = 0;
      for (int i=0; i<quadsBuffer1.size (); i++) {
        if (quadsBuffer1.get(i).area() > areaThres) {
          count++;
        }
      }
      if (count == 0) {
        smallEnough = true;
      }
      ArrayList<Quad> quadsBuffer2 = new ArrayList<Quad>(0);
      for (int i=0; i<quadsBuffer1.size (); i++) {
        count = 0;
        if (quadsBuffer1.get(i).area() > areaThres) {
          float xx1 = quadsBuffer1.get(i).x1;
          float xx2 = quadsBuffer1.get(i).x2;
          float yy1 = quadsBuffer1.get(i).y1;
          float yy2 = quadsBuffer1.get(i).y2;
          float xGap = (xx2-xx1)/2;
          float yGap = (yy2-yy1)/2;
          PVector[][] pointGrid = cal_perspective(quadsBuffer1.get(i).a1, quadsBuffer1.get(i).a2, quadsBuffer1.get(i).a3, quadsBuffer1.get(i).a4);
          for (int j=0; j<2; j++) {
            for (int k=0; k<2; k++) {
              quadsBuffer2.add(new Quad(pointGrid[j][k], pointGrid[j][k+1], pointGrid[j+1][k+1], pointGrid[j+1][k], xx1+k*xGap, xx1+(k+1)*xGap, yy1+j*yGap, yy1+(j+1)*yGap));
            }
          }
        } else {
          quadsBuffer2.add(quadsBuffer1.get(i));
        }
      }
      for (int i=quadsBuffer1.size ()-1; i>=0; i--) {
        quadsBuffer1.remove(i);
      }
      for (int i=0; i<quadsBuffer2.size (); i++) {
        quadsBuffer1.add(quadsBuffer2.get(i));
      }
    }
    quads = new ArrayList<Quad>();
    largestQuadSize = 0;
    for (int i=0; i<quadsBuffer1.size (); i++) {
      quads.add(quadsBuffer1.get(i));
      if (quadsBuffer1.get(i).area() > largestQuadSize) {
        largestQuadSize = quadsBuffer1.get(i).area();
      }
    }
  }

  void display() {
    textureMode(NORMAL);
    for (Quad q : quads) {
      if (selected) {
        strokeWeight(1);
        stroke(255, 100);
      } else {
        noStroke();
      }
      beginShape();
      texture(graphic);
      vertex(q.a1.x, q.a1.y, q.x1, q.y1);
      vertex(q.a2.x, q.a2.y, q.x2, q.y1);
      vertex(q.a3.x, q.a3.y, q.x2, q.y2);
      vertex(q.a4.x, q.a4.y, q.x1, q.y2);
      endShape(CLOSE);
    }
  }

  void hover() {
    if (showEdge) {
      stroke(255, 100);
      strokeWeight(1);
      noFill();
      beginShape();
      vertex(corners[0].x, corners[0].y);
      vertex(corners[1].x, corners[1].y);
      vertex(corners[2].x, corners[2].y);
      vertex(corners[3].x, corners[3].y);
      endShape(CLOSE);
    }
    if (in(mouseX, mouseY) || ptToMove != -1) {
      stroke(255);
      strokeWeight(2);
      noFill();
      beginShape();
      vertex(corners[0].x, corners[0].y);
      vertex(corners[1].x, corners[1].y);
      vertex(corners[2].x, corners[2].y);
      vertex(corners[3].x, corners[3].y);
      endShape(CLOSE);
    }
    if (selected) {
      for (int i=0; i<4; i++) {
        strokeWeight(1);
        stroke(255);
        fill(0);
        ellipse(corners[i].x, corners[i].y, 20, 20);
      }
    }
    if (ptToMove != -1) {
      strokeWeight(1);
      stroke(255);
      fill(0);
      ellipse(corners[ptToMove].x, corners[ptToMove].y, 20, 20);
    }
  }

  boolean in(float x, float y) {
    PVector pt = new PVector(x, y);
    return pt_in_quad(pt, corners[0], corners[1], corners[2], corners[3]);
  }

  int movePt(float x, float y) {
    PVector pt = new PVector(x, y);
    int c = 0;
    for (int i=0; i<4; i++) {
      float d = PVector.dist(pt, corners[i]);
      if (d < 20) {
        ptToMove = i;
        c++;
      }
    }
    if (c == 0) {
      ptToMove = -1;
    }    
    return c;
  }

  void move_corner() {
    if (mousePressed && ptToMove != -1) {
      boolean canItMove = true;
      PVector p = new PVector(mouseX, mouseY);
      switch(ptToMove) {
      case 0:
        canItMove = (mouseX >= corners[1].x || mouseY >= corners[3].y) ? false : true;
        if (determinant(p, corners[1], corners[3], p)>0.01) {
          canItMove = false;
        }
        break;
      case 1:
        canItMove = (mouseX <= corners[0].x || mouseY >= corners[2].y) ? false : true;
        if (determinant(p, corners[2], corners[0], p)>0.01) {
          canItMove = false;
        }
        break;
      case 2:
        canItMove = (mouseX <= corners[3].x || mouseY <= corners[1].y) ? false : true;
        if (determinant(p, corners[3], corners[1], p)>0.01) {
          canItMove = false;
        }
        break;
      case 3:
        canItMove = (mouseX >= corners[2].x || mouseY <= corners[0].y) ? false : true;
        if (determinant(p, corners[0], corners[2], p)>0.01) {
          canItMove = false;
        }
        break;
      }
      if (canItMove) {
        corners[ptToMove] = new PVector(mouseX, mouseY);
      }
    } else if (mousePressed && selected && ptToMove == -1) {
      PVector t = new PVector(mouseX-pmouseX, mouseY-pmouseY);
      for (int i=0; i<4; i++) {
        corners[i].add(t);
        cal_quads();
      }
    } else if (!mousePressed && ptToMove != -1) {
      cal_quads();
      ptToMove = -1;
    } else {
      ptToMove = -1;
    }
  }
}

class Quad {

  PVector a1, a2, a3, a4; //vertices starting with top left and clockwise
  float x1, x2; //texture x domain that quad maps
  float y1, y2; //texture y domain that quad maps

  Quad(PVector one, PVector two, PVector three, PVector four, float xx1, float xx2, float yy1, float yy2) {
    a1 = one;
    a2 = two;
    a3 = three;
    a4 = four;
    x1 = xx1;
    x2 = xx2;
    y1 = yy1;
    y2 = yy2;
  }

  float area() {
    float qa = abs(((a1.x*a2.y-a1.y*a2.x)+(a2.x*a3.y-a2.y*a3.x)+(a3.x*a4.y-a3.y*a4.x)+(a4.x*a1.y-a4.y*a1.x))/2);
    return qa;
  }
}
