/*
 * AUTOMATIC DETECTION OF CARDIOMYOCYTES - Aglutinina + Conexina
 * Target User: Maria Gonzalez
 *  
 *  Images: 
 *    - VECTRA FLOURESCENCE. 
	  - RGB Images
	  - Uncompress Format .JPG   
 *  
 *  GUI Requierments:
 *    - Delete unwanted fibrosis Regions 
 *    - Parameters . 
 *    - Add or Delete Detections. 
 *  
 *  Important Parameters
 *    - PROMINENCE -  
 *    - thFastMarching 
 *    
 *  OUTPUT: 
 *   Quantification_Cardiomyocytes.xls
 *   - Image Label
 *   - Number of cardiomyocytes
 *   - Tissue area in micras^2
 *   Imagelabel+_SegmentationResults.xls
 *   - CardioMyocyte ID:
 *   - CardioMyocyte Area 			
 *     
 *  Author: Tomás Muñoz 
 *  Date : March 2023
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


function infoMacro(){
	scripttitle= "AUTOMATIC DETECTION OF CARDIOMYOCYTES - Aglutinina + Conexina  ";
	version= "1.03";
	date= "March 2025";
	
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
	    +"<ul><font size=2  i><li>VECTRA Fluorescence</li><li>RGB images. DAPI(Blue) and Aglutinina+Conexina(Green) are selected.</li><li>Resolution: unknown</li<li>Format: Uncompressed .JPG</li></i></ul>"
	    +"<p><font size=3 i>Action tools (Buttons)</i></p>"
	    +"<ul><font size=2  i><li>Im: Single File Processing</li>"
	    +"<font size=2  i><li>Dir: BatchProcessing</li>"
	    +"<p><font size=3  i>Steps for the User</i></p><ol><li>Select File</li><li>Press Im </li><li>Introduce Parameters</li><li>Select Region of Interest</li><li>Edit Detections</li></ol>"
	    +"<p><font size=3  i>PARAMETERS: Must be adjusted for each batch of images</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li></li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=2  i>Result folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=2  i>Excel Quantification_Cardiomyocytes.xls</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>Image Label</li><li>#Cardiomyocytes<li>Tissue Area (um2)</li></ul>"
	    +"<p><font size=2  i>Excel Image_name+_SegmentationResults.xls</i></p>"
	    +"<ul id=list-style-3><li>Cardiomyocyte ID</li><li>Area of Cardiomyocyte (um2)</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
	}



var resolution =0.50; //Elvectra 0.5um pixel --> 20x
var tissueThrhld=7;
var AglutininaThd=30;
var prominence=5;
var nucleusDistance = 10;

		

macro "IF_CardioHypertrophy Action Tool 1 - Cf00T2d15IT6d10m"{
	
/*
 * This ImageJ macro, named "Aglutinina Action Tool 1", facilitates the automatic detection of tissue using Aglutinina staining. 
 * It prompts the user to set parameters for the analysis, including thresholds for tissue and membrane segmentation, as well as 
 * the option to separate joined cells. 
 * After parameter input, it segments the tissue using Aglutinina staining, which involves enhancing contrast, thresholding, creating a distance map, 
 * finding maxima, and analyzing particles. 
 * The macro then prompts the user to edit the detection with the provided buttons and finalize the process by pressing F. 
 * Output messages indicate the completion of the automatic detection process. 
 */

	infoMacro(); // Run predefined macro to gather information
	close("*"); // Close all open windows
	roiManager("Reset"); // Reset ROI manager
	run("Clear Results"); // Clear previous results
	run("Collect Garbage");
       
	
	// Open file dialog to select file
	open(File.openDialog("Select File"));
	MyTitle = getTitle(); // Get title of the selected file
	output = getInfo("image.directory"); // Get directory information
	OutDir = output + File.separator + "AnalyzedImages"; // Output directory for saving results
	File.makeDirectory(OutDir); // Create output directory if it doesn't exist
	MyTitle = File.getNameWithoutExtension(MyTitle);
	rename(MyTitle);

	/* Edit Region of Interest 
	 */
	selectRoi(MyTitle);

	cellSegmentation(MyTitle,tissueThrhld,AglutininaThd,prominence);
	
	quantifyMetrics(OutDir,MyTitle,resolution);
	 
	Dialog.create("DONE!");

}


macro "IF_CardioHypertrophy Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	infoMacro(); // Run predefined macro to gather information
	close("*"); // Close all open windows
	roiManager("Reset"); // Reset ROI manager
	run("Clear Results"); // Clear previous results

   	InDir=getDirectory("Choose a Directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"jpg") || endsWith(list[j],"tif")){
			close("*"); // Close all open windows
			roiManager("Reset"); // Reset ROI manager
			run("Clear Results"); // Clear previous resul
			setBatchMode("exit and display");
			setBatchMode(false);
			open(InDir+File.separator+list[j]);
			MyTitle = getTitle(); // Get title of the selected file
			output = getInfo("image.directory"); // Get directory information
			OutDir = output + File.separator + "AnalyzedImages"; // Output directory for saving results
			File.makeDirectory(OutDir); // Create output directory if it doesn't exist
			MyTitle = File.getNameWithoutExtension(MyTitle);
			rename(MyTitle);
		
		    /* Edit Region of Interest 
			 */
			selectRoi(MyTitle);
				
			cellSegmentation(MyTitle,tissueThrhld,AglutininaThd,prominence);
			
			quantifyMetrics(OutDir,MyTitle,resolution);
			run("Collect Garbage");
        }
	}
    Dialog.create("DONE!");
	
}
	

function selectRoi(MyTitle) {
	
	/**
	 * Selects regions of interest (ROI) in the specified image for further analysis.
	 * 
	 * @param {string} MyTitle - The title of the image containing ROIs.
	 * @returns {void}
	 */
	
	// Duplicate and split channels
	selectWindow(MyTitle);
	run("Duplicate...", "title=orig");
	run("Enhance Contrast", "saturated=0.35");
	// Option to delete a region from the image
	q=true;
	while (q) {
		setTool("freehand");
		waitForUser("Draw Region of Interest and press OK");
		type = selectionType();
		if (type == -1) {
			showMessage("No region has been selected. Whole image will be analyzed");
			run("Select All");
			q=false;
			Roi.setStrokeColor("yellow");
			Roi.setName("ROI");
			run("Add to Manager");
			roiManager("Deselect");
		} else {
			q=false;
			Roi.setStrokeColor("yellow");
			Roi.setName("ROI");
			run("Add to Manager");
			roiManager("Deselect");
		}
	}
	close("orig");
}


function cellSegmentation(image,tissueThrhld,AglutininaThd,prominence)
{
	/**
	 * Performs cell segmentation based on membrane and nucleus images.
	 * 
	 * @param {string} membrane - The name of the membrane image.
	 * @param {string} nucleus - The name of the nucleus image.
	 * @param {number} tissueThrhld - The threshold for tissue segmentation.
	 * @param {number} AglutininaThd - The threshold for membrane segmentation.
	 * @param {number} prominence - The prominence for finding maxima.
	 */
	 
	selectWindow(image);
	output = getInfo("image.directory"); // Get directory information
	OutDir = output + File.separator + "AnalyzedImages"; // Output directory for saving results
	
	run("Colors...", "foreground=black background=white selection=magenta"); 
	run("Options...", "iterations=1 count=1 do=Nothing");
	
	setBatchMode(true); 
	print("Segmenting TISSUE..");
	membrane = "Aglutinina";
	run("Duplicate...", "title=orig");
	run("Split Channels");	
	// Close unnecessary channels
	close("orig (red)");
	selectWindow("orig (blue)");
	rename("dapi");
	RoiManager.selectByName("ROI");
	setForegroundColor(255, 255, 255);
	setBackgroundColor(0, 0, 0);
	run("Clear Outside");
	// Process Aglutinina - GFP channel
	selectWindow("orig (green)");
	rename(membrane);
	RoiManager.selectByName("ROI");
	setForegroundColor(255, 255, 255);
	setBackgroundColor(0, 0, 0);
	run("Clear Outside");
	run("8-bit");
	run("Green");
	
	selectWindow(membrane); 

	// Tissue Area Segmentation
	run("Select None");
	run("Duplicate...", "title=tissue"); 
	RoiManager.selectByName("ROI");
	//tissueThrhld = 7;
	//setThreshold(tissueThrhld, 255); 
	setAutoThreshold("Percentile dark");
	getThreshold(lower, upper);
	setThreshold(lower-3, upper);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	close("Threshold"); 

	//run("Keep Largest Region");
	run("Invert"); 
	run("Analyze Particles...", "size=10000-Infinity pixel show=Masks in_situ"); 
	run("Invert"); 
	run("Create Selection"); 
	Roi.setStrokeColor("yellow");
	Roi.setName("tissue");
	run("Add to Manager"); 
	roiManager("Show None"); 
	run("Select None"); 
	
	selectWindow("Log");
	print("Segmenting Aglutinina+Conexina Stained Membrane..");
	// Membrane Segmentation
	selectWindow(membrane); 
	run("Duplicate...", "title=cellMask"); 
	RoiManager.selectByName("tissue")
	setForegroundColor(255, 255, 255);
	setBackgroundColor(0, 0, 0);
	run("Clear Outside");
	run("Select None");
	run("8-bit"); 
	run("Subtract Background...", "rolling=200");	
	run("Median...", "radius=1");
	run("Kuwahara Filter", "sampling=3");
	run("Subtract Background...", "rolling=20");
	run("Enhance Local Contrast (CLAHE)", "blocksize=127 histogram=256 maximum=3 mask=tissue fast_(less_accurate)");
	run("Apply LUT");
	RoiManager.selectByName("tissue")
	setAutoThreshold("Percentile dark");
	getThreshold(lower, upper);
	//setThreshold(lower+2, upper);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Analyze Particles...", "size=200-Inf pixel show=Masks in_situ"); 
	run("Invert");
	run("Analyze Particles...", "size=200-Inf pixel show=Masks exclude in_situ"); 
	imageCalculator("AND", "cellMask","tissue");
	run("Analyze Particles...", "size=200-Inf pixel show=Masks exclude in_situ"); 
	run("Median...", "radius=1");
	close(membrane);

	//MARKER CONTROLLED WATERSHED
	selectWindow("Log");
	print("Segmenting Individual Cells..");
	selectWindow("cellMask");
	run("Duplicate...", "title=EDM"); 
	run("Distance Map"); 
	prominence = 3;
	run("Find Maxima...", "prominence=" + prominence + " light output=[Single Points]"); 
	close("EDM"); 
	selectWindow("cellMask"); 
	run("Morphological Filters", "operation=Dilation element=Disk radius=2");
	close("cellMask");
	rename("cellMask");
	run("Duplicate...", "title=cellEdges"); 
	run("Variance...", "radius=1"); 
	run("Marker-controlled Watershed", "input=cellEdges marker=[EDM Maxima] mask=cellMask binary calculate use"); 
	selectWindow("cellEdges-watershed"); 
	run("8-bit"); 
	setThreshold(1, 255); 
	setOption("BlackBackground", false); 
	run("Convert to Mask"); 
	roiManager("show none");
	close("cellMask");
	rename("cellMask");
	close("cellE*"); 
	close("EDM*");
	run("Fill Holes");
	rename("cellMask");

	//segment nucleus 
	selectWindow("Log");
	print("Segmenting Nucleus..");
	selectWindow("dapi");
	run("Select None");
	run("Morphological Filters", "operation=Opening element=Disk radius=2");
	rename("dapiMask");
	//run("Threshold...");
	run("Auto Local Threshold", "method=Bernsen radius=15 parameter_1=0 parameter_2=0 white");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Analyze Particles...", "size=25-1000 pixel show=Masks in_situ");
	run("Watershed");
	run("Distance Map"); 
	prominence =1;
	run("Find Maxima...", "prominence=" + prominence + " light output=[Single Points]"); 
	run("Create Selection");
	run("Enlarge...", "enlarge=2 pixel");
	run("Clear", "slice");
	run("Select None");
	rename("centroid");
	close("dapi*");
	
	
	//FILTER CELLS BY : ASPECT RATION SHAPE - AVOID LONGITUDINAL CELLS
	selectWindow("Log");
	print("Filtering Detections By Aspect Ratio - Avoid Longitudinal Cells..");
	roiManager("reset");
	run("Clear Results");
	selectWindow("cellMask");
	run("Analyze Particles...", "show=Masks add in_situ");
	roiManager("show none");
	run("Set Measurements...", "area mean shape area_fraction redirect=None decimal=2");
	roiManager("measure");
	roiManager("show none");
	run("Select None");
		
	elongatedCells = filterTableColum("Results", "AR", "<", 3.5);
	roiManager("select", elongatedCells);
	roiManager("save selected", OutDir + "/"+image+"RoiSet.zip");
	roiManager("Reset");
	roiManager("Open",  OutDir + "/"+image+"RoiSet.zip");
	selectWindow(image);
	run("From ROI Manager");
	run("Create Mask");
	rename("cellMask-filtered");
	selectWindow(image);
	run("Remove Overlay");
	
	//FILTER CELLS BY : CENTERED NUCLEUS 
	selectWindow("Log");
	print("Filtering Detections by Centered Nucleus");
	selectWindow("cellMask-filtered");
	run("Distance Map");
	selectWindow("centroid");
	run("Divide...", "value=255");
	imageCalculator("Multiply create", "centroid","cellMask-filtered");
	rename("centroidDistances");
	close("cellMask-filtered");
	selectWindow("centroid");
	run("Multiply...", "value=255");

	run("Clear Results");
	close("Results");
	run("Set Measurements...", "area mean min shape area_fraction redirect=None decimal=2");
	selectWindow("centroidDistances");
	roiManager("measure");
	close("centroidDistances");
	
	containsNucleus = filterTableColum("Results", "Max", ">", nucleusDistance);
	roiManager("select", containsNucleus);
	roiManager("save selected", OutDir + "/"+image+"RoiSet.zip");
	roiManager("Reset");
	roiManager("Open",  OutDir + "/"+image+"RoiSet.zip");
	selectWindow(image);
	run("From ROI Manager");
	run("Create Mask");
	rename("cellMask-filtered");
	selectWindow(image);
	run("Remove Overlay");
	selectWindow("cellMask-filtered");
		
	imageCalculator("Substract","cellMask-filtered","centroid");
	
	selectWindow(image);
	run("Duplicate...", "title=merge");
	roiManager("reset");
	run("Clear Results");
	selectWindow("cellMask-filtered");
	setBatchMode("show");
	run("Analyze Particles...", "pixel add composite");
	roiManager("show none");
	selectWindow("merge");
	setBatchMode("show");
	run("Enhance Contrast", "saturated=0.35");
	roiManager("Set Color", "magenta");
	roiManager("Set Line Width", 0);
	roiManager("Show All without labels");
	
	//MANUAL CORRECTION
	addROIs();
	deleteROIs();
	
	selectWindow("merge");
	run("From ROI Manager");
	run("Create Mask");
	rename("positiveCells");
	Overlay.remove;
	
	
	//DELETE LONGUITUDINAL REGIONS
	selectWindow("merge");
	selectWindow("tissue");
	run("Create Selection");
	selectWindow("merge");
	run("Restore Selection");
	q=true;		
	while(q){
		// ADD
		selectWindow("merge");
		setTool("freehand");
		waitForUser("Please DELETE LONGITUDINAL TISSUE region and press OK");
		//check if we have a selection
		type = selectionType();
		if (type==-1)	{
			showMessage("Edition", "You should draw a REGION. Otherwise nothing will be DELETED.");
		}else{
			selectWindow("tissue");
			run("Restore Selection");
			setForegroundColor(255, 255, 255);
			run("Fill", "slice");
			run("Select None");
			
			selectWindow("cellMask");
			run("Restore Selection");
			setForegroundColor(255, 255, 255);
			run("Fill", "slice");
			run("Select None");
			
			selectWindow("cellMask");
			run("Restore Selection");
			setForegroundColor(255, 255, 255);
			run("Fill", "slice");
			run("Select None");
			
			selectWindow("positiveCells");
			run("Restore Selection");
			setForegroundColor(255, 255, 255);
			run("Fill", "slice");
			run("Select None");
			roiManager("reset");			
			run("Analyze Particles...", "pixel add composite");
			run("Select None");
				
			selectWindow("merge");
			roiManager("show all without labels");
		}
		q = getBoolean("Do you want delete another region?");
	}
	
	
	selectWindow("merge");
	Overlay.remove;
	roiManager("show all without labels");
	
	
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
		//print(lengthOf(positiveRois));
		// Return the array of positive indices
		return positiveRois;
	}
	


function addROIs(){

	 /*
	 * This ImageJ macro, named "Aglutinina Action Tool 2", provides functionality to add fibers to the detection.
	 * It prompts the user to draw a fiber to add and then fills the selected region with a mask. 
	 * After that, it analyzes the particles within the mask and displays the selection added message.
	*/
	
	q = getBoolean("Do you want to add MANUALLY a Cardiomyocite?");
		
	while(q){
		// ADD
		run("Select None");
		selectWindow("merge");
		setTool("freehand");
		waitForUser("Please draw a cardiomyocite and press OK");
		
		//check if we have a selection
		type = selectionType();
		if (type==-1)	{
			showMessage("Edition", "You should draw a fiber. Otherwise nothing will be added.");
		}else{
			selectWindow("cellMask-filtered");
			run("Restore Selection");
			setForegroundColor(0, 0, 0);
			run("Fill", "slice");
			run("Select None");
			
			roiManager("reset");
			selectWindow("cellMask-filtered");
			run("Analyze Particles...", "pixel add composite");
			run("Select None");
				
			selectWindow("merge");
			roiManager("show all without labels");
		}
		q = getBoolean("Do you want to add another Cardiomyocite?");
	}
}

function deleteROIs(){
	 
	/*
	 * This ImageJ macro, named "Aglutinina Action Tool 3", provides functionality to delete fibers from the detection.
	 * It prompts the user to select a fiber to delete and then fills the selected region with a mask to delete it. 
	 * After that, it analyzes the particles within the mask and displays the selection deleted message.
	 * 
	 */

   	q = getBoolean("Do you want to delete any Cardiomyocites?");
		
	while(q){
		// ADD
		run("Select None");
		selectWindow("merge");
		setTool("freehand");
		waitForUser("Please draw unwanted region and press OK");
		//check if we have a selection
		type = selectionType();
		if (type==-1)	{
			showMessage("Edition", "You should draw a fiber. Otherwise nothing will be added.");
		}else{
			selectWindow("cellMask-filtered");
			run("Restore Selection");
			setForegroundColor(255, 255, 255);
			run("Fill", "slice");
			run("Select None");
					
			roiManager("reset");
			selectWindow("cellMask-filtered");
			run("Analyze Particles...", "pixel add composite");
			run("Select None");
				
			selectWindow("merge");
			roiManager("show all without labels");
		}
		q = getBoolean("Do you want delete another region?");
	}
	

}
	

function quantifyMetrics(OutDir,MyTitle,resolution){
	/*
	 * It measures the area of the whole tissue and cardiomyocytes
	 * calculates statistics such as mean, minimum, maximum, and standard deviation of cardiomyocyte sizes, and saves the results in separate files.
	 * The results are saved in "Quantification_Cardiomyocytes.xls" and "MyTitle+_SegmentationResults.xls" files.
	 */

	// FINISH AND SAVE RESULTS
	selectWindow("Log");
	print("Filtering Detections by Centered Nucleus");
		
	// DETERMINE MICRONS/PIXEL RATIO:
	run("Set Measurements...", "area redirect=None decimal=2");	
	
	setBatchMode("exit and display");
	
	//Measure WHOLE TISSUE
	roiManager("Show None");
	selectWindow("tissue");
	setBatchMode("show");
	run("Create Selection");
	Roi.setStrokeColor("yellow");
	run("Set Scale...", "distance=1 known="+resolution+" unit=µm");
	run("Set Measurements...", "area redirect=None decimal=1");	
	run("Measure");
	tissueArea=getResult("Area",0,"Results");
	run("Clear Results");

	//Measure Cardiomyocytes
	selectWindow("merge");
	run("Restore Selection");
	Roi.setStrokeColor("yellow");
	Overlay.addSelection;
	nROIS=roiManager("Count");
	cellsID=Array.getSequence(nROIS);
	//print(cellsID[0]);
	roiManager("Select",cellsID);
	roiManager("Set Color", "magenta");
	roiManager("Show All with Labels");
	run("Labels...", "color=white font=8 show bold");
	run("Flatten");
	saveAs("Tiff", OutDir+File.separator+MyTitle+"_Analyzed.tif");	
		
	setBatchMode(true);
	selectWindow("merge");
	run("Set Scale...", "distance=1 known="+resolution+" unit=µm");
	run("Set Measurements...", "area redirect=None decimal=1");
	roiManager("Select",cellsID);
	roiManager("measure");
	close("cellMask");
	close("merge*");
	nROIS=roiManager("Count");
	cellsIndex=Array.getSequence(nROIS+1);
	cellsIndex=Array.slice(cellsIndex,1,nROIS+1);
	cellsArea=Table.getColumn("Area","Results");
	
	Array.getStatistics(cellsArea, minSize, maxSize, meanSize, stdSize);
	selectWindow(MyTitle+"_Analyzed.tif");	
	close("\\Others");
	run("Clear Results");

	//Save Area Results
	if (File.exists(OutDir+ File.separator+MyTitle+"_SegmentationResults.xls")){	//if exists add and modify
		File.delete(OutDir+ File.separator+MyTitle+"_SegmentationResults.xls");
		IJ.renameResults("Results");
		for (i = 0; i < lengthOf(cellsIndex); i++) {
			setResult("CardiomyocytesID", i,cellsIndex[i]);
			setResult("Area of tissue (um2)", i, cellsArea[i]); 
		}
		saveAs("Results", OutDir+File.separator+MyTitle+"_SegmentationResults.xls");
		
	}else {
		IJ.renameResults("Results");
		for (i = 0; i < lengthOf(cellsIndex); i++) {
			setResult("CardiomyocytesID", i,cellsIndex[i]);
			setResult("Area of tissue (um2)", i, cellsArea[i]); 
		}
		saveAs("Results", OutDir+File.separator+MyTitle+"_SegmentationResults.xls");
	}

	close(MyTitle+"_SegmentationResults.xls");
	close("Results");

	//run("Input/Output...", "jpeg=85 gif=-1 file=.csv use_file copy_column save_column");
	if(File.exists(OutDir+File.separator+"Quantification_Cardiomyocytes.xls"))
	{	
		//if exists add and modify
		open(OutDir+File.separator+"Quantification_Cardiomyocytes.xls");
		IJ.renameResults("Results");
	}else{
		IJ.renameResults("Results");
	}

	i=nResults;
	//print(i);
	setResult("[Label]", i, MyTitle,"Results"); 
	setResult("# total Cardiomyocytes", i, lengthOf(cellsIndex),"Results");
	setResult("Area of tissue (um2)", i, tissueArea,"Results"); 
	setResult("Cardiomyocytes MeanSize (um2)", i, meanSize,"Results"); 
	setResult("Cardiomyocytes stdSize (um2)", i, stdSize,"Results"); 
	setResult("Cardiomyocytes MaxSize (um2)", i, maxSize,"Results"); 
	setResult("Cardiomyocytes MinSize (um2)", i, minSize,"Results"); 
	
	saveAs("Results", OutDir+File.separator+"Quantification_Cardiomyocytes.xls");
	close("Quantification_Cardiomyocytes.xls");

	setBatchMode("exit and display");
}















