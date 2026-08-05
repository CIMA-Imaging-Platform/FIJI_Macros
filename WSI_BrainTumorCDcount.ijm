// ============================================================
// MACRO INFO
// ============================================================

function macroInfo(){

// * Quantification of Brown WSI Images Area
// * Target User: General

	scripttitle= "Quantification of DAB(+) Cells on WSImages ";
	version= "1.03";
	date= "2026";

// *  Tests Images:

	imageAdquisition="Aperio: BrightField Whole Slide Imaging Images.";
	imageType="RGB";
	voxelSize="Voxel size:  0.502 um xy";
	format="Format: Uncompressed .jpg";

	//*  GUI User Requierments:
	//*    - Choose parameters.
	//*    - Single File and Batch Mode
	//*
	// Important Parameters: click Im or Dir + right button.
	parameter1="Resolution (micra pixel ratio) = 0.502 micras/pixel xy";
	parameter2="Estimated Cell diameter (microns)";
	parameter3="Tumor Threshold (8bit) = Separate Tumor from Background";
	parameter4="Threshold for nuclei segmentation in HE (8bit)";
	parameter5="Threshold for TumorCDcount+ segmentation (8bit) = Separate TumorCDcount(+) from CD(-)";
	parameter6="Min Nucleus size (pixels)";
	parameter7="Max Nucleus size (pixels)";
	parameter8="Min percentage of TumorCDcount+(area within the cell) for positive cells (%)";

	//  2 Action tools:
	buttom1="Im: Single File processing. Use Single file processing for fine tunning parameters";
	buttom2="Dir: Batch Mode. Please tune parameters before using Batchmode";

	//  OUTPUT
	// Analyzed Images with ROIs
	excel="Quantification_TumorCDcountcount.xls";
	feature1="Image Label";
	feature2="# total cells";
	feature3="# TumorCDcount+ cells";
	feature4="Area of Tumor (um2)"

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
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li>"
	    +"<li>"+parameter3+"</li>"
	    +"<li>"+parameter4+"</li>"
	    +"<li>"+parameter5+"</li>"
	    +"<li>"+parameter6+"</li>"
	    +"<li>"+parameter7+"</li>"
	    +"<li>"+parameter8+"</li></ul>"
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

var r=0.502, cellRadiusPx=8, thTissue = 235 , thTumor=30, thBlue=150, thBrown=115, minSize=10, maxSize=10000, minBrownPerc=50;		// Escáner 20x


// ============================================================
// HELPER FUNCTIONS
// ============================================================

function isImageOpen() {
	/**
	 * Checks if an image with the specified name is currently open in ImageJ.
	 */

	// Get the list of open image windows
	openImages = getList("image.titles");
	// if empty, no images are open
	if (lengthOf(openImages) == 0) {
		return false; // No images are open
	} else {
		return true; // Return true if the image is open, false otherwise
	}
}


function showParamsDialog() {
	/**
	 * Shows the shared parameter dialog for both action tools.
	 * Reads values directly into global vars.
	 */

	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Choose parameters");
	Dialog.addNumber("Ratio micra/pixel", r);
	Dialog.addNumber("Cell diameter (microns)", cellRadiusPx);
	Dialog.addNumber("Threshold for Tumor segmentation", thTumor);
	Dialog.addNumber("Threshold for nuclei segmentation in HE", thBlue);
	Dialog.addNumber("Threshold for TumorCDcount+ segmentation", thBrown);
	Dialog.addNumber("Min nucleus size", minSize);
	Dialog.addNumber("Max nucleus size", maxSize);
	Dialog.addNumber("Min percentage of TumorCDcount+ for positive cells (%)", minBrownPerc);
	Dialog.show();

	r            = Dialog.getNumber();
	cellRadiusPx = Dialog.getNumber();
	thTumor     = Dialog.getNumber();
	thBlue       = Dialog.getNumber();
	thBrown      = Dialog.getNumber();
	minSize      = Dialog.getNumber();
	maxSize      = Dialog.getNumber();
	minBrownPerc = Dialog.getNumber();
}

function correctBackground(image) {
	/**
	 * Adjusts the background intensity of an image based on pixel intensity mode.
	 * Supports global and Tumor-specific correction modes.
	 *
	 * @param {string} image - Name of the image window to correct.
	 * @returns {number} mode - The mode of pixel intensity used for adjustment.
	 *
	 * Modes:
	 * - **Global Correction**: Calculates the mode for the entire image. If mode > 200, adjusts brightness by adding (255 - mode) to all pixels.
	 * - **Tumor-Specific Correction**: Calculates the mode within a selected ROI. Adjustment logic for this mode is incomplete.
	 *
	 * Requirements:
	 * - For Tumor-specific correction, an ROI must be present in the ROI Manager.
	 *
	 * Note: Global correction is enabled by default.
	 */

	// Set to true for global background correction; false for Tumor-specific correction.
	globalMode = true;

	if (globalMode) {
		// --- GLOBAL BACKGROUND CORRECTION ---
		// Measure the modal intensity of the whole image and shift brightness so background approaches 255 (white)
		run("Clear Results");
		run("Set Measurements...", "area mean modal redirect=None decimal=2");
		run("Select All");

		// Get the mode of pixel intensity
		mode = getValue("Mode");
		print("  [Background] Modal intensity of '" + image + "': " + mode);


		// Adjust brightness if mode exceeds threshold
		dif = 255 - mode;
		selectWindow(image);
		run("Add...", "value=" + dif);
		print("  [Background] Brightness corrected by +" + dif + " (255 - mode)");
		// Clear measurement results
		run("Clear Results");
	} else {
		// --- TUMOR-SPECIFIC BACKGROUND CORRECTION ---
		// Corrects background using the modal intensity within a pre-loaded ROI
		run("Clear Results");
		run("Set Measurements...", "area mean modal redirect=None decimal=2");

		// Assume ROI is preloaded in the ROI Manager
		selectWindow("a");
		roiManager("select", 0);
		run("Measure");

		// Get the mode of pixel intensity within the ROI
		mode = getResult("Mode", 0);
		selectWindow(image);
		dif = 255 - mode;
		run("Select None");

		// Clear measurement results
		run("Clear Results");
	}

	return mode; // Return the measured mode
}


function filterTableColum(tableName, columnName, filterType, threshold)
{
	/**
	 * Filters a table column based on a given threshold.
	 *
	 * @param {string} tableName - The name of the table window.
	 * @param {string} columnName - The name of the column to filter.
	 * @param {string} filterType - The type of filtering ("<" for values less than, ">" for values greater than).
	 * @param {number} threshold - The threshold value for filtering.
	 * @return {array} positiveRois - An array containing the indices of rows that meet the filtering criteria.
	 */

	 //TEST PARAMETERS
	 /*
	 tableName="Results";
	 columnName="Mean";
	 filterType=">";
	 threshold=0;*/

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
	for (i = 0; i < lengthOf(column); i++) {
		// Get the value at the current position
		value = column[i];

		// Check if the filter type is "<"
		if (filterType == "<") {
			// If the value is greater than the threshold, delete rows below the current position
			if (value > threshold) {
				selectWindow(tableName);
				Table.deleteRows(i, lengthOf(column) - 1);
				break;
			}
		} else if (filterType == ">") {
			// If the value is greater than the threshold, delete rows above the current position
			if (value > threshold) {
				selectWindow(tableName);
				Table.deleteRows(0, i - 1);
				break;
			}
		}
	}

	// Get the updated indices of rows that meet the filtering criteria
	positiveRois = Table.getColumn("Index");

	// Return the array of positive indices
	return positiveRois;
}


// ============================================================
// ACTION TOOLS
// ============================================================

macro "TumorCDcountcount Action Tool 1 - Cf00T2d15IT6d10m"{

	macroInfo();

	// --- SINGLE IMAGE MODE ---
	// if is open do nothing, if not open ask for file
	print("========================================");
	print("  WSI_BrainTumorCDcount  |  Single Image Mode");
	print("========================================");

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

	showParamsDialog();
	print("Parameters confirmed by user.");
	print("  r=" + r + "  cellRadiusPx=" + cellRadiusPx + "  thTumor=" + thTumor);
	print("  thBlue=" + thBlue + "  thBrown=" + thBrown + "  minSize=" + minSize + "  maxSize=" + maxSize + "  minBrownPerc=" + minBrownPerc + "%");

	TumorCDcount("-","-",name,r,cellRadiusPx,thTumor,thBlue,thBrown,minSize,maxSize,minBrownPerc);
	showMessage("TumorCDcount quantified!");

}


macro "TumorCDcountcount Action Tool 2 - C00fT0b11DT9b09iTcb09r"{

	macroInfo();

	// --- BATCH MODE ---
	// Iterates over all .tif files in the selected directory
	print("========================================");
	print("  WSI_BrainTumorCDcount  |  Batch Mode");
	print("========================================");

	InDir=getDirectory("Choose images directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	showParamsDialog();
	print("Parameters confirmed by user.");
	print("  r=" + r + "  cellRadiusPx=" + cellRadiusPx + "  thTumor=" + thTumor);
	print("  thBlue=" + thBlue + "  thBrown=" + thBrown + "  minSize=" + minSize + "  maxSize=" + maxSize + "  minBrownPerc=" + minBrownPerc + "%");
	print("Directory: " + InDir);
	print("Files found in directory: " + L);

	// Count eligible .tif files before starting
	tifCount = 0;
	for (j=0; j<L; j++) { if(endsWith(list[j],".tif")) tifCount++; }
	print(".tif files to process: " + tifCount);

	fileIdx = 0;
	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],".tif")){
			fileIdx++;
			name=list[j];
			print("--- Batch file " + fileIdx + " of " + tifCount + ": " + name + " ---");
			print("Processing "+name);
			TumorCDcount(InDir,InDir,list[j],r,cellRadiusPx,thTumor,thBlue,thBrown,minSize,maxSize,minBrownPerc);
			}
	}

	print("========================================");
	print("  Batch processing complete. " + tifCount + " images analysed.");
	print("========================================");
	showMessage("TumorCDcount quantified!");

}


// ============================================================
// CORE ANALYSIS
// ============================================================

function TumorCDcount(output,InDir,name,r,cellRadiusPx,thTumor,thBlue,thBrown,minSize,maxSize,minBrownPerc)
{

	// --------------------------------------------------------
	// SECTION 1 — INITIALIZATION
	// Open the image (if not already open), reset workspaces,
	// and set up the output directory.
	// --------------------------------------------------------

	print("[1/8] Initialization...");

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
	print("Output directory: " + OutDir);

	setBatchMode(true);
	run("Colors...", "foreground=white background=black selection=green");

	// Duplicate original for final RGB overlay before any processing alters it
	run("Duplicate...", "title=orig duplicate");
	run("RGB Color");
	close("orig");
	rename("orig");
	print("Original RGB copy saved for final overlay.");

	//get spatial Resolution
	getVoxelSize(unit, width, height, depth);
	if (width != r){
		print("       WARNING: Spatial calibration in metadata (" + width + " um/px) does not match default value (" + r + " um/px). Using metadata value.");
	} else if(width == 1 && height == 1){
		print("       No spatial calibration found in metadata, using default: 1 px = " + r + " um");
		r = width;
		print("       Spatial calibration found in metadata: 1 px = " + r + " um");
	}
	run("Set Scale...", "distance=1 known="+r+" unit=micron");   // spatial calibration: 1 px = r µm
	print("       Scale: 1 px = " + r + " um  |  Output folder: " + OutDir);

	

	// --------------------------------------------------------
	// SECTION 2 — COLOUR BALANCE AND TISSUE SEGMENTATION
	// Correct per-channel background, then threshold the
	// luminance image to isolate tissue from white background.
	// --------------------------------------------------------

	print("[2/8] Colour balance and tissue/background segmentation...");

	// -- COLOR BALANCE AND CONTRAST ENHANCEMENT --
	
	selectWindow(MyTitle);
	run("Select All");

	showStatus("Detecting tumor...");
	// check number of channels, if more than 1 convert to luminance
	getDimensions(width, height, channels, slices, frames);
	print("Image dimensions: " + width + " x " + height + " | Channels: " + channels);
	if (channels > 1) {
		print("  Multi-channel image detected. Splitting channels for individual background correction...");
		selectWindow(MyTitle);
		run("Split Channels");
		//apply correctBackground to each channel
		for (c=1; c<=channels; c++) {
			print("  Correcting background for channel C" + c + "...");
			selectWindow("C"+c+"-"+	MyTitle);
			modeBckg=correctBackground("C"+c+"-"+MyTitle);
			resetMinAndMax;
			run("Enhance Contrast", "saturated=0.01");
			run("Apply LUT");
		}
		//merge channels again
		print("  Merging corrected channels back into RGB...");
		run("Merge Channels...", "c1=[C1-"+MyTitle+"] c2=[C2-"+MyTitle+"] c3=[C3-"+MyTitle+"] create");
		run("RGB Color");
		// close result image and rename new one as original
		selectWindow(MyTitle+" (RGB)");
		close(MyTitle);
		rename(MyTitle);
	}

	rename("rgb");
	
	
	// -- SEGMENT BACKGROUND --
	// Convert RGB to luminance; threshold to separate tissue (dark) from white slide background
	selectWindow("rgb");
	// RGB TO LUMINANCE
	run("RGB to Luminance");
	// Thresholding to background segmentation
	run("Median...", "radius=2");
	run("Select All");
	modeBckg = getValue("Mode");
	setThreshold(0, thTissue);
	print("  Tissue threshold applied: 0 – " + thTissue + " (background mode: " + modeBckg + ")");

	//setThreshold(0, 235);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	rename("backgroundMask");
	run("Median...", "radius=4");
	run("Invert");
	run("Analyze Particles...", "size=500-Infinity pixel show=Masks in_situ");
	run("Duplicate...", "title=tissue");
	run("Invert");
	run("Analyze Particles...", "size=5000-Infinity pixel show=Masks in_situ");
	print("  Tissue mask created (holes <500 px filled; islands <5000 px removed).");

	

	// --------------------------------------------------------
	// SECTION 3 — COLOUR DECONVOLUTION
	// Separate the H&E and DAB (brown) staining components
	// from the RGB image using colour deconvolution.
	// The DAB channel (Colour_3) captures CD-positive staining;
	// the H&E channel (Colour_1) is used for nucleus and tumour detection.
	// --------------------------------------------------------

	print("[3/8] Colour deconvolution (H&E DAB)...");

	// Deconvolution of H&E and DAB channels
	selectWindow("rgb");
	run("Colour Deconvolution", "vectors=[H&E DAB] hide");
	selectWindow("rgb-(Colour_2)");
	close();
	print("  Colour deconvolution complete. Colour_2 (residual) closed.");

	
	// --------------------------------------------------------
	// SECTION 4 — DAB (BROWN) CHANNEL SEGMENTATION
	// Correct background on the DAB channel, subtract rolling
	// background, and threshold to produce a binary brown mask.
	// --------------------------------------------------------

	print("[4/8] DAB (brown staining) segmentation...");

	// --- BROWN SEGMENTATION (DAB CHANNEL) ---
	selectWindow("rgb-(Colour_3)");
	rename("DAB");
	print("  Correcting background on DAB channel...");
	modeDAB=correctBackground("DAB");
	// Correcting background and processing red channel
	selectWindow("DAB");
	showStatus("Correcting background...");
	run("Subtract Background...", "rolling=50 light");
	//thBrown=115;
	setThreshold(0, thBrown);
	print("  DAB threshold applied: 0 – " + thBrown);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Analyze Particles...", "size=50-Infinity pixel show=Masks in_situ");
	print("  DAB binary mask ready (particles <50 px removed).");
	//run("Analyze Particles...", "size="+minSize+"-Infinity show=Masks in_situ");


	
	// --------------------------------------------------------
	// SECTION 5 — TUMOUR REGION SEGMENTATION
	// Use the H&E channel (high nuclear density = tumour) minus
	// the DAB signal to isolate dense tumour areas.
	// An auto-threshold (Huang then Otsu) is applied; the
	// largest connected region becomes the tumour ROI.
	// --------------------------------------------------------

	print("[5/8] Tumour region segmentation...");

	// --- TUMOR SEGMENTATION (HE CHANNEL - DAB CHANNEL) ---
	// High nuclei density areas correspond to tumor; low density to background

	selectWindow("rgb-(Colour_1)");
	rename("HE");
	print("  Correcting background on H&E channel...");
	modeHE=correctBackground("HE");
	// enhance contrast of HE channel for better thresholding

	// Thresholding and segmentation of TUMOR areas
	selectWindow("HE");
	run("Duplicate...", "title=cellDetection");
	selectWindow("HE");
	selectWindow("tissue");
	run("Create Selection");
	selectWindow("HE");
	run("Restore Selection");
	setAutoThreshold("Otsu");
	getThreshold(lower, upper);
	print("  otsu auto-threshold on H&E: lower=" + lower + "  upper=" + upper);
	
	//if(upper<170){
	//	upper = 150;
	//	print("  Upper threshold too low (<170); clamped to 180.");
	//	setThreshold(lower, upper);
	//}else{
	//	setThreshold(lower, upper+(255-upper)*0.1);
	//	print("  Upper threshold adjusted to " + (upper+(255-upper)*0.1) + " (10% headroom).");
	//}
	//run("Threshold...");
	//setThreshold(0, 162);
	
	setOption("BlackBackground", false);
	run("Convert to Mask");
	imageCalculator("Subtract create", "HE","DAB");
	run("Analyze Particles...", "size=100-Infinity pixel show=Masks in_situ");
	run("Median...", "radius=4");
	run("Mean...", "radius=35");
	run("Fire");
	// Restrict density map histogram to tissue only before thresholding.
	// This removes background pixels from the histogram, collapsing the
	// 3-class problem (background / healthy / tumour) into 2 classes
	// (healthy vs. tumour density) so that IsoData reliably finds the split.
	/*selectWindow("tissue");
	run("Create Selection");
	selectWindow("Result of HE");
	run("Restore Selection");*/
	//run("Threshold...");
	//thTumor = 50;
	//setThreshold(thTumor,255);
	//setAutoThreshold("Otsu dark");
	//getThreshold(thTumor, upper);

	setBatchMode("exit and display");
	waitForUser;	
	setBatchMode(true);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Analyze Particles...", "size=10000-Infinity pixel show=Masks in_situ");
	run("Invert");
	run("Analyze Particles...", "size=10000-Infinity pixel show=Masks in_situ");
	run("Invert");
	run("Morphological Filters", "operation=Dilation element=Disk radius=30");
	run("Keep Largest Region");
	imageCalculator("Subtract create", "Result-Dilation-largest","backgroundMask");
	rename("tumorMask");
	run("Create Selection");
	// if no selection, finish macro — no tumor detected
	type=selectionType();
	if(type==-1) {
		print("  WARNING: No tumour region detected in this image. Stopping analysis.");
		break;
	}else {
		run("Add to Manager");	// ROI0 --> tumor Tumor
		print("  Tumour ROI added to ROI Manager (ROI 0).");
	}
	close("*HE*");
	close("*largest*");
	close("*Dilation*");

	// Measure Tumor area
	selectWindow("rgb");
	run("Set Scale...", "distance=1 known="+r+" unit=micron");
	run("Select None");
	roiManager("Select", 0);
	roiManager("Measure");
	tumorArea=getResult("Area",0);
	run("Clear Results");
	print("  Tumour area measured: " + tumorArea + " µm²");

	// --------------------------------------------------------
	// SECTION 6 — RESTRICT DAB MASK TO TUMOUR ROI
	// Clear DAB signal outside the tumour boundary so that
	// positivity classification is confined to tumour cells only.
	// --------------------------------------------------------

	print("[6/8] Restricting DAB mask to tumour ROI...");

	// --- BROWN STAINING DETECTION (DAB CHANNEL) ---

	// Restrict brown mask to Tumor ROI
	selectWindow("DAB");
	roiManager("Select", 0);
	setBackgroundColor(255, 255, 255);
	run("Clear Outside");
	run("Select All");
	print("  DAB mask cleared outside tumour boundary.");

	// --------------------------------------------------------
	// SECTION 7 — CELL SEGMENTATION (NUCLEI DETECTION + WATERSHED)
	// Detect individual cell nuclei within the tumour using the
	// H&E-derived cellDetection image.  A marker-controlled
	// watershed separates touching nuclei into individual cells.
	// --------------------------------------------------------

	print("[7/8] Cell segmentation (nuclei detection + watershed)...");

	// --- CELL SEGMENTATION (HE CHANNEL) ---
	selectWindow("cellDetection");

	run("Enhance Contrast", "saturated=0.35");
	run("Apply LUT");
	run("Subtract Background...", "rolling=50 light");
	selectWindow("cellDetection");
	run("Median...", "radius=2");
	run("Duplicate...", "title=cellMaxima");
	selectWindow("tumorMask");
	run("Create Selection");
	selectWindow("cellDetection");
	run("Restore Selection");
	//thBlue = 135;
	setAutoThreshold("Huang");
	getThreshold(lower, thNucleus);
	print("  Nucleus auto-threshold (Huang): lower=" + lower + "  upper=" + thNucleus);
	//waitForUser("Adjust threshold for cell segmentation and press OK when ready");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	//run("Fill Holes");
	run("Median...", "radius=2");
	run("Watershed");
	print("  Watershed applied to separate touching nuclei.");
	// Restrict nuclei mask to Tumor ROI
	roiManager("Select", 0);
	run("Clear Outside");
	run("Select All");
	run("Analyze Particles...", "size=35-10000 pixel show=Masks in_situ");
	//run("Analyze Particles...", "size="+minSize+"-"+maxSize+" pixel show=Masks in_situ");

	// Reduce each nucleus to a single seed point for marker-controlled watershed
	print("  Finding local maxima as seed points for marker-controlled watershed...");
	selectWindow("cellMaxima");
	run("Gaussian Blur...", "sigma=2");
	run("Find Maxima...", "prominence=5 light output=[Single Points]");
	imageCalculator("AND create", "cellDetection","cellMaxima Maxima");
	close("*Maxima*");
	close("cellDetection");

	selectImage("Result of cellDetection");
	rename("cellMaxima");

	// Expand seed points to approximate cell area, then derive edges as watershed input
	selectWindow("cellMaxima");
	run("Duplicate...", "title=cellMask");
	run("Create Selection");
	//cellRadiusPx = 10;
	run("Enlarge...", "enlarge="+cellRadiusPx);
	setForegroundColor(0, 0, 0);
	run("Fill", "slice");

	selectWindow("cellMask");
	run("Select All");
	run("Duplicate...", "title=cellEdges");
	run("Find Edges");

	// Marker-controlled watershed separates touching cells
	print("  Running marker-controlled watershed...");
	run("Marker-controlled Watershed", "input=cellEdges marker=cellMaxima mask=cellMask binary calculate use");

	selectWindow("cellEdges-watershed");
	run("8-bit");
	setThreshold(1, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Analyze Particles...", "size=0-Infinity show=Masks add in_situ");
	roiManager("show all without labels");
	roiManager("Show None");
	run("Remove Overlay");


	close("cellEdges");
	close("cellMaxima");
	close("cellMask");
	selectWindow("cellEdges-watershed");
	rename("cellMask");

	nCells=roiManager("Count");
	print("  Total cells detected within tumour: " + nCells);

	// --------------------------------------------------------
	// SECTION 8 — TumorCDcount POSITIVITY CLASSIFICATION
	// For each detected cell ROI, measure the fraction of its
	// area covered by DAB (brown) signal.  Cells exceeding
	// minBrownPerc are classified as TumorCDcount-positive.
	// --------------------------------------------------------

	print("[8/8] Classifying TumorCDcount+ positive cells...");
	print("  Minimum brown area fraction for positivity: " + minBrownPerc + "%");

	// --- TumorCDcount POSITIVITY CLASSIFICATION ---

	// Blank canvas to paint only TumorCDcount+ cells
	selectWindow("cellMask");
	run("Duplicate...", "title=positCellMask");
	run("Select All");
	setBackgroundColor(255, 255, 255);
	run("Clear", "slice");
	wait(100);

	// Measure brown area fraction within every cell ROI
	run("Set Measurements...", "area mean standard modal min area_fraction redirect=None decimal=2");
	run("Clear Results");
	selectWindow("DAB");
	run("Select None");
	roiManager("Deselect");
	roiManager("Measure");
	print("  Brown area fraction measured for all " + nCells + " cell ROIs.");

	// Keep only ROIs whose brown area fraction exceeds the threshold
	positiveRois=filterTableColum("Results", "%Area",">", minBrownPerc);

	print("Total Cells: "+nCells);
	print("positive Cells "+lengthOf(positiveRois));
	print("  Positivity rate: " + d2s(lengthOf(positiveRois)*100/nCells, 1) + "%");
	roiManager("select", positiveRois);
	roiManager("save selected", OutDir+File.separator+MyTitle+"_roisTumorCDcount.zip");
	roiManager("Reset");
	roiManager("Open", OutDir+File.separator+MyTitle+"_roisTumorCDcount.zip");
	selectWindow("positCellMask");
	run("Colors...", "foreground=black background=white selection=green");
	roiManager("Fill");
	nTumorCDcount=roiManager("Count");
	run("Select None");
	print("  Positive cell ROIs saved: " + OutDir + File.separator + MyTitle + "_roisTumorCDcount.zip");

	close("DAB");

	// --------------------------------------------------------
	// RESULTS OUTPUT
	// Append measurements to the shared XLS results table
	// (creates it if it does not yet exist).
	// --------------------------------------------------------

	print("[Results] Saving quantification results...");

	run("Clear Results");
	if(File.exists(output+File.separator+"Quantification_TumorCDcountcount.xls"))
	{
		//if exists add and modify
		print("  Existing results file found. Appending new row...");
		open(output+File.separator+"Quantification_TumorCDcountcount.xls");
		IJ.renameResults("Results");
	} else {
		print("  No existing results file. A new one will be created.");
	}
	i=nResults;
	setResult("[Label]", i, MyTitle);
	setResult("thTissue", i, thTissue);
	setResult("thTumor", i, thTumor);
	setResult("thNucleus", i, thNucleus);
	setResult("thDAB", i, thBrown);
	setResult("minSize", i, minSize);
	setResult("# total cells", i, nCells);
	setResult("# TumorCDcount+ cells", i, nTumorCDcount);
	setResult("Area of Tumor (um2)", i, tumorArea);
	saveAs("Results", output+File.separator+"Quantification_TumorCDcountcount.xls");
	print("  Results saved to: " + output + File.separator + "Quantification_TumorCDcountcount.xls");

	// --------------------------------------------------------
	// VISUALIZATION
	// Overlay cell outlines (red = all cells, green = CD+,
	// yellow = tumour boundary) on the original RGB image
	// and save as JPEG.
	// --------------------------------------------------------

	print("[Visualization] Generating annotated overlay image...");

	setBatchMode("exit and display");

	selectWindow("orig");

	// Draw all cells in red
	print("  Drawing all cell outlines in red...");
	selectWindow("cellMask");
	run("Select None");
	run("Create Selection");
	selectWindow("orig");
	run("Restore Selection");
	roiManager("Set Color", "red");
	roiManager("Set Line Width", 1);
	run("Flatten");
	wait(100);
	close("orig");

	// Draw TumorCDcount+ cells in green
	if(nTumorCDcount!=0) {
		print("  Drawing TumorCDcount+ cell outlines in green (" + nTumorCDcount + " cells)...");
		selectWindow("positCellMask");
		run("Select None");
		//run("Find Maxima...", "noise=10 output=[Point Selection] light");
		//setTool("multipoint");
		//run("Point Tool...", "type=Hybrid  color=Green size=Tiny counter=0");
		run("Create Selection");
		selectWindow("orig-1");
		run("Restore Selection");
		roiManager("Set Color", "green");
		roiManager("Set Line Width", 1);
	}
	run("Flatten");
	close("orig-1");
	wait(200);

	// Draw tumour boundary in yellow
	print("  Drawing tumour boundary in yellow...");
	selectWindow("tumorMask");
	run("Create Selection");
	selectWindow("orig-2");
	run("Restore Selection");
	roiManager("Set Color", "yellow");
	roiManager("Set Line Width", 1);
	run("Flatten");
	saveAs("Jpeg", OutDir+File.separator+MyTitle+"_analyzed.jpg");
	rename(MyTitle+"_analyzed.jpg");
	print("  Annotated image saved: " + OutDir + File.separator + MyTitle + "_analyzed.jpg");
	close("\\Others");
	if (InDir!="-") {
		close();
	}

	print("\\n--- Analysis complete: " + MyTitle + " ---");
	print("  Total cells:    " + nCells);
	print("  CD+ cells:      " + nTumorCDcount);
	print("  Tumour area:    " + tumorArea + " µm²");
	print("----------------------------------------");

	//showMessage("Done!");

}
