use <scad-utils/se3.scad>
use <scad-utils/linalg.scad>
use <scad-utils/lists.scad>
use <scad-utils/transformations.scad>

use <mg90s.scad>


function forward_kinematics_linalg_mat( FKl, M = identity4()) = len(FKl) == 0 ? M : forward_kinematics_linalg_mat(remove(FKl,0), M*FKl[0]);


