// These are the subdivisions when generating the threading geometry. The bigger the number, the better the resolution, but the harder to render.
min_facets = 15;
max_facets = 200;

// Standard nut clearance. This list is meant to be used as a lookup table, so missing diameters will be interpolated from neighbouring entries
std_nutClearance = [
    [4,0.4],
    [5,0.5],
    [6,0.6],
    [8,0.6],
    [10,0.6],
    [12,0.7],
    [14,0.7],
    [16,0.7],
    [18,0.7],
    [20,0.8]
];




// Fixed
nut_facet = 6;
text_height_offset = .25;   // Review this. Shouldnt be necessary; just position the text centered while giving it 2xthickness

// Customizable
screw_m_length_mm = 12.5;
screw_f_length_mm = 12.5;
screw_f_offset_mm = 2;
//screw_neck_length_mm = 3;
neck_height = 4;    // This is screw_neck_length_mm

// Nut size relative to screw diameter
// Min and max values are relative offset to nut threads in mm
nut_factor = 1.6;
min_nut_oversize = 3.5;
max_nut_oversize = 8;

text_font = "Noto Sans Sinhala Black Condensed";
text_height = .25;

// Multi object separation. This is only useful when generating multiple gauges at once
obj_sep = 1;

//screw_total_length = screw_m_length_mm + screw_f_length_mm + neck_height;

// Per-screw params: Treat these separately from each module
screw_diameter_mm = 10;
//nut_diameter = screw_diameter_mm*1.5;

//  Separate text profiles for different measures
//  For metric system: min(screw_diameter, basesize=6)
//  For freedom units: min(screw_diameter*swap_factor=.625, basesize=?)
text_size = 4;   // 2.5
text_vect_factor = 0.8;
text_inset = true;

nut_screw_lip_offset = 0.6;

nut_clearance = 0.18;   // Use 0.1 for nuts



function get_nutClearance(diameter) = lookup(diameter, std_nutClearance);
function to_metric_mm(inch_size) = inch_size * 25.4;
function tpi_to_pitchmm(tpi) = 25.4/tpi;
    
//function to_tpi(diam) = 25.4/(get_std_pitch(diam));

// Text offset to nut face. The following only makes sense for nut_facet == 6! (using trigonometry)
//text_offsetY = (nut_diameter * sqrt(3))/4;


// Gauges as index: (diameter (mm), textual name, screw length, nut length, pitch (mm))
screw_list = [
    // Metric
    /*
    [4, "M4", 10, 10, 0.7],//1.35
    [5, "M5", 10, 10, 0.8],
    [6, "M6", 10, 10, 1.0],//1.33
    [7, "M7", 10, 1.0],//1.3
    [8, "M8", 10, 1.25],//1.26
    [10, "M10", 10, 1.5],//1.22
    [12, "M12", 12, 1.75],//1.2
    [14, "M14", 12, 2.0],
    [16, "M16", 12, 2.0],//1.16
    [20, "M20", 12, 2.5],//1.14
    */
    
    // Imperial
    
    [to_metric_mm(5/32), "8", 10, 10, tpi_to_pitchmm(32)],     //1.35
    [to_metric_mm(3/16), "10", 10, 10, tpi_to_pitchmm(24)],    //1.33
    [to_metric_mm(1/4), "1/4", 10, 10, tpi_to_pitchmm(20)],  //1.3
    [to_metric_mm(5/16), "5/16", 12, 12, tpi_to_pitchmm(18)],   //1.26
    [to_metric_mm(3/8), "3/8", 12, 12, tpi_to_pitchmm(16)],     //1.22
    [to_metric_mm(7/16), "7/16", 12, 12, tpi_to_pitchmm(14)],   //1.2
    [to_metric_mm(1/2), "1/2", 12, 12, tpi_to_pitchmm(13)],    //1.16
    [to_metric_mm(9/16), "9/16", 12, 12, tpi_to_pitchmm(12)],   //1.16
    [to_metric_mm(5/8), "5/8", 12, 12, tpi_to_pitchmm(11)],     //1.12
    [to_metric_mm(3/4), "3/4", 12, 12, tpi_to_pitchmm(10)]      //1.12
];


// Remove this. just for placeholders
boxneck_d_ratio = 1.12; //1.35





///////////////////////////////////////////////////////////


/*
module piece(diameter, p)
{
r=diameter/2;
h=p*0.866;
pp=p/2;
pm=-p/2;
hh=r-h;
g=0.001;

rotate([90,0,0])
linear_extrude(height = g, center = true, convexity = 10){
polygon([
    [0,pp],[hh,pp],[r-h/8,p/16],[r-h/8,-p/16],[hh,pm],[0,pm]
    ]);
}
}
module piece_nut(diameter, p)
{
r=diameter/2;
h=p*0.866;
pp=p/2;
pm=-p/2;
hh=r-h;
g=0.001;
    
rotate([90,0,0])
linear_extrude(height = g, center = true, convexity = 10){
polygon([
    [0,pp],[hh,pp],[r,0],[hh,pm],[0,pm]
    ]);
}
}
*/

// Screw compositor
module screw_thread(diameter, length, pitch, n_facet){
    n_facet = min(max_facets, max(min_facets, n_facet));
    
    delta = 360/n_facet;   // Facets per rev
    intersection(){
        screw_thread_bounds(length, pitch, diameter, n_facet);
        shaft(length, pitch, delta, diameter);
    }
}

module nut_thread(diameter, length, extra_nut_clearance=0, pitch, n_facet=50){
    std_nut_clearance = get_nutClearance(diameter);
    n_facet = min(max_facets, max(min_facets, n_facet));
    
    delta_diameter = diameter + std_nut_clearance + extra_nut_clearance;

    // TODO delta to delta face
    
    delta = 360/n_facet;  // Facets per rev
    translate([0, 0, -0.001])
    intersection(){
        nut_thread_bounds(length+0.002, pitch, delta_diameter);
        shaft(length+0.002, pitch, delta, delta_diameter, isnut=true);
    }
    
    // Nut entry recess
    inshaft_length = length - 0.6 + 0.002;  // Accounts for safety offset
    translate([0, 0, inshaft_length-0.001])
        cylinder(d2=delta_diameter+0.4, d1=delta_diameter, h=0.6, $fn=n_facet);

}

// Defines screw bounds, including top and ending threading, plus a bounding box for the shaft. This is meant to be intersected with the screw revs
module screw_thread_bounds(length, pitch, diameter, n_facet){
    shaft_length = length - pitch;
    
    // Shaft bounding box
    translate([0, 0, shaft_length/2+pitch/2])
        cube([diameter, diameter, shaft_length],center=true);
    
    // Top screw threading
    translate([0, 0, shaft_length+pitch/2])
        cylinder(d1=diameter,d2=diameter-2*pitch*0.866,h=pitch/2, $fn=n_facet);
    
    // End screw threading
    cylinder(d2=diameter,d1=diameter-2*pitch*0.866,h=pitch/2, $fn=n_facet);
}


module nut_thread_bounds(length, pitch, diameter){
    inshaft_length = length;
    translate([0, 0, inshaft_length/2])
        cube([diameter, diameter, inshaft_length], center=true);
}

// Single thread revolution
module rev(p, delta, diameter, isnut){
    half_rev(p, delta, diameter, isnut);

    translate([0,0.001,0])
    rotate([0,180,180])
        half_rev(p, delta, diameter, isnut);
}

// Half thread revolution. This will have to be composed to generate a full rev.
// Each rev is generated by segments. Render complexity is tied to number of facets (from delta)
module half_rev(p, delta, diameter, isnut){
    r=diameter/2;
    h=p*0.866;
    pp=p/2;
    pm=-p/2;
    hh=r-h;
    g=0.001;
    
    hull(){
        if(isnut){
            for(k = [0 : delta : 180]){
                translate([0,0,k*p/360])rotate([0,0,k])
                rotate([90,0,0])
                linear_extrude(height = g, center = true, convexity = 10)
                    polygon([[0,pp],[hh,pp],[r,0],[hh,pm],[0,pm]]);
                
                translate([0,0,180*p/360])rotate([0,0,180])
                rotate([90,0,0])
                linear_extrude(height = g, center = true, convexity = 10)
                    polygon([[0,pp],[hh,pp],[r,0],[hh,pm],[0,pm]]);
            }
        }
        else{
            for(k = [0 : delta : 180]){
                translate([0,0,k*p/360])rotate([0,0,k])
                rotate([90,0,0])
                linear_extrude(height = g, center = true, convexity = 10)
                    polygon([[0,pp],[hh,pp],[r-h/8,p/16],[r-h/8,-p/16],[hh,pm],[0,pm]]);
                
                translate([0,0,180*p/360])rotate([0,0,180])
                rotate([90,0,0])
                linear_extrude(height = g, center = true, convexity = 10)
                    polygon([[0,pp],[hh,pp],[r-h/8,p/16],[r-h/8,-p/16],[hh,pm],[0,pm]]);
            }
        }
    }
}

// Shaft compositor. Depends on rev
module shaft(length, pitch, delta, diameter, isnut=false){
    n_revs = round(length/pitch+0.5)+1;
    
    translate([0, 0, -pitch/4])
    for(i = [0: 1: n_revs-1]){
        translate([0, 0, i*pitch])
            rev(pitch, delta, diameter, isnut);
    }
}


///////////////////////////////////////////////////////////

//screw_list_diam = [
//    5
//];



// M6X20 screw
/*
thread_for_screw(diameter=5, length=24);
cylinder(d=12, h=4, $fn=6);
*/

// M6 nut
//#thread_for_nut(diameter=5, length=12, usrclearance=0);

// Do module to generate a M-F screw of the specified diameter. Params: diamter, m_length, f_length, name,  usrclearance. Name is an str text with the screw identifier. Text should be engraved to the side


// TODO: Move up, and include composition with nut_thread here, then only call nut() in gauge screw
module nut(diameter, height){
    translate([0, 0, height/2])
        cylinder(h=height, d=diameter, center=true);
}


module gauge_screw(diameter, screw_pitch, m_length=screw_m_length_mm, f_length=screw_f_length_mm, name="", extra_nut_clearance=nut_clearance){
    
    nut_diameter = max((min(diameter*nut_factor, diameter + max_nut_oversize)), (diameter + min_nut_oversize));
    
    // Text offset to nut face. The following only makes sense for nut_facet == 6!
    // NOTE: Inset text - we've added text_height to move the text inside the geometry!
    text_offsetY = (nut_diameter * sqrt(3))/4 - text_height;
    
    // Clamping text size so it matches the nut size
    text_size = min(text_vect_factor*diameter, text_size);
    
    // NOTE: Adding + f_length/2 to every subpart Z position so the nut's center is set a origin. This simplifies text positioning 
    union(){
        // Screw
        translate([0, 0, neck_height + f_length/2])
            screw_thread(diameter, m_length, screw_pitch, n_facet=50);
        
        // Neck
        translate([0, 0, neck_height/2 + f_length/2])
            cylinder(h=neck_height, d1=nut_diameter, d2=diameter, center=true, $fn=nut_facet);
        
        // Nut
        difference(){// Negative text. Use union for emboss
            union(){
                translate([0, 0, f_length/2])
                rotate([180, 0, 0]){
                    difference(){
                        nut(nut_diameter, f_length, $fn=nut_facet);
                        translate([0, 0, nut_screw_lip_offset])
                        nut_thread(diameter, f_length, extra_nut_clearance, screw_pitch, n_facet=60);   
                    }
                }
            }
            // Text
            for(i=[0:1:len(name)-1]){
                translate([0, -text_offsetY, 0])
                rotate([90, 90, 0])
                linear_extrude(height=text_height+text_height_offset){
                    text(name, size=text_size, halign="center", valign="center", font=text_font);
                }
            
            }
            
        }
    }
}

for(i=[0:1:len(screw_list)-1]){    
    screw_diameter = screw_list[i][0];
    screw_name = screw_list[i][1];
    screw_length_m = screw_list[i][2];
    screw_length_f = screw_list[i][3];
    screw_pitch = screw_list[i][4];
    
    screw_total_length =  screw_length_m + screw_length_f + neck_height;
    
    // TODO: Update this properly
    vertical_offset = 0;
    for(j=[0:1:i]){
        vertical_offset = vertical_offset + screw_list[j][2] + screw_list[j][3] + obj_sep;
    }
    
    
    translate([0, 0, (screw_total_length + obj_sep)*i])
    //translate([0, 0, vertical_offset])
        gauge_screw(screw_diameter, screw_pitch, m_length=screw_length_m, f_length=screw_length_f, name=screw_name);
    
    //echo(screw_name);
    //echo(screw_pitch);
}
