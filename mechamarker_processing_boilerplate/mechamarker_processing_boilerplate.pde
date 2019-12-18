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
  
  float x = markers.get(0).center.x;
  float y = markers.get(0).center.y;
  ellipse(x, y, 20, 20);
}
