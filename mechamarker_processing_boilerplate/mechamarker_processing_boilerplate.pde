int knobCounter = 0;

void setup() {
  mechamarkers = new Mechamarkers(MARKER_COUNT);
  size(1000, 800, P2D);
  initWebSockets("ws://localhost:5000/");
  frameRate(50);
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

  background(255);
  rectMode(CENTER);
  
  if (input.get("testgroup-knob").dir > 0) {
    knobCounter++;
  } else if (input.get("testgroup-knob").dir < 0) {
    knobCounter--;
  }
  text(knobCounter, 200, 300);
  
  pushMatrix();
  fill(100);
  if (input.get("testgroup-b1").val > 0.5) {
    fill(255);
  }
  rect(50, 50, 20, 20);
  fill(100);
  if (input.get("testgroup-b2").val > 0.5) {
    fill(255);
  }
  rect(100, 50, 20, 20);

  fill(0);
  translate(200, 200);
  rotate(input.get("testgroup-knob").val);
  rect(0, 0, 40, 40);
  
  popMatrix();
}
