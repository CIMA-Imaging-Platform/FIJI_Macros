function macroInfo(){
	
// * 
// * Target User: General
// *  

	scripttitle= "IF 3D COLOCALIZATION 2 Nuclear Proteins with speckel/foci structures  ";
	version= "1.02";
	date= "2024";
	

// *  Tests Images:

	imageAdquisition="Confocal: 2 channel images.";
	imageType="8-16bits";  
	voxelSize="Voxel size: 0.19 um xy; 63x";
	format="Format: Uncompressed tiff/.czi";   
 
 //*  GUI User Requierments:
 //*    - None
 // Important Parameters: 
	// Parameters:
	
	parameter1="Introduce Channel order";
	parameter2="DAPI and  Protein1are segmented automatically , for Protein2 setUp threshold";
	parameter3="Introduce Particle Sizes for Protein1and Protein2 phenotype (pixels) ";
	
 //  2 Action tools:
		
	buttom1="Im: Single File processing. Use Single file processing for fine tunning parameters";
	buttom2="Dir: Batch Mode. Please tune parameters before using Batchmode";
	
//  OUTPUT

// Analyzed Images with ROIs

	excel="QuantificationResults_IF3D_Coloc2NuclearProts.xlsx";
	feature1="[ImageLabel]: Name Image";
	feature2="CellID : Cell Identificator";
	feature3="# Prot1_speckels : Number of protein1 speckels";
	feature4="Vol_Prot1_speckels(um^3): Total Volume of Prot1 Speckels";
	feature5="%Vol_Prot1_speckels/Nuclei: Ratio Vol Prot1 Speckels / Volume Nuclei";
	feature6="# Prot2 ";
	feature7="Vol_Prot2(um^3)";
	feature8="%Vol_Prot2/Nuclei: Ratio Vol Prot2 / Volume Nuclei";
	feature9="# Coloc Speckels_Prot1-Prot2: Number of Prot1 that colocalize with Prot2";
	feature10="Vol_Colocalized_Prot1-Prot2(um^3): Volume that colocalize";
	feature11="%Vol_Colocalized_Prot1-Prot2/Nuclei";
	
	//globalPathToImages="///C:/Users/tmsantoro/Documents/0._TMSANTORO/2.MikelLearning/2.Image_Platform/2_QUANTIFICATION_SERVICE/1._SOFTWARE/1.1_FijiPlatafomraImagen_DEV/macros/toolsets/"
	
/*  	  
 *  version: 1.02 
 *  Author: Mikel Ariz  
 *  Commented by: Tomas Muñoz 2023 
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
    + "<p><i>ACTION TOOLS (Buttons)</i></p>"
    + "<ol>"
    + "<li>" + buttom1 + "</li>"
    + "<li>" + buttom2 + "</li>"
    + "</ol>"
    + "<p><i>PARAMETERS:</i></p>"
    + "<ul>"
    + "<li>" + parameter1 + "</li>"
    + "<li>" + parameter2 + "</li>"
    + "<li>" + parameter3 + "</li></ul>"
    + "<p><i>QUANTIFICATION RESULTS</i></p>"
    + "<p>Analyzed Images folder: Visualize Segmented Images</p>"
    + "<p>Excel " + excel + "</p>"
    + "<ul>"
    + "<li>" + feature1 + "</li>"
    + "<li>" + feature2 + "</li>"
    + "<li>" + feature3 + "</li>"
    + "<li>" + feature4 + "</li>"
    + "<li>" + feature5 + "</li>"
    + "<li>" + feature6 + "</li>"
    + "<li>" + feature7 + "</li>"
    + "<li>" + feature8 + "</li>"
    + "<li>" + feature9 + "</li>"
    + "<li>" + feature10 + "</li>"
    + "<li>" + feature11 + "</li>"
    + "</ul>"
    + "</div>"
    + "</div>"
    + "</body>"
    + "</html>");
   // + "<div class='image-column'><img src='file:"+globalPathToImages+"resultsTemplates//WSI_Steatosis/WSI_Steatosis_imTemplate.jpg'></div>"

}


var cDAPI=3, cProtein=2, cProtein2=1, thProtein=30, thProtein2=50, minProtSize=2, minProtein2size=1, colocAnalysis=false;		


// SINGLE FILE 

// Define a macro for processing a single file.
macro "IF3D_Coloc2NuclearProts Action Tool 1 - Cf00T2d15IT6d10m" {

 	// Close all open images and the log window
    close("*");
    close("log");

	// Close all open windows and collect garbage.
    run("Close All");
    wait(500);
    run("Collect Garbage");
    
    // Display information about the macro
    macroInfo();
    
    // Open ROI Manager.
    run("ROI Manager...");
    
    // Select a single file for processing.
    name = File.openDialog("Select File");
    print("Processing " + name);
    
	// Create a dialog box to input parameters for analysis
    Dialog.create("Parameters for the analysis");

    // Channel Selection section
    Dialog.addMessage("Channel Selection");
    Dialog.addNumber("DAPI Channel", cDAPI);
    Dialog.addNumber("Protein1Channel", cProtein);
    Dialog.addNumber("Protein2 Channel", cProtein2);

    // Nucleus segmentation options
    Dialog.addMessage("Nucleus Segmentation");
    Dialog.addMessage("          Automatic");

    // Protein1 segmentation options
    Dialog.addMessage("Protein1Phenotyping");
    Dialog.addString("Protein1Marker", "GPF");
    Dialog.addMessage("          Automatic");
    Dialog.addNumber("Min Size marker", minProtSize);

    // Protein2 phenotyping section
    Dialog.addMessage("Protein2 Phenotyping");
    Dialog.addString("Protein2 Marker", "Rodamine");
    Dialog.addNumber("Protein2 Phenotype threshold", thProtein2);
    Dialog.addNumber("Min Size marker", minProtein2size);

    /*// Colocalization section
    Dialog.addMessage("Colocalization");
    Dialog.addCheckbox("Quantitative Colocalization", colocAnalysis);*/

    // Show the dialog box and retrieve user input
    Dialog.show();

    // Retrieve parameters from the dialog box
    cDapi = Dialog.getNumber();
    cProtein1 = Dialog.getNumber();
    cProtein2 = Dialog.getNumber();
    phNameProt = Dialog.getString();
    minProtSize = Dialog.getNumber();
    phNameProtein2 = Dialog.getString();
    thProtein2 = Dialog.getNumber();
    minProtein2size = Dialog.getNumber();
    //colocAnalysis = Dialog.getCheckbox();
    colocAnalysis=false;
    batch=true;
    
    // Call the main function for Prot colocalization classification and display completion message.
    IF3D_Coloc2NuclearProts("-", "-", name,batch,cDAPI,cProtein1,cProtein2, phNameProt,phNameProtein2,thProtein2, minProtSize,minProtein2size,colocAnalysis);
    showMessage("Colocalization Analysis DONE!");

}

// BATCH MODE
// Define a macro for processing multiple files in batch mode.

macro "IF3D_Coloc2NuclearProts Action Tool 2 - C00fT0b11DT9b09iTcb09r"{

	
	// Clean initialization
	// Close all open windows, open ROI Manager, and collect garbage.
	run("Close All");
	run("ROI Manager...");
	wait(500);
	run("Collect Garbage");
	
	// Print macro information.
	macroInfo();
		
	// Structure Directory
	// Prompt user to select the directory containing images.
	InDir = getDirectory("Choose images' directory");
	list = getFileList(InDir);
	L = lengthOf(list);
	

	// Create a dialog box to input parameters for analysis
    Dialog.create("Parameters for the analysis");

    // Channel Selection section
    Dialog.addMessage("Channel Selection");
    Dialog.addNumber("DAPI Channel", cDAPI);
    Dialog.addNumber("Protein1Channel", cProtein);
    Dialog.addNumber("Protein2 Channel", cProtein2);

    // Nucleus segmentation options
    Dialog.addMessage("Nucleus Segmentation");
    Dialog.addMessage("          Automatic");

    // Protein1 segmentation options
    Dialog.addMessage("Protein1Phenotyping");
    Dialog.addString("Protein1Marker", "GPF");
    Dialog.addMessage("          Automatic");
    Dialog.addNumber("Min Size marker", minProtSize);

    // Protein2 phenotyping section
    Dialog.addMessage("Protein2 Phenotyping");
    Dialog.addString("Protein2 Marker", "Rodamine");
    Dialog.addNumber("Protein2 Phenotype threshold", thProtein2);
    Dialog.addNumber("Min Size marker", minProtein2size);

    // Colocalization section
    Dialog.addMessage("Colocalization");
    Dialog.addCheckbox("Quantitative Colocalization", colocAnalysis);

    // Show the dialog box and retrieve user input
    Dialog.show();

    // Retrieve parameters from the dialog box
    cDapi = Dialog.getNumber();
    cProtein1 = Dialog.getNumber();
    cProtein2 = Dialog.getNumber();
    phNameProt = Dialog.getString();
    minProtSize = Dialog.getNumber();
    phNameProtein2 = Dialog.getString();
    thProtein2 = Dialog.getNumber();
    minProtein2size = Dialog.getNumber();
    colocAnalysis = Dialog.getCheckbox();
	batch=true;			
	
	// Process in batch Mode
	for (j = 0; j < L; j++)
	{
		// Analyze images with supported extensions (tif, czi)
		if (endsWith(list[j], "tif") || endsWith(list[j], "czi")) {
			// Print the processing message
			name = list[j];
			print("Processing " + list[j]);

		    // Call the main function for Prot colocalization classification and display completion message.
		    IF3D_Coloc2NuclearProts(InDir, InDir, list[j],batch,cDAPI,cProtein1,cProtein2, phNameProt,phNameProtein2,thProtein2, minProtSize,minProtein2size,colocAnalysis);
		}
		// Close all open windows after processing each image
		close("*");
	}
	
	// Display completion message
    showMessage("Colocalization Analysis DONE!")
    
}


function IF3D_Coloc2NuclearProts(InDir, InDir, name,batch,cDAPI,cProtein1,cProtein2, phNameProt,phNameProtein2,thProtein2, minProtSize,minProtein2size,colocAnalysis){
    
    function openFileFormat(file) {
		/* Function openFileFormat:
		// This function opens files based on their format.
		
		// Parameters:
		// - file: File path.
		*/
		
		
		if (endsWith(file, ".jpg") || endsWith(file, ".tif")) {
			open(file);
		} else if (endsWith(file, ".czi") || endsWith(file, ".svs")) {
			run("Bio-Formats Importer", "open=[" + file + "] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		}
	 }
	 
	function overlayLabels3D(target, mask, color) {
	
		/* Function to overlay labels on the image
	 	* 
	 	* @param {string} target - The name of the target image.
	 	* @param {string} mask - The name of the mask.
	 	* @param {string} color - color name ID.
	 	*/ 
		getDimensions(width, height, channels, slices, frames);
		selectWindow(mask);
		for (i = 1; i <= slices; i++) {
			selectWindow(mask);
			setSlice(i);
			run("Create Selection");
			type=selectionType();
			if (type != -1){
				selectWindow(target);
				run("Restore Selection");
				wait(5);
				run("Add Selection...", "stroke="+color+" width=1");
				wait(5);
				Overlay.setPosition(i);
				wait(5);
			}
		}
		roiManager("show none");
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
		 /*
		 tableName="Results";
		 columnName="Mean";
		 filterType=">";
		 threshold=0;*/
		 
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
		
		// Return the array of positive indices
		return positiveRois;
	}
	
	function multiplyArrayByScalar(array,scalar){
			
			for (i = 0; i < lengthOf(array); i++) {
				array[i]=array[i]*scalar;
			}
			return array;
	}
		
  
	// Clear ROI manager and results table
	
	roiManager("Reset");
	run("Clear Results");
	close("Results");

	// Set Colors config and measurements
	run("Colors...", "foreground=white background=black selection=green");
	run("Set Measurements...", "area mean standard modal area_fraction redirect=None decimal=4");

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
	
    // Clear previous results
    run("Clear Results");
    roiManager("reset");
    
    MyTitle = getTitle();
    output = getInfo("image.directory");

    // Create directory for analyzed images
    OutDir = output + File.separator + "AnalyzedImages/";
    File.makeDirectory(OutDir);

    // Get short title of the image
    aa = split(MyTitle, ".");
    MyTitle_short = aa[0];
    
     // Set color preferences
    run("Colors...", "foreground=white background=black selection=green");

    // Get voxel size and stack dimensions
    getVoxelSize(rx, ry, rz, unit);
    Stack.getDimensions(width, height, channels, slices, frames);

	// DETECT 3D NUCLEI FROM DAPI--
	
	// Select the active window and create a duplicate
	selectWindow(MyTitle);
	run("Select None");
	run("Duplicate...", "title=orig duplicate");
	
	// Set batch mode
	setBatchMode(false);
	   	
	selectWindow("orig");
	type = selectionType();
	if (type != -1) {
	    setBackgroundColor(0, 0, 0);
	    run("Clear Outside");
	}
	run("Select All");
	roiManager("Reset");
	run("Duplicate...", "title=dapi duplicate channels=" + cDAPI);
	run("3D Fast Filters", "filter=Median radius_x_pix=3.0 radius_y_pix=3.0 radius_z_pix=4.0 Nb_cpus=16");
	rename("dapi3D");
	run("3D Nuclei Segmentation", "auto_threshold=Otsu manual=0 separate_nuclei");
	
	setThreshold(1, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask", "background=Dark");
	run("Analyze Particles...", "size=200-Infinity pixel show=Masks stack");
	run("Morphological Filters (3D)", "operation=Dilation element=Ball x-radius=2 y-radius=2 z-radius=2");
	rename("dapiMask3D");
	close("*of*");
	close("merge");
	
	selectWindow("dapiMask3D");
	run("Invert LUT");
	run("Z Project...", "projection=[Max Intensity]");
	run("Invert LUT");
	run("Fill Holes", "stack");
	run("Adjustable Watershed", "tolerance=1");
	run("Duplicate...", "title=dapiMask2D duplicate ");
	run("Analyze Particles...", "size=8-Infinity show=Masks add in_situ");    // add projections as ROIs
	nCells = roiManager("Count");
	
	close("*Dilation*");
	close("MAX*");
	close("dapi3D");
	
	selectWindow("dapiMask3D");
	run("Invert LUT");
		
	// DETECT Protein1-- SPECKLES PHENOTYPE-- 
	
	selectWindow("orig");
	run("Duplicate...", "title=Protein1Mask3D duplicate channels="+cProtein);
	run("Subtract Background...", "rolling=10 stack");	
	getDimensions(width, height, channels, slices, frames);
	for (i = 1; i <= nSlices; i++) {
 	    setSlice(i);
    	// do something here;
    	run("Enhance Local Contrast (CLAHE)", "blocksize=149 histogram=256 maximum=2 mask=*None* fast_(less_accurate)");
	}
	
	run("Top Hat...", "radius=4 stack");
	//run("Enhance Contrast...", "saturated=0.02 normalize process_all");
	
	// Local threshold , different contrast and signal not homegeneus
	getDimensions(width, height, channels, slices, frames);
	for (i = 1; i <= nSlices; i++) {
 	    setSlice(i);
    	// do something here;
		run("Auto Local Threshold", "method=Contrast radius=150 parameter_1=0 parameter_2=0 white");
		//run("Auto Local Threshold", "method=Bernsen radius=15 parameter_1=0 parameter_2=0 white");
    }
	
	selectWindow("dapiMask2D");
	run("Create Selection");
	selectWindow("Protein1Mask3D");
	run("Restore Selection");
	run("Clear Outside","stack");
	run("Select None");
	run("Make Binary", "method=Otsu background=Dark calculate");
	minProtSize=2;
	maxProtSize=90;
	run("Analyze Particles...", "size="+minProtSize+"-"+maxProtSize+" pixel show=Masks in_situ stack");
	rename("Protein1Mask3D");
	
	// Save Protein1signal ROIs:
	roiManager("Reset");
	getDimensions(width, height, channels, slices, frames);
	flagProtein=newArray(slices);
	Array.fill(flagProtein, 0); 
	for (i=1;i<(slices+1);i++){
		
		// clear any Protein1signal outside the nuclei mask for current slice
		selectWindow("Protein1Mask3D");
		setSlice(i);
		run("Create Selection");
		// Check if we have a selection for current slice, and draw a pixel if not
		type = selectionType();
		  if (type==-1)	{
			makeRectangle(2,2,1,1);	
			flagProtein[i-1]=1;
		}
		run("Add to Manager");
	}
	
	roiManager("Save", OutDir+MyTitle_short+"_Protein_ROIs.zip");
	selectWindow("Protein1Mask3D");
	
	// Create a 2D mask projecting all the 3D selections:
	roiManager("Deselect");
	roiManager("Combine");
	run("Create Mask");
	rename("ProteinProjMask");

	// DETECT Protein2 -- 
	
	selectWindow("orig");
	run("Duplicate...", "title=Protein2Mask3D duplicate channels="+cProtein2);
	resetMinAndMax();
	run("Enhance Contrast", "saturated=0.01");
	run("Apply LUT","stack");
	run("Gamma...", "value=3.5 stack");
	run("8-bit");
	//thProtein2=100;
	setAutoThreshold("Otsu dark no-reset stack");
	setThreshold(thProtein2, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Otsu background=Dark");
	
	selectWindow("dapiMask2D");
	run("Create Selection");
	selectWindow("Protein2Mask3D");
	run("Restore Selection");
	setBackgroundColor(255,255,255);
	run("Clear Outside","stack");
	run("Select None");
	//minProtSize=2;
	run("Analyze Particles...", "size="+minProtSize+"-Infinity pixel show=Masks in_situ stack");
	rename("Protein2Mask3D");
	
	setBackgroundColor(0,0,0);
	
	// Save Protein2 signal ROIs:
	getDimensions(width, height, channels, slices, frames);
	roiManager("Reset");
	flagProtein2=newArray(slices);
	Array.fill(flagProtein2, 0); 
	for (i=1;i<(slices+1);i++){
		
		// clear any Protein2 signal outside the nuclei mask for current slice
		selectWindow("Protein2Mask3D");
		setSlice(i);
		run("Create Selection");
		// Check if we have a selection for current slice, and draw a pixel if not
		type = selectionType();
		  if (type==-1)	{
			makeRectangle(3,3,1,1);	
			flagProtein2[i-1]=1;
		}
		run("Add to Manager");
	}
	roiManager("Save", OutDir+MyTitle_short+"_Protein2_ROIs.zip");
	selectWindow("Protein2Mask3D");
	//close();
	
	// Create a 2D mask projecting all the 3D selections:
	roiManager("Deselect");
	roiManager("Combine");
	run("Create Mask");
	rename("Protein2ProjMask");
	
	// Protein1- Protein2 -- Protein-Protein2 COLOCALIZATION
	selectWindow("orig");
	roiManager("Reset");
	roiManager("Open", OutDir+MyTitle_short+"_Protein_ROIs.zip");
	roiManager("Open", OutDir+MyTitle_short+"_Protein2_ROIs.zip");
	
	
	selectWindow("Protein2Mask3D");
	getDimensions(width, height, channels, slices, frames);
	flagColoc=newArray(slices);
	Array.fill(flagColoc, 0); 
	for (i=1;i<(slices+1);i++){
		setSlice(i);
		roiManager("Deselect");
		roiManager("Select", 0);
		roiManager("select", newArray(0,slices-i+1));	
		roiManager("AND");
		// Check if we have a selection, and draw a pixel if not
		type = selectionType();
		  if (type==-1)	{
			makeRectangle(4,4,1,1);	
			flagColoc[i-1]=1;
		}
		roiManager("Add");	
		roiManager("Deselect");
		roiManager("Select", 0);
		roiManager("select", newArray(0,slices-i+1));
		roiManager("Delete");
	}

	roiManager("Save", OutDir+MyTitle_short+"_ProteinProtein2Coloc_ROIs.zip");
	// Create a 2D mask projecting all the 3D selections:
	roiManager("Deselect");
	roiManager("Combine");
	run("Create Mask");
	rename("colocProjMask");

	// MEASURE--
	run("Clear Results");
	run("Set Measurements...", "area mean Protein2irect=None decimal=2");
	
	// load ROIs
	roiManager("Reset");
	roiManager("Open", OutDir+MyTitle_short+"_Protein_ROIs.zip");
	roiManager("Open", OutDir+MyTitle_short+"_Protein2_ROIs.zip");
	roiManager("Open", OutDir+MyTitle_short+"_ProteinProtein2Coloc_ROIs.zip");

	// initialize variables
	Ag=newArray(slices);
	Ar=newArray(slices);
	Ac=newArray(slices);

	Agt=0;
	Art=0;
	Act=0;
	// loop over slices
	for (i=0;i<slices;i++){
		run("Clear Results");
		// Measure Protein
		selectWindow("orig");
		roiManager("Select", i);
		roiManager("Measure");
		Ag[i]=getResult("Area",0);
		if (flagProtein[i]==1) {
			Ag[i]=0;
			//Ig[i]=0;
		}
		Agt=Agt+Ag[i];
		// Measure Protein2
		selectWindow("orig");
		roiManager("Select", i+slices);
		roiManager("Measure");
		Ar[i]=getResult("Area",1);
		if (flagProtein2[i]==1) {
			Ar[i]=0;
			//Ir[i]=0;
		}
		Art=Art+Ar[i];
		// Measure colocalization
		selectWindow("orig");
		roiManager("Select", i+2*slices);
		roiManager("Measure");
		Ac[i]=getResult("Area",2);
		roiManager("Deselect");
		selectWindow("orig");
		roiManager("Select", i+2*slices);
		roiManager("Measure");
		if (flagColoc[i]==1) {
			Ac[i]=0;
			//Icg[i]=0;
			//Icr[i]=0;
		}
		Act=Act+Ac[i];
	}
	
	// total Protein1signal volume
	Vg=Agt*rz;
	// total Protein2 signal volume
	Vr=Art*rz;
	// total Protein-Protein2 colocalization volume
	Vc=Act*rz;
	
	// SINGLE CELL ANALYSIS.
	
	roiManager("reset");
	run("Clear Results");
	selectWindow("dapiMask3D");
	run("Morphological Filters (3D)", "operation=Erosion element=Ball x-radius=6 y-radius=6 z-radius=3");
	rename("dapiSeeds3D");
	selectImage("dapiMask2D");
	run("Create Selection");
	selectImage("dapiSeeds3D");
	run("Restore Selection");
	setBackgroundColor(255,255,255);
	run("Clear Outside", "stack");
	setBackgroundColor(0,0,0);
	
	run("3D Watershed Split", "binary=dapiMask3D seeds=dapiSeeds3D radius=8");
	close("EDT");
	close("dapiSeeds3D");
	selectWindow("Split");
	rename("dapiMask3D-seg");
	run("Connected Components Labeling", "connectivity=6 type=[8 bits]");
	setBatchMode("show");
	close("dapiMask3D-seg");
	selectWindow("Protein1Mask3D");
	run("Connected Components Labeling", "connectivity=26 type=[16 bits]");
	setBatchMode("show");
	selectWindow("Protein2Mask3D");
	run("Connected Components Labeling", "connectivity=26 type=[16 bits]");
	setBatchMode("show");
	
	// Pixel Volume
	voxelVolume=rx*ry*rz;
		
	// Protein1 - Speckels phenotype
	run("3D Numbering", "main=dapiMask3D-seg-lbl counted=Protein1Mask3D-lbl");
		
	id=Table.getColumn("Value");
	nProts=Table.getColumn("NbObjects");
	volProts=Table.getColumn("VolObjects");
	volProtsMicrons=multiplyArrayByScalar(volProts,voxelVolume);
	perProts=Table.getColumn("PercObjects");
	close("Numbering");
		
	// Protein2 - Dot phenotype.
	run("3D Numbering", "main=dapiMask3D-seg-lbl counted=Protein2Mask3D-lbl");
		
	nProts2=Table.getColumn("NbObjects");
	volProts2=Table.getColumn("VolObjects");
	volProts2Microns=multiplyArrayByScalar(volProts2,voxelVolume);
	perProts2=Table.getColumn("PercObjects");
	close("Numbering");
	
	// Calculate how many speckels presents dots of Colocalization Protein 1 - Protein 2
	imageCalculator("AND create stack", "Protein1Mask3D","Protein2Mask3D");
	selectImage("Result of Protein1Mask3D");
	rename("colocProts3D");
	run("Connected Components Labeling", "connectivity=26 type=[16 bits]");
	run("3D Numbering", "main=Protein1Mask3D-lbl counted=colocProts3D-lbl");
		
	IJ.renameResults("Results");
	positiveFoci=filterTableColum("Results", "NbObjects", ">", 0);
	
	selectWindow("colocProts3D");
	run("Select All");
	run("Fill","stack");
	close("Numbering");

	for (i = 0; i <= lengthOf(positiveFoci)-1; i++) {
		selectWindow("Protein1Mask3D-lbl");
		run("Duplicate...", "title=singleProtColoc duplicate ");
		setAutoThreshold("Otsu dark no-reset");
		//run("Threshold...");
		setThreshold(positiveFoci[i]+1, positiveFoci[i]+1, "raw");
		setOption("BlackBackground", false);
		run("Convert to Mask", "method=Otsu background=Dark");
		imageCalculator("OR create stack", "colocProts3D","singleProtColoc");
		close("colocProts3D");
		close("singleProtColoc");
		selectImage("Result of colocProts3D");
		rename("colocProts3D");
	}
	
	selectWindow("colocProts3D");
	run("Connected Components Labeling", "connectivity=26 type=[16 bits]");
	run("3D Numbering", "main=dapiMask3D-seg-lbl counted=colocProts3D-lbl");
		
	nProtsColoc=Table.getColumn("NbObjects");
	volProtsColoc=Table.getColumn("VolObjects");
	volProtsColocMicrons=multiplyArrayByScalar(volProtsColoc,voxelVolume);
	perProtsColoc=Table.getColumn("PercObjects");
	
	close("Numbering");
	
	
	
	// Calculate how many dots presents dots of Colocalization 
	imageCalculator("AND create stack", "Protein1Mask3D","Protein2Mask3D");
	selectImage("Result of Protein1Mask3D");
	rename("colocProts23D");
	run("Connected Components Labeling", "connectivity=26 type=[16 bits]");
	run("3D Numbering", "main=dapiMask3D-seg-lbl counted=colocProts23D-lbl");
	
	nProts2Coloc=Table.getColumn("NbObjects");
	volProts2Coloc=Table.getColumn("VolObjects");
	volProtsColoc2Microns=multiplyArrayByScalar(volProtsColoc,voxelVolume);
	perProts2Coloc=Table.getColumn("PercObjects");
	close("Numbering");
		
	// SAVE RESULTS
	
	// Define an empty array
	labelColumn = newArray(lengthOf(id));
	// Fill the array with image name
	for (i = 0; i < lengthOf(labelColumn); i++) {
	    labelColumn[i] = MyTitle_short;
	}
		
	Table.create("Metrics");
	Table.setColumn("[ImageLabel]",labelColumn);
	Table.setColumn("Cell_ID", id);
	Table.setColumn("#"+phNameProt+"_speckels", nProts);
	Table.setColumn("Vol_"+phNameProt+"_speckels(um^3)", volProtsMicrons);
	Table.setColumn("% Vol_"+phNameProt+"_speckels/Nuclei", perProts);
	Table.setColumn("#"+phNameProtein2, nProts2);
	Table.setColumn("Vol_"+phNameProtein2+"(um^3)", volProts2Microns);
	Table.setColumn("%Vol_"+phNameProtein2+"/Nuclei", perProts2);
	Table.setColumn("# Coloc  Speckels_"+phNameProt+"-"+phNameProtein2, nProtsColoc);
	Table.setColumn("Vol_Colocalized_"+phNameProt+"-"+phNameProtein2+"(um^3)", volProtsColocMicrons);
	Table.setColumn("%Vol_Colocalized"+phNameProt+"-"+phNameProtein2+"/Nuclei", perProtsColoc);
	Table.setColumn("# Coloc  Speckels_"+phNameProtein2+"-"+phNameProt, nProts2Coloc);
	Table.setColumn("Vol_Colocalized_"+phNameProtein2+"-"+phNameProt+"(um^3)", volProtsColoc2Microns);
	Table.setColumn("%Vol_Colocalized"+phNameProtein2+"-"+phNameProt+"/Nuclei", perProts2Coloc);
	IJ.renameResults("Results");

	//SAVE RESULTS
	run("Read and Write Excel", "file=["+output+File.separator+"QuantificationResults_IF3D_Coloc2NuclearProts"+phNameProt+"-"+phNameProtein2+".xlsx] stack_results");
	
	roiManager("reset");
	
	// Save image
	selectWindow("orig");
	setBatchMode("show");
	selectWindow("orig");
	run("Split Channels");
	selectWindow("C"+cDAPI+"-orig");
	run("Enhance Contrast", "saturated=0.2");
	run("Apply LUT", "stack");
	selectWindow("C"+cProtein1+"-orig");
	run("Enhance Contrast", "saturated=0.2");
	run("Apply LUT", "stack");
	run("Gamma...", "value=1.4 stack");
	selectWindow("C"+cProtein2+"-orig");
	run("Enhance Contrast", "saturated=0.01");
	run("Apply LUT", "stack");
	run("Gamma...", "value=3.5 stack");
	run("Merge Channels...", "c1=[C"+cProtein2+"-orig] c2=[C"+cProtein1+"-orig] c3=[C"+cDAPI+"-orig] create");
	run("Make Composite");
	run("RGB Color", "slices keep");
	rename("temp");
	
	
	roiManager("reset");
	RoiManager.restoreCentered(false);
	RoiManager.useNamesAsLabels(true);
	run("Duplicate...", "title=imageToSave3D duplicate ");
	selectWindow("dapiMask3D-seg-lbl");
	run("Label image to ROIs", "rm=[RoiManager[size=10, visible=true]]");
	selectWindow("imageToSave3D");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	roiManager("Show All");
	roiManager("Set Color", "blue");
	roiManager("Set Line Width", 0);
	run("Labels...", "color=white font=10 show draw");
	RoiManager.useNamesAsLabels(true);
	roiManager("Show All with labels");
	run("Flatten", "stack");
	//overlayLabels3D("imageToSave3D", "dapiMask3D", "blue");
	overlayLabels3D("imageToSave3D", "Protein1Mask3D", "green");
	overlayLabels3D("imageToSave3D", "Protein2Mask3D", "red");
	run("Flatten", "stack");
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_CellsID-3D.tiff");
	
	selectWindow("temp");
	run("Duplicate...", "title=imageToSave3D_nolabel duplicate ");
	selectWindow("dapiMask3D-seg-lbl");
	run("Label image to ROIs", "rm=[RoiManager[size=10, visible=true]]");
	selectWindow("imageToSave3D_nolabel");
	overlayLabels3D("imageToSave3D_nolabel", "dapiMask3D", "blue");
	overlayLabels3D("imageToSave3D_nolabel", "Protein1Mask3D", "green");
	run("Select None");
	overlayLabels3D("imageToSave3D_nolabel", "Protein2Mask3D", "red");
	run("Select None");
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_Analyzed3D.tiff");
		
	
	wait(100);
	roiManager("reset");
	selectWindow("temp");
	run("Z Project...", "projection=[Sum Slices]");
	rename("merge");
	selectWindow("dapiMask2D");
	run("Analyze Particles...", "add");    // add projections as ROIs
	roiManager("Show All");
	roiManager("Show None");
	selectWindow("merge");
	roiManager("Set Color", "white");
	roiManager("Set Line Width", 1);
	roiManager("Show None");
	roiManager("Show All");
	roiManager("Show All without labels");
	run("Flatten");
	wait(500);
	rename("imageToSave2D");
	//saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	
	close("merge");
	close("temp");
	
	
	// Save 2D projection image of detected things:
	selectWindow("imageToSave2D");
	roiManager("Reset");
	selectWindow("ProteinProjMask");
	run("Create Selection");
	run("Add to Manager");
	close();
	selectWindow("Protein2ProjMask");
	run("Create Selection");
	run("Add to Manager");
	close();
	selectWindow("colocProjMask");
	run("Create Selection");
	run("Add to Manager");
	close();
	selectWindow("imageToSave2D");
	roiManager("Select", 0);
	roiManager("Set Color", "Green");
	roiManager("Set Line Width", 1);
	run("Flatten");
	roiManager("Show None");
	roiManager("Select", 1);
	roiManager("Set Color", "Red");
	roiManager("Set Line Width", 1);
	run("Flatten");
	roiManager("Show None");
	roiManager("Select", 2);
	roiManager("Set Color", "yellow");
	roiManager("Set Line Width", 1);
	run("Flatten");
	wait(500);
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed2DProjection.jpg");
	rename(MyTitle_short+"_analyzed.jpg");
	wait(500);
	//close();
	
	close("imageToSave2D");
	close("imageToSave2D-1");
	close("imageToSave2D-2");

	
	/*
	// COLOC 2 PLUGIN
	if (colocAnalysis){
	
		imageCalculator("OR create stack", "Protein1Mask3D","Protein2Mask3D");
		rename("coloc2mask");
		run("Invert LUT");
		selectWindow("Protein1Mask3D");
		close();
		selectWindow("Protein2Mask3D");
		close();
		
		selectWindow("orig");
		run("Duplicate...", "title=Protein1duplicate channels="+cProtein);
		run("Duplicate...", "title=Protein2 duplicate channels="+cProtein2);
	
		
		
		run("Coloc 2", "channel_1=Protein1 channel_2=Protein2 roi_or_mask=coloc2mask threshold_regression=Costes show_save_pdf_dialog display_images_in_result spearman's_rank_correlation manders'_correlation 2d_intensity_histogram psf=3 costes_randomisations=10");
		

	
		close("Protein");
		close("Protein2");
		close("coloc2mask");
		
		selectWindow(MyTitle);
		roiManager("Reset");
		roiManager("Open", OutDir+"Analysis_"+MyTitle_short+"_ROIs.zip");
		setTool("rectangle");
		roiManager("Show All without labels");
		roiManager("Show None");
		roiManager("Show All");
		roiManager("Show All with labels");
		
	}*/
	
	//selectWindow(MyTitle_short+"_analyzed.jpg");
	//setTool("freehand");
	close("\\Others");
	
	setBatchMode("exit and display");
	
}

