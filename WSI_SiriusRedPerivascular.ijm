
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
 //  	- save and load previous ROIS --> todo
 //*    - Interactive Threshold. --> done
 //*	- Delete Unwanted tissue and SR positive--> done
 //		- Single File and Batch Mode --> done
 //*    
 // Important Parameters: 
 
 	 parameter1="Resolution (micra pixel ratio) = 0.502 micras/pixel xy"; 
	 parameter2="Tissue Threshold (0-255) = Separate Tissue from Background";
	 parameter3="Sirius Red Threshold (0-255): Visual Interactive ";
	 parameter4="Background Compensation Method";
	 
	  
 //  2 Action tools:
		
	 buttom1="Im: Single File processing. Use Single file processing for fine tunning parameters";
	 buttom2="Dir: Batch Mode. Please tune parameters before using Batchmode";

//  OUTPUT

// Analyzed Images with ROIs

	excel="SiriusRed_QuantificationResults.xls";
	
	feature1="Label";
	feature2="Tissue Area (um2)";
	feature3="Positive Area (um2)";
	feature4="Ratio AreaSiriusRed/Atissue (%)";
	
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
    + "<h3>Developed for</h3>"
    + "<p><i>INPUT IMAGES</i></p>"
    + "<ul>"
    + "<li>" + imageAdquisition + "</li>"
    + "<li>" + imageType + "</li>"
    + "<li>" + voxelSize + "</li>"
    + "<li>" + format + "</li>"
    + "</ul>"
    +"<p><font size=3 i>Action tools (Buttons)</i></p>"
    +"<ol><font size=2  i><li>"+buttom1+"</li></ol>"
    +"<p><font size=3  i>PARAMETERS:</i></p>"
    +"<ul id=list-style-3><font size=2  i>"
    +"<li>"+parameter1+"</li>"
    +"<li>"+parameter2+"</li>"
    +"<li>"+parameter3+"</li>"
    +"<li>"+parameter4+"</li></ul>"
    +"<p><font size=3  i>Quantification Results: </i></p>"
    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
    +"<p><font size=3  i>Excel "+excel+"</i></p>"
    +"<ul id=list-style-3><font size=2  i>"
    +"<li>"+feature1+"</li>"
    +"<li>"+feature2+"</li>"
    +"<li>"+feature3+"</li>"
    +"<li>"+feature4+"</li>"
    +"</ul>"
    +"<h0><font size=5></h0>");
	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
	   
}



// Changelog October 2021
// Added batch processing of a directory
// Included Sirius Red detection from color deconvolution

// Define default parameters
var r = 0.502;
var th_tissue = 200;
var redThreshold = 80;
var minSize=100;
var globalMode = false;
var export = true;

setOption("WaitForCompletion", true);
setOption("ExpandableArrays", true);

// Macro for processing a single file
macro "WSI_SiriusRed_Perivascular Action Tool 1 - Cf00T2d15IT6d10m" {
	
	close("*");
	
	macroInfo();
	
	// Select a single file
	name = File.openDialog("Select File");
	
	// Display parameter dialog
	Dialog.create("Parameters");
	Dialog.addMessage("Choose parameters");
	Dialog.addNumber("micra/px ratio", r);
	Dialog.addNumber("Tissue threshold", th_tissue);
	Dialog.addMessage("Sirius Red detection parameters");
	Dialog.addNumber("Sirius Min Size ", minSize);
	//Dialog.addNumber("Red threshold", redThreshold);
	modeArray = newArray("Global correction", "Tissue correction");
	Dialog.addRadioButtonGroup("Choose background compensation for sirius red", modeArray, 1, 2, "Tissue correction");
	Dialog.addCheckbox("Export analyzed image", export); 
	Dialog.show();
	
	// Get parameter values from dialog
	r = Dialog.getNumber();
	th_tissue = Dialog.getNumber();
	minSize=Dialog.getNumber();
	//redThreshold = Dialog.getNumber();
	corrType = Dialog.getRadioButton();
	export = Dialog.getCheckbox();
	
	// Perform Sirius Red detection
	sr("-", "-", name, r, th_tissue, redThreshold,corrType, export,minSize);
	close("positive");
	showMessage("Done!");
}

/*
// Macro for batch processing of a directory
macro "WSI_SiriusRed Action Tool 2 - C00fT0b11DT9b09iTcb09r" {
	
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
	corrType = Dialog.getRadioButton();
	export = Dialog.getCheckbox();

	// Process each file in the directory
	for (j = 0; j < L; j++) {
		if (endsWith(list[j], "tif") || endsWith(list[j], "jpg")) {
			// Analyze file
			name = list[j];
			print(name);
			sr(InDir, InDir, list[j], r, th_tissue, redThreshold,corrType, export,minSize);
		}
	}
	close("positive");
	showMessage("Done!");
}

*/

function sr(output,InDir,name,r,th_tissue, redThreshold,corrType,export,minSize)
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
	
	run("Collect Garbage");
	
	// Image Opening and Global Correction Mode Setting
	if (InDir == "-") {
	    // If input directory is not specified, open the image directly
	    open(name);
	} else {
	    // If input directory is specified, check if the image is already open, if not, open it
	    if (!isOpen(InDir + name)) {
	        open(InDir + name);
	    }
	}
	
	// Determine whether to apply global or tissue-specific background correction
	if (corrType == "Global correction") {
	    globalMode = true;
	} else {
	    globalMode = false;
	}
	
	
	// Initialize ROI Manager, clear results, and set up output directories
	roiManager("Reset");
	run("Clear Results");
	MyTitle = getTitle();
	output = getInfo("image.directory");
	run("Colors...", "foreground=black background=white selection=green");
	OutDir = output + File.separator + "AnalyzedImages";
	File.makeDirectory(OutDir);
	aa = split(MyTitle, ".");
	MyTitle_short = aa[0];
	setBatchMode(true);
	run("Select All");

	//downsampling in case >2GB
	getDimensions(width, height, channels, slices, frames);
	sizeBytes=getValue("image.size");
	sizeMB=(sizeBytes/(pow(2,20)));

	if (sizeMB > 2048){
		run("Scale...", "x=0.5 y=0.5 width="+floor(width/2)+" height="+floor(height/2)+" interpolation=None average create title=orig");
		r=r*2;
	}else{
		run("Duplicate...", "title=orig");
	}
	close(MyTitle);
	setBatchMode("exit and display");
	
	// Retrieve image dimensions and set properties such as pixel width and height
	run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=" + r + " pixel_height=+" + r + " voxel_depth=1.0000 frame=[0 sec] origin=0,0");
	run("Set Measurements...", "area mean modal area_fraction redirect=None decimal=2");
	run("Options...", "iterations=1 count=1");
	
	// Prompt the user to load previous ROIs or start a new segmentation
	loadROIs = getBoolean("Load previous Vessels ROIs?");
	
	// If the user chooses to load previous ROIs
	if (loadROIs) {
	    // Open the ROI set file
	    roiManager("Open", OutDir + File.separator + MyTitle_short + "_RoiSet_Perivascular.zip");
	    // Select the first ROI and create a mask
	    roiManager("select", 0);
	    run("Create Mask");
	    rename("vesselsMask");
	    // Delete the selected ROI
	    roiManager("select", 1);
	    roiManager("delete");
	} else {
	   
	    // If the user chooses to start a new segmentation
	    
	    // Duplicate image and split channels
        run("Duplicate...", "title=[vesselsMask]");
       	run("8-bit");
       	run("Select All");
  		setForegroundColor(255,255,255);
  		run("Fill");
    	setForegroundColor(0,0,0);
    	run("Convert to Mask");

		// Prompt the user to draw tissue manually
        selectWindow("orig");
        addROIsFun("vesselsMask", "orig");
        
        // Set ROI name and add it to the ROI manager
        Roi.setName("Vessels");
        roiManager("Add");
                                               
    }

	// Separate colors using color deconvolution
	showStatus("Separating colors...");
	selectWindow("orig");
	run("Select All");
	run("Duplicate...", "title=c");
	run("Select All");
	run("Colour Deconvolution", "vectors=[User values] hide [r1]=0.09617791 [g1]=0.6905216 [b1]=0.7168889 [r2]=0.12630461 [g2]=0.2563811 [b2]=0.958288 [r3]=0.8249893 [g3]=0.5651483 [b3]=0.001");
	close("c-(Colour_2)");
	close("c-(Colour_3)");
	close("c");
	selectWindow("c-(Colour_1)");
	rename("positive");
		
	// Correcting background and processing red channel
	showStatus("Correcting background...");
	
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
	}
	
	close("Results");
	
	
	// Detecting Sirius red-positive regions
	selectWindow("positive");
	setBatchMode("show");
	showStatus("Detecting sirius red...");
	run("Threshold...");
	setOption("BlackBackground", true);
	call("ij.process.ImageProcessor.setUnderColor", 0,255,0);
	call("ij.process.ImageProcessor.setOverColor", 255,255,255);
	call("ij.plugin.frame.ThresholdAdjuster.setMode", "Over/Under");
	waitForUser("Select PicoSirius Red Threshold");
	getThreshold(lower, upper);
	setThreshold(lower, upper);
	//setThreshold(0, redThreshold);
	run("Convert to Mask");
	
	run("Invert");
	run("Median...", "radius=1");
	roiManager("select", "tissue");
	
	run("Colors...", "foreground=white background=black selection=green");
	run("Clear Outside");
	run("Colors...", "foreground=black background=white selection=green");
	run("Create Selection");
	selectWindow("orig");
	run("Restore Selection");
	setBatchMode("exit and display");
	setBatchMode(false);

	// Analyze particles and measure tissue and positive areas
	selectWindow("positive");
	run("Analyze Particles...", "size="+minSize+"-Infinity pixel circularity=0.00-1.00 show=Masks clear in_situ");
	selectWindow("positive");
	run("Create Selection");
	Roi.setName("SRpositive");
	roiManager("Add");
	
	
	// Save red areas in tissue
	roiManager("Save", OutDir + File.separator + MyTitle_short + "_RoiSet_Perivascular.zip");
		
	run("Clear Results");
	roiManager("reset");
	run("Set Measurements...", "area mean modal area_fraction redirect=None decimal=2");
	selectWindow("vesselsMask");
	run("Select None");
	run("Analyze Particles...", "show=Masks clear add in_situ");
	roiManager("measure");
	
	
	
	areaVessel=Table.getColumn("Area","Results");
	//Array.print(areaVessel);
	
	run("Clear Results");
	selectWindow("positive");
	run("Select None");
	roiManager("measure");
	
	
	areaPositive=Table.getColumn("Area");
	//Array.print(areaPositive);
	ratio=Table.getColumn("%Area");
	//Array.print(ratio);
	
	/* Measure tissue and positive areas
	Tm = getResult("Area", 0); // Tissue area in micra
	Pm = getResult("Area", 1); // Positive area in micra
	
	// Calculate ratio of positive to tissue area
	T = Tm / (r * r);
	P = Pm / (r * r);
	r1 = Pm / Tm * 100;
	
	
	selectWindow("positive");
	setBatchMode(false);
	run("Close");
	*/
	run("Clear Results");

	for (i = 0; i < lengthOf(areaVessel); i++) {
		
		// Print results and save image
		if (File.exists(output + "Quantification_SiriusRed_Perivascular.xls")) {
		    open(output + "Quantification_SiriusRed_Perivascular.xls");
		    IJ.renameResults("Results");
		}
		
		j = nResults;
		setResult("[Label]", j, MyTitle+"_Vessel_"+i+1);
		setResult("Vessel Area (um2)",j, areaVessel[i]);
		setResult("Positive Area (um2)",j, areaPositive[i]);
		setResult("Ratio Ared/Atissue (%)",j, ratio[i]);
		saveAs("Results", output + "Quantification_SiriusRed_Perivascular.xls");

	}
	
	
	
	// Finalize visualization and export
	setBatchMode("exit and display");
	selectWindow("orig");
	roiManager("Show None");
	roiManager("Show All");
	roiManager("Set Color", "yellow");
	roiManager("Set Line Width", 3);
	run("Flatten");
	close("orig");
	roiManager("Show None");
	selectWindow("positive");
	run("Create Selection");
	selectWindow("orig-1");
	run("Restore Selection");
	roiManager("Set Color", "green");
	roiManager("Set Line Width", 2);
	run("Flatten");
	if (export) {
	    saveAs("Jpeg", OutDir + File.separator + MyTitle_short + "_analyzed_Perivascular.jpg");
	}
	rename(MyTitle_short + "_analyzed_Perivascular");
	close("\\Others");
	
	// Close opened images if necessary
	if (InDir != "-") {
	    close();
	}

}


function addROIsFun(Mask, orig) {
    // Loop to add multiple ROIs if desired
    addROIs = true;
    while (addROIs) {
        // Prompt the user to draw a ROI to delete
        setTool("freehand");
        selectWindow(orig);
        waitForUser("Please Draw Vessels ROI and press OK when ready");
      
        // Check if a selection is made
        type = selectionType();
        if (type == -1) {
            showMessage("Edition", "You should DRAW a REGION. Otherwise nothing will be added.");
            exit();
        }
        
        // Apply the selection to the mask image
        selectWindow(Mask);
        setBatchMode("show");
        run("Restore Selection");
        setForegroundColor(0, 0, 0);
        run("Fill", "slice");
        run("Create Selection");
        
        // Apply the selection to the original image
        selectWindow(orig);
        run("Restore Selection");
        
        // Prompt the user to add another ROI
        selectWindow(orig);
        addROIs = getBoolean("Do you want to add other Detected Regions");
    }
}


function deleteROIsFun(Mask, orig) {
    // Loop to delete multiple ROIs if desired
    deleteROIs = getBoolean("Do you want to Delete other Detected Regions");
    while (deleteROIs) {
        // Prompt the user to draw a ROI to delete
        setTool("freehand");
        waitForUser("Please Draw ROI to delete and press OK when ready");
        
        // Check if a selection is made
        type = selectionType();
        if (type == -1) {
            showMessage("Edition", "You should DRAW a REGION. Otherwise nothing will be deleted.");
            
        }else{
        
	        // Apply the selection to the mask image
	        selectWindow(Mask);
	        setBatchMode("show");
	        run("Restore Selection");
	        setForegroundColor(255, 255, 255);
	        run("Fill", "slice");
	        run("Create Selection");
	        
	        // Apply the selection to the original image
	        selectWindow(orig);
	        run("Restore Selection");
	         
	        // Prompt the user to delete another ROI
	        selectWindow(orig);
	        deleteROIs = getBoolean("Do you want to Delete other Detected Regions");
        }
    }
}




