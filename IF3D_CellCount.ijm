
// changelog Sept2018
// Automatic positive cell detection when they have blue+red and NO green


function macroInfo(){
	
// * Quantification of Brown WSI Images Area  
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



var ch=1, th=20, minParticleSize=20, maxParticleSize=1000,, r=0.502, prominence=1, circularity=0.0;


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
	Dialog.addNumber("Max Particle size (px)", ch);
    Dialog.addNumber("Min particle size (px)", minParticleSize);
    Dialog.addNumber("Circularity Filter)", circularity);	
	Dialog.show();
	r= Dialog.getNumber();
	maxParticleSize= Dialog.getNumber();
	minParticleSize= Dialog.getNumber(); 
	circularity= Dialog.getNumber(); 		
	
	//setBatchMode(true);
	organoidCount("-","-",name,r,maxParticleSize,minParticleSize,circularity);
			
	setBatchMode(false);
	showMessage("Cells quantified!");

}
/*
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
	Dialog.addNumber("Channel to Quantify", ch);
    Dialog.addNumber("Min particle size (px)", minParticleSize);
    Dialog.addNumber("Circularity Filter)", circularity);	
	Dialog.show();
	r= Dialog.getNumber();
	ch= Dialog.getNumber();
	minParticleSize= Dialog.getNumber(); 
	circularity= Dialog.getNumber(); 		
	
	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"czi")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print("Processing "+name);
			//setBatchMode(true);
			organoidCount(InDir,InDir,list[j],r,ch,minParticleSize,circularity);
			setBatchMode(false);
			}
	}
	
	showMessage("Cells quantified!");

}

*/

function organoidCount(output,InDir,name,r,maxParticleSize,minParticleSize,circularity)
{	

	run("Close All");

	if (InDir=="-") {
		run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
		}
	else {
		run("Bio-Formats Importer", "open=["+InDir+name+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
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
	run("Colors...", "foreground=white background=black selection=yellow");
	run("Set Measurements...", "area redirect=None decimal=2");
	run("Set Scale...", "distance=1 known="+r+" unit=micron");

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
	
	// IMAGE CHANNELS ADJUSTMENT
	run("Duplicate...", "title=orig duplicate");
	selectWindow("orig");
	run("Split Channels");
	
	//  channel to Quantify
	selectWindow("C"+ch+"-orig");
	run("Z Project...", "projection=[Max Intensity]");
	selectWindow("MAX_C"+ch+"-orig");
	rename("MaxZProjection");
	
	segmentOrganoids("MaxZProjection",prominence);
	
	selectWindow("finalNucleusMask");
	
	//minParticleSize=20;
	//circularity=0;
	//Size & Circularity Filter: Show Results 
	run("Analyze Particles...", "size="+minParticleSize+"-Infinity pixel circularity="+circularity+"-1.00 show=Masks display clear add in_situ");		
	close("finalNucleusMask");
	nCells=nResults;
	//Compute Mean Std of Area Column
	run("Summarize");
	
	averageSize=getResult("Area",nCells);
	stdSize=getResult("Area",nCells+1);
	//Array.print(averageSize,stdSize);

	close("M*");close("E*");
	
	
	
	// Write results:
	run("Clear Results");
	if(File.exists(output+File.separator+"QuantifiedImages.xls")){
		//if exists add and modify
		open(output+File.separator+"QuantifiedImages.xls");
		IJ.renameResults("Results");
		i=nResults;
		print(i);
		setResult("[Label]", i, MyTitle); 	
		setResult("# cells", i, nCells); 
		setResult("AverageSize [micras^2]", i, averageSize);
		setResult("stdSize [micras^2]", i, stdSize);
		saveAs("Results", output+File.separator+"QuantifiedImages.xls");
		
	}
	else{
		setResult("[Label]", 0, MyTitle); 
		setResult("# cells", 0, nCells); 
		setResult("AverageSize [micras^2]", 0, averageSize);
		setResult("stdSize [micras^2]", 0, stdSize);
		saveAs("Results", output+File.separator+"QuantifiedImages.xls");
		
	}
	
		
	selectWindow(MyTitle);
	run("Z Project...", "projection=[Max Intensity]");
	print(MyTitle);
	run("Split Channels");
	//MyTitle="ARPE19 P96 TUNEL A1 1% 20X2.czi";
	run("Merge Channels...", "c1=[C1-MAX_"+MyTitle+"] c3=[C2-MAX_"+MyTitle+"]");
	roiManager("Set Color", "yellow");
	roiManager("Set Line Width", 1);
	roiManager("Show All without labels");
	run("Flatten");
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_nCells.tif");
 	close("\\Others");
	
	
}
	


function segmentNucleus(image,prominence) 
{	
	setBatchMode(false);
	image="MaxZProjection";
	print("Segmenting Nucleus....");
	selectWindow(image);
	run("Duplicate...", "title=SegNucleus");
	run("Subtract Background...", "rolling=150");
	run("Threshold...");
	setAutoThreshold("Default dark no-reset");
	setOption("BlackBackground", true);
	//thNucleus=800;
	waitForUser("Select Threshold for Nucleus Segmentation");
	getThreshold(lower, upper);
	setThreshold(lower, upper);
	
	run("Convert to Mask");
	run("Analyze Particles...", "size=20-Infinity pixel show=Masks");
	run("Convert to Mask");
	close("SegNucleus");
	selectWindow("Mask of SegNucleus");
	rename("SegNucleus");
	setBatchMode(true);
	close("Threshold");
	//run("Fill Holes");
	run("Median...", "radius=2 stack");
	run("Watershed");
	run("Duplicate...", "title=SegNucleus-1");
	run("Distance Map");
	waitForUser;
	// transform selection to individual points
	//prominence=1;
	run("Find Maxima...", "prominence="+prominence+" output=[Single Points]");
	//print(prominence);
	rename("nucleusMaxima");
	
	selectWindow("SegNucleus");
	run("Duplicate...", "title=edgesNucleus");
	run("Find Edges");
	
	// MARKER-CONTROLLED WATERSHED
	run("Marker-controlled Watershed", "input=edgesNucleus marker=nucleusMaxima mask=SegNucleus binary calculate use");
	selectWindow("edgesNucleus-watershed");
	run("8-bit");
	setThreshold(1, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	roiManager("Show None");
	selectWindow("edgesNucleus-watershed");
	rename("finalNucleusMask");
	close("SegNucleus*");
	close("nucleusMaxima");
	close("edgesNucleus");
	setBatchMode(false);
		
}

