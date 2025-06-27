


function macroInfo(){
	
// * Quantifiaction of Organoids on Button Device PhaseContrast Image
// * Target User: General
// *  

	scripttitle= "Quantifiaction of Organoids on Button Device PhaseContrast Image";
	version= "1.01";
	date= "2023";
	

// *  Tests Images:

	imageAdquisition="Z Stack PhaseContrast Image";
	imageType="3D Z Stack ";  
	voxelSize="Voxel size: unknown um xy";
	format="Format: Uncompressed .czi";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button 
	
	parameter1="Resolution (micra pixel ratio) = 0.502 micras/pixel xy"; 
	parameter2="Max Organoid size (px)";
	parameter3="Min particle size (px)";
	parameter4="Circularity Filter: Introduce value between [0,1]. [0 Non circle morphology , 1 Perfect Circle]";
	 

 //  2 Action tools:
	buttom1="Im: Single File processing";
 //	buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs

	excel="QuantifiedImages.xls";
	feature1="Image Label";
	feature2="# Organoids";
	feature3="AverageSize [micras^2]";
	feature4="stdSize [micras^2]"
	
/*  	  
 *  version: 1.02 
 *  Author: Mikel Ariz  
 *  Commented by: Tomas Muñoz 2023 
 *  Date : 2015
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

	
	//image1="../templateImages/cartilage.jpg";
	//descriptionActionsTools="
	
	showMessage("ImageJ Script", "<html>"
		+"<style>h{margin-top: 5px; margin-bottom: 5px;} p{margin: 0px;padding: 0px;} ol{margin-left: 20px;padding: 5px;} #list-style-3 {list-style-type: circle;.container {max-width: 1200px; margin: 0 auto; padding: 0px; }</style>"
	    +"<h1><font size=6 color=Teal href=https://cima.cun.es/en/research/technology-platforms/image-platforms>CIMA: Imaging Platform</h1>"
	    +"<h1><font size=5 color=Purple><i>Software Development Service</i></h1>"
	    +"<p><font size=2 color=Purple><i>ImageJ Macros</i></p>"
	    +"<h2><font size=3 color=black>"+scripttitle+"</h2>"
	    +"<p><font size=2>Modified by Tomas Mu&ntilde;oz Santoro</p>"
	    +"<p><font size=2>Version: "+version+" ("+date+")</p>"
	    +"<p><font size=2> contact tmsantoro@unav.es</p>" 
	    +"<p><font size=2> Available for use/modification/sharing under the "+"<p4><a href=https://opensource.org/licenses/MIT/>MIT License</a></p>"
	    +"<h2><font size=3 color=black>Developed for</h2>"
	    +"<p><font size=3  i>Input Images</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+imageAdquisition +"</li><li>"+imageType+"</li><li>"+voxelSize+"</li><li>"+format+"</li></ul>"
	    +"<p><font size=3 i>Action tools (Buttons)</i></p>"
	    +"<ol><font size=2  i><li>"+buttom1+"</li></ol>"
	    +"<p><font size=3  i>PARAMETERS: </i></p>"
	    +"<ul id=list-style-3><font size=2  i>"
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li>"
	    +"<li>"+parameter3+"</li>"
	    +"<li>"+parameter4+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}



var  minParticleSize=300, maxParticleSize=10000, r=0.502, prominence=1, circularity=0.5;


macro "cellCount Action Tool 1 - Cf00T2d15IT6d10m"{
	
	close("*");
	
	macroInfo();
	
	
	run("ROI Manager...");
	
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	print("Processing "+name);
	
		
	Dialog.create("Parameters");
	Dialog.addMessage("Choose parameters");
	Dialog.addNumber("Objective Scale", r);
	Dialog.addNumber("Min Particle size (px)", minParticleSize);
    Dialog.addNumber("Max particle size (px)", maxParticleSize);
    Dialog.addNumber("Circularity Filter)", circularity);	
	Dialog.show();
	r= Dialog.getNumber();
	minParticleSize= Dialog.getNumber();
	maxParticleSize= Dialog.getNumber(); 
	circularity= Dialog.getNumber(); 		
	
	//setBatchMode(true);
	organoidCount("-","-",name,r,maxParticleSize,minParticleSize,circularity);
			
	setBatchMode(false);
	showMessage("Cells quantified!");

}

macro "cellCount Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	close("*");
	
	macroInfo();
	
	run("ROI Manager...");
	
	InDir=getDirectory("Choose Tiles' directory");
	list=getFileList(InDir);
	L=lengthOf(list);
	
	Dialog.create("Parameters");
	Dialog.addMessage("Choose parameters");
	Dialog.addNumber("Objective Scale", r);
	Dialog.addNumber("Min Particle size (px)", minParticleSize);
    Dialog.addNumber("Max particle size (px)", maxParticleSize);
    Dialog.addNumber("Circularity Filter)", circularity);	
	Dialog.show();
	r= Dialog.getNumber();
	minParticleSize= Dialog.getNumber();
	maxParticleSize= Dialog.getNumber(); 
	circularity= Dialog.getNumber(); 			
	
	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"czi")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print("Processing "+name);
			//setBatchMode(true);
			organoidCount(InDir,InDir,list[j],r,maxParticleSize,minParticleSize,circularity);
			setBatchMode(false);
			}
	}
	
	showMessage("Cells quantified!");

}



function organoidCount(output,InDir,name,r,maxParticleSize,minParticleSize,circularity)
{	

	run("Close All");

	if (InDir=="-") {
		run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Grayscale rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
		}
	else {
		run("Bio-Formats Importer", "open=["+InDir+name+"] autoscale color_mode=Grayscale rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
		}	


	/*
	ch=2;
	th=20;
	minParticleSize=20;
	r=0.502;
	prominence=5;
	circularity=0.1;
	*/
	
	
	//Initialize conditions
	roiManager("Reset");
	run("Clear Results");
	run("Colors...", "foreground=black background=white selection=red");
	run("Set Measurements...", "area redirect=None decimal=2");
	
	//Current Image Title 
	MyTitle=getTitle();
	output=getInfo("image.directory");
	OutDir = output+File.separator+"AnalyzedImages";
	//Make Results directory
	File.makeDirectory(OutDir);
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	showStatus("Analyzing"+MyTitle);
	print(MyTitle);
	
	// IMAGE PREPROCESSING --> Background and outside artifacs
	run("8-bit");
	getPixelSize(unit, pixelWidth, pixelHeight);
	run("Set Scale...", "distance=1 known="+pixelWidth+" unit="+unit);
	
	//run("Duplicate...", "title=buttonMask duplicate");
	run("Duplicate...", "title=buttonMask  duplicate range=30 use");
	
	//Delete outside artifacts
	selectWindow("buttonMask");
	setAutoThreshold("Default stack");
	setOption("BlackBackground", false);
	run("Convert to Mask", "background=Light");
	run("Invert", "stack");
	run("Z Project...", "projection=[Max Intensity]");
	run("Keep Largest Region");
	run("Create Selection");
	
	selectWindow(MyTitle);
	run("Restore Selection");
	run("Enlarge...", "enlarge=-100 pixel");
	run("Clear Outside", "stack");
	run("Select None");
	//close("MAX*");
	close("button*");
	close("MAX_buttonMask");
	
	//BAckground remuval
	selectWindow(MyTitle);
	run("Duplicate...", "title=organoidsMask duplicate");
	run("Subtract Background...", "rolling=20 light stack");
	run("Brightness/Contrast...");
	waitForUser("get rid of gray values and saturate organoids edges");
	run("Apply LUT", "stack");
	
	selectWindow("MAX_buttonMask-largest");
	run("Create Selection");
	selectWindow("organoidsMask");
	run("Restore Selection");
	run("Enlarge...", "enlarge=-100 pixel");
	run("Clear Outside", "stack");
	run("Select None");
	
	segmentOrganoids3D("organoidsMask",minParticleSize,maxParticleSize,circularity,prominence);
		
	selectWindow("finalOrganoidMask");
	

	run("Connected Components Labeling", "connectivity=26 type=[16 bits]");
	run("Analyze Regions 3D", "voxel_count volume equivalent_ellipsoid surface_area_method=[Crofton (13 dirs.)] euler_connectivity=6");
	
	IJ.renameResults("Results");	
	//close("finalOrganoidMask");
	
	selectWindow("Results");
	
	
	// Write results:
	if(File.exists(output+File.separator+MyTitle+"_OrganoidsCount.xls")){
		//if exists add and modify
		open(output+File.separator+MyTitle+"_OrganoidsCount.xls");
		Table.reset();
		selectWindow("Results");
		saveAs("Results", output+File.separator+MyTitle+"_OrganoidsCount.xls");
	}
	else
	{
		saveAs("Results", output+File.separator+MyTitle+"_OrganoidsCount.xls");
	
	}
	
	//LABELLED IMAGE
	//OutDir="Z:/DEPARTAMENTO/Imagen/ConBackup/Xabi/Tumatrix/AnalyzedImages";
	//MyTitle="g1.czi"
	
	selectWindow("finalOrganoidMask-lbl");	
	saveAs("Tiff", OutDir+File.separator+MyTitle+"_Labelled.tif");
 	close("*");
	
	
}
	


function segmentOrganoids3D(name,minParticleSize,maxParticleSize,circularity,prominence){
	
	
	/*
	name="organoidsMask";	
	minParticleSize=300;
	maxParticleSize=10000;
	r=0.502;
	prominence=1;
	circularity=0.5;*/
	
	
	selectWindow(name);
	//run("Threshold...");
	setAutoThreshold("Otsu stack");
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Otsu background=Light");
	run("Analyze Particles...", "size="+minParticleSize+"-"+maxParticleSize+" pixel circularity=0-1 show=Masks composite stack");
	close(name);
	selectWindow("Mask of "+name);
	rename(name);
	run("Fill Holes", "stack");
	run("Analyze Particles...", "size=200-Inf pixel circularity="+circularity+"-1 show=Masks composite stack");
	close(name);
	selectWindow("Mask of "+name);
	rename(name);
	run("Median", "radius=1 stack");
	run("Watershed", "stack");
	rename("finalOrganoidMask");
	
	
	/*OPTIONS TO QUANTIFY OBJECTS IN 3D 
	
	/*3D MANAGER
	run("3D Manager Options", "volume fit_ellipse feret objects radial_distance use exclude_objects_on_edges_xy exclude_objects_on_edges_z distance_between_centers=10 distance_max_contact=1.80 drawing=Sphere use_0 use_1");
	run("3D Manager");
	selectWindow(name);
	run("Connected Components Labeling", "connectivity=6 type=[16 bits]");
	selectWindow(name);
	Ext.Manager3D_AddImage();
	Ext.Manager3D_Measure();
	Ext.Manager3D_SaveResult(output+"/OrganoidsCounts.csv");
	Ext.Manager3D_CloseResult();
	Ext.Manager3D_Reset();
	*/
	
	/* SIMPLIFY TO 2D WITH PROJECTIONS
	
	waitForUser;
	run("Z Project...", "projection=[Max Intensity]");
	run("Watershed");
	rename("organoids");
	selectWindow(name);
	run("Duplicate...", "title=organoidsEdges duplicate");
	run("Find Edges","stack");
	run("Z Project...", "projection=[Max Intensity]");
	close("organoidsEdges");
	selectWindow("MAX_organoidsEdges");
	rename("organoidsEdges")
	selectWindow("organoids");
	run("Duplicate...", "title=EDM duplicate");
	run("Distance Map");
	//run("Brightness/Contrast...");
	// transform selection to individual points
	prominence=1;
	run("Find Maxima...", "prominence="+prominence+" light output=[Single Points]");
	run("Find Maxima...", "prominence=1 light output=[Single Points]");
	//print(prominence);
	rename("organoidsMaxima");
	
	// MARKER-CONTROLLED WATERSHED
	run("Marker-controlled Watershed", "input=organoidsEdges marker=organoidsMaxima mask=organoids binary calculate use");
	selectWindow("organoidsEdges-watershed");
	run("8-bit");
	setThreshold(1, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	roiManager("Show None");
	selectWindow("organoidsEdges-watershed");
	rename("finalOrganoidMask");
	close("*Edges*");
	close("*Maxima");
	close("organoids");
	setBatchMode(false);
	*/
			
}

