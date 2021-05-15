use <mg90s.scad>

servo_bolt_depth=10;
servo_bolt_dia=1.6;


bolt_len=mg90s_shaft_len()+3; //not the true bolt length, the thread does not reach the bottom of the shaft.
bolt_head_len=30;
rear_flange=5;


servo_tail_shaft_dia = 5;
servo_tail_shaft_dia_shank = servo_tail_shaft_dia + 2;

servo_tail_shaft_dia_int = servo_tail_shaft_dia+0.5;
servo_tail_shaft_dia_shank_int=servo_tail_shaft_dia_shank+2;
servo_tail_thickness=3;

wrist_pos = [0,0,-40];
wrist_dia = 60;
arm_pos = [-20,-30,-70];

module palm_part(knuckle_motor_pos, knuckle_range){
    difference()
    {
        
        union(){
            for(i=[0:len(knuckle_motor_pos)-1])let(mot=knuckle_motor_pos[i]){
                hull(){
                    translate(mot[0]) rotate(mot[1]){
                        // house body of servo
                        translate(mg90s_base_pos()-[0,0,servo_tail_thickness+rear_flange+2*mg90s_shaft_len()])
                            linear_extrude(height=servo_tail_thickness+rear_flange+2*mg90s_shaft_len() + -mg90s_base_pos()[2]+ mg90s_bolt_top_pos()[0][2])
                                mg90s_section(use_hull=true,clearance=5);
                        // servo anchor points
                        translate([0,0,mg90s_bolt_bottom_pos()[0][2]-servo_bolt_depth])
                            linear_extrude(height=servo_bolt_depth)
                                mg90s_section(slice_height = -mg90s_bolt_bottom_pos()[0][2], use_hull=true);
                    }
                    translate(wrist_pos)cylinder(d=wrist_dia); // extend hull into arm
                }
            }
            hull(){
                translate(wrist_pos)cylinder(d=wrist_dia); // extend hull into arm
                translate(arm_pos)cylinder(d=50); // extend hull into arm
            }
        }

        color("red")union(){
            // palm negative space
            for(i=[0:len(knuckle_motor_pos)-1])let(mot=knuckle_motor_pos[i]){
                translate(mot[0]) rotate(mot[1]) {

                    //mg90s();
                    translate(mg90s_base_pos()) linear_extrude(height=40) mg90s_section();
                    translate([0,0,mg90s_bolt_bottom_pos()[0][2]])
                        linear_extrude(height=40)
                            mg90s_section(slice_height = -mg90s_bolt_bottom_pos()[0][2], use_hull=true);
                    mg90s_wire_channel(wrap_under=true);
                    //bolts for the mg90s
                    translate([0,0,-servo_bolt_depth]){
                        translate(mg90s_bolt_top_pos()[0])cylinder(d=servo_bolt_dia, h=servo_bolt_depth);
                        translate(mg90s_bolt_top_pos()[1])cylinder(d=servo_bolt_dia, h=servo_bolt_depth);
                    }

                    // clearance for knuckle tail shafts
                    translate(mg90s_base_pos()+[mg90s_shaft_pos()[0],0,0]) {
                        // shaft proper
                        translate([0,0,-(servo_tail_thickness + rear_flange + 2*mg90s_shaft_len())])
                            cylinder(d=servo_tail_shaft_dia_int,h=rear_flange + 2*mg90s_shaft_len());
                        // rocking clearance
                        hull(){
                            translate([0,0,-(servo_tail_thickness + rear_flange + mg90s_shaft_len())])
                                cylinder(d=servo_tail_shaft_dia_shank_int,h=rear_flange + mg90s_shaft_len());
                            for(a=knuckle_range[i]) rotate(v=[0,0,1],a=a)
                                translate([15,0,-(servo_tail_thickness + rear_flange + mg90s_shaft_len())])
                                    cylinder(d=16,h=rear_flange + mg90s_shaft_len());
                        }

                    }

                
                    //extra clearance
                    //etc
                }
            }
            //cavity joining motor bases
            for(mot=knuckle_motor_pos){
                hull(){
                    translate(mot[0]) rotate(mot[1]) {
                        translate(mg90s_base_pos()+[-5,0,0]){
                            linear_extrude(height=1)square([10,10], center=true);
                        }
                    }
                    // XXX duplicated cylinder
                    translate(wrist_pos)cylinder(d=30); // extend hull into arm
                }
            }
            hull(){
                // XXX duplicated cylinder
                translate(wrist_pos)cylinder(d=30); // extend hull into arm
                translate(arm_pos + [0,0,-1])cylinder(d=30); // extend hull into arm
            }
        }
    }
}

module knuckle_part(i, finger_motor_pos, knuckle_range){
    difference(){
        
        union(){
            // knuckle parts
            hull(){
                // mate to knuckle spline
                cylinder(d=15,h=6); //cube([10,40,6], center=true);
                // wide span over the servo horn
                translate([15, 10,0]) cylinder(d=10,h=3);
                translate([15,-10,0]) cylinder(d=10,h=3);
                //reach down to second shaft
                translate(mg90s_base_pos()+[0,0,-mg90s_shaft_pos()[2]]) {
                    // XXX duplicated arch
                    let(rad=8)
                        translate([20-rad,0,-(servo_tail_thickness + rear_flange+mg90s_shaft_len()-rad)])
                            rotate([-90,0,0])
                                linear_extrude(height=servo_tail_shaft_dia_shank, center=true)intersection(){
                                        circle(r=rad);
                                        square([rad,rad]);
                                    }
                }
                
                // mate to finger spline
                translate(finger_motor_pos[i][0]) rotate(finger_motor_pos[i][1]){
                    cylinder(d=15,h=6);
                    translate([0,0,-6-mg90s_shaft_len()-mg90s_shaft_pos()[2]+mg90s_base_pos()[2]]) cylinder(d=15,h=6);
                }
            }
            //
            hull(){
                translate(mg90s_base_pos()+[0,0,-mg90s_shaft_pos()[2]]) {
                    translate([0,0,-(servo_tail_thickness + rear_flange+mg90s_shaft_len())])
                        cylinder(d=servo_tail_shaft_dia_shank,h=rear_flange);
                    // XXX duplicated arch
                    let(rad=8)
                        translate([20-rad,0,-(servo_tail_thickness + rear_flange+mg90s_shaft_len()-rad)])
                            rotate([-90,0,0])
                                linear_extrude(height=servo_tail_shaft_dia_shank, center=true)intersection(){
                                    circle(r=rad);
                                    square([rad,rad]);
                                }
                }
            }
            //second support shaft into palm
            translate(mg90s_base_pos()+[0,0,-mg90s_shaft_pos()[2]]) {
                translate([0,0,-(servo_tail_thickness + rear_flange + 2*mg90s_shaft_len())])cylinder(d=5,h=mg90s_shaft_len());
            }

        }
        
        union(){
            // knuckle negative space

            // mate to knuckle servo spline
            translate([0,0,bolt_len])cylinder(d=7, h=bolt_head_len);//through-bolt head for spline
            cylinder(d=3.2, h=bolt_len+bolt_head_len);//through-bolt for spline
            spline_shaft();

            // palm motor negative space
            for(a=knuckle_range[i]) rotate(v=[0,0,1],a=a){
                let(
                    clear_len = mg90s_shaft_len() + mg90s_shaft_pos()[2]-mg90s_base_pos()[2] + servo_tail_thickness,
                    rad=mg90s_shaft_len()
                ) translate([0,0,-clear_len/2]) 
                    rotate([90,0,0])linear_extrude(height=50, center=true)hull()for(x=[-1,1])for(y=[-1,1])
                        translate([x*(13-rad), y*(clear_len/2-rad)])
                            circle(r=rad);
                    
            }
            // mate to finger servo spline
            cylinder();

            translate(finger_motor_pos[i][0]) rotate(finger_motor_pos[i][1]) spline_shaft();

            //clearance for finger servo body
            translate(finger_motor_pos[i][0]) rotate(finger_motor_pos[i][1]) rotate([180,0,0])hull() {
                cylinder(d=20,h=33);
                translate([0,0,5])cylinder(d=28,h=23);
            }
        }
    }
}

module finger_part(i, claw_motor_pos){
    difference(){
        union(){
            hull(){
            translate([mg90s_shaft_pos()[0],0,mg90s_base_pos()[2]]) cylinder(h=mg90s_bolt_top_pos()[0][2]-mg90s_base_pos()[2],d1=25,d2=25);
            //finger parts
            
            //claw spline
            translate(claw_motor_pos[i][0]) rotate(claw_motor_pos[i][1]) cylinder(d=12, h=6);
            }

        }
        union(){
            //finger negative space
            // mounting space for finger servo motor
            translate(mg90s_base_pos()) linear_extrude(height=40) mg90s_section();
            translate([0,0,mg90s_bolt_bottom_pos()[0][2]]) linear_extrude(height=40) mg90s_section(slice_height = -mg90s_bolt_bottom_pos()[0][2], use_hull=true);
            translate([0,0,-servo_bolt_depth]){
                translate(mg90s_bolt_top_pos()[0])cylinder(d=servo_bolt_dia, h=servo_bolt_depth);
                translate(mg90s_bolt_top_pos()[1])cylinder(d=servo_bolt_dia, h=servo_bolt_depth);
            }
            mg90s();
            // mate to claw servo spline
            translate(claw_motor_pos[i][0]) rotate(claw_motor_pos[i][1]) spline_shaft();
            //clearance for claw servo body
            translate(claw_motor_pos[i][0]) rotate(claw_motor_pos[i][1]) rotate([180,0,0])hull() {
                cylinder(d=20,h=33);
                translate([0,0,5])cylinder(d=28,h=23);
            }

        }
    }
}

module claw_part(i, claw_point_pos){
    difference(){
        union(){
            hull(){
                color("red")translate(claw_point_pos[i][0])sphere(r=1);
                //wrap servo body
                translate([0,0,-mg90s_bolt_top_pos()[0][2]])
                    linear_extrude(height=2*mg90s_bolt_top_pos()[0][2])
                        mg90s_section(clearance=2);
            }
            // servo anchor points
            translate([0,0,mg90s_bolt_bottom_pos()[0][2]-servo_bolt_depth])
                linear_extrude(height=servo_bolt_depth)
                    mg90s_section(slice_height = -mg90s_bolt_bottom_pos()[0][2], use_hull=true);
            // round body to fill finger clearance
            //translate([mg90s_shaft_pos()[0],mg90s_shaft_pos()[1],0])sphere(d=30);

        }
        union(){
            //claw negative space
            // mount claw servo motor
            translate(mg90s_base_pos()) linear_extrude(height=40) mg90s_section();
            translate([0,0,mg90s_bolt_bottom_pos()[0][2]]) linear_extrude(height=40)
                mg90s_section(slice_height = -mg90s_bolt_bottom_pos()[0][2], use_hull=true);
            translate([0,0,-servo_bolt_depth]){
                translate(mg90s_bolt_top_pos()[0])cylinder(d=servo_bolt_dia, h=servo_bolt_depth);
                translate(mg90s_bolt_top_pos()[1])cylinder(d=servo_bolt_dia, h=servo_bolt_depth);
            }
            mg90s();
        }
    }
}