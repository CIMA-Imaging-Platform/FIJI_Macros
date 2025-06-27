function macroInfo(){
	
// * Target User: General
// *  

	scripttitle= "Netosis Quantification";
	version= "1.01";
	date= "Sep 2024";
	
	
// *  Tests Images:

	imageAdquisition="2D or Z stack Confocal, Single Channel";
	imageType="IF";  
	voxelSize="Voxel size: unknown um xy";
	format="Format: Uncompressed .czi";   
 
 //*  GUI User Requierments:
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button 
 
 	parameter1="Apply constrast enhacement if needed ";

 //  2 Action tools:
	buttom1="Im: Single File processing";
    buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs

	excelName="Quantification_IF_NETs.xls";
	feature1="Image Label";
	feature2="# Cells";
	feature3="# NETs";
	feature4="NETs Area  [microns^3]";
	
/*  	  
 *  version: 1.01 
 *  Author: Tomás Muñoz 
 *  Date : Sep 2024
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
	    +"<ol><font size=2  i><li>"+buttom1+"</li></ol>"
	    +"<p><font size=3  i>PARAMETERS: </i></p>"
	    +"<ul id=list-style-3><font size=2  i>"
	    +"<li>"+parameter1+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excelName+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}

var  applyContrast=false; 

setOption("WaitForCompletion", true);
setOption("ExpandableArrays", true);

macro "NETs Action Tool 1 - Cf00T2d15IT6d10m" {
    
    // Close all open images
    close("*");
    
    // Open dialog to select an image file
    name = File.openDialog("Select File");
 	run("Bio-Formats Importer", "open=[" + name + "] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
   
   	// Checks if image is a stack (multiple slices)
	getDimensions(width, height, channels, slices, frames);
	getVoxelSize(rx, ry, rz, unit);
	
	if (slices > 1) {
		run("Subtract Background...", "rolling=50 stack");  // Background subtraction for stacks
		run("Z Project...", "projection=[Max Intensity]");  // Z-projection for intensity
	}
	rename("projection");
	selectWindow("projection");
      
     // Display macro information
    macroInfo();
    
	// Cell segmentation options:
	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("NETs segmentation");
	Dialog.addCheckbox("Adjust contrast", applyContrast);
	Dialog.show();	
		
	applyContrast=Dialog.getCheckbox();
	
    // Open ROI Manager
    run("ROI Manager...");
        
    // Perform cell counting
    NETs("-", "-", name,applyContrast);
}

macro "NETs Action Tool 2 - C00fT0b11DT9b09iTcb09r" {
    // Close all open images
    close("*");
    
    // Display macro information
    macroInfo();
    
    // Open ROI Manager
    run("ROI Manager...");
    
    // Prompt user to select a directory
    InDir = getDirectory("Choose a Directory");
    list = getFileList(InDir);
    L = lengthOf(list);
    
	// Cell segmentation options:
	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("NETs segmentation")
	Dialog.addCheckbox("Adjust contrast", applyContrast);
	Dialog.show();	
		
	applyContrast=Dialog.getCheckbox();
      
     // Disable batch mode
    setBatchMode(false);
    
    // Loop through files in the directory and process each one
    for (j = 0; j < L; j++) {
        if (endsWith(list[j], "czi")) {
            name = list[j];
            NETs("-", InDir, name,applyContrast);
            setBatchMode(false);
        }
    }
    setBatchMode(false);
    showMessage("Batch Preprocessing DONE!");
}


function NETs(output, InDir, name,applyContrast) {
	
	/**
	 * Counts cells in a 2D image stack and performs quantification.
	 *
	 * @param output        The output directory path.
	 * @param InDir         The input directory path, or "-" if not applicable.
	 * @param name          The name of the image file to process.
	 */
	
	// Resets ROI Manager and closes all images
	roiManager("reset");
	run("Close All");
	run("Fresh Start");


    // Imports the image using Bio-Formats depending on whether InDir is provided
    if (InDir == "-") {
        run("Bio-Formats Importer", "open=[" + name + "] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
    } else {
  		
      	run("Bio-Formats Importer", "open=[" + InDir + name + "] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
    }
    
	setBatchMode(true);
    
	// Retrieves current image title and sets output directory
    MyTitle = getTitle();
    output = getInfo("image.directory");
    OutDir = output + File.separator + "AnalyzedImages";
    File.makeDirectory(OutDir);  // Creates output directory
    aa = split(MyTitle, ".");
    MyTitle_short = aa[0];  // Extracts base name from image title
    showStatus("Analyzing " + MyTitle);
           
    showStatus("Preprocessing -->"+MyTitle);
	print("Preprocessing -->"+MyTitle);	
    
	// Checks if image is a stack (multiple slices)
	getDimensions(width, height, channels, slices, frames);
	getVoxelSize(rx, ry, rz, unit);
	
	if (slices > 1) {
		run("Subtract Background...", "rolling=50 stack");  // Background subtraction for stacks
		run("Z Project...", "projection=[Max Intensity]");  // Z-projection for intensity
	}
	rename("projection");
	selectWindow("projection");
	run("Green");
	setBatchMode("show");
	
	close(MyTitle);
	
	// Preprocessing steps: Convert to 8-bit, background subtraction, and contrast enhancement
	run("8-bit");
	run("Subtract Background...", "rolling=50 stack");
	
	//applyContrast=true;
	if (applyContrast){
		run("Enhance Local Contrast (CLAHE)", "blocksize=100 histogram=100 maximum=2 mask=*None*");
		run("Apply LUT", "stack");
	}
		
	/* UNSUPERVISED PIXEL INTENSITY CLASSIFICATION 						 //////////////////////////////////////////////////////////////////////////////////////////////////////////*/
	
    showStatus("Clustering Pixels -->"+MyTitle);
	print("Clustering Pixels -->"+MyTitle);
	
	//using k-means clustering (unsupervised method)
	run("k-means Clustering ...", "number_of_clusters=4 cluster_center_tolerance=0.01000000 enable_randomization_seed randomization_seed=50");
	
	// Duplicate and convert each cluster into a mask
	for (i = 0; i < 4; i++) {
	    selectWindow("Clusters");
	    run("Duplicate...", "title=Cluster" + i);
	    setThreshold(i, i);
	    setOption("BlackBackground", false);
	    run("Convert to Mask");
	}
	
	// Measures mean intensity of each cluster to classify them
	clustersIntensities=newArray();
	for (i = 0; i < 4; i++) {
	    selectWindow("Cluster" + i);
	    run("Create Selection");
	    selectWindow("projection");
	    run("Restore Selection");
	    meanCluster = getValue("Mean");
	    clustersIntensities[i]=meanCluster;
	    print("Cluster"+i+" : "+meanCluster);
	    run("Select None");
	}

	// Sort clusters by intensity, from background to nuclei
	clusterID = newArray(0, 1, 2, 3);
	Array.sort(clustersIntensities, clusterID);  // Sort clusters based on intensity
	
	// Assign cluster IDs to relevant categories (background, NETs, nuclei)
	bckg = clusterID[0];
	NETsLowI = clusterID[1];
	NETsHighI = clusterID[2];
	nuclei = clusterID[3];
	
	// Rename windows to reflect cluster classification
	selectWindow("Cluster" + bckg);
	rename("background");
	selectWindow("Cluster" + NETsLowI);
	rename("NETsLowI");
	selectWindow("Cluster" + NETsHighI);
	rename("NETsHighI");
	selectWindow("Cluster" + nuclei);
	rename("nuclei");
	
	close("Clusters");
	
	//waitForUser;
	
	
	/* CLASSIFY Cells 					 //////////////////////////////////////////////////////////////////////////////////////////////////////////*/
	
    showStatus("Classify Cells -->"+MyTitle);
	print("Classify Cells -->"+MyTitle);
	
	// Select nuclei window and clear selection
	selectWindow("nuclei");
	run("Select None");
	
	// Apply morphological filters for nuclei refinement
	run("Morphological Filters", "operation=Closing element=Disk radius=2");
	run("Morphological Filters", "operation=Opening element=Disk radius=1");
	run("Median","radius=2");
	
	// Analyze particles to identify seeds
	run("Analyze Particles...", "size=50-Infinity show=Masks in_situ");
	rename("Seeds"); // Rename to 'Seeds'
	
	// Process background for watershed segmentation
	selectWindow("background");
	run("Select None");
	run("Invert");
	run("Morphological Filters", "operation=Dilation element=Disk radius=1");
	run("Median", "radius=1");
	run("Analyze Particles...", "size=50-Infinity show=Masks in_situ");
	run("Median","radius=2");
	
	// Duplicate for boundary and edge processing
	run("Duplicate...", "title=Boundary");
	run("Duplicate...", "title=Edges");
	run("Find Edges");
	close("*Closing*");
	
	// Perform marker-controlled watershed segmentation
	run("Marker-controlled Watershed", "input=Edges marker=Seeds mask=Boundary compactness=0 binary calculate use");
	
	// Threshold to define cell boundaries
	run("Threshold...");
	getThreshold(lower, upper);
	setThreshold(1, upper);
	setOption("BlackBackground", false);
	wait(10);
	run("Convert to Mask");
	rename("cells"); 
	run("Clear Results");
	
	// Close temporary windows
	close("Seeds");
	close("Edges");
	close("Boundary");
	close("Threshold");
	close("background");
	
	run("Clear Results");
	roiManager("reset");
	
	//Measure Median Cell Size 
	selectWindow("cells");
	run("Analyze Particles...", "size=1-Infinity circularity=0.6-1.00 show=Nothing display add");	
	wait(1000);
	cellSize = Table.getColumn("Area","Results");
	//x = Array.getSequence(lengthOf(aFraction));
	//Array.sort(aFraction);
	//Array.reverse(aFraction);
	//Plot.create("Title", "X-axis Label", "Y-axis Label");
	//Plot.addHistogram(aFraction, 1, 0);
	Array.getStatistics(cellSize, min, max, mean, stdDev);
	bottomSizeFilter=mean-2*stdDev;
	topSizeFilter=mean+2*stdDev;
	
	selectWindow("cells");
	run("Analyze Particles...", "size="+bottomSizeFilter+"-Infinity circularity=0-1.00 show=Masks in_situ");

	nCells=nResults;
	print("Cells Detected: "+nCells);
	
	selectWindow("cells");
	run("Analyze Particles...", "size="+topSizeFilter+"-Infinity circularity=0-1.00 show=Masks");
	rename("topTailCells");
	
	// Array.print(newArray(min, max, mean, stdDev));
	// Parametrization (commented out code for future reference)
	// This section is intended for histogram creation and statistical analysis
	
	selectWindow("cells");
	run("Clear Results");
	roiManager("reset");
	run("Duplicate...","duplicate");
	run("Analyze Particles...", "circularity=0-0.7 show=Masks in_situ");
	run("Select None");
	rename("possibleNET+");

	imageCalculator("OR", "possibleNET+", "topTailCells");
	close("topTailCells");
		
	// Prepare NETs from classified cells
	selectWindow("background-Dilation");
	run("Select All");
	setBackgroundColor(255,255,255);
	run("Clear");
	run("Select None");
	rename("NETs"); 
	
	// Combine low and high intensity NETs
	imageCalculator("OR", "NETsLowI", "NETsHighI");
	run("Select None");
	close("NETsHighI");
	
	// Refine NETsLowI
	selectWindow("NETsLowI");
	run("Morphological Filters", "operation=Dilation element=Disk radius=1");
	run("Morphological Filters", "operation=Erosion element=Disk radius=1");
	run("Analyze Particles...", "size=50-Infinite show=Masks in_situ");
	//run("Median", "radius=1"); // Apply median filter


	/* Identify  NETs within possible NET+ based on area percentage //////////////////////////////////////////////////////////////////////////////////////////////////////////*/
	

	run("Clear Results");
	roiManager("reset");
	
	// Analyze particles in the "possibleNET+" window
	selectWindow("possibleNET+");
	run("Morphological Filters", "operation=Erosion element=Disk radius=1");
	run("Analyze Particles...", " add");
	
	// Set measurement options to include area and integrated area fraction
	run("Set Measurements...", "area shape integrated area_fraction redirect=None decimal=2");
	
	// Process nuclei
	selectWindow("nuclei");
	run("Select None");
	run("Morphological Filters", "operation=Closing element=Disk radius=2");
	run("Fill Holes"); // Fill holes in nuclei
	run("Median", "radius=1");
	
	// Enlarge the selection from the "nuclei" mask and fill it
	setForegroundColor(255, 255, 255);
	selectWindow("nuclei-Closing");
	run("Create Selection");
	selectWindow("NETsLowI-Dilation-Erosion");
	run("Restore Selection");
	run("Enlarge...", "enlarge=2");
	run("Fill");
	
	selectWindow("NETsLowI-Dilation-Erosion");
	roiManager("Measure");
	//waitForUser;
	
	// Parametrization (commented out code for future reference)
	// This section is intended for histogram creation and statistical analysis
	
	/*
	aFraction = Table.getColumn("%Area");
	x = Array.getSequence(lengthOf(aFraction));
	Array.sort(aFraction);
	Array.reverse(aFraction);
	Plot.create("Title", "X-axis Label", "Y-axis Label");
	Plot.addHistogram(aFraction, 1, 0);
	Array.getStatistics(aFraction, min, max, mean, stdDev);
	Array.print(newArray(min, max, mean, stdDev));

	*/
		
	// Filter ROIs based on area and delete those below the threshold
	ROIsToDelete = filterTableColum("Results", "%Area", "<", 35);
	selectWindow("NETsLowI-Dilation-Erosion");
	roiManager("select", ROIsToDelete);
	roiManager("delete");
	
	netsDetected=roiManager("count");
	print("From NET+ (-->)  NETs+ Detected: "+netsDetected);
	
	if(netsDetected>0){
		selectWindow("NETsLowI");
		run("Duplicate...","title=NETsDetected ignore");
		run("Select None");
		roiManager("combine");
		run("Clear Outside");
		imageCalculator("OR", "NETs", "NETsDetected");
		close("NETsDetected");
	}
	
	selectWindow("NETs");
	
	//waitForUser;
		
	// Detect Isolated NETs
	selectWindow("cells");
	run("Morphological Filters", "operation=Closing element=Disk radius=2");
	run("Create Selection");
	selectWindow("NETsLowI");
	run("Restore Selection");
	run("Enlarge...","enlarge=3");
	run("Clear");
	run("Select None");
	selectWindow("nuclei");
	run("Invert");
	run("Fill Holes");
	run("Invert");
	run("Create Selection");
	selectWindow("NETsLowI");
	run("Restore Selection");
	run("Enlarge...","enlarge=5");
	run("Clear");
	run("Morphological Filters", "operation=Closing element=Disk radius=2");
	run("Median","radius=1");
	run("Select All");
	run("Enlarge...","enlarge=-5");
	run("Clear Outside");
	run("Select None");
	run("Analyze Particles...", "size=300-Infinity  circularity=0-0.5 show=Masks in_situ exclude");
	rename("NETsIsolated");
	
	imageCalculator("OR", "NETs","NETsIsolated");
	selectWindow("NETs");
	run("Morphological Filters", "operation=Closing element=Disk radius=2");
	rename("ROIs");
	setBatchMode("show");
	
	close("NETs*");
	close("nuclei*");
	close("cells*");
	close("possible*");
	setBatchMode("exit and display");
	
	
	// SEMIAUTOMATIC -- USER EDITION -- just in single file processing
	
	if (InDir == "-") {
		deleteROIsFun("ROIs", "projection");
		addROIsFun("ROIs", "projection");
	}
	
	run("Clear Results");
	roiManager("reset");
	
	selectWindow("ROIs");
	run("Analyze Particles...", "show=Nothing display add");	
	netsDetected=roiManager("count");
	print("From NET+ (-->)  NETs+ Detected: "+netsDetected);
	
	selectWindow("ROIs");
	run("Create Selection");
	areaNets=getValue("Area");
	areaNets=areaNets*rx*ry;
	//print(areaNets);
	
	//waitForUser;
		
	run("Clear Results");
	roiManager("reset");
	
	selectWindow("ROIs");
	run("Create Selection");
	selectWindow("projection");
	run("Green");
	run("Restore Selection");
	run("Flatten");
	saveAs("Tiff", OutDir + File.separator + MyTitle_short+"Analyzed");
	
	//--Save results
	run("Clear Results");
	if(File.exists(output+File.separator+"QuantificationResults_IF_NETs.xls"))
	{	
		//if exists add and modify
		open(output+File.separator+"QuantificationResults_IF_NETs.xls");
		IJ.renameResults("Results");
	}
	i=nResults;
	setResult("[Label]", i, MyTitle); 
	setResult("#Cells",i,nCells);
	setResult("# NETs ",i,netsDetected);
	setResult("NETsArea(um2)",i,areaNets);
	saveAs("Results", output+File.separator+"QuantificationResults_IF_NETs.xls");
	
	close("projection");



	
}

function filterTableColum(tableName, columnName, filterType, threshold)
{
	
	/**
	 * Filters a table column based on a given threshold.
	 * 
	 * @param {string} tableName - The name of the table window.
	 * @param {string} columnName - The name of the column to filter.
	 * @param {string} filterType - The type of filtering ("<" for values less than, ">" for values 
	 * @param {number} threshold - The threshold value for filtering.
	 * @return {array} positiveRois - An array containing the indices of rows that meet the filterin
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


function deleteROIsFun(Mask, orig) {
    
    selectWindow(Mask);
    run("Create Selection");
    type=selectionType();
    
    if (type !=-1){
    	
    	selectWindow(orig);
		run("Restore Selection");
    
    	// Loop to delete multiple ROIs if desired
	    deleteROIs = getBoolean("Do you want to Delete Detected NETs");
	    while (deleteROIs) {
	        // Prompt the user to draw a ROI to delete
	        setTool("freehand");
	        waitForUser("Please Draw ROI to delete and press OK when ready");
	        
	        // Check if a selection is made
	        type = selectionType();
	        if (type == -1) {
	            showMessage("Edition", "You should DRAW a REGION. Otherwise nothing will be deleted.");
	            
	        }else{
	        
		        // Apply the selection to the mask image
		        selectWindow(Mask);
		        setBatchMode("show");
		        run("Restore Selection");
		        setForegroundColor(255, 255, 255);
		        run("Fill", "slice");
		        run("Create Selection");
		        
		        // Apply the selection to the original image
		        selectWindow(orig);
		        run("Restore Selection");
		         
		        // Prompt the user to delete another ROI
		        selectWindow(orig);
		        deleteROIs = getBoolean("Do you want to Delete other Detected Regions");
	        }
	    }
    }
    
    
  
}

function addROIsFun(Mask, orig) {
	
	selectWindow(Mask);
    run("Create Selection");
    type=selectionType();
    
    if (type !=-1){
    	
    	selectWindow(orig);
		run("Restore Selection");
		
	    // Loop to add multiple ROIs if desired
	    addROIs = getBoolean("Do you want to ADD NETs");
	    while (addROIs) {
	        // Prompt the user to draw a ROI to delete
	        setTool("freehand");
	        selectWindow(orig);
	        waitForUser("Please Draw Vessels ROI and press OK when ready");
	      
	        // Check if a selection is made
	        type = selectionType();
	        if (type == -1) {
	            showMessage("Edition", "You should DRAW a REGION. Otherwise nothing will be added.");
	            exit();
	        }
	        
	        // Apply the selection to the mask image
	        selectWindow(Mask);
	        setBatchMode("show");
	        run("Restore Selection");
	        setForegroundColor(0, 0, 0);
	        run("Fill", "slice");
	        run("Create Selection");
	        
	        // Apply the selection to the original image
	        selectWindow(orig);
	        run("Restore Selection");
	        
	        // Prompt the user to add another ROI
	        selectWindow(orig);
	        addROIs = getBoolean("Do you want to add other Detected Regions");
	    }
    }
}




