function macroInfo(){
    
    // * Target User: General
    scripttitle = "IF 3D COLOCALIZATION 2 Nuclear Markers with speckel/ structures";
    version = "1.04";
    date = "02/2026";

    // * Tests Images:
    imageAdquisition = "Confocal: 2 channel images.";
    imageType = "8-16bits";
    voxelSize = "Voxel size: 0.19 um xy; 63x";
    format = "Format: Uncompressed tiff/.czi";

    // * GUI User Requirements:
    // *    - None
    // Important Parameters:
    parameter1 = "Introduce Channel order";
    parameter2 = "Nucleus Segmentation: set a threshold";
    parameter3 = "Nuclear Markers: Set Threshold and minimum Particle sizes";

    // 2 Action tools:
    buttom1 = "Im: Single File processing. Use Single file processing for fine tuning parameters";
    buttom2 = "Dir: Batch Mode. Please tune parameters before using Batchmode";

    // OUTPUT
	excel = "QuantificationResults_IF3D_Coloc2NuclearMarkers.xlsx"; // The name of the Excel file where the quantification results will be saved.

	feature1 = "[ImageLabel]: The name or label of the analyzed image.";
	feature2 = "Cell_ID: The unique identifier assigned to each detected cell in the image.";
	feature3 = "Nucleus_Volume(um^3): The measured volume of each cell's nucleus, in cubic micrometers (um³).";
	feature4 = "# Marker1_Aggregates: The total number of Marker1 aggregates (distinct Marker1-positive structures) detected within each cell.";
	feature5 = "Vol_Marker1_Aggregates(um^3): The combined volume of all Marker1 aggregates within a cell, in um³.";
	feature6 = "%Vol_Marker1_Aggregates/Nucleus: The percentage of the nucleus volume that is occupied by Marker1 aggregates.";
	feature7 = "# Marker2: The total number of Marker2 puncta (distinct Marker2-positive spots) detected within each cell.";
	feature8 = "Vol_Marker2_Puncta(um^3): The combined volume of all Marker2 puncta within a cell, in um³.";
	feature9 = "%Vol_Marker2_Puncta/Nucleus: The percentage of the nucleus volume that is occupied by Marker2 puncta.";
	feature10 = "# Coloc Aggregates Marker1-Marker2: The number of Marker1 aggregates that are colocalized (overlapping or in close proximity) with Marker2 puncta within each cell.";
	feature11 = "Vol_Colocalized_Marker1-Marker2(um^3): The total volume of Marker1 aggregates that are colocalized with Marker2, in um³.";
	feature12 = "%Vol_Colocalized_Marker1-Marker2/Nucleus: The percentage of the nucleus volume that is occupied by colocalized Marker1 aggregates.";
	feature13 = "# Coloc Puncta Marker2-Marker1: The number of Marker2 puncta that are colocalized with Marker1 aggregates within each cell.";
	feature14 = "Vol_Colocalized_Marker2-Marker1(um^3): The total volume of Marker2 puncta that are colocalized with Marker1, in um³.";
	feature15 = "%Vol_Colocalized_Marker2-Marker1/Nucleus: The percentage of the nucleus volume that is occupied by Marker2 puncta which are colocalized (overlapping or in close proximity) with Marker1 aggregates. This value shows, for each cell, how much of the nucleus is filled by Marker2 puncta that are also found together with Marker1.";

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
    + "<li>" + feature12 + "</li>"
    + "<li>" + feature13 + "</li>"
    + "<li>" + feature14 + "</li>"
    + "<li>" + feature15 + "</li>"
    + "</ul>"
    + "</div>"
    + "</div>"
    + "</body>"
    + "</html>");
}


var cDapi=1, cMarker1=3, cMarker2=2, thDapi=80, thMarker1=15, minMarker1Size=10, minMarker2size=3, 	maxMarkerSize=1000 ,colocAnalysis=false;		


// SINGLE FILE 

// Define a macro for processing a single file.
macro "IF3D_Coloc2NuclearMarkers Action Tool 1 - Cf00T2d15IT6d10m" {

	run("Fresh Start");
	
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
    
	openFileFormat(name);
		
	// Create a dialog box to input parameters for analysis
    Dialog.create("Parameters for the analysis");

    // Channel Selection section
    Dialog.addMessage("Channel Selection");
    Dialog.addNumber("DAPI Channel", cDapi);
    Dialog.addNumber(" Marker1 Channel", cMarker1);
    Dialog.addNumber("Speckle Marker2 Channel", cMarker2);

    // Nucleus segmentation options
    Dialog.addMessage("Nucleus Segmentation");
    Dialog.addNumber("DAPI  threshold", thDapi);
    
    //  Marker1 segmentation options
    Dialog.addMessage("Marker1 Phenotype: Aggregates Phenotype");
    Dialog.addString("Marker1 Name", "Rodamine");
    Dialog.addNumber("Marker1 Phenotype threshold", thMarker1);
    Dialog.addNumber("Min Size marker", minMarker1Size);

    // Marker2 phenotyping section
    Dialog.addMessage("Marker2  Phenotype: Puncta Phenotype");
    Dialog.addString("Marker2 Name", "GFP");
    Dialog.addMessage(" Marker2 threshold Automatic");
    Dialog.addNumber("Min Size marker", minMarker2size);

    // Colocalization section
    Dialog.addMessage("Colocalization");
    Dialog.addCheckbox("Quantitative Colocalization", colocAnalysis);

    // Show the dialog box and retrieve user input
    Dialog.show();


    // Show the dialog box and retrieve user input
    
    // Retrieve parameters from the dialog box
    cDapi = Dialog.getNumber();
    cMarker1 = Dialog.getNumber();
    cMarker2 = Dialog.getNumber();
    thDapi = Dialog.getNumber();    
    phNameMarker1 = Dialog.getString();
    thMarker1 = Dialog.getNumber();
    minMarker1Size = Dialog.getNumber();
    phNameMarker2 = Dialog.getString();
    minMarker2size = Dialog.getNumber();
    //colocAnalysis = Dialog.getCheckbox();
    colocAnalysis=false;
    batch=true;
    
    // Call the main function for Marker colocalization classification and display completion message.
    IF3D_Coloc2NuclearMarkers("-", "-", name,batch,cDapi,cMarker1,cMarker2, phNameMarker1,phNameMarker2,thDapi,thMarker1,minMarker1Size,minMarker2size,colocAnalysis);
    showMessage("Colocalization Analysis DONE!");

}

// BATCH MODE
// Define a macro for processing multiple files in batch mode.

macro "IF3D_Coloc2NuclearMarkers Action Tool 2 - C00fT0b11DT9b09iTcb09r"{

	
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
    Dialog.addNumber("DAPI Channel", cDapi);
    Dialog.addNumber(" Marker1 Channel", cMarker1);
    Dialog.addNumber("Speckle Marker2 Channel", cMarker2);

    // Nucleus segmentation options
    Dialog.addMessage("Nucleus Segmentation");
    Dialog.addNumber("DAPI  threshold", thDapi);
    
    //  Marker1 segmentation options
    Dialog.addMessage("Marker1  Phenotype");
    Dialog.addString("Marker1 Name", "Rodamine");
    Dialog.addNumber("Marker1 Phenotype threshold", thMarker1);
    Dialog.addNumber("Min Size marker", minMarker1Size);

    // Marker2 phenotyping section
    Dialog.addMessage("Marker2  Phenotype");
    Dialog.addString("Marker2 Name", "GFP");
    Dialog.addMessage(" Marker1 threshold Automatic");
    Dialog.addNumber("Min Size marker", minMarker2size);

    // Colocalization section
    Dialog.addMessage("Colocalization");
    Dialog.addCheckbox("Quantitative Colocalization", colocAnalysis);

    // Show the dialog box and retrieve user input
    Dialog.show();


  // Retrieve parameters from the dialog box
    cDapi = Dialog.getNumber();
    cMarker1 = Dialog.getNumber();
    cMarker2 = Dialog.getNumber();
    thDapi = Dialog.getNumber();    
    phNameMarker1 = Dialog.getString();
    thMarker1 = Dialog.getNumber();
    minMarker1Size = Dialog.getNumber();
    phNameMarker2 = Dialog.getString();
    minMarker2size = Dialog.getNumber();
    //colocAnalysis = Dialog.getCheckbox();
    colocAnalysis=false;
    batch=false;
	
	// Process in batch Mode
	for (j = 0; j < L; j++)
	{
		// Analyze images with supported extensions (tif, czi)
		if (endsWith(list[j], "tif") || endsWith(list[j], "czi")) {
			// Print the processing message
			name = list[j];
			print("Processing " + list[j]);

		    // Call the main function for Marker colocalization classification and display completion message.
		    IF3D_Coloc2NuclearMarkers(InDir, InDir, list[j],batch,cDapi,cMarker1,cMarker2, phNameMarker1,phNameMarker2,thDapi,thMarker1,minMarker1Size,minMarker2size,colocAnalysis);
		}
		// Close all open windows after processing each image
		close("*");
	}
	
	// Display completion message
    showMessage("Colocalization Analysis DONE!")
    
}


function IF3D_Coloc2NuclearMarkers(InDir, InDir, name,batch,cDapi,cMarker1,cMarker2, phNameMarker1,phNameMarker2,thDapi,thMarker1,minMarker1Size,minMarker2size,colocAnalysis){
     
	// Clear ROI manager and results table
	
	roiManager("Reset");
	run("Clear Results");
	close("Results");

	// Set Colors config and measurements
	run("Colors...", "foreground=white background=black selection=green");
	run("Set Measurements...", "area mean standard modal area_fraction redirect=None decimal=4");
	run("Options...", "iterations=1 count=1 do=Nothing");

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
    
   // Get voxel size and stack dimensions
    getVoxelSize(rx, ry, rz, unit);
    Stack.getDimensions(width, height, channels, slices, frames);
    
    
	// DETECT 3D NUCLEI FROM DAPI--
	
	// Select the active window and create a duplicate
	selectWindow(MyTitle);
	run("Select None");
	run("Duplicate...", "title=orig duplicate");
	
	selectWindow("orig");
	type = selectionType();
	if (type != -1) {
	    setBackgroundColor(0, 0, 0);
	    run("Clear Outside");
	}
	run("Select All");
	roiManager("Reset");
	run("Duplicate...", "title=dapiMask3D duplicate channels=" + cDapi);
	run("3D Fast Filters", "filter=Median radius_x_pix=3.0 radius_y_pix=3.0 radius_z_pix=4.0 Nb_cpus=16");
	close("dapiMask3D");
	rename("dapiMask3D");
	close("Log");
	close("dapi");
	run("Enhance Contrast", "saturated=0.35");
	run("Apply LUT","stack");
	//run("3D Nuclei Segmentation", "auto_threshold=Huang manual=0 separate_nuclei");
	//setAutoThreshold("Huang dark stack");
	//thDapi=80;
	setThreshold(thDapi, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Otsu background=Dark");
	run("Analyze Particles...", "size=2000-Infinity pixel show=Masks in_situ stack");    // add projections as ROIs
	run("Invert LUT");
	run("Z Project...", "projection=[Max Intensity]");
	run("Invert LUT");
	run("Fill Holes", "stack");
	run("Adjustable Watershed", "tolerance=1.5");
	rename("dapiMask2D");
	selectWindow("dapiMask2D");
	run("Create Selection");
	selectWindow("dapiMask3D");
	run("Restore Selection");
	run("Clear Outside","stack");
	run("Select None");
	run("Invert LUT");
	selectWindow("dapiMask2D");
	run("Analyze Particles...", "size=2000-Infinity pixel show=Masks add in_situ");    // add projections as ROIs
	nCells = roiManager("Count");
	roiManager("show none");
	
	// DETECT Marker1-- SPECKLES PHENOTYPE-- 
	selectWindow("orig");
	run("Duplicate...", "title=Marker1Mask3D duplicate channels="+cMarker1);
	run("Median...", "radius=1 stack");
	run("Subtract Background...", "rolling=20 stack");	
	setMinAndMax(4, 100);
	run("Apply LUT","stack");
	//run("3D Fast Filters","filter=Median radius_x_pix=2.0 radius_y_pix=2.0 radius_z_pix=2.0 Nb_cpus=16");
	//close("Marker1Mask3D");
	//rename("Marker1Mask3D");
	//thMarker1=15;
	setThreshold(thMarker1, 255);
	run("Convert to Mask", "method=Otsu background=Dark");
		
	selectWindow("dapiMask2D");
	run("Create Selection");
	selectWindow("Marker1Mask3D");
	run("Restore Selection");
	setForegroundColor(0, 0, 0);
	setBackgroundColor(255, 255, 255);
	run("Clear Outside","stack");
	run("Select None");
	run("Make Binary", "method=Huang background=Dark");
	//minMarker1Size=10;
	run("Analyze Particles...", "size="+minMarker1Size+"-"+maxMarkerSize+" pixel show=Masks in_situ stack");
	rename("Marker1Mask3D");
	
	// Save Marker1signal ROIs:
	roiManager("Reset");
	selectWindow("Marker1Mask3D");
	run("Label image to ROIs", "rm=[]");
	roiManager("Save", OutDir+MyTitle_short+"_"+phNameMarker1+"_ROIs.zip");
	
	// Create a 2D mask projecting all the 3D selections:
	selectWindow("Marker1Mask3D");
	run("Invert LUT");
	run("Z Project...", "projection=[Max Intensity]");
	run("Invert LUT");
	rename("Marker1ProjMask");
	selectWindow("Marker1Mask3D");
	run("Invert LUT");

	// DETECT Marker2 -- 

	selectWindow("orig");
	run("Duplicate...", "title=Marker2Mask3D duplicate channels="+cMarker2);
	run("Median...", "radius=1 stack");
	resetMinAndMax();
	getDimensions(width, height, channels, slices, frames);
	setSlice(slices/2);
	run("Enhance Contrast", "saturated=0.01");
	run("Apply LUT","stack");
	run("Gamma...", "value=1.5 stack");
	run("Subtract Background...", "rolling=8 stack");
	run("3D Fast Filters","filter=Median radius_x_pix=1.0 radius_y_pix=1.0 radius_z_pix=1.0 Nb_cpus=16");
	close("Log");
	close("Marker2Mask3D");
	rename("Marker2Mask3D");
	run("8-bit");
	//thMarker1=100;
	//setAutoThreshold("Otsu dark no-reset stack");
	run("Auto Local Threshold", "method=Bernsen radius=8 parameter_1=0 parameter_2=0 white stack");
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Otsu background=Dark");
	
	selectWindow("dapiMask2D");
	run("Create Selection");
	selectWindow("Marker2Mask3D");
	run("Restore Selection");
	setBackgroundColor(255,255,255);
	run("Clear Outside","stack");
	run("Select None");
	//minMarker1Size=5;
	run("Analyze Particles...", "size="+minMarker1Size+"-Infinity pixel show=Masks in_situ stack");
	rename("Marker2Mask3D");
	setBackgroundColor(0,0,0);
	run("3D Fast Filters","filter=Median radius_x_pix=1.0 radius_y_pix=1.0 radius_z_pix=1.0 Nb_cpus=16");
	close("Log");
	close("Marker2Mask3D");
	rename("Marker2Mask3D");
	setThreshold(200, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Otsu background=Dark");
	//minMarker1Size=5;
	run("Analyze Particles...", "size="+minMarker1Size+"-Infinity pixel show=Masks in_situ stack");   
	
	roiManager("Reset");
	selectWindow("Marker2Mask3D");
	run("Label image to ROIs", "rm=[]");
	roiManager("Save", OutDir+MyTitle_short+"_"+phNameMarker2+"_ROIs.zip");
	
	// Create a 2D mask projecting all the 3D selections:
	selectWindow("Marker2Mask3D");
	run("Invert LUT");
	run("Z Project...", "projection=[Max Intensity]");
	run("Invert LUT");
	rename("Marker2ProjMask");
	selectWindow("Marker2Mask3D");
	run("Invert LUT");

	// Marker1- Marker2 -- COLOCALIZATION
	selectWindow("orig");
	roiManager("Reset");
	
	imageCalculator("AND create stack", "Marker1Mask3D","Marker2Mask3D");
	selectImage("Result of Marker1Mask3D");
	rename("colocMask3D");
	
	roiManager("Reset");
	selectWindow("colocMask3D");
	run("Label image to ROIs", "rm=[]");
	roiManager("Save", OutDir+MyTitle_short+"_"+phNameMarker1+"-"+phNameMarker2+"Coloc_ROIs.zip");
	
	selectWindow("colocMask3D");
	run("Invert LUT");
	run("Z Project...", "projection=[Max Intensity]");
	run("Invert LUT");
	rename("colocProjMask");
	selectWindow("colocMask3D");
	run("Invert LUT");
	
	setBatchMode(true);	
	// MEASURE--
	run("Clear Results");
	run("Set Measurements...", "area mean Marker2irect=None decimal=2");
	
	// total Marker1signal volume
	selectWindow("Marker1Mask3D");
	run("Analyze Regions 3D", "volume surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
	selectWindow("Marker1Mask3D-morpho");
	IJ.renameResults("Results");
	marker1TotalVolume = getResult("Volume", 0);
	run("Clear Results");
		
	// total Marker2signal volume
	selectWindow("Marker2Mask3D");
	run("Analyze Regions 3D", "volume surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
	selectWindow("Marker2Mask3D-morpho");
	IJ.renameResults("Results");
	marker2TotalVolume = getResult("Volume", 0);
	run("Clear Results");
	
	// total coloc volume
	selectWindow("colocMask3D");
	run("Analyze Regions 3D", "volume surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
	selectWindow("colocMask3D-morpho");
	IJ.renameResults("Results");
	volumeColoc = getResult("Volume", 0);
	run("Clear Results");
	
	// SINGLE CELL ANALYSIS.
	roiManager("reset");
	run("Clear Results");
	selectWindow("dapiMask3D");
	run("Morphological Filters (3D)", "operation=Erosion element=Ball x-radius=10 y-radius=10 z-radius=3");
	rename("dapiSeeds3D");
	selectImage("dapiMask2D");
	run("Create Selection");
	selectImage("dapiSeeds3D");
	run("Restore Selection");
	setBackgroundColor(255,255,255);
	run("Clear Outside", "stack");
	setBackgroundColor(0,0,0);
	setForegroundColor(255,255,255);
	run("3D Watershed Split", "binary=dapiMask3D seeds=dapiSeeds3D radius=8");
	close("EDT");
	close("dapiSeeds3D");
	close("Log");
	selectWindow("Split");
	setVoxelSize(rx, ry, rz, "um");
	rename("dapiMask3D-seg");
	run("Connected Components Labeling", "connectivity=6 type=[8 bits]");
	setBatchMode("show");
	close("dapiMask3D-seg");
	selectWindow("Marker1Mask3D");
	run("Connected Components Labeling", "connectivity=26 type=[16 bits]");
	setBatchMode("show");
	selectWindow("Marker2Mask3D");
	run("Connected Components Labeling", "connectivity=26 type=[16 bits]");
	setBatchMode("show");
	
	// Pixel Volume
	voxelVolume=rx*ry*rz;
	
	// nucleus size
	selectWindow("dapiMask3D-seg-lbl");
	run("Analyze Regions 3D", "volume surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
	selectWindow("dapiMask3D-seg-lbl-morpho");
	IJ.renameResults("Results");
	nucleusSize = Table.getColumn("Volume");
	run("Clear Results");
		
	// Marker1 - aggregates phenotype
	run("3D Numbering", "main=dapiMask3D-seg-lbl counted=Marker1Mask3D-lbl");
		
	id=Table.getColumn("Value");
	nMarker1=Table.getColumn("NbObjects");
	volMarker1=Table.getColumn("VolObjects");
	volMarker1Microns=multiplyArrayByScalar(volMarker1,voxelVolume);
	//perMarker1=Table.getColumn("PercObjects");
	close("Numbering");
		
	// Marker2 - Dot phenotype.
	run("3D Numbering", "main=dapiMask3D-seg-lbl counted=Marker2Mask3D-lbl");
	nMarker2=Table.getColumn("NbObjects");
	volMarker2=Table.getColumn("VolObjects");
	volMarker2Microns=multiplyArrayByScalar(volMarker2,voxelVolume);
	//perMarker2=Table.getColumn("PercObjects");
	close("Numbering");
	
	selectWindow("colocMask3D");
	run("Connected Components Labeling", "connectivity=26 type=[16 bits]");
	
	// Calculate how many Marker 1 are  Colocalization positive
	run("3D Numbering", "main=Marker1Mask3D-lbl counted=colocMask3D-lbl");
	selectWindow("Numbering");
	IJ.renameResults("Results");
	positive=filterTableColum("Results", "NbObjects", ">", 0);
	Array.print(positive);
		
	selectWindow("colocMask3D");
	run("Duplicate...", "title=positiveMarker1 duplicate");
	setBatchMode("show");
	run("Select All");
	run("Fill","stack");
	close("Numbering");
	
	for (i = 0; i <= lengthOf(positive)-1; i++) {
		selectWindow("Marker1Mask3D-lbl");
		run("Duplicate...", "title=singleMarkerColoc duplicate ");
		setAutoThreshold("Otsu dark no-reset");
		//run("Threshold...");
		setThreshold(positive[i]+1, positive[i]+1, "raw");
		setOption("BlackBackground", false);
		run("Convert to Mask", "method=Otsu background=Dark");
		imageCalculator("OR create stack", "positiveMarker1","singleMarkerColoc");
		close("positiveMarker1");
		close("singleMarkerColoc");
		selectImage("Result of positiveMarker1");
		rename("positiveMarker1");
	}
	
	selectWindow("positiveMarker1");
	run("Connected Components Labeling", "connectivity=26 type=[16 bits]");
	run("3D Numbering", "main=dapiMask3D-seg-lbl counted=positiveMarker1-lbl");
	
	nMarker1Coloc=Table.getColumn("NbObjects");
	volMarker1Coloc=Table.getColumn("VolObjects");
	volMarker1ColocMicrons=multiplyArrayByScalar(volMarker1Coloc,voxelVolume);
	//perMarker1Coloc=Table.getColumn("PercObjects");
	
	close("Numbering");
	
	// Calculate how many marker 2 are colocalization positive
	run("3D Numbering", "main=Marker2Mask3D-lbl counted=colocMask3D-lbl");
	selectWindow("Numbering");
	IJ.renameResults("Results");
	positive=filterTableColum("Results", "NbObjects", ">", 0);
	Array.print(positive);
		
	selectWindow("colocMask3D");
	run("Duplicate...", "title=positiveMarker2 duplicate");
	setBatchMode("show");
	run("Select All");
	run("Fill","stack");
	close("Numbering");
	
	for (i = 0; i <= lengthOf(positive)-1; i++) {
		selectWindow("Marker2Mask3D-lbl");
		run("Duplicate...", "title=singleMarkerColoc duplicate ");
		setAutoThreshold("Otsu dark no-reset");
		//run("Threshold...");
		setThreshold(positive[i]+1, positive[i]+1, "raw");
		setOption("BlackBackground", false);
		run("Convert to Mask", "method=Otsu background=Dark");
		imageCalculator("OR create stack", "positiveMarker2","singleMarkerColoc");
		close("positiveMarker2");
		close("singleMarkerColoc");
		selectImage("Result of positiveMarker2");
		rename("positiveMarker2");
	}
	
	selectWindow("positiveMarker2");
	run("Connected Components Labeling", "connectivity=26 type=[16 bits]");
	run("3D Numbering", "main=dapiMask3D-seg-lbl counted=positiveMarker2-lbl");
	
	nMarker2Coloc=Table.getColumn("NbObjects");
	volMarker2Coloc=Table.getColumn("VolObjects");
	volMarker2ColocMicrons=multiplyArrayByScalar(volMarker1Coloc,voxelVolume);
	//perMarker1Coloc=Table.getColumn("PercObjects");
	
	close("Numbering");
		
	// SAVE RESULTS
	
	// Define an empty array
	labelColumn = newArray(lengthOf(id));
	// Fill the array with image name
	for (i = 0; i < lengthOf(labelColumn); i++) {
	    labelColumn[i] = MyTitle_short;
	}
	
	// Calculate percentages for Marker1, Marker2, Coloc Marker1, Coloc Marker2
	percMarker1Array = arraysOps(volMarker1Microns, nucleusSize, "divide");
	percMarker2Array = arraysOps(volMarker2Microns, nucleusSize, "divide");
	percColocMarker1Array = arraysOps(volMarker1ColocMicrons, nucleusSize, "divide");
	percColocMarker2Array = arraysOps(volMarker2ColocMicrons, nucleusSize, "divide");
	
	// Convert to percentage using multiplyArrayByScalar
	percMarker1Array = multiplyArrayByScalar(percMarker1Array, 100.0);
	percMarker2Array = multiplyArrayByScalar(percMarker2Array, 100.0);
	percColocMarker1Array = multiplyArrayByScalar(percColocMarker1Array, 100.0);
	percColocMarker2Array = multiplyArrayByScalar(percColocMarker2Array, 100.0);

	Table.create("Metrics");
	Table.setColumn("[ImageLabel]", labelColumn);
	Table.setColumn("Cell_ID", id);
	Table.setColumn("Nucleus_Volume(um^3)", nucleusSize); // Add nucleus volume per cell
	Table.setColumn("#" + phNameMarker1 + "_Aggregates", nMarker1);
	Table.setColumn("Vol_" + phNameMarker1 + "_Aggregates(um^3)", volMarker1Microns);
	Table.setColumn("% Vol_" + phNameMarker1 + "_Aggregates per Nucleus", percMarker1Array); // Percentage Marker1/Nucleus
	Table.setColumn("#" + phNameMarker2, nMarker2);
	Table.setColumn("Vol_" + phNameMarker2 + "_Puncta(um^3)", volMarker2Microns);
	Table.setColumn("%Vol_" + phNameMarker2 + "_Puncta per Nucleus", percMarker2Array); // Percentage Marker2/Nucleus
	Table.setColumn("# Coloc Aggregates " + phNameMarker1 + "-" + phNameMarker2, nMarker1Coloc);
	Table.setColumn("Vol_Colocalized_" + phNameMarker1 + "-" + phNameMarker2 + "(um^3)", volMarker1ColocMicrons);
	Table.setColumn("%Vol_Colocalized_" + phNameMarker1 + "-" + phNameMarker2 + " per Nucleus", percColocMarker1Array); // Percentage Coloc Marker1/Nucleus
	Table.setColumn("# Coloc Puncta " + phNameMarker2 + "-" + phNameMarker1, nMarker2Coloc);
	Table.setColumn("Vol_Colocalized_" + phNameMarker2 + "-" + phNameMarker1 + "(um^3)", volMarker2ColocMicrons);
	Table.setColumn("%Vol_Colocalized_" + phNameMarker2 + "-" + phNameMarker1 + " per Nucleus", percColocMarker2Array); // Percentage Coloc Marker2/Nucleus

	IJ.renameResults("Results");

	//SAVE RESULTS
	run("Read and Write Excel", "file=["+output+File.separator+"QuantificationResults_IF3D_Coloc2NuclearMarkers"+phNameMarker1+"-"+phNameMarker2+".xlsx] stack_results");
	
	setBatchMode("exit and display");
	roiManager("reset");
	
	// Save image
	selectWindow("orig");
	setBatchMode("show");
	selectWindow("orig");
	run("Split Channels");
	selectWindow("C"+cDapi+"-orig");
	run("Enhance Contrast", "saturated=0.1");
	run("Apply LUT", "stack");
	selectWindow("C"+cMarker1+"-orig");
	run("Enhance Contrast", "saturated=0.1");
	run("Apply LUT", "stack");
	run("Gamma...", "value=1.4 stack");
	selectWindow("C"+cMarker2+"-orig");
	run("Enhance Contrast", "saturated=0.1");
	run("Apply LUT", "stack");
	run("Gamma...", "value=1.4 stack");
	run("Merge Channels...", "c1=[C"+cMarker2+"-orig] c2=[C"+cMarker1+"-orig] c3=[C"+cDapi+"-orig] create");
	run("Make Composite");
	run("RGB Color", "slices keep");
	rename("temp");
	
	
	roiManager("reset");
	RoiManager.restoreCentered(false);
	RoiManager.useNamesAsLabels(true);
	run("Duplicate...", "title=imageToSave3D duplicate ");
	selectWindow("dapiMask3D-seg-lbl");
	run("Label image to ROIs", "rm=[]");
	selectWindow("imageToSave3D");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	roiManager("show all with labels");
	roiManager("Set Color", "blue");
	roiManager("Set Line Width", 0);
	run("Labels...", "color=white font=10 show draw");
	RoiManager.useNamesAsLabels(true);
	roiManager("Show All with labels");
	run("Flatten", "stack");
	roiManager("reset");
	overlayLabels3D("imageToSave3D", "dapiMask3D", "blue");
	overlayLabels3D("imageToSave3D", "Marker1Mask3D", "red");
	overlayLabels3D("imageToSave3D", "Marker2Mask3D", "green");
	run("Flatten", "stack");
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_CellsID-3D.tiff");
	
	selectWindow("temp");
	run("Duplicate...", "title=imageToSave3D_nolabel duplicate ");
	selectWindow("dapiMask3D-seg-lbl");
	run("Label image to ROIs", "rm=[]");
	selectWindow("imageToSave3D_nolabel");
	overlayLabels3D("imageToSave3D_nolabel", "dapiMask3D", "blue");
	overlayLabels3D("imageToSave3D_nolabel", "Marker1Mask3D", "red");
	run("Select None");
	overlayLabels3D("imageToSave3D_nolabel", "Marker2Mask3D", "green");
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
	wait(1000);
	rename("imageToSave2D");
	//saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	
	close("merge");
	close("temp");
	
	
	// Save 2D projection image of detected things:
	rename("imageToSave2D");
	selectWindow("imageToSave2D");
	roiManager("Reset");
	selectWindow("Marker1ProjMask");
	run("Create Selection");
	run("Add to Manager");
	close();
	selectWindow("Marker2ProjMask");
	run("Create Selection");
	run("Add to Manager");
	close();
	selectWindow("colocProjMask");
	run("Create Selection");
	run("Add to Manager");
	close();
	selectWindow("imageToSave2D");
	roiManager("Select", 0);
	roiManager("Set Color", "Red");
	roiManager("Set Line Width", 1);
	run("Flatten");
	roiManager("Show None");
	roiManager("Select", 1);
	roiManager("Set Color", "Green");
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
	
		imageCalculator("OR create stack", "Marker1Mask3D","Marker2Mask3D");
		rename("coloc2mask");
		run("Invert LUT");
		selectWindow("Marker1Mask3D");
		close();
		selectWindow("Marker2Mask3D");
		close();
		
		selectWindow("orig");
		run("Duplicate...", "title=Marker1duplicate channels="+cMarker);
		run("Duplicate...", "title=Marker2 duplicate channels="+cMarker2);
		run("Coloc 2", "channel_1=Marker1 channel_2=Marker2 roi_or_mask=coloc2mask threshold_regression=Costes show_save_pdf_dialog display_images_in_result spearman's_rank_correlation manders'_correlation 2d_intensity_histogram psf=3 costes_randomisations=10");
	
		close("Marker");
		close("Marker2");
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
// Multiply, add, subtract, or divide two arrays element-wise
function arraysOps(arr1, arr2, op) {
    result = newArray(lengthOf(arr1));
    for (i = 0; i < lengthOf(arr1); i++) {
        if (op == "multiply") {
            result[i] = arr1[i] * arr2[i];
        } else if (op == "add") {
            result[i] = arr1[i] + arr2[i];
        } else if (op == "subtract") {
            result[i] = arr1[i] - arr2[i];
        } else if (op == "divide") {
            result[i] = arr1[i] / arr2[i];
        } else {
            result[i] = arr1[i]; // default: copy arr1
        }
    }
    return result;
}
