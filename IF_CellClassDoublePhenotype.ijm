/**
 * Displays an HTML dialog with information about the macro, its purpose,
 * author details, expected inputs, and output measurements.
 */
function macroInfo(){
	
	// * Automatic Cell Classification based on Single and Double Phenotypes
	// * Target User: Imaging Core Users / Sheila
	
	scripttitle= "Automatic Cell Classification based on Single and Double Phenotypes";
	version= "1.02";
	date= "2026";
	
	// * Tests Images:
	imageAdquisition="Confocal / Fluorescent Images: Minimum 3 Channels (DAPI + Marker1 + Marker2)";
	imageType="2D / Multichannel Composite";  
	voxelSize="Voxel size: Read from metadata";
	format="Format: Bio-Formats compatible (e.g., czi, .tif)";   
 
	//* GUI User Requirements:
	parameter1="Channel indices, marker names, thresholds, and DAPI smoothing/separation variables."; 
	 
	//  Action tools:
	buttom1="Im: Single File processing with UI Dialog";

	//  OUTPUT
	excel="QuantificationResults_IFCellClassDoublePhenotype.xls";
	feature1="Tissue Area (um^2)";
	feature2="# Cells (Total DAPI Nuclei)";
	feature3="# Marker 1 cells (e.g., GFP/ALB)";
	feature4="# Marker 2 cells (e.g., F480/HDV)"; 
	feature5="# DoublePositive cells (Marker 1 + Marker 2)"; 
	
	/*
	 * Version: 1.02 
	 * Author: Tomas Muñoz 2026 
	 * Date : 2026
	 */

	//	MIT License
	//	Copyright (c) 2026 Tomas Muñoz tmsantoro@unav.es
	//	Permission is hereby granted, free of charge, to any person obtaining a copy
	//	of this software and associated documentation files (the "Software"), to deal
	//	in the Software without restriction, including without limitation the rights
	//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	//	copies of the Software, and to permit persons to whom the Software is
	//	furnished to do so, subject to the following conditions:
	//	The above copyright notice and this permission notice shall be included in all
	//	copies or substantial portions of the Software.

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
		+"<li>"+parameter1+"</li></ul>"
		+"<p><font size=3  i>Quantification Results: </i></p>"
		+"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images with multi-point ROIs</i></p>"
		+"<p><font size=3  i>Excel: "+excel+"</i></p>"
		+"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li><li>"+feature5+"</li></ul>"
		+"<h0><font size=5></h0>"
		+"");
}


var cDAPI=3, cMarker1=2, cMarker2=1, nuclEnlargement=2, nameMarker1="GFP", nameMarker2="Actinina";
var thDapi=20, thMarker1=25, thMarker2=25, findMaximaDetect=5, meanRadius=2;


macro "IF_CellClassDoublePhenotype Action Tool 1 - Cf00T2d15IT6d10m"{
		
	close("*");
	roiManager("reset");
	run("Clear Results");
		
	macroInfo();
	file=File.openDialog("Select File");
	openFileFormat(file);
	
	Dialog.create("Channels");
	Dialog.addMessage("Nuclei Parameters");	
	Dialog.addNumber("Channel", cDAPI);
	Dialog.addNumber("Threshold", thDapi);
	Dialog.addNumber("Blurring", meanRadius);
	Dialog.addNumber("Separation", findMaximaDetect);
	Dialog.addMessage("Marker 1 Parameters");	
	Dialog.addString("Name", nameMarker1);
	Dialog.addNumber("Channel", cMarker1);	
	Dialog.addNumber("Threshold", thMarker1);	
	Dialog.addMessage("Marker 2 Parameters");	
	Dialog.addString("Name", nameMarker2);
	Dialog.addNumber("Channels", cMarker2);
	Dialog.addNumber("Threshold", thMarker2);
	options = newArray("Manual","Automatic","BatchMode");
	Dialog.addChoice("Thresholds Selection", options);
	Dialog.show();	
		
	
	cDAPI= Dialog.getNumber();
	thDapi= Dialog.getNumber();
	meanRadius= Dialog.getNumber();
	findMaximaDetect= Dialog.getNumber();
	var nameMarker1 = Dialog.getString();
	cMarker1= Dialog.getNumber();
	thMarker1= Dialog.getNumber();
	var nameMarker2 = Dialog.getString();
	cMarker2= Dialog.getNumber();
	thMarker2= Dialog.getNumber();
	auto = Dialog.getChoice();
	
	close("*");
	
	print("\\Clear");
	print(">>> Starting Single File Processing ");
	print("> Processing file --> "+file);
	doublePhenotypeDetection('-',file, cDAPI,cMarker1,cMarker2,thDapi,meanRadius,findMaximaDetect,thMarker1,thMarker2,auto);
	print(">>> Quantification Complete!");
}
	
	
macro "IF_CellClassDoublePhenotype Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	macroInfo(); // Run predefined macro to gather information
	
	Dialog.create("Channels");
	Dialog.addMessage("Nuclei Parameters");	
	Dialog.addNumber("Channel", cDAPI);
	Dialog.addNumber("Threshold", thDapi);
	Dialog.addNumber("Blurring", meanRadius);
	Dialog.addNumber("Separation", findMaximaDetect);
	Dialog.addMessage("Marker 1 Parameters");	
	Dialog.addString("Name", nameMarker1);
	Dialog.addNumber("Channel", cMarker1);	
	Dialog.addNumber("Threshold", thMarker1);	
	Dialog.addMessage("Marker 2 Parameters");	
	Dialog.addString("Name", nameMarker2);
	Dialog.addNumber("Channels", cMarker2);
	Dialog.addNumber("Threshold", thMarker2);
	options = newArray("Manual","Automatic","BatchMode");
	Dialog.addChoice("Thresholds Selection", options);
	Dialog.show();	
		
	
	cDAPI= Dialog.getNumber();
	thDapi= Dialog.getNumber();
	meanRadius= Dialog.getNumber();
	findMaximaDetect= Dialog.getNumber();
	var nameMarker1 = Dialog.getString();
	cMarker1= Dialog.getNumber();
	thMarker1= Dialog.getNumber();
	var nameMarker2 = Dialog.getString();
	cMarker2= Dialog.getNumber();
	thMarker2= Dialog.getNumber();
	auto = Dialog.getChoice();
	

	
	close("*"); // Close all open windows
	roiManager("Reset"); // Reset ROI manager
	run("Clear Results"); // Clear previous results

    InDir=getDirectory("Choose a Directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	print("\\Clear");
	print(">>> Starting Batch Mode Processing...");
	print(">>> Found " + L + " files in directory: " + InDir);

	for (j=0; j<L; j++)
	{
		file = list[j];
		print("=====================================================");
		print(">>> Processing File (" + (j+1) + "/" + L + "): " + file);
		doublePhenotypeDetection(InDir,file, cDAPI,cMarker1,cMarker2,thDapi,meanRadius,findMaximaDetect,thMarker1,thMarker2,auto);
		close("*");
	}
    print(">>> Batch Mode Complete!");
    Dialog.create("DONE!");
    Dialog.show();
}
	
/**
 * Core processing pipeline: Segments tissue, detects nuclei, segments two cellular markers,
 * calculates colocalization, saves ROIs, outputs cell counts to an Excel file, and generates
 * a combined visualization image.
 *
 * @param {string} InDir - The input directory containing the image (use '-' for single file).
 * @param {string} file - The name or path of the file to process.
 * @param {number} cDAPI - Channel index for the DAPI (nuclei) staining.
 * @param {number} cMarker1 - Channel index for the first marker.
 * @param {number} cMarker2 - Channel index for the second marker.
 * @param {number} thDapi - Threshold value to segment DAPI.
 * @param {number} meanRadius - Radius for mean filtering the DAPI channel.
 * @param {number} findMaximaDetect - Prominence value for detecting distinct nuclei (Find Maxima).
 * @param {number} thMarker1 - Threshold value to segment Marker 1.
 * @param {number} thMarker2 - Threshold value to segment Marker 2.
 * @param {boolean} auto - If true, applies 'Huang dark' auto-thresholding instead of manual values.
 */
function doublePhenotypeDetection(InDir,file, cDAPI,cMarker1,cMarker2,thDapi,meanRadius,findMaximaDetect,thMarker1,thMarker2,auto){
	
	print("--- Initializing environment and loading image...");
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
	
	if (InDir != "-") {
		file=InDir+file;
		openFileFormat(file);
	}else{
		openFileFormat(file);
	}		
	
	// Set batch mode 
	if(auto == "Automatic"){setBatchMode(true);}
	else if (auto == "Manual"){setBatchMode(false);}
	else if (auto = "BatchMode"){setBatchMode(true);}
	
	// Get file information
	MyTitle=getTitle();
	output=getInfo("image.directory");
		
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	getDimensions(width, height, channels, slices, frames);
	getVoxelSize(width, height, depth, unit);
		
	// TISSUE SEGMENTATION
	print("--- Step 1: Segmenting overall tissue area...");
	run("Make Composite");
	run("Duplicate...", "title=merge duplicate ");
	run("RGB Color");
	run("RGB to Luminance");
	rename("merge");
	
	// Convert image to binary mask
	run("Subtract Background...", "rolling=500");
	setThreshold(15, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=6");
	
	// Add segmented tissue region to ROI manager
	roiManager("Show None");
	run("Create Selection");
	Roi.setName("Tissue");
	Roi.setStrokeColor("green");
	run("Add to Manager");	// ROI1 --> WHOLE TISSUE
	roiManager("measure");
	tissueArea=getResult("Area", 0);
	run("Select None");
	close("merge");
	print("    Tissue Area found: " + tissueArea + " um^2");

	// Post-processing: Clear outside tissue region
	selectWindow(MyTitle);
	roiManager("select", 0);
	run("Colors...", "foreground=white background=black selection=green");
	run("Clear Outside","stack");
	run("Select None");
	
	
	// SEGMENT NUCLEI FROM DAPI
	print("--- Step 2: Segmenting nuclei from DAPI channel...");
	selectWindow(MyTitle);
	run("Duplicate...", "title=nucleiMask duplicate channels="+cDAPI);
	run("8-bit");
	run("Mean...", "radius="+meanRadius);
	
	run("Subtract Background...", "rolling=200");
	run("Enhance Local Contrast (CLAHE)", "blocksize=99 histogram=256 maximum=2 mask=*None* fast_(less_accurate)");
	run("Duplicate...", "title=EDM duplicate ");
	
	selectWindow("nucleiMask");
	
	// Apply thresholding and morphological operations to segment nuclei
	if(auto == "Automatic"){setAutoThreshold("Huang dark stack");}
	else if (auto == "Manual"){run("Threshold..."); setThreshold(thDapi,255); selectWindow("Threshold"); waitForUser("Select Threshold");}
	else if (auto == "BatchMode"){setThreshold(thDapi,255);}
	
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Select All");
	RoiManager.selectByName("Tissue");
	setBackgroundColor(255,255,255);
	run("Clear Outside");
	setBackgroundColor(0,0,0);
	run("Select None");
	
	// Perform marker-controlled watershed segmentation
	selectWindow("EDM");
	run("Find Maxima...", "prominence="+findMaximaDetect+" output=[Single Points]");
	rename("nucleiMaxima");
	
	selectWindow("nucleiMask");
	run("Select None");
	run("Duplicate...", "title=nucleiEdges");
	run("Find Edges");
	
	// Apply marker-controlled watershed
	run("Marker-controlled Watershed", "input=nucleiEdges marker=nucleiMaxima mask=nucleiMask binary calculate use");
	selectWindow("nucleiEdges-watershed");
	run("8-bit");
	setThreshold(1, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Create Selection");
	Roi.setName("nuclei");
	Roi.setStrokeColor("blue");
	run("Add to Manager");	// ROI2 --> Watershed NUCLEI
	run("Select None");
	
	// Cleanup and save segmented nuclei
	close("nucleiEdges");
	close("nucleiMask");
	close("nucleiMaxima");
	close("EDM");
	selectWindow("nucleiEdges-watershed");
	rename("nucleiMask");
	roiManager("Save", OutDir+File.separator+MyTitle+"_roisDAPI.zip");
	print("    Saved DAPI ROIs to zip.");
		
	// SEGMENT 1st MARKER
	print("--- Step 3: Segmenting Marker 1 (" + nameMarker1 + ") channel...");
	selectWindow(MyTitle);
	run("Duplicate...", "title=marker1Mask duplicate channels="+cMarker1);
	run("8-bit");
	
	run("Subtract Background...", "rolling=200");
	run("Median...", "radius=1");
		
	if(auto == "Automatic"){setAutoThreshold("Huang dark stack");}
	else if (auto == "Manual"){run("Threshold..."); setThreshold(thMarker1, 255); selectWindow("Threshold"); waitForUser("Select Threshold");}
	else if (auto == "BatchMode"){setThreshold(thMarker1,255);}
	
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=2");
	run("Analyze Particles...", "size=100-Infinity pixel show=Masks in_situ");
	run("Create Selection");
	if (selectionType() != -1) {
		Roi.setName(nameMarker1);
		Roi.setStrokeColor("Red");
		run("Add to Manager");
	} else {
		print("    WARNING: No " + nameMarker1 + " particles found — marker mask is empty.");
	}
	run("Select None");
	
	// SEGMENT 2nd MARKER
	print("--- Step 4: Segmenting Marker 2 (" + nameMarker2 + ") channel...");
	selectWindow(MyTitle);
	run("Select None");
	run("Duplicate...", "title=marker2Mask duplicate channels="+cMarker2);
	run("8-bit");
	
	run("Subtract Background...", "rolling=200");
	run("Median...", "radius=1");
	
	if(auto == "Automatic"){setAutoThreshold("Huang dark stack");}
	else if (auto == "Manual"){run("Threshold..."); setThreshold(thMarker2, 255); selectWindow("Threshold"); waitForUser("Select Threshold");}
	else if (auto == "BatchMode"){setThreshold(thMarker2,255);}
	
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=2");
	run("Analyze Particles...", "size=100-Infinity pixel show=Masks in_situ");
	run("Create Selection");
	if (selectionType() != -1) {
		Roi.setName(nameMarker2);
		Roi.setStrokeColor("Green");
		run("Add to Manager");
	} else {
		print("    WARNING: No " + nameMarker2 + " particles found — marker mask is empty.");
	}
	run("Select None");
	
	
	
	// CHECK WHICH NUCLEI CONTAIN MARKER 1
	print("--- Step 5: Calculating Colocalization for Marker 1...");
	roiManager("Reset");
	run("Clear Results");
	
	selectWindow("nucleiMask");
	run("Analyze Particles...", "size=1-Inf show=Masks add in_situ");
	roiManager("Show None");
	nCells= roiManager("Count");
	print("    Total DAPI cells detected: " + nCells);
	
	selectWindow("nucleiMask");
	run("Select None");
	run("Duplicate...", "title=marker1Positive");
	run("Select All");
	setBackgroundColor(255, 255, 255);
	run("Clear", "slice");
	setBackgroundColor(0,0,0);
	run("Select None");
	wait(100);
	
		
	selectWindow("marker1Mask");
	getStatistics(area, mean);
	if (mean > 0) {
		run("Select None");
		roiManager("Deselect");
		roiManager("Measure");
		roiManager("Show None");
		positiveRois = filterTableColum("Results", "Mean", ">", 0);
		roiManager("select", positiveRois);
		roiManager("save selected", OutDir + File.separator + MyTitle + "_roisMarker1.zip");
		roiManager("Reset");
		roiManager("Open", OutDir + File.separator + MyTitle + "_roisMarker1.zip");
		selectWindow("marker1Positive");
		run("Colors...", "foreground=black background=white selection=red");
		roiManager("Fill");
		nMarker1Postive = roiManager("Count");
	} else {
		nMarker1Postive = 0;
		print("    WARNING: " + nameMarker1 + " mask is empty — skipping positive detection.");
	}
	roiManager("Show None");
	print("    " + nameMarker1 + " Positive Cells: " + nMarker1Postive);

	// CHECK WHICH NUCLEI CONTAIN MARKER 2
	print("--- Step 6: Calculating Colocalization for Marker 2...");
	roiManager("Reset");
	run("Clear Results");
	
	selectWindow("nucleiMask");
	run("Analyze Particles...", "size=1-Inf show=Masks add in_situ");
	
	selectWindow("nucleiMask");
	run("Select None");
	run("Duplicate...", "title=marker2Positive");
	run("Select All");
	setBackgroundColor(255, 255, 255);
	run("Clear", "slice");
	setBackgroundColor(0,0,0);
	run("Select None");
	wait(100);
	
	
	selectWindow("marker2Mask");
	getStatistics(area, mean);
	if (mean > 0) {
		run("Select None");
		roiManager("Deselect");
		roiManager("Measure");
		roiManager("Show None");
		positiveRois = filterTableColum("Results", "Mean", ">", 0);
		roiManager("select", positiveRois);
		roiManager("save selected", OutDir + File.separator + MyTitle + "_roisMarker2.zip");
		roiManager("Reset");
		roiManager("Open", OutDir + File.separator + MyTitle + "_roisMarker2.zip");
		selectWindow("marker2Positive");
		run("Colors...", "foreground=black background=white selection=red");
		roiManager("Fill");
		nMarker2Positve = roiManager("Count");
	} else {
		nMarker2Positve = 0;
		print("    WARNING: " + nameMarker2 + " mask is empty — skipping positive detection.");
	}
	roiManager("Show None");
	print("    " + nameMarker2 + " Positive Cells: " + nMarker2Positve);
	
	// CHECK CELLS THAT HAVE BOTH MARKERS (DOUBLE POSITIVE)
	print("--- Step 7: Identifying Double Positive Cells...");
	imageCalculator("AND create", "marker1Positive", "marker2Positive");
	rename("Marker1-Marker2Positive");
	roiManager("Reset");
	run("Clear Results");
	run("Analyze Particles...", "size=1-Inf show=Masks add in_situ");
	roiManager("Show None");
	nDoublePositive = roiManager("Count");
	run("Select None");
	roiManager("Show None");
	print("    Double Positive Cells: " + nDoublePositive);
	
	// RESULTS 
	print("--- Step 8: Saving quantification results to Excel...");
	run("Clear Results");
	if (File.exists(output + File.separator + "QuantificationResults_IFCellClassDoublePhenotype"+nameMarker1+nameMarker2+".xls")) {
	    // if exists add and modify
	    open(output + File.separator + "QuantificationResults_IFCellClassDoublePhenotype"+nameMarker1+nameMarker2+".xls");
	    IJ.renameResults("Results");
	}
	i = nResults;
	setResult("Label", i, MyTitle);
	setResult("Tissue Area (um^2)", i, tissueArea);
	setResult("# Cells", i, nCells);
	setResult("# "+nameMarker1+" cells", i, nMarker1Postive);
	setResult("# "+nameMarker2+" cells", i, nMarker2Positve);
	setResult("# DoublePositive cells", i, nDoublePositive);
	saveAs("Results", output + File.separator + "QuantificationResults_IFCellClassDoublePhenotype"+nameMarker1+nameMarker2+".xls");
	
	run("Collect Garbage");
	setBatchMode("exit and display");
	roiManager("Show None");
	roiManager("Show None");
	
	close("*ask");
	
	// DRAW (Visualization)
	print("--- Step 9: Drawing marker visualization on output image...");
	selectWindow("merge (RGB)");
	run("Select None");
	selectWindow("marker1Positive");
	run("Select None");
	run("Find Maxima...", "noise=10 output=[Point Selection] light");
	setTool("multipoint");
	run("Point Tool...", "type=Hybrid color=Red cross=Magenta marker=Small");
	selectWindow("merge (RGB)");
	if (nMarker1Postive != 0) {
	    run("Restore Selection");
	}
	// Emulate "Ctrl + F" drawing on overlay
	run("In [+]", " "); run("In [+]", " "); run("In [+]", " "); run("In [+]", " ");
	run("In [+]", " "); run("In [+]", " "); run("In [+]", " "); run("In [+]", " ");
	run("In [+]", " "); run("In [+]", " "); run("In [+]", " ");
	run("Flatten");
	close("marker1Positive");
	
	rename("firstMarker");
	wait(200);
	close("merge (RGB)");
	
    selectWindow("marker2Positive");
	run("Select None");
	run("Find Maxima...", "noise=10 output=[Point Selection] light");
	setTool("multipoint");
	run("Point Tool...", "type=Hybrid selection=Green cross=Green marker=Small");
	selectWindow("firstMarker");
	if (nMarker2Positve!=0) {
		run("Restore Selection");
	}
	run("In [+]"); run("In [+]"); run("In [+]"); run("In [+]"); run("In [+]");
	run("In [+]"); run("In [+]"); run("In [+]"); run("In [+]"); run("In [+]");
	run("In [+]");
	run("Flatten");
	rename("secondMaker");
	wait(1000);
	close("firstMarker");
	close("marker2*");
	
	selectWindow("Marker1-Marker2Positive");
	run("Select None");
	run("Find Maxima...", "noise=10 output=[Point Selection] light");
	setTool("multipoint");
	run("Point Tool...", "type=Hybrid selection=Magenta cross=Yellow marker=Small");
	selectWindow("secondMaker");
	if (nDoublePositive!=0) {
		run("Restore Selection");
	}
	run("In [+]"); run("In [+]"); run("In [+]"); run("In [+]"); run("In [+]");
	run("In [+]"); run("In [+]"); run("In [+]"); run("In [+]"); run("In [+]");
	run("In [+]");
	run("Flatten");
	rename("thirdMarker");
	wait(200);
	close("secondMaker");
	
	selectWindow("thirdMarker");
	saveAs("Jpeg", OutDir+File.separator+MyTitle+"_analyzed.jpg");
	wait(100);
	rename(MyTitle+"_analyzed.jpg");
	setBatchMode("exit and display");
	close("\\Others");
	setTool("zoom");
	
	print("--- Done generating visualization!");
}

/**
 * Subtracts background from an image using CLIJ/CLIJx GPU acceleration.
 * (Note: Currently disabled/commented out in the main pipeline).
 * * @param {string} name - The title of the input image window.
 * @param {number} sigma - The standard deviation for the Gaussian blur applied during subtraction.
 */
function backgroundSubstract2DGPU(name, sigma) {
	// Load CLIJ GPU accelerator and CLIJ2 Macro Extensions
	run("CLIJx Version 0.32.1.1");
	run("CLIJ2 Macro Extensions", "cl_device=[NVIDIA GeForce RTX 4060 Laptop GPU]");
	
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
	rename(name);
}
	
/**
 * Filters the ImageJ Results table to isolate rows that meet a specific condition,
 * and returns the array of corresponding original row indices.
 * * @param {string} tableName - The title/name of the Results table to evaluate.
 * @param {string} columnName - The header of the column to check (e.g., "Mean").
 * @param {string} filterType - The logic operator ("<" or ">").
 * @param {number} threshold - The threshold value to filter against.
 * @return {array} positiveRois - An array containing the "Index" values of rows that passed the filter.
 */
function filterTableColum(tableName, columnName, filterType, threshold)
{
	// Select the table window
	selectWindow(tableName);
	
	// Get the number of results in the table
	n = nResults;
	
	// Create an array of indices for the table rows
	id = Array.slice(Array.getSequence(n + 1), 0, n);
	
	// Set the "Index" column in the table
	Table.setColumn("Index", id);
	
	// Sort the table based on the specified column
	Table.sort(columnName);
	
	// Get the specified column from the table
	column = Table.getColumn(columnName);
	
	// Loop through the values in the column
	found = false;
	for (i = 0; i < lengthOf(column); i++) {
		// Get the value at the current position
		value = column[i];

		// Check if the filter type is "<"
		if (filterType == "<") {
			// If the value is greater than the threshold, delete rows below the current position
			if (value > threshold) {
				selectWindow(tableName);
				Table.deleteRows(i, lengthOf(column) - 1);
				found = true;
				break;
			}
		} else if (filterType == ">") {
			// If the value is greater than the threshold, delete rows above the current position
			if (value > threshold) {
				selectWindow(tableName);
				if (i > 0) Table.deleteRows(0, i - 1);
				found = true;
				break;
			}
		}
	}
	// No value passed the ">" filter: all means are 0 → no positive cells → clear table so marker mask stays white
	if (filterType == ">" && !found) {
		selectWindow(tableName);
		Table.deleteRows(0, lengthOf(column) - 1);
	}
	
	// Get the updated indices of rows that meet the filtering criteria
	positiveRois = Table.getColumn("Index");
	
	// Return the array of positive indices
	return positiveRois;
}

/**
 * Utility function to correctly open different image formats via standard ImageJ
 * protocols or through Bio-Formats depending on the file extension.
 * * @param {string} file - The file path to evaluate and open.
 */
function openFileFormat(file){
			
	if(endsWith(file,".jpg")||endsWith(file,".tif")){
		if (!endsWith(file,"ome.tif")){
			open(file);
		}else{
			run("Bio-Formats", "open=["+file+"] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
		}
	}else if(endsWith(file,".czi") || endsWith(file,".svs") || endsWith(file,"ome.tif")){
		run("Bio-Formats", "open=["+file+"] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
	}
}