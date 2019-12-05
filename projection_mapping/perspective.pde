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
