use <mg90s.scad>


module palm_part(knuckle_motor_pos){

    difference(){
        union(){
            hull(){
                cylinder(d=100,h=10);
                translate([20,-30,-70])cylinder(d=50);
            }
        }
        union(){
            // palm negative space
            for(i=[0:len(knuckle_motor_pos)-1]){
                translate(knuckle_motor_pos[i][0]) rotate(knuckle_motor_pos[i][1]) {
                    mg90s();
                    //bolts for the mg90s
                    //extra clearance
                    //etc
                }
            }
        }
    }
}

module knuckle_part(i, finger_motor_pos){
    difference(){
        union(){
            // knuckle parts
            hull(){
                cylinder(d=30,h=finger_motor_pos[i][0][2] - 15);
                translate(finger_motor_pos[i][0]) rotate(finger_motor_pos[i][1]) cylinder(d=15,h=6);
                rotate([0,0,180])translate(finger_motor_pos[i][0]) rotate(finger_motor_pos[i][1]) cylinder(d=15,h=6);
            }


        }
        union(){
            // knuckle negative space
            spline_shaft();
            translate(finger_motor_pos[i][0]) rotate(finger_motor_pos[i][1]) spline_shaft();
            translate(finger_motor_pos[i][0]) rotate(finger_motor_pos[i][1]) rotate([180,0,0]) cylinder(r=15,h=33);
        }
    }
}

module finger_part(i, claw_motor_pos){
    difference(){
        union(){
            //finger parts
            rotate([0,-90,0])cylinder(d=30, h=-claw_motor_pos[i][0][0]);

        }
        union(){
            //finger negative space
            mg90s();
            translate(claw_motor_pos[i][0]) rotate(claw_motor_pos[i][1]) spline_shaft();
        }
    }
}

module claw_part(i, claw_point_pos){
    difference(){
        union(){
            rotate([0,-90,0])cylinder(d1=30, d2=0, h=abs(claw_point_pos[i][0][0]));
            translate([mg90s_shaft_pos()[0],mg90s_shaft_pos()[1],0])sphere(d=30);

        }
        union(){
            //claw negative space
            mg90s();
        }
    }
}