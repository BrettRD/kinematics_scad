use <mg90s.scad>


module palm_part(knuckle_motor_pos){

    difference(){
        union(){
            hull(){
                for(mot=knuckle_motor_pos)
                    translate(mot[0]) rotate(mot[1])
                            cube([10,10,10],center=true); // minimum mountings for each servo 
                translate([-20,-30,-70])cylinder(d=50); // extend hull into arm
            }
        }
        union(){
            // palm negative space
            for(mot=knuckle_motor_pos)
                translate(mot[0]) rotate(mot[1]) {
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
                // mate to knuckle spline
                cylinder(d=30,h=finger_motor_pos[i][0][2] - 15);
                // mate to finger spline
                translate(finger_motor_pos[i][0]) rotate(finger_motor_pos[i][1]) cylinder(d=15,h=6);
                // finger rear bearing 
                rotate([0,0,180])translate(finger_motor_pos[i][0]) rotate(finger_motor_pos[i][1]) cylinder(d=15,h=6);
            }


        }
        union(){
            // knuckle negative space

            // mate to knuckle servo spline
            spline_shaft();
            
            // mate to finger servo spline
            translate(finger_motor_pos[i][0]) rotate(finger_motor_pos[i][1]) spline_shaft();

            //clearance for finger servo body
            translate(finger_motor_pos[i][0]) rotate(finger_motor_pos[i][1]) rotate([180,0,0]) cylinder(r=15,h=33);
        }
    }
}

module finger_part(i, claw_motor_pos){
    difference(){
        union(){
            //finger parts
            rotate([0,-90,0])cylinder(d=20, h=-claw_motor_pos[i][0][0]);

        }
        union(){
            //finger negative space
            // mounting space for finger servo motor
            mg90s();
            // mate to claw servo spline
            translate(claw_motor_pos[i][0]) rotate(claw_motor_pos[i][1]) spline_shaft();
        }
    }
}

module claw_part(i, claw_point_pos){
    difference(){
        union(){
            rotate([0,-90,0])cylinder(d1=20, d2=0, h=abs(claw_point_pos[i][0][0]));

            // round body to fill finger clearance
            //translate([mg90s_shaft_pos()[0],mg90s_shaft_pos()[1],0])sphere(d=30);

        }
        union(){
            //claw negative space
            // mount claw servo motor
            mg90s();
        }
    }
}