use <scad-utils/transformations.scad>


point = [0,0,40];
rot = [-10,-20,-30];
M=rotation(rot);

rotate(rot) cylinder(d1=20, d2=0, h=40);

translate(transform(M,[point])[0])sphere(d=5);





