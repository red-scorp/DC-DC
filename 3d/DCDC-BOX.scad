/*  To view the 3D render or to export the .STL file, open this file with openscad (it is free and opensource).
    For more information, see the pdf attached.

    This work is licensed under a Creative Commons Attribution 4.0 International License.

    Note that the default parameter (at the top of the file) get overridden
    by the ones (at the bottom of the file) needed to satisfy your requirements.
    Modifying the values of the first set will have no effect, as the second set will
    still override them.

    Downloaded from www.sol75.com
*/

$fs=0.1;

//Assigned from req, not DOF
hole_distance_x = 30;
hole_distance_y = 45;

lh1 = 8; //Internal, from the bottom to the lower surface of the board
lh2 = 8; //Internal, from the top of the board, to the top surface of the box

d_screw = 3;
use_latch = 1;

use_trapped_nut = 0;// 0= nuts from below, 1= nuts in the colum

// Length = internal length of the walls
lx = 45;
ly = 55;
r_in = 2;
col_wall_t = 1; //material around the screw

// LATCH
latch_w = 10;
latch_l = 12;
latch_t = 0.8;
wedge_out = 0.8;// box_wedge to ease fittings NB:is asymetric!
wedge_angle = 30;
wedge_pos = 5;
//External screw fixture
scew_fixture_stick_out = d_screw+2;
screw_fixture_width    = d_screw*3;

//Printer settings
// How much to compenetrate
p0 = 0.01;
//Toleance as difference hole diameter vs peg diameter good tolerance
min_tol = 0.3;
min_layer_t = 0.2; //Used for bridges over holes, which will be broken away  

max_overhang = 45; // 90 would be a bridge

tx = 1.8;
ty = 0.8;
tz = 1.2;

nut_width = 6.01; // across corners
nut_h = 2.4;
// === DERIVED PARAMETERS ===
r_out = (tx<ty)?tx:ty;
t_out = r_out;// Thickness of the outer skirt on the lid
wedge_h_lwr = wedge_out;
wedge_h_upp = wedge_out/tan(wedge_angle);

fixture_width = (use_latch==0)?screw_fixture_width:latch_w;

A0_e_enclosure_0_STAND_ALONE_PRINT();
module A0_e_enclosure_0_STAND_ALONE_PRINT(){
    color("LightSteelBlue"){
        translate([0,-ly/2 - 2*tx ,0])box_bottom();
        translate([0,ly/2 + 2*tx + t_out ,0]) box_lid();
    }
}

//A0_e_enclosure_0_NULL();
module A0_e_enclosure_0_NULL(){
    color("LightSteelBlue"){
        box_bottom();
        translate([0,0,3*(lh2+lh1+tz)])rotate([0,180,0]) box_lid();
    }
}

//!box_bottom();
module box_bottom(){
      difference(){
                //Bulk
                translate([0,0,(tz+lh1)/2]) roundedBox(x= lx + 2*ty, y= ly + 2*tx, z=lh1+tz, r = r_out + r_in);
                //Take out internal volume
                translate([0,0,(tz+lh1)/2+ tz ]) roundedBox(x = lx ,y =ly,z=lh1 + tz, r = r_in);
                
                if( use_trapped_nut == 0){
                translate([0,0,-tz]) place_support() nut_negative(); 
                }
           }

        //Add support columns, but make sure they do not spill out of the box
        intersection(){
            if( use_trapped_nut ==0){
                place_support() support_column2(); 
            }else{
                place_support() support_column(); 
            }
            translate([0,0,(tz+lh1)/2]) cube(size=[lx + ty,ly + tx, lh1+tz],center = true);
        }

        if(use_latch==1){
            //Add wedges for latches
            translate([lx/2+ty, 0, wedge_pos]) asym_wedge(l = latch_w,wedge_out = wedge_out, angle = wedge_angle);
            rotate([0,0,180]) translate([lx/2+ty,0, wedge_pos]) asym_wedge(l= latch_w,wedge_out = wedge_out, angle = wedge_angle);
        }else{
            translate([lx/2 +ty,0,0]) bolt_support(height =lh1+tz,
                                                   width=screw_fixture_width,
                                                   stick_out = scew_fixture_stick_out,t= tx,t_top = tz );
            rotate([0,0,180])translate([lx/2 + ty,0,0]) bolt_support(height =lh1+tz,
                                                                     width = screw_fixture_width,
                                                                     stick_out = scew_fixture_stick_out,
                                                                     t= tx,t_top = tz );
            }
}


module place_support(){
      translate([-hole_distance_x/2,-hole_distance_y/2,tz]) rotate([0,0, 45]) children();
      translate([ hole_distance_x/2, hole_distance_y/2,tz]) rotate([0,0,-90 -45]) children();
      translate([-hole_distance_x/2, hole_distance_y/2,tz]) rotate([0,0,-45])children();
      translate([ hole_distance_x/2,-hole_distance_y/2,tz]) rotate([0,0, 90 +45]) children();
 }
//!support_column();
 
module support_column(){
    //Columns with space to insert a nut
    nut_across_flat = (nut_width)/2*tan(60) + min_tol;
    column_d_out =d_screw + 2*col_wall_t;
    d_hole = d_screw + min_tol;
    D0= sqrt( pow(column_d_out/2,2) - pow( nut_across_flat/2,2) );
    top_h = min(tz*2,2);
    module nut_and_exit(){
       hull(){
            cylinder(d =nut_width + min_tol, h =nut_h + min_tol, center = false, $fn = 6);
            translate([column_d_out/2,0,0])cylinder(d =nut_width + min_tol, h =nut_h + min_tol, center = false, $fn = 6);
       }
       translate([d_screw/2 + D0,0, nut_h + min_tol+ top_h - p0])cube([d_screw, column_d_out, 2*top_h ],center = true);
    }

    difference(){
           union(){
             translate([0,0,-p0])cylinder(d=column_d_out,h =lh1+p0 ,center=false);
             translate([0,0,-p0])cylinder(d1 =column_d_out + 2 ,d2=column_d_out,h =1 ,center=false);
           }
           translate([0,0,-2*p0])cylinder(d=d_hole,h =1.1*lh1 ,center=false);
           // groove for the nut
           translate([0,0,lh1 - top_h - (nut_h + min_tol)]) nut_and_exit();
           // rectify hole to avoid strange bridges
           rotate([0,0,90])translate([0,0,lh1])cube([nut_across_flat, d_hole, 2*top_h + p0],center = true);
    }
}

//!support_column2();
module support_column2(){
    //The nut is placed on the outer surface of the box bottom
    column_d_base = nut_width + 2*col_wall_t;
    column_d_out  = d_screw + 2*col_wall_t;
    base_h = (nut_h + min_tol) - tz + 3*min_layer_t ; 
    d_hole = d_screw + min_tol;
    fillet = 1;
    points = [ [0,-tz],
               [column_d_base/2 +fillet,-tz],
               [column_d_base/2 +fillet,0],
               [column_d_base/2,0],
               [column_d_base/2,base_h],
               [column_d_out/2,base_h], 
               [column_d_out/2,lh1+p0 ],
               [0,lh1+p0 ],
             ];
    
    difference(){
        rotate_extrude() offset(r= -fillet) offset(r =fillet) polygon(points);
        translate([0,0,-tz])nut_negative();
    }

}

//!nut_negative(); 
module nut_negative(){
     nut_across_flat = (nut_width)/2*tan(60) + min_tol;
     nut_side = nut_width/2;
     d_hole = d_screw + min_tol;
    //Empty space to house the nut 
    translate([0,0,-p0])linear_extrude(nut_h + min_tol,center = false) offset(min_tol) circle(d = nut_width, $fn = 6);
     translate([0,0,nut_h + min_tol -1.1*p0]){
        translate([0,0,min_layer_t/2]) cube([d_hole,nut_across_flat,min_layer_t],center = true); 
        translate([0,0,min_layer_t*1.5-p0*1.1]) cube([d_hole,d_hole,min_layer_t],center = true); 
        
         translate([0,0, min_layer_t*2-2.1*p0])cylinder(d =d_hole, h = tz + lh1, center = false);
     }
}

//!translate([2*lx,0,0])box_lid();
module box_lid(){
    base_x = lx + 2*ty;
    base_y = ly + 2*tx;

    stick_out = (min_tol/2 + t_out);
    half_skirt = stick_out;
    difference(){
       union(){
          //Base
           translate([0,0,(tz+lh2)/2]) roundedBox(x =base_x ,y =base_y,z=lh2+tz,r =  r_out + r_in);
           //skirt
           translate([0,0,(tz+lh2)]) rotate([0,180,0]) roundedBox_champfered_edge(x = base_x +2*stick_out,
                 y = base_y + 2*stick_out,
                 z =2*half_skirt,
                 r= r_out+r_in+stick_out,champfer_h=half_skirt);
       }

       //Take out internal volume
       translate([0,0, (lh2+tz)/2+ tz ]) roundedBox(x= lx, y= ly, z= lh2 + tz, r = r_in);
       translate([0,0, lh2 + tz + half_skirt-p0]) roundedBox(x= base_x + min_tol, y=base_y+ min_tol, z=2*half_skirt, r = r_in + r_out + min_tol/2);

          //Take out space for latch
          translate([lx/2 + ty+stick_out+p0,0,lh2+tz+p0]) cube([2*stick_out,fixture_width + 2*min_tol,2*half_skirt],center=true);
          rotate([0,0,180])translate([lx/2 + ty+stick_out+p0,0,lh2+tz+p0]) cube([2*stick_out,fixture_width  + 2*min_tol,2*half_skirt],center=true);
     }

    if(use_latch == 1){
        //Add flexible latchs
        lwr_end_latch_h = wedge_pos - (wedge_h_upp + wedge_h_lwr) ;
        upp_end_latch_h = lwr_end_latch_h + latch_l;
        tot_h = 2*tz + lh1 + lh2 ;
        latch_start_h = tot_h - upp_end_latch_h;
        translate([0,0, latch_start_h ]){
            translate([lx/2 +ty,0,0]) latch(l_bending =latch_l,depth= latch_w, t_latch = latch_t,stick_out = wedge_out, wedge_angle = wedge_angle);
            rotate([0,0,180])translate([lx/2 + ty,0,0]) latch(l_bending =latch_l,depth= latch_w, t_latch = latch_t, wedge_angle = wedge_angle);
        }
    }else{
    //Add bolt support
        translate([lx/2 +ty,0,0]) bolt_support(height = lh2+tz,
                                               width = screw_fixture_width+ 2*min_tol,
                                                stick_out = scew_fixture_stick_out,t= tx,t_top = tz );
        rotate([0,0,180])translate([lx/2 + ty,0,0]) bolt_support(height = lh2+tz,
                                                                 width = screw_fixture_width+ 2*min_tol,
                                                                stick_out = scew_fixture_stick_out,t= tx, t_top = tz);
    }
}

// Better than box wedge because asymmetric
//asym_wedge();
module asym_wedge(l=20,wedge_out = 0.8, angle = 30){
    // Edge on the x-y plane
    // The asymetric nature should make it easier to get over in one direction.
    // The lower triangle is as steep as possible (while avoiding overhang).
    // The upper one uses the wedge angle
    wedge_h_lwr = wedge_out;
    wedge_h_upp = wedge_out/tan(angle);
    rotate([90,0,0])
    linear_extrude(height= l,center = true, convexity = 2){
        polygon([ [-p0,-wedge_h_lwr],
                  [0,-wedge_h_lwr],
                  [wedge_out,0],
                  [0,wedge_h_upp],
                  [-p0,wedge_h_upp]]);
    }
}

//!latch(l_bending =latch_l,depth= latch_w, t_latch = latch_t, stick_out = wedge_out,  wedge_angle = wedge_angle );
module latch(l_bending = 10, depth = 5, t_latch = 0.8, stick_out = 0.8, wedge_angle = 30 ){
    //Connectes to a wall (normal to x, face on yz plane) with 45deg champfer
    tot_x = stick_out + t_latch;
    tot_y = depth;
    tot_z = l_bending + t_latch + tot_x;
    // Bounding box
    //%translate([tot_x/2,0,tot_z/2 - (t_latch + tot_x) ])cube([tot_x,tot_y,tot_z],center = true);

    wedge_h_long = stick_out/tan(wedge_angle);
    p0 = 0.1;
    rotate([90,0,0])
    linear_extrude(height= depth,center = true, convexity = 2){
        polygon([ [-p0, -( t_latch + tot_x) ],
                  [0,   -( t_latch + tot_x)],
                  [tot_x, -t_latch],
                  [tot_x, +l_bending],
                  [stick_out,l_bending],
                  [0,l_bending- wedge_h_long], // Start the wedge
                  [stick_out,l_bending- wedge_h_long - stick_out], // 45 deg
                  [stick_out, 0],
                  [-p0,0]]);
    }
 }

//!bolt_support();
module bolt_support(height = 10,stick_out = 10,width=20,t=1.6,t_top = 2.0){
        //If you don't use latches, these will keep the lid on
    
        native_overhang = atan(stick_out/height);
        //echo(native_overhang);
        base_x = (native_overhang < max_overhang)? 0:stick_out;
        base_y = (native_overhang > 20)? 0: height-1.5*stick_out;

        //Top surface with bolt hole; thickner for the sacrificial layer
        t_true_top = t_top + min_layer_t;
    
        module triangular_support(){
            rotate([90,0,0])
            linear_extrude(height= t,center = true, convexity = 2){
            polygon([ [-p0,base_y],
                      [base_x,base_y],
                      [stick_out,height-t_true_top],
                      [stick_out-p0,height-t_true_top/2],
                      [-p0,height-t_true_top/2],
                      [-p0,base_y]]);
            }
        }
        
        translate([0,-width/2+t/2,0]) triangular_support();
        translate([0,+width/2-t/2,0]) triangular_support();
        difference(){
            translate([stick_out/2-p0,0,height-t_true_top/2]) cube(size=[stick_out+p0,width,t_true_top],center =true);
            //Leave a single, sacrificial layer so that you are able to print this 
            translate([stick_out/2,0,height-t_true_top + min_layer_t]) cylinder(d =d_screw, h = 2*t_true_top,center = false);
        }
}

//=== Useful shapes & functions ===
module roundedBox(x,y,z,r){
    //result is center = true
    if(r == 0){
        cube(size=[x,y,z],center = true);
    }else{
        r_safe = min(r, x/2 - p0);
        r_safe2 = min(r_safe, y/2 - p0);
        linear_extrude(z, convexity = 4, center = true){
            offset(r_safe2) offset(-r_safe2) square([x,y],center = true);
         }
    }
}

//roundedBox_champfered_edge(20,30,5,4,1);
module roundedBox_champfered_edge(x,y,z,r,champfer_h){
    // The top surface meets the mantel with a champfer at 45 deg
    //result is center = true
    if(r == 0){
        cube(size=[x,y,z],center = true);
    }else{
        r2 = (r > champfer_h)? r-champfer_h: r/2;
        xpos = x/2 - r;
        ypos = y/2 - r;
        hull(){
            translate([-xpos,-ypos,0]) corner_element(r_base=r,r_top = r2,h_base=z-champfer_h,h_top = champfer_h);
            translate([+xpos,-ypos,0]) corner_element(r_base=r,r_top = r2,h_base=z-champfer_h,h_top = champfer_h);
            translate([-xpos,+ypos,0]) corner_element(r_base=r,r_top = r2,h_base=z-champfer_h,h_top = champfer_h);
            translate([+xpos,+ypos,0]) corner_element(r_base=r,r_top = r2,h_base=z-champfer_h,h_top = champfer_h);
        }
    }
}

//!corner_element();
module corner_element(r_base=4,r_top=2,h_base=5,h_top=2){
    //Used by the roundedBox with champfered edges
    h_tot =h_base + h_top;
    translate([0,0,-h_tot/2]){
       //body
       translate([0,0,0])cylinder(r = r_base, h=h_base+p0,center = false);
       //hat
        translate([0,0,h_base]) cylinder(d1=2*r_base,d2=2*r_top,h=h_top,center=false);
    }
}// === Internal State Parameters
n_tx = 1.000000;
n_ty = 1.000000;
n_tz = 3.000000;
latch_w = 15.250000;
latch_l = 16.100000;
wedge_out = 0.800000;
wedge_angle = 30.000000;
latch_t = 2.000000;
wedge_pos = 4.850000;
col_wall_t = 2.000000;
hole_distance_x = 34.000000;
hole_distance_y = 18.000000;
lh1 = 13.000000;
lh2 = 13.600000;
d_screw = 3.000000;
lx = 74.000000;
ly = 37.000000;
r_in = 2.000000;
use_latch = 1.000000;
material_ID = 0.000000;
tx = 2.000000;
ty = 2.000000;
tz = 2.000000;
nut_width = 6.010000;
nut_h = 2.150000;
min_tol = 0.400000;
max_overhang = 45.000000;
min_layer_t = 0.200000;
