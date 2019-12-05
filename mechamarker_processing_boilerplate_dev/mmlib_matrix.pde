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
