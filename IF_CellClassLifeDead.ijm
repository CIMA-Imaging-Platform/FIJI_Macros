function macroInfo(){

	 /* TOOL for AUTOMATIC CLASSIFICATION OF CELL LIFE DEAD PHENOTYPES 
	 *  Target User: Charlie. Carlos Sobejano
	 */

	scripttitle= "TOOL for AUTOMATIC CLASSIFICATION OF CELL LIFE DEAD PHENOTYPES ";
	version= "1.01";
	date= "2024";
	

	//  Tests Images:

	imageAdquisition="Confocal Microscopy : 3 channel images. (DAPI + Life PhenotpeMarker + Dead PhenotpeMarker)";
	imageType="8 or 16 bits";  
	voxelSize="Voxel size: um xyz";
	format="Format: Zeiss .czi";   
 
	 /*  GUI User Requierments:
	     - Choose parameters.
	     - Single File and Batch Mode
	     
	   Important Parameters: click Im or Dir + right button.
	 
	 
	 *  Algorithms
	 *    - Nuclei Segmentation : MARKER-CONTROLLED WATERSHED  
	 * 		   	Use DAPI to segment nuclei. 
	 *    		Preprocessing: flagConstrast ; 
	 *    		Watershed: prominence
	 *    	
	 *    - Phenotyping:
	 *    		Detect +/- Cells Presence Phenotypeamine inside Nuclei	
	 *    		cytoBand: radius region if marker is cytoplasm or nuclear.
	 *    		Masking AND operator: cell and phenotypes. 
	 */
 
	parameter1="Introduce Channel Order";
	
	//Preprocessing Params
	parameter2="Background Removal and Adjust contrast checkBox";
		
	// DAPI segmentation options:
	parameter3="DAPI threshold";
	parameter4="Diffenrence for Local Maxima detection";
	
	// Life segmentation options:
	parameter5="Life Phenotype threshold";
	parameter6="Min Size marker";
	parameter7="Min presence of Life marker per cell (%)";
	
	// Markers1' segmentation options:
	parameter8="Life Phenotype threshold";
	parameter9="Min Size marker";
	parameter10="Min presence of Life marker per cell (%)";
	 
	  
	 //  2 Action tools:
		
	 buttom1="Im: Single File processing. Use Single file processing for fine tunning parameters";
	 buttom2="Dir: Batch Mode. Please tune parameters before using Batchmode";

	//  OUTPUT
	
	// Analyzed Images with ROIs

	excel="Quantification_LifeDead.xls";
	feature1="Image Label"; 
	feature2="# total cells"; 
	feature3="# Life+";
	feature4="# Dead+";
	feature5="# % Life+";
	feature6="# % Dead+";
	feature7="Iavg of Life+";
	feature8="Iavg of Dead";
	feature9="Istd of Life+";
	feature10="Istd of Dead+"; 

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
	    +"<p><font size=3  i>PARAMETERS: Right Click on Action tools  </i></p>s"
	    +"<ul id=list-style-3><font size=2  i>"
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li>"
	    +"<li>"+parameter3+"</li>"
	    +"<li>"+parameter4+"</li>"
	    +"<li>"+parameter5+"</li>"
	    +"<li>"+parameter6+"</li>"
	    +"<li>"+parameter7+"</li>"
	    +"<li>"+parameter8+"</li>"
	    +"<li>"+parameter9+"</li>"
	    +"<li>"+parameter10+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li>"
	    +"<li>"+feature5+"</li><li>"+feature6+"</li><li>"+feature7+"</li><li>"+feature8+"</li><li>"+feature9+"</li><li>"+feature10+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}

// Set options for debugging, expandable arrays, and wait for completion.
setOption("DebugMode", true);
setOption("ExpandableArrays", true);
setOption("WaitForCompletion", true);

// Hide row indexes in tables.
Table.showRowIndexes(false);

// Define default channel indices and flags for preprocessing.
var cDapi = 3, cLife = 1, cDead = 2;
var flagContrast = true, flagSubstractBackground = true;

// Define default threshold and parameter values for segmentation.
var thNucl = 35, thLife = 60, thDead = 200, prominence = 10;
var minSizeLife = 200, minSizeDead = 50;
var minMarkerPercLife = 50, minMarkerPercDead = 5;

// SINGLE FILE 

// Define a macro for processing a single file.
macro "IF_CellClassLifeDead Action Tool 1 - Cf00T2d15IT6d10m" {

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
    
    // Channel Selection section:
    Dialog.addMessage("Channel Selection")
    Dialog.addNumber("DAPI Channel", cDapi);
    Dialog.addNumber("Life Channel", cLife);
    Dialog.addNumber("Dead Channel", cDead);
    
    // Preprocessing Params section:
    Dialog.addMessage("Preprocessing parameters")
    Dialog.addCheckbox("Adjust contrast", flagContrast);
    Dialog.addCheckbox("Background Removal", flagSubstractBackground);
        
    // DAPI segmentation options:
    Dialog.addMessage("DAPI segmentation parameters")
    Dialog.addNumber("DAPI threshold", thNucl);
    Dialog.addNumber("Prominence for maxima detection", prominence);
    
    // Life segmentation options:
    Dialog.addMessage("Life Phenotyping");
    Dialog.addString("Life Marker", "GPF");
    Dialog.addNumber("Life Phenotype threshold", thLife);
    Dialog.addNumber("Min Size marker", minSizeLife);
    Dialog.addNumber("Min presence of positive marker per cell (%)", minMarkerPercLife);
    
    // Dead Phenotyping section:
    Dialog.addMessage("Dead Phenotyping");
    Dialog.addString("Dead Marker", "PI");
    Dialog.addNumber("Dead Phenotype threshold", thDead);
    Dialog.addNumber("Min Size marker", minSizeDead);
    Dialog.addNumber("Min presence of positive marker per cell (%)", minMarkerPercDead);
    
    // Show the dialog box.
    Dialog.show();	
    
    // Retrieve parameters from the dialog box.
    cDapi = Dialog.getNumber();
    cLife = Dialog.getNumber();
    cDead = Dialog.getNumber();
    
    flagContrast = Dialog.getCheckbox();
    flagSubstractBackground = Dialog.getCheckbox();
    
    thNucl = Dialog.getNumber();
    prominence = Dialog.getNumber();
    
    phNameLife = Dialog.getString();
    thLife = Dialog.getNumber();
    minSizeLife = Dialog.getNumber();
    minLifePerc = Dialog.getNumber();
    
    phNameDead = Dialog.getString();
    thDead = Dialog.getNumber();
    minSizeDead = Dialog.getNumber();
    minDeadPerc = Dialog.getNumber();
    
    // Call the main function for cell classification and display completion message.
    IF_CellClassLifeDead("-", "-", name, cDapi, cLife, cDead, flagContrast, flagSubstractBackground, thNucl, prominence, phNameLife, thLife, minSizeLife, phNameDead, thDead, minSizeDead, minDeadPerc);
    showMessage("IF_CellClassLifeDead done!");

}

// BATCH MODE
// Define a macro for processing multiple files in batch mode.

macro "IF_CellClassLifeDead Action Tool 2 - C00fT0b11DT9b09iTcb09r"{

	
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
	
	// Channel Selection section:
	Dialog.addMessage("Channel Selection")
	Dialog.addNumber("DAPI Channel", cDapi);
	Dialog.addNumber("Life Channel", cLife);
	Dialog.addNumber("Dead Channel", cDead);
	
	// Preprocessing Params section:
	Dialog.addMessage("Preprocessing parameters")
	Dialog.addCheckbox("Adjust contrast", flagContrast);
	Dialog.addCheckbox("Background Removal", flagSubstractBackground);
		
	// DAPI segmentation options:
	Dialog.addMessage("DAPI segmentation parameters")
	Dialog.addNumber("DAPI threshold", thNucl);
	Dialog.addNumber("Prominence for maxima detection", prominence);
	
	// Life segmentation options:
	Dialog.addMessage("Life Phenotyping");
	Dialog.addString("Life Marker", "GPF");
	Dialog.addNumber("Life Phenotype threshold", thLife);
	Dialog.addNumber("Min Size marker", minSizeLife);
	Dialog.addNumber("Min presence of positive marker per cell (%)", minMarkerPercLife);
	
	// Dead Phenotyping section:
	Dialog.addMessage("Dead Phenotyping");
	Dialog.addString("Dead Marker", "PI");
	Dialog.addNumber("Dead Phenotype threshold", thDead);
	Dialog.addNumber("Min Size marker", minSizeDead);
	Dialog.addNumber("Min presence of positive marker per cell (%)", minMarkerPercDead);
	
	// Show the dialog box.
	Dialog.show();	
	
	// Retrieve parameters from the dialog box.
	cDapi = Dialog.getNumber();
	cLife = Dialog.getNumber();
	cDead = Dialog.getNumber();
	
	flagContrast = Dialog.getCheckbox();
	flagSubstractBackground = Dialog.getCheckbox();
	
	thNucl = Dialog.getNumber();
	prominence = Dialog.getNumber();
	
	phNameLife = Dialog.getString();
	thLife = Dialog.getNumber();
	minSizeLife = Dialog.getNumber();
	minLifePerc = Dialog.getNumber();
	
	phNameDead = Dialog.getString();
	thDead = Dialog.getNumber();
	minSizeDead = Dialog.getNumber();
	minDeadPerc = Dialog.getNumber();
	
		
	// Process in batch Mode
	for (j = 0; j < L; j++)
	{
		// Analyze images with supported extensions (tif, czi)
		if (endsWith(list[j], "tif") || endsWith(list[j], "czi")) {
			// Print the processing message
			name = list[j];
			print("Processing " + list[j]);
			
			// Call the main function for cell classification
			IF_CellClassLifeDead(InDir, InDir, list[j], cDapi, cLife, cDead, flagContrast, flagSubstractBackground, thNucl, prominence, phNameLife, thLife, minSizeLife, phNameDead, thDead, minSizeDead, minDeadPerc);
		}
		// Close all open windows after processing each image
		close("*");
	}
	
	// Display completion message
	showMessage("IF_CellClassLifeDead done!");

}

/* Function Level 1
	IF_CellClassLifeDead: quantify inmunoFluorescence
*/


function IF_CellClassLifeDead(output,InDir,name,cDapi,cLife,cDead,flagContrast,flagSubstractBackground,thNucl,prominence,phNameLife,thLife,minSizeLife,phNameDead,thDead,minSizeDead,minDeadPerc)
{
	/*
	Summary:
	This function performs cell classification and phenotype analysis on images using provided parameters.
	It segments nuclei, adjusts contrast, removes background, and identifies cell markers to classify cells.
	Phenotype analysis is conducted for both life and dead markers, and results are saved to a spreadsheet.
	
	Parameters:
	- output: Output directory for saving results.
	- InDir: Directory containing input images.
	- name: Name of the current image being processed.
	- cDapi: DAPI channel number.
	- cLife: Life channel number.
	- cDead: Dead channel number.
	- flagContrast: Flag for contrast adjustment.
	- flagSubstractBackground: Flag for background subtraction.
	- thNucl: Threshold for nuclei segmentation.
	- prominence: Prominence for maxima detection.
	- phNameLife: Name of the life marker.
	- thLife: Threshold for life marker.
	- minSizeLife: Minimum size for life marker.
	- phNameDead: Name of the dead marker.
	- thDead: Threshold for dead marker.
	- minSizeDead: Minimum size for dead marker.
	- minDeadPerc: Minimum presence of positive marker per cell (%).
	*/

	// Clear ROI manager and results table
	roiManager("Reset");
	run("Clear Results");

	// Set Colors config and measurements
	run("Colors...", "foreground=white background=black selection=green");
	run("Set Measurements...", "area mean standard modal area_fraction redirect=None decimal=2");

	// Set batch mode
	setBatchMode(true);

	// Open the image
	if (InDir == "-") {
		openFileFormat(name);
	} else {
		file = InDir + name;
		openFileFormat(file);
	}

	// Extract file name and directory for output
	MyTitle = getTitle();
	output = getInfo("image.directory");
	OutDir = output + File.separator + "AnalyzedImages";
	File.makeDirectory(OutDir);
	aa = split(MyTitle, ".");
	MyTitle_short = aa[0];
	
	rename(MyTitle_short);
	
	
	
	// Keep only marker channels and eliminate autofluorescence
	run("Duplicate...", "title=merge duplicate channels=1-3");
	run("Make Composite", "display=Composite");
	wait(100);
	
	// DEFINE AREA TO QUANTIFY - ALL BUT THE BORDER
	run("RGB Color");
	run("RGB to Luminance");
	setAutoThreshold("Otsu");
	setThreshold(30, 255);
	setOption("BlackBackground", false);
	wait(100);
	run("Convert to Mask");
	run("Analyze Particles...", "size=5-20000 pixel circularity=0.5-1.00 show=Masks exclude in_situ");
	
	getDimensions(width, height, channels, slices, frames);
	makePoint(floor(width/2), floor(height/2));
	run("Enlarge...", "enlarge="+floor(width/2)-400+" pixel");
	
	//WaitForUser;
	
	setForegroundColor(0,0,0);
	setBackgroundColor(255,255,255);
	run("Clear Outside", "stack");
	run("Select None");	
	
	//WaitForUser;
	
	run("Create Selection");
	run("Convex Hull");
	run("Enlarge...", "enlarge=-200");
	selectWindow("merge");
	run("Restore Selection");
	Overlay.addSelection("Yellow");
	Overlay.hide;
	close("luminance*");
	close("merge (RGB)");
		
	// SEGMENT NUCLEI FROM DAPI:
	selectWindow("merge");
	run("Select None");
	run("Duplicate...", "title=nuclei duplicate channels=" + cDapi);
	run("8-bit");

	// Preprocessing
	if (flagSubstractBackground) {
		rollingRadius = 60;
		run("Subtract Background...", "rolling=" + rollingRadius);
	}
	if (flagContrast) {
		run("Enhance Contrast", "saturated=0.1");
		run("Apply LUT");
	}
	

	rollingRadius = 60;
	run("Subtract Background...", "rolling=" + rollingRadius);
	run("Median...", "radius=2");
		
	
	// CELL MASK FROM DAPI
	run("Duplicate...", "title=nucleiMask duplicate");
	selectWindow("nucleiMask");
	setAutoThreshold("Default dark");
	getThreshold(lower, upper);
	setThreshold(thNucl, upper);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	
	centralAreaMask("nucleiMask");
	selectWindow("nucleiMask");
	
	run("Median...", "radius=2");
	selectWindow("nucleiMask");
	run("Analyze Particles...", "size=100-7000 pixel show=Masks in_situ");
	run("Adjustable Watershed", "tolerance=1");
	close("Segmentation Movie");
	selectWindow("nucleiMask");
	run("Analyze Particles...", "size=100-7000 circularity=0.2-1.00 pixel show=Masks in_situ");
	selectWindow("nuclei");
	run("Duplicate...", "title=dapiMaxima ignore");
	run("Morphological Filters", "operation=[White Top Hat] element=Disk radius=10");
	rename("dapiSeeds");
	selectWindow("nucleiMask");
	run("Create Selection");
	selectWindow("dapiSeeds"); 
	run("Restore Selection");
	/*if (flagContrast) {
		run("Enhance Contrast", "saturated=0.1");
		run("Apply LUT");
	}*/
	run("Gaussian Blur...", "sigma=1");
	run("Find Maxima...", "prominence=" + prominence + " output=[Single Points]");
	close("dapiMaxima");
	close("dapiSeeds");
	selectWindow("dapiSeeds Maxima");
	rename("dapiMaxima");

	// Generate cellMask by enlarging the mask of nuclei
	selectWindow("nucleiMask");
	run("Select None");
	run("Duplicate...", "title=cellMask");
	run("Create Selection");
	type = selectionType();
	if (type != -1) {
		cytoBand = 0;
		run("Enlarge...", "enlarge=" + cytoBand);
		setForegroundColor(0, 0, 0);
		run("Fill", "slice");
	}
	close("nucleiMask");

	selectWindow("dapiMaxima");
	run("Select None");
	run("Restore Selection");
	setBackgroundColor(255, 255, 255);
	run("Clear Outside");
	run("Select None");
	selectWindow("cellMask");
	run("Select All");
	run("Duplicate...", "title=cellEdges");
	run("Find Edges");
	run("Marker-controlled Watershed", "input=cellEdges marker=dapiMaxima mask=cellMask binary calculate use");
	selectWindow("cellEdges-watershed");
	run("8-bit");
	setThreshold(1, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	close("cellEdges");
	close("cellMask");
	close("dapiMaxima");
	close("nuclei");
	selectWindow("cellEdges-watershed");
	rename("cellMask");

	// Seed correction using other channels
	dapiSeedCorrection(phNameLife, cLife, thLife, minSizeLife);
	dapiSeedCorrection(phNameDead, cDead, thDead, minSizeDead);
	
	// Count total number of cells detected
	run("Select None");
	run("Analyze Particles...", "size=0-Infinity pixel show=Masks display clear in_situ");
	nCells = nResults;
	selectWindow("Results");
	run("Clear Results");

	// Analyze particles and phenotype for life marker
	lifeFeatures = findPhenotype(OutDir, MyTitle_short, phNameLife, cLife, thLife, minSizeLife, minMarkerPercLife);
	nLife = lifeFeatures[0];
	lifeIpos = lifeFeatures[1];
	lifeIpos_std = lifeFeatures[2];

	// Analyze particles and phenotype for dead marker
	deadFeatures = findPhenotype(OutDir, MyTitle_short, phNameDead, cDead, thDead, minSizeDead, minMarkerPercDead);
	nDead = deadFeatures[0];
	DeadIpos = deadFeatures[1];
	DeadIpos_std = deadFeatures[2];

	
	//-- Write results to a file named "Quantification_LifeDead.xls"
	run("Clear Results");
	
	// Check if the results file already exists
	if(File.exists(output + File.separator + "Quantification_LifeDead.xls")) {
		// If the file exists, open it and modify
		open(output + File.separator + "Quantification_LifeDead.xls");
		wait(500);
		IJ.renameResults("Results");
		wait(500);
	}
	
	// Record the number of cells, phenotyped cells, and their intensities and percentages
	i = nResults;
	wait(100);
	setResult("[Label]", i, MyTitle_short); 
	setResult("# total cells", i, nCells); 
	setResult("# " + phNameLife + " cells", i, nLife);
	setResult("# " + phNameDead + "+ cells", i, nDead);
	setResult("# Double Positive Cells",i ,nCells-(nLife+nDead));
	setResult("# % " + phNameLife + " cells", i, (nLife / nCells) * 100);
	setResult("# % " + phNameDead + " cells", i, (nDead / nCells) * 100);
	setResult("Iavg of " + phNameLife + "+ cells", i, lifeIpos);
	setResult("Iavg of " + phNameDead + "- cells", i, DeadIpos);
	setResult("Istd of " + phNameLife + "+ cells", i, lifeIpos_std);
	setResult("Istd of " + phNameDead + "- cells", i, DeadIpos_std); 
	
	// Save the results to the file
	saveAs("Results", output + File.separator + "Quantification_LifeDead.xls");
	
	close("*");
	
	// Set batch mode to exit and display
	setBatchMode("exit and display");
	
	// Clear unused memory
	wait(500);
	run("Collect Garbage");
}


/* Function Level 2
	Find_Phenotype = classify cells 
	dapiSeedCorrection = obtain cell seeds from other markers
	openFileFormat = open file depending on the format
*/

function findPhenotype(OutDir,MyTitle_short,phName, ch,thMarker,minSize,minMarkerPerc) {
	// This function classifies cells based on a given marker channel and phenotype criteria.

	// Parameters:
	// OutDir: The directory where the analysis results will be saved.
	// MyTitle_short: Short title of the image.
	// phName: Name of the marker used for phenotyping.
	// ch: Channel number of the marker.
	// thMarker: Threshold value for segmenting the marker signal.
	// minSize: Minimum size of particles to be considered.
	// minMarkerPerc: Minimum percentage of marker-positive cells per cell.

    // Select the image containing all channels
    selectWindow("merge");
    run("Select None");
    // Duplicate the channel containing the marker of interest
    run("Duplicate...", "title=" + phName + "mask duplicate channels=" + ch);
    run("Set Measurements...", "area mean standard modal area_fraction redirect=None decimal=2");

    // Convert the image to 8-bit resolution
    run("8-bit");

    // Subtract background from the image
    rollingRadius = 50;
    run("Subtract Background...", "rolling=" + rollingRadius);

    // Enhance contrast to improve signal visibility
    run("Enhance Contrast", "saturated=0.35");
    run("Apply LUT");
	
	//WaitForUser;
 
    // Segment the signal of the marker
    selectWindow(phName + "mask");
    setAutoThreshold("Default dark");
    getThreshold(lower, upper);
    setThreshold(thMarker, upper);
    setOption("BlackBackground", false);
    run("Convert to Mask");
    
    // Focus on the central area of the image
    //centralAreaMask(phName + "mask");
  
    selectWindow(phName + "mask");  
    run("Median...", "radius=2");
    run("Analyze Particles...", "size=" + minSize + "-Inf circularity=0.2-1.00  pixel show=Masks in_situ");

	//WaitForUser;

    // Detect marker-positive cells in the image
    selectWindow("cellMask");
    run("Select None");
    run("Duplicate...", "title=" + phName);
    roiManager("Reset");
    run("Analyze Particles...", "size=0-Infinity show=Masks add in_situ");
    roiManager("Show None");
    n = roiManager("Count");
    selectWindow(phName);
    run("Select All");
    setBackgroundColor(255, 255, 255);
    run("Clear", "slice");
    wait(100);
    run("Clear Results");
    selectWindow(phName + "mask");
    run("Select None");
    roiManager("Deselect");
    roiManager("Measure");
    selectWindow(phName);
    
    setForegroundColor(0,0,0);
    setBackgroundColor(255, 255, 255);
    

    // Fill in the marker mask with only marker-positive cells
    for (i = 0; i < n; i++) {
        Aperc = getResult("%Area", i);
        if (Aperc >= minMarkerPerc) {
            roiManager("Select", i);
            run("Fill", "slice");
        }
    }

    run("Select None");
    roiManager("Reset");

    // Count the number of marker-positive cells
    selectWindow(phName);
    run("Select None");
    run("Analyze Particles...", "size=0-Infinity pixel show=Masks display clear in_situ");
    nMarkerCells = nResults;

    // Phenotype analysis
    print("Number of Phenotype+ cells: " + nMarkerCells);
    
	
	//--Negative cell mask:
	selectWindow("cellMask");
	run("Duplicate...", "title=negativeMask ignore duplicate");
	
	imageCalculator("XOR", "negativeMask",phName);

    // Measure intensity of positive and negative cells
    run("Set Measurements...", "area mean standard redirect=None decimal=2");
    selectWindow("merge");
    Stack.setChannel(ch);

    // Positive cells
    selectWindow(phName);
    run("Create Selection");
    type = selectionType();
    if (type != -1) {
        run("Clear Results");
        selectWindow("merge");
        Stack.setChannel(ch);
        run("Restore Selection");
        run("Measure");
        Ipos = getResult("Mean", 0);
        Ipos_std = getResult("StdDev", 0);
    } else {
        Ipos = 0;
        Ipos_std = 0;
    }

    // Negative cells
    selectWindow("negativeMask");
    run("Create Selection");
    type = selectionType();
    if (type != -1) {
        run("Clear Results");
        selectWindow("merge");
        Stack.setChannel(ch);
        run("Restore Selection");
        run("Measure");
        Ineg = getResult("Mean", 0);
        Ineg_std = getResult("StdDev", 0);
    } else {
        Ineg = 0;
        Ineg_std = 0;
    }

    // Save detections
    roiManager("Reset");
    selectWindow("cellMask");
    run("Create Selection");
    type = selectionType();
    if (type == -1) {
        makeRectangle(1, 1, 1, 1);
    }
    roiManager("Add");

    selectWindow(phName);
    run("Create Selection");
    type = selectionType();
    if (type == -1) {
        makeRectangle(1, 1, 1, 1);
    }
    roiManager("Add");
    close(phName);
    close(phName + "mask");
    
    selectWindow(MyTitle_short);
    run("Duplicate...", "title=b duplicate channels=1-3");
    close(MyTitle_short);
    selectWindow("b");
    rename(MyTitle_short);
    run("Make Composite");
    run("RGB Color");
    setBatchMode("show");
    roiManager("Select", 0);
    roiManager("Set Color", "#00FFFF");
    roiManager("rename", "AllCells");
    roiManager("Set Line Width", 1);
    run("Flatten");
    setBatchMode("show");
    wait(200);

	selectWindow(MyTitle_short+" (RGB)-1");
    roiManager("Select", 1);
    roiManager("Set Color", "#FF00FF");
    roiManager("rename", "Phenotype+");
    roiManager("Set Line Width", 1);
    run("Flatten");   
    setBatchMode("show");
    wait(200);
   
	selectWindow("merge");
	Overlay.show;
	Overlay.activateSelection(0);
	selectWindow(MyTitle_short+" (RGB)-2");
	run("Restore Selection");
    run("Flatten");
    setBatchMode("show");
    wait(200);
    	
  
    saveAs("Jpeg", OutDir + File.separator + MyTitle_short + "_" + phName + "_analyzed.jpg");
    wait(200);
    
    selectWindow("merge");
	Overlay.hide;
	run("Select None");
    
    close(MyTitle_short + "_" + phName + "_analyzed.jpg");
    close("*(RGB)*");
    close("negativeMask");

    // Return phenotype features
    phenotypeFeatures = newArray(nMarkerCells, Ipos, Ipos_std);
    return phenotypeFeatures;
}

function dapiSeedCorrection(phName,ch,thMarker,minSize){
	// This function obtains cell seeds from other markers.

	// Parameters:
	// phName: Name of the marker used for seed correction.
	// ch: Channel number of the marker.
	// thMarker: Threshold value for segmenting the marker signal.
	// minSize: Minimum size of particles to be considered.

	// Detection of GFP/PI Seeds - DAPI may fail
	selectWindow("merge");
	run("Duplicate...", "title=" + phName + "mask duplicate channels=" + ch);
	
	// Convert to 8-bit
	run("8-bit");
	
	// Preprocessing
	rollingRadius = 60;
	run("Subtract Background...", "rolling=" + rollingRadius);
	run("Enhance Contrast", "saturated=0.1");
	run("Apply LUT");
	
	rollingRadius = 40;
	run("Subtract Background...", "rolling=" + rollingRadius);
	run("Median...", "radius=2");
	
	//WaitForUser;
	
	// Segmenting phName signal	
	selectWindow(phName + "mask");
	setAutoThreshold("Default dark");
	getThreshold(lower, upper);
	setThreshold(thMarker, upper);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	
	// Focus central Area
	centralAreaMask(phName + "mask");
	selectWindow(phName + "mask");
	
	run("Median...", "radius=2");

	//WaitForUser;


	// Analyze particles
	run("Analyze Particles...", "size=" + minSize + "-Inf circularity=0.2-1.00  pixel show=Masks in_situ");
	run("Distance Map");
	run("Find Maxima...", "prominence=1 exclude light output=[Single Points]");
	run("Create Selection");
	type = selectionType();
	if (type != -1) {
		run("Enlarge...", "enlarge=4 pixel");
		setForegroundColor(0, 0, 0);
		run("Fill", "slice");
		run("Select None");
	}
	
	imageCalculator("Subtract create", phName + "mask Maxima", "cellMask");
	rename("newSeeds");
	run("Analyze Particles...", "size=20-Infinity circularity=0.20-1.00 show=Masks composite in_situ");

	//WaitForUser;


	close(phName + "mask Maxima");
	close(phName + "mask");
	imageCalculator("OR create", "newSeeds", "cellMask");
	close("cellMask");
	rename("cellMask");
	close("newSeeds");
	
}



function centralAreaMask(name) {
	// Function centralAreaMask:
	// This function focuses on the central area of the image.
	
	// Parameters:
	// - name: Name of the image window.
		
	// Focus on central area
	selectWindow("merge");
	Overlay.show;
	Overlay.activateSelection(0);
	selectWindow(name);
	run("Restore Selection");
	setForegroundColor(0, 0, 0);
	setBackgroundColor(255, 255, 255);
	run("Clear Outside");
	setBackgroundColor(0, 0, 0);
	setForegroundColor(255, 255, 255);
	run("Select None");
	
	selectWindow("merge");
	Overlay.hide;
	run("Select None");

		
}



function openFileFormat(file) {
	// Function openFileFormat:
	// This function opens files based on their format.
	
	// Parameters:
	// - file: File path.
	
	
	if (endsWith(file, ".jpg") || endsWith(file, ".tif")) {
		open(file);
	} else if (endsWith(file, ".czi") || endsWith(file, ".svs")) {
		run("Bio-Formats Importer", "open=[" + file + "] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	}
}




