function macroInfo(){
	
// * Title  
	scripttitle =  "NanoParticles Tracking";
	version =  "1.01";
	date =  "2024";
	

// *  Tests Images:

	imageAdquisition = "IF Confocal Single Channel  ";
	imageType = "Video: 2D + Time 8 bit";  
	voxelSize = "Voxel size:  unknown";
	format = "Format: czi";   
 
 //*  GUI User Requierments:
 //  	- save and load previous ROIS --> todo
 //*    - Interactive Threshold. --> done
 //*	- Delete Unwanted tissue and SR positive--> done
 //		- Single File and Batch Mode --> done
 //*    
 // Important Parameters: 
 
 	 //parameter1 = "Threshold for all bacteria";
	 //parameter2 = "Min bacteria size (px)";
	 
	  
 //  2 Action tools:
		
	 buttom1 = "Im: Single File processing. Use Single file processing for fine tunning parameters";

//  OUTPUT

	parameter1="1. Detect Nanopartilces with Thresholding Detection (click preview)";
	parameter2="2. Filter Detection with (Quality,Radius,MaxIntensity,stdIntensity,shape Features) (click preview)";
	parameter3="3. Track Particles with Simple LAP Tracker.";
	parameter4="		(Linking max distance 2)";
	parameter5="		(Gap-closing distance 5)";
	parameter6="		(Gap-closing frame 20)";
	parameter7="4. Display settings. (On the bottom, choose TRACKS) Obtain tracks as CSV, ";

	
/*  	  
 *  version: 1.01
 *  Commented by: Tomas Muñoz 2023 
 *  Date : 2024
 *  
 */

//	MIT License
//	Copyright (c) 2023 Tomas Muñoz tmsantoro@unav.es
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.


	//image1 = "../templateImages/cartilage.jpg";
	//descriptionActionsTools = "
	
	showMessage("ImageJ Script", "<html>"
		+"<style>h{margin-top: 5px; margin-bottom: 5px;} p{margin: 0px;padding: 0px;} ol{margin-left: 20px;padding: 5px;} #list-style-3 {list-style-type: circle;.container {max-width: 1200px; margin: 0 auto; padding: 0px; }</style>"
	    +"<h1><font size = 6 color = Teal href = https://cima.cun.es/en/research/technology-platforms/image-platforms>CIMA: Imaging Platform</h1>"
	    +"<h1><font size = 5 color = Purple><i>Software Development Service</i></h1>"
	    +"<p><font size = 2 color = Purple><i>ImageJ Macros</i></p>"
	    +"<h2><font size = 3 color = black>"+scripttitle+"</h2>"
	    +"<p><font size = 2>Modified by Tomas Mu&ntilde;oz Santoro</p>"
	    +"<p><font size = 2>Version: "+version+" ("+date+")</p>"
	    +"<p><font size = 2> contact tmsantoro@unav.es</p>" 
	    +"<p><font size = 2> Available for use/modification/sharing under the "+"<p4><a href = https://opensource.org/licenses/MIT/>MIT License</a></p>"
	    +"<h2><font size = 3 color = black>Developed for</h2>"
	    +"<p><font size = 3  i>Input Images</i></p>"
	    +"<ul id = list-style-3><font size = 2  i><li>"+imageAdquisition +"</li><li>"+imageType+"</li><li>"+voxelSize+"</li><li>"+format+"</li></ul>"
	    +"<p><font size = 3 i>Action tools (Buttons)</i></p>"
	    +"<ol><font size = 2  i><li>"+buttom1+"</li></ol>"
	    +"<p><font size = 3  i> SUGGESTED WORKFLOW PARAMETERS:</i></p>"
	    +"<ul id = list-style-3><font size = 2  i>"
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li>"
	    +"<li>"+parameter3+"</li>"
	    +"<li>"+parameter4+"</li>"
	    +"<li>"+parameter5+"</li>"
	    +"<li>"+parameter6+"</li>"
	    +"<li>"+parameter7+"</li></ul>"
	    +"<h0><font size = 5></h0>"
	    +"");
	   //+"<P4><font size = 2> For more detailed instructions see "+"<p4><a href = https://www.protocols.io/edit/movie-timepoint-copytoclipboaMarker2-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}



// changelog February 2022
// Segmentation of the biofilm in 3D
// Quantification of biofilm volume

var displacement=1, thBac=60, minBacSize=20;

macro "IF_NanoTrack Action Tool 1 - Cf00T2d15IT6d10m"{
	
	run("Close All");
	
	macroInfo();
	
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	print("Processing "+name);

	 // Open dialog to select an image file
    run("Bio-Formats Importer", "open=[" + name + "] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
 
	IF_NanoTrack();
	
	setBatchMode(false);
	showMessage("NanoTrack DONE!");

}


function IF_NanoTrack()
{
 	rename("orig");
	run("8-bit");  
	getDimensions(width, height, channels, slices, frames);
	setSlice(floor(frames/2));
	run("StackReg", "transformation=Translation");  // Align frames using translation
	
	// metadata info
	getDimensions(width, height, channels, slices, frames);
	getVoxelSize(rx,ry, rz, unit);
	frameInterval=Stack.getFrameInterval();
	//print(frameInterval);
		
	//large hiper saturated regions 
	run("Z Project...", "projection=[Max Intensity]");
	run("Threshold...");
	setThreshold(170, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Analyze Particles...", "size=100-Infinity pixel show=Masks in_situ");
	run("Fill Holes");
	run("Dilate");
	rename("Artefact_type0");
	close("Threshold");
	
	// Preprocessing of the image
	selectWindow("orig");
	run("Duplicate...", "duplicate  title=Seeds");
	run("Subtract Background...", "rolling=3 stack");
	run("Find Edges", "stack");	
	setMinAndMax(35, 180);
	run("Apply LUT","stack");
	run("Median...", "radius=1 stack");
	
	selectImage("Artefact_type0");
	run("Create Selection");
	type=selectionType() ;
	if(type!=-1){
		selectImage("Seeds");
		run("Restore Selection");
		run("Enlarge...","enlarge=5 pixel");
		setBackgroundColor(0, 0, 0);
		run("Clear", "stack");
		run("Select None");
	}
	close("Artefact_type0");
	
	// Crop out a portion of the image and clear the outer region
	run("Select All");
	run("Enlarge...","enlarge=-10 pixel"); 
	setBackgroundColor(0,0,0);
	run("Clear Outside","stack"); 
	run("Select None");
	
	//run("Re-order Hyperstack ...", "channels=[Channels (c)] slices=[Frames (t)] frames=[Slices (z)]");
	//run("3D Fast Filters","filter=Median radius_x_pix=2.0 radius_y_pix=2.0 radius_z_pix=5.0 Nb_cpus=16");
	//close("Seeds");
	//rename("Seeds");
	
	// run TrackMate
	selectWindow("orig");
	getVoxelSize(rx,ry, rz, unit);
	selectWindow("Seeds");
	run("Set Scale...", "distance=1 known="+rx+" unit=micron");
	//run("Re-order Hyperstack ...", "channels=[Channels (c)] slices=[Frames (t)] frames=[Slices (z)]");
	run("TrackMate");
	waitForUser("SUGGESTION:\n  1.Detect Nanopartilces with Thresholding Detection (click preview)\n  2. Filter Detection with (Quality,Radius,MaxIntensity,stdIntensity,shape Features) (click preview)\n  3. Track Particles with Simple LAP Tracker.\n		(Linking max distance 2)\n		(Gap-closing distance 5)\n		(Gap-closing frame 20)\n  4. Track Filter: Select Track Duration.\n  5. Display Option select Track on the bottom and export to CSV\n  6. Action: Capture overlay and save Image");
	close("*");
	close("TrackMate*");

}

	
	
	

	

	
	

