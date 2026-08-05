function infoMacro(){
    // Target User - Marisol aymerich - leyre ayerra - clara etc
    scripttitle = "Quantification of Triple Colocalization : Neuron + Microglia + Protein of Interest";
    version = "1.01";
    date = "2026";
    // Input image requirements
    imageAdquisition = "IF Confocal Images: 3 Channel: Neuron + Microglia + Protein of Interest";
    imageType = "3D 8 bit";
    voxelSize = "Voxel size: unknown um xy";
    format = "Format: Uncompressed .czi";

    // GUI User Requirements
    parameter1 = "Specify channel order for Neuron, Microglia, and Protein of Interest";
    parameter2 = "Set intensity threshold for each channel";
    parameter3 = "Set minimum particle size for segmentation";
    parameter4 = "Choose region of colocalization interest: Volumetric";

    // Action tools
    buttom1 = "Im: Single File processing";
    buttom2 = "DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

    // Output features (updated to match actual results)
    excel = "IF3D_NeuronPhagocytosis_Volumetric.xls";
    feature1 = "Neuron total volume (um^3)";
    feature2 = "Microglia total volume (um^3)";
    feature3 = "Protein of Interest total volume (um^3)";
    feature4 = "Total Protein of Interest Integrated Density";
    feature5 = "Neuron-Microglia Colocalization volume (um^3)";
    feature6 = "Coloc - Protein of Interest meanIntensity";
    feature7 = "Coloc - Protein of Interest stdIntensity";
    feature8 = "Coloc - Protein of Interest Integrated Density";

    // License
    showMessage("ImageJ Script", "<html>"
        +"<style>h{margin-top: 5px; margin-bottom: 5px;} p{margin: 0px;padding: 0px;} ol{margin-left: 20px;padding: 5px;} #list-style-3 {list-style-type: circle;.container {max-width: 1200px; margin: 0 auto; padding: 0px; }</style>"
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
        +"<p><font size=3><i>PARAMETERS: </i></p>"
        +"<ul id=list-style-3><font size=2>"
        +"<li>"+parameter1+"</li>"
        +"<li>"+parameter2+"</li>"
        +"<li>"+parameter3+"</li>"
        +"<li>"+parameter4+"</li></ul>"
        +"<p><font size=3><i>Quantification Results: </i></p>"
        +"<p><font size=3><i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
        +"<p><font size=3><i>Excel: "+excel+"</i></p>"
        +"<ul id=list-style-3><font size=2>"
        +"<li>"+feature1+"</li>"
        +"<li>"+feature2+"</li>"
        +"<li>"+feature3+"</li>"
        +"<li>"+feature4+"</li>"
        +"<li>"+feature5+"</li>"
        +"<li>"+feature6+"</li>"
        +"<li>"+feature7+"</li>"
        +"<li>"+feature8+"</li></ul>"
        +"<h0><font size=5></h0>"
        +"");
}


// Default parameters for analysis
var cNeuron = 3, cProt = 1, cMicroglia=2;               // Default channel numbers for neuron and protein markers
var thNeuron = 25, thMicroglia = 25, thProtein = 50;           // Thresholds for neuron and protein signal detection
var minSizeNeuron = 20, minSizeProtein = 20; // Minimum particle sizes for neuron and protein detection

// Macro for single-file quantification
macro "QIF Action Tool 1 - Cf00T2d15IT6d10m" {
    
    run("Close All"); // Close all currently open images and windows
	
	
    infoMacro();

    // Prompt user to select a file for analysis
    name = File.openDialog("Select File");
    print("Processing " + name); // Log the selected file
    
    // Create a dialog to adjust analysis parameters
    Dialog.create("Parameters for the analysis");
    
    // Channel selection
    Dialog.addMessage("Choose channel numbers");
    Dialog.addNumber("Neuron marker", cNeuron);
    Dialog.addNumber("Microglia marker", cMicroglia);
    Dialog.addNumber("Protein marker", cProt);
    
    // Segmentation parameters
    Dialog.addMessage("Choose analysis parameters");
    Dialog.addSlider("Neuron threshold", 0, 255, thNeuron);
    Dialog.addSlider("Microglia threshold", 0, 255, thMicroglia);
    Dialog.addSlider("Protein threshold", 0, 255, thProtein);
    //Dialog.addNumber("Min Neuron particle size (px)", minSizeNeuron);
    Dialog.addNumber("Min Neuron/Microglia particle size (px)", minSizeNeuron);
    Dialog.addNumber("Min particle size (px)", minSizeProtein);
    items=newArray("Volumetric");
    Dialog.addChoice("Choose Type of Analysis ", items);
    Dialog.show(); // Display the dialog and get user inputs
        
    // Update parameters based on user input
    cNeuron = Dialog.getNumber();
    cMicroglia = Dialog.getNumber();
    cProt = Dialog.getNumber();
    thNeuron = Dialog.getNumber();
    thMicroglia = Dialog.getNumber();
    thProtein = Dialog.getNumber();
    minSizeNeuron = Dialog.getNumber();
    minSizeProtein = Dialog.getNumber();
    typeAnalysis = Dialog.getChoice();
    
    print(typeAnalysis);            // Perform quantification on the current file
                
    // Perform quantification on the selected file
    IF3D_NeuronPhagocytosis("-", "-",typeAnalysis,name, cNeuron,cMicroglia, cProt, thNeuron,thMicroglia, thProtein, minSizeNeuron, minSizeProtein);
    showMessage("Quantification finished!"); // Notify user when the process is complete
}

// Macro for batch quantification on multiple files
macro "QIF Action Tool 2 - C00fT0b11DT9b09iTcb09r" {
    
    run("Close All"); // Close all open images and windows
        
    infoMacro();
    
    // Prompt user to select a directory containing tiles
    InDir = getDirectory("Choose Tiles' directory");
    list = getFileList(InDir); // Get a list of all files in the directory
    L = lengthOf(list); // Count the number of files
    
        // Create a dialog to adjust analysis parameters
    Dialog.create("Parameters for the analysis");
    
    // Channel selection
    Dialog.addMessage("Choose channel numbers");
    Dialog.addNumber("Neuron marker", cNeuron);
    Dialog.addNumber("Microglia marker", cMicroglia);
    Dialog.addNumber("Protein marker", cProt);
    
    // Segmentation parameters
    Dialog.addMessage("Choose analysis parameters");
    Dialog.addSlider("Neuron threshold", 0, 255, thNeuron);
    Dialog.addSlider("Microglia threshold", 0, 255, thMicroglia);
    Dialog.addSlider("Protein threshold", 0, 255, thProtein);
    Dialog.addNumber("Min Neuron/Microglia particle size (px)", minSizeNeuron);
    //Dialog.addNumber("Min Microglia particle size (px)", minSizeMicroglia);
    Dialog.addNumber("Min particle size (px)", minSizeProtein);
    items=newArray("Volumetric");
    Dialog.addChoice("Choose Type of Analysis ", items);
    
    Dialog.show(); // Display the dialog and get user inputs
    
    // Update parameters based on user input
    cNeuron = Dialog.getNumber();
    cMicroglia = Dialog.getNumber();
    cProt = Dialog.getNumber();
    thNeuron = Dialog.getNumber();
    thMicroglia = Dialog.getNumber();
    thProtein = Dialog.getNumber();
    minSizeNeuron = Dialog.getNumber();
    minSizeProtein = Dialog.getNumber();
    typeAnalysis = Dialog.getChoice();
    
    // Loop through all files in the directory
    for (j = 0; j < L; j++) {
        if (endsWith(list[j], "czi")) { // Process only .czi files
            name = list[j];
            print("Processing " + name); // Log the file being processed
            print(typeAnalysis);            
            IF3D_NeuronPhagocytosis(InDir, InDir,typeAnalysis,list[j], cNeuron,cMicroglia, cProt, thNeuron,thMicroglia, thProtein, minSizeNeuron, minSizeProtein);
        }
    }
    
    showMessage("Quantification finished!"); // Notify user when the batch process is complete
}


function IF3D_NeuronPhagocytosis(output, InDir, typeAnalysis, name, cNeuron,cMicroglia, cProt, thNeuron,thMicroglia, thProtein, minSizeNeuron, minSizeProtein) {
		
	/**
	 * Function to process 3D image stacks for neuron and protein analysis.
	 *
	 * @param {string} output - Output directory for processed files.
	 * @param {string} InDir - Input directory containing image files.
	 * @param {string} name - Name of the file to be processed.
	 * @param {number} cNeuron - Channel number for neuron marker.
	 * @param {number} cProt - Channel number for protein marker.
	 * @param {number} thNeuron - Threshold for neuron signal segmentation.
	 * @param {number} thProtein - Threshold for protein signal segmentation.
	 * @param {number} minSizeNeuron - Minimum size for neuron particles (px).
	 * @param {number} minSizeProtein - Minimum size for protein particles (px).
	 */
    
    run("Close All"); // Close all open images to reset the workspace
    
    // Import the image file using Bio-Formats Importer
    if (InDir == "-") {
        // Single file mode: File path is directly provided
        run("Bio-Formats Importer", "open=[" + name + "] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
    } else {
        // Directory mode: Combine directory path and file name
        run("Bio-Formats Importer", "open=[" + InDir + name + "] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
    }
    
    // Set the image stack display mode to composite
    Stack.setDisplayMode("composite");
    
    // Configure colors for analysis (e.g., ROI and background)
    run("Colors...", "foreground=black background=white selection=yellow");
    
    // Retrieve stack dimensions (width, height, channels, slices, frames)
    Stack.getDimensions(width, height, channels, slices, frames);
    
    // Reset ROI manager and clear any previous analysis results
    roiManager("Reset");
    run("Clear Results");
    
    setBatchMode(true);
    
    // Get the title of the currently opened image
    MyTitle = getTitle();
    output = getInfo("image.directory"); // Retrieve the directory where the image is located
    
    // Create an output directory for storing analyzed images
    OutDir = output + File.separator + "AnalyzedImages_"+typeAnalysis+"/";
    File.makeDirectory(OutDir); // Ensure the directory exists or create it
    
    // Extract the base name of the file (excluding the extension)
    aa = split(MyTitle, ".");
    MyTitle_short = aa[0]; // Shortened file title for labeling
    
    // Retrieve voxel size to be used in volumetric calculations
    getVoxelSize(rx, ry, rz, unit);
    
    // Rename the original window for easier reference
    selectWindow(MyTitle);
    rename("orig");
    setBatchMode("show");
    
   
	// Neuron detection and segmentation
	selectWindow("orig");
	run("Duplicate...", "title=neuron duplicate channels="+cNeuron+""); // Isolate neuron channel for processing
	run("Median...","radius=1 stack");
	run("Subtract Background...", "rolling=50 stack"); // Enhance signal by removing background noise
	//run("Gamma...", "value=0.50 stack"); // Enhance low intensity contrast with gmmma exp0.5
	run("Duplicate...", "title=neuronMask duplicate "); // Prepare a duplicate for binary mask creation
	run("8-bit");
	setAutoThreshold("Huang dark stack"); // Automatically determine an intensity threshold using Huang's method
	setThreshold(thNeuron, 255); // Apply user-defined threshold to segment neuron structures
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark"); // Generate a binary mask for segmented regions
	run("Median...", "radius=1 stack"); // Reduce noise in the mask
	//minSizeNeuron = 20;
	run("Analyze Particles...", "size=" + minSizeNeuron + "-Infinity pixel show=Masks in_situ stack"); // Detect and label individual neuron objects
	
	// Microglia detection and segmentation
	selectWindow("orig");
	run("Duplicate...", "title=microglia duplicate channels="+cMicroglia); // Isolate protein channel for processing
	run("Subtract Background...", "rolling=50 stack"); // Enhance signal by suppressing background noise
	run("Duplicate...", "title=microgliaMask duplicate ");
	run("Median...", "radius=1 stack");
	run("8-bit");
	setAutoThreshold("Huang dark stack");
	setThreshold(thProtein, 255); // Apply user-defined threshold for protein segmentation
	run("Convert to Mask", "method=Default background=Dark");
	run("Median...", "radius=1 stack");
	//minSizeNeuron = 20;
	run("Analyze Particles...", "size=" + minSizeNeuron + "-Infinity pixel show=Masks in_situ stack"); // Detect and label individual neuron objects
	
	// Protein of Interest detection and segmentation
	selectWindow("orig");
	run("Duplicate...", "title=protein duplicate channels="+cProt); // Isolate protein channel for processing
	run("Duplicate...", "title=proteinMask duplicate ");
	run("Morphological Filters (3D)", "operation=Closing element=Ball x-radius=2 y-radius=2 z-radius=2");
	close("proteinMask");
	rename("proteinMask");
	setAutoThreshold("Huang dark stack");
	//setThreshold(thProtein, 255); // Apply user-defined threshold for protein segmentation
	run("Convert to Mask", "method=Default background=Dark");
	run("Median...", "radius=1 stack");
	//minSizeProtein = 10;
	run("Analyze Particles...", "size=" + minSizeProtein + "-Infinity pixel show=Masks in_situ stack"); // Detect and label individual neuron objects
			
	print("3D Volume Quantification......");
			
	neuronMetrics= getIntensityMetrics3D("neuron","neuronMask");
	meanINeuron = neuronMetrics[0];  // Intensity within colocalized neuron regions
	stdNeuron = neuronMetrics[1];
	volNeuron = neuronMetrics[2];
	
	microgliaMetrics= getIntensityMetrics3D("microglia","microgliaMask");
	meanImicroglia = microgliaMetrics[0];  // Intensity within colocalized neuron regions
	stdImicroglia = microgliaMetrics[1];
	volmicroglia = microgliaMetrics[2];
	
	protMetrics= getIntensityMetrics3D("protein","proteinMask");
	meanIProt = protMetrics[0];  // Intensity within colocalized neuron regions
	stdIProt = protMetrics[1];
	volProt = protMetrics[2];
	proteinIntegratedDensity = protMetrics[3];
	
	if (typeAnalysis == "Volumetric"){
	
		// Colocalization Neuron - Microglia analysis
		print("Calculating Colocalization......");
		selectWindow("neuronMask");
		run("Duplicate...", "title=ColocMask duplicate "); // Combine neuron and protein masks
		imageCalculator("AND stack", "ColocMask", "microgliaMask"); // Identify overlapping regions of neuron and protein masks
		
		protColocMetrics= getIntensityMetrics3D("protein","ColocMask");
		meanIColocProt = protColocMetrics[0];
		stdIColocProt = protColocMetrics[1];
		volColoc = protColocMetrics[2];
		proteinIntegratedDensityColoc = protColocMetrics[3];
	
		
		// Save colocalization mask for further reference
		selectWindow("ColocMask");
		saveAs("Tiff", OutDir + File.separator + MyTitle_short + "_ColocMask.tif");
		rename("ColocMask");
		
	}
	run("Clear Results");
	close("Results");

			
	// SAVE RESULTS SECTION

	// Clear any residual results from previous operations
	run("Clear Results");
	
	if (typeAnalysis == "Volumetric"){
		
		resultsFile="IF3D_NeuronPhagocytosis_Volumetric.xls";		
		
		// Check if the results file already exists to append data
		if (File.exists(output + File.separator + resultsFile)) {
		    open(output + File.separator + resultsFile); // Open the existing results file
		    IJ.renameResults("Results"); // Ensure compatibility with the current results format
		}
		
		// Append analysis data to the results table
		i = nResults; // Determine the next available row in the results table
		setResult("[Label]", i, MyTitle); // Add the sample name or identifier
		setResult("Neuron total volume (um^3)", i, volNeuron); // Volume of neuron marker in cubic microns
		setResult("Microglia total volume (um^3)", i, volmicroglia); // Volume of protein marker in cubic microns
		setResult("Protein of Interest total volume (um^3)", i, volProt); // Volume of protein marker in cubic microns
		setResult("Total Protein of Interest Integrated Density ", i, proteinIntegratedDensity); // Mean intensity within colocalized protein regions
		setResult("Neuron-Microglia Colocalization volume (um^3)", i, volColoc); // Volume of colocalized neuron-protein regions
		setResult("Coloc - Protein of Interest meanIntensity)", i, meanIColocProt); // Mean intensity within colocalized neuron regions
		setResult("Coloc - Protein of Interest stdIntensity)", i, stdIColocProt); // Intensity variation in colocalized neuron regions
		setResult("Coloc - Protein of Interest Integrated Density", i, proteinIntegratedDensityColoc); // Mean intensity within colocalized protein regions
		
	}
	
	setBatchMode("exit and display");

	print(resultsFile);
	// Save the updated results table to the specified file
	saveAs("Results", output + File.separator + resultsFile);
	
	// Add 3D overlays to the raw image for visualization
	// Overlay based on colocalization mask, displayed in red
	addOverlay3D("orig","neuronMask",1,"green");
	addOverlay3D("orig","microgliaMask",1,"red");
	addOverlay3D("orig", "proteinMask", 2, "cyan");
	addOverlay3D("orig", "ColocMask", 2, "yellow");
	
	setBatchMode("exit and display");
	
	selectWindow("orig");
	// Save the final 3D analyzed image with all overlays
	saveAs("Tiff", OutDir + File.separator + MyTitle_short + "_3DAnalyzed.tif");
	close("\\Others");
	
	// Perform garbage collection to free up unused memory resources
	wait(500); // Small delay to ensure operations are completed before cleanup
	run("Collect Garbage");

}

function detectSomas(){
	
		// fill somas
		selectWindow("neuronMask");
		run("Duplicate...", "title=soma duplicate "); 
		run("Analyze Particles...", "size=200-Infinity pixel circularity=0.0-1.00 show=Masks stack in_situ");
		run("Erode", "stack");
		run("Erode", "stack");
		run("Dilate", "stack");
		run("Dilate", "stack");
		run("Invert","stack");
		run("Open", "stack");
		run("Open", "stack");
		run("Analyze Particles...", "size=1-Infinity pixel circularity=0.0-1.00 show=Masks exclude stack in_situ");
		imageCalculator("OR stack", "neuronMask", "soma");
		run("Invert","stack");
		run("Analyze Particles...", "size=500-Infinity pixel circularity=0-1.00 show=Masks stack in_situ");
		run("Invert","stack");
		close("soma");
}



function getSurface3d(mask) {
	/***
	 * surface from 3D specified mask.
	 * @param {string} mask - The title of the binary mask image window used to segment the input image.
	*/
	
    // Duplicate the mask for surface analysis and detect edges.
    selectWindow(mask);
    run("Duplicate...", "title=" + mask + "Surface duplicate");
    run("Find Edges", "stack");

    // Retrieve voxel dimensions for normalization.
    getVoxelSize(rx, ry, rz, unit);
    run("Clear Results");

    // Analyze 3D regions for volume and surface area.
    run("Analyze Regions 3D", "volume surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
    IJ.renameResults("Results");

    // Normalize surface area by voxel size and clear results.
    surf_mask = getResult("Volume", 0) / rx;
    selectWindow(mask + "Surface");
    run("Clear Results");

    return surf_mask; // Return the calculated surface area.
}


function getIntensityMetrics3D(im, mask) {
	/***
	 * Measures intensity metrics and volume for a 3D image using a specified mask.
	 *
	 * @param {string} im - The title of the input 3D image window to analyze.
	 * @param {string} mask - The title of the binary mask image window used to segment the input image.
	*/
	
    // Clear previous measurement results for the selected mask
    selectWindow(mask);
    run("Clear Results");

    // Perform intensity measurements and calculate volume for the masked area
	run("Intensity Measurements 2D/3D", "input=" + im + " labels=" + mask + " mean stddev numberofvoxels volume");
    selectWindow(im + "-intensity-measurements"); // Access results window
    IJ.renameResults("Results"); // Rename results for clarity

    // Retrieve intensity metrics from the results
    meanI_im = getResult("Mean", 0);  // Average intensity
    stdI_im = getResult("StdDev", 0); // Intensity variation
    vol_mask = getResult("Volume", 0); // Total volume
    nVoxels = getResult("NumberOfVoxels", 0); // Total volume
    
    //Array.print(newArray(meanI_im, nVoxels));
    integratedDensity = meanI_im * nVoxels; 
    

    // Clear results and return metrics as an array
    selectWindow(mask);
    run("Clear Results");
    return newArray(meanI_im, stdI_im, vol_mask,integratedDensity);
}


function addOverlay3D(rawImage, maskImage, channel, color) {
	/**
	* Adds a 3D overlay to a raw image based on a binary mask.
	* The overlay is applied slice-by-slice for multi-slice stacks.
	* 
	* @param {string} rawImage - The title of the raw image window.
	* @param {string} maskImage - The title of the binary mask image window.
	* @param {number} channel - The target channel for overlay visualization.
	* @param {string} color - The color for the overlay (e.g., "Red").
	*/
    
    // Activate the raw image and retrieve its dimensions
    selectWindow(rawImage);
    getDimensions(width, height, channels, slices, frames);
    RoiManager.associateROIsWithSlices(true); // Link ROIs to specific slices for stack processing

    // Ensure the image is a multi-slice stack before proceeding
    if (slices > 1) {
        for (i = 1; i <= slices; i++) { // Iterate through each slice
            selectWindow(maskImage);
            setSlice(i); // Focus on the current slice of the mask

            // Generate an ROI from the binary mask, if valid
            run("Create Selection");
            type = selectionType(); // Check if a valid selection exists
            if (type != -1) {
                Roi.setPosition(channel, i, 0); // Associate the ROI with the specific channel and slice
                selectWindow(rawImage);
                Stack.setChannel(channel); // Switch to the target channel in the raw image
                run("Restore Selection"); // Activate the selection on the raw image

                // Add the selection as an overlay and associate it with the correct position
                Overlay.addSelection(color);
                Overlay.setPosition(channel, i, 0);
            }
        }
    } else {
        print("The image is not a stack."); // Notify the user if the input is not multi-slice
    }
}


