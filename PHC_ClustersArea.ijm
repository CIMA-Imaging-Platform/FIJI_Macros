

function macroInfo(){
	
// * Target User: General
// *  

	scripttitle= "Quantification of Clustered Cells Area on PhaseContrast Microscopy ";
	version= "1.01";
	date= "2023";
	

// *  Tests Images:

	imageAdquisition="PhaseContrast Microscopy Images.";
	imageType="RGB";  
	voxelSize="Voxel size:  introduce by user [um/xy]";
	format="Format: Uncompressed .jpg";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button.
 
	 parameter1="Resolution (micra pixel ratio) = 0.502 micras/pixel xy"; 
	 parameter2="Min Cluster size (pixels)";
	 
	  
 //  2 Action tools:
		
	 buttom1="Im: Single File processing. Use Single file processing for fine tunning parameters";
	 buttom2="Dir: Batch Mode. Please tune parameters before using Batchmode";

//  OUTPUT

// Analyzed Images with ROIs

	excel="Results_PHC_ClusterArea.xls";
	feature1="Image Label";
	feature2="# Total Cluster";
	feature3="ID Cluster";
	feature4="Area of Cluster (um2)"
	
/*  	  
 *  version: 1.02 
 *  Author: Tomas Muñoz  
 *  Commented by: Tomas Muñoz 2023 
 *  Date : 2023
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
	    +"<li>"+parameter2+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}


// Define default parameters for cluster analysis

var r = 0.32; // Micron-to-pixel ratio for image resolution
var minSize = 1500; // Minimum cluster size in pixels
var thEdges=30;
    
/*
 * Macro: PHC_ClustersArea Action Tool 1
 * Description: Processes a single image for cluster quantification based on user-defined parameters.
 */
macro "PHC_ClustersArea Action Tool 1 - Cf00T2d15IT6d10m" 
{
 

 	
 	// Reset the ImageJ environment and close all open windows
    close("*");
    run("Fresh Start");
    run("Close All");
    roiManager("Reset");
    run("Clear Results");
    close("Threshold");
    
 	macroInfo();

    // Prompt the user to select a single image file for analysis
    name = File.openDialog("Select image file");
    print("Processing " + name);
    
    open(name);

 	 // Display a dialog for the user to input analysis parameters
    Dialog.create("Parameters for the analysis");
    Dialog.addMessage("Choose parameters"); // Instruction to the user
    //Dialog.addSlider("Threshold for ClusterDetection", 1, 255, 30); // Micron-to-pixel ratio
    Dialog.addNumber("Ratio micra/pixel", r); // Micron-to-pixel ratio
    Dialog.addNumber("Min Cluster size", minSize); // Minimum cluster size
 	items=newArray(0.5,1,5,10,25,30);
    Dialog.addChoice("Split Clusters", items);
    Dialog.show(); // Show the parameter dialog

    // Retrieve user-defined parameter values from the dialog
    r = Dialog.getNumber();
    //thEdges=Dialog.getNumber();
    minSize = Dialog.getNumber();
    tolerance = Dialog.getChoice();

     // Perform cluster analysis on the selected image with the given parameters
    clusterArea("-", "-", name, thEdges, r, minSize, tolerance);
    
    // Notify the user that the process is complete
    showMessage("CLUSTERS quantified!");

}


/**
 * Macro: PHC_ClustersArea Action Tool 2
 * Description: Processes all images in a selected directory for cluster quantification in batch mode.
 */
macro "PHC_ClustersArea Action Tool 2 - C00fT0b11DT9b09iTcb09r" 
{
	
   
   // Reset the ImageJ environment and close all open windows
    close("*");
    
 	macroInfo();
 	
    run("Fresh Start");
    run("Close All");
    roiManager("Reset");
    run("Clear Results");
    close("Threshold");

    // Prompt the user to select a directory containing images for batch processing
    InDir = getDirectory("Choose images directory");
    list = getFileList(InDir); // Get a list of all files in the selected directory
    L = lengthOf(list); // Determine the total number of files

    // Display a dialog for the user to input analysis parameters
    Dialog.create("Parameters for the analysis");
    Dialog.addMessage("Choose parameters"); // Instruction to the user
    //Dialog.addSlider("Threshold for ClusterDetection", 1, 255, 30); // Micron-to-pixel ratio
    Dialog.addNumber("Ratio micra/pixel", r); // Micron-to-pixel ratio
    Dialog.addNumber("Min Cluster size", minSize); // Minimum cluster size
 	items=newArray(0.5,1,5,10,25,30);
    Dialog.addChoice("Split Clusters", items);
    Dialog.show(); // Show the parameter dialog

    // Retrieve user-defined parameter values from the dialog
    r = Dialog.getNumber();
    //thEdges=Dialog.getNumber();
    minSize = Dialog.getNumber();
    tolerance = Dialog.getChoice();

    

    // Loop through each file in the directory and analyze valid image files
    for (j = 0; j < L; j++) {
        if (endsWith(list[j], ".tif") || endsWith(list[j], ".jpg")) {
            name = list[j]; // Get the file name
            print("Processing " + name); // Log the current file being processed
          
          	// Perform cluster analysis on the current image file
            clusterArea(InDir, InDir, list[j], thEdges, r, minSize, tolerance);
        }
    }

    // Notify the user that the batch process is complete
    showMessage("CLUSTERS quantified!");
}

function clusterArea(output,InDir,name,thEdges,r,minSize,tolerance)
{
	
	/**
	 * Function: clusterArea
	 * Description: Processes an image (or batch of images) to quantify cell clusters' area using various segmentation, filtering, and analysis techniques.
	 * Parameters:
	 *  - output: Directory to save the results and processed images.
	 *  - InDir: Input directory containing images to be analyzed.
	 *  - name: Name of the image file being processed.
	 *  - r: Micron-to-pixel ratio for area calculations.
	 *  - minSize: Minimum size (in pixels) for cluster detection.
	 *  - tolerance: Tolerance parameter for the watershed segmentation.
	 */
		
	// Reset ImageJ environment to ensure a clean workspace
    run("Close All");
    roiManager("Reset");
    run("Clear Results");
    setBatchMode(true);
    run("Collect Garbage"); // Clear unused memory

    // Open the specified image file, either from a directory or directly
    if (InDir == "-") {
        open(name); // Directly open the image if no directory is specified
    } else {
        if (!isOpen(InDir + name)) { // Open only if the image isn't already open
            open(InDir + name);
        }
    }

    // Initialize output directory for saving analyzed images
    MyTitle = getTitle(); // Get the title of the opened image
    output = getInfo("image.directory");
    OutDir = output + File.separator + "AnalyzedImages";
    File.makeDirectory(OutDir); // Create a folder for analyzed images

    // Extract image title without the file extension
    aa = split(MyTitle, ".");
    MyTitle_short = aa[0];

    // Configure measurement and processing options
    run("Colors...", "foreground=black background=white selection=green");
    run("Set Measurements...", "area mean area_fraction redirect=None decimal=2");
    run("Options...", "iterations=1 count=1 do=Nothing");

    // Field of View (FOV) calculation
    run("Select All");
    FOVpix = getValue("Area"); // Get area in pixels
    FOV = FOVpix * r * r; // Convert area to microns
    run("Select None");

    // Segment clusters using gradient-based detection
    
	//preprocessing
    selectWindow(MyTitle);
    run("RGB to Luminance"); // extract luminance
    //run("Unsharp Mask...", "radius=1 mask=0.60");
    rename("edges");
    //run("Median...", "radius=1"); // Smooth the image
    run("Find Edges"); // Detect edges
    
	//segmentation
    run("Threshold...");
    //setAutoThreshold("Default"); 
    //thEdges=30;
    setThreshold(thEdges, 255); // Manually refine threshold
    setOption("BlackBackground", false);
    run("Convert to Mask"); // Convert the thresholded image into a binary mask
  	run("Morphological Filters", "operation=Closing element=[Line 45 degrees] radius=1");
	run("Morphological Filters", "operation=Closing element=[Line 135 degrees] radius=1");
    close("edges"); 
    close("edges-Closing"); 
    rename("edges");

	// preprocess segmentation masks
    run("Duplicate...", "title=bckgInside");
    run("Invert");
    run("Analyze Particles...", "size=200-Infinity circularity=0.25-1.00 show=Masks exclude in_situ");
	selectWindow("bckgInside");
	run("Analyze Particles...", "size=500-Infinity show=Masks in_situ exclude");
       
    selectWindow("edges");
   	minSize = 1500;
    run("Analyze Particles...", "size=" + minSize + "-Infinity show=Masks in_situ");
    run("Median...", "radius=1"); 
    run("Morphological Filters", "operation=Opening element=[Disk] radius=1");
    close("edges");
    selectWindow("edges-Opening");
    rename("edges");
    run("Fill Holes");
    
 	// Subtract background from detected clusters
    imageCalculator("XOR", "edges", "bckgInside");
    run("Erode");
    //minSize = 1500;
    run("Analyze Particles...", "size=" + minSize + "-Infinity show=Masks in_situ exclude");
	run("Morphological Filters", "operation=Opening element=[Disk] radius=3");
	
	minSize = 1500;
    run("Analyze Particles...", "size=" + minSize + "-Infinity show=Masks in_situ exclude");
	
	rename("CLUSTERS");
	close("edges*");
    close("bck*");
    
	// Perform final cluster segmentation and analysis
	if (tolerance < 26){
		// Split clusters 
	    run("Adjustable Watershed", "tolerance=" + tolerance + ""); // Split clusters using watershed algorithm
	    roiManager("Show None");
	}
	
    //minSize = 1500; // Minimum size for final cluster detection
    run("Analyze Particles...", "size=" + minSize + "-Infinity show=Masks in_situ exclude add");

    roiManager("show none");
    run("Remove Overlay");
    run("Create Selection");
    totalAreaPix=getValue("Area");
    totalArea=totalAreaPix*r*r;

	
	nClusters = roiManager("count"); // Get the total number of clusters
    
    if (nClusters > 0){
				
	    // set measurements each cluster's area
	    run("Set Measurements...", "area redirect=None decimal=2");
		
	    roiManager("measure");
	    selectWindow("Results");
	    clustersSize = Table.getColumn("Area");

		run("Clear Results"); // Clear results table for each iteration
				
	    // Save results to an Excel file
	    for (j = 0; j < lengthOf(clustersSize); j++) {
	
	        // Check if the results file already exists
			if (File.exists(output + File.separator + "QuantificationResults_PHC_ClusterArea.xls")) {
				open(output + File.separator + "QuantificationResults_PHC_ClusterArea.xls"); // Open existing file
				IJ.renameResults("Results");
			}
			
	        // Add results for the current cluster
			i = nResults;
			setResult("[Label]", i, MyTitle); // Image label
	        setResult("FOV", i, FOV); // Field of view in microns
	        setResult("# Total Clusters", i, nClusters); // Total number of clusters
	        setResult("Area Total Clusters (um2)", i,totalArea);
	        setResult("ClusterID", i, j + 1); // Unique ID for each cluster
	        setResult("Area (um2)", i, clustersSize[j] * r * r); // Cluster area in microns
	        
	        // Save results back to the Excel file
	    	saveAs("Results", output + File.separator + "QuantificationResults_PHC_ClusterArea.xls");
	    }
	    
		// Save Analyzed Image
		setBatchMode("exit and display");

		selectWindow(MyTitle);
		roiManager("Show All without labels");
		roiManager("Show All with labels");
		run("Flatten");
	    saveAs("Tiff", OutDir + File.separator + MyTitle_short+"_Analyzed.tif");
		close("\\Others");

		
    }else{
    	showStatus("0 Segmented Clusters ");   	
    }
	
}



