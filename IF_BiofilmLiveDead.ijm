function macroInfo(){
	
// * Title  
	scripttitle =  "Bacteria - Live Dead Quantification";
	version =  "1.02";
	date =  "2023";
	

// *  Tests Images:

	imageAdquisition = "IF Confocal 2 Channel: GFP - IP  ";
	imageType = "2D - 8 bit";  
	voxelSize = "Voxel size:  unknown";
	format = "Format: czi";   
 
 //*  GUI User Requierments:
 //  	- save and load previous ROIS --> todo
 //*    - Interactive Threshold. --> done
 //*	- Delete Unwanted tissue and SR positive--> done
 //		- Single File and Batch Mode --> done
 //*    
 // Important Parameters: 
 
 	 parameter1 = "Threshold for Dead bacteria";
	 parameter2 = "Min bacteria size (px)";
	 
	  
 //  2 Action tools:
		
	 buttom1 = "Im: Single File processing. Use Single file processing for fine tunning parameters";
	 buttom2 = "Dir: Batch Mode. Please tune parameters before using Batchmode";

//  OUTPUT

// Analyzed Images with ROIs

	excel = "QuantificationResults_IF_BiofilmLiveDead.xls";
	
	feature1 ="Label"; 
	feature2 ="Calculated threshold for live";
	feature3 ="Calculated threshold for dead";
	feature4 ="Total biofilm (um2)";
	feature5 ="Live biofilm (um2)";
	feature6 ="Dead biofilm (um2)";
	feature7 ="Alive/Abiofilm (%)";
	feature8 ="Adead/Abiofilm (%)";
	
//run("Synchronize Windows");
	
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
	    +"<p><font size = 3  i>PARAMETERS:</i></p>"
	    +"<ul id = list-style-3><font size = 2  i>"
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li></ul>"
	    +"<p><font size = 3  i>Quantification Results: </i></p>"
	    +"<p><font size = 3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size = 3  i>Excel "+excel+"</i></p>"
	    +"<ul id = list-style-3><font size = 2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li><li>"+feature5+"</li><li>"+feature6+"</li><li>"+feature7+"</li><li>"+feature8+"</li></ul>"
	    +"<h0><font size = 5></h0>"
	    +"");
	   //+"<P4><font size = 2> For more detailed instructions see "+"<p4><a href = https://www.protocols.io/edit/movie-timepoint-copytoclipboaMarker2-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}



// changelog February 2022
// Segmentation of the biofilm in 3D
// Quantification of biofilm volume

var cBiofilm=1, cMarker1=2, thBac=60, thBacDead=40, minBacSize=10;

macro "IF_BiofilmLiveDead Action Tool 1 - Cf00T2d15IT6d10m"{
	
	run("Close All");
	
	macroInfo();
	
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	print("Processing "+name);
		
	Dialog.create("PARAMETERS");
	//Dialog.addSlider("Threshold for all bacteria", 0,255, thBac);
	Dialog.addSlider("Threshold for dead bacteria", 0,255, thBacDead);
	Dialog.addNumber("Min bacteria size (px)", minBacSize);	
	Dialog.show();	
	
	//thBac= Dialog.getNumber();
	thBacDead= Dialog.getNumber();
	minBacSize= Dialog.getNumber();
	
	IF_BiofilmLiveDead("-","-",name,thBac,thBacDead,minBacSize);

	setBatchMode(false);
	showMessage("Biofilm quantified!");

}

macro "IF_BiofilmLiveDead Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	run("Close All");
	
	InDir=getDirectory("Choose Tiles' directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("PARAMETERS");
	//Dialog.addSlider("Threshold for all bacteria", 0,255, thBac);
	Dialog.addSlider("Threshold for dead bacteria", 0,255, thBacDead);
	Dialog.addNumber("Min bacteria size (px)", minBacSize);	
	Dialog.show();	
	
	//thBac= Dialog.getNumber();
	thBacDead= Dialog.getNumber();
	minBacSize= Dialog.getNumber();

	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"czi") || endsWith(list[j],"tif")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print("Processing "+name);
			//setBatchMode(true);
			IF_BiofilmLiveDead(InDir,InDir,list[j],thBac,thBacDead,minBacSize);
			//biofilm4d(InDir,InDir,list[j],thBac,minBacSize);
			setBatchMode(false);
			}
	}
	
	showMessage("Biofilm quantified!");

}

function  IF_BiofilmLiveDead(output,InDir,name,thBac,thBacDead,minBacSize){

	run("Close All");
	
	if (InDir == "-") {
		run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");	
		//open(name);
	}else{

		run("Bio-Formats Importer", "open=["+InDir+name+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		//open(InDir+name);
	}
			
	roiManager("Reset");
	run("Clear Results");
	
	MyTitle=getTitle();
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	output=getInfo("image.directory");
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	rename(MyTitle_short);
		
	setBatchMode(true);
			
	run("Set Measurements...", "area mean redirect=None decimal=2");
	run("Colors...", "foreground=white background=black selection=yellow");
	run("Options...", "iterations=1 count=1");
		
    // Calculate total live biofilm 
	run("Duplicate...", "title=totalBiofilm duplicate");
    selectWindow("totalBiofilm");
    
    // Calculate total scanned volume (FOV)
    getVoxelSize(vx, vy, vz, unit);
    Stack.getDimensions(width, height, channels, slices, frames);
    FOV = 1024 * 1024 * vx * vy ; // Volume in cubic microns
    
    if (slices>1){
	 	 // Find Slice with Max Signal
		
		run("Select All");
		Stack.setChannel(2);
		run("Measure Stack...", "slices order=czt(default)");
		selectWindow("Results");
		meanSliceI=Table.getColumn("Mean");
		Array.getStatistics(meanSliceI, min, max, mean, stdDev);
		//Array.print(newArray(min, max, mean, stdDev));
		maxMarker1=Array.findMaxima(meanSliceI,stdDev);
		//Array.print(maxMarker1);
		selectWindow("totalBiofilm");
		if (maxMarker1[0]==0){
			run("Duplicate...", "title=slice duplicate slices=1");
		}else{
			run("Duplicate...", "title=slice duplicate slices="+maxMarker1[0]);
		}
		run("Clear Results");
	}
	
	close("totalBiofilm");
	selectWindow("slice");
	run("Make Composite");
	run("RGB Color");
	run("RGB to Luminance");
	rename("totalBiofilm");
	close("*RGB*");
	
	selectWindow("totalBiofilm");
    // Preprocessing steps to enhance image quality
    run("Subtract Background...", "rolling=100 stack");
    run("Median...", "radius=1 stack");
    run("Unsharp Mask...", "radius=5 mask=0.60 stack");
       
	setAutoThreshold("Huang dark");
	getThreshold(thBiofilm, upper);
	//setThreshold(25, 255);
	run("Convert to Mask", "method=Huang background=Dark");
	
	run("Median...", "radius=1 stack");
	minBacSize = 10;
    run("Analyze Particles...", "size=" + minBacSize + "-Infinity pixel show=Masks in_situ");
    run("Clear Results");
    
     run("Create Selection");
	totalBiofilmArea=getValue("Area");
	Roi.setName("totalBiofilm");
	roiManager("add");
	run("Select None");
	
	// Calculate total dead biofilm 
	selectWindow("slice");
    run("Remove Overlay");
    run("Select None");
	//run("Duplicate...", "title=dead channels=1 slices="+maxMarker1[0]);
	Stack.setChannel(1);
	run("Duplicate...", "title=dead channels=1");
	selectWindow("dead");
		
    // Preprocessing steps to enhance image quality
    run("Subtract Background...", "rolling=50 stack");
    run("Median...", "radius=1 stack");
	// run("Unsharp Mask...", "radius=5 mask=0.60 stack");
	run("Enhance Contrast", "saturated=0.1");
	//run("Apply LUT");

   	//Segmentation
   	setThreshold(40, 255);
   	//setThreshold(thBacDead, 255);
   	setOption("BlackBackground", false);
	run("Convert to Mask","method=Huang background=Dark");
	run("Make Binary");
	
	run("Morphological Filters", "operation=Closing element=Disk radius=2");
	minBacSize = 5;
    run("Analyze Particles...", "size=" + minBacSize + "-Infinity pixel show=Masks in_situ");
  	run("Dilate");    
   
  	run("Clear Results");  
    run("Create Selection");
    deadArea=getValue("Area");
	Roi.setName("dead");
	roiManager("add"); 
	close("dead");
	selectWindow("dead-Closing");
	rename("dead");
	
	imageCalculator("Subtract create", "totalBiofilm","dead");
	minBacSize = 5;
    run("Analyze Particles...", "size=" + minBacSize + "-Infinity pixel show=Masks in_situ");
	rename("live");
	run("Create Selection");
	liveArea=getValue("Area");
	Roi.setName("live");
	roiManager("add");
	run("Select None");
	
	close("TotalBiofilm");
	close("live");
	close("dead");

    rLive = (liveArea / totalBiofilmArea ) * 100; 
    rDead = (deadArea / totalBiofilmArea ) * 100; 
     

     
	// Save quantification results for the current frame
    run("Clear Results");
    if (File.exists(output + File.separator + "QuantificationResults_IF_BiofilmLiveDead.xls")) {
        open(output + File.separator + "QuantificationResults_IF_BiofilmLiveDead.xls");
        IJ.renameResults("Results");
    }
   	    
    j = nResults; // Append new results to existing table
    setResult("[Label]", j, MyTitle);
    setResult("ThBacteria", j, thBiofilm);
    setResult("thDead", j, thBacDead);
    setResult("FOV Area (um^2)", j, FOV);
    setResult("TotalBiofilm Area (um^2)", j, totalBiofilmArea);
    setResult("Dead Biofilm Area (um^2)", j, deadArea);
    setResult("Live Biofilm Area (um^2)", j, liveArea);
    setResult("Ratio Live/TotalVolume (%)", j, rLive);
   	setResult("Ratio Dead/TotalVolume (%)", j, rDead);
     
    saveAs("Results", output + File.separator + "QuantificationResults_IF_BiofilmLiveDead.xls");	
    
    selectWindow("slice");
	RoiManager.selectByName("live");
	Roi.setStrokeColor("green");
	Overlay.addSelection;
	Overlay.setPosition(1, 0, 0);
	RoiManager.selectByName("dead");
	Roi.setStrokeColor("red");
	Overlay.addSelection;
	Overlay.setPosition(1, 0, 0);
	    
	saveAs("Tiff", output+File.separator+"AnalyzedImages"+File.separator+MyTitle+"_LifeDead_Overlay.tif");
   
   	//Clear unused memory
	wait(500);
	run("Collect Garbage");
	
	close("\\Others");
	
}
