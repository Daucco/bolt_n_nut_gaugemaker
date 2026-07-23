//use </home/daucco/Syncthing/Dev/3d/openscad/libs/threads/files/threads-library-by-cuiso-v1.scad>





// Fixed
screw_m_length_mm = 12.5;
screw_f_length_mm = 12.5;
screw_f_offset_mm = 2;
screw_neck_length_mm = 3;
nut_facet = 6;
neck_height = 4;
text_font = "Noto Sans Sinhala Black Condensed";
text_height = .25;
text_height_offset = .25;
nut_factor = 1.6;
min_nut_oversize = 3.5;
max_nut_oversize = 8;
lay_sep = 10;
screw_total_length = screw_m_length_mm + screw_f_length_mm + screw_neck_length_mm;

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




function to_metric_mm(inch_size) = inch_size * 25.4;
    
//function to_tpi(diam) = 25.4/(get_std_pitch(diam));

// Text offset to nut face. The following only makes sense for nut_facet == 6! (using trigonometry)
//text_offsetY = (nut_diameter * sqrt(3))/4;


// Gauges as list of lists: (diameter in mm, name, screw_length)

screw_list = [
    [4, "M4", 10, 0.7],//1.35
    [5, "M5", 10, 0.8],
    [6, "M6", 10, 1.0],//1.33
    /*
    [7, "M7", 10, 1.0],//1.3
    [8, "M8", 10, 1.25],//1.26
    [10, "M10", 10, 1.5],//1.22
    [12, "M12", 12, 1.75],//1.2
    [14, "M14", 12, 2.0],
    [16, "M16", 12, 2.0],//1.16
    [20, "M20", 12, 2.5],//1.14
    */
];


// Remove this. just for placeholders
boxneck_d_ratio = 1.12; //1.35

screw_list_imperial = [
    [to_metric_mm(5/32), "8", 10, tpi_to_pitchmm(32)],     //1.35
    [to_metric_mm(3/16), "10", 10, tpi_to_pitchmm(24)],    //1.33
    /*
    [to_metric_mm(1/4), "1/4", 10, tpi_to_pitchmm(20)],  //1.3
    [to_metric_mm(5/16), "5/16", 12, tpi_to_pitchmm(18)],   //1.26
    [to_metric_mm(3/8), "3/8", 12, tpi_to_pitchmm(16)],     //1.22
    [to_metric_mm(7/16), "7/16", 12, tpi_to_pitchmm(14)],   //1.2
    [to_metric_mm(1/2), "1/2", 12, tpi_to_pitchmm(13)],    //1.16
    [to_metric_mm(9/16), "9/16", 12, tpi_to_pitchmm(12)],   //1.16
    [to_metric_mm(5/8), "5/8", 12, tpi_to_pitchmm(11)],     //1.12
    [to_metric_mm(3/4), "3/4", 12, tpi_to_pitchmm(10)]      //1.12
    */
];



///////////////////////////////////////////////////////////

module thread_for_nut_fullparam(diameter, length, usrclearance=0, pitch, divs=50, entry=1)
{
stdclearance=get_std_clearance(diameter);

if(divs<20)thread_for_nut_build
(diameter+stdclearance+usrclearance,length,pitch,20,entry=entry);
else
if(divs>360)thread_for_nut_build
(diameter+stdclearance+usrclearance,length,pitch,360,entry=entry);
else
thread_for_nut_build
(diameter+stdclearance+usrclearance,length,pitch,divs,entry=entry);
}

module thread_for_nut_build(diameter,lenght,pitch,divdelta,entry){
delta=360/divdelta;
translate([0,0,-0.001])
intersection(){
screw(long=lenght+0.002,p=pitch,delta=delta,diameter=diameter,nut=1);
#innercube_nut(lenght+0.002,pitch,diameter);
}
if(entry==1){translate([0,0,-0.001])innercube_nut_in(lenght+0.002,pitch,diameter,divdeltacube=divdelta);}
//#cylinder(d=diameter,h=lenght,$fn=100);
}


module thread_for_screw_build(diameter,lenght,pitch,divdelta){
delta=360/divdelta;
intersection(){
innercube_screw(long=lenght,pitch=pitch,diameter=diameter,divdeltacube=divdelta);
screw(long=lenght,p=pitch,delta=delta,diameter=diameter);
}
//#cylinder(d=diameter,h=lenght,$fn=100);
}

module screw(long,p,delta,diameter,nut=0)
{
revs=round(long/p+0.5)+1;
translate([0,0,-p/4])
for(v = [0 : 1 : revs-1])
translate([0,0,v*p])
do_rev(p=p,delta=delta,diameter=diameter,nut=nut);
}

module do_rev(p,delta,diameter,nut)
{
inner(p=p,delta=delta,diameter=diameter,nut=nut);

translate([0,0.001,0])
rotate([0,180,180])
inner(p=p,delta=delta,diameter=diameter,nut=nut);
}


module inner(p,delta,diameter,nut)
{
if(nut==1)
//render()
hull(){
for(k = [0 : delta : 180])
translate([0,0,k*p/360])rotate([0,0,k])piece_nut(diameter=diameter, p=p);
translate([0,0,180*p/360])rotate([0,0,180])piece_nut(diameter=diameter, p=p);
}
else
//render()
hull(){
for(k = [0 : delta : 180])
translate([0,0,k*p/360])rotate([0,0,k])piece(diameter=diameter, p=p);
translate([0,0,180*p/360])rotate([0,0,180])piece(diameter=diameter, p=p);
}
}

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
    ], 
    [
    [0,1,2,3,4,5]
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
    ], 
    [
    [0,1,2,3,4]
    ]);
}
}


module innercube_nut(long,pitch,diameter)
{
longcube=long;
translate([0,0,longcube/2])cube([diameter,diameter,longcube],center=true);
}

module innercube_nut_in(long,pitch,diameter,divdeltacube)
{
longcube=long-0.6;
translate([0,0,longcube])
cylinder(d2=diameter+0.4,d1=diameter,h=0.6, $fn=divdeltacube);
cylinder(d1=diameter+0.4,d2=diameter,h=0.6, $fn=divdeltacube);
}


module thread_for_screw_fullparam(diameter, length, pitch, divs=50)
{
if(divs<20) thread_for_screw_build(diameter,length,pitch,20);
    else if(divs>360) thread_for_screw_build(diameter,length,pitch,360);
        else thread_for_screw_build(diameter,length,pitch,divs);
}


module innercube_screw(long,pitch,diameter,divdeltacube)
{
longcube=long-pitch;
translate([0,0,longcube/2+pitch/2])cube([diameter,diameter,longcube],center=true);
translate([0,0,longcube+pitch/2])
cylinder(d1=diameter,d2=diameter-2*pitch*0.866,h=pitch/2, $fn=divdeltacube);
cylinder(d2=diameter,d1=diameter-2*pitch*0.866,h=pitch/2, $fn=divdeltacube);
}

function get_std_clearance(diam) = 
lookup(diam,[[3,0.4],[4,0.4],[5,0.5],[6,0.6],[8,0.6],[10,0.6],
[12,0.7],[14,0.7],[16,0.7],[18,0.7],[20,0.8],[22,0.8],[24,0.8]
]);

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

module nut(diameter, height){
    translate([0, 0, height/2])
        cylinder(h=height, d=diameter, center=true);
}


module gauge_screw(diameter, screw_pitch, m_length=screw_m_length_mm, f_length=screw_f_length_mm, name="", usrclearance=nut_clearance){
    // Do a cone-neck to connect female to male
    
    // NOTE: Adding + f_length/2 to every subpart Z position so the nut's center is set a origin. This simplifies text positioning
    
    /*
    // This magic does not work in OpenSCAD. The updated variable only lives within the scope of the if statement...
    text_offsetY = nut_diameter/2;
    if(nut_facet == 6){
        // If hexagon, position text right at the edge (trigonometry)
        text_offsetY = (nut_diameter * sqrt(3))/4;
    }
    */
    
    //nut_diameter = diameter*nut_factor;
    nut_diameter = max((min(diameter*nut_factor, diameter + max_nut_oversize)), (diameter + min_nut_oversize));
    
    // Text offset to nut face. The following only makes sense for nut_facet == 6! (using trigonometry)
    // NOTE: Inset text - we've added text_height to move the text inside the geometry!
    text_offsetY = (nut_diameter * sqrt(3))/4 - text_height;
    
    text_size = min(text_vect_factor*diameter, text_size);
    
    
    union(){
        // Screw
        translate([0, 0, neck_height + f_length/2])
            thread_for_screw_fullparam(diameter, m_length, screw_pitch, divs=50);
        
        // Neck
        translate([0, 0, neck_height/2 + f_length/2])
            cylinder(h=neck_height, d1=nut_diameter, d2=diameter, center=true, $fn=nut_facet);
        
        // Nut
        difference(){// Negative text!
            union(){
                translate([0, 0, f_length/2])
                rotate([180, 0, 0]){
                    difference(){
                        nut(nut_diameter, f_length, $fn=nut_facet);
                        translate([0, 0, nut_screw_lip_offset])
                        thread_for_nut_fullparam(diameter, f_length, usrclearance, screw_pitch, divs=60);   
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

//gauge_screw(5, name="5mm");

curr_list = screw_list_imperial;
//curr_list = screw_list;

function get_tpi_from_mm(_d) = 25.4/get_std_ptich(_d);

function tpi_to_pitchmm(tpi) = 25.4/tpi;

for(i=[0:1:len(curr_list)-1]){    
    screw_diameter = curr_list[i][0];
    screw_name = curr_list[i][1];
    screw_length = curr_list[i][2];
    screw_pitch = curr_list[i][3];
    //screw_diameter = 5;
    //screw_name = "5mm";
    
    translate([0, 0, (screw_total_length + lay_sep)*i])
        gauge_screw(screw_diameter, screw_pitch, m_length=screw_length, f_length=screw_length, name=screw_name); 

    //echo(get_std_pitch(screw_diameter));
    //echo(get_tpi_from_mm(screw_diameter));
    //echo(25.4/get_std_pitch(screw_diameter));
    //echo(get_std_pitch(screw_diameter));
    echo(screw_name);
    echo(screw_pitch);
}
