


/**
 * Displays an HTML dialog with information about the macro, its purpose,
 * author details, expected inputs, and output measurements.
 */
function macroInfo(){
    
    scripttitle= "Circulating Tumor Cells (CTCs) Classification - Triple Marker Phenotyping";
    version= "1.00";
    date= "2026";
    
    // * Tests Images:
    imageAdquisition="Confocal / Fluorescent Images: 4 Channels (DAPI + CD45 + Vimentin + Cytokeratin)";
    imageType="2D Multichannel Composite Images";  
    voxelSize="Voxel size: Read from metadata";
    format="Format: Bio-Formats compatible (.czi, .tif, .svs, OME-TIFF)";   
 
    //* GUI User Requirements:
    parameter1="Channel indices for DAPI, CD45, Vimentin, and Cytokeratin"; 
    parameter2="Threshold values for DAPI and each marker (or select Automatic/Batch mode)";
    parameter3="DAPI preprocessing: mean filter radius and find maxima prominence";
    
    //  Action tools:
    button1="Tool 1: Single File processing with interactive UI dialog and manual thresholding";
    button2="Tool 2: Batch Mode processing with directory selection and auto-thresholding";

    //  OUTPUT
    roisOutput="AnalyzedImages folder: *_roisDAPI.zip (nucleus ROIs for each cell)";
    excel="QuantificationResults_IF_CTCsPhenotype.xls (Excel spreadsheet)";
    feature1="[Label] - Source image filename";
    feature2="Cells ID - Individual cell identifier (Cell1, Cell2, etc.)";
    feature3="CD45Class - CD45 marker status (+/-)";
    feature4="VimentinaClass - Vimentin marker status (+/-)"; 
    feature5="CitokeratinaClass - Cytokeratin marker status (+/-)"; 
    
    /*
     * Version: 1.00 
     * Author: Tomas Muñoz 2026 
     * Date : 2026
     * CTC phenotyping based on triple-marker classification
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
        +"<p><font size=2 color=Purple><i>ImageJ Macros - Cell Phenotyping</i></p>"
        +"<h2><font size=3 color=black>"+scripttitle+"</h2>"
        +"<p><font size=2>Modified by Tomas Mu&ntilde;oz Santoro</p>"
        +"<p><font size=2>Version: "+version+" ("+date+")</p>"
        +"<p><font size=2> contact tmsantoro@unav.es</p>" 
        +"<p><font size=2> Available for use/modification/sharing under the "+"<p4><a href=https://opensource.org/licenses/MIT/>MIT License</a></p>"
        +"<h2><font size=3 color=black>Developed for</h2>"
        +"<p><font size=3  i>Input Images</i></p>"
        +"<ul id=list-style-3><font size=2  i><li>"+imageAdquisition +"</li><li>"+imageType+"</li><li>"+voxelSize+"</li><li>"+format+"</li></ul>"
        +"<p><font size=3 i>Action tools (Buttons)</i></p>"
        +"<ol><font size=2  i><li>"+button1+"</li><li>"+button2+"</li></ol>"
        +"<p><font size=3  i>PARAMETERS: </i></p>"
        +"<ul id=list-style-3><font size=2  i>"
        +"<li>"+parameter1+"</li><li>"+parameter2+"</li><li>"+parameter3+"</li></ul>"
        +"<p><font size=3  i>Segmentation & Processing: </i></p>"
        +"<ul id=list-style-3><font size=2  i><li>Nuclei detection via marker-controlled watershed on DAPI channel</li><li>Individual marker segmentation with thresholding</li><li>Single-cell classification based on marker co-expression</li></ul>"
        +"<p><font size=3  i>Quantification Results: </i></p>"
        +"<p><font size=3 i>"+roisOutput+"</i></p>"
        +"<p><font size=3  i>"+excel+"</i></p>"
        +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li><li>"+feature5+"</li></ul>"
        +"<h0><font size=5></h0>"
        +"");
}

var cDAPI=4, cMarker1=1, cMarker2=2, cMarker3 = 3,	markerList = newArray("CD45","Vimentina","Citokeratina"), nameMarker1="CD45", nameMarker2="Vimentina", nameMarker3="Citokeratina";
var thDapi=20, findMaximaDetect=15, meanRadius=1, thMarker1=25, thMarker2=25,thMarker3=25, thPer = 15, checkbox=false;

macro "IF_CellClass_CTCphenotype Action Tool 1 - Cf00T2d15IT6d10m"{
		
	close("*");
	roiManager("reset");
	run("Clear Results");
		
	macroInfo();
	file=File.openDialog("Select File");
	//openFileFormat(file);
	
	Dialog.create("Channels");
	Dialog.addMessage("Nuclei Parameters");	
	Dialog.addNumber("Channel", cDAPI);
	Dialog.addNumber("Threshold", thDapi);
	Dialog.addNumber("Blurring", meanRadius);
	Dialog.addNumber("Separation", findMaximaDetect);
	Dialog.addMessage("Marker 1 Parameters");	
	Dialog.addChoice("Name", markerList, nameMarker1);
	Dialog.addNumber("Channel", cMarker1);	
	Dialog.addNumber("Threshold", thMarker1);	
	Dialog.addMessage("Marker 2 Parameters");	
	Dialog.addChoice("Name", markerList, nameMarker2);
	Dialog.addNumber("Channel", cMarker2);
	Dialog.addNumber("Threshold", thMarker2);	
	Dialog.addMessage("Marker 3 Parameters");	
	Dialog.addChoice("Name", markerList, nameMarker3);
	Dialog.addNumber("Channel", cMarker3);
	Dialog.addNumber("Threshold", thMarker3);
	options = newArray("Manual","Automatic","BatchMode");
	Dialog.addChoice("Thresholds Selection", options);
	Dialog.addNumber("% of positive signal area for marker classification", thPer);
	Dialog.addCheckbox("Save single cell cropped images?", checkbox);
	Dialog.show();	
		
	
	cDAPI = Dialog.getNumber();
	thDapi = Dialog.getNumber();
	meanRadius = Dialog.getNumber();
	findMaximaDetect = Dialog.getNumber();
	var nameMarker1 = Dialog.getChoice();
	cMarker1 = Dialog.getNumber();
	thMarker1 = Dialog.getNumber();
	var nameMarker2 = Dialog.getChoice();
	cMarker2 = Dialog.getNumber();
	thMarker2 = Dialog.getNumber();
	var nameMarker3 = Dialog.getChoice();
	cMarker3 = Dialog.getNumber();
	thMarker3 = Dialog.getNumber();
	auto = Dialog.getChoice();
	thPer = Dialog.getNumber();
	checkbox = Dialog.getCheckbox();

	
	print("\\Clear");
	print(">>> Starting Single File Processing ");
	print("> Processing file --> "+file);
	cellPhenotyper("-",file, cDAPI,cMarker1,cMarker2,cMarker3,thDapi,meanRadius,findMaximaDetect,thMarker1,thMarker2,thMarker3,auto,thPer,checkbox);
	showMessage(">>> Quantification Complete!");
}
	
	
macro "IF_CellClassDoublePhenotype Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	close("*"); // Close all open windows
	roiManager("Reset"); // Reset ROI manager
	run("Clear Results"); // Clear previous results

	
	macroInfo(); // Run predefined macro to gather information
	
	markerList = newArray("CD45","Vimentina","Citokeratina");
	
	Dialog.create("Channels");
	Dialog.addMessage("Nuclei Parameters");	
	Dialog.addNumber("Channel", cDAPI);
	Dialog.addNumber("Threshold", thDapi);
	Dialog.addNumber("Blurring", meanRadius);
	Dialog.addNumber("Separation", findMaximaDetect);
	Dialog.addMessage("Marker 1 Parameters");	
	Dialog.addChoice("Name", markerList, nameMarker1);
	Dialog.addNumber("Channel", cMarker1);	
	Dialog.addNumber("Threshold", thMarker1);	
	Dialog.addMessage("Marker 2 Parameters");	
	Dialog.addChoice("Name", markerList, nameMarker2);
	Dialog.addNumber("Channel", cMarker2);
	Dialog.addNumber("Threshold", thMarker2);	
	Dialog.addMessage("Marker 3 Parameters");	
	Dialog.addChoice("Name", markerList, nameMarker3);
	Dialog.addNumber("Channel", cMarker3);
	Dialog.addNumber("Threshold", thMarker3);
	options = newArray("Manual","Automatic","BatchMode");
	Dialog.addChoice("Thresholds Selection", options);
	Dialog.addNumber("% of positive signal area for marker classification", thPer);
	Dialog.addCheckbox("Save single cell cropped images?", checkbox);
	Dialog.show();	
		
	cDAPI = Dialog.getNumber();
	thDapi = Dialog.getNumber();
	meanRadius = Dialog.getNumber();
	findMaximaDetect = Dialog.getNumber();
	var nameMarker1 = Dialog.getChoice();
	cMarker1 = Dialog.getNumber();
	thMarker1 = Dialog.getNumber();
	var nameMarker2 = Dialog.getChoice();
	cMarker2 = Dialog.getNumber();
	thMarker2 = Dialog.getNumber();
	var nameMarker3 = Dialog.getChoice();
	cMarker3 = Dialog.getNumber();
	thMarker3 = Dialog.getNumber();
	auto = Dialog.getChoice();
	thPer = Dialog.getNumber();
	checkbox = Dialog.getCheckbox();

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
		if (endsWith(file, ".czi") || endsWith(file, ".tif")){
			cellPhenotyper(InDir,file,cDAPI,cMarker1,cMarker2,cMarker3,thDapi,meanRadius,findMaximaDetect,thMarker1,thMarker2,thMarker3,auto,thPer,checkbox);
			close("*");
		}
	}
    print(">>> Batch Mode Complete!");
    showMessage(">>> Quantification Complete!");
}
	
   		


function cellPhenotyper(InDir,file, cDAPI,cMarker1,cMarker2,cMarker3,thDapi,meanRadius,findMaximaDetect,thMarker1,thMarker2,thMarker3,auto,thPer,checkbox){
/**
 * Core processing pipeline: Segments tissue, detects nuclei, segments  cellular markers,
 , outputs cell counts to an Excel file, and generates a combined visualization image.
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

	print("--- Step 1: Initializing environment and loading image...");
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
	else if (auto == "BatchMode"){setBatchMode(true);}
	
	// Get file information
	MyTitle=getTitle();
	MyTitle = File.nameWithoutExtension;
	rename(MyTitle);
	output=getInfo("image.directory");
		
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	getDimensions(width, height, channels, slices, frames);
	getVoxelSize(width, height, depth, unit);
		
	// SEGMENT NUCLEI FROM DAPI
	print("--- Step 2: Detect Cells Nuclei from DAPI channel...");
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
	run("Analyze Particles...", "size=10-Infinity pixel show=Masks add in_situ");
	
	imageLabel = newArray();
	cellIds = newArray();
    nCells = roiManager("Count");
    
    if (nCells >0){
		for (i = 0; i < nCells; i++) {
			roiManager("select", i);
			roiManager("rename", "Cell"+(i+1));
			imageLabel[i] = MyTitle;
			cellIds[i] = "Cell"+(i+1);
		}
    }else{
    	print("NO CELLS DETECTING. Killing Process.");
    	break;
    }
    
	// Cleanup and save segmented nuclei
	close("nucleiEdges");
	close("nucleiMask");
	close("nucleiMaxima");
	close("EDM");
	selectWindow("nucleiEdges-watershed");
	rename("nucleiMask");
	roiManager("Save", OutDir+File.separator+MyTitle+"_roisDAPI.zip");
	close("nucleiMask");
		
	// SEGMENT MARKERs
	print("--- Step 3: Segmenting Markers Positive Signal...");
	
	
	selectWindow(MyTitle);
	run("Duplicate...", "title="+nameMarker1+" duplicate channels="+cMarker1);
	thMarker1 = segmentMarker(nameMarker1,auto,thMarker1);
	
	selectWindow(MyTitle);
	run("Duplicate...", "title="+nameMarker2+" duplicate channels="+cMarker2);
	thMarker2 = segmentMarker(nameMarker2,auto,thMarker2);
	
	selectWindow(MyTitle);
	run("Duplicate...", "title="+nameMarker3+" duplicate channels="+cMarker3);
	thMarker3 = segmentMarker(nameMarker3,auto,thMarker3);
	
	// CHECK WHICH NUCLEI CONTAIN MARKER 1
	print("--- Step 4: Calculating Single Cell Markers Classification...");
	run("Set Measurements...", "area mean modal area_fraction redirect=None decimal=2");
	
	// marker names are or ("CD45","Vimentina","Citokeratina") 
	// assign marker results to the correct marker depending on the name of the marker assigned 
	// find which array is of each channel 

	//thPer = 10;
	
	if (nameMarker1 == "CD45"){
		cd45Results = cellClassPhenotype(nameMarker1, thPer);
		thCD45 = thMarker1;

	}else if (nameMarker1 == "Vimentina"){
		vimResults = cellClassPhenotype(nameMarker1, thPer);
		thVim = thMarker1;
	}else if (nameMarker1 == "Citokeratina"){
		ckResults = cellClassPhenotype(nameMarker1, thPer);
		thCK = thMarker1;
	}	
	if (nameMarker2 == "CD45"){
		cd45Results = cellClassPhenotype(nameMarker2, thPer);
		thCD45 = thMarker2;
	}else if (nameMarker2 == "Vimentina"){
		vimResults = cellClassPhenotype(nameMarker2, thPer);
		thVim = thMarker2;
	}else if (nameMarker2 == "Citokeratina"){
		ckResults = cellClassPhenotype(nameMarker2, thPer);
		thCK = thMarker2;
	}	
	if (nameMarker3 == "CD45"){
		cd45Results = cellClassPhenotype(nameMarker3, thPer);
		thCD45 = thMarker3;
	}else if (nameMarker3 == "Vimentina"){
		vimResults = cellClassPhenotype(nameMarker3, thPer);
		thVim = thMarker3;
	}else if (nameMarker3 == "Citokeratina"){
		ckResults = cellClassPhenotype(nameMarker3, thPer);
		thCK = thMarker3;
	}	

	//create a array of length as results with the threshold repeated
	thCD45Array = newArray();
	thVimArray = newArray();
	thCKArray = newArray();
	
	for (i = 0; i < nCells; i++) {
		thCD45Array[i] = thCD45;
		thVimArray[i] = thVim;
		thCKArray[i] = thCK;
	}
	
	/* 	IS CTC IF : 
	DAPI (+) CK(+) Vim(+) CD45(-) 
	DAPI (+) CK(+) Vim(-) CD45(-) 
	DAPI (+) CK(-) Vim(+) CD45(-) 
	DAPI (+) CK(+) Vim(+) CD45(+) 
	DAPI (+) CK(+) Vim(-) CD45(+) 
	*/

	// Generate marker classification results for each cell
	ctcPhenotypeResults = newArray();
	for (i = 0; i < nCells; i++) {
		if (cd45Results[i] == "-" && ckResults[i] == "+" && vimResults[i] == "+") {
			ctcPhenotypeResults[i] = "CTC - Epithelial-Mesenchymal";
		} else if (cd45Results[i] == "-" && ckResults[i] == "+" && vimResults[i] == "-") {
			ctcPhenotypeResults[i] = "CTC - Epithelial";
		} else if (cd45Results[i] == "-" && ckResults[i] == "-" && vimResults[i] == "+") {
			ctcPhenotypeResults[i] = "CTC - Mesenchymal";
		} else if (cd45Results[i] == "+" && ckResults[i] == "+" && vimResults[i] == "+") {
			ctcPhenotypeResults[i] = "CTC - Epithelial-Mesenchymal with CD45";
		} else if (cd45Results[i] == "+" && ckResults[i] == "+" && vimResults[i] == "-") {
			ctcPhenotypeResults[i] = "CTC - Epithelial with CD45";
		} else {
			ctcPhenotypeResults[i] = "Non-CTC or Unclassified";
		}
	}

	// RESULTS 
	print("--- Step 5: Saving quantification results to Excel...");

	if (File.exists(output + File.separator + "QuantificationResults_IF_CTCsPhenotype.xls")) {
	    // if exists add and modify
	    open(output + File.separator + "QuantificationResults_IF_CTCsPhenotype.xls");
    	IJ.renameResults("Results");
    	selectWindow("Results");
    	label = Table.getColumn("[Label]");
		ids = Table.getColumn("Cells ID");
		thCD45 = Table.getColumn("thCD45");
		cd45 = Table.getColumn("CD45");
		thVim = Table.getColumn("thVimentina");
		vim = Table.getColumn("Vimentina");
		thCK = Table.getColumn("thCitokeratina");
		ck = Table.getColumn("Citokeratina");
		ctcPhenotype = Table.getColumn("CTC Phenotype");
		
		imageLabel = Array.concat(label,imageLabel);
		cellIds = Array.concat(ids,cellIds);
		thCD45Array = Array.concat(thCD45Array,thCD45);
		cd45Results = Array.concat(cd45,cd45Results);
		thVimArray = Array.concat(thVimArray,thVim);
		vimResults = Array.concat(vim,vimResults);
		thCKArray = Array.concat(thCKArray,thCK);
		ckResults = Array.concat(ck,ckResults);
		ctcPhenotypeResults = Array.concat(ctcPhenotype,ctcPhenotypeResults);
	}
	run("Clear Results");
	close("Results");
	Table.create("ctcs");
	IJ.renameResults("Results");
	Table.setColumn("[Label]", imageLabel);
	Table.setColumn("Cells ID", cellIds);
	Table.setColumn("thCD45", thCD45Array);
	Table.setColumn("CD45", cd45Results);
	Table.setColumn("thVimentina", thVimArray);
	Table.setColumn("Vimentina", vimResults);
	Table.setColumn("thCitokeratina", thCKArray);
	Table.setColumn("Citokeratina", ckResults);
	Table.setColumn("CTC Phenotype", ctcPhenotypeResults);
	Table.update;
	saveAs("Results", output + File.separator + "QuantificationResults_IF_CTCsPhenotype.xls");
	setBatchMode("exit and display");
	
	
	// DRAW (Visualization)
	print("--- Step 6: Drawing marker visualization on output image...");
	selectWindow(MyTitle);
	Property.set("CompositeProjection", "null");
	Stack.setDisplayMode("color");
	selectWindow(nameMarker1);
	run("Create Selection");
	selectWindow(MyTitle);
	Stack.setChannel(cMarker1);
	run("Restore Selection");
	Overlay.addSelection("Red", 0);
	Overlay.setPosition(cMarker1, 1, 1);
	
	selectWindow(nameMarker2);
	run("Create Selection");
	selectWindow(MyTitle);
	Stack.setChannel(cMarker2);
	run("Restore Selection");
	Overlay.addSelection("Orange", 0);
	Overlay.setPosition(cMarker2, 1, 1);
	
	selectWindow(nameMarker3);
	run("Create Selection");
	selectWindow(MyTitle);
	Stack.setChannel(cMarker3);
	run("Restore Selection");
	Overlay.addSelection("Green", 0);
	Overlay.setPosition(cMarker3, 1, 1);
	
	selectWindow(MyTitle);
	Stack.setChannel(cDAPI);
	roiManager("Show All with labels");
	run("In [+]");run("In [+]");run("In [+]");
	roiManager("Show All with labels");
	roiManager("Set Color", "blue");
	roiManager("Set Line Width", 0);
	run("From ROI Manager");
	Overlay.setPosition(cDAPI, 1, 1);
	saveAs("Tiff", OutDir+File.separator+MyTitle+".tif");
	rename(MyTitle);
	
	run("Collect Garbage");
	setBatchMode("exit and display");
	roiManager("Show None");
	roiManager("Show None");
	close("\\Others");
	print("--- Done generating visualization!");
	
	/*
	// load the DAPI ZIP 
	roiManager("Reset");
	roiManager("Open", OutDir+File.separator+MyTitle+"_roisDAPI.zip");
	*/
	
	roiManager("Show All with labels");

	//create a new folder for the single cell images
	OutDirSingleCells = OutDir+File.separator+"SingleCells";
	File.makeDirectory(OutDirSingleCells);

	//create subfolder dapi and marker for each channel
	File.makeDirectory(OutDirSingleCells+File.separator+"DAPI");
	File.makeDirectory(OutDirSingleCells+File.separator+nameMarker1);
	File.makeDirectory(OutDirSingleCells+File.separator+nameMarker2);
	File.makeDirectory(OutDirSingleCells+File.separator+nameMarker3);
	File.makeDirectory(OutDirSingleCells+File.separator+"Multichannel");

	//Save whole image channel
	selectWindow(MyTitle);
	run("Duplicate...", "title=DAPI duplicate channels="+cDAPI);
	saveAs("Tiff", OutDirSingleCells+File.separator+"DAPI"+File.separator+MyTitle+"_DAPI.tif");
	selectWindow(MyTitle);
	run("Duplicate...", "title=Marker1 duplicate channels="+cMarker1);
	saveAs("Tiff", OutDirSingleCells+File.separator+nameMarker1+File.separator+MyTitle+"_"+nameMarker1+".tif");
	selectWindow(MyTitle);
	run("Duplicate...", "title=Marker2 duplicate channels="+cMarker2);
	saveAs("Tiff", OutDirSingleCells+File.separator+nameMarker2+File.separator+MyTitle+"_"+nameMarker2+".tif");
	selectWindow(MyTitle);
	run("Duplicate...", "title=Marker3 duplicate channels="+cMarker3);
	saveAs("Tiff", OutDirSingleCells+File.separator+nameMarker3+File.separator+MyTitle+"_"+nameMarker3+".tif");
	close(MyTitle+"_DAPI.tif");
	close(MyTitle+"_"+nameMarker1+".tif");
	close(MyTitle+"_"+nameMarker2+".tif");
	close(MyTitle+"_"+nameMarker3+".tif");	
	
	if (checkbox){
		// Loop through each ROI (cell) and save a cropped image for each marker
		nCells = roiManager("Count");
		setBatchMode(true);
		for (i = 0; i < nCells; i++) {
			selectWindow(MyTitle);
			run("Select None");
			selectWindow(MyTitle);
			roiManager("select", i);
			cellId = "Cell"+(i+1);
			// Save DAPI channel crop
			selectWindow(MyTitle);
			Stack.setChannel(cDAPI);
			//duplicate the image, just the channel of interest, crop just the area of the cell and save it in the corresponding folder
			run("Duplicate...", "title=DAPI duplicate channels="+cDAPI);
			saveAs("Tiff", OutDirSingleCells+File.separator+"DAPI"+File.separator+MyTitle+"_"+cellId+"_DAPI.tif");
			// Save Marker 1 channel crop
			selectWindow(MyTitle);
			Stack.setChannel(cMarker1);
			//duplicate the image, just the channel of interest, crop just the area of the cell and save it in the corresponding folder
			run("Duplicate...", "title=Marker1 duplicate channels="+cMarker1);
			saveAs("Tiff", OutDirSingleCells+File.separator+nameMarker1+File.separator+MyTitle+"_"+cellId+"_"+nameMarker1+".tif");
			// Save Marker 2 channel crop
			selectWindow(MyTitle);
			Stack.setChannel(cMarker2);
			//duplicate the image, just the channel of interest, crop just the area of the cell and save it in the corresponding folder
			run("Duplicate...", "title=Marker2 duplicate channels="+cMarker2);
			saveAs("Tiff", OutDirSingleCells+File.separator+nameMarker2+File.separator+MyTitle+"_"+cellId+"_"+nameMarker2+".tif");
			// Save Marker 3 channel crop
			selectWindow(MyTitle);
			Stack.setChannel(cMarker3);
			//duplicate the image, just the channel of interest, crop just the area of the cell and save it in the corresponding folder
			run("Duplicate...", "title=Marker3 duplicate channels="+cMarker3);
			saveAs("Tiff", OutDirSingleCells+File.separator+nameMarker3+File.separator+MyTitle+"_"+cellId+"_"+nameMarker3+".tif");
			// close the cropped images
			close(MyTitle+"_"+cellId+"_DAPI.tif");
			close(MyTitle+"_"+cellId+"_"+nameMarker1+".tif");
			close(MyTitle+"_"+cellId+"_"+nameMarker2+".tif");
			close(MyTitle+"_"+cellId+"_"+nameMarker3+".tif");
	
	
			selectWindow(MyTitle);
			roiManager("select", i);
			cellId = "Cell"+(i+1);
			// Save Multichannel crop
			selectWindow(MyTitle);
			getDimensions(width, height, channels, slices, frames);
			run("Duplicate...", "title=Multichannel duplicate channels=1-"+channels);
			saveAs("Tiff", OutDirSingleCells+File.separator+"Multichannel"+File.separator+MyTitle+"_"+cellId+"_Multichannel.tif");
			// close the cropped images
			close(MyTitle+"_"+cellId+"_Multichannel.tif");
		}
	}
	
	roiManager("reset");
	close("\\Others");

    
}


function openFileFormat(file){
	/**
	 * Utility function to correctly open different image formats via standard ImageJ
	 * protocols or through Bio-Formats depending on the file extension.
	 * * @param {string} file - The file path to evaluate and open.
	 */
		
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

function segmentMarker(markerWindow,auto,thMarker){
		
		print("---  Segmenting Marker (" + markerWindow + ") channel...");
		selectWindow(markerWindow);
		run("Subtract Background...", "rolling=200");
		run("Median...", "radius=1");
	
		if(auto == "Automatic"){
			setAutoThreshold("Otsu dark stack");
			getThreshold(thMarker, upper);
			print("Auto-threshold for "+markerWindow+" is: "+thMarker);
		}else if (auto == "Manual"){
			run("Threshold...");
			setThreshold(thMarker, 255);
			selectWindow("Threshold");
			waitForUser("Select Threshold");}
		else if (auto == "BatchMode"){
			setThreshold(thMarker,255);
			}
		setOption("BlackBackground", false);
		run("Convert to Mask");

		return thMarker;
}

function cellClassPhenotype(markerWindowName, thPer) {
	    run("Clear Results");
	    nCells = roiManager("Count");
	    
	    if (nCells > 0){
	    selectWindow(markerWindowName);
	    roiManager("show none");
	    roiManager("Deselect");
	    roiManager("Measure");
	    
	    for (i = 0; i < nCells; i++) {
	        v = getResult("%Area", i);
	        if (v > thPer) {
	            setResult("Status", i, "+"); 
	        } else {
	            setResult("Status", i, "-"); 
	        }
	    }
	    updateResults();
	    markerResults = Table.getColumn("Status");
	    return markerResults;
	    }else{
	    	print("No Cells Detected");
	    }
	}
	