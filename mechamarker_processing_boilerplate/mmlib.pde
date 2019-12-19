///////////////////////////////
///////////////////////////////
//          MARKERS          //
///////////////////////////////
///////////////////////////////


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






///////////////////////////////
///////////////////////////////
//  INPUT GROUPS AND INPUTS  //
///////////////////////////////
///////////////////////////////


PVector xaxis = new PVector(-1, 0);

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
    inputs.put(name+"-"+n, inputList.get(inputList.size()-1));
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
      v = lineCPt(pos, spos, epos);
      v = constrain(v, 0, 1);
      val = (1-smoothing)*v + smoothing*val;
      pushMatrix();
      translate(width/2, height/2);
      stroke(255, 0, 0);
      fill(0, 255, 0);
      ellipse(pos.x, pos.y, 10, 10);
      line(spos.x, spos.y, epos.x, epos.y);
      popMatrix();
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
      inputGroups = new HashMap<String, InputGroup>();
      inputs = new HashMap<String, Input>();
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
            inputGroups.put(n, mechamarkers.inputGroupList.get(i));
            JSONArray jinputs = inputGroupObj.getJSONArray("inputs");
            if (jinputs.size() > 0) {
              for (int j=0; j<jinputs.size(); j++) {
                JSONObject jinput = jinputs.getJSONObject(j);
                String iN = jinput.getString("name");
                String t = jinput.getString("type");
                int aID = jinput.getInt("actorID");
                int aTO = jinput.getInt("detectWindow");
                JSONObject rp = jinput.getJSONObject("relativePosition");
                float rpd = rp.getFloat("distance");
                float rpa = rp.getFloat("angle");
                float rpd2 = rpd;
                float rpa2 = rpa;
                if (t.equals("SLIDER")) {
                  JSONObject ep = jinput.getJSONObject("endPosition");
                  rpd2 = ep.getFloat("distance");
                  rpa2 = ep.getFloat("angle");
                }
                println(inputGroups);
                inputGroups.get(n).addInput(iN, t, markers.get(aID), rpd, rpa, rpd2, rpa2);
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
