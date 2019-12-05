import java.util.Map;

Table pmapConfig;
ArrayList<PMAP> pmaps;
HashMap<String, PGraphics> project;


boolean showEdge = true;
float minArea = 300;

void keyPressed() {
  for (int i=0; i<pmaps.size (); i++) {
    if (pmaps.get(i).selected) {
      if (key == CODED) {
        if (keyCode == UP) {
          pmaps.get(i).areaThres = pmaps.get(i).largestQuadSize-1;
          if (pmaps.get(i).areaThres < minArea) {
            pmaps.get(i).areaThres = pmaps.get(i).areaThres = minArea;
          }
          pmaps.get(i).cal_quads();
        }
        if (keyCode == DOWN) {
          pmaps.get(i).areaThres = pmaps.get(i).areaThres+pmaps.get(i).largestQuadSize;
          PVector a1 = pmaps.get(i).corners[0];
          PVector a2 = pmaps.get(i).corners[1];
          PVector a3 = pmaps.get(i).corners[2];
          PVector a4 = pmaps.get(i).corners[3];
          float qa = abs(((a1.x*a2.y-a1.y*a2.x)+(a2.x*a3.y-a2.y*a3.x)+(a3.x*a4.y-a3.y*a4.x)+(a4.x*a1.y-a4.y*a1.x))/2);
          if (pmaps.get(i).areaThres > qa) {
            pmaps.get(i).areaThres = pmaps.get(i).areaThres = qa;
          }
          pmaps.get(i).cal_quads();
        }
      }
    }
  }
  if (key == ' ') {
    showEdge = !showEdge;
  }
  if (key == 's' || key == 'S') {
    updatePMAP();
  }
}

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




/////////////////////////
/////////////////////////
//     PERSPECTIVE     //
/////////////////////////
/////////////////////////

PVector intersection(PVector a1, PVector a2, PVector a3, PVector a4) {

  float x = ((a1.x*a2.y-a1.y*a2.x)*(a3.x-a4.x)-(a1.x-a2.x)*(a3.x*a4.y-a3.y*a4.x))/((a1.x-a2.x)*(a3.y-a4.y)-(a1.y-a2.y)*(a3.x-a4.x));
  float y = ((a1.x*a2.y-a1.y*a2.x)*(a3.y-a4.y)-(a1.y-a2.y)*(a3.x*a4.y-a3.y*a4.x))/((a1.x-a2.x)*(a3.y-a4.y)-(a1.y-a2.y)*(a3.x-a4.x));

  PVector xy = new PVector(x, y);

  return xy;
}

float determinant(PVector a1, PVector a2, PVector a3, PVector a4) {

  float d = ((a1.x-a2.x)*(a3.y-a4.y)-(a1.y-a2.y)*(a3.x-a4.x));

  return d;
}

PVector[][] cal_perspective(PVector a1, PVector a2, PVector a3, PVector a4) {

  PVector[][] points = new PVector[3][3];

  points[0][0] = a1;
  points[0][2] = a2;
  points[2][2] = a3;
  points[2][0] = a4;

  boolean isThereVP1 = true;
  PVector vp1;
  boolean isThereVP2 = true;
  PVector vp2;

  if (abs(determinant(a1, a2, a3, a4)) < 0.001) {
    isThereVP1 = false;
  }

  if (abs(determinant(a1, a4, a2, a3)) < 0.001) {
    isThereVP2 = false;
  }

  points[1][1] = intersection(a1, a3, a2, a4);

  if (isThereVP1) {
    vp1 = intersection(a1, a2, a3, a4);
    points[1][0] = intersection(vp1, points[1][1], a1, a4);
    points[1][2] = intersection(vp1, points[1][1], a2, a3);
  } else {
    PVector dir = PVector.sub(a1, a2);
    PVector a5 = PVector.add(points[1][1], dir);
    points[1][0] = intersection(points[1][1], a5, a1, a4);
    points[1][2] = intersection(points[1][1], a5, a2, a3);
  }

  if (isThereVP2) {
    vp2 = intersection(a1, a4, a2, a3);
    points[0][1] = intersection(vp2, points[1][1], a1, a2);
    points[2][1] = intersection(vp2, points[1][1], a4, a3);
  } else {
    PVector dir = PVector.sub(a1, a4);
    PVector a5 = PVector.add(points[1][1], dir);
    points[0][1] = intersection(points[1][1], a5, a1, a2);
    points[2][1] = intersection(points[1][1], a5, a4, a3);
  }

  return points;
}

boolean pt_in_triangle(PVector test, PVector a1, PVector a2, PVector a3) {

  boolean is_it_in = false;

  float d1 = (a2.y-a1.y)*(test.x-a1.x)+(-a2.x+a1.x)*(test.y-a1.y);
  float d2 = (a3.y-a2.y)*(test.x-a2.x)+(-a3.x+a2.x)*(test.y-a2.y);
  float d3 = (a1.y-a3.y)*(test.x-a3.x)+(-a1.x+a3.x)*(test.y-a3.y);

  if (d1 >= 0 && d2 >= 0 && d3 >= 0) {
    is_it_in = true;
  }

  return is_it_in;
}

boolean pt_in_quad(PVector test, PVector a1, PVector a2, PVector a3, PVector a4) {

  boolean is_it_in1 = false;
  boolean is_it_in2 = false;

  float d1 = (a2.y-a1.y)*(test.x-a1.x)+(-a2.x+a1.x)*(test.y-a1.y);
  float d2 = (a3.y-a2.y)*(test.x-a2.x)+(-a3.x+a2.x)*(test.y-a2.y);
  float d3 = (a1.y-a3.y)*(test.x-a3.x)+(-a1.x+a3.x)*(test.y-a3.y);
  
  if ((d1 >= 0 && d2 >= 0 && d3 >= 0) || (d1 <= 0 && d2 <= 0 && d3 <= 0)) {
    is_it_in1 = true;
  }

  d1 = (a3.y-a1.y)*(test.x-a1.x)+(-a3.x+a1.x)*(test.y-a1.y);
  d2 = (a4.y-a3.y)*(test.x-a3.x)+(-a4.x+a3.x)*(test.y-a3.y);
  d3 = (a1.y-a4.y)*(test.x-a4.x)+(-a1.x+a4.x)*(test.y-a4.y);
  
  if ((d1 >= 0 && d2 >= 0 && d3 >= 0) || (d1 <= 0 && d2 <= 0 && d3 <= 0)) {
    is_it_in2 = true;
  }

  if (is_it_in1 || is_it_in2) {
    return true;
  } else {
    return false;
  }
}



///////////////////////////////
///////////////////////////////
//          MARKERS          //
///////////////////////////////
///////////////////////////////


int MARKER_COUNT = 100;
int MARKER_TIMEOUT_DEFAULT = 300;
float SMOOTHING = 0.5;

Mechamarkers mechamarkers; // declare Mechamarkers object

HashMap<Integer, Marker> markers = new HashMap<Integer, Marker>();
HashMap<String, InputGroup> inputGroup = new HashMap<String, InputGroup>();
HashMap<String, Input> input = new HashMap<String, Input>();

class Mechamarkers {

  Marker[] markerList;
  ArrayList<InputGroup> inputGroupList = new ArrayList<InputGroup>();

  Mechamarkers(int mc) {
    markerList = new Marker[mc];
    for (int i=0; i<mc; i++) {
      markerList[i] = new Marker(i);
      markers.put(i, markerList[i]);
    }
  }

  void updateMarker(int i, int timenow, PVector cen, PVector cor, PVector[] allCor) {
    markerList[i].update(timenow, cen, cor, allCor);
  }

  void checkMarkerPresence(int timenow) {
    for (int i=0; i<markerList.length; i++) {
      markerList[i].checkPresence(timenow);
    }
  }
}

class Marker {

  int id;
  int timestamp = 0;
  int timeout = MARKER_TIMEOUT_DEFAULT;

  PVector center = new PVector(0, 0);
  PVector corner = new PVector(0, 0);
  PVector[] allCorners = {new PVector(0, 0), new PVector(0, 0), new PVector(0, 0), new PVector(0, 0)};
  float smoothing = SMOOTHING;

  boolean present = false;

  boolean inuse = false;
  int groupID = -1;
  int inputID = -1;

  Marker(int ID) {
    id = ID;
  }

  void update(int timenow, PVector cen, PVector cor, PVector[] allCor) {
    if (present) {
      timestamp = timenow;
      center = PVector.add(PVector.mult(cen, 1-smoothing), PVector.mult(center, smoothing));
      corner = PVector.add(PVector.mult(cor, 1-smoothing), PVector.mult(corner, smoothing));
    } else {
      present = true;
      timestamp = timenow;
      center = cen.copy();
      corner = cor.copy();
    }

    for (int i=0; i<allCor.length; i++) {
      allCorners[i] = allCor[i].copy();
    }
  }

  void checkPresence(int timenow) {
    present = (timenow - timestamp) > timeout ? false : true;
  }
}






///////////////////////////////
///////////////////////////////
//  INPUT GROUPS AND INPUTS  //
///////////////////////////////
///////////////////////////////


PVector xaxis = new PVector(1, 0);

class InputGroup {

  String name;
  Marker anchor;
  boolean present = false;

  ArrayList<Input> inputList = new ArrayList<Input>();

  Matrix r2q;
  Matrix q2r;

  float markerSize;
  PVector[] realMarkerCorners  = new PVector[4];

  float angleOffset = -PI/4;

  InputGroup(String n, Marker anch, float ms) {
    name = n;
    anchor = anch;
    markerSize = ms;
    realMarkerCorners[0] = new PVector(-ms/2, -ms/2);
    realMarkerCorners[1] = new PVector(ms/2, -ms/2);
    realMarkerCorners[2] = new PVector(ms/2, ms/2);
    realMarkerCorners[3] = new PVector(-ms/2, ms/2);
  }

  void addInput(String n, String t, Marker act, float rpd, float rpa, float rpd2, float rpa2) {
    inputList.add(new Input(n, t, act, rpd, rpa, rpd2, rpa2));
    input.put(name+"-"+n, inputList.get(inputList.size()-1));
  }

  void update() {
    present = anchor.present;
    if (anchor.present) {
      r2q = calDistortionMatrix(anchor.allCorners[0], anchor.allCorners[1], anchor.allCorners[2], anchor.allCorners[3], realMarkerCorners[0], realMarkerCorners[1], realMarkerCorners[2], realMarkerCorners[3]);
      q2r = r2q.inverse();

      for (Input i : inputList) {
        i.update(this);
      }
    }
  }
}

class Input {

  String name;
  String type;
  float val = 0.0;

  Marker actor;
  boolean present = false;

  float relDist;
  float relAngle;
  float smoothing = 0.5;
  float relDistEnd;
  float relAngleEnd;
  float pval = 0;
  int dir = 0;
  int timestamp = 0;
  boolean click = false;

  Input(String n, String t, Marker act, float rpd, float rpa, float rpd2, float rpa2) {
    name = n;
    type = t;
    actor = act;
    relDist = rpd;
    relAngle = rpa;
    relDistEnd = rpd2;
    relAngleEnd = rpa2;
  }

  void update(InputGroup parent) {
    float v = 0;
    present = actor.present;

    switch(type) {

    case "BUTTON":
      v = actor.present ? 1 : 0;
      val = v*(1-smoothing) + val*smoothing;
      break;

    case "TOGGLE":
      v = actor.present ? 1 : 0;
      val = v*(1-smoothing) + val*smoothing;
      break;

    case "KNOB":
      PVector anchCen = matrixTransform(parent.q2r, parent.anchor.center);
      PVector anchCor = matrixTransform(parent.q2r, parent.anchor.corner);
      PVector actCen = matrixTransform(parent.q2r, actor.center);
      PVector actCor = matrixTransform(parent.q2r, actor.corner);
      PVector anchVec = PVector.sub(anchCor, anchCen);
      PVector actVec = PVector.sub(actCor, actCen);
      float angleBetween = -vecAngleBetween(anchVec, actVec);
      PVector A = new PVector(smoothing*cos(angleBetween), smoothing*sin(angleBetween));
      PVector B = new PVector((1-smoothing)*cos(val), (1-smoothing)*sin(val));
      PVector C = PVector.add(A, B);
      val = atan2(C.y, C.x);
      break;

    case "SLIDER":
      PVector pos = matrixTransform(parent.q2r, actor.center);
      PVector spos = PVector.mult(xaxis, relDist);
      spos.rotate(relAngle - parent.angleOffset);
      PVector epos = PVector.mult(xaxis, relDistEnd);
      epos.rotate(relAngleEnd - parent.angleOffset);
      PVector track = PVector.sub(epos, spos);
      v = lineCPt(pos, epos, spos);
      v = constrain(v, 0, 1);
      val = (1-smoothing)*v + smoothing*val;
      break;

    default:
      break;
    }

    if (millis() - timestamp > actor.timeout) {
      float delta = 0;
      switch(type) {

      case "KNOB":
        PVector CV = new PVector(cos(val), sin(val));
        PVector PV = new PVector(cos(pval), sin(pval));
        delta = -vecAngleBetween(CV, PV);
        dir = delta > 0.2 ? 1 : delta < -0.2 ? -1 : 0;
        break;

      case "SLIDER":
        delta = val - pval;
        dir = delta > 0.1 ? 1 : delta < -0.1 ? -1 : 0;
        break;

      default:
        delta = val - pval;
        dir = delta > 0.3 ? 1 : delta < -0.3 ? -1 : 0;
        break;
      }
      
      pval = val;
      timestamp = millis();
    } else {
      dir = 0;
    }
  }
}

float lineCPt(PVector p0, PVector p1, PVector p2) {
  PVector p10 = PVector.sub(p0, p1);
  PVector p12 = PVector.sub(p2, p1);
  return PVector.dot(p12, p10) / PVector.dot(p12, p12);
}

float vecAngleBetween(PVector vec1, PVector vec2) {
  // return Math.atan2(vec1.y, vec1.x) - Math.atan2(vec2.y, vec2.x);
  return atan2(vec1.x*vec2.y-vec1.y*vec2.x, vec1.x*vec2.x+vec1.y*vec2.y);
}




///////////////////////////////
///////////////////////////////
//          MATRIX           //
///////////////////////////////
///////////////////////////////


import Jama.*;

Matrix calDistortionMatrix(PVector q1, PVector q2, PVector q3, PVector q4, PVector r1, PVector r2, PVector r3, PVector r4) {
  double[][] preMatrixA = {
    { r1.x, r1.y, 1., 0., 0., 0., (-q1.x)*r1.x, (-q1.x)*r1.y }, 
    { 0., 0., 0., r1.x, r1.y, 1., (-q1.y)*r1.x, (-q1.y)*r1.y }, 
    { r2.x, r2.y, 1., 0., 0., 0., (-q2.x)*r2.x, (-q2.x)*r2.y }, 
    { 0., 0., 0., r2.x, r2.y, 1., (-q2.y)*r2.x, (-q2.y)*r2.y }, 
    { r3.x, r3.y, 1., 0., 0., 0., (-q3.x)*r3.x, (-q3.x)*r3.y }, 
    { 0., 0., 0., r3.x, r3.y, 1., (-q3.y)*r3.x, (-q3.y)*r3.y }, 
    { r4.x, r4.y, 1., 0., 0., 0., (-q4.x)*r4.x, (-q4.x)*r4.y }, 
    { 0., 0., 0., r4.x, r4.y, 1., (-q4.y)*r4.x, (-q4.y)*r4.y }
  };
  double[][] preMatrixB = {
    { q1.x }, 
    { q1.y }, 
    { q2.x }, 
    { q2.y }, 
    { q3.x }, 
    { q3.y }, 
    { q4.x }, 
    { q4.y }
  };

  Matrix matrixA = new Matrix(preMatrixA);
  Matrix matrixB = new Matrix(preMatrixB);

  Matrix s = matrixA.solve(matrixB);

  double[][] subset = {
    {s.get(0, 0), s.get(1, 0), s.get(2, 0)}, 
    {s.get(3, 0), s.get(4, 0), s.get(5, 0)}, 
    {s.get(6, 0), s.get(7, 0), 1.0}
  };

  return new Matrix(subset);
}

PVector matrixTransform(Matrix m, PVector v) {
  double[][] preMatrixV = {
    {v.x}, 
    {v.y}, 
    {1.0}
  };
  Matrix matrixV = new Matrix(preMatrixV);
  Matrix result = m.times(matrixV);

  return new PVector(
    (float)(result.get(0, 0)/result.get(2, 0)), (float)(result.get(1, 0)/result.get(2, 0))
    );
}




///////////////////////////////
///////////////////////////////
//        WEBSOCKETS         //
///////////////////////////////
///////////////////////////////


import websockets.*;

WebsocketClient wsc;
boolean inputLoaded = false;

void initWebSockets(String url) {
  wsc= new WebsocketClient(this, url);
  delay(1000);
  wsc.sendMessage("{\"type\": \"get input config\"}");
}

void webSocketEvent(String msg) {
  JSONObject json = parseJSONObject(msg);
  if (json != null) {
    String msgType = json.getString("type");

    switch(msgType) {

    case "markers":
      JSONObject markersJSON = json.getJSONObject("markers"); 
      try {
        JSONArray markersArray = markersJSON.getJSONArray("markers");
        if (markersArray.size() > 0) {
          for (int i=0; i<markersArray.size(); i++) {
            JSONObject markerObject = markersArray.getJSONObject(i);
            int markerID = markerObject.getInt("id");

            JSONArray cornersJSON = markerObject.getJSONArray("corners");
            float cornerX1 = cornersJSON.getJSONArray(0).getFloat(0);
            float cornerY1 = cornersJSON.getJSONArray(0).getFloat(1);
            float cornerX2 = cornersJSON.getJSONArray(1).getFloat(0);
            float cornerY2 = cornersJSON.getJSONArray(1).getFloat(1);
            float cornerX3 = cornersJSON.getJSONArray(2).getFloat(0);
            float cornerY3 = cornersJSON.getJSONArray(2).getFloat(1);
            float cornerX4 = cornersJSON.getJSONArray(3).getFloat(0);
            float cornerY4 = cornersJSON.getJSONArray(3).getFloat(1);

            PVector corner = new PVector(cornerX1, cornerY1);
            PVector center = new PVector((cornerX1+cornerX2+cornerX3+cornerX4)/4, (cornerY1+cornerY2+cornerY3+cornerY4)/4);
            PVector[] cornerArray = {new PVector(cornerX1, cornerY1), new PVector(cornerX2, cornerY2), new PVector(cornerX3, cornerY3), new PVector(cornerX4, cornerY4)};
            mechamarkers.updateMarker(markerID, millis(), center, corner, cornerArray);
          }
        }
      } 
      catch (Exception e) {
        println(e);
      }
      break;

    case "input config":
      println(msg);
      mechamarkers.inputGroupList = new ArrayList<InputGroup>();
      inputGroup = new HashMap<String, InputGroup>();
      input = new HashMap<String, Input>();
      String inputGroupConfigString = json.getString("config");
      JSONObject inputGroupConfig = parseJSONObject(inputGroupConfigString);
      try {
        JSONArray inputGroupArray = inputGroupConfig.getJSONArray("groups");
        if (inputGroupArray.size() > 0) {
          for (int i=0; i<inputGroupArray.size(); i++) {
            JSONObject inputGroupObj = inputGroupArray.getJSONObject(i);
            String n = inputGroupObj.getString("name");
            int id = inputGroupObj.getInt("anchorID");
            int tO = inputGroupObj.getInt("detectWindow");
            float ms = inputGroupObj.getInt("markerSize");
            mechamarkers.inputGroupList.add(new InputGroup(n, markers.get(id), ms));
            markers.get(id).timeout = tO;
            inputGroup.put(n, mechamarkers.inputGroupList.get(i));
            
            JSONArray inputs = inputGroupObj.getJSONArray("inputs");
            if (inputs.size() > 0) {
              for (int j=0; j<inputs.size(); j++) {
                JSONObject input = inputs.getJSONObject(j);
                String iN = input.getString("name");
                String t = input.getString("type");
                int aID = input.getInt("actorID");
                int aTO = input.getInt("detectWindow");
                JSONObject rp = input.getJSONObject("relativePosition");
                float rpd = rp.getFloat("distance");
                float rpa = rp.getFloat("angle");
                float rpd2 = rpd;
                float rpa2 = rpa;
                if (t.equals("SLIDER")) {
                  JSONObject ep = input.getJSONObject("endPosition");
                  rpd2 = ep.getFloat("distance");
                  rpa2 = ep.getFloat("angle");
                }
                inputGroup.get(n).addInput(iN, t, markers.get(aID), rpd, rpa, rpd2, rpa2);
                markers.get(aID).timeout = aTO;
              }
            }
          }
        }
      }
      catch (Exception e) {
        println(e);
      }
      inputLoaded = true;
      break;

    default:
      break;
    }
  }
}
