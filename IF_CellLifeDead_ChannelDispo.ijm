
function macroInfo(){
    /*
     *  Target User: Charlie. Carlos Sobejano
     *  Script Title: Quantification of channel Life Dead population on CHANNEL Device
     *  Version: 1.01
     *  Date: 2025
     *  Author: Tomas Muñoz tmsantoro@unav.es
     *  License: MIT
     *
     *  Description:
     *  This macro quantifies live and dead cell populations in channel devices using confocal microscopy images.
     *  - Input: 8 or 16 bit images in Zeiss .czi format with voxel size provided in um (x, y, z).
     *  - Modes: Single File and Batch Mode.
     *  - Algorithms:
     *      - Channel Segmentation: is used to isolate the channel by eliminating border and convex regions.
     *      - Phenotyping: Threshold-based segmentation (using user-defined Hoestch, GPF, and IP thresholds) is applied to detect cell markers,
     *        followed by measurements of areas corresponding to the whole device (FOV), cells, live cells, and dead cells.
     *  - Output: Processed images with ROIs, segmented masks, and an Excel file summarizing the quantification metrics.
     *
     *  Parameters:
     *      - Theoretic Channel Height (um)
     *      - Hoestch threshold (for nuclei/cell segmentation)
     *      - GPF threshold (for live cell detection)
     *      - IP threshold (for dead cell detection)
     *      - Minimum marker size (to eliminate small/noisy regions)
     *
     *  Output Features:
     *      - Image Label
     *      - Hoestch threshold (thHoestch)
     *      - GPF threshold (thGFP)
     *      - IP threshold (thIP)
     *      - Theoretic Channel Height (um)
     *      - FOV Area (um^2) of the device
     *      - Cells Area (um^2)
     *      - Dead Area (um^2)
     *      - Live Area (um^2)
     *      - Ratio of Live Cells/Total Cells (%)
     *      - Ratio of Dead Cells/Total Cells (%)
     *
     *  MIT License applies.
     */

    scripttitle = "Quantification of channel Life Dead population on CHANNEL Device";
    version = "1.01";
    date = "2025";
    imageAdquisition = "Confocal Microscopy : 1 channel images.";
    imageType = "8 or 16 bits";
    voxelSize = "Voxel size: um xyz";
    format = "Format: Zeiss .czi";
    parameter1 = "Theoretic Channel Height (um)";
    parameter2 = "Hoestch threshold";
    parameter3 = "GPF threshold";
    parameter4 = "IP threshold";
    parameter5 = "Min Size marker";
    buttom1 = "Im: Single File processing. Use Single file processing for fine tuning parameters";
    buttom2 = "Dir: Batch Mode. Please tune parameters before using Batchmode";
    excel = "Quantification_.xls";
    feature1 = "Image Label";
    feature2 = "thHoestch";
    feature3 = "thGFP";
    feature4 = "thIP";
    feature5 = "TheoreticHeight";
    feature6 = "FOV Area (um^2)";
    feature7 = "Cells Area (um^2)";
    feature8 = "Dead Area (um^2)";
    feature9 = "Live Area (um^2)";
    feature10 = "Ratio Live/Cells (%)";
    feature11 = "Ratio Dead/Cells (%)";

    showMessage("ImageJ Script", "<html>"
        +"<style>h{margin-top: 5px; margin-bottom: 5px;} p{margin: 0px;padding: 0px;} ol{margin-left: 20px;padding: 5px;} "
        + "#list-style-3 {list-style-type: circle;}.container {max-width: 1200px; margin: 0 auto; padding: 0px; }</style>"
        +"<h1><font size=6 color=Teal href=https://cima.cun.es/en/research/technology-platforms/image-platforms>CIMA: Imaging Platform</h1>"
        +"<h1><font size=5 color=Purple><i>Software Development Service</i></h1>"
        +"<p><font size=2 color=Purple><i>ImageJ Macros</i></p>"
        +"<h2><font size=3 color=black>"+scripttitle+"</h2>"
        +"<p><font size=2>Modified by Tomas Mu&ntilde;oz Santoro</p>"
        +"<p><font size=2>Version: "+version+" ("+date+")</p>"
        +"<p><font size=2> contact tmsantoro@unav.es</p>"
        +"<p><font size=2> Available for use/modification/sharing under the <a href=https://opensource.org/licenses/MIT/>MIT License</a></p>"
        +"<h2><font size=3 color=black>Developed for</h2>"
        +"<p><font size=3><i>Input Images</i></p>"
        +"<ul id=list-style-3><font size=2><li>"+imageAdquisition+"</li><li>"+imageType+"</li><li>"+voxelSize+"</li><li>"+format+"</li></ul>"
        +"<p><font size=3><i>Action tools (Buttons)</i></p>"
        +"<ol><font size=2><li>"+buttom1+"</li><li>"+buttom2+"</li></ol>"
        +"<p><font size=3><i>PARAMETERS:</i></font></p>"
        +"<ul id=list-style-3><font size=2><li>"+parameter1+"</li><li>"+parameter2+"</li><li>"+parameter3+"</li><li>"+parameter4+"</li><li>"+parameter5+"</li></ul>"
        +"<p><font size=3><i>Quantification Results:</i></font></p>"
        +"<p><font size=3><i>AnalyzedImages folder: Visualize Segmented Images</i></font></p>"
        +"<p><font size=3><i>Excel "+excel+"</i></font></p>"
        +"<ul id=list-style-3><font size=2><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li><li>"+feature5+"</li>"
        + "<li>"+feature6+"</li><li>"+feature7+"</li><li>"+feature8+"</li><li>"+feature9+"</li><li>"+feature10+"</li><li>"+feature11+"</li></ul>"
        +"<h0><font size=5></h0>"
        +"");
}



// Set options for debugging, expandable arrays, and wait for completion.
setOption("DebugMode", true);
setOption("ExpandableArrays", true);
setOption("WaitForCompletion", true);

// Hide row indexes in tables.
Table.showRowIndexes(false);

// Define default threshold and parameter values for segmentation.
var  theoricHeight=1000; thHoe = 75; thGFP = 50; thIP = 40; minSize=1000 ;

// SINGLE FILE 

// Define a macro for processing a single file.
macro "IF_channelClassPhenotype Action Tool 1 - Cf00T2d15IT6d10m" {

    // Print macro information.
    macroInfo();

    // Close all open windows and collect garbage.
    run("Close All");
    wait(500);
    run("Collect Garbage");
    
    // Open ROI Manager.
    run("ROI Manager...");
    
    // Select a single file for processing.
    name = File.openDialog("Select File");
    print("Processing " + name);
    
    // Create a dialog box to input parameters for analysis.
    Dialog.create("Parameters for the analysis");
    
    Dialog.addMessage("Device SetUp")
    Dialog.addNumber("Theoretic Channel Height (um)", theoricHeight);
            
    // Segmentation options:
    Dialog.addMessage("channels segmentation parameters")
    Dialog.addNumber("Hoestch threshold", thHoe);
    Dialog.addNumber("GPF threshold", thGFP);
    Dialog.addNumber("IP threshold", thIP);
  
    // Phenotyping section:
    Dialog.addNumber("Min Size marker", minSize);
    // Show the dialog box.
    Dialog.show();	
    
	// Device SetUp Parameters
    phName = Dialog.getString();
    theoricHeight = Dialog.getNumber();
      
    thHoe = Dialog.getNumber();
    thGFP = Dialog.getNumber();
    thIP = Dialog.getNumber();
   
    minSize = Dialog.getNumber();

    batch=true;
    
    // Call the main function for channel classification and display completion message.
    IF_channelClass("-", "-", name, thHoe,thGFP,thIP,minSize,batch,theoricHeight);
    showMessage("IF_Quantification done!");

}

// BATCH MODE
// Define a macro for processing multiple files in batch mode.

macro "IF_channelClassPhenotype Action Tool 2 - C00fT0b11DT9b09iTcb09r"{

	
	// Print macro information.
	macroInfo();
	
	// Clean initialization
	// Close all open windows, open ROI Manager, and collect garbage.
	run("Close All");
	run("ROI Manager...");
	wait(500);
	run("Collect Garbage");
	
	// Structure Directory
	// Prompt user to select the directory containing images.
	InDir = getDirectory("Choose images' directory");
	list = getFileList(InDir);
	L = lengthOf(list);
	
	 // Create a dialog box to input parameters for analysis.
    Dialog.create("Parameters for the analysis");
    
    Dialog.addMessage("Device SetUp")
    Dialog.addNumber("Theoretic Channel Height (um)", theoricHeight);
            
    // Segmentation options:
    Dialog.addMessage("channels segmentation parameters")
    Dialog.addNumber("Hoestch threshold", thHoe);
    Dialog.addNumber("GPF threshold", thGFP);
    Dialog.addNumber("IP threshold", thIP);
  
    // Phenotyping section:
    Dialog.addNumber("Min Size marker", minSize);
    // Show the dialog box.
    Dialog.show();	
    
	// Device SetUp Parameters
    phName = Dialog.getString();
    theoricHeight = Dialog.getNumber();
      
    thHoe = Dialog.getNumber();
    thGFP = Dialog.getNumber();
    thIP = Dialog.getNumber();
   
    minSize = Dialog.getNumber();

	// Process in batch Mode
	batch=true;
	
	for (j = 0; j < L; j++)
	{
		// Analyze images with supported extensions (tif, czi)
		if (endsWith(list[j], "tif") || endsWith(list[j], "czi")) {
			// Print the processing message
			name = list[j];
			print("Processing " + list[j]);
			
			// Call the main function for channel classification
			IF_channelClass(InDir, InDir, list[j],thHoe,thGFP,thIP,minSize,batch,theoricHeight);
		}
		
		// Close all open windows after processing each image
		close("*");
	}
	
	// Display completion message
    showMessage("IF_Quantification done!");

}

/* Function Level 1
	IF_channelClass: quantify inmunoFluorescence
*/


function IF_channelClass(output,InDir,name, thHoe,thGFP,thIP,minSize,batch,theoricHeight){
	/*
	Suumary:
	This function performs channel classification and phenotype analysis on images using provided parameters.
	It segments channel, adjusts contrast, removes background, and identifies channel markers to classify channels Marker+.
	Phenotype analysis is conducted for both  and  markers, and results are saved to a spreadsheet.
	
	Parameters:
	- output: Output directory for saving results.
	- InDir: Directory containing input images.
	- name: Name of the current image being processed.
	- flagContrast: Flag for contrast adjustment.
	- flagSubstractBackground: Flag for background subtraction.
	- thchannel: Threshold for channel segmentation.
	- phName: Name of the  marker.
	- minSize: Minimum size for  marker.
	*/

	// Clear ROI manager and results table
	roiManager("Reset");
	run("Clear Results");

	// Set Colors config and measurements
	run("Colors...", "foreground=white background=black selection=green");
	run("Set Measurements...", "area mean standard modal area_fraction redirect=None decimal=1");

	// Open the image
	if (InDir == "-") {
		openFileFormat(name);
	} else {
		file = InDir + name;
		openFileFormat(file);
	}
	
	// Set batch mode
	setBatchMode(false);
	
	// Extract file name and directory for output
	MyTitle = getTitle();
	output = getInfo("image.directory");
	OutDir = output + File.separator + "AnalyzedImages";
	File.makeDirectory(OutDir);
	aa = split(MyTitle, ".");
	MyTitle_short = aa[0];
	getVoxelSize(rx, ry, rz, rUnit);
	
	rename("orig");
	wait(100);
	print(MyTitle_short);
	
	run("Options...", "iterations=1 count=1");
		
	// Keep only marker channels and eliminate autofluorescence
	run("Duplicate...", "title=channelSignal duplicate channels=2-2");
	run("Duplicate...", "title=channelsMask  duplicate channels=2-2");
	wait(100);
	getDimensions(width, height, channels, slices, frames);
	
	// DEFINE CHANNEL TO QUANTIFY - ALL BUT THE BORDER
	selectWindow("channelsMask");
	run("8-bit");
	run("Threshold...");
	setAutoThreshold("Otsu dark 16-bit no-reset");
	setThreshold(thHoe, 255);
	waitForUser("Adjust Threshold : avoid offside artefacts");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Analyze Particles...", "size=1000-Infinity pixel in_situ show=Masks");
	
	// Get rid of the convex regions of the channel
	setForegroundColor(0,0,0);	
	run("Duplicate...", "title=boundingBox");
	run("Create Selection");
	run("Fit Rectangle");
	run("Fill");
	
	selectWindow("channelsMask");
	run("Duplicate...", "title=convexHull");
	run("Create Selection");
	run("Convex Hull");
	run("Enlarge...", "enlarge=50 pixel");
	run("Fill");
	run("Select None");
	run("Invert");

	imageCalculator("XOR create", "boundingBox","convexHull");
	selectImage("Result of boundingBox");
	run("Invert");
	run("Morphological Filters", "operation=Erosion element=Square radius=20");
	run("Analyze Particles...", "size=200000-Infinity pixel circularity=0.10-1.00 show=Masks add");
	
	close("*oundingBox*");
	close("*convexHull*");
	close("*Erosion");

	setForegroundColor(255,255,255);	
	selectWindow("channelsMask");
	roiManager("select", 0);
	getSelectionBounds(x, y, w, h);
	getDimensions(width, height, channels, slices, frames);

	if(x<(width/2)){
		makeRectangle(x-100, 0, w+1000,height);
		run("Fill");
	}else{
		makeRectangle(x-1000, 0, width-w,height);
		run("Fill");	
	}
	
	roiManager("select", 1);
	getDimensions(width, height, channels, slices, frames);
	getSelectionBounds(x, y, w, h);
	//Array.print(newArray(x,y,w,h));
	if(x<(width/2)){
		makeRectangle(x-100, 0, w+1000,height);
		run("Fill");
	}else{
		makeRectangle(x-1000, 0, width-w,height);
		run("Fill");	
	}
	
	run("Create Selection");
	run("Fit Rectangle");
	selectWindow("channelSignal");
	run("Restore Selection");
	setBackgroundColor(0,0,0);
	run("Clear Outside");
	run("Select None");

	setBatchMode("exit and display");
	
	setForegroundColor(0,0,0);
	setBackgroundColor(255,255,255);
	
	selectWindow("channelsMask");
		
	// Calculate real channel heigth
	getVoxelSize(rx,ry,rz,unit);
	run("Create Selection");
	run("Fit Rectangle");
	
	Roi.getSplineAnchors(x, y)
	vector=newArray(x[3]-x[0],y[3]-y[0]);
	height=sqrt(Math.pow(vector[0],2)+Math.pow(vector[1],2));
	print(height*rx);
	
	//adjust to theoreticHeight
	//heoricHeight=750;

	if ((height*rx)>theoricHeight){
		run("Enlarge...", "enlarge="+(-((height*rx)-theoricHeight)/2)+"");
	}
	
	//Measure channel area	
	run("Measure");
	FOV=getResult("Area", 0);
	//run("Enlarge...", "enlarge=-200");
	selectWindow("channelSignal");
	run("Restore Selection");
	Overlay.addSelection("Yellow");
	Overlay.hide;
	Roi.setName("FOV");
	
	roiManager("reset");
	run("Add to Manager");
	
	
	//--PROCESS CELLS
	
	selectWindow("orig");
	run("Duplicate...", "title=Hoestch duplicate channels=2-2");
	run("8-bit");
	
	//--Preprocessing
	//run("Unsharp Mask...", "radius=5 mask=0.60 stack");
	//setMinAndMax(15, 255);
	//run("Apply LUT", "stack");
	run("Subtract Background...", "rolling=750");

	//--Thresholding methods
	run("Threshold...");
	setAutoThreshold("Otsu dark 16-bit no-reset");
	setThreshold(thHoe, 255);
	waitForUser("Adjust Threshold for Hoestch segmentation");
	getThreshold(lower, upper);
	thHoe = lower;
	run("Convert to Mask");
	run("Median...", "radius=2");
	
	roiManager("select", 0);
	run("Clear Outside");
	run("Select None");
	
	
	//--PROCESS LIVE
	
	selectWindow("orig");
	run("Duplicate...", "title=live duplicate channels=1-1");
	run("8-bit");
	
	//--Preprocessing
	//run("Unsharp Mask...", "radius=5 mask=0.60 stack");
	//setMinAndMax(15, 255);
	//run("Apply LUT", "stack");
	

	//--Thresholding methods
	
	run("Threshold...");
	setAutoThreshold("Otsu dark 16-bit no-reset");
	setThreshold(thGFP, 255);
	waitForUser("Adjust Threshold for GFP segmentation");
	getThreshold(lower, upper);
	thGFP = lower;
	run("Convert to Mask");
	run("Median...", "radius=2");
	
	roiManager("select", 0);
	run("Clear Outside");
	run("Select None");
	
	//--Post-processing
	//run("Close-", "stack");

	//minBacSize=50;
	//run("Analyze Particles...", "size="+minBacSize+"-Infinity pixel show=Masks in_situ stack");
	
		
	//--PROCESS DEAD BACTERIA
	
	selectWindow("orig");
	run("Duplicate...", "title=dead duplicate channels=3-3");
	run("8-bit");
	
	//--Preprocessing
	setMinAndMax(5, 100);
	run("Apply LUT", "stack");
	run("Subtract Background...", "rolling=300");
	
	
	//--Thresholding Mehtods
				
	//autoThreshold("dead","Otsu");
	//percHistMode("dead");
	//fixThreshold("dead",thBacDead);
	
	run("Threshold...");
	setAutoThreshold("Otsu dark 16-bit no-reset");
	setThreshold(thIP, 255);
	waitForUser("Adjust Threshold for IP segmentation");
	getThreshold(lower, upper);
	thIP = lower;

	run("Convert to Mask");
	run("Median...", "radius=2");
	
	roiManager("select", 0);
	run("Clear Outside");
	run("Select None");
	//run("Analyze Particles...", "size=0-7000 pixel show=Masks in_situ");

	//--Post-processing
	//run("Close-", "stack");
	//run("Median...", "radius=1 stack");
	//minBacSize=50;
	//run("Analyze Particles...", "size="+minBacSize+"-Infinity pixel show=Masks in_situ stack");
	
	//--Final live bacteria mask
	imageCalculator("AND create stack", "Hoestch","live");
	close("live");
	rename("live");
	imageCalculator("AND create stack", "dead","Hoestch");
	close("dead");
	rename("dead");
	imageCalculator("XOR stack", "live","dead");
	
	run("Clear Results");
	
	selectWindow("Hoestch");
	run("Create Selection");
	Roi.setName("Cells");
	run("Add to Manager");
	run("Measure");
	cells = getResult("Area", 0);
	//cells = cells /1e6;
	
	run("Select None");
	run("Clear Results");
	saveAs("Tiff", output+File.separator+"AnalyzedImages"+File.separator+MyTitle+"_HoestchMask.tif");
    rename("Hoestch");
	
	selectWindow("live");
	run("Create Selection");
	Roi.setName("Live");
	run("Add to Manager");
	run("Measure");
	live = getResult("Area", 0);
	run("Select None");
	run("Clear Results");
	saveAs("Tiff", output+File.separator+"AnalyzedImages"+File.separator+MyTitle+"_LiveMask.tif");
    rename("Live");
    //live = live /1e6;
	
	selectWindow("dead");
	run("Create Selection");
	Roi.setName("dead");
	run("Add to Manager");
	run("Measure");
	dead = getResult("Area", 0);
	run("Select None");
	run("Clear Results");
	saveAs("Tiff", output+File.separator+"AnalyzedImages"+File.separator+MyTitle+"_DeadMask.tif");
   	rename("dead");
   	//dead = dead /1e6;
		
    rLive = (live / cells ) * 100; 
    rDead = (dead / cells ) * 100; 
     
	// Save quantification results for the current frame
    run("Clear Results");
    if (File.exists(output + File.separator + "QuantificationResults_IF_CellsLifeDead_Channel.xls")) {
        open(output + File.separator + "QuantificationResults_IF_CellsLifeDead_Channel.xls");
        IJ.renameResults("Results");
    }
   	    
    j = nResults; // Append new results to existing table
    setResult("[Label]", j, MyTitle_short);
    setResult("thHoestch", j, thHoe);
    setResult("thGFP", j, thGFP);
    setResult("thIP", j, thIP);
    setResult("TheoreticHeight", j, theoricHeight);
    setResult("FOV Area (um^2)", j, FOV);
    setResult("Cells Area (um^2)", j, cells);
    setResult("Dead Area (um^2)", j, dead);
    setResult("Live Area (um^2)", j, live);
    setResult("Ratio Live/Cells (%)", j, rLive);
   	setResult("Ratio Dead/Cells (%)", j, rDead);
    
    saveAs("Results", output + File.separator + "QuantificationResults_IF_CellsLifeDead_Channel.xls");	
    
    selectWindow("orig");
    run("8-bit");
	run("Duplicate...", "title=imageToSave duplicate channels=1-3");
	
	selectWindow("imageToSave");		
	run("Duplicate...", "title=H duplicate channels=2-2");
	roiManager("Select", 1);
    roiManager("Set Color", "Blue");
    Overlay.addSelection;
	saveAs("Tiff", output+File.separator+"AnalyzedImages"+File.separator+MyTitle+"_HoestchSeg.tif");
	close();
	
	selectWindow("imageToSave");		
	run("Duplicate...", "title=H duplicate channels=1-1");
	roiManager("Select", 2);
    roiManager("Set Color", "Green");
    Overlay.addSelection;
	saveAs("Tiff", output+File.separator+"AnalyzedImages"+File.separator+MyTitle+"_GFPSeg.tif");
	close();
	
	selectWindow("imageToSave");		
	run("Duplicate...", "title=H duplicate channels=3-3");
	roiManager("Select", 3);
    roiManager("Set Color", "Red");
    Overlay.addSelection;
	saveAs("Tiff", output+File.separator+"AnalyzedImages"+File.separator+MyTitle+"_IPSeg.tif");
	close();
		
	selectWindow("imageToSave");		
	Stack.setChannel(1);
	run("Green");
	setMinAndMax(20, 255);
	run("Apply LUT","slice");
	Stack.setChannel(2);
	setMinAndMax(0, 255);
	run("Apply LUT","slice");
	Stack.setChannel(3);
	run("Red");
	run("Enhance Contrast", "saturated=0.35");
	run("Apply LUT","slice");
	
	run("Make Composite");
	run("RGB Color");
	
	//Stack.setChannel(2);
	//run("Blue");
			
    selectWindow("imageToSave");
    setBatchMode("show");
    roiManager("Select", 0);
    roiManager("Set Color", "Yellow");
    Overlay.addSelection;
	
	roiManager("Select", 1);
    roiManager("Set Color", "Blue");
    Overlay.addSelection;
	
	roiManager("Select", 2);
    roiManager("Set Color", "Green");
    Overlay.addSelection;
    
    roiManager("Select", 3);
    roiManager("Set Color", "Red");
    Overlay.addSelection;
   
    run("Flatten");
	saveAs("Tiff", output+File.separator+"AnalyzedImages"+File.separator+MyTitle+"_LifeDead_Overlay.tif");
	
	roiManager("Save",output+File.separator+"AnalyzedImages"+File.separator+MyTitle+"_ROIS.zip");
   
   	//Clear unused memory
	wait(500);
	run("Collect Garbage");
	
	close("\\Others");
	
		  
	}
	
}


function openFileFormat(file) {
	// Function openFileFormat:
	// This function opens files based on their format.
	
	// Parameters:
	// - file: File path.
	
	
	if (endsWith(file, ".jpg") || endsWith(file, ".tif")) {
		open(file);
	} else if (endsWith(file, ".czi") || endsWith(file, ".svs")) {
		run("Bio-Formats Importer", "open=[" + file + "] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");

	}
}




