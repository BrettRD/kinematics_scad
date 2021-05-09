use <dragon_claw.scad>

contact_rad = 70;
contact_height=90;
step_height = -10;
n_points = 5;

function ramp(t) = let(t_=t%1) t_ < 1/n_points ? t_ * (n_points-1) : 1-t_;
function parabola(t) = let(t_=t%1) 1 - (pow(t_ - (1/(2*n_points)),2)/pow(1/(2*n_points),2));
function step(t) = let(t_=t%1) t_ < 1/n_points ? parabola(t_): 0;

//for(t=[0:0.01:1]) translate([10*t, 10*ramp(t)]) circle(d=1);
//for(t=[0:0.001:1]) translate([10*t, 10*parabola(t)]) circle(d=1);
//for(t=[0:0.001:1]) translate([10*t, 10*step(t)]) circle(d=1);

function target_point(i,t) = let(
    theta = -15 + i*(360/n_points) + (90/n_points)*ramp(t+i/n_points) ,
    x = contact_rad*sin(theta),
    y = contact_rad*-cos(theta),
    z = contact_height+step_height*step(t+i/n_points)
    ) [x,y,z];

function pose(i,t) = ik_search(i=i, dst=target_point(i,t), pose=[0,0,0]);




//for(i=[0:n_points-1]) color("red")   fk_linalg_marker(i=i,pose=[0,0,0]);
//for(i=[0:n_points-1]) color("red")   fk_native_marker(i=i,pose=pose(i,$t));


//for(i=[0:4]) {
//    %translate(target_point(i,$t)) sphere(d=5);
//    color("red")   fk_linalg_marker(i=i,pose=pose(i,$t));
//}

assembly( [for(i=[0:n_points-1])pose(i,$t)] );
//assembly([[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]]);


