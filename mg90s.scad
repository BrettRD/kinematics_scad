// rough model of a MG90S servo motor with convenience functions for significant features
// XXX origin needs to move to the base of the splines on the shaft


body_dims = [22.8,12.3,22.5];
body_length = body_dims[0];
body_width = body_dims[1];
body_height = body_dims[2];


wing_dims = [32.4, body_width, 2.6];
wing_len = wing_dims[0];
wing_thick = wing_dims[2];
wing_drop = 1.5;
wing_bolt_dia = 2;
wing_bolt_spacing = 25.8 + wing_bolt_dia;
wing_split = 1;

gear_drop = 5.6;
spur_dia=6;
spur_pos= (-body_width)/2; //XXX check this


shaft_len=0.5; //blank length of shaft before the spline


wire_drop=4;    //distance from base to wire


// as measured
//mg90s_spline_r1=4.2 /2;
//mg90s_spline_r2=4.7 /2;
// as printed and tested against an actual shaft
mg90s_spline_r1 = (4.2 /2) +0.1*(1-6);
mg90s_spline_r2 = (4.7 /2) +0.1*(1+6);

mg90s_spline_n=20;
mg90s_spline_h=5;   // the length of usable spline on the shaft
//Actully M2.5, not M3 or M2.
mg90s_spline_bolt_dia = 2.5;

fudge=0.01;




function spline_list(r1=mg90s_spline_r1, r2=mg90s_spline_r2, n=mg90s_spline_n) = 
    [for(theta = [0:360/n:360]) for(p=[[r1,0],[r2,180/n]]) p[0]* [sin(theta+p[1]), cos(theta+p[1])]];

module spline_sect(r1=mg90s_spline_r1, r2=mg90s_spline_r2, n=mg90s_spline_n){
    polygon(spline_list(r1,r2,n));
}

module spline_shaft(r1=mg90s_spline_r1, r2=mg90s_spline_r2, n=mg90s_spline_n, h=mg90s_spline_h){
    translate([0,0,-fudge])linear_extrude(height = h+fudge) spline_sect(r1,r2,n);
    translate([0,0,-shaft_len])cylinder(r=r1, h=shaft_len);
}

function mg90s_wire_width() = 4;
function mg90s_wire_thickness() = 1.3;
function mg90s_wire_size(t=mg90s_wire_thickness(),w=mg90s_wire_width()) = [t, w];

function mg90s_shaft_pos() = [0,0,0];
function mg90s_shaft_axis() = [0,0,1];
function mg90s_shaft_len() = mg90s_spline_h;
function mg90s_shaft_bolt_dia(clearance = 0.2) = mg90s_spline_bolt_dia + clearance;


//the bottom of the body below the shaft
function mg90s_body_top_pos() = [0,0,-gear_drop-shaft_len];
function mg90s_base_pos() = [0,0,-body_height -gear_drop-shaft_len];
//the bottom of the body in the middle of the body
function mg90s_base_center_pos() = mg90s_base_pos() + ([body_width-body_length,0,0]/2);
function mg90s_body_center_pos() = mg90s_base_center_pos() + [0,0,body_height/2];


function mg90s_bolt_top_pos() = [for(mirr=[1,-1])
        mg90s_base_center_pos() +
        [0,0,body_height-wing_drop]+
        [(mirr * wing_bolt_spacing/2), 0,0]
    ];
function mg90s_bolt_top_angles() = [[0,0,0], [0,0,180]];
function mg90s_bolt_bottom_pos() = [for(pos = mg90s_bolt_top_pos()) pos - [0,0,wing_thick] ];
function mg90s_bolt_bottom_angles() =  [for(a = mg90s_bolt_top_angles()) [180,0,0] + a];




function mg90s_wire_pos(wire_size=mg90s_wire_size()) =
    let(
        wire_thickness = wire_size[0],
        wire_width = wire_size[1]
    )
    mg90s_base_pos() + [body_width/2 + wire_thickness/2,0, wire_drop + wire_thickness/2];

module mg90s_wire_stub(wire_size=mg90s_wire_size()){
    let(
        wire_thickness = wire_size[0],
        wire_width = wire_size[1]
    )
    translate(mg90s_wire_pos(wire_size=wire_size))cube([wire_thickness, wire_width, wire_thickness], center=true);
}

module mg90s_wire_channel(wire_size=mg90s_wire_size(), clearance=0.2, wrap_under=false){
    let(
        wire_thickness = wire_size[0],
        wire_width = wire_size[1]
    )
    minkowski(){
        sphere(r=clearance);
        union(){
            hull(){
                translate([0,0,-wire_drop])mg90s_wire_stub();
                translate([0,0,body_height - wire_drop - wire_thickness])mg90s_wire_stub();
            }
            if(wrap_under)
            {
                hull(){
                    translate([0,0,-wire_drop-wire_thickness])mg90s_wire_stub();
                    translate([-body_length,0,-wire_drop-wire_thickness])mg90s_wire_stub();
                }
            }
        }
    }
}


module mg90s(a=0){
    //gear head
    translate(mg90s_body_top_pos()){
        cylinder(d=body_width,h=gear_drop);
        translate([spur_pos,0,0])cylinder(d=spur_dia,h=gear_drop);
    }
    mg90s_wire_stub();

    difference(){
        translate(mg90s_base_center_pos()){
            translate([0,0,body_height/2])cube(body_dims, center=true);
            translate([0,0,body_height-wing_drop +(-wing_thick)/2])cube(wing_dims, center=true);
        }
        for(i=[0,1]){
            translate(mg90s_bolt_top_pos()[i])
            rotate(mg90s_bolt_top_angles()[i]){
                cylinder(d=wing_bolt_dia, h=wing_thick*3, center=true);
                translate([(wing_len-wing_bolt_spacing)/4,0,0]) cube([(wing_len-wing_bolt_spacing)/2, wing_split, wing_thick*3], center=true);
            }
        }
    }

    translate(mg90s_shaft_pos()) rotate(mg90s_shaft_axis()) rotate([0,0,a]) spline_shaft();
}


// use with slice_height = -mg90s_wire_pos()[2] to include wire
module mg90s_section(clearance=0.1, slice_height=-body_height/2, use_hull=false) {
    offset(r=clearance){
        if(use_hull){
            hull()projection(cut=true){
                translate([0,0,-slice_height])
                mg90s();
            }
        }
        if(!use_hull){
            projection(cut=true){
                translate([0,0,-slice_height])
                mg90s();
            }
        }
    }
}



//mg90s();
//mg90s_wire_channel(wrap_under=true);
/*
$fs=0.1;
spacing=7;
difference(){
    translate([0,-spacing*3,0])cube([50,50,4],center=true);
    for(x=[-3:3])for(y=[-6:0])
    {
        translate(7*[x,y,0])
        {
            spline_shaft(r1=mg90s_spline_r1 +0.1*(x+y), r2=mg90s_spline_r2+0.1*(x-y));
            translate([0,0,-3])cylinder(d=3.2,h=3);
        }
    }
}
*/

//spline_shaft();