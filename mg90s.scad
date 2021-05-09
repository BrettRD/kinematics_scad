


body_dims = [22.5,12.3,22.5];
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
spur_pos= body_dims[0]/2 -15 + spur_dia/2;


shaft_len=5.5;



mg90s_spline_r1=4.2 /2;
mg90s_spline_r2=4.7 /2;
mg90s_spline_n=20;
mg90s_spline_h=4;

function spline_list(r1=mg90s_spline_r1, r2=mg90s_spline_r2, n=mg90s_spline_n) = 
    [for(theta = [0:360/n:360]) for(p=[[r1,0],[r2,180/n]]) p[0]* [sin(theta+p[1]), cos(theta+p[1])]];

module spline_sect(r1=mg90s_spline_r1, r2=mg90s_spline_r2, n=mg90s_spline_n){
    polygon(spline_list(r1,r2,n));
}

module spline_shaft(r1=mg90s_spline_r1, r2=mg90s_spline_r2, n=mg90s_spline_n, h=mg90s_spline_h){
    linear_extrude(height = h) spline_sect(r1,r2,n);
}


function mg90s_shaft_pos() = [(body_length-body_width)/2,0,body_height/2 + gear_drop];
function mg90s_shaft_axis() = [0,0,1];

function mg90s_bolt_top_pos() = [for(mirr=[1,-1]) [mirr * wing_bolt_spacing/2, 0, (body_height-wing_thick)/2-wing_drop]];
function mg90s_bolt_bottom_pos() = [for(pos = mg90s_bolt_top_pos()) pos - [0,0,wing_thick] ];

function mg90s_bolt_top_axes() = [[0,0,1], [0,0,1]];
function mg90s_bolt_bottom_axes() = -1 * mg90s_bolt_top_axes();

module mg90s(a=0){
    cube(body_dims, center=true);
    translate([body_length - body_width,0,body_height]/2)cylinder(d=body_width,h=gear_drop);
    translate([spur_pos,0,body_height]/2)cylinder(d=spur_dia,h=gear_drop);
    translate([body_length/2,0,-body_height/2 + 4.5])cube([8,4,1], center=true);

    difference(){
        translate([0,0,(body_height-wing_thick)/2-wing_drop])cube(wing_dims, center=true);
        for(mirr=[1,-1]){
            translate([mirr * wing_bolt_spacing/2,0,0]) cylinder(d=wing_bolt_dia, h=body_height, center=true);
            translate([mirr * (wing_len + wing_bolt_spacing)/4,0,0]) cube([(wing_len-wing_bolt_spacing)/2, wing_split, body_height], center=true);
        }
    }

    translate(mg90s_shaft_pos()) rotate(mg90s_shaft_axis()) rotate([0,0,a]) spline_shaft();
}


mg90s();





