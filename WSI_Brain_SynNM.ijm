/**/

function macroInfo(){

// * Quantification of Brown WSI Images Area  
// * Target User: General
// *  

	scripttitle= "Quantification of Brown Stained Area";
	version= "1.01";
	date= "2025";
	

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
	parameter3="NM Marker Threshold (0-255) = Separate Brown(+) ROIs from Brown(-) ROIs";
	parameter4="AlphaSyn Marker Threshold (0-255) = Separate Purple(+) ROIs from Purple(-) ROIs";
	parameter5="% Syn (minimum percent area for Syn positive) = Minimum % area for Syn positivity";
	 
 //  2 Action tools:
	 buttom1="Im: Single File processing";
	 buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs

	excel="WSI_Brain_Syn-NM_QuantificationResults.xls";
	feature1="Image Label";
	feature2="Tissue Area (micra^2)";
	feature3="NM Stained area (micra^2)";
	feature4="Alpha Syn Stained area (micra^2)";
	feature5="Ratio NM/Atissue (%)";
	feature6="Ratio AlphaSyn/Atissue (%)";

/*  	  
 *  version: 1.01 
 *  Author: Tomas Muñoz Santoro		  
 *  Date : 2025
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
		+"<li>"+parameter5+"</li></ul>"
		+"<p><font size=3  i>Quantification Results: </i></p>"
		+"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
		+"<p><font size=3  i>Excel "+excel+"</i></p>"
		+"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li><li>"+feature5+"</li><li>"+feature6+"</li></ul>"
		+"<h0><font size=5></h0>"
		+"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}


var r = 0.502;
var thTissue = 220;
var thNM = 100;
var thSyn = 150;
var minPer = 5;
	

macro "WSI_Brain_SynNM Action Tool 1 - Cf00T2d15IT6d10m" {
	/*  Processes a single histological slide image to detect regions 
	    (NM and alpha Synuclein ) and tissue. Prompts the user to select an image and adjust 
	    detection parameters before running the stain detection pipeline.
	
	Output:
	    - Executes `stainDetection` on the selected file.
	    - Saves results and annotated image according to the `stainDetection` output format.
	*/
	
	
	close("*");
	run("Fresh Start");
	
    macroInfo();
	
    // --- Select single image file ---
    name = File.openDialog("Select File");
	
    // --- Prompt user for parameters ---
    Dialog.create("Parameters");
    Dialog.addMessage("Choose parameters");
    Dialog.addNumber("micra/px ratio", r);
    items = newArray("Automatic","Manual ROI");
    Dialog.addChoice("Tissue Segmentation", items, "Manual ROI");
    Dialog.addNumber("Threshold for tissue detection", thTissue); 
    Dialog.addNumber("Threshold for Neuromelanin", thNM);  
    Dialog.addNumber("Threshold for AlphaSyn", thSyn);  
    Dialog.addNumber("% Syn", minPer);
    Dialog.show();
         
    r = Dialog.getNumber();
    tissueSeg = Dialog.getChoice();
    thTissue = Dialog.getNumber();
    thNM = Dialog.getNumber();     
	thSyn = Dialog.getNumber();     
	minPer = Dialog.getNumber();     
	
    // --- Run stain detection on selected image ---
    print(name);
    stainDetection("-", "-", name,r,tissueSeg,thTissue,thNM,thSyn,minPer);
    setBatchMode(false);
	run("Collect Garbage");
    showMessage("Done!");
}

macro "WSI_Brain_Syn-NM Action Tool 2 - C00fT0b11DT9b09iTcb09r" {
	/*  Processes a single histological slide image to detect regions 
	    (NM and alpha Synuclein ) and tissue. Prompts the user to select an image and adjust 
	    detection parameters before running the stain detection pipeline.

	Output:
	    - Executes `stainDetection` on each image in the directory.
	    - Saves results and annotated images according to the `stainDetection` output format.
	*/
	
	
	close("*");
	run("Fresh Start");

    macroInfo();
	
    // --- Select directory containing images ---
    InDir = getDirectory("Choose a Directory");
    list = getFileList(InDir);
    L = lengthOf(list);
	
        // --- Prompt user for parameters ---
    Dialog.create("Parameters");
    Dialog.addMessage("Choose parameters");
    Dialog.addNumber("micra/px ratio", r);
    Dialog.addNumber("Threshold for tissue detection", thTissue); 
    Dialog.addNumber("Threshold for Neuromelanin", thNM);  
    Dialog.addNumber("Threshold for AlphaSyn", thSyn);  
    Dialog.addNumber("% Syn", minPer);
    Dialog.show();
     
    r = Dialog.getNumber();
    thTissue = Dialog.getNumber();
    thNM = Dialog.getNumber();     
	thSyn = Dialog.getNumber();
	minPer = Dialog.getNumber();     
	
	
    // --- Loop through files and process valid images ---
    for (j = 0; j < L; j++) {
        if (endsWith(list[j], "jpg") || endsWith(list[j], "tif")) {
            name = list[j];
            print(name);
            stainDetection(InDir, InDir, list[j],r,tissueSeg,thTissue,thNM,thSyn,minPer);
            setBatchMode(false);
            run("Collect Garbage");
        }
    }
    showMessage("Done!");
}



function stainDetection(output, InDir, name,r,tissueSeg,thTissue,thNM,thSyn,minPer){
	/*  Main processing pipeline for detecting and quantifying 
	    Opens the image, runs tissue and stain detection, calculates area metrics, 
	    saves results, and exports annotated images.
	
		@param output   Output directory path where results and processed images will be saved.
		@param InDir    Input directory containing the image, or "-" if directly using the given file path.
		@param name     Image file name to process.
		@param r 		spatial resolution 
		@param thTissue tissue fix th
		@param thNM 	NM fix th
		@param thSyn 	alpha Syn fix th
	
	
	Output:
	    - Appends measurements to "WSI_Brain_Syn-NM_QuantificationResults.xls" in the output directory.
	    - Saves annotated image as JPEG in "AnalyzedImages" subfolder.
	    - Adds relevant ROIs to the ROI Manager.
	*/
	
	// --- Open image from file or input directory ---
	
		
	run("Collect Garbage");
	
	
	if (InDir == "-") { 
	    open(name);
	} else {
	    if (!isOpen(InDir + name)) {
	        open(InDir + name);
	    }
	}

		// --- Initialize ROI Manager and output folders ---
	roiManager("Reset");
	run("Clear Results");
	MyTitle = getTitle();
	output = getInfo("image.directory");
	OutDir = output + File.separator + "AnalyzedImages";
	File.makeDirectory(OutDir);
	
	
	selectWindow("Log");	
	// --- Set batch processing mode and colors ---
	setBatchMode(true);
	run("Colors...", "foreground=black background=white selection=green");
	setVoxelSize(r, r, r, "um");
	
	// --- Detect tissue and stain regions ---
	
	print("Segmenting Tissue ...");
	
	tissueDetection(MyTitle,tissueSeg,thTissue);
	aSyn_NM_Detection(MyTitle,thNM,thSyn,minPer);
	
	setBatchMode("exit and display");
	
	RoiManager.selectByName("Tissue");
	run("Create Mask");
	rename("tissueMask");
	RoiManager.selectByName("NM");
	run("Create Mask");
	rename("nmMask");
	RoiManager.selectByName("syn");
	run("Create Mask");
	rename("synMask");
	
	findPhenotype("nmMask","synMask",minPer);
	
	selectWindow("tissueMask");
	run("Create Selection");
	Roi.setName("Tissue");
	run("Add to Manager");
	close("tissueMask");
	
	selectWindow("nmMask");
	run("Create Selection");
	Roi.setName("NM");
	run("Add to Manager");
	close("nmMask");
	
	selectWindow("synMask");
	run("Create Selection");
	Roi.setName("syn");
	run("Add to Manager");
	close("synMask");
	
	// --- Measurement calculations ---
	print("Computing Metrics ...");
	run("Clear Results");
	selectWindow(MyTitle);	
	run("Set Measurements...", "area redirect=None decimal=2");
	roiManager("Measure");
	
	//already scaled to 0.502 aperio resolution 
	
	// Tissue area
	At = getResult("Area", 0);
	
	// NM and alpha synuclein Stained area
	areaNM = getResult("Area", 1);
	areaSyn = getResult("Area", 2);
	
	// Stain-to-tissue ratio
	r1 = (areaNM / At) * 100;
	r2 = (areaSyn / At) * 100;
	
	// --- Save or update results file ---
	run("Clear Results");
	if (File.exists(output + File.separator + "WSI_Brain_Syn-NM_QuantificationResults.xls")) {	
	    open(output + File.separator + "WSI_Brain_Syn-NM_QuantificationResults.xls");
	    IJ.renameResults("Results");
	}
	i = nResults;
	setResult("[Label]", i, MyTitle); 
	setResult("Tissue area (micra^2)", i, At);
	setResult("NM Stained area (micra^2)", i, areaNM);
	setResult("Alpha Syn Stained area (micra^2)", i, areaSyn);
	setResult("Ratio NM/Atissue (%)", i, r1);
	setResult("Ratio AlphaSyn/Atissue (%)", i, r2);
	
	saveAs("Results", output + File.separator + "WSI_Brain_Syn-NM_QuantificationResults.xls");

	// --- Prepare filename for annotated image export ---
	aa = split(MyTitle, ".");
	MyTitle_short = aa[0];
	
	// --- Annotate and save analyzed image ---
	setBatchMode("exit and display");
	
	print("Saving Segmented images ...");
	
	selectWindow(MyTitle);
	roiManager("Show None");
	roiManager("Select", 0);
	roiManager("Set Color", "yellow");
	roiManager("Show None");
	roiManager("Select", 1);
	roiManager("Set Color", "green");	
	roiManager("Show None");
	roiManager("Select", 2);
	roiManager("Set Color", "red");
	roiManager("show all without labels");
	run("Flatten");
	close(MyTitle);
	rename(MyTitle);
	saveAs("Jpeg", OutDir + File.separator + MyTitle_short + "_analyzed.jpg");
	close("\\Others");
	
	// --- Clean up and close windows ---
	close("Threshold");
	selectWindow(MyTitle);
	setTool("zoom");
	roiManager("reset");
	
	run("Collect Garbage");
	
		
}

function tissueDetection(im, method,thTissue){
	
	/*  Detects tissue regions in a slide image by either manual ROI selection 
	    or automatic intensity thresholding. The function generates binary masks 
	    separating tissue from background and stores the result as ROIs in the ROI Manager.
	
	@param im       Input slide image.
	@param method   Tissue detection method:
	                  - "Manual ROI" : user draws tissue ROI manually.
	                  - (default)    : automatic detection by thresholding.
	
	Output:
	    Adds ROIs to the ROI Manager:
	        - "Tissue"       : Automatically or manually detected tissue region.
	        - "TissueFilled" : Tissue region after hole filling and refinement.
	*/

    if (method == "Manual ROI") {
        // --- Manual selection mode ---
        print("Manual Selection ...");
        waitForUser("Draw Region of Interest and click OK");
        Roi.setName("ManualROI");
        run("Add to Manager");
    }

    run("Select None");
    print("-- Preprocessing Selection ...");

    // --- -- Preprocess image for tissue detection ---
    run("Duplicate...", "title=tissueMask");
    run("8-bit");
    run("Subtract Background...", "rolling=200 light");
    run("Select All");
    run("Enhance Contrast...", "saturated=0.35");
    run("Apply LUT");

    // --- Thresholding and mask creation ---
    setThreshold(0, thTissue);
    setOption("BlackBackground", false);
    run("Convert to Mask");

    // --- Remove small particles and fill tissue areas ---
    run("Analyze Particles...", "size=200-Infinity show=Masks in_situ");
    run("Invert");
    run("Analyze Particles...", "size=200-Infinity show=Masks in_situ");
    run("Invert");

    // --- Smooth mask and save ROIs ---
    run("Median...", "radius=2");
    run("Keep Largest Region");
    run("Create Selection");
    type = selectionType();
    if (type == -1) {
        makeRectangle(0, 0, 1, 1);
    }
    Roi.setName("Tissue");
    run("Add to Manager");
    
    run("Select None");
    run("Fill Holes");
    run("Create Selection");
    run("Enlarge...", "enlarge=-15");
    type = selectionType();
    if (type == -1) {
        makeRectangle(0, 0, 1, 1);
    }
    Roi.setName("TissueFilled");
    run("Add to Manager");
    close("tissueMask*");
        
    // --- Combine manual and automatic ROIs if Manual ROI mode was used ---
    if (method == "Manual ROI") {
        roiManager("Select", newArray(0,1));
        roiManager("AND");
        Roi.setName("Tissue");
        roiManager("Add");
        roiManager("Delete");  
        
        roiManager("Select", newArray(0,1));
        roiManager("AND");
        Roi.setName("TissueFilled");
        roiManager("Add");
        roiManager("Deselect");
        roiManager("Select", 0);
        roiManager("Delete");   	
        
    }
}


function aSyn_NM_Detection(im,thNM,thSyn,minPer){
	
	/*	Performs color deconvolution on an input RGB image to separate α-synuclein (purple) 
	    and neuromelanin (brown) stains. Each stain channel is processed using thresholding 
	    and morphological filters to generate binary masks. Resulting stain-specific ROIs 
	    are saved into the ROI Manager.
	
	@param im   Input image containing α-synuclein and neuromelanin stains.
	
	Output:
	    Adds ROIs to the ROI Manager:
	        - "NM"             : Neuromelanin regions
	        - "syn_stain"      : α-synuclein regions
	        - "residual_stain" : Remaining residual stain regions
	        - Combination of syn + residual as merged α-synuclein ROI
	*/
	
	print("Color deconvolution for NM detection ...");
    // --- Separate NM channel using color deconvolution ---
    run("Select None");
    run("Duplicate...", "title=stainMasks");
    rois = roiManager("count");
	
    run("Colour Deconvolution2", "vectors=[H&E DAB] output=8bit_Transmittance simulated cross hide");
    close("Colour Deconvolution");
    close("stainMasks-(Colour_2)");
    close("stainMasks-(Colour_1)");
    rename("NM");
	
	print("-- preprecessing and segmenting NM channel ...");
    // --- Process NM channel ---
    run("Subtract Background...", "rolling=200 light disable");
    run("Enhance Contrast...", "saturated=0.35");
    run("Apply LUT");
    setThreshold(0, thNM);
    setOption("BlackBackground", false);
    run("Convert to Mask");
    run("Morphological Filters", "operation=Closing element=Disk radius=1");
    run("Morphological Filters", "operation=Opening element=Disk radius=1");
    run("Median...", "radius=2");
    run("Analyze Particles...", "size=500-10000 circularity=0.0-1.00 pixel show=Masks exclude in_situ");
    close("NM");
    rename("NMmask");
    close("*Closing*");

    run("Create Selection");
    type = selectionType();
    if (type == -1) {
        makeRectangle(0,0,1,1);		
    }
    Roi.setName("NM");
    run("Add to Manager");
    close();

    // --- Restrict NM detection to tissue regions ---ç
    	
	print("-- discarting outsite tissue regions ...");
    roiManager("Deselect");
    roiManager("Select", newArray(1, 2));
    roiManager("AND");
    Roi.setName("NM");
    roiManager("Add");
    roiManager("Deselect");
    roiManager("Select", 2);
    roiManager("Delete");
    close("Mask*");
		
	 // --- Separate α-synuclein and residual stains ---
 	print("Color deconvolution for alpha-syn detection ...");
    selectWindow("stainMasks");
    run("Colour Deconvolution2", "vectors=[User values] output=[8bit_Transmittance] simulated [r1]=0.4488736662703707 [g1]=0.6413454476421424 [b1]=0.6222446854073532 [r2]=0.45069160390623 [g2]=0.668815140837207 [b2]=0.5912388566014054 [r3]=0.5261126144464447 [g3]=0.6506645620487793 [b3]=0.5475775238394984");
    close("stainMasks-(Colour_1)");
    selectWindow("stainMasks-(Colour_2)"); rename("syn_stain");
    selectWindow("stainMasks-(Colour_3)"); rename("residual_stain");
    close("Colour Deconvolution");
    close("Log");

    // --- Process α-synuclein channel ---
	print("-- preprecessing and segmenting alpha-syn channel ...");
    selectWindow("syn_stain");
	run("Duplicate...", "title=singlePos");
	run("Morphological Filters", "operation=Closing element=Disk radius=2");
    run("Median...", "radius=5");
    setThreshold(0, 75);
    setOption("BlackBackground", false);
    run("Convert to Mask");
    run("Analyze Particles...", "size=100-10000 circularity=0.0-1.00 pixel show=Masks exclude in_situ");
    close("singlePos");
    rename("singlePos");
	
 	selectWindow("syn_stain");
    RoiManager.selectByName("NM");
    run("Clear Outside");
    run("Select None");
    run("Morphological Filters", "operation=Closing element=Disk radius=1");
    run("Morphological Filters", "operation=Opening element=Disk radius=1");
    run("Median...", "radius=2");
    setThreshold(0, thSyn);
    setOption("BlackBackground", false);
    run("Convert to Mask");
    run("Analyze Particles...", "size=100-10000 circularity=0.0-1.00 pixel show=Masks exclude in_situ");
    close("syn_stain");
    rename("syn_stain");
    close("*Closing*");
    
    imageCalculator("OR create", "syn_stain","singlePos");
	selectImage("Result of syn_stain");
	rename("syn");
	close("singlePos");
    close("syn_stain");
        
    run("Create Selection");
    type = selectionType();
    if (type == -1) {
        makeRectangle(0,0,1,1);		
    }
    Roi.setName("syn");
    run("Add to Manager");
    close();

    // --- Process residual channel ---
    selectWindow("residual_stain");
    RoiManager.selectByName("NM");
    run("Clear Outside");
    run("Select None");
    run("Morphological Filters", "operation=Closing element=Disk radius=2");
    setThreshold(0, 50);
    setOption("BlackBackground", false);
    run("Convert to Mask");
    run("Analyze Particles...", "size=250-10000 circularity=0.0-1.00 pixel show=Masks exclude in_situ");
    close("residual_stain");
    rename("residual_stain");
    close("*Closing*");
    run("Create Selection");
    type = selectionType();
    if (type == -1) {
        makeRectangle(0,0,1,1);		
    }
    Roi.setName("residual_stain");
    run("Add to Manager");
    close();
	
    // --- Merge syn + residual stains into combined ROI ---
    roiManager("Select", newArray(3,4));
    roiManager("Combine");
    roiManager("Add");
    roiManager("Delete");
      
    roiManager("Select", newArray(1,3));
	roiManager("AND");
	Roi.setName("syn");
	roiManager("Add");
	roiManager("Select",  newArray(1,3));
	roiManager("Delete");
}


function findPhenotype(cellMask,phenotypeMask, minMarkerPerc) {	

	//--Detect marker-positive cells in the tumor
	selectWindow(cellMask);
	run("Select None");
	roiManager("Reset");
	run("Analyze Particles...", "size=0-10000 show=Masks add in_situ");
	roiManager("Show None");
	run("Clear Results");
	selectWindow(phenotypeMask);
	run("Select None");
	roiManager("Deselect");
	run("Set Measurements...", "area_fraction redirect=None decimal=2");
	roiManager("Measure");

	minMarkerPerc=5;
	n=roiManager("Count");
	for (i=0; i<n; i++)
	{
		Aperc=getResult("%Area",i);	
		if (Aperc>=minMarkerPerc) {	
	  		roiManager("Select", i);
			run("Fill", "slice");
	  	}	 	 	
	}
	
	run("Select None");
	run("Clear Results");
	roiManager("Reset");

	
}


