// changelog November 2022

// Manual selection of area of analysis
// Automatic tissue detection
// Possibility of deleting regions of tissue
// Automatic detection of capillaries in DAB
// Manual edition of detected capillaries

function macroInfo(){
	
// * Automatic Quantification of DAB stained Capillaries
// * Target User: Maria Gonzalez Cardio
// *  

	scripttitle= "Automatic Quantification of DAB stained Capillaries ";
	version= "1.03";
	date= "2022";
	

// *  Tests Images:

	imageAdquisition="Aperio: BrightField Whole Slide Imaging Images.";
	imageType="RGB";  
	voxelSize="Voxel size:  0.502 um xy";
	format="Format: Uncompressed .jpg / tiff ";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters:  

	 parameter1="Resolution (micra pixel ratio) = 0.502 micras/pixel xy"; 
	 parameter2="Tissue Threshold (8bit) = Separate Tissue from Background";
	 parameter3="Capillary Marker Threshold (8bit)= Separate Brown(+) ROIs form Brown(-) ROIs";
	 parameter4="Threshold for nuclei segmentation (8bit)";
	 parameter5="Min size of stained particles (um2): Size Filter.";
	 parameter6="Max size of stained particles (um2): Size Filter.";
	 parameter7="Max Lumen size : Size Filter.";
	  
 //  2 Action tools:
	 buttom1="Cap: Single File processing. Quantify # of capillaries";
	 buttom2="Area: Single File processing. Quantify Area of capillaries. ";

//  OUTPUT

// Analyzed Images with ROIs

	excel="Quantification_capillaries_area.xls";
	feature1="Image Label";
	feature2="Analyzed area of tissue (um2)";
	feature3="Area of capillaries (um2)";
	feature4="Ratio Acap/Atot (%)";
	feature5="# Capillaries";

	excel2="Quantification_capillaries.xls";

/*  	  
 *  version: 1.02 
 *  Author: Mikel Ariz  
 *  Commented by: Tomas Muñoz 2023 
 *  Date : // Changelog June 2022
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
	    +"<ul id=list-style-3><font size=2  i><li>"+imageAdquisition+"</li><li>"+imageType+"</li><li>"+voxelSize+"</li><li>"+format+"</li></ul>"
	    +"<p><font size=3 i>Action tools (Buttons)</i></p>"
	    +"<ol><font size=2  i><li>"+buttom1+"</li>"
	    +"<li>"+buttom2+"</li></ol>"
	    +"<p><font size=3  i>PARAMETERS: Right Click on Action tools  </i></p>"
	    +"<ul id=list-style-3><font size=2  i>"
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li>"
	    +"<li>"+parameter3+"</li>"
	    +"<li>"+parameter4+"</li>"
	    +"<li>"+parameter5+"</li>"
	    +"<li>"+parameter6+"</li>"
	    +"<li>"+parameter7+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel2+"</i></p>"
	    +"<ul id=list-style-3><font size=2 i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature5+"</li></ul>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li><li>"+feature5+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}



var r=0.502, thTissue=254, thBlue=180, thCap=220, minSizeUm=17.5, maxSizeUm=2000, maxLumenSizeUm=1250;		// Escáner 20x

macro "CapillaryDAB Action Tool 1 - Cf00T0d12CT8d12aTfd12p"{
	
	run("Close All");
	
	//just one file
	name=File.openDialog("Select image file");
	//print(name);
	print("Processing "+name);
	
	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Choose parameters")	
	Dialog.addNumber("Ratio micra/pixel", r);		
	Dialog.addNumber("Threshold for tissue segmentation", thTissue);
	Dialog.addNumber("Threshold for capillary segmentation", thCap);
	Dialog.addNumber("Threshold for nuclei segmentation", thBlue);
	Dialog.addNumber("Min capillary size (um2)", minSizeUm);	
	Dialog.addNumber("Max capillary size (um2)", maxSizeUm);
	Dialog.addNumber("Max lumen size (um2)", maxLumenSizeUm);		
	Dialog.show();	
	
	r= Dialog.getNumber();
	thTissue= Dialog.getNumber();
	thCap= Dialog.getNumber(); 	
	thBlue= Dialog.getNumber(); 		
	minSizeUm= Dialog.getNumber(); 		
	maxSizeUm= Dialog.getNumber(); 
	maxLumenSizeUm= Dialog.getNumber(); 
			
	
	open(name);
	
	minSize = round(minSizeUm/(r*r));
	maxSize = round(maxSizeUm/(r*r));
	maxLumenSize = round(maxLumenSizeUm/(r*r));
	
	
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	run("Colors...", "foreground=black background=white selection=green");
	run("Set Measurements...", "area mean area_fraction redirect=None decimal=2");
	
	
	rename("orig");
	
	//--Correct background by using the mode for contrast adjustment previously balancing the three RGB channels
	
	setBatchMode(true);
	run("Set Measurements...", "area mean modal redirect=None decimal=2");
	run("Split Channels");
	// Get modes:
	selectWindow("orig (red)");
	run("Measure");
	selectWindow("orig (green)");
	run("Measure");
	selectWindow("orig (blue)");
	run("Measure");
	modRGB = newArray(3);
	modRGB[0] = getResult("Mode", 0);
	modRGB[1] = getResult("Mode", 1);
	modRGB[2] = getResult("Mode", 2);
	// Balance RGB channels:
	Array.getStatistics(modRGB, min, max, mean, stdDev);
	difR = max-modRGB[0];
	difG = max-modRGB[1];
	difB = max-modRGB[2];
	selectWindow("orig (red)");
	run("Add...", "value="+difR);
	selectWindow("orig (green)");
	run("Add...", "value="+difG);
	selectWindow("orig (blue)");
	run("Add...", "value="+difB);
	// Merge and perform white balance:
	run("Merge Channels...", "c1=[orig (red)] c2=[orig (green)] c3=[orig (blue)]");
	rename("orig");
	if(max>200) {
		setMinAndMax(0, max);
		run("Apply LUT");
	}
	run("Clear Results");
	setBatchMode(false);
	
	
	//--SELECT AREA OF ANALYSIS
	
	setTool("Freehand");
	waitForUser("Please select the area of analysis and press OK");
	type = selectionType();
	if(type==-1) {
		run("Select All");
	}
	run("Crop");
	roiManager("add");	// ROI 0 --> Region of analysis in the crop
	run("Select None");
	
	
	//--DETECT TISSUE
	
	run("Select All");
	showStatus("Detecting tissue...");
	run("RGB to Luminance");
	rename("a");
		//thTissue=254;
	setThreshold(0, thTissue);
	run("Convert to Mask");
	run("Median...", "radius=4");
	run("Close-");
	run("Invert");
	run("Analyze Particles...", "size=20000-Infinity pixel show=Masks in_situ");
	run("Invert");
	//run("Analyze Particles...", "size=5000-Infinity pixel show=Masks in_situ");
	run("Analyze Particles...", "size="+maxLumenSize+"-Infinity pixel show=Masks in_situ");
	run("Create Selection");
	run("Add to Manager");	// ROI1 --> whole tissue
	selectWindow("a");
	close();
	
	
	//--Tissue in selected region of analysis
	roiManager("deselect");
	roiManager("Select", newArray(0,1));
	roiManager("AND");
	roiManager("Add");
	roiManager("Deselect");
	roiManager("Select", newArray(0,1));
	roiManager("Delete");
	
	
	//--POSSIBILITY OF DELETING TISSUE REGIONS
	
	selectWindow("orig");
	roiManager("select", 0);
	q=getBoolean("Tissue detected. Would you like to elliminate any tissue region from the analysis?");
	while(q) {
		waitForUser("Select a region to elliminate from the analysis and then press OK");
		type=selectionType();
		if(type!=-1) {
			roiManager("add");
			roiManager("deselect");
			roiManager("Select", newArray(0,1));
			roiManager("AND");
			roiManager("Add");
			roiManager("Deselect");
			roiManager("Select", newArray(0,2));
			roiManager("XOR");
			roiManager("Add");
			roiManager("Deselect");
			roiManager("Select", newArray(0,1,2));
			roiManager("Delete");
			roiManager("deselect");
		}
		selectWindow("orig");
		roiManager("select", 0);
		q=getBoolean("Would you like to elliminate any other tissue region from the analysis?");
	}
	
	
	//--MEASURE AREA OF ANALYSIS
	
	selectWindow("orig");
	run("Select All");
	roiManager("Select", 0);
	roiManager("Measure");
	At=getResult("Area",0);
	Atm=At*r*r;
	run("Clear Results");
	
	
	//setBatchMode(true);
	
	//--SEPARATE STAINING CHANNELS
	
	selectWindow("orig");
	roiManager("Show None");
	run("Select All");
	showStatus("Deconvolving channels...");
	run("Colour Deconvolution", "vectors=[H&E DAB] hide");
	selectWindow("orig-(Colour_2)");
	close();
	selectWindow("orig-(Colour_1)");
	rename("blue");
	selectWindow("orig-(Colour_3)");
	rename("brown");
	
	
	//--DETECT CAPILLARIES
	
	selectWindow("brown");
	run("Mean...", "radius=3");
	  // thCap=220;
	setThreshold(0, thCap);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=2");
	run("Close-");
	roiManager("Select", 0);
	setBackgroundColor(255, 255, 255);
	run("Clear Outside");
	run("Select All");
	//run("Analyze Particles...", "size=70-1000 show=Masks in_situ");
	run("Analyze Particles...", "size="+minSize+"-"+maxSize+" show=Masks in_situ");
	
	
	//--SEGMENT BLUE CELLS TO ELLIMINATE DAB SIGNAL INSIDE THEM
	
	selectWindow("blue");
	run("Mean...", "radius=2");
	   //thBlue = 160;
	setThreshold(0, thBlue);
	//waitForUser("Adjust threshold for cell segmentation and press OK when ready");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	//run("Fill Holes");
	run("Median...", "radius=2");
	run("Watershed");
	roiManager("Select", 0);
	run("Clear Outside");
	run("Select All");
	run("Analyze Particles...", "size=10-10000 pixel show=Masks in_situ");
	//run("Analyze Particles...", "size="+minSize+"-"+maxSize+" pixel show=Masks in_situ");
	run("Create Selection");
	roiManager("add");
	
	//--Elliminate nuclear signal from capillaries:
	selectWindow("brown");
	roiManager("Deselect");
	roiManager("Select", 1);
	setBackgroundColor(255, 255, 255);
	run("Clear", "slice");
	run("Select All");
	run("Median...", "radius=1");
	run("Close-");
	run("Fill Holes");
	run("Analyze Particles...", "size="+minSize+"-"+maxSize+" show=Masks in_situ");
	
	
	// transform selection to individual points
	
	run("Find Maxima...", "prominence=10 light output=[Point Selection]");
	setTool("multipoint");
	run("Point Tool...", "type=Hybrid color=Green size=Large counter=0");
	selectWindow("orig");
	run("Restore Selection");
	waitForUser("Automatic detection finished. Add (Click) or Delete (CTRL+ALT+Click) nuclei if needed and press OK when ready");
	run("Create Mask");
	rename("MaskCap");
	run("Find Maxima...", "prominence=10 output=Count light");
	// Get number of capillaries
	i=nResults;
	nCap=getResult("Count",i-1);
	run("Clear Results");
	print(nCap);
	
	selectWindow("brown");
	close();
	selectWindow("blue");
	close();
	
	
	//--Write results:
	run("Clear Results");
	if(File.exists(output+File.separator+"Quantification_capillaries.xls"))
	{	
		//if exists add and modify
		open(output+File.separator+"Quantification_capillaries.xls");
		IJ.renameResults("Results");
	}
	i=nResults;
	setResult("[Label]", i, MyTitle); 
	setResult("Analyzed area of tissue (um2)", i, Atm); 
	setResult("# Capillaries", i, nCap);
	saveAs("Results", output+File.separator+"Quantification_capillaries.xls");
	
	
	// DRAW:
	
	selectWindow("orig");
	
	roiManager("Show None");
	roiManager("Select", 0);
	roiManager("Set Color", "red");
	roiManager("Set Line Width", 2);
	run("Flatten");
	wait(100);
	
	// Draw capillaries
	selectWindow("MaskCap");
	run("Find Maxima...", "prominence=10 output=[Point Selection] light");
	setTool("multipoint");
	run("Point Tool...", "type=Hybrid color=Green size=Medium counter=0");
	setTool("multipoint");
	selectWindow("orig-1");
	run("Restore Selection");
	setTool("multipoint");
	run("Point Tool...", "type=Hybrid color=Green size=Medium counter=0");
	run("Flatten");
	wait(200);
	
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	rename(MyTitle_short+"_analyzed.jpg");
	
	selectWindow("orig");
	close();
	selectWindow("orig-1");
	close();
	selectWindow("MaskCap");
	close();
	
	setTool("zoom");
	
	run("Collect Garbage");
	
	showMessage("Done!");

}



macro "CapillaryDAB Action Tool 2 - Cf00T0d10AT6d10rTad10eTfd10a"{

	run("Close All");
	
	//just one file
	name=File.openDialog("Select image file");
	//print(name);
	print("Processing "+name);
	
	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Choose parameters")	
	Dialog.addNumber("Ratio micra/pixel", r);		
	Dialog.addNumber("Threshold for tissue segmentation", thTissue);
	Dialog.addNumber("Threshold for capillary segmentation", thCap);
	Dialog.addNumber("Threshold for nuclei segmentation", thBlue);
	Dialog.addNumber("Min capillary size (um2)", minSizeUm);	
	Dialog.addNumber("Max capillary size (um2)", maxSizeUm);
	Dialog.addNumber("Max lumen size (um2)", maxLumenSizeUm);		
	Dialog.show();	
	
	r= Dialog.getNumber();
	thTissue= Dialog.getNumber();
	thCap= Dialog.getNumber(); 	
	thBlue= Dialog.getNumber(); 		
	minSizeUm= Dialog.getNumber(); 		
	maxSizeUm= Dialog.getNumber(); 
	maxLumenSizeUm= Dialog.getNumber(); 
			
	
	open(name);
	
	minSize = round(minSizeUm/(r*r));
	maxSize = round(maxSizeUm/(r*r));
	maxLumenSize = round(maxLumenSizeUm/(r*r));
	
	
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	run("Colors...", "foreground=black background=white selection=green");
	run("Set Measurements...", "area mean area_fraction redirect=None decimal=2");
	
	
	rename("orig");
	
	//--Correct background by using the mode for contrast adjustment previously balancing the three RGB channels
	
	setBatchMode(true);
	run("Set Measurements...", "area mean modal redirect=None decimal=2");
	run("Split Channels");
	// Get modes:
	selectWindow("orig (red)");
	run("Measure");
	selectWindow("orig (green)");
	run("Measure");
	selectWindow("orig (blue)");
	run("Measure");
	modRGB = newArray(3);
	modRGB[0] = getResult("Mode", 0);
	modRGB[1] = getResult("Mode", 1);
	modRGB[2] = getResult("Mode", 2);
	// Balance RGB channels:
	Array.getStatistics(modRGB, min, max, mean, stdDev);
	difR = max-modRGB[0];
	difG = max-modRGB[1];
	difB = max-modRGB[2];
	selectWindow("orig (red)");
	run("Add...", "value="+difR);
	selectWindow("orig (green)");
	run("Add...", "value="+difG);
	selectWindow("orig (blue)");
	run("Add...", "value="+difB);
	// Merge and perform white balance:
	run("Merge Channels...", "c1=[orig (red)] c2=[orig (green)] c3=[orig (blue)]");
	rename("orig");
	if(max>200) {
		setMinAndMax(0, max);
		run("Apply LUT");
	}
	run("Clear Results");
	setBatchMode(false);
	
	
	//--SELECT AREA OF ANALYSIS
	
	setTool("Freehand");
	waitForUser("Please select the area of analysis and press OK");
	type = selectionType();
	if(type==-1) {
		run("Select All");
	}
	run("Crop");
	roiManager("add");	// ROI 0 --> Region of analysis in the crop
	run("Select None");
	
	
	//--DETECT TISSUE
	
	run("Select All");
	showStatus("Detecting tissue...");
	run("RGB to Luminance");
	rename("a");
		//thTissue=254;
	setThreshold(0, thTissue);
	run("Convert to Mask");
	run("Median...", "radius=4");
	run("Close-");
	run("Invert");
	run("Analyze Particles...", "size=20000-Infinity pixel show=Masks in_situ");
	run("Invert");
	//run("Analyze Particles...", "size=5000-Infinity pixel show=Masks in_situ");
	run("Analyze Particles...", "size="+maxLumenSize+"-Infinity pixel show=Masks in_situ");
	run("Create Selection");
	run("Add to Manager");	// ROI1 --> whole tissue
	selectWindow("a");
	close();
	
	
	//--Tissue in selected region of analysis
	roiManager("deselect");
	roiManager("Select", newArray(0,1));
	roiManager("AND");
	roiManager("Add");
	roiManager("Deselect");
	roiManager("Select", newArray(0,1));
	roiManager("Delete");
	
	
	//--POSSIBILITY OF DELETING TISSUE REGIONS
	
	selectWindow("orig");
	roiManager("select", 0);
	q=getBoolean("Tissue detected. Would you like to elliminate any tissue region from the analysis?");
	while(q) {
		waitForUser("Select a region to elliminate from the analysis and then press OK");
		type=selectionType();
		if(type!=-1) {
			roiManager("add");
			roiManager("deselect");
			roiManager("Select", newArray(0,1));
			roiManager("AND");
			roiManager("Add");
			roiManager("Deselect");
			roiManager("Select", newArray(0,2));
			roiManager("XOR");
			roiManager("Add");
			roiManager("Deselect");
			roiManager("Select", newArray(0,1,2));
			roiManager("Delete");
			roiManager("deselect");
		}
		selectWindow("orig");
		roiManager("select", 0);
		q=getBoolean("Would you like to elliminate any other tissue region from the analysis?");
	}
	
	
	//--MEASURE AREA OF ANALYSIS
	
	selectWindow("orig");
	run("Select All");
	roiManager("Select", 0);
	roiManager("Measure");
	At=getResult("Area",0);
	Atm=At*r*r;
	run("Clear Results");
	
	
	//setBatchMode(true);
	
	//--SEPARATE STAINING CHANNELS
	
	selectWindow("orig");
	roiManager("Show None");
	run("Select All");
	showStatus("Deconvolving channels...");
	run("Colour Deconvolution", "vectors=[H&E DAB] hide");
	selectWindow("orig-(Colour_2)");
	close();
	selectWindow("orig-(Colour_1)");
	rename("blue");
	selectWindow("orig-(Colour_3)");
	rename("brown");
	
	
	//--DETECT CAPILLARIES
	
	selectWindow("brown");
	run("Mean...", "radius=3");
	  // thCap=220;
	setThreshold(0, thCap);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=2");
	run("Close-");
	roiManager("Select", 0);
	setBackgroundColor(255, 255, 255);
	run("Clear Outside");
	run("Select All");
	run("Fill Holes");
	//run("Analyze Particles...", "size=70-1000 show=Masks in_situ");
	run("Analyze Particles...", "size="+minSize+"-"+maxSize+" show=Masks in_situ");
	run("Create Selection");
	roiManager("Add");
	
	/*
	selectWindow("orig");
	roiManager("Select", 1);
	waitForUser("Check capillary detections and press OK");
	q=getBoolean("Would you like to manually close a capillary contour?");
	while(q) {
		setTool("freehand");
		waitForUser("Draw a closed contour and press OK when ready");
		selectWindow("brown");
		run("Restore Selection");
		setForegroundColor(0, 0, 0);
		run("Fill", "slice");
		run("Create Selection");
		roiManager("Add");
		selectWindow("orig");
		roiManager("Select", 1);
		roiManager("Delete");
		roiManager("Select", 1);
		waitForUser("Check capillary detections and press OK");
		q=getBoolean("Would you like to manually close another capillary contour?");
	}
	*/
	
	
	//--SEGMENT BLUE CELLS TO ELLIMINATE DAB SIGNAL INSIDE THEM
	
	selectWindow("blue");
	run("Mean...", "radius=2");
	   //thBlue = 160;
	setThreshold(0, thBlue);
	//waitForUser("Adjust threshold for cell segmentation and press OK when ready");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	//run("Fill Holes");
	run("Median...", "radius=2");
	run("Watershed");
	roiManager("Select", 0);
	run("Clear Outside");
	run("Select All");
	run("Analyze Particles...", "size=10-10000 pixel show=Masks in_situ");
	//run("Analyze Particles...", "size="+minSize+"-"+maxSize+" pixel show=Masks in_situ");
	run("Create Selection");
	roiManager("add");
	
	
	//--Elliminate nuclear signal from capillaries:
	
	roiManager("deselect");
	roiManager("Select", newArray(1,2));
	roiManager("AND");
	roiManager("Add");
	roiManager("deselect");
	roiManager("Select", newArray(1,3));
	roiManager("XOR");
	roiManager("Add");
	roiManager("deselect");
	roiManager("Select", newArray(1,2,3));
	roiManager("delete");
	
	selectWindow("brown");
	close();
	selectWindow("blue");
	close();
	
	//--Count capillaries:
	run("Clear Results");
	selectWindow("orig");
	roiManager("Select", 1);
	run("Create Mask");
	run("Median...", "radius=1");
	run("Close-");
	run("Fill Holes");
	run("Analyze Particles...", "size="+minSize+"-"+maxSize+" show=Masks display clear in_situ");
	run("Create Selection");
	roiManager("add");
	roiManager("deselect");
	roiManager("Select", 1);
	roiManager("delete");
	nCap = nResults;
	
	
	//--Measure areas:
	run("Clear Results");
	selectWindow("orig");
	roiManager("Select", 1);
	roiManager("Measure");
	Acap=getResult("Area",0);
	Acapm=Acap*r*r;
	
	//ratio
	r1 = Acapm/Atm*100;
	
	
	//--Write results:
	run("Clear Results");
	if(File.exists(output+File.separator+"Quantification_capillaries_area.xls"))
	{	
		//if exists add and modify
		open(output+File.separator+"Quantification_capillaries_area.xls");
		IJ.renameResults("Results");
	}
	i=nResults;
	setResult("[Label]", i, MyTitle); 
	setResult("Analyzed area of tissue (um2)", i, Atm); 
	setResult("Area of capillaries (um2)", i, Acapm);
	setResult("Ratio Acap/Atot (%)", i, r1);
	setResult("# Capillaries", i, nCap);
	saveAs("Results", output+File.separator+"Quantification_capillaries_area.xls");
	
	
	// DRAW:
	
	selectWindow("orig");
	roiManager("Show None");
	roiManager("Select", 0);
	roiManager("Set Color", "red");
	roiManager("Set Line Width", 2);
	run("Flatten");
	wait(100);
	selectWindow("orig-1");
	roiManager("Select", 1);
	roiManager("Set Color", "green");
	roiManager("Set Line Width", 2);
	run("Flatten");
	wait(200);
	
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzedArea.jpg");
	rename(MyTitle_short+"_analyzedArea.jpg");
	
	selectWindow("orig");
	close();
	selectWindow("orig-1");
	close();
	selectWindow("Mask");
	close();
	
	setTool("zoom");
	
	run("Collect Garbage");
	
	showMessage("Done!");

}

