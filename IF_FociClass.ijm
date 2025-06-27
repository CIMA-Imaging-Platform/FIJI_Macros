/* 
 *  FOCI CLASSIFICATION
 * 
 * TOOL for AUTOMATIC DETECTION OF CELL PHENOTYPES
 * Target User: Borja Ruiz.
 *  
 *  Images: 
 *    - Confocal Microscopy : 2 channel images.
 *    - 16 bits
 *    - Format .czi   
 		  
 *  GUI Requierments:
 *    - Single and Batch Buttons
 *    - User must choose parameters
 *    
 *  Algorithms
 *    - Nuclei Segmentation : MARKER-CONTROLLED WATERSHED  
 * 		   	Use DAPI to segment nuclei. 
 *    		Preprocessing: flagConstrast ; radSmooth
 *    		Watershed: prominence
 *    	
 *    - Phenotyping:
 *    		Detect +/- Cells Presence Rodamine inside Nuclei	
 *    		cytoBand: radius region if marker is cytoplasm or nuclear.
 *    		Masking AND operator: cell and phenotypes. 
 *    	
 *   OUTPUT Results:
		setResult("Label", i, MyTitle); 
		setResult("# total cells", i, nCells); 
		setResult("# Rod+ cells", i, nRod);
		setResult("# % Rod+ cells", i, nRod/nCells);
		setResult("Iavg of Rod+ cells", i, Ipos);
		setResult("Iavg of Rod- cells", i, Ineg);
		setResult("Istd of Rod+ cells", i, Ipos_std);
		setResult("Istd of Rod- cells", i, Ineg_std); 
 *   
 *     
 *  Author: Tomás Muñoz Santoro
 *  Date : 22/06/2024
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


function info(){
	scripttitle= "Foci DNA Damage Cell Classification and Quantification";
	version= "1.02";
	date= "22/06/2024";
	
	//image1="../templateImages/cartilage.jpg";
	//descriptionActionsTools="
	
	showMessage("ImageJ Script", "<html>"
	    +"<style>h{margin-top: 5px; margin-bottom: 5px;} p{margin: 0px;padding: 0px;} ol{margin-left: 20px;padding: 5px;} #list-style-3 {list-style-type: circle;.container {max-width: 1200px; margin: 0 auto; padding: 0px; }</style>"
	     +"<div class='container' style='width: 800px; height: 500px; overflow: auto;'>" // Set custom dimensions
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
	    +"<ul id=list-style-3><font size=2  i><li>Confocal : 2 channel DAPI, Rodamine</li><li>16 bit Images </li><li>Format .czi</li></i></ul>"
	    +"<p><font size=3 i>Action tools (Buttons)</i></p>"
	    +"<ol><font size=2  i><li>Im : Single File Quantification</li>"
	    +"<li> Dir : Batch Mode. Select Folder: All images within the folder will be quantified</li></ol>"
	    +"<p><font size=3  i>Parameters</i></p>"
	    +"<p2><font size=3  i>Nuclear Segmentation: Please adjust Parameters to your images<p2>"
	    +"<ul id=list-style-3><font size=2  i><li>DAPI threshold:Signal Threshold, Higher Number means Less Area Segmented</li>"
	    +"<li>Prominence Maxima Detection: Difference between Signal Local Maximas. Higher Number multiple close cells could be segmented as just one.</li>"
	    +"<li>Radius for smoothing: Use in case DAPI within the cell presents heterogeneous signal.</li></ul></p2>"
	    +"<p><font size=3  i>Foci Classification: Determine the theshold between +/- Cells</i></p>"
	    +"<ul id=list-style-3><li>Rodamine Threshold: Signal Threshold to determine Rodamine Positive and Negative Cells, Higher Number means Less Area Segmented</li>"
	    +"</li>Rod Cell %: % Area within the cell with Rodamine. Higher % means, Less cells will be positive</ul>"
	    +"<p><font size=3  i>Quantification Results (Excel) </i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>ImageName</li><li>#Cells</li><li>Rod+ Cells</li><li>% Rod+ Cells</li><li>Mean and Std Intensity of Rod+ and Rod- Cells</li></i></ul>"
	    +"<h0><font size=5> </h0>"
	    +"");
	
	//+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
	
}
	


// Enable debugging and expandability options for better logging and array handling.
setOption("DebugMode", true);
setOption("ExpandableArrays", true);
setOption("WaitForCompletion", true);

// Disable row indexes in tables for cleaner presentation.
Table.showRowIndexes(false);

// Define default parameter values for analysis
var cDAPI = 1, cRod = 2;                // Channel indices for DAPI and Rodamine
var thNucl = 800, thRod = 400;          // Threshold values for nuclei and rodamine
var minMarkerPerc = 5;                  // Minimum percentage of marker presence per cell
var flagContrast = false;               // Flag to indicate whether contrast adjustment is needed
var radSmooth = 4;                      // Radius for smoothing
var prominence = 200;                   // Prominence for maxima detection
var cytoBand = 0;                       // Cytoplasmic band (unused in the current code)

/**
 * Macro for processing a single image file.
 * Asks the user to select an image file and specify analysis parameters,
 * then performs segmentation and analysis using the `qif` function.
 */
macro "QIF Action Tool 1 - Cf00T2d15IT6d10m" {
    info(); // Display plugin or macro information.
    run("Close All"); // Close all open images.
    wait(500); // Small delay for cleanup.
    run("Collect Garbage"); // Free up memory.

    run("ROI Manager..."); // Open ROI Manager.

    // Prompt the user to select a single file for analysis.
    name = File.openDialog("Select File");
    print("Processing " + name); // Log the selected file name.

    // Create a dialog to collect user-defined parameters for analysis.
    Dialog.create("Parameters for the analysis");
    Dialog.addMessage("Cell segmentation");
    Dialog.addNumber("DAPI threshold", thNucl);
    Dialog.addNumber("Prominence for maxima detection", prominence);
    Dialog.addNumber("Radius for smoothing", radSmooth);
    Dialog.addCheckbox("Adjust contrast", flagContrast);

    Dialog.addMessage("FOCI Marker");
    Dialog.addNumber("Rodamine threshold", thRod);
    Dialog.addNumber("Min presence of positive marker per cell (%)", minMarkerPerc);

    Dialog.show(); // Display the dialog.

    // Retrieve user inputs from the dialog.
    thNucl = Dialog.getNumber();
    prominence = Dialog.getNumber();
    radSmooth = Dialog.getNumber();
    flagContrast = Dialog.getCheckbox();
    thRod = Dialog.getNumber();
    minMarkerPerc = Dialog.getNumber();

    // Perform the analysis using the `qif` function.
    qif("-", "-", name, thNucl, prominence, flagContrast, thRod, minMarkerPerc, radSmooth);

    // Notify the user when the analysis is complete.
    showMessage("QIF done!");
}

/**
 * Macro for processing multiple image files in batch mode.
 * Prompts the user to select a directory and specify analysis parameters,
 * then processes all compatible image files in the directory using the `qif` function.
 */
macro "QIF Action Tool 2 - C00fT0b11DT9b09iTcb09r" {
    info(); // Display plugin or macro information.

    run("Close All"); // Close all open images.
    run("ROI Manager..."); // Open ROI Manager.
    wait(500); // Small delay for cleanup.
    run("Collect Garbage"); // Free up memory.

    // Prompt the user to select an input directory.
    InDir = getDirectory("Choose images' directory");
    list = getFileList(InDir); // Get the list of files in the directory.
    L = lengthOf(list); // Number of files in the directory.

    // Create a dialog to collect user-defined parameters for analysis.
    Dialog.create("Parameters for the analysis");
    Dialog.addMessage("Cell segmentation");
    Dialog.addNumber("DAPI threshold", thNucl);
    Dialog.addNumber("Prominence for maxima detection", prominence);
    Dialog.addNumber("Radius for smoothing", radSmooth);
    Dialog.addCheckbox("Adjust contrast", flagContrast);

    Dialog.addMessage("FOCI Marker");
    Dialog.addNumber("Rodamine threshold", thRod);
    Dialog.addNumber("Min presence of positive marker per cell (%)", minMarkerPerc);

    Dialog.show(); // Display the dialog.

    // Retrieve user inputs from the dialog.
    thNucl = Dialog.getNumber();
    prominence = Dialog.getNumber();
    radSmooth = Dialog.getNumber();
    flagContrast = Dialog.getCheckbox();
    thRod = Dialog.getNumber();
    minMarkerPerc = Dialog.getNumber();

    // Loop through the list of files and process each one.
    for (j = 0; j < L; j++) {
        if (endsWith(list[j], "tif") || endsWith(list[j], "czi")) {
            name = list[j]; // File name
            print("Processing " + list[j]); // Log the file being processed.

            // Perform analysis on the current file using the `qif` function.
            qif(InDir, InDir, list[j], thNucl, prominence, flagContrast, thRod, minMarkerPerc, radSmooth);
        }

        // Close all open images.
        close("*");
    }

    // Notify the user when the batch analysis is complete.
    showMessage("QIF done!");
}


/* Function Level 1
	qif: quantify inmunoFluorescence
*/


function qif(output,InDir,name,thNucl,prominence,flagContrast,thRod,minMarkerPerc,radSmooth)
{
	// Function: qif
	// Description: Processes an image for quantification of phenotype-specific markers. 
	//              Detects and measures marker-positive cells, calculates intensity metrics, and saves results.
	// Input Parameters:
	//   - output: Directory for saving output files
	//   - InDir: Input directory for loading images ("-" to use a single file)
	//   - name: Image name
	//   - thNucl: Threshold for nuclei segmentation
	//   - prominence: Prominence value for finding maxima in nuclei
	//   - flagContrast: Boolean flag to enhance contrast
	//   - thRod: Threshold for marker detection
	//   - minMarkerPerc: Minimum percentage of marker-positive pixels
	//   - radSmooth: Radius for smoothing during preprocessing	

	if (InDir=="-") {
		openFileFormat(name);
		}
	else {
		file=InDir+name;
		openFileFormat(file);
		}


	/* For testing
	cDAPI=1;
	radSmooth=4;
	prominence=200;
	thNucl=660;
	flagContrast=false;*/
	
	 // Initialize variables and directories
    roiManager("Reset");
    run("Clear Results");
    MyTitle = getTitle(); // Get the image title
    output = getInfo("image.directory"); // Get the output directory
	
	setBatchMode(true);
	
    // Create output directory for analyzed images
    OutDir = output + File.separator + "AnalyzedImages";
    File.makeDirectory(OutDir);

    // Extract base name of the file
    aa = split(MyTitle, ".");
    MyTitle_short = aa[0];
	
    // Prepare image: Keep specific channels and remove autofluorescence
    run("Duplicate...", "title=orig duplicate channels=1-7");
    run("Make Composite", "display=Composite");

    getDimensions(width, height, channels, slices, frames);

    Stack.setChannel(cDAPI); // Set to DAPI channel
    if (flagContrast) {
        run("Enhance Contrast", "saturated=0.35"); // Enhance contrast if flag is true
    }
    Stack.setDisplayMode("composite");
    wait(100);

    run("RGB Color");
    rename("merge");
	
	run("Colors...", "foreground=black background=white selection=green");
	run("Set Measurements...", "area mean standard modal area_fraction redirect=None decimal=2");

	// Nuclei segmentation from DAPI channel
    selectWindow("orig");
    run("Duplicate...", "title=nucleiMask duplicate channels=" + cDAPI);

    if (flagContrast) {
        run("Enhance Contrast", "saturated=0.35");
    }

    run("Mean...", "radius=" + radSmooth);
    run("Find Maxima...", "prominence=" + prominence + " output=[Single Points]");
    rename("dapiMaxima");

    selectWindow("nucleiMask");
    setAutoThreshold("Default dark");
    getThreshold(lower, upper);
    setThreshold(thNucl, upper);
    setOption("BlackBackground", false);
    run("Convert to Mask");
    run("Median...", "radius=2");
    run("Fill Holes");
    run("Select All");
    run("Analyze Particles...", "size=50-Infinity pixel show=Masks in_situ");
	
	// Create cell mask by enlarging the nuclei mask
    run("Duplicate...", "title=cellMask");
    run("Create Selection");
    type = selectionType();
    if (type != -1) {
        run("Enlarge...", "enlarge=" + cytoBand);
        setForegroundColor(0, 0, 0);
        run("Fill", "slice");
    }

    // Prepare edges for marker-controlled watershed
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
	
	// MARKER-CONTROLLED WATERSHED
	run("Marker-controlled Watershed", "input=cellEdges marker=dapiMaxima mask=cellMask binary calculate use");
	close("cellEdges");
	close("cellMask");
	close("dapiMaxima");

    selectWindow("cellEdges-watershed");
    run("8-bit");
    setThreshold(1, 255);
    setOption("BlackBackground", false);
    run("Convert to Mask");
    rename("cellMask");

   	run("Select None");
	run("Analyze Particles...", "size=0-Infinity pixel show=Masks display clear in_situ");
	nCells = nResults;
	selectWindow("Results");
	run("Clear Results");
	
	setBatchMode("exit and display");
	
	
	////////////////////
	//--PHENOTYPING...
	////////////////////
	
	// Identify Rod+ cells and calculate the number of marker-positive cells
	nRod = findPhenotype("Rodamine", cRod, thRod, minMarkerPerc, "nuclear");
	print("Number of Rod+ cells: " + nRod);
	
	// Create a mask for Rod- cells by excluding Rod+ regions
	imageCalculator("XOR", "cellMask", "Rodamine");
	
	// Measure intensity values for Rod+ (positive) and Rod- (negative) cells
	run("Set Measurements...", "area mean standard redirect=None decimal=2");
	selectWindow("orig");
	Stack.setChannel(cRod);
	
	// Measure average and standard deviation of intensity for positive cells
	selectWindow("Rodamine");
	run("Create Selection");
	type = selectionType();
	if (type != -1) {
	    run("Clear Results");
	    selectWindow("orig");
	    run("Restore Selection");
	    Stack.setChannel(cRod);
	    run("Measure");
	    Ipos = getResult("Mean", 0);
	    Ipos_std = getResult("StdDev", 0);
	} else {
	    Ipos = 0;
	    Ipos_std = 0;
	}
	
	// Measure average and standard deviation of intensity for negative cells
	selectWindow("cellMask");
	run("Create Selection");
	type = selectionType();
	if (type != -1) {
	    run("Clear Results");
	    selectWindow("orig");
	    run("Restore Selection");
	    Stack.setChannel(cRod);
	    run("Measure");
	    Ineg = getResult("Mean", 0);
	    Ineg_std = getResult("StdDev", 0);
	} else {
	    Ineg = 0;
	    Ineg_std = 0;
	}
	
	
	// Save results to a quantification file, appending if it already exists
	run("Clear Results");
	if (File.exists(output + File.separator + "IF_FociClass_QuantificationResults.xls")) {
	    open(output + File.separator + "IF_FociClass_QuantificationResults.xls");
	    wait(500);
	    IJ.renameResults("Results");
	    wait(500);
	}
	i = nResults;
	setResult("Label", i, MyTitle);
	setResult("# total cells", i, nCells);
	setResult("# Rod+ cells", i, nRod);
	setResult("# % Rod+ cells", i, nRod / nCells);
	setResult("Iavg of Rod+ cells", i, Ipos);
	setResult("Iavg of Rod- cells", i, Ineg);
	setResult("Istd of Rod+ cells", i, Ipos_std);
	setResult("Istd of Rod- cells", i, Ineg_std);
	saveAs("Results", output + File.separator + "IF_FociClass_QuantificationResults.xls");
	

	// SAVE DETECTIONS

	// Add cell masks and marker masks to ROI Manager for later visualization
	roiManager("Reset");
	selectWindow("cellMask");
	run("Create Selection");
	type = selectionType();
	if (type == -1) { makeRectangle(1, 1, 1, 1); }
	roiManager("Add");
	close();
	
	selectWindow("Rodamine");
	run("Create Selection");
	type = selectionType();
	if (type == -1) { makeRectangle(1, 1, 1, 1); }
	roiManager("Add");
	close();
	
	// Annotate and flatten ROIs on the merged image
	selectWindow("merge");
	roiManager("Select", 0);
	roiManager("Set Color", "#00FFFF");
	roiManager("rename", "AllCells");
	roiManager("Set Line Width", 1);
	run("Flatten");
	wait(100);
	
	selectWindow("merge-1");
	roiManager("Select", 1);
	roiManager("Set Color", "#FF00FF");
	roiManager("rename", "Rod+");
	roiManager("Set Line Width", 1);
	run("Flatten");
	saveAs("Jpeg", OutDir + File.separator + MyTitle_short + "_analyzed.jpg");
	wait(100);
	rename(MyTitle_short + "_analyzed.jpg");
	
	// Save annotated Rodamine channel separately
	selectWindow(MyTitle);
	run("Select None");
	run("Duplicate...", "title=Rod duplicate channels=" + cRod);
	
	roiManager("Select", 0);
	roiManager("Set Color", "#00FFFF");
	roiManager("rename", "AllCells");
	roiManager("Set Line Width", 1);
	run("Flatten");
	wait(200);
	
	selectWindow("Rod-1");
	roiManager("Select", 1);
	roiManager("Set Color", "#FF00FF");
	roiManager("rename", "Rod+");
	roiManager("Set Line Width", 1);
	run("Flatten");
	saveAs("Jpeg", OutDir + File.separator + MyTitle_short + "_Rhodamine.jpg");
	wait(200);
	rename(MyTitle_short + "_Rhodamine.jpg");
	
	// Cleanup temporary files and windows, and release memory
	close("orig");
	close("m*");
	close("Rod*");
	wait(500);
	run("Collect Garbage");
		
	//showMessage("Done!");

}

/* Function Level 2
	Find_Phenotype
	openFileFormat
*/


function findPhenotype(phName, ch, thMarker, minMarkerPerc, markerLoc) {
	

	// Function: findPhenotype
	// Description: Detects and quantifies cells positive for a specific marker in either the nuclear or cytoplasmic region.
	// Input Parameters:
	//   - phName: Phenotype name (e.g., "Rodamine")
	//   - ch: Channel to use for marker detection
	//   - thMarker: Threshold value for marker detection
	//   - minMarkerPerc: Minimum percentage of marker-positive pixels in a cell
	//   - markerLoc: Location of the marker ("nuclear" or "cytoplasmic")
	// Output: Number of marker-positive cells.
	    
    // Example parameter values (for reference/testing purposes)
    
    /*
    phName = "Rodamine";
    thMarker = 350;
    ch = 2;
    markerLoc = "nuclear";
    */

    // Determine the mask to use based on the marker location
    if (markerLoc == "nuclear") {
        maskToUse = "nucleiMask"; // Use nuclei mask for nuclear marker
    } else {
        maskToUse = "cellMask"; // Use cell mask for cytoplasmic marker
    }

    // Duplicate the selected channel for processing
    selectWindow("orig");
    run("Select None");
    run("Duplicate...", "title=" + phName + "mask duplicate channels=" + ch);
    run("Set Measurements...", "area mean standard modal area_fraction redirect=None decimal=2");

    // Background removal
    selectWindow(maskToUse);
    run("Invert"); // Invert the mask to prepare for selection
    run("Create Selection");
    run("Select None");
    run("Invert");
    selectWindow(phName + "mask");
    run("Restore Selection");
    run("Measure");
    bg = getResult("Mode", 0); // Measure background intensity
    run("Select None");
    run("Subtract...", "value=" + bg); // Subtract background value
    selectWindow(phName + "mask");
    run("Clear Results");

    // Marker detection using thresholding
    selectWindow(phName + "mask");
    setAutoThreshold("Default dark");
    getThreshold(lower, upper); // Get current threshold range
    // print(thMarker); // Print the marker threshold value for debugging
    setThreshold(thMarker, upper); // Apply the marker threshold
    setOption("BlackBackground", false);
    run("Convert to Mask");

    // Perform AND operation between marker mask and cell/tumor mask
    imageCalculator("AND", phName + "mask", maskToUse);

    // Detect marker-positive cells in the tumor
    selectWindow("cellMask");
    run("Select None");
    run("Duplicate...", "title=" + phName);
    roiManager("Reset");
    run("Analyze Particles...", "size=0-Infinity show=Masks add in_situ");
    roiManager("Show None");
    n = roiManager("Count"); // Get total ROI count
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
    selectWindow(phName); // Fill marker mask with only marker-positive cells

    // Loop through detected cells and filter based on percentage of marker-positive pixels
    for (i = 0; i < n; i++) {
        Aperc = getResult("%Area", i); // Get percentage area of marker-positive pixels
        if (Aperc >= minMarkerPerc) { // Check if it meets the minimum percentage
            roiManager("Select", i);
            run("Fill", "slice"); // Fill in the marker-positive cell
        }
    }

    run("Select None");
    roiManager("Reset");

    // Count the number of marker-positive cells
    selectWindow(phName);
    run("Select None");
    run("Analyze Particles...", "size=0-Infinity pixel show=Masks display clear in_situ");
    nMarkerCells = nResults; // Store the count of marker-positive cells

    // Clean up temporary images
    selectWindow(phName + "mask");
    close();
    selectWindow(phName);

    return nMarkerCells; // Return the number of marker-positive cells
}



function openFileFormat(file) {
	// Function openFileFormat:
	// This function opens files based on their format.
	
	// Parameters:
	// @param {string} : File path.
	
	
	if (endsWith(file, ".jpg") || endsWith(file, ".tif")) {
		open(file);
	} else if (endsWith(file, ".czi") || endsWith(file, ".svs")) {
		run("Bio-Formats Importer", "open=[" + file + "] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	}
}



