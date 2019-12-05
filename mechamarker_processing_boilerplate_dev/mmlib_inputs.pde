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
