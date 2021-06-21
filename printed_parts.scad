use <mg90s.scad>
use <scad-utils/transformations.scad>

servo_bolt_depth=10;
servo_bolt_dia=1.6;


bolt_len=mg90s_shaft_len()+1; //not the true bolt length, the thread does not reach the bottom of the shaft.
bolt_head_len=30;
rear_flange=5;
rear_flange_bush=0.5;


servo_tail_shaft_dia = 5;
servo_tail_shaft_dia_shank = servo_tail_shaft_dia + 2;

servo_tail_shaft_dia_int = servo_tail_shaft_dia+0.5;
servo_tail_shaft_dia_shank_int=servo_tail_shaft_dia_shank+2;
servo_tail_thickness=3;

wrist_pos = [0,0,-40];
wrist_dia = 60;
arm_pos = [-20,-30,-70];

motor_socket_dia=25;
motor_socket_clear_dia=28;
motor_socket_clear_dia_neck=20;

spline_mate_dia=15;
spline_mate_len=6.5;   //the length of the part that holds the spline and bearing, more than mg90s_shaft_len(),
spline_mate_top_dia=12;

//623 bearing
bearing_len=4;
bearing_od=10;
bearing_id=3;
bearing_bolt_len = 12 +1; // the bolt through the bearing in the tail of the finger servo, needs to be bearing + servo spline length for assembly + length to self-tap
M3_self_tap_dia = 2.5;
// plenty of space around 3-pin header
servo_connector_box = (2.54*[1,3]) + [1,1];


//a parameter describing the total width of servo and tail bolt
function servo_body_length() = (mg90s_shaft_pos()[2] - mg90s_base_pos()[2]);

function joint_int_width() = servo_body_length() + (bearing_bolt_len - bearing_len);    // could add clearance here to avoid crushing the servo with the tail bolt
function joint_width() = joint_int_width() + 2*spline_mate_len; //total width of the printed joint

function joint_body_width() = joint_int_width() - 2*mg90s_shaft_len();    // clearance to insert the shaft at the tail side, mirrored on the shaft side

function finger_tail_bolt_len() = 3;

module bearing(od1=10, od2=8.2, id1=3, id2=4.8, l=4, negative=false){
    if(!negative){
        translate([0,0,l/2]){
            color("gray")difference(){
                cylinder(d=od1,h=l,center=true);
                cylinder(d=od2,h=l+0.1,center=true);
            }
            difference(){
                union(){
                    color("lightgray")cylinder(d=od2,h=l*0.8,center=true);
                    color("gray")cylinder(d=id2,h=l,center=true);
                }
                color("gray")cylinder(d=id1,h=l+0.1,center=true);
            }
        }
    }
    if(negative){
        translate([0,0,l/2]){
            cylinder(d=od1,h=l+0.1,center=true);
            cylinder(d=od2,h=l+1,center=true);
        }
    }
}

module palm_bearing_pos(knuckle_motor_pos, knuckle_range){
// XXX no bearings in palm
}

module palm_part(knuckle_motor_pos, knuckle_range){
    difference()
    {
        union(){
            for(i=[0:len(knuckle_motor_pos)-1])let(mot=knuckle_motor_pos[i]){
                hull(){
                    translate(mot[0])  rotate(mot[1]) translate(-mg90s_body_center_pos()){
                        // house body of servo
                        translate(mg90s_base_pos()-[0,0,servo_tail_thickness+rear_flange+rear_flange_bush+2*mg90s_shaft_len()])
                            linear_extrude(height=servo_tail_thickness+rear_flange+rear_flange_bush+2*mg90s_shaft_len() + mg90s_bolt_top_pos()[0][2]-mg90s_base_center_pos()[2])
                                mg90s_section(use_hull=true,clearance=5);
                        // servo anchor points
                        translate([0,0,mg90s_bolt_bottom_pos()[0][2]-servo_bolt_depth])
                            linear_extrude(height=servo_bolt_depth)
                                mg90s_section(slice_height = mg90s_bolt_bottom_pos()[0][2], use_hull=true);
                    }
                    translate(wrist_pos)cylinder(d=wrist_dia); // extend hull into arm
                }
            }
            //hull(){
            //    translate(wrist_pos)cylinder(d=wrist_dia); // extend hull into arm
            //    translate(arm_pos)cylinder(d=50); // extend hull into arm
            //}
        }

        color("red")union(){
            // palm negative space
            for(i=[0:len(knuckle_motor_pos)-1])let(mot=knuckle_motor_pos[i]){
                translate(mot[0]) rotate(mot[1]) translate(-mg90s_body_center_pos()){

                    //mg90s();
                    translate(mg90s_base_pos()) linear_extrude(height=40) mg90s_section();
                    translate([0,0,mg90s_bolt_bottom_pos()[0][2]])
                        linear_extrude(height=40)
                            mg90s_section(slice_height = mg90s_bolt_bottom_pos()[0][2], use_hull=true);
                    mg90s_wire_channel(wrap_under=true);


                    //bolts for the mg90s
                    translate([0,0,-servo_bolt_depth]){
                        translate(mg90s_bolt_top_pos()[0])cylinder(d=servo_bolt_dia, h=servo_bolt_depth);
                        translate(mg90s_bolt_top_pos()[1])cylinder(d=servo_bolt_dia, h=servo_bolt_depth);
                    }

                    // clearance for knuckle tail shafts
                    translate(mg90s_base_pos()+[mg90s_shaft_pos()[0],0,0]) {
                        // shaft proper
                        translate([0,0,-(servo_tail_thickness + rear_flange+rear_flange_bush + 2*mg90s_shaft_len())]){
                            //shaft as required
                            cylinder(d=servo_tail_shaft_dia_int,h=rear_flange+rear_flange_bush + 2*mg90s_shaft_len());
                            //shaft extended to allow cleaning the print
                            cylinder(d=servo_tail_shaft_dia_int,h=30+rear_flange+rear_flange_bush + 2*mg90s_shaft_len());
                        }
                        // rocking clearance
                        hull(){
                            translate([0,0,-(servo_tail_thickness + rear_flange + rear_flange_bush + mg90s_shaft_len())])
                                cylinder(d=servo_tail_shaft_dia_shank_int,h=rear_flange +rear_flange_bush + mg90s_shaft_len());
                            for(a=knuckle_range[i]) rotate(v=[0,0,1],a=a)
                                translate([15,0,-(servo_tail_thickness + rear_flange + rear_flange_bush + mg90s_shaft_len())])
                                    cylinder(d=16,h=rear_flange + rear_flange_bush + mg90s_shaft_len());
                        }

                    }

                
                    //extra clearance
                    //etc
                }
            }
            //cavity joining motor bases
            for(mot=knuckle_motor_pos){
                //knuckle motor wires
                hull(){
                    translate(mot[0]) rotate(mot[1]) translate(-mg90s_body_center_pos()){
                        translate(mg90s_base_center_pos()+[-5,0,0]){
                            //linear_extrude(height=1)square([10,10], center=true);
                            linear_extrude(height=1)rotate(45)square([7,7], center=true);
                        }
                    }
                    // XXX duplicated cylinder
                    translate(wrist_pos)cylinder(d=40); // extend hull into arm
                }
                //finger and claw wires
                hull(){
                    translate(mot[0]) rotate(mot[1]) translate(-mg90s_body_center_pos()){
                        translate([-19+mg90s_body_center_pos()[0],0,(mg90s_bolt_top_pos()[0])[2]]){
                            rotate([90,0,0])cylinder(d=4, h=8, center=true);
                        }
                    }
                    // XXX duplicated cylinder
                    translate(wrist_pos)cylinder(d=20); // extend hull into arm
                }
            }
            //hull(){
            //    // XXX duplicated cylinder
            //    translate(wrist_pos)cylinder(d=30); // extend hull into arm
            //    translate(arm_pos + [0,0,-1])cylinder(d=30); // extend hull into arm
            //}
        }
    }
}

module knuckle_bearing_pos(i, finger_motor_pos, knuckle_range){
    translate(finger_motor_pos[i][0]) rotate(finger_motor_pos[i][1])
        translate([0,0,-joint_int_width()/2])
            translate([0,0,-bearing_len])
                children();
}

module knuckle_tail_arch(){
    translate(-mg90s_shaft_pos()+mg90s_base_pos()) {
        let(rad=8)
            translate([20-rad,0,-(servo_tail_thickness + rear_flange+mg90s_shaft_len()-rad)])
                rotate([-90,0,0])
                    linear_extrude(height=servo_tail_shaft_dia_shank, center=true)
                        intersection(){
                            circle(r=rad);
                            square([rad,rad]);
                        }
    }
}

module knuckle_part(i, finger_motor_pos, knuckle_range){

    knuckle_origin = [0,0,0]; //XXX unused
    knuckle_shaft_pos = knuckle_origin;
    finger_origin = knuckle_origin + finger_motor_pos[i][0];

    difference(){
        union(){
            // knuckle parts
            hull(){
                // mate to knuckle spline
                cylinder(d1=spline_mate_dia, d2=spline_mate_top_dia, h=spline_mate_len);
                // mate to finger spline and bearing
                translate(finger_origin) rotate(finger_motor_pos[i][1]){
                    cylinder(d=spline_mate_dia, h=joint_int_width(),center=true);
                    cylinder(d=spline_mate_top_dia, h=joint_width(),center=true);
                }
                // wide span over the servo horn
                translate([spline_mate_dia, 10,0]) cylinder(d=10,h=3);
                translate([spline_mate_dia,-10,0]) cylinder(d=10,h=3);
                //reach down to second shaft
                knuckle_tail_arch();
            }
            // join arch to tail shaft
            hull(){
                translate(-mg90s_shaft_pos()+mg90s_base_pos()) 
                    translate([0,0,-(servo_tail_thickness + rear_flange + mg90s_shaft_len())])
                        cylinder(d=servo_tail_shaft_dia_shank,h=rear_flange);
                knuckle_tail_arch();
            }
            //tail shaft into palm
            translate(-mg90s_shaft_pos()+mg90s_base_pos())
                translate([0,0,-(servo_tail_thickness + rear_flange+rear_flange_bush + mg90s_shaft_len())]){
                    cylinder(d=servo_tail_shaft_dia_shank,h= rear_flange+rear_flange_bush);
                    translate([0,0,-mg90s_shaft_len()])
                        cylinder(d=servo_tail_shaft_dia,h=mg90s_shaft_len()+ rear_flange+rear_flange_bush);
                }
        }
        // knuckle negative space
        union(){
            // mate to knuckle servo spline
            translate([0,0,bolt_len])cylinder(d=7, h=bolt_head_len);//through-bolt head for spline
            cylinder(d=mg90s_shaft_bolt_dia(), h=bolt_len+bolt_head_len);//through-bolt for spline
            spline_shaft();

            // palm motor negative space
            for(a=knuckle_range[i]) rotate(v=[0,0,1],a=a){
                let(
                    clear_len = mg90s_shaft_len() + mg90s_shaft_pos()[2]-mg90s_base_pos()[2] + servo_tail_thickness,
                    rad=mg90s_shaft_len()
                ) translate([0,0,-clear_len/2]) 
                    rotate([90,0,0])linear_extrude(height=1000, center=true)hull()for(x=[-1,1])for(y=[-1,1])
                        translate([x*(13-rad), y*(clear_len/2-rad)])
                            circle(r=rad);
                    
            }
            translate(finger_motor_pos[i][0]) rotate(finger_motor_pos[i][1]){
                // mate to finger servo spline
                translate([0,0,joint_int_width()/2]){
                    spline_shaft();
                    translate([0,0,bolt_len])cylinder(d=7, h=bolt_head_len);//through-bolt head for spline
                    cylinder(d=mg90s_shaft_bolt_dia(), h=bolt_len+bolt_head_len);//through-bolt for spline
                }

                // clearance for finger servo body
                hull() {
                    cylinder(d=motor_socket_clear_dia_neck,h=joint_int_width(), center=true);
                    cylinder(d=motor_socket_clear_dia,h=joint_int_width()-10, center=true);
                }
                // space for bearing
                translate([0,0,-joint_int_width()/2]){
                    translate([0,0,-bearing_len])bearing(negative=true);
                    translate([0,0,-bearing_bolt_len - bearing_len])cylinder(d=8.2, h=bearing_bolt_len);    //8.2 should come from bearing module
                }
            }
        }
    }
}
function claw_tail_bolt_len() = 3;

module finger_bearing_pos(i, claw_motor_pos){
    finger_origin = [0,0,0];
    claw_origin = finger_origin + claw_motor_pos[i][0];
    claw_tail_pos = claw_origin - [0,0,joint_int_width()/2];
    translate(claw_origin) rotate(claw_motor_pos[i][1])
        translate([0,0,-joint_int_width()/2])
            translate([0,0,-bearing_len])
                children();

}

module finger_part(i, claw_motor_pos){
    
    finger_origin = [0,0,0];
    finger_shaft_pos = finger_origin + [0,0,joint_int_width()/2];
    finger_tail_pos = finger_origin - [0,0,joint_int_width()/2];
    
    claw_origin = finger_origin + claw_motor_pos[i][0];

    difference(){
        union(){
            //finger parts
            hull(){
                //fill the knuckle socket and enclose the motor
                translate(finger_origin)
                    linear_extrude(height=joint_body_width(), center=true){
                        mg90s_section(clearance=2);
                        circle(d=motor_socket_dia);
                    }
                //accept the servo spline and bearing
                translate(claw_origin) rotate(claw_motor_pos[i][1]){
                    cylinder(d=spline_mate_dia, h=joint_int_width(),center=true);
                    cylinder(d=spline_mate_top_dia, h=joint_width(),center=true);
                }
            }
        }
        //finger negative space
        union(){
            // mounting space for finger servo motor
            translate(finger_shaft_pos - mg90s_shaft_pos()){  //get into mg90s coords
                translate(mg90s_base_pos())
                    linear_extrude(height=40)
                        mg90s_section();
                translate([0,0,mg90s_bolt_bottom_pos()[0][2]])
                    linear_extrude(height=40)
                        mg90s_section(slice_height = mg90s_bolt_bottom_pos()[0][2], use_hull=true);
                for(screw_pos=mg90s_bolt_top_pos())
                    translate(screw_pos)
                        translate([0,0,-servo_bolt_depth])
                            cylinder(d=servo_bolt_dia, h=servo_bolt_depth);
                
                //#mg90s();
                //wire channel
                mg90s_wire_channel(wrap_under=false);
            }
            translate(finger_origin){
                //servo connector exit
                rotate([0,90,0])linear_extrude(height=20)square(servo_connector_box, center=true);
                slot_depth = 2;
                slot_width = mg90s_wire_width();
                //wire channel over outside
                linear_extrude(height=slot_width, center=true){
                    difference(){
                        intersection(){
                            circle(d=motor_socket_dia+5);
                            translate([-slot_depth,-motor_socket_dia,-slot_width/2])square([motor_socket_dia, motor_socket_dia]);
                        }
                        translate([-slot_depth,0,0])circle(d=motor_socket_dia);
                    }
                }
            }
            //finger motor tail bolt
            translate(finger_origin + [0,0,mg90s_base_pos()[2]-finger_tail_bolt_len()]) cylinder(h=finger_tail_bolt_len(),d=2.5);
            //finger_bolt spacer slides in from underside
            hull(){
                translate(finger_origin + [   0,0,mg90s_base_pos()[2]-finger_tail_bolt_len()-mg90s_shaft_len()]) cylinder(h=mg90s_shaft_len(),d=spline_mate_dia+0.5);
                translate(finger_origin + [motor_socket_dia/2,0,mg90s_base_pos()[2]-finger_tail_bolt_len()-mg90s_shaft_len()]) cylinder(h=mg90s_shaft_len(),d=spline_mate_dia+0.5);
            }
            translate(claw_origin) rotate(claw_motor_pos[i][1]){
                // mate to claw servo spline
                translate([0,0,joint_int_width()/2]){
                    spline_shaft();
                    cylinder(d=mg90s_shaft_bolt_dia(), h=bolt_len+bolt_head_len);//through-bolt for spline
                    translate([0,0,bolt_len])cylinder(d=7, h=bolt_head_len);//through-bolt head for spline
                }
                // clearance for claw servo body
                hull(){
                    cylinder(d=motor_socket_clear_dia_neck, h=joint_int_width(),center=true);
                    cylinder(d=motor_socket_clear_dia, h=joint_int_width()-10,center=true);
                }
                // bearing
                translate([0,0,-joint_int_width()/2]){
                    translate([0,0,-bearing_len])bearing(negative=true);
                    translate([0,0,-bearing_bolt_len - bearing_len])cylinder(d=8.2, h=bearing_bolt_len);    //8.2 should come from bearing module
                }
            }
        }
    }
}


module claw_part(i, claw_point_pos){
    
    claw_origin = [0,0,0];
    claw_shaft_pos = claw_origin + [0,0,joint_int_width()/2];
    claw_tail_pos = claw_origin - [0,0,joint_int_width()/2];
    
    difference(){
        union(){
            hull(){
                color("red")translate(claw_point_pos[i][0])sphere(r=1);
                //wrap servo body
                translate(claw_origin)
                    linear_extrude(height=joint_body_width(), center=true){
                        mg90s_section(clearance=2);
                        circle(d=motor_socket_dia);
                    }
            }
            // servo anchor points
            translate(
                claw_shaft_pos - mg90s_shaft_pos() +
                [0,0,mg90s_bolt_bottom_pos()[0][2]] + //to the bottom of the wings
                [0,0,-servo_bolt_depth] //to the bottom of the extrusion
            ){
                linear_extrude(height=servo_bolt_depth)
                    mg90s_section(slice_height = mg90s_bolt_bottom_pos()[0][2], use_hull=true);
            }
        }

        union(){
            //claw negative space
            translate(claw_shaft_pos - mg90s_shaft_pos()){  //get into mg90s coords
                // servo body
                translate(mg90s_base_pos())
                    linear_extrude(height=40)
                        mg90s_section();
                // servo wings
                translate([0,0,mg90s_bolt_bottom_pos()[0][2]])
                    linear_extrude(height=40)
                        mg90s_section(slice_height = mg90s_bolt_bottom_pos()[0][2], use_hull=true);
                //mounting bolts (treating servo_bolt_depth as bolt length)
                for(screw_pos=mg90s_bolt_top_pos())
                    translate(screw_pos)
                        translate([0,0,-servo_bolt_depth])
                            cylinder(d=servo_bolt_dia, h=servo_bolt_depth);
                //#mg90s();
                //wire channel
                mg90s_wire_channel(wrap_under=false);
            }
            translate(claw_origin){
                //servo connector exit
                rotate([0,90,0])linear_extrude(height=20)square(servo_connector_box, center=true);
                slot_depth = 2;
                slot_width = mg90s_wire_width();
                //wire channel over outside
                linear_extrude(height=slot_width, center=true){
                    difference(){
                        intersection(){
                            circle(d=motor_socket_dia+5);
                            translate([-slot_depth,-motor_socket_dia,-slot_width/2])square([motor_socket_dia, motor_socket_dia]);
                        }
                        translate([-slot_depth,0,0])circle(d=motor_socket_dia);
                    }
                }
            }
            //tail spacer and assembly clearance
            translate(claw_tail_pos) {
                translate([0,0,-bearing_len]){
                    cylinder(h=bearing_bolt_len, d=M3_self_tap_dia);
                }
                hull(){ // XXX maybe create an assembly clearance function that takes a path as an arg
                    cylinder(h=mg90s_shaft_len(),d=spline_mate_dia+0.5);
                    translate([motor_socket_dia/2,0,0]) cylinder(h=mg90s_shaft_len(),d=spline_mate_dia+0.5);
                }
            }
        }
    }
}

module tail_spacer(clearance = 0.2){
    difference(){
        union(){
            cone_len=1;
            translate([0,0,bearing_len])cylinder(h=cone_len,d1=5,d2=spline_mate_dia-clearance);
            translate([0,0,bearing_len +cone_len])cylinder(h=mg90s_shaft_len()-cone_len-clearance/2,d=spline_mate_dia-clearance);
        }
        union(){
            cylinder(d=3.2, h=bearing_len+mg90s_shaft_len()+0.1);
        }

    }
}