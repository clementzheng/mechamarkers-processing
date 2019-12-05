void setup() {
  fullScreen(P2D);
  generatePMAP();
}

void draw() {
  background(0);
  fill(0);
  rect(0, 0, width, height);
  
  project.get("panelA").beginDraw();
  project.get("panelA").background(100);
  project.get("panelA").translate(40, 40);
  project.get("panelA").rotate(PI/2);
  project.get("panelA").fill(255);
  project.get("panelA").textSize(30);
  project.get("panelA").text(millis(), 0, 0);
  project.get("panelA").endDraw();

  for (PMAP p : pmaps) {
    p.display();
    p.hover();
    p.move_corner();
  }
}

void mousePressed() {
  boolean pointMoving = false;
  for (PMAP p : pmaps) {
    if (p.selected) {
      if (p.movePt(mouseX, mouseY) > 0) {
        pointMoving = true;
      }
    }
  }
  if (!pointMoving) {
    int c = -1;
    for (int i=0; i<pmaps.size (); i++) {
      if (pmaps.get(i).in(mouseX, mouseY)) {
        pmaps.get(i).selected = true;
        c = i;
      }
    }
    if (c == -1) {
      for (int i=0; i<pmaps.size (); i++) {
        pmaps.get(i).selected = false;
      }
    } else {
      for (int i=0; i<pmaps.size (); i++) {
        if (i != c) {
          pmaps.get(i).selected = false;
        }
      }
    }
  }
}

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
