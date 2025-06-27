function macroInfo(){
	
// * Quantification of Tissue+MARKER Immunofluorescence Images  
// * Target User: General
// *  

	scripttitle= "Quantification of Tissue MARKER IF Images";
	version= "1.01";
	date= "2025";
	

// *  Tests Images:

	imageAdquisition="Epifluorescence/Confocal: 2 channel .tif images (Tissue + Marker).";
	imageType="(24bit RGB)";  
	voxelSize="Voxel size: user defined";
	format="Format: .tif";   
 
 //*  GUI User Requierments:
 //*    - Interactive Threshold for Marker
 //*    - Automatic Tissue segmentation
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: 

	 parameter3="Tissue Threshold (automatic)";
	 parameter4="Marker Threshold (interactive)";
	 parameter5="Min Nucleus Size (pixels)";
	 parameter6="Min Marker Size (pixels)";
	 
 //  2 Action tools:
		
	 buttom1="Im: Single File processing. Use for parameter tuning";
	 buttom2="Dir: Batch Mode. Tune parameters before batch processing";

//  OUTPUT

// Analyzed Images with ROIs

	excel="IF_TissuePhenotype_Manual_Results.xls";
	
	feature1="Label";
	feature2="ROI Area (um2)";
	feature3="Tissue Area (um2)";
	feature4="Positive Area (um2)";
	feature5="Ratio AMarker/ATissue (%)";
    feature6="Mean Marker Signal (ROI)";      // <-- Added new parameter
    feature7="Std Marker Signal (ROI)";       // <-- Added new parameter
	
/*  	  
 *  version: 2.00 
 *  Author: Adapted by Tomas Muñoz 2025 
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
		+"<h1><font size=6 color=Teal>CIMA: Imaging Platform</h1>"
		+"<h1><font size=5 color=Purple><i>Software Development Service</i></h1>"
		+"<p><font size=2 color=Purple><i>ImageJ Macros</i></p>"
		+"<h2><font size=3 color=black>"+scripttitle+"</h2>"
		+"<p><font size=2>Modified by Tomas Mu&ntilde;oz Santoro</p>"
		+"<p><font size=2>Version: "+version+" ("+date+")</p>"
		+"<p><font size=2> contact tmsantoro@unav.es</p>" 
		+"<p><font size=2> Available for use/modification/sharing under the "+"<a href=https://opensource.org/licenses/MIT/>MIT License</a></p>"
		+"<h2><font size=3 color=black>Developed for</h2>"
		+"<ul><font size=2><li>"+imageAdquisition+"</li><li>"+imageType+"</li><li>"+voxelSize+"</li><li>"+format+"</li></ul>"
		+"<ol><font size=2><li>"+buttom1+"</li><li>"+buttom2+"</li></ol>"
		+"<ul><font size=2><li>"+parameter3+"</li><li>"+parameter4+"</li><li>"+parameter5+"</li><li>"+parameter6+"</li></ul>"
		+"<p><font size=3>Quantification Results: </font></p>"
		+"<p><font size=3>AnalyzedImages folder: Visualize Segmented Images</font></p>"
		+"<p><font size=3>Excel "+excel+"</font></p>"
		+"<ul><font size=2><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li><li>"+feature5+"</li><li>"+feature6+"</li><li>"+feature7+"</li></ul>"
		+"");
}


// Changelog October 2021
// Added batch processing of a directory
// Included Marker Phenotypedetection from color deconvolution

// Define default parameters
var r = 0.502;
var thTissue  = 200;
var markerThreshold = 80;
var minSize=20;
var corrType = "Global correction";
var export = true;

// Macro for processing a single file
macro "IF_TissuePhenotype_Manual Action Tool 1 - Cf00T2d15IT6d10m" {
	
	close("*");
	
	// Select a single file
	name = File.openDialog("Select File");
    open(name);
    
    macroInfo();
    
	// Display parameter dialog
	Dialog.create("Parameters");
	Dialog.addMessage("Choose parameters");
	Dialog.addNumber("micra/px ratio", r);
	Dialog.addNumber("Tissue  threshold", thTissue );
	Dialog.addMessage("Marker Phenotype Detection parameters");
	Dialog.addNumber("Marker  Min Size ", minSize);
	//Dialog.addNumber(" threshold", markerThreshold);
	//modeArray = newArray("Global correction", "Tissue  correction");
	//Dialog.addRadioButtonGroup("Choose background compensation for Marker  ", modeArray, 1, 2, "Global correction");
	Dialog.addCheckbox("Export analyzed image", export); 
	Dialog.show();
	
	// Get parameter values from dialog
	r = Dialog.getNumber();
	thTissue  = Dialog.getNumber();
	minSize=Dialog.getNumber();
	//markerThreshold = Dialog.getNumber();
	//corrType = Dialog.getRadioButton();
	export = Dialog.getCheckbox();
	
	// Perform Marker Phenotypedetection
	analyzeMarkerImage("-", "-", name, r, thTissue , markerThreshold,corrType, export,minSize);
	showMessage("Done!");
}


// Macro for batch processing of a directory
macro "IF_TissuePhenotype_Manual Action Tool 2 - C00fT0b11DT9b09iTcb09r" {
	
	close("*");
	
	// Select a directory
	InDir = getDirectory("Choose a Directory");
	list = getFileList(InDir);
	L = lengthOf(list);

	// Display parameter dialog
	Dialog.create("Parameters");
	Dialog.addMessage("Choose parameters");
	Dialog.addNumber("micra/px ratio", r);
	Dialog.addNumber("Tissue  threshold", thTissue );
	Dialog.addMessage("Marker Phenotype Detection parameters");
	Dialog.addNumber("Marker threshold", markerThreshold);
	Dialog.addNumber("Marker Min Size ", minSize);
	modeArray = newArray("Global correction", "Tissue  correction");
	Dialog.addRadioButtonGroup("Choose background compensation for Marker  ", modeArray, 1, 2, "Tissue  correction");
	Dialog.addCheckbox("Export analyzed image", export); 
	Dialog.show();
	
	// Get parameter values from dialog
	r = Dialog.getNumber();
	thTissue  = Dialog.getNumber();
	markerThreshold = Dialog.getNumber();
	minSize=Dialog.getNumber();
	//corrType = Dialog.getRadioButton();
	export = Dialog.getCheckbox();

	// Process each file in the directory
	for (j = 0; j < L; j++) {
		if (endsWith(list[j], "tif") || endsWith(list[j], "jpg")) {
			// Analyze file
			name = list[j];
			print(name);
			analyzeMarkerImage(InDir, InDir, list[j], r, thTissue , markerThreshold,corrType, export,minSize);
		}
	}
	showMessage("Done!");
}


function analyzeMarkerImage(output,InDir,name,r,thTissue , markerThreshold,corrType,export,minSize)
{
	
	// Performs Marker Phenotypedetection and analysis.
	// 
	// Parameters:
	// - output: Output directory for saving analyzed images and results.
	// - InDir: Input directory where the image is located.
	// - name: Name of the image file.
	// - r: Micra/pixel ratio.
	// - thTissue : Tissue  threshold value.
	// - markerThreshold:  threshold value for Marker Phenotypedetection.
	// - corrType: Type of background compensation ("Global correction" or "Tissue  correction").
	// - export: Indicates whether to export analyzed images.
	
	
	if (InDir != "-") {
		close("*");
	    // If input directory is specified, check if the image is already open, if not, open it
	    if (!isOpen(InDir + name)) {
	        open(InDir + name);
	    }
	}
	

	// Initialize ROI Manager, clear results, and set up output directories
	roiManager("Reset");
	run("Clear Results");
	MyTitle = getTitle();
	output = getInfo("image.directory");
	MyTitleShort = File.nameWithoutExtension;
	rename(MyTitleShort);
	run("Colors...", "foreground=black background=white selection=green");
	OutDir = output + File.separator + "AnalyzedImages";
	File.makeDirectory(OutDir);
	
		
	// Retrieve image dimensions and set properties such as pixel width and height
	getDimensions(width, height, channels, slices, frames);
	run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=" + r + " pixel_height=+" + r + " voxel_depth=1.0000 frame=[0 sec] origin=0,0");
	
	// Detecting background
	run("Select All");

	Dialog.create("Region of Interest");
	Dialog.addMessage("Choose ROI selection method:");
	Dialog.addRadioButtonGroup("Segmentation mode", newArray("Automatic", "Manual"), 1, 2, "Automatic");
	Dialog.show();
	segMode = Dialog.getRadioButton();

	run("Roi Defaults...", "color=blue stroke=0 group=0");
	
	setBatchMode(false);
	
	// Determine whether to apply global or Tissue -specific background correction
	if (corrType == "Global correction") {
	    globalMode = true;
	} else {
	    globalMode = false;
	}
	
	
	iteration=1;
	
	if (segMode == "Manual") {
		
		nextROI = true ; 

		while (nextROI) {
			
			getROI(segMode,MyTitleShort,iteration);

			processROI(iteration, MyTitleShort, MyTitleShort, output, r, segMode, markerThreshold, minSize, globalMode, export, OutDir);
			
			choice = getBoolean("Do you want to draw another ROI?");

			if (!choice) {
				nextROI = false;
			}else{
				iteration++;
			}
			
		}
	} else {
			
			getROI(segMode,MyTitleShort,iteration);
			processROI(iteration, MyTitleShort, MyTitleShort, output, r, segMode, markerThreshold, minSize, globalMode, export, OutDir);
	}


	//deleteUnwantedROIs(MyTitle);
}

function checkImageType(image) {
	/**
	 * Checks and returns the type of the currently active image.
	 * Returns a string: "8-bit", "16-bit", "24-bit RGB", "32-bit", or "Unknown".
	 * Also checks if the image is multichannel and appends " (multichannel)" if so.
	 * Note: 24-bit means RGB image (3 channels, 8 bits per channel).
	 */
	 
	selectWindow(image);
	getDimensions(width, height, channels, slices, frames);
	imageType = bitDepth();

	if (imageType == 8) {
		typeStr = "8-bit";
	} else if (imageType == 16) {
		typeStr = "16-bit";
	} else if (imageType == 24) {
		typeStr = "24-bit RGB"; // 8 bits per channel, 3 channels = RGB
	} else if (imageType == 32) {
		typeStr = "32-bit";
	} else {
		typeStr = "Unknown";
	}

	if (channels > 1) {
		typeStr = typeStr + " (multichannel)";
	}
	return typeStr;
}


function getROI(segMode,image,iteration) {

		/*
		 * Segments Tissue  regions in an image using either automatic or manual methods.
		 * @param image      The input image to be processed for Tissue  segmentation. expects RGB image
		 */
		
		selectWindow(image);
		if (segMode == "Automatic") {
			
			run("Select All");
			Roi.setName("ROI__1");
			roiManager("Set Color", "yellow");
			roiManager("Add");
		} else {
			// Manual ROI addition
			waitForUser("Manual ROI", "Draw your Region of Interest and then press OK when finished.");
			// Optionally, you can check if at least one ROI is present:
			type = selectionType() ;
			if (type != -1) {
				Roi.setName("ROI_"+iteration);
				Roi.setStrokeColor("yellow");
				roiManager("Add");
				
			}else{
				showMessage("No ROIs", "No ROIs were added. Please try again.");
				exit();
			}
		}

	return segMode
}


function processROI(iteration, orig, MyTitleShort, output, r, segMode, markerThreshold, minSize, globalMode, export, OutDir) {
	/*
	* Processes a single Region of Interest (ROI) for Marker Phenotypequantification.
	*
	* @param {int} i - Index of the ROI to process.
	* @param {string} orig - Title of the original image.
	* @param {string} MyTitleShort - Shortened title for output naming.
	* @param {string} output - Output file or directory for results.
	* @param {int} r - Current ROI index or identifier.
	* @param {string} segMode - Segmentation mode to use for Tissue  detection.
	* @param {int} markerThreshold - Threshold value for Marker Phenotypedetection.
	* @param {int} minSize - Minimum size for detected regions to be considered.
	* @param {boolean} globalMode - Whether to use global background correction.
	* @param {boolean} export - Whether to export visualization images.
	* @param {string} OutDir - Output directory for exported images.
	*/

	roiManager("select", 0);
	Roi.getBounds(x, y, width, height);
	pos = newArray(x, y);
	//Array.print(pos);
	run("Duplicate...", "title=roi");

	segmentTissue(MyTitleShort, "roi", pos, iteration);

	// Extract marker channel 
	markerIm = extractMarkerChannel("roi");

	correctBackground(markerIm, globalMode);

	segmentMarker(MyTitleShort, markerIm, segMode, pos, markerThreshold, iteration, minSize);

	measureAndExportResults(MyTitleShort,markerIm, output, r, iteration);

	visualizationAndExport(export, OutDir, MyTitleShort);
	
	
	run("Clear Results");
	roiManager("reset");
		
	
}


function segmentTissue(orig,roi,pos,iteration) {
	/*
	 * Segments Tissue+ nuclei using the selected Tissue channel.
	 * @param orig      The original image window name.
	 * @param roi       The ROI window name.
	 * @param pos       Position array for ROI placement.
	 * @param iteration ROI index.
	 */
 	imageType = checkImageType(roi);

	if (imageType == "24-bit RGB"){
		//run("Split Channels");
		//run("Merge Channels...", "c1=["+roi+" (red)] c2=["+roi+" (green)] c3=["+roi+" (blue)] create");
		run("RGB to Luminance");
	}else if (indexOf(imageType, "multichannel") != -1) {
		// If the image is multichannel, split channels
		run("RGB Color");
		run("RGB to Luminance");		
	}

	setAutoThreshold("Huang dark");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=3");
	run("Open");
	run("Analyze Particles...", "size=50-Infinity pixel circularity=0.00-1.00 show=Masks clear in_situ");
	selectWindow(roi);
	selectWindow("luminance of "+roi);
	run("Restore Selection");
	run("Clear Outside");
	run("Create Selection");
	Roi.getBounds(x, y, width, height);
	selectWindow(orig);
	run("Restore Selection");
	Roi.move(pos[0]+x, pos[1]+y);
	Roi.setName("Tissue_"+iteration);
	Roi.setStrokeColor("blue");
	roiManager("Add");
	close("luminance of "+roi);
}

// Function to delete unwanted ROIs interactively
function deleteUnwantedROIs(MyTitle) {
	/*
	 * Allows the user to interactively delete unwanted Regions of Interest (ROIs) from an image.
	 * Prompts the user to confirm deletion, then enables freehand selection to specify the ROI to delete.
	 * After the user draws and confirms the selection, the selected region is filled and removed from the image.
	 * The process can be repeated until the user chooses to stop.
	 * 
	 * @param MyTitle  The title of the image window where ROIs are managed and deletions are performed.
	 */


	// Ask user if they want to delete unwanted regions
	deleteROIs = getBoolean("Do you want to Delete unwanted Regions");
	do {
		nRois = roiManager("count");
		if (nRois > 1) {
			roiManager("select", 1);
			roiManager("delete");
		}
		// Set tool for freehand selection
		setTool("freehand");
		selectWindow(MyTitle);
		roiManager("select", 1);

		waitForUser("Please Draw ROI to delete and press ok when ready");

		// Check if we have a selection
		type = selectionType();
		if (type == -1) {
			showMessage("Edition", "You should select a fiber to delete. Nothing will be deleted.");
			exit();
		}

		selectWindow("positive");
		setBatchMode("show");
		run("Restore Selection");
		setForegroundColor(255, 255, 255);
		run("Fill", "slice");
		run("Create Selection");
		selectWindow(MyTitle);
		run("Restore Selection");
		showMessage("Selection deleted");
		selectWindow(MyTitle);
		deleteROIs = getBoolean("Do you want to Delete another unwanted Regions");
	} while (deleteROIs)
}



function extractMarkerChannel(roi) {
	/*
	 * Extracts the red channel from a multichannel (RGB or composite) image.
	 * @param cropName  The name of the image window to extract from.
	 * @return          The name of the extracted red channel image.
	 */
	selectWindow(roi);
	
	imageType = checkImageType(roi);
	run("Duplicate...", "title=markerChannel");
	
	if (imageType == "24-bit RGB"){
		run("Split Channels");
		close("markerChannel (blue)");
		close("markerChannel (green)");
		selectWindow("markerChannel (red)");
		rename("markerChannel");
	}else if (indexOf(imageType, "multichannel") != -1) {
		run("Split Channels");
		// For split channels, ImageJ names them as "cropName (red)", "cropName (green)", etc.
		close("C2-"+roi);
		close("C3-"+roi);
		selectWindow("C1-"+roi);
		rename("markerChannel");
	} 
	
	return "markerChannel";


	
}

function correctBackground(image,globalMode) {

		/*
		* Corrects the background intensity of the current image, either globally or within a selected Tissue  region.
		*
		* @param {boolean} globalMode - If true, applies global background correction to the entire image.
		*                               If false, applies correction only to the region selected in the ROI Manager.
		*/

		showStatus("Correcting background...");
		
		selectWindow(image);
		
		// Determine background correction mode
		if (globalMode) {
			// Apply global background correction
			run("Clear Results");
			run("Set Measurements...", "area mean modal redirect=None decimal=2");
			run("Select All");
			run("Measure");
			mod = getResult("Mode", 0);
			if (mod > 200) {
				dif = 255 - mod;
				run("Add...", "value=" + dif);
			}
			run("Clear Results");
			close("Results");
		} else {
			// Apply Tissue -specific background correction
			run("Clear Results");
			run("Set Measurements...", "area mean modal redirect=None decimal=2");
			roiManager("select", 0);
			run("Measure");
			mod = getResult("Mode", 0);
			if (mod > 200) {
				dif = 255 - mod;
				run("Select None");
				run("Add...", "value=" + dif);
			}
			run("Clear Results");
			close("Results");
		}
}


function segmentMarker(MyTitle,positiveIm,segMode,pos,markerThreshold,iteration,minSize) {
	/*
	 * Detects Marker  -positive regions in the current image window.
	 * Allows user to interactively select threshold, then creates a mask and ROI.
	 *
	 * @param MyTitle      The title of the main image window.
	 * @param x, y         Coordinates to move overlay (optional, for ROI placement).
	 * @param positiveIm   A string, should be "positive", indicating that the function will detect and process Marker  -positive regions.
	 * @param markerThreshold Default threshold value (not used if user selects interactively).
	 * @param segMode      Segmentation mode: "Automatic" applies Otsu threshold, "Manual" lets user select threshold interactively.
	 * 
	 */
	selectWindow(positiveIm);
	setBatchMode("show");
	showStatus("Detecting Marker ...");

	if (segMode == "Automatic") {
				
		// If segmentation mode is Automatic, use Otsu thresholding
		
		setAutoThreshold("Li dark");
		getThreshold(lower, upper);
		setThreshold(lower, upper);
	} else {
		// Manual/interactive threshold selection
		run("Threshold...");
		waitForUser("Select Marker PhenotypeThreshold");
		getThreshold(lower, upper);
		setThreshold(lower, upper);
	}

	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=1");
	run("Analyze Particles...", "size="+minSize+"-Infinity pixel circularity=0.00-1.00 show=Masks clear in_situ");
	
	selectWindow("roi");
	selectWindow(positiveIm);
	run("Restore Selection");
	run("Clear Outside");
	close("roi");
	
	run("Create Selection");
	Roi.getBounds(x, y, width, height);
	selectWindow(MyTitle);
	run("Restore Selection");
	Roi.move(pos[0]+x, pos[1]+y);
	Roi.setName("positive_"+(iteration));
	Roi.setStrokeColor("red");
	roiManager("Add");
	
	close(positiveIm);


}

function measureAndExportResults(MyTitle,markerIm, output, r, iteration) {
	/*
	* Measures Tissue  and positive areas from ROI Manager, calculates area ratios, and exports results to an Excel file.
	*
	* @param output   The directory path where the results file ("Total.xls") will be saved.
	* @param MyTitle  The label/title to associate with the current measurement in the results.
	* @param r        The pixel-to-micron conversion factor (scaling factor).
	*/
	
	
	// Measure Tissue  and positive areas
	run("Clear Results");
	close("Results");
	
	selectWindow(MyTitle);
	run("Duplicate...", "title=markerChannel ignore");
	run("Split Channels");
	close("*blue*");
	close("*green*");
	rename("markerChannel");
	run("Set Measurements...", "area mean standard redirect=None decimal=2");
	run("Set Scale...", "distance=1 known="+r+" unit=µm");
	 	 
	roiManager("deselect");
	roiManager("Measure");
	
	roiArea = getResult("Area", 0);
	Tm = getResult("Area", 1); // Tissue area in micra
	TmeanSignal = getResult("Mean", 1);
	TstdSignal = getResult("StdDev", 1);
	Pm = getResult("Area", 2); // Positive area in micra
	PmeanSignal = getResult("Mean", 2);
	PstdSignal = getResult("StdDev", 2);

	close("markerChannel");
	run("Clear Results");
	close("Results");
	
	// Calculate ratio of positive to Tissue  area
	rP = Pm / Tm;

	// Print results and save image
	resultsFile = output + "IF_TissuePhenotype_Manual_Results.xls";
	if (File.exists(resultsFile)) {
		open(resultsFile);
		IJ.renameResults("Results");
	}
	i = nResults;
	setResult("[Label]", i, MyTitle+"_ROI_"+(iteration)+"");
	setResult("ROI Area (um2)", i, roiArea);
	setResult("Tissue Area (um2)", i, Tm);
	setResult("Tissue Marker mean Signal", i, TmeanSignal);
	setResult("Tissue Marker std Signal", i, TstdSignal);
	setResult("Positive Area (um2)", i, Pm);
	setResult("Positive Marker mean Signal", i, PmeanSignal);
	setResult("Positive Marker std Signal", i, PstdSignal);
	setResult("Ratio AMarker/ATissue (%)", i, rP);
	saveAs("Results", resultsFile);
	
	
}

function visualizationAndExport(export, OutDir, MyTitleShort) {
	/*
	* Finalizes the visualization of ROI analysis and optionally exports the result as a JPEG image.
	*
	* @param {boolean} export - If true, exports the analyzed image as a JPEG file.
	* @param {string} OutDir - The output directory where the image will be saved.
	* @param {string} MyTitleShort - The base name for the output image file.
	*/
		RoiManager.associateROIsWithSlices(true);
		RoiManager.useNamesAsLabels(true);
		
		// Finalize visualization and export
		setBatchMode("exit and display");
		
		analyzedFile = OutDir + File.separator + MyTitleShort + "_analyzed.jpg";

		selectWindow(MyTitleShort);
		roiManager("Show All with labels");
		run("Flatten");
		if (export) {
			saveAs("Jpeg", analyzedFile);
		}
		close(MyTitleShort);
		rename(MyTitleShort);
	
}


