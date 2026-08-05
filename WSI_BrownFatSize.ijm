
function macroInfo(){

// * Quantification of BrownFatSize Identification on WSI Images
// * Target User: General
// *

	scripttitle= "Quantification of BrownFatSize on WSI Images";
	version= "1.02";
	date= "2026";


// *  Tests Images:

	imageAdquisition="Aperio: BrightField Whole Slide Imaging Images.";
	imageType="RGB";
	voxelSize="Voxel size:  0.252 um xy";
	format="Format: Uncompressed .jpg";

 //*  GUI User Requierments:
 //*    - None
 //* Important Parameters:
	// Parameters:

	parameter1="r= Micra per pixel ratio for image analysis. Default: 0.252 um/px (Aperio 20x).";
	parameter2="thTissue= Threshold for tissue detection [0-255]. Pixels darker than this value are considered tissue.";
	parameter3="thFat= Threshold for fat-deposit detection [0-255]. Pixels brighter than this value are considered fat vacuoles.";
	parameter4="fatCircularity= Minimum circularity of fat deposits [0-1]. 1 = perfect circle. Recommended: 0.5.";
	parameter5="minFatDiameter= Minimum diameter (um) of fat deposits to include in analysis.";
	parameter6="maxFatDiameter= Maximum diameter (um) of fat deposits to include in analysis.";

 //  2 Action tools:

	 buttom1="Im: Single File processing. Use Single file processing for fine tunning parameters";
	 buttom2="Dir: Batch Mode. Please tune parameters before using Batchmode";

//  OUTPUT

// Analyzed Images with ROIs

	excel="QuantificationResults_BrownFatSize.xls";
	feature1="Label";
	feature2="Tissue area (um2)";
	feature3="BrownFatSize area (um2)";
	feature4="Ratio ABrownFatSize/Atissue (%)";

/*
 *  version: 1.02
 *  Author: Tomas Muñoz 2026
 *
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
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.

	showMessage("ImageJ Script", "<html>"
    + "<head>"
    + "<style>"
    + "h1, h2, h3, h4, h5, h6 {margin-top: 5px; margin-bottom: 5px;}"
    + "p {margin: 0px; padding: 0px;}"
    + "ol, ul {margin-left: 20px; padding: 5px;}"
    + "#list-style-3 {list-style-type: circle;}"
    + ".container {max-width: 1200px; max-width: 2000px; margin: 0 auto; padding: 0px;}"
    + ".text-column {float: left; width: 1200px; padding-right: 20px;}"
    + ".image-column img {width: 100%; height: 100%;}"
    + "</style>"
    + "</head>"
    + "<body>"
    + "<div class='container'>"
    + "<div class='text-column'>"
    + "<h1 style='color: teal;'>CIMA: Imaging Platform</h1>"
    + "<h2 style='color: purple;'><i>Software Development Service</i></h2>"
    + "<p><i>ImageJ Macros</i></p>"
    + "<h3>" + scripttitle + "</h3>"
    + "<p>Modified by Tomas Muñoz Santoro</p>"
    + "<p>Version: " + version + " (" + date + ")</p>"
    + "<p>Contact: tmsantoro@unav.es</p>"
    + "<p>Available under the <a href='https://opensource.org/licenses/MIT/'>MIT License</a></p>"
    + "<p><i>Video Tutorial:</i> <a href='https://drive.google.com/file/d/1EpzzgVGnLe994FX7YAjl9HfV11qwSyI_/view?usp=sharing' target='_blank'>Watch the video tutorial</a></p>"
    + "<h3>Developed for</h3>"
    + "<p><i>INPUT IMAGES</i></p>"
    + "<ul>"
    + "<li>" + imageAdquisition + "</li>"
    + "<li>" + imageType + "</li>"
    + "<li>" + voxelSize + "</li>"
    + "<li>" + format + "</li>"	
    + "</ul>"
    + "<p><i>ACTION TOOLS (Buttons)</i></p>"
    + "<ol>"
    + "<li>" + buttom1 + "</li>"
    + "<li>" + buttom2 + "</li>"
    + "</ol>"
    + "<p><i>PARAMETERS:</i></p>"
    + "<ul>"
    + "<li>" + parameter1 + "</li>"
    + "<li>" + parameter2 + "</li>"
    + "<li>" + parameter3 + "</li>"
    + "<li>" + parameter4 + "</li>"
    + "<li>" + parameter5 + "</li>"
    + "<li>" + parameter6 + "</li>"
    + "</ul>"
    + "<p><i>QUANTIFICATION RESULTS</i></p>"
    + "<p>Analyzed Images folder: Visualize Segmented Images</p>"
    + "<p>Excel " + excel + "</p>"
    + "<ul>"
    + "<li>" + feature1 + "</li>"
    + "<li>" + feature2 + "</li>"
    + "<li>" + feature3 + "</li>"
    + "<li>" + feature4 + "</li>"
    + "</ul>"
    + "</div>"
    + "</div>"
    + "</body>"
    + "</html>");
   // + "<div class='image-column'><img src='file:"+globalPathToImages+"resultsTemplates//WSI_BrownFatSize/WSI_BrownFatSize_imTemplate.jpg'></div>"
}

// ============================================================
// GLOBAL DEFAULT PARAMETERS
// Default values used by both single-file and batch modes.
// These are overridden by the user via the parameters dialog.
// ============================================================
// changelog September 2022

var r = 0.252, thTissue = 240, thFat = 235,  minFatDiameter = 0.01, maxFatDiameter = 20, fatCircularity = 0.5,  textureFeature=1.3; // Scanner 20x


// ============================================================
// ACTION TOOL 1: SINGLE FILE MODE
// Opens one image (or uses the currently open image), prompts
// for analysis parameters, and runs BrownFatSize analysis.
// ============================================================
macro "BrownFatSize Action Tool 1 - Cf00T2d15IT6d10m" {

	macroInfo();

	print("========================================");
	print("=== BrownFatSize - Single Image Mode ===");
	print("========================================");

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

	// Create a dialog box for parameter input
	Dialog.create("Parameters");

	// Add message to instruct the user
	Dialog.addMessage("Choose parameters")

	// Add input fields for parameter values
	Dialog.addNumber("micra/px ratio", r); // micrometers per pixel ratio
	Dialog.addNumber("Threshold for tissue detection", thTissue); // threshold for tissue detection
	Dialog.addNumber("Threshold for fat-deposit detection", thFat); // threshold for fat-deposit detection
	Dialog.addNumber("Fat-deposit Circularity", fatCircularity); // minimum Roundness of fat deposits
	Dialog.addNumber("Min fat-deposit Diameter (um)", minFatDiameter); // minimum size of fat deposits
	Dialog.addNumber("Max fat-deposit Diameter (um)", maxFatDiameter); // maximum size of fat deposits
	
	// Display the dialog box
	Dialog.show();

	// Retrieve parameter values from the dialog box
	r = Dialog.getNumber();
	thTissue = Dialog.getNumber();
	thFat = Dialog.getNumber();
	fatCircularity = Dialog.getNumber();
	minFatDiameter = Dialog.getNumber();
	maxFatDiameter = Dialog.getNumber();
	//textureFeature = Dialog.getNumber();
	//fatRoundness = Dialog.getNumber();

	// Log confirmed parameters for traceability
	print("Parameters confirmed:");
	print("  micra/px ratio:          " + r);
	print("  Tissue threshold:        " + thTissue);
	print("  Fat threshold:           " + thFat);
	print("  Fat circularity (min):   " + fatCircularity);
	print("  Min fat diameter (um):   " + minFatDiameter);
	print("  Max fat diameter (um):   " + maxFatDiameter);
	//print("  Texture feature limit:   " + textureFeature);
	

	print("--- Starting BrownFatSize analysis ---");

    // Perform BrownFatSize analysis
    BrownFatSize("-", "-", name,r, thTissue, thFat,minFatDiameter, maxFatDiameter, fatCircularity,textureFeature);
    setBatchMode(false);
    showMessage("Done!");
}

// ============================================================
// ACTION TOOL 2: BATCH MODE
// Scans a user-selected directory for .jpg/.tif images and
// runs BrownFatSize analysis on each file using shared parameters.
// ============================================================
macro "BrownFatSize Action Tool 2 - C00fT0b11DT9b09iTcb09r" {

    macroInfo();

	print("========================================");
	print("=== BrownFatSize - Batch Mode ===");
	print("========================================");

    // Prompt user to select a directory
    InDir = getDirectory("Choose a Directory");
    list = getFileList(InDir);
    L = lengthOf(list);

    print("Input directory: " + InDir);
    print("Total files found in directory: " + L);

    	// Create a dialog box for parameter input
	Dialog.create("Parameters");

	// Add message to instruct the user
	Dialog.addMessage("Choose parameters")

	// Add input fields for parameter values
	Dialog.addNumber("micra/px ratio", r); // micrometers per pixel ratio
	Dialog.addNumber("Threshold for tissue detection", thTissue); // threshold for tissue detection
	Dialog.addNumber("Threshold for fat-deposit detection", thFat); // threshold for fat-deposit detection
	Dialog.addNumber("Fat-deposit Circularity", fatCircularity); // minimum Roundness of fat deposits
	Dialog.addNumber("Min fat-deposit Diameter (um)", minFatDiameter); // minimum size of fat deposits
	Dialog.addNumber("Max fat-deposit Diameter (um)", maxFatDiameter); // maximum size of fat deposits
	
	// Display the dialog box
	Dialog.show();

	// Retrieve parameter values from the dialog box
	r = Dialog.getNumber();
	thTissue = Dialog.getNumber();
	thFat = Dialog.getNumber();
	fatCircularity = Dialog.getNumber();
	minFatDiameter = Dialog.getNumber();
	maxFatDiameter = Dialog.getNumber();
	//textureFeature = Dialog.getNumber();
	//fatRoundness = Dialog.getNumber();

	// Log confirmed parameters for traceability
	print("Parameters confirmed:");
	print("  micra/px ratio:          " + r);
	print("  Tissue threshold:        " + thTissue);
	print("  Fat threshold:           " + thFat);
	print("  Fat circularity (min):   " + fatCircularity);
	print("  Min fat diameter (um):   " + minFatDiameter);
	print("  Max fat diameter (um):   " + maxFatDiameter);
	//print("  Texture feature limit:   " + textureFeature);
	

	print("--- Starting BrownFatSize analysis ---");
	
    // Iterate over files in the directory
    for (j = 0; j < L; j++) {
        if (endsWith(list[j], "jpg") || endsWith(list[j], "tif")) {
            print("--- File " + (j+1) + " of " + L + ": " + list[j] + " ---");
            // Perform BrownFatSize analysis
            BrownFatSize(InDir, InDir, list[j],r, thTissue, thFat,minFatDiameter, maxFatDiameter, fatCircularity,textureFeature);
            setBatchMode(false);
        }
    }
    print("========================================");
    print("=== Batch processing complete ===");
    print("========================================");
    showMessage("Done!");
}


function BrownFatSize(output, InDir, name,r, thTissue, thFat, minFatDiameter, maxFatDiameter, fatCircularity,texturePerc) {
	// Function: BrownFatSize
	// This function performs the BrownFatSize analysis on a given image.
	// It detects tissue and fat deposits, calculates their areas, and saves the results.

	// Fat deposit based on Thresholding and Particle Analysis:
	//After thresholding, the image is processed to identify connected regions (particles) that correspond to fat deposits.
	//The Analyze Particles function is used to detect these regions based on specified criteria such as size (minFatSize and maxFatSize)
	//and circularity (fatRoundness).

	// Parameters:
	// - output: Output directory for saving analyzed images and results.
	// - InDir: Input directory where images are located (if processing multiple images).
	// - name: Name of the image file to be analyzed.

	// ============================================================
	// HELPER FUNCTIONS
	// Utility functions used internally by BrownFatSize.
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
		//print(mode);
		if (mode >220){
			// Adjust brightness if mode exceeds threshold
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
		if (mode >220){
		
			// Get the mode of pixel intensity within the ROI
			mode = getResult("Mode", 0);
			selectWindow(image);
			dif = 255 - mode;
			run("Select None");
		}
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

		 /* tableName="Results";
		 columnName="Mean";
		 filterType=">";
		 threshold=25;
		 */

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
		roiManager("select", positiveRois);

		// Return the array of positive indices
		return positiveRois;
	}

	// ============================================================
	// SECTION 1: IMAGE LOADING
	// Opens the target image via Bio-Formats (supports .czi, .tif,
	// .svs, etc.) or reuses the already-open image in single mode.
	// ============================================================
  
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

	// ============================================================
	// SECTION 2: WORKSPACE SETUP
	// Clears ROI manager and results table, creates the output
	// directory for analyzed images, and retrieves image metadata.
	// ============================================================
    // Reset ROI manager and clear previous results
    roiManager("Reset");
    run("Clear Results");

	setBatchMode("exit and display");

    // Get image title and output directory
    MyTitle = getTitle();
	MyTitle = File.nameWithoutExtension;
    output = getInfo("image.directory");
    OutDir = output + File.separator + "AnalyzedImages";
    File.makeDirectory(OutDir);
    print("Output directory: " + OutDir);

    rename(MyTitle);
    print("Processing "+MyTitle);
    selectWindow("Log");

    // Set batch mode and color preferences
    setBatchMode(true);
    run("Colors...", "foreground=white background=black selection=green");

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

	// ============================================================
	// SECTION 3: PREPROCESSING - BACKGROUND CORRECTION
	// If the image has multiple channels, each channel is corrected
	// individually for uneven background illumination (global mode:
	// pixel intensity mode is used to normalize the background to 255).
	// Channels are then re-merged into a single RGB image.
	// ============================================================
    run("Select All");
	showStatus("Detecting tumor...");
	// check number of channels, if more than 1 convert to luminance
	getDimensions(width, height, channels, slices, frames);
	if (channels > 1) {
		print("- Preprocessing: multichannel image detected (" + channels + " channels). Correcting background...");
		selectWindow(MyTitle);
	}else{
		//split rgb channels and apply background correction to each one and merge it again
		print("- Preprocessing: RGB image detected. Correcting background...");
		run("Make Composite");
	}
	run("Split Channels");
	//apply correctBackground to each channel
	for (c=1; c<=channels; c++) {
		selectWindow("C"+c+"-"+	MyTitle);
		modeBckg=correctBackground("C"+c+"-"+MyTitle);
		print("  Channel " + c + " background corrected (mode = " + modeBckg + ").");
		resetMinAndMax;
		run("Enhance Contrast", "saturated=0.01");
		run("Apply LUT");

	}
	//merge channels again
	run("Merge Channels...", "c1=[C1-"+MyTitle+"] c2=[C2-"+MyTitle+"] c3=[C3-"+MyTitle+"] create");
	run("RGB Color");
	rename("orig");
	print("- Preprocessing complete. Channels merged back into RGB.");
	
	/*
	r=0.252;
	minFatDiameter =0.01;
	maxFatDiameter = 30;*/
	
	//from maxDiameter calculate maxFatSize in pixels, diameter in microns, convert to pixels using r, then calculate area of circle in pixels
	maxFatSize = 3.14 * (maxFatDiameter/2) * (maxFatDiameter/2) / (r*r); // Area of circle in pixels
	maxFatSize = floor(maxFatSize);
	// from minFatDiameter calculate minFatSize in pixels, diameter in microns, convert to pixels using r, then calculate area of circle in pixels
	minFatSize = 3.14 * (minFatDiameter/2) * (minFatDiameter/2) / (r*r); // Area of circle in pixels
	minFatSize = floor(minFatSize);

 	print("Max fat size in pixels: " + maxFatSize);
	print("Min fat size in pixels: " + minFatSize);


	// ============================================================
	// SECTION 4: TISSUE SEGMENTATION
	// Converts the RGB image to luminance (grayscale), applies a
	// fixed threshold (thTissue=210) to isolate stained tissue from
	// background, removes small particles and holes with morphological
	// operations, and stores the result as ROI 0 ("Tissue").
	// ============================================================
		
	print("- Segmenting Tissue...");
    run("Select All");
    showStatus("Detecting tissue...");
    run("RGB to Luminance");
    rename("tissueMask");
    run("Threshold...");
    //thTissue=245;
    setThreshold(0, thTissue);
    setOption("BlackBackground", false);
    run("Convert to Mask");
    run("Invert");
    run("Open");
    run("Analyze Particles...", "size="+maxFatSize+"-Infinity pixel show=Masks in_situ");
    run("Invert");
    run("Analyze Particles...", "size="+maxFatSize+"-Infinity pixel show=Masks in_situ");
    run("Create Selection");
    Roi.setName("Tissue");
    run("Add to Manager"); // ROI0 --> whole tissue
    print("  Tissue ROI added to manager (ROI 0).");

	// ============================================================
	// SECTION 5: LIPID MASK - INITIAL DETECTION
	// Duplicates the RGB image, converts to 8-bit, thresholds the
	// bright (white) fat-vacuole regions (thFat=210), applies a
	// morphological Opening to remove noise, excludes edge objects,
	// restricts detections to the tissue ROI, and applies Adjustable
	// Watershed to separate touching lipid vacuoles.
	// Result stored as ROI 1 ("FatMask").
	// ============================================================
	//-- DETECT LIPID DEPOSITS
    
	selectWindow("orig");
	run("Select None");

 	// LIPID MASK--> no signal regions (white)set
	print("- Segmenting Fat deposits ...");
	selectWindow("orig");
	run("Select None");
	run("Duplicate...", "title=fatMask");
    //run("RGB to Luminance");	
	run("8-bit");
	run("Subtract Background...", "rolling=500 light");
	run("Median...", "radius=1");
	//thFat=235;
	run("Threshold...");
	setThreshold(thFat, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Morphological Filters", "operation=Opening element=Disk radius=1");
	close("fatMask");
	selectWindow("fatMask-Opening");
	rename("fatMask");
	run("Analyze Particles...", "show=Masks exclude in_situ");
	roiManager("select", 0);
	run("Enlarge...", "enlarge=-5 pixel");
	setBackgroundColor(255,255,255);
	run("Clear Outside");
	run("Select None");
	run("Analyze Particles...", "size="+minFatSize+"-"+(2*maxFatSize)+" pixel show=Masks exclude in_situ");
    run("Adjustable Watershed", "tolerance=0.25");
	run("Analyze Particles...", "size="+minFatSize+"-"+maxFatSize+" pixel circularity="+fatCircularity+"-1.00 show=Masks exclude in_situ");
	run("Create Selection");
	Roi.setName("FatMaskFiltered");
	roiManager("add");
	run("Select None");
	print("  Fat mask ROI added to manager (ROI 1).");
	
	
	/*
	// ============================================================
	// SECTION 6: TEXTURE FEATURE EXTRACTION
	// Glycogen deposits mimic fat vacuoles visually but have a
	// different texture. A first-order derivative (FeatureJ) captures
	// local intensity gradients: fat vacuoles have low gradient energy
	// (smooth interiors) while glycogen clusters are coarser.
	// The squared gradient image is thresholded to keep only smooth
	// (low-texture) regions, then filtered by size and dilated.
	// Result stored as "textureFeature" mask (ROI 2).
	// ============================================================
	// FAT MASK BASED ON TEXTURE -->
	//Test images present glucogen, same phenotype as BrownFatSize with different morphology and texture.

	print("- Separate Fat deposits from  glucogen ...");
	selectWindow("rgb");
	run("Duplicate...", "title=fatMask-texture");
	run("Select None");
	run("8-bit");
	run("FeatureJ Derivatives", "x-order=1 y-order=1 z-order=0 smoothing=1.0");
	selectImage("fatMask-texture dx1 dy1 dz0");
	run("Square");
	//run("Threshold...");
	textureFeature=1.5;
	setThreshold(-0.2,textureFeature);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Morphological Filters", "operation=Opening element=Disk radius=1");
	//minFatSize=20;
	//maxFatSize=8000;
	run("Analyze Particles...", "size="+minFatSize+"-"+maxFatSize+" pixel show=Masks exclude in_situ");
	run("Dilate");
	roiManager("select", 1);
	setBackgroundColor(255,255,255);
	run("Clear Outside");
	run("Select None");
	run("Colors...", "foreground=white background=black selection=green");
	run("Create Selection");
	Roi.setName("TextureFeature");
	roiManager("add");
	close("*dx1*");
	close("fatMask-texture");
	selectWindow("fatMask-texture-Opening");
	rename("textureFeature");
	run("Select None");
	roiManager("Show None");
	print("  Texture feature mask generated (ROI 2).");

	/* TEXTURE FEATURES SHAPE DESCRIPTORS  ...
	 *  Classify fatMask ROIs based on texture feature
	 *  	--> Decided not to use due to fat glucogen clusters - shape descriptors wont be useful then.
 	 *  Use directly texture Rois shape descriptors.
 	 *  Roundness
 	 *  Solidity
 	 *

 	// Classify fatMask ROIs based on texture feature
    selectWindow("fatMask");
    run("Select None");
    run("Analyze Particles...", "show=Masks add in_situ");
    roiManager("show none");
    selectWindow("textureFeature");
    run("Select None");
    run("Set Measurements...", "area_fraction mean redirect=None decimal=2");
    roiManager("measure");


	// ============================================================
	// SECTION 7: SHAPE FILTERING - ROUNDNESS
	// Roundness = 4 × Area / (π × MajorAxis²), equivalent to the
	// inverse of Aspect Ratio. Filters out elongated objects (e.g.
	// vessel lumens, artifacts) that are not round like true lipid
	// vacuoles. Only ROIs with Roundness > fatRoundness are kept.
	// ============================================================
	// ROUNDNESS --> 4 × [Area] / π × [Major axis]2  or the inverse of Aspect Ratio.

    roiManager("Reset");
    run("Clear Results");
    close("Results");
   	print("- Obtaining Texture Features ...");
   	print("- Filtering by Roundness (> " + fatRoundness + ")...");
   	selectWindow("textureFeature");
   	run("Set Measurements...", "area shape redirect=None decimal=2");
   	run("Analyze Particles...", "show=Masks add display in_situ");
	positiveRois=filterTableColum("Results","Round",">",fatRoundness);
	roiManager("select", positiveRois);
	roiManager("save selected", OutDir+File.separator+MyTitle+"_BrownFatSizeROIs.zip");
	roiManager("Reset");
	roiManager("Open", OutDir+File.separator+MyTitle+"_BrownFatSizeROIs.zip");
	print("  Roundness filter applied. " + roiManager("count") + " ROIs passed.");

	run("From ROI Manager");
	run("Create Mask");
	close("textureFeature");
	selectWindow("Mask");
	rename("TextureFeature_Roundness");
	run("Median", "radius=2");
	//run("Dilate");

	////

	// ============================================================
	// SECTION 8: SHAPE FILTERING - SOLIDITY
	// Solidity = Area / ConvexArea. Rejects irregular or concave
	// objects (e.g. merged clusters, debris). Only ROIs with
	// Solidity > 0.8 are kept, indicating compact, filled shapes.
	// ============================================================

 	roiManager("Reset");
    run("Clear Results");
  	close("Results");
    //mFatSize=50;
	//maxFatSize=8000;
	print("- Filtering by Solidity (> 0.8)...");
	selectWindow("TextureFeature_Roundness");
	run("Analyze Particles...", "size="+minFatSize+"-"+maxFatSize+" pixel show=Masks add display in_situ");
	positiveRois=filterTableColum("Results","Solidity",">",0.8);
	roiManager("select", positiveRois);
	roiManager("save selected", OutDir+File.separator+MyTitle+"_BrownFatSizeROIs.zip");
	roiManager("Reset");
	roiManager("Open", OutDir+File.separator+MyTitle+"_BrownFatSizeROIs.zip");
	print("  Solidity filter applied. " + roiManager("count") + " ROIs passed.");

	run("From ROI Manager");
	run("Create Mask");
	close("TextureFeature_Roundness");
	selectWindow("Mask");
	rename("TextureFeature_Roundness_Sol");
	roiManager("Show None");

	selectWindow("TextureFeature_Roundness_Sol");
	run("Analyze Particles...", "size="+minFatSize+"-"+maxFatSize+" show=Ellipses");
	run("Fill Holes");
	close("TextureFeature_Roundness_Sol");
	selectWindow("Drawing of TextureFeature_Roundness_Sol");
	rename("TextureFeature_Roundness_Sol");

	// ============================================================
	// SECTION 9: SHAPE FILTERING - ASPECT RATIO
	// AR = MajorAxis / MinorAxis of the fitted ellipse. Values close
	// to 1 indicate a near-circular shape. Lipid vacuoles are
	// expected to be roughly circular; objects with AR > 1.35 are
	// rejected as too elongated. This is the final shape gate.
	// ============================================================
	// ASPECT RATIO -->  The aspect ratio of the particle's fitted ellipse, i.e., [Major Axis]/[Minor Axis]

	roiManager("Reset");
    run("Clear Results");
 	close("Results");
 	print("- Filtering by Aspect Ratio (< 1.35)...");
    selectWindow("TextureFeature_Roundness_Sol");
	run("Set Measurements...", "area shape redirect=None decimal=2");
   	run("Analyze Particles...", "show=Masks add display in_situ");
   	positiveRois=filterTableColum("Results","AR","<",1.35);
   	roiManager("select", positiveRois);
	roiManager("save selected", OutDir+File.separator+MyTitle+"_BrownFatSizeROIs.zip");
	roiManager("Reset");
	roiManager("Open", OutDir+File.separator+MyTitle+"_BrownFatSizeROIs.zip");
	run("From ROI Manager");
	run("Create Mask");
	rename("texturePositive");
	close("TextureFeature_Roundness_Sol");
	roiManager("Show None");
	print("  Aspect Ratio filter applied. " + roiManager("count") + " ROIs passed.");
	
	*/
	// ============================================================
	// SECTION 10: LIPID STATISTICS
	// Collects total count and per-object area statistics (min, max,
	// mean, stddev) for the final filtered lipid ROI set.
	// These values are used in the quantification results table.
	// ============================================================
	
  	/* IN CASE MARKER CONTROLLED WATERSHED IS NEEDED
	 *
  	/* Seeds
	selectWindow("rgb");
	run("8-bit");
	run("Gaussian Blur...", "sigma=1");
	run("From ROI Manager");
	run("Create Mask");

	run("Adjustable Watershed", "tolerance=1");
	//minFatSize=25;
	//maxFatSize=8000;
	//fatRoundness=0.7;
	run("Analyze Particles...", "size="+minFatSize+"-"+maxFatSize+" circularity="+fatRoundness+"-1 pixel show=Masks exclude in_situ");
	rename("texturePositive");


	selectWindow("textureFeature");
	run("Restore Selection");
	setBackgroundColor(255,255,255);
	run("Clear Outside");
	run("Colors...", "foreground=white background=black selection=green");
	run("Select None");
	run("Distance Map");
	run("Log");
	run("Fire");
	prominence=10;
	run("Find Maxima...", "prominence="+prominence+" output=[Single Points]");
	rename("seeds");

	// Fat deposit edges
	selectWindow(MyTitle);
	run("Duplicate...", "title=fatEdges");
	run("Select None");
	run("8-bit");
	run("Find Edges");

	// Reset ROI manager and clear previous results
    roiManager("Reset");
    run("Clear Results");

	// Marker-controlled watershed
	run("Marker-controlled Watershed", "input=fatEdges marker=seeds mask=texturePositive binary calculate use");
	selectWindow("fatEdges-watershed");
	rename("fatSegmented");
	run("8-bit");
	setThreshold(1, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");

	minFatSize=40;
	maxFatSize=8000;
	fatRoundness=0.6;
	//run("Analyze Particles...", "size=40-3000 circularity=0.70-1.00 pixel show=Masks in_situ");
	run("Analyze Particles...", "size="+minFatSize+"-"+maxFatSize+" circularity="+fatRoundness+"-1.00 pixel show=Masks in_situ");
	*/
	// ============================================================
	// SECTION 11: QUANTIFICATION
	// Measures tissue area (ROI 0) and total lipid area (ROI 1) in
	// pixels, converts to µm² using the calibration ratio r (µm/px),
	// and computes the lipid-to-tissue area ratio as a percentage.
	// ============================================================
    print("- Calculate Quantification Features ...");

    // RESULTS --- Calculate Quantification Features

    selectWindow("tissueMask");
    run("Select None");
    run("Create Selection");
	tissueArea = getValue("Area");

	selectWindow("fatMask");
	run("Select None");
    run("Create Selection");
	fatArea = getValue("Area");
	run("Select None");
	roiManager("show none");
	run("Analyze Particles...", "show=Ellipses exclude");
	roiManager("Select", 1);
	roiManager("Delete");
	run("Select None");
	roiManager("show none");
	run("Create Selection");
	Roi.setName("Elipses");
 	run("Add to Manager");
		
    // Ratio of fat deposits to tissue area
    r1 = fatArea / tissueArea * 100;

    print("  Tissue area:            " + tissueArea + " um2");
    print("  Total Lipid area:       " + fatArea + " um2");
    print("  Lipid/Tissue ratio:     " + r1 + " %");

	// GET LIPID SIZE and shape  STATISTICS
	selectWindow("fatMask");
	run("Set Measurements...", "area shape redirect=None decimal=2");
	run("Analyze Particles...", "show=Nothing display");
	area=Table.getColumn("Area");
	nLipids=lengthOf(area);
	Array.getStatistics(area, areaMin, areaMax, areaAvg, areaStdDev);
	print("  Lipids detected:        " + nLipids);
	print("  Avg lipid size (um2):   " + areaAvg);
	print("  StdDev size (um2):      " + areaStdDev);	

	// ESTIMATE DIAMETER FROM AREA
	// Assuming lipid deposits are roughly circular, we can estimate the diameter from the area using the
	// formula for the area of a circle: A = π * (d/2)^2  =>  d = 2 * sqrt(A/π)
	diameterAvg = 2 * sqrt(areaAvg / 3.14);
	print("  Avg lipid diameter (um): " + diameterAvg);
	diameterStdDev = 2 * sqrt(areaStdDev / 3.14);
	print("  StdDev lipid diameter (um): " + diameterStdDev);	

	// ============================================================
	// SECTION 13: RESULTS EXPORT (XLS)
	// Appends the quantification row for this image to the shared
	// results file (Quantification_BrownFatSize.xls).  If the file
	// already exists it is re-opened first so all images accumulate
	// in a single spreadsheet.
	// ============================================================
    // Save results to a file
    run("Clear Results");
    if (File.exists(output + File.separator + "QuantificationResults_BrownFatSize.xls")) {
        open(output + File.separator + "QuantificationResults_BrownFatSize.xls");
        IJ.renameResults("Results");
    }
    i = nResults;
    setResult("[Label]", i, MyTitle);
    setResult("Tissue area (um2)", i, tissueArea);
    setResult("Total Lipids area (um2)", i, fatArea);
    setResult("Ratio ALipids/Atissue (%)", i, r1);
    setResult("# Lipids Detected", i, nLipids);
    setResult("Lipid Avg Size (um2)", i, areaAvg);
    setResult("Lipid stdDev Size (um2)", i, areaStdDev);
    setResult("Lipid Avg Diameter (um)", i, diameterAvg);
    setResult("Lipid stdDev Diameter (um)", i, diameterStdDev);
    saveAs("Results", output + File.separator + "QuantificationResults_BrownFatSize.xls");
    print("  Results saved to: " + output + File.separator + "QuantificationResults_BrownFatSize.xls");
    
  	// ============================================================
	// SECTION 12: individual LIPID MEASUREMENTS EXPORT
	// Exports the measurements for each detected lipid deposit (area,
	// shape descriptors, etc.) to a separate XLS file (LipidMeasurements_[ImageName].xls) for more detailed analysis of lipid size distribution, morphology, etc.
	// =========================================================

	// GET LIPID SIZE and shape  STATISTICS
	selectWindow("fatMask");
    run("Clear Results");
    close("Results");
	// add diameter measurement based on area, assuming circular shape: d = 2 * sqrt(A/π)
	run("Set Measurements...", "area fit redirect=None decimal=2");
	run("Analyze Particles...", "size=show=Nothing display clear in_situ");
	wait(10);
	selectWindow("Results");
	Table.deleteColumn("Angle");
	Table.update;
	
	selectWindow("Results");
	// Save individual lipid measurements to a file
	if (nLipids > 0) {
		saveAs("Results", output + File.separator + "LipidMeasurements_" + MyTitle + ".xls");
		print(" Individual lipid measurements saved to: " + output + File.separator + "LipidMeasurements_" + MyTitle + ".xls");
	} else {
		print("No lipids detected, skipping individual measurements export.");
	}

// ============================================================
	// SECTION 14: OVERLAY IMAGE EXPORT
	// Renders the original image with ROI overlays:
	//   - Yellow outline → Tissue boundary (ROI 0)
	//   - Green outline  → Lipid deposits (ROI 1)
	// The flattened image is saved as a JPEG in the AnalyzedImages
	// output folder for visual quality-control review.
	// ============================================================
	print("- Saving Segmented Images ...");

    // Display and save analyzed images
    selectWindow(MyTitle);
    roiManager("Show None");
    roiManager("Select", 0);
    roiManager("Set Color", "yellow");
    roiManager("Set Line Width", 0.5);
    roiManager("Show None");
    roiManager("Select", 1);
    roiManager("Set Color", "green");
    roiManager("Set Line Width", 0.5);
	roiManager("Show All with labels");
	run("Flatten");
    saveAs("Tiff", OutDir + File.separator + MyTitle + "_analyzed.tif");
    rename(MyTitle + "_analyzed.jpg");
    print("  Overlay image saved to: " + OutDir + File.separator + MyTitle + "_analyzed.1");



	// ============================================================
	// SECTION 15: CLEANUP
	// Closes all intermediate windows and resets the active tool.
	// In batch mode, the analyzed image is also closed to free memory
	// before the next file is processed.
	// ============================================================
    print("- Cleanup: closing intermediate windows...");
    // Close windows and reset tool
    close("\\Others");
    roiManager("reset");
    close("Results");
 	setTool("zoom");

    if (InDir != "-") {
        close();
    }

    print("=== BrownFatSize analysis complete for: " + MyTitle + " ===");
    //showMessage("Done!");
}
