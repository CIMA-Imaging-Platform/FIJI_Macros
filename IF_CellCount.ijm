
// changelog Sept2018
// Automatic positive cell detection when they have blue+red and NO green


function macroInfo(){
	
// * Quantification of Brown WSI Images Area  
// * Target User: General
// *  

	scripttitle= "Quantifiaction of Cell Phenotype on Selected Channel";
	version= "1.03";
	date= "2018";
	

// *  Tests Images:

	imageAdquisition="Aperio: BrightField Whole Slide Images.";
	imageType="RGB";  
	voxelSize="Voxel size:  0.502 um xy";
	format="Format: Uncompressed .jpg";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button 
	
	parameter1="Resolution (micra pixel ratio) = 0.502 micras/pixel xy"; 
	parameter2="Channel to Quantify";
	parameter3="Min particle size (px)";
	parameter4="Circularity Filter: Introduce value between [0,1]. [0 Non circle morphology , 1 Perfect Circle]";
	 

 //  2 Action tools:
	buttom1="Im: Single File processing";
	buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs

	excel="QuantifiedImages.xls";
	feature1="Image Label";
	feature2="# cells";
	feature3="AverageSize [micras^2]";
	
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
	    +"<ol><font size=2  i><li>"+buttom1+"</li>"
	    +"<li>"+buttom2+"</li></ol>"
	    +"<p><font size=3  i>PARAMETERS: Right Click on Action tools  </i></p>"
	    +"<ul id=list-style-3><font size=2  i>"
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li>"
	    +"<li>"+parameter3+"</li>"
	    +"<li>"+parameter4+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}



var ch=1, th=20, minParticleSize=20, r=0.502, prominence=5, circularity=0.8;

macro "CellCountAuto Action Tool - C0f0T4d14C"{	
	
	/*
	ch=1;
	th=20;
	minParticleSize=100;
	r=0.502;
	prominence=5;
	circularity=0.8;
	*/
	
	//Initialize conditions
	roiManager("Reset");
	run("Clear Results");
	run("Colors...", "foreground=black background=white selection=yellow");
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

	
	// IMAGE CHANNELS ADJUSTMENT
	run("Duplicate...", "title=orig duplicate");
	selectWindow("orig");
	run("Split Channels");
	
	//  channel to Quantify
	selectWindow("C"+ch+"-orig");
	run("Z Project...", "projection=[Max Intensity]");
	selectWindow("MAX_C"+ch+"-orig");
	rename("MaxZProjection");
	close("C*");
	
	/// AUTOMATIC SEGMENTATION BASED ON SELECTED CHANNEL
	
	selectWindow("MaxZProjection");		
	run("Select All");
	run("Subtract Background...", "rolling=100");
	run("Threshold...");
	setAutoThreshold("Default dark no-reset");
	//Let the user choose the threshold
	waitForUser("Select Threshold for Nucleus Segmentation");
	getThreshold(lower, upper);
	setThreshold(lower, upper);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=2");
	run("Fill Holes");
	run("Median...", "radius=2");
	// EDM + Watershed
	run("Duplicate...", "title=SegmentCells");
	run("Distance Map");
	rename("EDM");
	//prominence=5;
	run("Find Maxima...", "prominence="+prominence+" light output=[Segmented Particles]");
	run("Invert");
	selectWindow("MaxZProjection");
	run("Invert");
	imageCalculator("OR", "MaxZProjection","EDM Segmented");
	selectWindow("MaxZProjection");
	run("Invert");
	//minParticleSize=20;
	//Size & Circularity Filter: Show Results 
	run("Analyze Particles...", "size="+minParticleSize+"-Infinity pixel circularity="+circularity+"-1.00 show=Masks display exclude clear add in_situ");		
	nCells=nResults;
	//Compute Mean Std of Area Column
	run("Summarize");
	
	averageSize=getResult("Area",nCells);
	stdSize=getResult("Area",nCells+1);
	//Array.print(averageSize,stdSize);

	close("M*");close("E*");
	

	// Write results:
	run("Clear Results");
	if(File.exists(output+File.separator+"Total.xls"))
	{
		//if exists add and modify
		open(output+File.separator+"Total.xls");
		i=nResults;
		setResult("Label", i, MyTitle); 	
		setResult("# cells", i, nCells); 
		setResult("AverageSize [micras^2]", i, averageSize);
		setResult("stdSize [micras^2]", i, stdSize);
		saveAs("Results", output+File.separator+"Total.xls");
		
	}
	else
	{
		setResult("Label", 0, MyTitle); 
		setResult("# cells", 0, nCells); 
		setResult("AverageSize [micras^2]", 0, averageSize);
		setResult("stdSize [micras^2]", 0, stdSize);
		saveAs("Results", output+File.separator+"QuantifiedImages.xls");
		
	}
	
	selectWindow(MyTitle);
	run("Z Project...", "projection=[Max Intensity]");
	run("Split Channels");
	run("Merge Channels...", "c1=C1-MAX_"+MyTitle+" c3=C2-MAX_"+MyTitle);
	roiManager("Set Color", "yellow");
	roiManager("Set Line Width", 1);
	roiManager("Show All");
	run("Flatten");
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_nCells.tif");
 	close("\\Others");
	
		
}
	
	
	macro "CellCountAuto Action Tool Options" {
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
	}
