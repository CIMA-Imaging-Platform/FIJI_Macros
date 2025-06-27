
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
//	 parameter4="Background Compensation Method";
	 
	  
 //  2 Action tools:
		
	 buttom1="Im: Single File processing. Use Single file processing for fine tunning parameters";
	 buttom2="Dir: Batch Mode. Please tune parameters before using Batchmode";

//  OUTPUT

// Analyzed Images with ROIs

	excel="QuantificationResults_SiriusRedCardio.xls";
	
	feature1="Label";
	feature2="Tissue Area (um2)";
	feature3="Positive Area (um2)";
	feature4="Ratio Ared/Atissue (%)";
	
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
	    +"<ol><font size=2  i><li>"+buttom1+"</li></ol>"
	    +"<p><font size=3  i>PARAMETERS:</i></p>"
	    +"<ul id=list-style-3><font size=2  i>"
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li>"
	    +"<li>"+parameter3+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");
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
var globalMode = true;
var export = true;

call("ij.Prefs.set", "threshold.mode", "Over/Under");

// Macro for processing a single file
macro "WSI_SiriusRed Action Tool 1 - Cf00T2d15IT6d10m" {
	
	close("*");
	roiManager("Deselect");
	run("Fresh Start");
	
		
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
	//Dialog.addRadioButtonGroup("Choose background compensation for sirius red", modeArray, 1, 2, "Tissue correction");
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
	sr("-", "-", name, r, th_tissue, redThreshold, export,minSize);
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

function sr(output,InDir,name,r,th_tissue,redThreshold,export,minSize)
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
	
	close("*");
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
	/*if (corrType == "Global correction") {
	    globalMode = true;
	} else {
	    globalMode = false;
	}*/
	
	
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
	run("Options...", "iterations=1 count=1");
	
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
	selectWindow("orig");
	setBatchMode("show");
	
	// Retrieve image dimensions and set properties such as pixel width and height
	run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=" + r + " pixel_height=+" + r + " voxel_depth=1.0000 frame=[0 sec] origin=0,0");
		
	// Prompt the user to load previous ROIs or start a new segmentation
	loadROIs = getBoolean("Load previous Tissue ROIs?");
	
	// If the user chooses to load previous ROIs
	if (loadROIs) {
		
	    // Open the ROI set file
	    roiManager("Open", OutDir + File.separator + MyTitle_short + "_RoiSet_Cardio.zip");
	    // Select the first ROI and create a mask
	    roiManager("select", 0);
	    run("Create Mask");
	    rename("tissueMask");
	    // Delete the selected ROI
	    roiManager("select", 1);
	    roiManager("delete");
	    
	} else {
	    
	    // If the user chooses to start a new segmentation
	    
	    // Detect background automatically or manually
	    automatic = getBoolean("Select Segmentation Workflow", "Automatic", "Manual");
	    
	    // If automatic segmentation is chosen
	    if (automatic) {
	        // Duplicate image and split channels
	        run("Duplicate...", "title=[lum]");
	        run("Split Channels");
	        selectWindow("lum (blue)");
	        close();
	        selectWindow("lum (red)");
	        close();
	        selectWindow("lum (green)");
	        rename("tissueMask");
	        	    	
	        // Preprocess and segment background
	        //setAutoThreshold("Huang");
	        setThreshold(0, th_tissue);
	        setOption("BlackBackground", false);
	        run("Convert to Mask");
	        run("Median...", "radius=12");
	        run("Invert");
	        run("Open");
	        run("Analyze Particles...", "size=3000-Infinity pixel show=Masks in_situ");
	        run("Invert");
	        run("Analyze Particles...", "size=50000-Infinity pixel show=Masks in_situ");
	        run("Create Selection");
	        
	        selectWindow("orig");
	        run("Restore Selection");
	        
	        // Call the function to delete unwanted ROIs
	        deleteROIsFun("tissueMask", "orig");
	        
	        // Set ROI name and add it to the ROI manager
	        Roi.setName("Tissue");
	        roiManager("Add");
	        selectWindow("tissueMask");
	        close();
	        
	    } else {
	        // If manual segmentation is chosen
	        
	        // Prompt the user to draw tissue manually
	        waitForUser("Draw Tissue Manually");
	        roiManager("Add");
	        run("Select All");
	        
	        // Duplicate image and split channels
	        run("Duplicate...", "title=[lum]");
	        run("Split Channels");
	        selectWindow("lum (blue)");
	        close();
	        selectWindow("lum (red)");
	        close();
	        selectWindow("lum (green)");
	        rename("tissueMask");
	        
	        // Preprocess and segment background
	        setAutoThreshold("Huang");
	        //th_tissue = 200;
	        setThreshold(0, th_tissue);
	        setOption("BlackBackground", false);
	        run("Convert to Mask");
	        run("Median...", "radius=12");
	        run("Invert");
	        run("Open");
	        run("Analyze Particles...", "size=3000-Infinity pixel show=Masks in_situ");
	        run("Invert");
	        roiManager("select", 0);
	        run("Clear Outside");
	        	        
	        // Call the function to delete unwanted ROIs
	        deleteROIsFun("tissueMask", "orig");
	        
	        // Set ROI name and add it to the ROI manager
	        Roi.setName("Tissue");
	        roiManager("Add");
	        selectWindow("tissueMask");
	        close();
	        
    	    // Delete the first ROI from the ROI manager
	    	roiManager("select", 0);
	    	roiManager("delete");
	                
	    }

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
	//if (globalMode) {
    
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
    
	/*} else {
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
	*/
	
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
	setThreshold(0, lower);
	//setThreshold(0, redThreshold);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	close("Threshold");
	
	selectWindow("positive");
	setBatchMode("hide");	
	deleteROIsFun("positive","orig");
	
	// Analyze particles and measure tissue and positive areas
	selectWindow("positive");
	run("Analyze Particles...", "size="+minSize+"-Infinity pixel circularity=0.00-1.00 show=Masks clear in_situ");
	selectWindow("positive");
	run("Create Selection");
	Roi.setName("SRpositive");
	roiManager("Add");
	
	// Save red areas in tissue
	roiManager("Save", OutDir + File.separator + MyTitle_short + "_RoiSet_Cardio.zip");

	// Measure tissue and positive areas
	run("Clear Results");
	selectWindow("positive");
	run("Set Measurements...", "area mean modal area_fraction redirect=None decimal=2");
	selectWindow("orig");
	roiManager("select", 0);
	roiManager("Measure");
	selectWindow("orig");
	roiManager("select", 1);
	roiManager("Measure");
	Tm = getResult("Area", 0); // Tissue area in micra
	Pm = getResult("Area", 1); // Positive area in micra
	
	// Calculate ratio of positive to tissue area
	T = Tm / (r * r);
	P = Pm / (r * r);
	r1 = Pm / Tm * 100;
	
	selectWindow("positive");
	run("Close");
	
	run("Clear Results");

	// Print results and save image
	if (File.exists(output + "QuantificationResults_SiriusRedCardio.xls")) {
	    open(output + "QuantificationResults_SiriusRedCardio.xls");
	    IJ.renameResults("Results");
	}
	i = nResults;
	setResult("[Label]", i, MyTitle);
	setResult("Tissue Area (um2)", i, Tm);
	setResult("Positive Area (um2)", i, Pm);
	setResult("Ratio Ared/Atissue (%)", i, r1);
	saveAs("Results", output + "QuantificationResults_SiriusRedCardio.xls");
		
	// Finalize visualization and export
	setBatchMode("exit and display");
	selectWindow("orig");
	roiManager("Show None");
	roiManager("Select", 0);
	roiManager("Set Color", "yellow");
	roiManager("Set Line Width", 3);
	run("Flatten");
	roiManager("Show None");
	roiManager("Select", 1);
	roiManager("Set Color", "green");
	roiManager("Set Line Width", 2);
	run("Flatten");
	if (export) {
	    saveAs("Jpeg", OutDir + File.separator + MyTitle_short + "_analyzed_Cardio.jpg");
	}
	rename(MyTitle_short + "_analyzed_Cardio");
	selectWindow("orig");
	close();
	setTool("zoom");
	selectWindow("orig-1");
	close();
	close("\\Others");
	
	
	// Close opened images if necessary
	if (InDir != "-") {
	    close();
	}

}


function deleteROIsFun(Mask, orig) {
	
	selectWindow(Mask);
	run("Create Selection");
    selectWindow(orig);
    run("Restore Selection");
	
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
            exit();
        }
        
        // Apply the selection to the mask image
        selectWindow(Mask);
        //setBatchMode("show");
        run("Restore Selection");
        setForegroundColor(255,255,255);
        run("Fill", "slice");
        run("Create Selection");
        
        // Apply the selection to the original image
        selectWindow(orig);
        run("Restore Selection");
        //showMessage("Selection deleted");
        
        // Prompt the user to delete another ROI
        selectWindow(orig);
        deleteROIs = getBoolean("Do you want to Delete other Detected Regions");
    }
}




