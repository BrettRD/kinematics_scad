use <mg90s.scad>
use <printed_parts.scad>
use <forward_kinematics.scad>
use <scad-utils/transformations.scad>
use <scad-utils/spline.scad>


n_claws = 5;





shaft_comp=mg90s_shaft_pos()[2];


//positions and orientations of the knuckle motors relative to the palm origin
knuckle_motor_pos = [
    [[-10,-35,0], [90, -90, -10]],
    [[ 40, 10,0], [90, -90, 115]],
    [[ 20, 35,0], [90, -90, 160]],
    [[-20, 35,0], [90, -90, 200]],
    [[-40, 10,0], [90, -90, 245]]
    ];


//positions and orientations of the finger motor shaft relative to the respective knuckle motor shaft

finger_motor_pos = [
    [[0,-shaft_comp,20],[90,140,0]],
    [[0,-shaft_comp,20],[90,140,0]],
    [[0,-shaft_comp,20],[90,140,0]],
    [[0,-shaft_comp,20],[90,140,0]],
    [[0,-shaft_comp,20],[90,140,0]],
];

claw_motor_pos = [
    [[-40,0,shaft_comp],[0,0,-60]],
    [[-40,0,shaft_comp],[0,0,-60]],
    [[-40,0,shaft_comp],[0,0,-60]],
    [[-40,0,shaft_comp],[0,0,-60]],
    [[-40,0,shaft_comp],[0,0,-60]],
];

claw_point_pos = [
    [[-60,0,0],[0,0,0]],
    [[-60,0,0],[0,0,0]],
    [[-60,0,0],[0,0,0]],
    [[-60,0,0],[0,0,0]],
    [[-60,0,0],[0,0,0]],
];

module assembly(pose = [[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]]){
    palm_part(knuckle_motor_pos);
    for(i=[0:n_claws-1]){
        translate(knuckle_motor_pos[i][0]) rotate(knuckle_motor_pos[i][1]) {
            // origin is knuckle motor
            mg90s(a=pose[i][0]);    //knuckle motor
            translate(mg90s_shaft_pos()) rotate(v=mg90s_shaft_axis(), a=pose[i][0]){
                // origin is knuckle shaft
                knuckle_part(i, finger_motor_pos);  // knuckle bracket
                translate(finger_motor_pos[i][0]) rotate(finger_motor_pos[i][1]){
                    // origin is finger shaft
                    rotate(v=-mg90s_shaft_axis(), a=pose[i][1]) translate(-mg90s_shaft_pos()) {
                        // origin is finger motor
                        mg90s(a=pose[i][1]);    //finger motor
                        finger_part(i, claw_motor_pos); //finger shroud
                        translate(claw_motor_pos[i][0]) rotate(claw_motor_pos[i][1]){
                            // origin is claw shaft
                            rotate(v=-mg90s_shaft_axis(), a=pose[i][2]) translate(-mg90s_shaft_pos()) {
                                // origin is claw motor
                                mg90s(a=pose[i][2]);  //claw motor
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





function claw_kinematic_chains() = [ for(i=[0:n_claws-1])
    [
        //links
        [
            translation(knuckle_motor_pos[i][0]) *
            rotation(knuckle_motor_pos[i][1]) *
            translation(mg90s_shaft_pos()),
            //rotation with pose[0]
            translation(finger_motor_pos[i][0])*
            rotation(finger_motor_pos[i][1]),
            //rotation with pose[1]
            translation(-mg90s_shaft_pos()) *
            translation(claw_motor_pos[i][0]) *
            rotation(claw_motor_pos[i][1]) ,
            //rotation with pose[2]
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


//%translate([0,0,150])sphere(r=100);



echo(fk_jacobian(chain=claw_kinematic_chains()[0], delta=0.1, pose=[0,0,0]));  //jacobian
echo(matrix_invert(fk_jacobian(chain=claw_kinematic_chains()[0], delta=0.1, pose=[0,0,0]))); //inverse jacobain
echo(fk_jacobian(chain=claw_kinematic_chains()[0], delta=0.1, pose=[0,0,0])*matrix_invert(fk_jacobian(chain=claw_kinematic_chains()[0], delta=0.1, pose=[0,0,0]))); //identity


dst = [0,-50,100];
starting_pose = [0,0,0];
i=0;
//echo(ik_search(chain=claw_kinematic_chains()[i], dst=dst, pose=starting_pose));
//echo(fk_linalg_point(chain=claw_kinematic_chains()[i],ik_search(chain=claw_kinematic_chains()[i], dst=dst, pose=starting_pose)));

//fk_linalg_marker(chain=claw_kinematic_chains()[i],pose=starting_pose);
fk_linalg_marker(chain=claw_kinematic_chains()[0], pose=ik_search(chain=claw_kinematic_chains()[0], dst=dst, pose=starting_pose));
translate(dst)color("blue")sphere(d=5);


assembly([[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]]);

/*
//layout of components
palm_part(knuckle_motor_pos);
for(i=[0:n_claws-1]) translate([-100, 50 *i,0]) knuckle_part(i, finger_motor_pos);
for(i=[0:n_claws-1]) translate([-150, 50 *i,0]) finger_part(i, claw_motor_pos);
for(i=[0:n_claws-1]) translate([-250, 50 *i,0]) claw_part(i);
*/

