use <mg90s.scad>

servo_bolt_depth=10;
servo_bolt_dia=1.6;

module palm_part(knuckle_motor_pos){
    difference(){
        union(){
            hull(){
                for(mot=knuckle_motor_pos){
                    translate(mot[0]) rotate(mot[1]){
                        translate([0,0,mg90s_bolt_bottom_pos()[0][2]])translate([0,0,-servo_bolt_depth/2])cube([33,12,servo_bolt_depth],center=true);
                    }
                }
                translate([-20,-30,-70])cylinder(d=50); // extend hull into arm
            }
        }
        union(){
            // palm negative space
            for(mot=knuckle_motor_pos){
                translate(mot[0]) rotate(mot[1]) {
                    mg90s();
                    mg90s_wire_channel();
                    //bolts for the mg90s
                    translate([0,0,-servo_bolt_depth]){
                        translate(mg90s_bolt_top_pos()[0])cylinder(d=servo_bolt_dia, h=servo_bolt_depth);
                        translate(mg90s_bolt_top_pos()[1])cylinder(d=servo_bolt_dia, h=servo_bolt_depth);
                    }
                    //extra clearance
                    //etc
                }
            }
            hull(){
                for(mot=knuckle_motor_pos){
                    translate(mot[0]) rotate(mot[1]) {
                        translate(mg90s_base_pos()){
                            linear_extrude(height=1)mg90s_section(clearance=0.3, slice_height = -mg90s_wire_pos()[2]);
                            //translate([0,0,-20])linear_extrude(height=1)mg90s_section(clearance=10);
                        }
                    }
                }
                translate([-20,-30,-71])cylinder(d=30); // extend hull into arm
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
                translate([0,0,3]) cylinder(d=15,h=6); //cube([10,40,6], center=true);
                
                translate([15, 10,0]) cylinder(d=10,h=3);
                translate([15,-10,0]) cylinder(d=10,h=3);
                rear_flange=5;
                translate(mg90s_base_pos()+[0,0,-mg90s_shaft_pos()[2]]) {
                    translate([0,0,-(rear_flange+mg90s_shaft_len())])cylinder(d=5,h=rear_flange);
                    translate([15,0,-(rear_flange+mg90s_shaft_len())]) cylinder(d=10,h=rear_flange);
                }
                
                // mate to finger spline
                translate(finger_motor_pos[i][0]) rotate(finger_motor_pos[i][1]){
                    cylinder(d=15,h=6);
                    translate([0,0,-6-mg90s_shaft_len()-mg90s_shaft_pos()[2]+mg90s_base_pos()[2]]) cylinder(d=15,h=6);
                }
            }
            //second support shaft into palm
            translate(mg90s_base_pos()+[0,0,-mg90s_shaft_pos()[2]]) {
                translate([0,0,-(3+2*mg90s_shaft_len())])cylinder(d=5,h=mg90s_shaft_len());
            }

        }
        union(){
            // knuckle negative space
            bolt_len=mg90s_shaft_len()+3; //not the true bolt length, the thread does not reach the bottom of the shaft.
            bolt_head_len=30;
            // mate to knuckle servo spline
            translate([0,0,bolt_len])cylinder(d=7, h=bolt_head_len);//through-bolt head for spline
            cylinder(d=3.2, h=bolt_len+bolt_head_len);//through-bolt for spline
            spline_shaft();

            // palm motor negative space
            knuckle_range = 20;
            for(a=[-knuckle_range,knuckle_range]) rotate(v=[0,0,1],a=a){
                translate([0,0,-mg90s_shaft_len()-mg90s_shaft_pos()[2]+mg90s_base_pos()[2]]) {
                    linear_extrude(height = mg90s_shaft_len() + mg90s_shaft_pos()[2]-mg90s_base_pos()[2]) square([23,50], center=true);
                }
            }
            // mate to finger servo spline
            cylinder();

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