function macroInfo(){
	
// * Quantification of Sirius Red IHC on WSI Images Area  
// * Target User: General
// *  

	scripttitle= "Quantification of Sirius Red IHC WSImages";
	version= "1.02";
	date= "2023";
	

// *  Tests Images:

	imageAdquisition="Aperio: BrightField Whole Slide Imaging Images.";
	imageType="RGB";  
	voxelSize="Voxel size:  0.502 um xy";
	format="Format: Uncompressed .jpg";   
 
 //*  GUI User Requierments:
 //*    - Interactive Threshold. --> done
 //*	- Delete Unwanted done --> done
 //*    - save and load previous ROIS --> todo
 //		- Single File and Batch Mode --> done
 //*    
 // Important Parameters: 
 
 	 parameter1="Resolution (micra pixel ratio) = 0.502 micras/pixel xy"; 
	 parameter2="Tissue Threshold (8bit) = Separate Tissue from Background";
	 parameter3="Sirius Red Threshold (8bit): Visual Interactive ";
	 parameter4="Background Compensation Method";
	 
	  
 //  2 Action tools:
		
	 buttom1="Im: Single File processing. Use Single file processing for fine tunning parameters";
	 buttom2="Dir: Batch Mode. Please tune parameters before using Batchmode";

//  OUTPUT

// Analyzed Images with ROIs

	excel="QuantificationResults_SiriusRed.xls";
	
	feature1="Label";
	feature2="Tissue Area (um2)";
	feature3="Positive Area (um2)";
	feature4="Ratio Ared/Atissue (%)";
	feature5="Inflammation (um2)";
	
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
	    +"<p><font size=3  i>PARAMETERS:</i></p>"
	    +"<ul id=list-style-3><font size=2  i>"
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li>"
	    +"<li>"+parameter3+"</li>"
	    +"<li>"+parameter4+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li><li>"+feature5+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}


// Define default parameters
var r = 0.502;
var th_tissue = 200;
var redThreshold = 80;
var minSize=20;
var corrType = "Global correction";
var export = true;

// Macro for processing a single file
macro "SiriusRed_batch Action Tool 1 - Cf00T2d15IT6d10m" {
	
	close("*");
	
	 macroInfo();
	
	// Select a single file
	name = File.openDialog("Select File");
    open(name);
    
	// Display parameter dialog
	Dialog.create("Parameters");
	Dialog.addMessage("Choose parameters");
	Dialog.addNumber("micra/px ratio", r);
	Dialog.addNumber("Tissue threshold", th_tissue);
	Dialog.addMessage("Sirius Red detection parameters");
	Dialog.addNumber("Sirius Min Size ", minSize);
	//Dialog.addNumber("Red threshold", redThreshold);
	//modeArray = newArray("Global correction", "Tissue correction");
	//Dialog.addRadioButtonGroup("Choose background compensation for sirius red", modeArray, 1, 2, "Global correction");
	Dialog.addCheckbox("Export analyzed image", export); 
	Dialog.show();
	
	// Get parameter values from dialog
	r = Dialog.getNumber();
	th_tissue = Dialog.getNumber();
	minSize=Dialog.getNumber();
	//redThreshold = Dialog.getNumber();
	//corrType = Dialog.getRadioButton();
	export = Dialog.getCheckbox();
	
	// Perform Sirius Red detection
	analyzeSiriusRedImage("-", "-", name, r, th_tissue, redThreshold,corrType, export,minSize);
	showMessage("Done!");
}


// Macro for batch processing of a directory
macro "SiriusRed_batch Action Tool 2 - C00fT0b11DT9b09iTcb09r" {
	
	close("*");
	
	 macroInfo();
	
	// Select a directory
	InDir = getDirectory("Choose a Directory");
	list = getFileList(InDir);
	L = lengthOf(list);

	// Display parameter dialog
	Dialog.create("Parameters");
	Dialog.addMessage("Choose parameters");
	Dialog.addNumber("micra/px ratio", r);
	Dialog.addNumber("Tissue threshold", th_tissue);
	Dialog.addMessage("Sirius Red detection parameters");
	Dialog.addNumber("Red threshold", redThreshold);
	Dialog.addNumber("Sirius Min Size ", minSize);
	modeArray = newArray("Global correction", "Tissue correction");
	Dialog.addRadioButtonGroup("Choose background compensation for sirius red", modeArray, 1, 2, "Tissue correction");
	Dialog.addCheckbox("Export analyzed image", export); 
	Dialog.show();
	
	// Get parameter values from dialog
	r = Dialog.getNumber();
	th_tissue = Dialog.getNumber();
	redThreshold = Dialog.getNumber();
	minSize=Dialog.getNumber();
	//corrType = Dialog.getRadioButton();
	export = Dialog.getCheckbox();

	// Process each file in the directory
	for (j = 0; j < L; j++) {
		if (endsWith(list[j], "tif") || endsWith(list[j], "jpg")) {
			// Analyze file
			name = list[j];
			print(name);
			analyzeSiriusRedImage(InDir, InDir, list[j], r, th_tissue, redThreshold,corrType, export,minSize);
		}
	}
	showMessage("Done!");
}


function analyzeSiriusRedImage(output,InDir,name,r,th_tissue, redThreshold,corrType,export,minSize)
{
	
	// Performs Sirius Red detection and analysis.
	// 
	// Parameters:
	// - output: Output directory for saving analyzed images and results.
	// - InDir: Input directory where the image is located.
	// - name: Name of the image file.
	// - r: Micra/pixel ratio.
	// - th_tissue: Tissue threshold value.
	// - redThreshold: Red threshold value for Sirius Red detection.
	// - corrType: Type of background compensation ("Global correction" or "Tissue correction").
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
	
	// Image Setup and Preprocessing
	run("Select All");
	roiManager("Reset");
	
	// Determine whether to apply global or tissue-specific background correction
	if (corrType == "Global correction") {
	    globalMode = true;
	} else {
	    globalMode = false;
	}
	
	
	// Detecting background
	run("Select All");

	Dialog.create("Region of Interest");
	Dialog.addMessage("Choose ROI selection method:");
	Dialog.addRadioButtonGroup("Segmentation mode", newArray("Automatic", "Manual"), 1, 2, "Automatic");
	Dialog.show();
	segMode = Dialog.getRadioButton();

	run("Roi Defaults...", "color=blue stroke=0 group=0");
	
	setBatchMode(false);
	
	iteration=1;
	
	if (segMode == "Manual") {
		
		nextROI = true ; 

		while (nextROI) {
			
			getROI(segMode,MyTitleShort,iteration);

			processROI(iteration, MyTitleShort, MyTitleShort, output, r, segMode, redThreshold, minSize, globalMode, export, OutDir);
			
			choice = getBoolean("Do you want to draw another ROI?");

			if (!choice) {
				nextROI = false;
			}else{
				iteration++;
			}
			
		}
	} else {
			
			getROI(segMode,MyTitleShort,iteration);
			processROI(iteration, MyTitleShort, MyTitleShort, output, r, segMode, redThreshold, minSize, globalMode, export, OutDir);
	}


	//deleteUnwantedROIs(MyTitle);
}

function getROI(segMode,image,iteration) {

		/*
		 * Segments tissue regions in an image using either automatic or manual methods.
		 * @param image      The input image to be processed for tissue segmentation. expects RGB image
		 */
		
		selectWindow(image);
		
	
		if (segMode == "Automatic") {
			
			run("Select All");
			Roi.setName("ROI__1");
			roiManager("Set Color", "blue");
			roiManager("Add");
		
				
		} else {
			// Manual ROI addition
			waitForUser("Manual ROI", "Draw your Region of Interest and then press OK when finished.");
			// Optionally, you can check if at least one ROI is present:
			type = selectionType() ;
			if (type != -1) {
				Roi.setName("ROI_"+iteration);
				Roi.setStrokeColor("blue");
				roiManager("Add");
				
			}else{
				showMessage("No ROIs", "No ROIs were added. Please try again.");
				exit();
			}
			
		}

	return segMode
}


function processROI(iteration, orig, MyTitleShort, output, r, segMode, redThreshold, minSize, globalMode, export, OutDir) {
	/*
	* Processes a single Region of Interest (ROI) for Sirius Red quantification.
	*
	* @param {int} i - Index of the ROI to process.
	* @param {string} orig - Title of the original image.
	* @param {string} MyTitleShort - Shortened title for output naming.
	* @param {string} output - Output file or directory for results.
	* @param {int} r - Current ROI index or identifier.
	* @param {string} segMode - Segmentation mode to use for tissue detection.
	* @param {int} redThreshold - Threshold value for Sirius Red detection.
	* @param {int} minSize - Minimum size for detected regions to be considered.
	* @param {boolean} globalMode - Whether to use global background correction.
	* @param {boolean} export - Whether to export visualization images.
	* @param {string} OutDir - Output directory for exported images.
	*/


	roiManager("select", 0);
	Roi.getBounds(x, y, width, height);
	pos = newArray(x, y);
	Array.print(pos);
	run("Duplicate...", "title=roi");

	// Detecting Tissue regions
	segmentTissue(MyTitleShort, "roi", pos, iteration,th_tissue);
		
	// Perform color deconvolution and extract the positive channel
	positiveIm = colorDeconvolution("roi");

	// Function to correct background in the positive channel
	correctBackground(positiveIm, globalMode);
		
	// Detecting Sirius red-positive regions
	segmentSiriusRed(MyTitleShort, positiveIm, segMode, pos, redThreshold, iteration, minSize);
	
	// Segment inflamation background region whithin positive.
	segmentInfamation(MyTitleShort,"background", positiveIm,pos);

	// Quantify mask areas
	measureAndExportResults(MyTitleShort, output, r, iteration);
	
	
	
	// export laballed image
	visualizationAndExport(export, OutDir, MyTitleShort);
		
	run("Clear Results");
	roiManager("reset");
	
	
}


	
function segmentTissue(orig,roi,pos,iteration,th_tissues) {
	/*
	 * Segments tissue regions in the given image using the Huang threshold on the blue channel.
	 *
	 * @param image      The input image to be processed for tissue segmentation (expects RGB image).
	 * @param th_tissue  The upper threshold value for tissue segmentation.
	 * @return           None. Adds the tissue ROI to the ROI Manager.
	 */
	
	/*
	orig = "orig";	
	roi = "roi";
	pos=newArray(726,204);
	Roi.move(pos[0], pos[1]);
	iteration = 0;
	*/
	
	selectImage(roi);
	run("Duplicate...", "title=blueChannel");
	run("Split Channels");
	selectImage("blueChannel (green)");
	close();
	selectImage("blueChannel (red)");
	close();
	selectImage("blueChannel (blue)");
	
	
	//run("Brightness/Contrast...");
	run("Enhance Contrast", "saturated=0.35");
	run("Apply LUT");
	
	correctBackground("blueChannel (blue)", true);
	
	// Automatic segmentations
	setAutoThreshold("Huang");
	setThreshold(0, th_tissue);
	getThreshold(lower, upper);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=3");
	run("Open");
	run("Analyze Particles...", "size=50-Infinity pixel circularity=0.00-1.00 show=Masks clear in_situ");
	selectWindow(roi);
	selectImage("blueChannel (blue)");
	run("Restore Selection");
	
	run("Clear Outside");
	selectImage("blueChannel (blue)");
	run("Create Selection");
	Roi.getBounds(x, y, width, height);
	selectWindow(orig);
	run("Restore Selection");
	Roi.move(pos[0]+x, pos[1]+y);
	Roi.setName("Tissue_"+iteration);
	Roi.setStrokeColor("yellow");
	roiManager("Add");
	
	selectWindow("blueChannel (blue)");
	run("Select None");
	run("Invert");
	rename("background");
	run("Analyze Particles...", "size=20-Infinity pixel show=Masks exclude clear in_situ");

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


// Function to perform color deconvolution and extract the positive channel
function colorDeconvolution(MyTitle) {
	/*
	* Separates colors using color deconvolution and extracts the positive channel.
	* Closes unnecessary channels and renames the positive channel window.
	*
	* @param MyTitle  The title of the main image window.
	*/
		
	showStatus("Separating colors...");
	selectWindow(MyTitle);
	run("Colour Deconvolution2", "vectors=[User values]  simulated cross hide [r1]=0.09617791 [g1]=0.6905216 [b1]=0.7168889 [r2]=0.12630461 [g2]=0.2563811 [b2]=0.958288 [r3]=0.8249893 [g3]=0.5651483 [b3]=0.001");
	selectWindow(MyTitle + "-(Colour_2)");
	close();
	selectWindow(MyTitle + "-(Colour_3)");
	close();
	selectWindow(MyTitle + "-(Colour_1)");
	rename("positive");
	positiveIm = "positive";
	

	return positiveIm;
}

function correctBackground(image,globalMode) {

		/*
		* Corrects the background intensity of the current image, either globally or within a selected tissue region.
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
			// Apply tissue-specific background correction
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



function segmentSiriusRed(MyTitle,positiveIm,segMode,pos,redThreshold,iteration,minSize) {
	/*
	 * Detects Sirius red-positive regions in the current image window.
	 * Allows user to interactively select threshold, then creates a mask and ROI.
	 *
	 * @param MyTitle      The title of the main image window.
	 * @param x, y         Coordinates to move overlay (optional, for ROI placement).
	 * @param positiveIm   A string, should be "positive", indicating that the function will detect and process Sirius red-positive regions.
	 * @param redThreshold Default threshold value (not used if user selects interactively).
	 * @param segMode      Segmentation mode: "Automatic" applies Otsu threshold, "Manual" lets user select threshold interactively.
	 * 
	 */

	selectWindow(positiveIm);
	setBatchMode("show");
	showStatus("Detecting sirius red...");

	if (segMode == "Automatic") {
				
		// If segmentation mode is Automatic, use Otsu thresholding
		setAutoThreshold("Otsu");
		getThreshold(lower, upper);
		setThreshold(lower, upper);
	} else {
		// Manual/interactive threshold selection
		run("Threshold...");
		waitForUser("Select PicoSirius Red Threshold");
		getThreshold(lower, upper);
		setThreshold(lower, upper);
	}

	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=1");
	run("Analyze Particles...", "size="+minSize+"-Infinity pixel circularity=0.00-1.00 show=Masks clear in_situ");
	
	
	selectWindow("roi");
	selectWindow("positive");
	run("Restore Selection");
	run("Clear Outside");
	close("roi");
	
	run("Create Selection");
	Roi.getBounds(x, y, width, height);
	selectWindow(MyTitle);
	run("Restore Selection");
	Roi.move(pos[0]+x, pos[1]+y);
	Roi.setName("positive_"+(iteration));
	Roi.setStrokeColor("green");
	roiManager("Add");


}


function segmentInfamation(MyTitle,background, positiveIm,pos) {
	/*
	 * Segments inflammation regions in the current image window.
	 * This function allows the user to interactively select a threshold, then creates a mask and ROI for inflammation detection.
	 *
	 * @param background   The background image or mask to use for reference.
	 * @param positiveIm   The image containing positive staining to be analyzed for inflammation.
	 */
	
	selectWindow(positiveIm);
	run("Duplicate...", "title=filledTissue");
	run("Select None");
	
	run("Morphological Filters", "operation=Closing element=Disk radius=6");
	close("filledTissue");
	rename("filledTissue");
	run("Fill Holes");
	imageCalculator("AND create", "filledTissue","background");
	rename("inflamation");
	run("Create Selection");
	Roi.getBounds(x, y, width, height);
	selectWindow(MyTitle);
	run("Restore Selection");
	Roi.move(pos[0]+x, pos[1]+y);
	Roi.setName("inflamation_"+(iteration));
	Roi.setStrokeColor("black");
	run("Add to Manager");
	close("filled*");
	close(background);
	close("inflamation");
	close(positiveIm);
		

}



function measureAndExportResults(MyTitle, output, r, iteration) {
	/*
	* Measures tissue and positive areas from ROI Manager, calculates area ratios, and exports results to an Excel file.
	*
	* @param output   The directory path where the results file ("Total.xls") will be saved.
	* @param MyTitle  The label/title to associate with the current measurement in the results.
	* @param r        The pixel-to-micron conversion factor (scaling factor).
	*/
	
		
	// Measure tissue and positive areas
	run("Clear Results");
	close("Results");
	
	selectWindow(MyTitle);
	run("Set Measurements...", "area redirect=None decimal=2");
	run("Set Scale...", "distance=1 known="+r+" unit=µm");
	
	roiManager("deselect");
	roiManager("Measure");
	
	roiArea = getResult("Area", 0);
	Tm = getResult("Area", 1); // Tissue area in micra
	Pm = getResult("Area", 2); // Positive area in micra
	inflamation = getResult("Area", 3); // Positive area in micra

	run("Clear Results");
	close("Results");
	
	// Calculate ratio of positive to tissue area
	rP = (Pm / Tm)*100;

	// Print results and save image
	resultsFile = output + "WSI_SiriusRed_Manual_Results.xls";
	if (File.exists(resultsFile)) {
		open(resultsFile);
		IJ.renameResults("Results");
	}
	i = nResults;
	setResult("[Label]", i, MyTitle+"_ROI_"+(iteration)+"");
	setResult("ROI Area (um2)", i, roiArea);
	setResult("Tissue Area (um2)", i, Tm);
	setResult("Positive Area (um2)", i, Pm);
	setResult("Inflamation Area (um2)",i,inflamation);
	setResult("Ratio Ared/Atissue (%)", i, rP);
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


