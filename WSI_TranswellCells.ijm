function macroInfo(){
	
// * Quantification of Brown WSI Images Area  
// * Target User: General
// *  

	scripttitle= "Quantification of High Intensity Stained Cells in Transwell";
	version= "1.03";
	date= "2023";
	

// *  Tests Images:

	imageAdquisition="Microscope: BrightField Images.";
	imageType="RGB";  
	voxelSize="Voxel size:  0.502 um xy";
	format="Format: Uncompressed /.czi";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button 
	 //parameter1="Resolution (micra pixel ratio) = 0.502 micras/pixel xy"; 
	 parameter1="Tissue Threshold (8bit) = Separate Tissue from Background";
	 parameter1="Cells Threshold (8bit) = Separate Cells from Tissue";
	 parameter1="Min Cell Size (pixels)";
 //  2 Action tools:
	 buttom1="Im: Single File processing";
	 buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs

	excel="QuantificationResults_WSI_TransWellCells.xls";
	feature1="Image Label";
	feature2="Tissue Area (micra²)";
	feature3="Cells area (micra²)";
	feature4="Ratio Area Cells stained/Area Tissue(%)"

/*  	  
 *  version: 1.02 
 *  Author: Mikel Ariz  
 *  Commented by: Tomas Muñoz 2023 
 *  Date : 2023
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
	    +"<li>"+parameter1+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}


// changelog September 2022

var thTissue=235, thCells=80, minCellSize=140;	

macro "TranswellCells Action Tool 1 - Cf00T2d15IT6d10m"{
	
	close("*");
	
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	
	macroInfo();
	
	Dialog.create("PARAMETERS FOR THE ANALYSIS");
	Dialog.addSlider("Threshold for Tissue Segmentation  ", 0, 255, thTissue); 
	Dialog.addSlider("Threshold for Cell Segmentation  ", 0, 255, thCells); 
	Dialog.addNumber("Min Cell Size (pixels)", minCellSize);	
		
	Dialog.show();	
	
	thTissue= Dialog.getNumber();
	thCells= Dialog.getNumber()
	minCellSize= Dialog.getNumber()
		
	//setBatchMode(true);
	print(name);
	transwellcells("-","-",name,thTissue,thCells,minCellSize);
	setBatchMode(false);
	showMessage("Done!");

		}
macro "TranswellCells Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	close("*");
	
	InDir=getDirectory("Choose a Directory");
	list=getFileList(InDir);
	L=lengthOf(list);
	
	macroInfo();
		
	Dialog.create("PARAMETERS FOR THE ANALYSIS");
	Dialog.addSlider("Threshold for Tissue Segmentation  ", 0, 255, thTissue); 
	Dialog.addSlider("Threshold for Cell Segmentation  ", 0, 255, thCells); 
	Dialog.addNumber("Min Cell Size (pixels)", minCellSize);	

	Dialog.show();	
	
	thTissue= Dialog.getNumber();
	thCells= Dialog.getNumber()
	minCellSize= Dialog.getNumber()

	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"tif")||endsWith(list[j],"czi")){
				//analyze
				//d=InDir+list[j]t;
				name=list[j];
				print(name);
				//setBatchMode(true);
				transwellcells(InDir,InDir,list[j],thTissue,thCells,minCellSize);
				setBatchMode(false);
		}
	}
		showMessage("Done!");
}


function transwellcells(output,InDir,name,thTissue,thCells,minCellSize)
{
	

	
	run("Close All");
	
	if(endsWith(name,"czi")) {
		if (InDir=="-") {
			run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
			}
		else {
			run("Bio-Formats Importer", "open=["+InDir+name+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
			}	
	}
	else {
		if (InDir=="-") {
			open(name);
		}
		else {
			open(InDir+name); 
		}	
	}
	
	
	
	/*	
	thTissue=235;
	thCells=80;
	minCellSize=140;	
	*/
	
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	run("Colors...", "foreground=white background=black selection=green");
	
	getDimensions(width, height, channels, slices, frames);
	if (channels >1){
		Stack.setDisplayMode("composite");
		// Create RGB image to work with:
		run("RGB Color");
		rename("orig");
		selectWindow(MyTitle);
		close();
	}else{
		rename("orig");
	
	}
	
	setBatchMode(true);
	
	// DETECT TISSUE
	showStatus("Detecting tissue...");
	run("RGB to Luminance");
	rename("a");
	run("Threshold...");
	//setAutoThreshold("Huang");
	//getThreshold(lower, upper);
		//thTissue=235;
	setThreshold(0, thTissue);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=12");
	run("Analyze Particles...", "size=50000-Infinity pixel show=Masks in_situ");
	run("Invert");
	run("Analyze Particles...", "size=300-Infinity pixel show=Masks in_situ");
	run("Invert");
	run("Create Selection");
	run("Select All");
	run("Add to Manager");	// ROI0 --> whole tissue
	selectWindow("a");
	close();
	
	// SEGMENT CELLS--
	run("Duplicate...", "title=cellMask");
	run("8-bit");
	run("Mean...", "radius=2");
	  //setThreshold(0, 135);
	setThreshold(0, thCells);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=1");
	run("Analyze Particles...", "size=140-Infinity show=Masks in_situ");
	run("Analyze Particles...", "size="+minCellSize+"-Infinity show=Masks in_situ");
	run("Select None");
	roiManager("Select", 0);
	setBackgroundColor(255,255,255);
	run("Clear Outside");
	run("Create Selection");
	run("Add to Manager");	// ROI1 --> Cells in tissue
	close();

	// RESULTS--
	run("Clear Results");
	selectWindow("orig");	
	run("Set Measurements...", "area redirect=None decimal=2");
	
	// Tissue
	roiManager("select", 0);
	roiManager("Measure");
	At=getResult("Area",0);
	
	// Cells
	roiManager("select", 1);
	roiManager("Measure");
	Ap=getResult("Area",1);
	
	// Ratio
	r1=Ap/At*100;
	
	run("Clear Results");
	if(File.exists(output+File.separator+"QuantificationResults_WSI_TranswellCells.xls"))
	{
		
		//if exists add and modify
		open(output+File.separator+"QuantificationResults_WSI_TranswellCells.xls");
		IJ.renameResults("Results");
	}
	i=nResults;
	setResult("[Label]", i, MyTitle); 
	setResult("Tissue area (um2)",i,At);
	setResult("Cells area (um2)",i,Ap);
	setResult("Ratio Acells/Atissue (%)",i,r1);			
	saveAs("Results", output+File.separator+"QuantificationResults_WSI_TranswellCells.xls");
		
	
	// DRAW--
	setBatchMode("exit and display");

	selectWindow("orig");
	roiManager("Show None");
	run("Select None");
	roiManager("Select", 0);
	roiManager("Set Color", "red");
	run("Flatten");
	roiManager("Show None");
	roiManager("Select", 1);
	roiManager("Set Color", "green");
	run("Flatten");
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	rename(MyTitle_short+"_analyzed.jpg");
	
	close("orig*");
	
	if (InDir!="-") {
	close(); }
	
	//showMessage("Done!");

}