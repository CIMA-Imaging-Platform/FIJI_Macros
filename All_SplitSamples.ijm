
function macroInfo(){

// * Title

	scripttitle= "Automatic IF WSI Split -> from Multi Tissue WSI to Single Tissue WSI ";
	version= "1.01";
	date= "2024";
	
// *  Tests Images:

	imageAdquisition=" VECTRA POLARIS Images";
	imageType="2D 8 bit ";  
	voxelSize="Voxel size: unknown um xy";
	format="Format: Uncompressed .qptiff";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button 
	
	parameter1="Number of channels"; 
	 
 //  2 Action tools:
	buttom1="Im: Single File processing --> Crop based on size";
 	buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs

	feature1="CropSamples Folders: individual images, jpg format ";
	
/*
 *  version: 1.01 
 *  Author: Tomas Muñoz  2024 
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
	    +"<ol><font size=2  i><li>"+buttom1+"</li><li>"+buttom2+"</li></ol>"
	    +"<p><font size=3  i>PARAMETERS: </i></p>"
	    +"<ul id=list-style-3><font size=2  i>"
	    +"<li>"+parameter1+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}


var nSamples=3; 

macro "IF_SplitSamples Action Tool 1 - Sa3fT0b10CT8b10PTfb10LTfb10I"{
	
	close("*");
	macroInfo();
	
	/* TESTING PARAMS
	cDAPI=1;
	cSMA=3;
	cCAV=2;
	nuclEnlargement=2;
	*/
		
	// Open just one file
	name=File.openDialog("Select File");	
	run("Bio-Formats", "open=["+name+"] autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT");
		
	Dialog.create("SplitSamples");
	Dialog.addNumber("Number of Samples", nSamples);
	Dialog.show();	
	nSamples= Dialog.getNumber();
	
	OutDir=getDir("SELECT OUTPUT DIRECTORY");
				
	// Clear initialization of ROI manager and results table
	run("Collect Garbage");
	roiManager("Reset");
	run("Clear Results");
	RoiManager.associateROIsWithSlices(true);
	setOption("ExpandableArrays", true);
	setOption("WaitForCompletion", true);
	
	// Set color configuration and measurements
	run("Colors...", "foreground=white background=black selection=green");
	run("Set Measurements...", "area mean redirect=None decimal=2");
		
	// Set batch mode 
	setBatchMode(false);
	
	// Get file information
	MyTitle=getTitle();
	print(MyTitle);
	output=getInfo("image.directory");
		
	//OutDir = output+File.separator+"SplitSamples";
	//File.makeDirectory(OutDir);
		
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	getDimensions(width, height, channels, slices, frames);
	getVoxelSize(width, height, depth, unit);
		
	// TISSUE SEGMENTATION

	selectWindow(MyTitle);
	rename(MyTitle_short);
	run("RGB Color");
	run("RGB to Luminance");
	rename("tissueMask");
	close("*RGB*");	
	setAutoThreshold("Huang dark no-reset");
	//run("Threshold...");
	//setThreshold(7, 255);
	run("Convert to Mask");
	run("Fill Holes");
	run("Dilate");
	run("Dilate");
	run("Dilate");
	
	//run("Analyze Particles...", "size=10000-Infinity pixel show=Nothing display add");
	//roiManager("Show None");
	
	/* METHOD TO JOIN POSSIBLE TISSUES
	// Create an array of indices for the table rows
	n = nResults;
	roiID = Array.slice(Array.getSequence(n + 1), 0, n);
	sampleSizes=Table.getColumn("Area");
		
	// Sort the table based on the specified column
	Array.sort(sampleSizes, roiID);
	
	//Array.print(sampleSizes);
	//Array.print(roiID);

	
	nRois=lengthOf(sampleSizes);
	
	setForegroundColor(0,0,0);
	setBackgroundColor(255,255,255);

	nSamples=3;
	for (i = 0; i < nSamples; i++) {
		roiManager("select", roiID[nRois-1-i]);
		run("Convex Hull");
		run("Fill");
	
	}
	
	run("Collect Garbage");
	roiManager("Reset");
	run("Clear Results");
	

	*/
	
	// Create an array of indices for the table rows
	selectWindow("tissueMask");
	run("Analyze Particles...", "size=10000-Infinity pixel show=Nothing display add");
	roiManager("Show None");
	
	n = nResults;
	roiID = Array.slice(Array.getSequence(n + 1), 0, n);
	sampleSizes=Table.getColumn("Area");
		
	// Sort the table based on the specified column
	Array.sort(sampleSizes, roiID);
	//nSamples=3;
	
	nRois=lengthOf(sampleSizes);
	
	//Array.print(sampleSizes);
	//Array.print(roiID);
	
	for (i = 0; i < nSamples; i++) {
		selectWindow(MyTitle_short);
		roiManager("select", roiID[nRois-1-i]);
		run("To Bounding Box");
		run("Enlarge...", "enlarge=100");
		run("Duplicate...", "title="+MyTitle_short+"_Sample"+(i+1)+" duplicate");
		
		//saveAs("Tiff", OutDir+MyTitle_short+"_Sample"+(i+1)+".tif");
		saveAs("Tiff",OutDir+File.separator+MyTitle_short+"_Sample"+(i+1)+".tif");
		close();
		run("Collect Garbage");
		selectWindow(MyTitle_short);
		run("Select None");
	}
	close("tissueMask");
	setBatchMode("exit and display");
	showMessage(MyTitle+" Samples Saved in: "+OutDir);
	close("*");


}		
	
	



