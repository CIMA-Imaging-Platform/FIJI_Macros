

function macroInfo(){
	// * Automatic Microplastics Quantification in OME-TIFF Images
	// * Target User: Researcher (CIMA)

	scripttitle= "Automatic Microplastics Quantification in VECTRA SLIDES";
	version= "1.0";
	date= "2026";

	// *  Tests Images:
	imageAdquisition="Vectra/QuPath OME-TIFF: DAPI (tissue) + TRITC (MPs)";
	imageType="2D multichannel OME-TIFF";
	voxelSize="Voxel size: calibrated in µm";
	format="Format: OME-TIFF (.ome.tif)";

 //*  GUI User Requirements:
 //*    - Choose input/output folders, channels, and parameters.
 //*    - Batch Mode: All images in the folder will be quantified.

 //*    - Quantification of microplastics (MPs) in tissue sections.
 //*    - MPs: TRITC channel; Tissue: DAPI channel.
 //*    - Outputs: CSVs per image, summary CSV, masks for traceability.

 // Important Parameters:
	parameter1="TRITC (MPs) Channel Order and MPs sensibility detection";

 //  Action tools:
	buttom1="Im: Single Image Analyisis. Use it for parameter setup";
	buttom2="DIR: Batch Mode. Select Folder: All OME-TIFF images will be quantified";

//  OUTPUT

// Analyzed Images with Results
	excel="MP_summary.csv (summary), per-image CSVs";
	feature1="Tissue_area_total_um2: Total tissue area (µm²)";
	feature2="MPs_count: Number of microplastics detected";
	feature3="MPs Intensity Distribution, Mean, StdDev, Max, Min";
	

/*
 *  version: 1.0
 *  Author: Adapted by Tomas Muñoz 2026
 *  Date : 2026
 */

// MIT License
// Copyright (c) 2026 Tomas Muñoz tmsantoro@unav.es
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
	    +"<p><font size=3 i>Output folder: Visualize Segmented Masks and CSVs</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");
}

macro "IF_TissueMicroPlastics Action Tool 1 - Cf00T2d15IT6d10m"{
	
	// Initialization Subprocess
	initializeEnvironment();
	macroInfo();

	// Directory Selection for Batch Mode
	print("Waiting for input folder selection...");
	
	file = File.openDialog("Selectfile");
	fileName = File.getName(file);
	inputDir = File.getDirectory(file);
	outputDir = inputDir + "AnalyzedImages" + File.separator;
	
	if (!File.exists(outputDir)) File.makeDirectory(outputDir);
	
	// User Parameters Dialog
	Dialog.create("Microplastics Quantification");
	Dialog.addNumber("Channel for MPs (TRITC)", 2);
	Dialog.addMessage("MPs detection");
	Dialog.addSlider("(Lower values equal more MPs detected)", 1, 200, 20);
	Dialog.show();
	
	chMP = Dialog.getNumber();
	sensibility = Dialog.getNumber();
	
	if (endsWith(file, ".ome.tif")) {
		runAnalysisSubprocess(inputDir, fileName, outputDir, chMP, sensibility);
	}
	
	print("Batch Processing Finished.");
	showMessage("Success", "Quantification complete. Check results in: " + outputDir);
}



macro "IF_PhenotypeQuant Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	// Initialization Subprocess
	initializeEnvironment();
	macroInfo();
		
	// Directory Selection for Batch Mode
	print("Waiting for input folder selection...");
	inputDir = getDirectory("Select Input Directory with OME-TIF images");
	outputDir = inputDir + "AnalyzedImages" + File.separator;
	if (!File.exists(outputDir)) File.makeDirectory(outputDir);
	
	// User Parameters Dialog
	Dialog.create("Microplastics Quantification");
	Dialog.addNumber("Channel for MPs (TRITC)", 2);
	Dialog.addMessage("MPs detection");
	Dialog.addSlider("(Lower values equal more MPs detected)", 1, 200, 20);
	Dialog.show();
	
	chMP = Dialog.getNumber();
	sensibility = Dialog.getNumber();
	
	// Batch Execution Loop
	list = getFileList(inputDir);
	for (i = 0; i < list.length; i++) {
		if (endsWith(list[i], ".ome.tif")) {
			print("--- Processing " + (i+1) + " of " + list.length + ": " + list[i] + " ---");
			runAnalysisSubprocess(inputDir, list[i], outputDir, chMP, sensibility);
		}
	}
	
	print("Batch Processing Finished.");
	showMessage("Success", "Quantification complete. Check results in: " + outputDir);
}

function initializeEnvironment() {
	
	RoiManager.associateROIsWithSlices(true);
	setOption("ExpandableArrays", true);
	setOption("WaitForCompletion", true);

	run("Set Measurements...", "mean redirect=None decimal=2");
	run("Options...", "iterations=1 count=1");
	
	print("\\Clear");
	print("Initializing Analysis Environment...");
	close("*");
	run("Collect Garbage");
	if (roiManager("count") > 0) roiManager("Reset");
	run("Clear Results");
	close("Results");
	
}

function runAnalysisSubprocess(inputDir, fileName, OutDir, chMP, sensibility) {
	path = inputDir + fileName;
	print("Opening image " + fileName);
	
	run("Bio-Formats", "open=["+path+"] autoscale color_mode=Default rois_import=[ROI manager] specify_range view=Hyperstack stack_order=XYCZT series_1 c_begin_1="+chMP+" c_end_1="+chMP+" c_step_1=1");
	
	
	// Get file information
	MyTitle = File.nameWithoutExtension;
	rename(MyTitle);
		
	// Get calibration
	getVoxelSize(pxWidth, pxHeight, pxDepth, unit);
	if (unit!="microns" && unit!="µm" && unit!="um") {
		print("Warning: Calibration missing for " + fileName);
	}
	
	setBatchMode(false);
	
	// SEGMENT WHOLE TISSUE
	print("Segmenting tissue area...");
	selectWindow(MyTitle);
	rename("orig");

	run("Duplicate...","ignore title=tissue");
	//run("Threshold...");
	setAutoThreshold("Otsu dark stack");
	//setThreshold(18, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Convert to Mask");
	run("Analyze Particles...", "size=10000-Infinity pixel show=Masks in_situ");
	run("Invert");
	run("Analyze Particles...", "size=3000-Infinity pixel show=Masks in_situ");
	run("Invert");
	run("Keep Largest Region");
	rename("tissueMask");
	run("Create Selection");
	run("Add to Manager");
	tissueArea = getValue("Area");
	close("tissue");
	
	// MPs segmentation (TRITC channel)
	print("Microplastics (MPs) Detection ...");
	selectWindow("orig");
	roiManager("Select", 0);
	bckTissue = getValue("Mode");
	run("Select None");
	run("Duplicate...","ignore title=MPsmask");
	print("Background subtraction...");
	run("Subtract...", "value="+bckTissue);
	//run("Subtract Background...", "rolling=5");
	//backgroundSubstract2DGPU("MPsmask", 5);
	run("Top Hat...", "radius=5");
	// Use ROI 0 (tissue) to limit maxima detection
	print("MPs Detecton...");
	run("Mean...", "radius=1");
	roiManager("Select", 0);
	run("Find Maxima...", "prominence="+sensibility+" output=[Single Points]");
	roiManager("reset"); // Reset to collect individual MP ROIs
	run("Analyze Particles...", "add");
	//roiManager("show all without labels");
	roiManager("show none");
	
	// Analyze MPs
	print("Analyzing MP intensity and quantify...");
	run("Clear Results");
	close("Results");
	nMPs = roiManager("count");
	if (nMPs > 0) {
		selectWindow("MPsmask");
		roiManager("measure");
		nMPsIntensity=Table.getColumn("Mean");
		Array.getStatistics(nMPsIntensity, min, max, mean, stdDev);
	} else {
		min=0; max=0; mean=0; stdDev=0;
	}
	
	run("Clear Results");
	close("Results");
	
	resultsPath = OutDir + "IF_TissueMicroPlastics.xls";
	if(File.exists(resultsPath)) {	
		open(resultsPath);
		IJ.renameResults("Results");
	}

	print("Updating results table...");
	i=nResults;
	setResult("[Label]", i, MyTitle); 
	setResult("Channel Analyzed", i, chMP); 
	setResult("MPs DetectionSensibility", i, sensibility); 
	setResult("Area of tissue (um2)", i, tissueArea); 
	setResult("# total MPs detected", i, nMPs);
	setResult("MPs meanIntensity",i,mean);
	setResult("MPs stdIntensity",i,stdDev);
	setResult("MPs MaxIntensity", i, max);
	setResult("MPs MinIntensity", i, min);
	saveAs("Results", resultsPath);
	
	print("Saving ROIs to: " + OutDir);
	print("Total MPs: "+nMPs);
	roiManager("select", Array.getSequence(nMPs));
	roiManager("save selected", OutDir+File.separator+MyTitle+"_MPsROIS.zip");

	roiManager("reset");
	
	setBatchMode("exit and display");
	
	
	print("Generating and saving analyzed image overlays...");
	selectWindow("orig");
	selectWindow("tissueMask");
	run("Create Selection");
	selectWindow("orig");
	run("Restore Selection");
	Roi.setStrokeColor("yellow");
	run("Add Selection...");
	
	selectWindow("MPsmask Maxima");
	run("Create Selection");
	selectWindow("orig");
	run("Restore Selection");
	Roi.setStrokeColor("red");
	run("Add Selection...");
	Overlay.flatten;
	
	saveAs("Jpeg", OutDir+File.separator+MyTitle+"_RawAnalyzed.jpg");
	close();
	
	selectWindow("MPsmask");
	selectWindow("tissueMask");
	run("Create Selection");
	selectWindow("MPsmask");
	run("Restore Selection");
	Roi.setStrokeColor("yellow");
	run("Add Selection...");
	
	selectWindow("MPsmask Maxima");
	run("Create Selection");
	selectWindow("MPsmask");
	run("Restore Selection");
	Roi.setStrokeColor("red");
	run("Add Selection...");
	Overlay.flatten;
	
	saveAs("Jpeg", OutDir+File.separator+MyTitle+"_Analyzed.jpg");
	print("finished: " + MyTitle);
	close("\\Others");
	
}


function backgroundSubstract2DGPU(name, sigma) {
	
	/**
	 * Subtracts background from an image using GPU acceleration.
	 * 
	 * @param {string} name - The name of the input image.
	 * @param {number} sigma - The standard deviation for Gaussian blur.
	 */
	// Load CLIJ GPU accelerator and CLIJ2 Macro Extensions
	run("CLIJx Version 0.32.1.1");
	run("CLIJ2 Macro Extensions", "cl_device=[]");
	
	// Clear CLIJ2
	Ext.CLIJ2_clear();
	
	// Push input image to GPU memory
	image1 = name;
	Ext.CLIJ2_push(image1);
	
	// Define output image name
	image2 = name + "_subtracted";
	
	// Set sigma values for Gaussian blur
	sigma_x = sigma;
	sigma_y = sigma;
	
	// Subtract background using CLIJx
	Ext.CLIJx_subtractBackground2D(image1, image2, sigma_x, sigma_y);
	
	// Pull result image from GPU memory
	Ext.CLIJ2_pull(image2);
	
	// Clear CLIJ2
	Ext.CLIJ2_clear();
	
	// Close input image
	close(image1);
	
	// Rename output image
	selectWindow(image2);
	resetMinAndMax;
	rename(name);
}

