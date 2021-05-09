use <scad-utils/se3.scad>
use <scad-utils/linalg.scad>
use <scad-utils/lists.scad>
use <scad-utils/transformations.scad>
use <scad-utils/spline.scad>


// This kinematics system is for series kinematic linkages
// most functions deal with a structure called "chain" which is of the form [[n+1 links],[n axes]]
// links provide a transform in a 4-matrix format like translation([x,y,z]) from scad-utils/transformations.scad
// axes provide a 3-vector describing the axis of the motor in the local origin of the chain up to that point. (usually just [0,0,1])
// links[0] gets from the global origin to the first axis, the frame links[1] builds from gets rotated around axis[0].


function identity(n) = [for(i=[0:n-1]) [for(j=[0:n-1]) i==j?1:0 ]];
function zip(a,b, i=0, out=[]) = i>=len(a) ? out : i>=len(b) ? out : zip(a,b,i=i+1, out=concat(out, [a[i],b[i]]));

// insert the motor poses into the kinematic chain
function fk_linalg_list(chain, pose) =
assert(pose!=undef)
assert(len(chain[0]) == 1+len(chain[1]) )
let(
    links = chain[0],
    axes = chain[1],
    n_axes = len(axes),
    axes_tf = [for(i=[0:n_axes-1]) rotation(axis = axes[i] * pose[i])]
) concat( zip(links, axes_tf) , [links[n_axes]]);

// convert kinematic chains down to a single transformation matrix
function fk_flatten_chain( FKl, M = identity4()) = len(FKl) == 0 ? M : fk_flatten_chain(remove(FKl,0), M*FKl[0]);

//return a transformation matrix describing the whole kinematic chain in a given pose
function fk_linalg_mat(chain,pose) =
fk_flatten_chain(
    fk_linalg_list(
        chain,
        pose
    )
);

// return a 3-vector at the end of the kinematic chain
function fk_linalg_point(
    chain,
    pose
) = transform(
    fk_linalg_mat(
        chain,
        pose
    ),
    [[0,0,0]]
)[0];

//draw a sphere at the end of the kinematic chain.
module fk_linalg_marker(chain,
    pose = [0,0,0]){
    translate(
        fk_linalg_point(
            chain,
            pose
        )
    ) sphere(d=5);
}

// numerically compute the jacobian of the kinematic chain.
function fk_jacobian (chain, delta, pose) = let(n_axes = len(chain[1])) [
    for(d = identity(n_axes))
    (fk_linalg_point(chain, pose + delta*d) - 
    fk_linalg_point(chain, pose )) / delta
];



// perform a simple gradient descent search to solve inverse kinematics based on location only.
// XXX this will not solve for end-effector orientation
function ik_search(chain, dst, step=0.8, margin=0.1, recursion_limit=20, pose) =
    recursion_limit == 0 ?
        echo("ik recursion limit reached")
        pose :
        let(
            err =  dst-fk_linalg_point(chain, pose) ,
            dir =  err*matrix_invert(fk_jacobian(chain,0.1, pose)),
            next_pose = pose + step*dir
        ) norm(err) < margin ?
            next_pose :
            ik_search(chain=chain, dst=dst, step=step, margin=margin, recursion_limit=recursion_limit-1, pose=next_pose);


