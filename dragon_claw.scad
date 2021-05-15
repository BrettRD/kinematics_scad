use <mg90s.scad>
use <printed_parts.scad>
use <forward_kinematics.scad>
use <scad-utils/transformations.scad>
use <scad-utils/spline.scad>


n_claws = 5;





shaft_comp=mg90s_shaft_pos()[2];


//positions and orientations of the knuckle motors relative to the palm origin
knuckle_motor_pos = [
    [[ 30,-50,-5], [0, -65, 110]],
    [[ 50, 10,-5], [0, -75, 205]],
    [[ 20, 35,-10], [0, -90, 250]],
    [[-20, 35,-5], [0, -80, 290]],
    [[-50, 5, 0], [0, -65, 335]]
    ];

knuckle_motor_range=[
    [-12,45],
    [-30,30],
    [-30,30],
    [-30,30],
    [-30,30],
];

//positions and orientations of the finger motor shaft relative to the respective knuckle motor shaft

finger_motor_pos = [
    [[15,-shaft_comp,20],[90,130,0]],
    [[10,-shaft_comp,26],[90,130,0]],
    [[10,-shaft_comp,26],[90,130,0]],
    [[10,-shaft_comp,26],[90,130,0]],
    [[10,-shaft_comp,26],[90,130,0]],
];

claw_motor_pos = [
    [[-38,10,shaft_comp],[0,0,-50]],
    [[-36,10,shaft_comp],[0,0,-50]],
    [[-40,10,shaft_comp],[0,0,-50]],
    [[-36,10,shaft_comp],[0,0,-50]],
    [[-32,10,shaft_comp],[0,0,-50]],
];

claw_point_pos = [
    [[-42,10,0],[0,0,0]],
    [[-50,10,0],[0,0,0]],
    [[-55,10,0],[0,0,0]],
    [[-50,10,0],[0,0,0]],
    [[-45,10,0],[0,0,0]],
];

module assembly(pose = [[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]]){
    palm_part(knuckle_motor_pos,knuckle_motor_range);
    for(i=[0:n_claws-1]){
        translate(knuckle_motor_pos[i][0]) rotate(knuckle_motor_pos[i][1]) {
            // origin is knuckle motor
            color("gray")mg90s(a=pose[i][0]);    //knuckle motor
            translate(mg90s_shaft_pos()) rotate(v=mg90s_shaft_axis(), a=pose[i][0]){
                // origin is knuckle shaft
                knuckle_part(i, finger_motor_pos,knuckle_motor_range);  // knuckle bracket
                translate(finger_motor_pos[i][0]) rotate(finger_motor_pos[i][1]){
                    // origin is finger shaft
                    rotate(v=-mg90s_shaft_axis(), a=pose[i][1]) translate(-mg90s_shaft_pos()) {
                        // origin is finger motor
                        color("gray")mg90s(a=pose[i][1]);    //finger motor
                        finger_part(i, claw_motor_pos); //finger shroud
                        translate(claw_motor_pos[i][0]) rotate(claw_motor_pos[i][1]){
                            // origin is claw shaft
                            rotate(v=-mg90s_shaft_axis(), a=pose[i][2]) translate(-mg90s_shaft_pos()) {
                                // origin is claw motor
                                color("gray")mg90s(a=pose[i][2]);  //claw motor
                                claw_part(i, claw_point_pos);   //pointy bit
                                translate(claw_point_pos[1][0])  rotate(claw_point_pos[1][1]){
                                    // the end of the kinematic chain
                                    //color("red") sphere(r=3);
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
    translate(-mg90s_shaft_pos())
    translate(claw_motor_pos[i][0])
    rotate(claw_motor_pos[i][1])
    rotate(v=-mg90s_shaft_axis(), a=pose[2])
    translate(-mg90s_shaft_pos())
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
            rotation(knuckle_motor_pos[i][1]) *
            translation(mg90s_shaft_pos()),
            //rotation with pose[0] gets inserted here
            translation(finger_motor_pos[i][0])*
            rotation(finger_motor_pos[i][1]),
            //rotation with pose[1] gets inserted here
            translation(-mg90s_shaft_pos()) *
            translation(claw_motor_pos[i][0]) *
            rotation(claw_motor_pos[i][1]) ,
            //rotation with pose[2] gets inserted here
            translation(-mg90s_shaft_pos()) *
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




assembly([[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]]);
//mg90s();
//mg90s_wire_channel();

/*
for(i=[0:n_claws-1]) translate([-100, 50 *i,0]) {
    knuckle_part(i, finger_motor_pos);
    translate(-mg90s_shaft_pos())%mg90s();
}
*/
/*
//layout of components
palm_part(knuckle_motor_pos);
for(i=[0:n_claws-1]) translate([-150, 50 *i,0]) finger_part(i, claw_motor_pos);
for(i=[0:n_claws-1]) translate([-250, 50 *i,0]) claw_part(i);
*/

