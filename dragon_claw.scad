use <mg90s.scad>
use <printed_parts.scad>
use <forward_kinematics.scad>
use <scad-utils/transformations.scad>
use <scad-utils/spline.scad>


$fs=0.2;
$fa=1;

//number of claws
n_claws = 5;



//positions and orientations of the knuckle motor bodies relative to the palm origin
knuckle_motor_pos = [
    [[34.6192, -62.6912, 7.09054], [0, -65, 110]],
    [[63.9572, 16.5083, 4.56162], [0, -75, 205]],
    [[25.934, 51.3037, -4.75], [0, -90, 250]],
    [[-25.5321, 50.1993, 3.18304], [0, -80, 290]],
    [[-62.2403, 10.7078, 12.0905], [0, -65, 335]]
    ];

//range of the knuckle motors
knuckle_motor_range=[
    [-30,30],
    [-30,30],
    [-30,30],
    [-30,30],
    [-30,30],
];

//positions and orientations of the finger motor axis relative to the respective knuckle motor shaft
finger_motor_pos = [
    [[15,0,20],[90,130,0]],
    [[10,0,26],[90,130,0]],
    [[10,0,26],[90,130,0]],
    [[10,0,26],[90,130,0]],
    [[10,0,26],[90,130,0]],
];

//positions and orientations of the claw motor axis relative to the respective finger motor axis
claw_motor_pos = [
    [[-43.25,10,0],[0,0,-50]],
    [[-41.25,10,0],[0,0,-50]],
    [[-45.25,10,0],[0,0,-50]],
    [[-41.25,10,0],[0,0,-50]],
    [[-37.25,10,0],[0,0,-50]],
];

//positions of the claw points relative to the claw motor axis
claw_point_pos = [
    [[-47.25,10,0],[0,0,0]],
    [[-55.25,10,0],[0,0,0]],
    [[-60.25,10,0],[0,0,0]],
    [[-55.25,10,0],[0,0,0]],
    [[-50.25,10,0],[0,0,0]],
];


for(i=[0:n_claws-1]){
    echo([0,0,0] + 
        translation(knuckle_motor_pos[i][0]) *
        rotation(knuckle_motor_pos[i][1]) *
        translation(-mg90s_body_center_pos()) *
        [0,0,0,1]
    );
}


module assembly(pose = [[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]]){
    palm_part(knuckle_motor_pos,knuckle_motor_range);
    for(i=[0:n_claws-1]){
        translate(knuckle_motor_pos[i][0]) rotate(knuckle_motor_pos[i][1]){
            // origin is knuckle motor origin
            color("gray")mg90s(a=pose[i][0]);    //knuckle motor
            translate(mg90s_shaft_pos()) rotate(v=mg90s_shaft_axis(), a=pose[i][0]){
                // origin is knuckle shaft
                knuckle_bearing_pos(i, finger_motor_pos,knuckle_motor_range){
                    bearing();
                    tail_spacer();
                }
                knuckle_part(i, finger_motor_pos,knuckle_motor_range);  // knuckle bracket
                translate(finger_motor_pos[i][0]) rotate(finger_motor_pos[i][1]){
                    // origin is finger axis
                    rotate(v=-mg90s_shaft_axis(), a=pose[i][1]) {
                        // origin is finger origin
                        color("gray")translate([0,0,joint_int_width()/2]) translate(-mg90s_shaft_pos()) mg90s(a=pose[i][1]);    //finger motor
                        finger_part(i, claw_motor_pos); //finger shroud
                        finger_bearing_pos(i, claw_motor_pos){
                            bearing();
                            tail_spacer();
                        }
                        translate(claw_motor_pos[i][0]) rotate(claw_motor_pos[i][1]){
                            // origin is claw shaft
                            rotate(v=-mg90s_shaft_axis(), a=pose[i][2]){
                                // origin is claw motor
                                color("gray")translate([0,0,joint_int_width()/2]) translate(-mg90s_shaft_pos()) mg90s(a=pose[i][2]);  //claw motor
                                claw_part(i, claw_point_pos);   //pointy bit
                                translate(claw_point_pos[i][0])  rotate(claw_point_pos[i][1]){
                                    // the end of the kinematic chain
                                    color("red") sphere(r=3);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}





module fk_native(
    i,
    pose
){
    translate(knuckle_motor_pos[i][0])
    rotate(knuckle_motor_pos[i][1])
    translate(mg90s_shaft_pos())
    rotate(v=mg90s_shaft_axis(), a=pose[0])
    translate(finger_motor_pos[i][0])
    rotate(finger_motor_pos[i][1])
    rotate(v=-mg90s_shaft_axis(), a=pose[1])
    translate(claw_motor_pos[i][0])
    rotate(claw_motor_pos[i][1])
    rotate(v=-mg90s_shaft_axis(), a=pose[2])
    translate(claw_point_pos[i][0])
    rotate(claw_point_pos[i][1])
    children();
}


module fk_native_marker( i=0,
    pose = [0,0,0]){
    fk_native(
        i,
        pose
        )sphere(d=5);
}




// describe the kinematic chain for each finger as 4x4 transformation matrices and rotation axis vectors for each motor
function claw_kinematic_chains() = [ for(i=[0:n_claws-1])
    [
        //links
        [
            translation(knuckle_motor_pos[i][0]) *
            rotation(knuckle_motor_pos[i][1]),
            //rotation with pose[0] gets inserted here
            translation(finger_motor_pos[i][0])*
            rotation(finger_motor_pos[i][1]),
            //rotation with pose[1] gets inserted here
            translation(claw_motor_pos[i][0]) *
            rotation(claw_motor_pos[i][1]) ,
            //rotation with pose[2] gets inserted here
            translation(claw_point_pos[i][0]) *
            rotation(claw_point_pos[i][1])
        ],
        //axes
        [
            mg90s_shaft_axis(),  //axis for pose[0]
            -mg90s_shaft_axis(), //axis for pose[1]
            -mg90s_shaft_axis(), //axis for pose[2]
        ]
    ]
];


//layout of components
module layout(){
    palm_part(knuckle_motor_pos,knuckle_motor_range);
    for(i=[0:n_claws-1]) translate([-100, 50 *i,0]) {
        knuckle_part(i, finger_motor_pos,knuckle_motor_range);
        //%translate(-mg90s_shaft_pos())mg90s();
    }
    for(i=[0:n_claws-1]) translate([-150, 50 *i,finger_tail_bolt_len()/2]){
        finger_part(i, claw_motor_pos);
        //%mg90s();
    }

    for(i=[0:n_claws-1]) translate([-250, 50 *i,finger_tail_bolt_len()/2]){
        claw_part(i, claw_point_pos);
        //%mg90s();
    }

}

//render()layout();
assembly([[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]]);
//mg90s();
//mg90s_wire_channel();

//palm_part(knuckle_motor_pos,knuckle_motor_range);
i=0;
//knuckle_part(i, finger_motor_pos,knuckle_motor_range);
//finger_part(i, claw_motor_pos);
//claw_part(i, claw_point_pos);

//tail_spacer();


//check for collisions
/*
intersection(){
    i=1;
    pose = [[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]];
    //finger_part(i, claw_motor_pos); //finger shroud
    finger_bearing_pos(i, claw_motor_pos){
        //bearing();
        tail_spacer();
    }
    translate(claw_motor_pos[i][0]) rotate(claw_motor_pos[i][1]){
        // origin is claw shaft
        rotate(v=-mg90s_shaft_axis(), a=pose[i][2]) translate(-mg90s_shaft_pos()) {
            // origin is claw motor
            //color("gray")mg90s(a=pose[i][2]);  //claw motor
            claw_part(i, claw_point_pos);   //pointy bit
        }
    }
}
*/