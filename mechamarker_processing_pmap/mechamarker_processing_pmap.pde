int knobCounter = 0;

void setup() {
  fullScreen(P2D);
  generatePMAP();
  mechamarkers = new Mechamarkers(MARKER_COUNT);
  initWebSockets("ws://localhost:5000/");
  frameRate(50);
  fill(255);
  textSize(50);
  text("loading", 100, 100);
}

void draw() {
  //
  // Mechamarkers core functions. Do not edit
  //
  if (!inputLoaded) {
    println("waiting for input config ...");
    return;
  }
  mechamarkers.checkMarkerPresence(millis());
  for (InputGroup i : mechamarkers.inputGroupList) {
    i.update();
  }
  //
  //
  // Drawing routine. Add code below this line.
  
  background(0);
  fill(0);
  rect(0, 0, width, height);
  
  if (input.get("testgroup-knob").dir > 0) {
    knobCounter++;
  } else if (input.get("testgroup-knob").dir < 0) {
    knobCounter--;
  }
  
  project.get("panelA").beginDraw();
  project.get("panelA").background(100);
  project.get("panelA").translate(40, 40);
  project.get("panelA").rotate(PI/2);
  project.get("panelA").fill(255);
  project.get("panelA").textSize(30);
  project.get("panelA").text(knobCounter, 0, 0);
  project.get("panelA").endDraw();
  
  project.get("panelB").beginDraw();
  project.get("panelB").background(100, 0, 0);
  project.get("panelB").translate(40, 40);
  project.get("panelB").fill(255);
  project.get("panelB").textSize(30);
  project.get("panelB").text(knobCounter, 0, 0);
  project.get("panelB").endDraw();




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
