

function macroInfo(){

	 /* TOOL for AUTOMATIC CLASSIFICATION OF CELL PHENOTYPES 
	 *  Target User: Charlie. Carlos Sobejano
	 */

	scripttitle= "CHARACTERIZATION OF MARKER PHENOTYPES";
	version= "1.01";
	date= "2024";
	

	//  Tests Images:

	imageacquisition="Confocal Microscopy : 1 channel images.";
	imageType="8 or 16 bits";  
	voxelSize="Voxel size: um xyz";
	format="Format: Zeiss .czi";   
 
	 /*  GUI User requirements:
	     - Choose parameters.
	     - Single File and Batch Mode
	     
	   Important Parameters: click Im or Dir + right button.
	 
	 
	 *  Algorithms
	 *    - cell Segmentation : MARKER-CONTROLLED WATERSHED  
	 * 		   	Use cell to segment cell. 
	 *    		Preprocessing: flagcontrast ; 
	 *    		Watershed: prominence
	 *    	
	 *    - phenotypic:
	 *    		Detect +/- Cells Presence Phenotypeamine inside cell	
	 *    		cytoBand: radius region if marker is cytoplasm or nuclear.
	 *    		Masking AND operator: cell and phenotypes. 
	 */
 
	//Preprocessing Params
	parameter1="Background Removal and Adjust contrast checkBox";
		
	//  segmentation options:
	parameter2=" Phenotype threshold";
	parameter3="Min Size marker";
	
	//  2 Action tools:
	button1="Im: Single File processing. Use Single file processing for fine tunning parameters";
	button2="Dir: Batch Mode. Please tune parameters before using Batchmode";

	//  OUTPUT
	
	// Analyzed Images with ROIs

	excel="Quantification_.xls";
	feature1="Image Label"; 
	feature2="Area(um2) FOV";
	feature3="Area(um2) of  phName + cells";
	feature4="Ratio of phName Area Positive";
	feature5="Iavg of  phName +  cells";
	feature6="Istd of  phName +  cells";
	
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
	    +"<ul id=list-style-3><font size=2  i><li>"+imageacquisition +"</li><li>"+imageType+"</li><li>"+voxelSize+"</li><li>"+format+"</li></ul>"
	    +"<p><font size=3 i>Action tools (Buttons)</i></p>"
	    +"<ol><font size=2  i><li>"+button1+"</li>"
	    +"<li>"+button2+"</li></ol>"
	    +"<p><font size=3  i>PARAMETERS: </i></p>"
	    +"<ul id=list-style-3><font size=2  i>"
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li>"
	    +"<li>"+parameter3+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li>"
	    +"<li>"+feature5+"</li><li>"+feature6+"</li></ul>"
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
var flagContrast = true, flagSubstractBackground = true, rollingRadius=100, radSmooth=2;

// Define default threshold and parameter values for segmentation.
var phName="GFP", chMarker=1, thMarker = 35, prominence = 10, minSize = 50;



// SINGLE FILE 

// Define a macro for processing a single file.
macro "IF_PhenotypeQuant Action Tool 1 - Cf00T2d15IT6d10m" {

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
    
    Dialog.addString("Phenotype", "GFP");
	Dialog.addNumber("Marker Channel", chMarker);
  
	// Preprocessing Params section:
    Dialog.addMessage("Preprocessing parameters")
    Dialog.addCheckbox("Background Removal", flagSubstractBackground);
    Dialog.addNumber("Background kernel", rollingRadius);
    Dialog.addNumber("Smoothing kernel", radSmooth);
    Dialog.addCheckbox("Adjust contrast", flagContrast);
        
    // Segmentation options:
    Dialog.addMessage("cell segmentation parameters")
    Dialog.addNumber("cell threshold", thMarker);
  
    // Phenotyping section:
    Dialog.addNumber("Min Size marker", minSize);
    // Show the dialog box.
    Dialog.show();	
    
    phName = Dialog.getString();
    chMarker = Dialog.getNumber();
    
    // Retrieve parameters from the dialog box.
    flagSubstractBackground = Dialog.getCheckbox();
    rollingRadius = Dialog.getNumber();
   	radSmooth = Dialog.getNumber();
    flagContrast = Dialog.getCheckbox();	
    
    thMarker = Dialog.getNumber();
    minSize = Dialog.getNumber();
    batch=false;
    
    // Call the main function for cell classification and display completion message.
    IFphenotype("-", "-", name,batch,chMarker,flagContrast, flagSubstractBackground, rollingRadius,radSmooth,phName, thMarker,minSize);
    showMessage("IF_Quantification done!");

}

// BATCH MODE
// Define a macro for processing multiple files in batch mode.

macro "IF_PhenotypeQuant Action Tool 2 - C00fT0b11DT9b09iTcb09r"{

	
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
    
    Dialog.addString("Phenotype", "GFP");
	Dialog.addNumber("Marker Channel", chMarker);
  
	// Preprocessing Params section:
    Dialog.addMessage("Preprocessing parameters")
    Dialog.addCheckbox("Background Removal", flagSubstractBackground);
    Dialog.addNumber("Background kernel", rollingRadius);
    Dialog.addNumber("Smoothing kernel", radSmooth);
    Dialog.addCheckbox("Adjust contrast", flagContrast);
        
    // Segmentation options:
    Dialog.addMessage("cell segmentation parameters")
    Dialog.addNumber("cell threshold", thMarker);
  
    // Phenotyping section:
    Dialog.addNumber("Min Size marker", minSize);
    // Show the dialog box.
    Dialog.show();	
    
    phName = Dialog.getString();
    chMarker = Dialog.getNumber();
    
    // Retrieve parameters from the dialog box.
    flagSubstractBackground = Dialog.getCheckbox();
    rollingRadius = Dialog.getNumber();
   	radSmooth = Dialog.getNumber();
    flagContrast = Dialog.getCheckbox();	
    
    thMarker = Dialog.getNumber();
    minSize = Dialog.getNumber();
	batch=true;
		
	// Process in batch Mode
	for (j = 0; j < L; j++)
	{
		// Analyze images with supported extensions (tif, czi)
		if (endsWith(list[j], "tif") || endsWith(list[j], "czi")) {
			// Print the processing message
			name = list[j];
			print("Processing " + list[j]);
			
			// Call the main function for cell classification
			IFphenotype(InDir, InDir, list[j],batch,chMarker,flagContrast, flagSubstractBackground, rollingRadius,radSmooth,phName, thMarker,minSize);
		}
		// Close all open windows after processing each image
		close("*");
	}
	
	// Display completion message
    showMessage("IF_Quantification done!");

}

/* Function Level 1
	IF_CellClass: quantify inmunoFluorescence
*/


function IFphenotype(output,InDir,name,batch,chMarker,flagContrast, flagSubstractBackground, rollingRadius,radSmooth,phName, thMarker,minSize){
	/*
	Summary:
	This function performs cell classification and phenotype analysis on images using provided parameters.
	It segments cell, adjusts contrast, removes background, and identifies cell markers to classify cells.
	Phenotype analysis is conducted for both  and  markers, and results are saved to a spreadsheet.
	
	Parameters:
	- output: Output directory for saving results.
	- InDir: Directory containing input images.
	- name: Name of the current image being processed.
	- flagContrast: Flag for contrast adjustment.
	- flagSubstractBackground: Flag for background subtraction.
	- thMarker: Threshold for cell segmentation.
	- phName: Name of the  marker.
	- minSize: Minimum size for  marker.
	*/

	// Clear ROI manager and results table
	roiManager("Reset");
	run("Clear Results");

	// Set Colors config and measurements
	run("Colors...", "foreground=white background=black selection=green");
	run("Set Measurements...", "area mean standard modal area_fraction redirect=None decimal=4");

	// Set batch mode
	setBatchMode(batch);

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
	
	getDimensions(width, height, channels, slices, frames);
	getVoxelSize(rx, ry, depth, unit);
	
	
	areaFOV=(width*height)*(rx*ry);
		
	// Keep only marker channels and eliminate autofluorescence
	run("Duplicate...", "title=orig duplicate channels="+chMarker);
	run("Duplicate...", "title=Marker duplicate channels="+chMarker);
	wait(100);
	
	// SEGMENT Marker signal:
	selectWindow("Marker");
	run("Select None");
	run("Duplicate...", "title=markerMask duplicate");
	run("8-bit");
	
		
	// Preprocessing
	
	if (flagSubstractBackground) {
		rollingRadius = 150;
		run("Subtract Background...", "rolling=" + rollingRadius);
	}

	if (flagContrast) {
		
		run("Select None");
	    //run("Brightness/Contrast...");
		run("Enhance Contrast", "saturated=0.35");
		run("Apply LUT");
    
	}
	
	//radSmooth=4
	run("Mean...", "radius="+radSmooth);

	// CELL MASK FROM cell
	selectWindow("markerMask");
	setAutoThreshold("Default dark");
	getThreshold(lower, upper);
	setThreshold(15, upper);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	
	run("Median...", "radius=2");
		
	// Count total number of cells detected
	run("Clear Results");
	close("Results");
	run("Select None");
	run("Set Measurements...", "area mean standard modal shape area_fraction redirect=None decimal=4");
	selectWindow("markerMask");
	run("Analyze Particles...", "size="+minSize+"-Infinity pixel show=Masks add clear in_situ");
	run("Create Selection");
	selectWindow("orig");
	run("Restore Selection");
	run("Measure");
	areaPos=getResult("Area", 0);
	Ipos_avg=getResult("Mean", 0);
	Ipos_std=getResult("StdDev", 0);
	//nCells=roiManager("count");
		
	//-- Write results to a file named "Quantification_.xls"
	run("Clear Results");
	close("Results");
	
	// Check if the results file already exists
	if(File.exists(output + File.separator + "Quantification_"+phName+".xls")) {
		// If the file exists, open it and modify
		open(output + File.separator + "Quantification_"+phName+".xls");
		wait(500);
		IJ.renameResults("Results");
		wait(500);
	}
	
	// Record the number of cells, phenotyped cells, and their intensities and percentages
	i = nResults;
	wait(100);
	setResult("[Label]", i, MyTitle_short); 
	//setResult("# " + phName + " cells", i, nCells);
	setResult("Area (um^2) of " + phName + "+ cells", i, areaPos);
	setResult("Area (um^2) FOV", i,areaFOV);
	setResult("Ratio of" + phName + " Area Positive",i,areaPos/areaFOV);
	setResult("Iavg of " + phName + "+ cells", i, Ipos_avg);
	setResult("Istd of " + phName + "+ cells", i, Ipos_std);
	// Save the results to the file
	saveAs("Results", output + File.separator + "Quantification_"+phName+".xls");
	
	// Set batch mode to exit and display
	setBatchMode("exit and display");
	
	// Clear unused memory
	wait(500);
	run("Collect Garbage");
	
  // Save detections
    roiManager("Reset");
    selectWindow("markerMask");
    run("Create Selection");
    type = selectionType();
    if (type == -1) {
        makeRectangle(1, 1, 1, 1);
    }
    roiManager("Add");
   	
    selectWindow("orig");
    run("Select None");
    //run("Brightness/Contrast...");
	run("Enhance Contrast", "saturated=0.1");
	run("Apply LUT");
    setBatchMode("show");
    roiManager("Select", 0);
    roiManager("Set Color", "#00FFFF");
    roiManager("rename", "Marker");
    roiManager("Set Line Width", 1);
    run("Flatten");
    setBatchMode("show");
    wait(200);
  
    saveAs("Jpeg", OutDir + File.separator + MyTitle_short + "_" + phName + "_analyzed.jpg");
    wait(200);
	close("\\Others");
	
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




