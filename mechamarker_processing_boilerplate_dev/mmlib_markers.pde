int MARKER_COUNT = 100;
int MARKER_TIMEOUT_DEFAULT = 300;
float SMOOTHING = 0.5;

Mechamarkers mechamarkers; // declare Mechamarkers object

import java.util.Map;

HashMap<Integer, Marker> markers = new HashMap<Integer, Marker>();
HashMap<String, InputGroup> inputGroups = new HashMap<String, InputGroup>();
HashMap<String, Input> inputs = new HashMap<String, Input>();

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
