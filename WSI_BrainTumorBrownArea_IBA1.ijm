// ============================================================
// MACRO INFO
// ============================================================

function macroInfo(){

// * Quantification of Brown WSI Images Area  adapted for Brain tissue
// * Target User: General
// *

	scripttitle= "Quantification of Brown Stained Area: Parameters adapted for Brain tumor tissue";
	version= "1.03";
	date= "2015";

// *  Tests Images:

	imageAdquisition="Aperio: BrightField Whole Slide Imaging Images.";
	imageType="RGB";
	voxelSize="Voxel size:  0.502 um xy";
	format="Format: Uncompressed .jpg";

	//*  GUI User Requierments:
	//*    - Choose parameters.
	//*    - Single File and Batch Mode
	//*
	// Important Parameters: click Im or Dir + right button
	parameter1="Resolution (micra pixel ratio) = 0.502 micras/pixel xy";
	parameter2="Tissue Threshold (8bit) = Separate Tissue from Background";
	parameter3="Brown DAB Threshold (8bit)= Separate Brown(+) ROIs form Brown(-) ROIs";
	parameter4="Min size of stained particles (px): Size Filter."

	//  2 Action tools:
	buttom1="Im: Single File processing";
	buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

	//  OUTPUT
	// Analyzed Images with ROIs

	excel="Results_WSI_BrainTumorBrownArea_IBA1.xls";
	feature1="Image Label";
	feature2="Tissue Area (micra²)";
	feature3="Stained area (micra²)";
	feature4="Ratio Area stained/Area tissue (%)"

/*
 *  version: 1.02
 *  Author: Mikel Ariz
 *  Commented by: Tomas Muñoz 2023
 *  Date : // Changelog June 2021
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
		+"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li></ul>"
		+"<h0><font size=5></h0>"
		+"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}


// ============================================================
// GLOBAL CONFIGURATION
// ============================================================

var r=0.502, thTissue=235, th_brown=150, minSize=50;


// ============================================================
// HELPER FUNCTIONS
// ============================================================

function isImageOpen() {
	/**
	 * Checks if an image with the specified name is currently open in ImageJ.
	 */

	// Get the list of open image windows
	openImages = getList("image.titles");
	// Check if the specified image name is in the list of open images
	// if empty
	if (lengthOf(openImages) == 0) {
		return false; // No images are open
	} else {
		return true; // Return true if the image is open, false otherwise
	}
}

function correctBackground(image) {
	/**
	 * Adjusts the background intensity of an image based on pixel intensity mode.
	 * Supports global and tissue-specific correction modes.
	 *
	 * @param {string} image - Name of the image window to correct.
	 * @returns {number} mode - The mode of pixel intensity used for adjustment.
	 *
	 * Modes:
	 * - **Global Correction**: Calculates the mode for the entire image. If mode > 200, adjusts brightness by adding (255 - mode) to all pixels.
	 * - **Tissue-Specific Correction**: Calculates the mode within a selected ROI. Adjustment logic for this mode is incomplete.
	 *
	 * Requirements:
	 * - For tissue-specific correction, an ROI must be present in the ROI Manager.
	 *
	 * Note: Global correction is enabled by default.
	 */

	// Set to true for global background correction; false for tissue-specific correction.
	globalMode = true;

	if (globalMode) {
		// Global background correction
		run("Clear Results");
		run("Set Measurements...", "area mean modal redirect=None decimal=2");
		run("Select All");

		// Get the mode of pixel intensity
		mode = getValue("Mode");
		print(mode);
		

		// Adjust brightness if mode exceeds threshold
		if (mode > 225)  {
			dif = 255 - mode;
			selectWindow(image);
			run("Add...", "value=" + dif);
		}
		// Clear measurement results
		run("Clear Results");
	} else {
		// Tissue-specific background correction
		run("Clear Results");
		run("Set Measurements...", "area mean modal redirect=None decimal=2");

		// Assume ROI is preloaded in the ROI Manager
		selectWindow("a");
		roiManager("select", 0);
		run("Measure");

		// Get the mode of pixel intensity within the ROI
		mode = getResult("Mode", 0);

		if (mode > 200) {
			selectWindow(image);
			dif = 255 - mode;
			run("Select None");
		}

		// Clear measurement results
		run("Clear Results");
	}

	return mode; // Return the measured mode
}


// ============================================================
// ACTION TOOLS
// ============================================================

macro "TumorBrownArea Action Tool 1 - Cf00T2d15IT6d10m"{

	//just one file
	macroInfo();
	// if is open do nothing, if not open
	if (isImageOpen()) {
		name = getTitle();
		name = File.nameWithoutExtension;
		rename(name);
		print("Image "+name+" is already open.");
	} else {
		run("Fresh Start");
		run("Collect Garbage");
		name=File.openDialog("Select File");
		print("Processing "+name);
	}

	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Choose parameters")
	Dialog.addNumber("micra/px ratio", r);
	Dialog.addNumber("Threshold for tissue detection", thTissue);
	Dialog.addNumber("Threshold for brown detection", th_brown);
	Dialog.addNumber("Min size of stained particles (px)", minSize);
	Dialog.show();
	r= Dialog.getNumber();
	thTissue= Dialog.getNumber();
	th_brown= Dialog.getNumber();
	minSize= Dialog.getNumber();

	//setBatchMode(true);
	browndetection("-","-",name,r,thTissue,th_brown,minSize);
	setBatchMode(false);
	showMessage("Done!");
}


macro "TumorBrownArea Action Tool 2 - C00fT0b11DT9b09iTcb09r"{

	run("Fresh Start");
	run("Collect Garbage");

	macroInfo();
	InDir=getDirectory("Choose a Directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Choose parameters")
	Dialog.addNumber("micra/px ratio", r);
	Dialog.addNumber("Threshold for Tissue detection", thTissue);
	Dialog.addNumber("Threshold for brown detection", th_brown);
	Dialog.addNumber("Min size of stained particles (px)", minSize);
	Dialog.show();
	r= Dialog.getNumber();
	thTissue= Dialog.getNumber();
	th_brown= Dialog.getNumber();
	minSize= Dialog.getNumber();

	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"jpg")||endsWith(list[j],"tif")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print(name);
			//setBatchMode(true);
			browndetection(InDir,InDir,list[j],r,thTissue,th_brown,minSize);
			setBatchMode(false);
		}
	}
	showMessage("Done!");
}


// ============================================================
// CORE ANALYSIS
// ============================================================

function browndetection(output,InDir,name,r,thTissue,th_brown,minSize)
{
	// --- INITIALIZATION ---

	// if image is already open do nothing, if not open. use indir + name in case of batch mode, just name in case of single image mode
	if (isImageOpen()) {
		name = getTitle();
		name = File.nameWithoutExtension;
		rename(name);
		print("Image "+name+" is already open.");
	}else if (InDir == "-") {
		//open(name);
		run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
		print("Image "+name+" is already open.");
	}else {
		//open(InDir+name);
		run("Bio-Formats Importer", "open=["+InDir+name+"] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
		print("Processing "+name);
	}

	roiManager("Reset");
	run("Clear Results");
	run("Options...", "iterations=1 count=1");

	MyTitle=getTitle();
	MyTitle = File.nameWithoutExtension;
	rename(MyTitle);
	output=getInfo("image.directory");
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);

	setBatchMode(true);
	run("Colors...", "foreground=white background=black selection=green");
	run("Set Scale...", "distance=1 known="+r+" unit=micron");

	// --- COLOUR DECONVOLUTION ---

	run("Select All");
	showStatus("Detecting tumor...");
	// check number of channels, if more than 1 convert to luminance
	getDimensions(width, height, channels, slices, frames);
	if (channels > 1) {
		selectWindow(MyTitle);
		run("Split Channels");
		//apply correctBackground to each channel
		for (c=1; c<=channels; c++) {
			selectWindow("C"+c+"-"+	MyTitle);
			modeBckg=correctBackground("C"+c+"-"+MyTitle);
			run("Enhance Contrast", "saturated=0.35");
			run("Apply LUT");

		}
		//merge channels again
		run("Merge Channels...", "c1=[C1-"+MyTitle+"] c2=[C2-"+MyTitle+"] c3=[C3-"+MyTitle+"] create");
		run("RGB Color");
		// close result image and rename new one as original
		selectWindow(MyTitle+" (RGB)");
		close(MyTitle);
		rename(MyTitle);
	}
	rename("rgb");

	// -- SEGMENT BACKGROUND

	selectWindow("rgb");
	// RGB TO LUMINANCE
	run("RGB to Luminance");
	// Thresholding to background segmentation
	run("Threshold...");
	thTissue = modeBckg-5;
	setThreshold(0, thTissue);
	//setThreshold(0, 235);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	rename("backgroundMask");
	run("Invert");
	run("Median...", "radius=4");
	run("Analyze Particles...", "size=5000-Infinity pixel show=Masks in_situ");
	run("Duplicate...", "title=tissue");
	run("Invert");

		
	// Deconvolution of H&E and DAB channels
	selectWindow("rgb");
	run("Colour Deconvolution", "vectors=[H&E DAB] hide");
	selectWindow("rgb-(Colour_2)");
	close();

	// --- BROWN SEGMENTATION (DAB CHANNEL) ---

	selectWindow("rgb-(Colour_3)");
	rename("DAB");
	modeDAB=correctBackground("DAB");

	// Correcting background and processing red channel
	showStatus("Correcting background...");
	run("Subtract Background...", "rolling=50 light");

	run("Threshold...");
	setAutoThreshold("Default");
	//th_brown=150;
	setThreshold(0, th_brown);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...","radius=2");
	run("Analyze Particles...", "size=10-Infinity pixel show=Masks in_situ");

	//run("Analyze Particles...", "size="+minSize+"-Infinity show=Masks in_situ");


	// --- TUMOR SEGMENTATION (HE CHANNEL - DAB CHANNEL) ---
	// High nuclei density areas correspond to tumor; low density to background

	selectWindow("rgb-(Colour_1)");
	rename("HE");
	modeHE=correctBackground("HE");

	// enhance contrast of HE channel for better thresholding
	// Correcting background and processing red channel
	showStatus("Correcting background...");
	run("Subtract Background...", "rolling=50 light");
	// Thresholding and segmentation of TUMOR areas
	selectWindow("HE");
	run("Threshold...");
	setAutoThreshold("Otsu");
	//run("Threshold...");
	//setThreshold(0, 162);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	imageCalculator("Subtract create", "HE","DAB");
	run("Mean...", "radius=100");
	run("Median...", "radius=4");
	run("Fire");
	selectWindow("tissue");
	run("Create Selection");
	selectWindow("Result of HE");
	run("Restore Selection");
	//run("Threshold...");
	//thTumor = 30;
	//setThreshold(thTumor,255);
	//setAutoThreshold("Otsu dark");
	setBatchMode("exit and display");
	waitForUser("Select a threshold for tumor segmentation and click OK");
	getThreshold(thTumor,upper);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Analyze Particles...", "size=10000-Infinity pixel show=Masks in_situ");
	run("Keep Largest Region");
	imageCalculator("Subtract create", "Result-largest","backgroundMask");
	rename("tumorMask");
	run("Create Selection");
	// if no selection, finish macro , no tumor detected
	type=selectionType();
	if(type==-1) {
		break;
	}else {
		run("Add to Manager");	// ROI0 --> tumor tissue
	}
	close("*HE*");
	close("*largest*");

	
	// --- BROWN WITHIN TISSUE (INTERSECTION) ---
	
	selectWindow("DAB");
	run("Create Selection");
	// if no selection, finish macro , no tumor detected
	type=selectionType();
	if(type==-1) {
		break;
	}else {
		run("Add to Manager");	// ROI0 --> tumor tissue
	}
	close("*DAB*");

	// Save just brown in tissue
	roiManager("Deselect");
	roiManager("Select", 0);
	roiManager("Select", newArray(0,1));
	roiManager("AND");
	type=selectionType();
	if(type==-1) {
		makeRectangle(1, 1, 1, 1);
		flagBrown=true;
	}
	roiManager("Add");
	roiManager("Deselect");
	roiManager("Select", 1);
	roiManager("Delete");


	// --- MEASUREMENTS ---

	// RESULTS--
	run("Clear Results");
	selectWindow("rgb");
	run("Set Measurements...", "area redirect=None decimal=2");

	// Tissue
	roiManager("select", 0);
	roiManager("Measure");
	At=getResult("Area",0);
	//in micra
	Atm=At;

	// Staining
	roiManager("select", 1);
	roiManager("Measure");
	Ap=getResult("Area",1);
	//in micra
	Apm=Ap;

	// Ratio
	r1=Apm/Atm*100;


	// --- RESULTS OUTPUT ---

	run("Clear Results");
	if(File.exists(output+File.separator+"Results_WSI_BrainTumorBrownArea_IBA1.xls"))
	{  //if exists add and modify
		open(output+File.separator+"Results_WSI_BrainTumorBrownArea_IBA1.xls");
		IJ.renameResults("Results");
	}
	i=nResults;
	setResult("[Label]", i, MyTitle);
	//setResult("background", i, modeBckg);
	setResult("HE", i, modeHE);
	setResult("DAB", i, modeDAB);
	setResult("thTissue", i, thTissue);
	setResult("thTumor", i, thTumor);
	setResult("thDAB", i, th_brown);
	setResult("minSize", i, minSize);
	setResult("Tissue area (micra2)",i,Atm);
	setResult("Stained area (micra2)",i,Apm);
	setResult("Ratio Astained/Atissue (%)",i,r1);
	saveAs("Results", output+File.separator+"Results_WSI_BrainTumorBrownArea_IBA1.xls");

	aa = split(MyTitle,".");
	MyTitle_short = aa[0];


	// --- VISUALIZATION ---

	setBatchMode("exit and display");
	selectWindow("rgb");
	roiManager("Show None");
	roiManager("Select", 0);
	roiManager("Set Color", "yellow");
	run("Flatten");
	roiManager("Show None");
	roiManager("Select", 1);
	roiManager("Set Color", "green");
	run("Flatten");
	saveAs("Jpeg", OutDir+File.separator+MyTitle+"_analyzed.jpg");
	rename(MyTitle_short+"_analyzed.jpg");


	// --- CLEANUP ---

	close("*");
	run("Collect Garbage");
	//showMessage("Done!");
}
