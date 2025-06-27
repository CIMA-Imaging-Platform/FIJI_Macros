
function infoMacro(){
	
	
// *  Target User: Leyre Basurco y Leyre Ayerra, Clara - Marisol Aymerich";

	scripttitle= "3D COLOCALIZACION OF NEURO and Phagocytes Markers"
 	version= "1.01";
	date= "2024";
	
// *  Tests Images:

	imageAdquisition=" IF Confocal Images: 2 Channel: Neuron Marker + PhagoMarker";
	imageType="2D 8 bit ";  
	voxelSize="Voxel size: unknown um xy";
	format="Format: Uncompressed .czi";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button 
	
	// Default parameters for analysis
	parameter1 = "Introduce channel order for Neuron and Phagocytes"
	parameter2 = "Introduce Intensity threshold for Neuron and Phagocytes"
	parameter3 = "Introduce Min size for Neuron and Phagocytes"// Default channel numbers for neuron and protein markers
	parameter4 = "Introduce Region of Colocalization interest: Surface or Volume colocalization"// Default channel numbers for neuron and protein markers
	 
 //  2 Action tools:
	buttom1="Im: Single File processing";
 	buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs
	excel = "IF3D_NeuronPhagocytosis (Surface or Volumetric)";
	feature1 = "Neuron-marker volume (um^3)"; // Volume of neuron marker in cubic microns
	feature2 = "Neuron-marker meanIntensity [0-255])"; // Mean intensity of neuron marker
	feature3 = "Neuron-marker stdIntensity [0-255])"; // Standard deviation of neuron marker intensity
	feature4 = "Protein-marker volume (um^3)"; // Volume of protein marker in cubic microns
	feature5 = "Protein-marker meanIntensity [0-255])"; // Mean intensity of protein marker
	feature6 = "Protein-marker stdIntensity [0-255])"; // Standard deviation of protein marker intensity
	feature7 = "Neuron-Protein Colocalization volume (um^3)"; // Volume of colocalized neuron-protein regions
	feature8 = "Neuron Colocalization meanIntensity [0-255])"; // Mean intensity within colocalized neuron regions
	feature9 = "Neuron Colocalization stdIntensity [0-255])"; // Intensity variation in colocalized neuron regions
	feature10 = "Protein Colocalization meanIntensity [0-255])"; // Mean intensity within colocalized protein regions
	feature11 = "Protein Colocalization stdIntensity [0-255])"; // Intensity variation in colocalized protein regions

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
	    +"<ol><font size=2  i><li>"+buttom1+"</li><li>"+buttom2+"</li></ol>"
	    +"<p><font size=3  i>PARAMETERS: </i></p>"
	    +"<ul id=list-style-3><font size=2  i>"
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li>"
	    +"<li>"+parameter3+"</li>"
	    +"<li>"+parameter4+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li><li>"+feature5+"</li><li>"+feature6+"</li>"
	    +"<li>"+feature7+"</li><li>"+feature8+"</li><li>"+feature9+"</li><li>"+feature10+"</li><li>"+feature11+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
	}


// Default parameters for analysis
var cneuron = 2, cprotein = 1;               // Default channel numbers for neuron and protein markers
var thneuron = 50, thprotein = 50;           // Thresholds for neuron and protein signal detection
var minSizeneuron = 20, minSizeprotein = 20; // Minimum particle sizes for neuron and protein detection

// Macro for single-file quantification
macro "QIF Action Tool 1 - Cf00T2d15IT6d10m" {
    
    run("Close All"); // Close all currently open images and windows
    
    // Prompt user to select a file for analysis
    name = File.openDialog("Select File");
    print("Processing " + name); // Log the selected file
    
    // Create a dialog to adjust analysis parameters
    Dialog.create("Parameters for the analysis");
    
    // Channel selection
    Dialog.addMessage("Choose channel numbers");
    Dialog.addNumber("Neuron marker", cneuron);
    Dialog.addNumber("Protein marker", cprotein);
    
    // Segmentation parameters
    Dialog.addMessage("Choose analysis parameters");
    Dialog.addSlider("Neuron threshold", 0, 255, thneuron);
    Dialog.addSlider("Protein threshold", 0, 255, thprotein);
    Dialog.addNumber("Min neuron particle size (px)", minSizeneuron);
    Dialog.addNumber("Min protein particle size (px)", minSizeprotein);
    items=newArray("Volumetric","Surface");
    Dialog.addChoice("Choose Type of Analysis ", items);
    
    Dialog.show(); // Display the dialog and get user inputs
    
    // Update parameters based on user input
    cneuron = Dialog.getNumber();
    cprotein = Dialog.getNumber();
    thneuron = Dialog.getNumber();
    thprotein = Dialog.getNumber();
    minSizeneuron = Dialog.getNumber();
    minSizeprotein = Dialog.getNumber();
    typeAnalysis = Dialog.getChoice();
    
    print(typeAnalysis);            // Perform quantification on the current file
            
    
    // Perform quantification on the selected file
    IF3D_NeuronPhagocytosis("-", "-",typeAnalysis,name, cneuron, cprotein, thneuron, thprotein, minSizeneuron, minSizeprotein);
    showMessage("Quantification finished!"); // Notify user when the process is complete
}

// Macro for batch quantification on multiple files
macro "QIF Action Tool 2 - C00fT0b11DT9b09iTcb09r" {
    
    run("Close All"); // Close all open images and windows
    
    // Prompt user to select a directory containing tiles
    InDir = getDirectory("Choose Tiles' directory");
    list = getFileList(InDir); // Get a list of all files in the directory
    L = lengthOf(list); // Count the number of files
    
    // Create a dialog to adjust analysis parameters
    Dialog.create("Parameters for the analysis");
    
    // Channel selection
    Dialog.addMessage("Choose channel numbers");
    Dialog.addNumber("Neuron marker", cneuron);
    Dialog.addNumber("Protein marker", cprotein);
    
    // Segmentation parameters
    Dialog.addMessage("Choose analysis parameters");
    Dialog.addSlider("Neuron threshold", 0, 255, thneuron);
    Dialog.addSlider("Protein threshold", 0, 255, thprotein);
    Dialog.addNumber("Min neuron particle size (px)", minSizeneuron);
    Dialog.addNumber("Min protein particle size (px)", minSizeprotein);
    items=newArray("Volumetric","Surface");
    Dialog.addChoice("Choose Type of Analysis ", items);
    
    Dialog.show(); // Display the dialog and get user inputs
    
    // Update parameters based on user input
    cneuron = Dialog.getNumber();
    cprotein = Dialog.getNumber();
    thneuron = Dialog.getNumber();
    thprotein = Dialog.getNumber();
    minSizeneuron = Dialog.getNumber();
    minSizeprotein = Dialog.getNumber();
    typeAnalysis = Dialog.getChoice();
    
    // Loop through all files in the directory
    for (j = 0; j < L; j++) {
        if (endsWith(list[j], "czi")) { // Process only .czi files
            name = list[j];
            print("Processing " + name); // Log the file being processed
            print(typeAnalysis);            
            IF3D_NeuronPhagocytosis(InDir, InDir, list[j],typeAnalysis, cneuron, cprotein, thneuron, thprotein, minSizeneuron, minSizeprotein);
        }
    }
    
    showMessage("Quantification finished!"); // Notify user when the batch process is complete
}


function IF3D_NeuronPhagocytosis(output, InDir, typeAnalysis, name, cneuron, cprotein, thneuron, thprotein, minSizeneuron, minSizeprotein) {
		
	/**
	 * Function to process 3D image stacks for neuron and protein analysis.
	 *
	 * @param {string} output - Output directory for processed files.
	 * @param {string} InDir - Input directory containing image files.
	 * @param {string} name - Name of the file to be processed.
	 * @param {number} cneuron - Channel number for neuron marker.
	 * @param {number} cprotein - Channel number for protein marker.
	 * @param {number} thneuron - Threshold for neuron signal segmentation.
	 * @param {number} thprotein - Threshold for protein signal segmentation.
	 * @param {number} minSizeneuron - Minimum size for neuron particles (px).
	 * @param {number} minSizeprotein - Minimum size for protein particles (px).
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
    
    // Rearrange channels to place neuron and protein channels in the correct order
    run("Arrange Channels...", "new=" + cneuron + "" + cprotein + "");

	// Neuron detection and segmentation
	selectWindow("orig");
	run("Duplicate...", "title=neuron duplicate channels=1"); // Isolate neuron channel for processing
	run("Median...","radius=1 stack");
	run("Subtract Background...", "rolling=50 stack"); // Enhance signal by removing background noise
	//run("Gamma...", "value=0.50 stack"); // Enhance low intensity contrast with gmmma exp0.5
	run("Duplicate...", "title=neuronMask duplicate "); // Prepare a duplicate for binary mask creation
	run("8-bit");
	setAutoThreshold("Huang dark"); // Automatically determine an intensity threshold using Huang's method
	setThreshold(thneuron, 255); // Apply user-defined threshold to segment neuron structures
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark"); // Generate a binary mask for segmented regions
	run("Median...", "radius=1 stack"); // Reduce noise in the mask
	run("Analyze Particles...", "size=" + minSizeneuron + "-Infinity pixel show=Masks in_situ stack"); // Detect and label individual neuron objects
	
	// Protein detection and segmentation
	selectWindow("orig");
	run("Duplicate...", "title=protein duplicate channels=2"); // Isolate protein channel for processing
	run("Subtract Background...", "rolling=50 stack"); // Enhance signal by suppressing background noise
	run("Duplicate...", "title=proteinMask duplicate ");
	run("8-bit");
	setAutoThreshold("Huang dark");
	setThreshold(thprotein, 255); // Apply user-defined threshold for protein segmentation
	run("Convert to Mask", "method=Default background=Dark");
	run("Median...", "radius=1 stack");
	run("Analyze Particles...", "size=" + minSizeprotein + "-Infinity pixel show=Masks in_situ stack"); // Detect and label individual protein objects
	
	print("3D Volume Quantification......");
			
	neuronMetrics= getIntensityMetrics3D("neuron","neuronMask");
	meanINeuron = neuronMetrics[0];  // Intensity within colocalized neuron regions
	stdNeuron = neuronMetrics[1];
	volNeuron = neuronMetrics[2];
	
	protMetrics= getIntensityMetrics3D("protein","proteinMask");
	meanIProt = protMetrics[0];  // Intensity within colocalized neuron regions
	stdIProt = protMetrics[1];
	volProt = protMetrics[2];
	
	
	if (typeAnalysis == "Volumetric"){
	
		// Colocalization NeuroSurface - Protein analysis
		print("Calculating Colocalization......");
		selectWindow("neuronMask");
		run("Duplicate...", "title=ColocMask duplicate "); // Combine neuron and protein masks
		imageCalculator("AND stack", "ColocMask", "proteinMask"); // Identify overlapping regions of neuron and protein masks
		
		neuroColocMetrics= getIntensityMetrics3D("neuron","ColocMask");
		meanIColocNeuron = neuroColocMetrics[0];
		stdIColocNeuron = neuroColocMetrics[1];
		volColoc= neuroColocMetrics[2];
		
		protColocMetrics= getIntensityMetrics3D("protein","ColocMask");
		meanIColocProtein = protColocMetrics[0];
		stdIColocProtein = protColocMetrics[1];
		
		// Save colocalization mask for further reference
		selectWindow("ColocMask");
		saveAs("Tiff", OutDir + File.separator + MyTitle_short + "_ColocMask.tif");
		rename("ColocMask");
		
	}

	if (typeAnalysis == "Surface"){

		// fill somas
		selectWindow("neuronMask");
		run("Duplicate...", "title=soma duplicate ");
		run("Invert","stack");
		run("Open", "stack");
		run("Open", "stack");
		run("Analyze Particles...", "size=200-Infinity pixel circularity=0.0-1.00 show=Masks exclude stack in_situ");
		imageCalculator("OR stack", "neuronMask", "soma");
		run("Invert","stack");
		run("Analyze Particles...", "size=500-Infinity pixel circularity=0-1.00 show=Masks stack in_situ");
		run("Invert","stack");
		close("soma");
		
		selectImage("neuronMask");
		run("Label Boundaries");
		selectImage("neuronMask-bnd");
		run("Make Binary", " ");
		run("Erode", "stack");
		run("Erode", "stack");
		run("Erode", "stack");
		run("Dilate", "stack");
		run("Dilate", "stack");
		run("Dilate", "stack");
		run("Analyze Particles...", "size=500-Infinity pixel show=Masks stack in_situ");
		imageCalculator("OR stack", "neuronMask", "neuronMask-bnd");
		close("neuronMask-bnd");
				
		surf_Neuron = getSurface3d("neuronMask");
		
		// same method as surface of colocalization --> implement ratio 
		surf_Prot = getSurface3d("proteinMask");


		// Colocalization NeuroSurface - Protein analysis
		print("Calculating Colocalization......");
		selectWindow("neuronMaskSurface");
		run("Duplicate...", "title=NeuroSurfaceColocMask duplicate "); // Combine neuron and protein masks
		imageCalculator("AND stack", "NeuroSurfaceColocMask", "proteinMask"); // Identify overlapping regions of neuron and protein masks
				
		print("3D Surface Quantification......");
		
		neuroColocMetrics= getIntensityMetrics3D("neuron","NeuroSurfaceColocMask");
		meanIneuronColoc =neuroColocMetrics[0];  // Intensity within colocalized neuron regions
		stdIneuronColoc = neuroColocMetrics[1];
		volneuronColoc = neuroColocMetrics[2];
		surfneuronColoc = volneuronColoc / rx ; // simplify 1 pixel width volume to surface by dividing rx
		
		selectWindow("NeuroSurfaceColocMask");
		saveAs("Tiff", OutDir + File.separator + MyTitle_short + "_NeuroSurfaceColocMask.tif");
		rename("ColocMask");
		
		// Colocalization NeuroSurface - Protein analysis
		print("Calculating Colocalization......");
		selectWindow("proteinMaskSurface");
		run("Duplicate...", "title=proteinSurfaceColocMask duplicate "); // Combine neuron and protein masks
		imageCalculator("AND stack", "proteinSurfaceColocMask", "neuronMask"); // Identify overlapping regions of neuron and protein masks
			
		// Measure colocalized regions in relation to neuron and protein volumes
		selectWindow("proteinSurfaceColocMask");
		protColocMetrics= getIntensityMetrics3D("protein","proteinSurfaceColocMask");
		meanIprotColoc = protColocMetrics[0];  // Intensity within colocalized neuron regions
		stdIprotColoc = protColocMetrics[1];
		volprotColoc = protColocMetrics[2];
		surfprotColoc = volprotColoc / rx ; // simplify 1 pixel width volume to surface by dividing rx
		
		selectWindow("proteinSurfaceColocMask");
		saveAs("Tiff", OutDir + File.separator + MyTitle_short + "_proteinSurfaceColocMask.tif");
		close();
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
		setResult("Neuron-marker volume (um^3)", i, volNeuron); // Volume of neuron marker in cubic microns
		setResult("Neuron-marker meanIntensity [0-255])", i, meanINeuron); // Mean intensity of neuron marker
		setResult("Neuron-marker stdIntensity [0-255])", i, stdNeuron); // Standard deviation of neuron marker intensity
		setResult("Protein-marker volume (um^3)", i, volProt); // Volume of protein marker in cubic microns
		setResult("Protein-marker meanIntensity [0-255])", i, meanIProt); // Mean intensity of protein marker
		setResult("Protein-marker stdIntensity [0-255])", i, stdIProt); // Standard deviation of protein marker intensity
		setResult("Neuron-Protein Colocalization volume (um^3)", i, volColoc); // Volume of colocalized neuron-protein regions
		setResult("Neuron Colocalization meanIntensity [0-255])", i, meanIColocNeuron); // Mean intensity within colocalized neuron regions
		setResult("Neuron Colocalization stdIntensity [0-255])", i, stdIColocNeuron); // Intensity variation in colocalized neuron regions
		setResult("Protein Colocalization meanIntensity [0-255])", i, meanIColocProtein); // Mean intensity within colocalized protein regions
		setResult("Protein Colocalization stdIntensity [0-255])", i, stdIColocProtein); // Intensity variation in colocalized protein regions
		
	}
	

	if (typeAnalysis == "Surface"){
		
		resultsFile="IF3D_NeuronPhagocytosis_Surface.xls";		
		
		// Check if the results file already exists to append data
		if (File.exists(output + File.separator + resultsFile)) {
		    open(output + File.separator + resultsFile); // Open the existing results file
		    IJ.renameResults("Results"); // Ensure compatibility with the current results format
		}
		
		// Append analysis data to the results table
		i = nResults; // Determine the next available row in the results table
		setResult("[Label]", i, MyTitle); // Add the sample name or identifier
		setResult("Neuron-marker Surface (um^2)", i, surf_Neuron); // Volume of neuron marker in cubic microns
		setResult("Neuron-marker meanIntensity [0-255])", i, meanINeuron); // Mean intensity of neuron marker
		setResult("Neuron-marker stdIntensity [0-255])", i, stdNeuron); // Standard deviation of neuron marker intensity
		setResult("Protein-marker Surface (um^2)", i, surf_Prot); // Volume of protein marker in cubic microns
		setResult("Protein-marker meanIntensity [0-255])", i, meanIProt); // Mean intensity of protein marker
		setResult("Protein-marker stdIntensity [0-255])", i, stdIProt); // Standard deviation of protein marker intensity
		setResult("Neuron Colocalization Surface (um^2)", i, surfneuronColoc); // Volume of colocalized neuron-protein regions
		setResult("Neuron Colocalization meanIntensity [0-255])", i, meanIneuronColoc); // Mean intensity within colocalized neuron regions
		setResult("Neuron Colocalization stdIntensity [0-255])", i, stdIneuronColoc); // Intensity variation in colocalized neuron regions
		setResult("Protein Colocalization Surface (um^2)", i, surfprotColoc); // Volume of colocalized neuron-protein regions
		setResult("Protein Colocalization meanIntensity [0-255])", i, meanIprotColoc); // Mean intensity within colocalized protein regions
		setResult("Protein Colocalization stdIntensity [0-255])", i, stdIprotColoc); // Intensity variation in colocalized protein regions
				
	}
		
	setBatchMode("exit and display");

	
	print(resultsFile);
	// Save the updated results table to the specified file
	saveAs("Results", output + File.separator + resultsFile);
	
	// Add 3D overlays to the raw image for visualization
	// Overlay based on colocalization mask, displayed in red
	addOverlay3D("orig","neuronMask",1,"green");
	addOverlay3D("orig","proteinMask",1,"red");
	addOverlay3D("orig", "ColocMask", 1, "yellow");
	
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
    run("Intensity Measurements 2D/3D", "input=" + im + " labels=" + mask + " mean stddev volume");
    selectWindow(im + "-intensity-measurements"); // Access results window
    IJ.renameResults("Results"); // Rename results for clarity

    // Retrieve intensity metrics from the results
    meanI_im = getResult("Mean", 0);  // Average intensity
    stdI_im = getResult("StdDev", 0); // Intensity variation
    vol_mask = getResult("Volume", 0); // Total volume

    // Clear results and return metrics as an array
    selectWindow(mask);
    run("Clear Results");
    return newArray(meanI_im, stdI_im, vol_mask);
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


