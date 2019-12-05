int knobCounter = 0;

void setup() {
  mechamarkers = new Mechamarkers(MARKER_COUNT);
  size(1000, 800, P2D);
  initWebSockets("ws://localhost:5000/");
  frameRate(50);
}

void draw() {
  // Mechamarkers core functions. Do not edit
  if (!inputLoaded) {
    println("waiting for input config ...");
    return;
  }
  mechamarkers.checkMarkerPresence(millis());
  for (InputGroup i : mechamarkers.inputGroupList) {
    i.update();
  }

  // Drawing routine. Add code below this line.
  fill(255);
  rect(0, 0, width, height);
  fill(100);
  if (markers.get(0).present) {
    fill(255);
  }
  rect(markers.get(14).center.x, markers.get(14).center.y, 10, 10);
  rect(markers.get(16).center.x, markers.get(16).center.y, 10, 10);
  
  
  //background(255);
  //rectMode(CENTER);
  
  //if (inputs.get("testgroup-knob").dir > 0) {
  //  knobCounter++;
  //} else if (inputs.get("testgroup-knob").dir < 0) {
  //  knobCounter--;
  //}
  //text(knobCounter, 200, 300);
  
  //pushMatrix();
  //fill(100);
  //if (inputs.get("testgroup-b1").val > 0.5) {
  //  fill(255);
  //}
  //rect(50, 50, 20, 20);
  //fill(100);
  //if (inputs.get("testgroup-b2").val > 0.5) {
  //  fill(255);
  //}
  //rect(100, 50, 20, 20);

  //fill(0);
  //translate(200, 200);
  //rotate(inputs.get("testgroup-knob").val);
  //rect(0, 0, 40, 40);
  
  //popMatrix();
}
