

function macroInfo(){
	
// * Automatic Cell Classification based on Single and Double Phenotypes
// * Target User: Sheila
// *  b

	scripttitle= "Automatic Cardiomyocytes Death Count based on Double Phenotype (CY5+CY3-)";
	version= "1.01";
	date= "2025";
	
// *  Tests Images:

	imageAdquisition=" VECTRA POLARIS Images: 3 Channel: DAPI + 2 Markers: CY5 CY3";
	imageType="2D 8 bit ";  
	voxelSize="Voxel size: unknown um xy";
	format="Format: Uncompressed .qptiff";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
  
 //*	Cuantificacion Fibroblastos en IF , DAPI + CY5 . Eliminar los vasos 
 //*	------------------------------------------------------------------
 //*	Seleccionar zona de Infarto / PeriInfarto. --> #fibroblastos
 //*	
 //*	cardiomyocitos --> CY3+ (red) & CY5 (green)
 	
 //*    
 // Important Parameters: click Im or Dir + right button 
	
	parameter1="DAPI, CY5 CY3 Channel Order"; 
	 
 //  2 Action tools:
	buttom1="Im: Single File processing";
 	buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs

	excel="QuantificationResults_IF_CardioDeath.xls";
	feature1="Aortic Ring Tissue Area (um^2)";
	feature2="Area Infarction or PeriInfaction ROI Area (um^2)";
	feature3="# Cells Death";; 
	
/*
 *  version: 1.01 
 *  Author by: Tomas Muñoz 2025 
 *  Date : 2025
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
	    +"<li>"+parameter1+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}

var cDAPI=1, cCY3=2, cCY5=3; // thCY3=35, thCY5=24;

macro "IF_CellClassDoublePhenotype Action Tool 1 - Ca3fT0b10CT8b10ETfb10LTfb10L"{
		
	// Clear initialization of ROI manager and results table
	close("*");
	run("Collect Garbage");
	roiManager("Reset");
	run("Clear Results");
	RoiManager.associateROIsWithSlices(true);
	setOption("ExpandableArrays", true);
	setOption("WaitForCompletion", true);
	call("ij.plugin.frame.ThresholdAdjuster.setMode", "Red");
	
	macroInfo();
		
	// Open just one file
	name=File.openDialog("Select File");	
	//open(name);
	run("Bio-Formats", "open=["+name+"] autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT series_1");
	run("Make Composite");
	
	Dialog.create("Channels");
	Dialog.addMessage("Choose channel numbers");	
	Dialog.addNumber("DAPI", cDAPI);	
	Dialog.addNumber("CY3", cCY3);	
	Dialog.addNumber("CY5", cCY5);
	//Dialog.addSlider("Define CY3+ Threshold", 0, 255, thCY3);
	//Dialog.addSlider("Define CY5+ Threshold", 0, 255, thCY5);
	
	Dialog.show();	
	cDAPI= Dialog.getNumber();
	cCY3= Dialog.getNumber();
	cCY5= Dialog.getNumber();
	//thCY3= Dialog.getNumber();
	//thCY5= Dialog.getNumber();
	
	/*
	//TESTING PARAMS
	cDAPI=1;
	cCY3=2;
	cCY5=3;
	thCY3=35; 
	thCY5=24;
	*/
	
	// Set color configuration and measurements
	run("Colors...", "foreground=white background=black selection=green");
	run("Set Measurements...", "area mean area_fraction redirect=None decimal=2");
			
		
	// Get file information
	MyTitle=getTitle();
	output=getInfo("image.directory");
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	getDimensions(width, height, channels, slices, frames);
	getVoxelSize(width, height, depth, unit);
	
	Stack.setChannel(1);
	run("Blue");
	Stack.setChannel(2);
	run("Red");
	Stack.setChannel(3);
	run("Green");
	
	setBatchMode(true);
	// TISSUE SEGMENTATION
	run("Duplicate...", "title=merge duplicate ");
	run("Make Composite");
	run("RGB Color");
	//run("RGB to Luminance");
	close("merge");
	rename("merge");
	//run("Brightness/Contrast...");
	run("Enhance Contrast", "saturated=0.15");
	//run("Apply LUT");
	run("8-bit");
	// Convert image to binary mask
	run("Threshold...");
	resetThreshold;
	//setAutoThreshold("Huang dark no-reset");
	setThreshold(15, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Close-");
	run("Dilate");
	//	run("Watershed");
	run("Analyze Particles...", "size=1000-Infinity pixel show=Masks in_situ");
	run("Median", "radius=5");
	run("Keep Largest Region");
	// Analyze particles to identify tissue regions
	rename("tissueMask");
	close("merge*");
	setBatchMode("exit and display");
	
	selectWindow(MyTitle);
	
	// Add segmented tissue region to ROI manager
	selectWindow("tissueMask");
	deleteROIsFun("tissueMask", MyTitle);
	
	selectWindow("tissueMask");
	roiManager("Show None");
	run("Create Selection");
	Roi.setName("Tissue");
	Roi.setStrokeColor("yellow");
	run("Add to Manager");	// ROI1 --> WHOLE TISSUE
	run("Select None");
	close("merge*");
	run("Clear Results");
	close("Results");
	
	selectWindow(MyTitle);

	// Introduce area of Interest to quantify: -->
 	setTool("freehand");
	waitForUser("Select ROI for Analysis: infarction Area");
	type = selectionType();
	if (type==-1)	{
		waitForUser("Edition", "You should draw an ROIs.Otherwise nothing will be added.");
	 }else{
	 	Dialog.create("Parameter needed");
 		Dialog.addString("Introduce ROI Name","Infart");
	 	Dialog.show();	
	 	roiName=Dialog.getString();
	 	Roi.setName(roiName);
		run("Add to Manager");
	 }
	close("selectROI");
	roiManager("Select", newArray(0,1));
	roiManager("AND");
	Roi.setName("Infart");
	run("Add to Manager");
	roiManager("deselect");
	roiManager("select",1);
	roiManager("delete");
	roiManager("select",1);
	run("Create Mask");
	rename(roiName+"Mask");
	
	// SEGMENT 2nd MARKER: marker (CY5+) 
	selectWindow(MyTitle);
	cCY5=3;
	run("Select None");
	run("Duplicate...", "title=CY5Mask duplicate channels="+cCY5);
	
	//run("Subtract Background...", "rolling=50");
	//backgroundSubstract2DGPU("CY5Mask",50.0);
	//resetMinAndMax();
	
	RoiManager.selectByName("Tissue");
	setAutoThreshold("Otsu dark no-reset");
	//run("Threshold...");
	//setThreshold(35, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=2");
	
	RoiManager.selectByName(roiName);
	run("Colors...", "foreground=black background=white selection=green");
	run("Clear Outside");
	run("Select None");
	run("Analyze Particles...", "size=100-Infinity pixel show=Masks in_situ");
		
	run("Create Selection");
	Roi.setName("CY5");
	Roi.setStrokeColor("green");
	run("Add to Manager");	// ROI2 -->cardiomyocytes
	run("Select None");
	
	roiManager("deselect");
	roiManager("measure");
	tissueArea=getResult("Area", 0);
	roiArea=getResult("Area", 1);
	cy5PositiveArea=getResult("Area", 2);
	
	selectWindow("tissueMask");
	setBatchMode("hide");
	selectWindow(roiName+"Mask");
	setBatchMode("hide");
	selectWindow("CY5Mask");
	setBatchMode("hide");
		
	run("Clear Results");
	close("Results");
		
	//run("Collect Garbage");
	
	// SEGMENT NUCLEI FROM DAPI:
	
	setBatchMode(true);

	// Duplicate the image and apply mean filtering
	selectWindow(MyTitle);
	cDAPI=1;
	run("Duplicate...", "title=nucleiMask duplicate channels="+cDAPI);
	// Apply thresholding and morphological operations to segment nuclei
	run("Enhance Contrast", "saturated=0.35");
	run("Apply LUT");
	run("Median...", "radius=1");
		
	RoiManager.selectByName(roiName);
	run("Colors...", "foreground=white background=black selection=green");
	run("Clear Outside");
	run("Select None");	
	run("Subtract Background...", "rolling=40");
	
	// Background subtraction using GPU acceleration
	//backgroundSubstract2DGPU("nucleiMask",40);
	RoiManager.selectByName(roiName);

	selectWindow("nucleiMask");	
	RoiManager.selectByName(roiName);
	run("Find Maxima...", "prominence=20 output=[Single Points]");
	//run("Auto Local Threshold", "method=Bernsen  radius=20 parameter_1=20 parameter_2=0 white");
	selectWindow("nucleiMask");	
	RoiManager.selectByName(roiName);
	setAutoThreshold("Huang dark");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Duplicate...", "title=nucleiMaskEdges");
	run("Find Edges");
	run("Marker-controlled Watershed", "input=nucleiMaskEdges marker=[nucleiMask Maxima] mask=nucleiMask compactness=0 binary calculate use");
	setAutoThreshold("Minimum dark");
	getThreshold(lower, upper);
	setThreshold(1, upper);
	setOption("BlackBackground", false);
	run("Convert to Mask");

	//run("Adjustable Watershed", "tolerance=0.5");
	run("Analyze Particles...", "size=10-1000 pixel show=Masks in_situ");
	rename("nuclei");
	close("nucleiMask*");
	selectWindow("nuclei");
	run("Create Selection");
	Roi.setName("nuclei");
	Roi.setStrokeColor("magenta");
	run("Add to Manager");	// ROI2 --> Watershed NUCLEI
	run("Select None");
	
	roiManager("Save", OutDir+File.separator+MyTitle_short+"_roisDAPI.zip");
	
	//run("Collect Garbage");
		
	// SEGMENT 1st MARKER: CY3 cell death marker ()
	
	setBatchMode("exit and display");
	
	// Duplicate the image and apply background subtraction
	selectWindow(MyTitle);
	cCY3=2;
	run("Duplicate...", "title=CY3Mask duplicate channels="+cCY3);
	run("Red");
	//backgroundSubstract2DGPU("CY3Mask",100.0);
	run("Subtract Background...", "rolling=40");

	//run("Enhance Contrast", "saturated=0.1");
	//run("Apply LUT");
		
	// Apply thresholding and morphological operations to segment marker
	RoiManager.selectByName("Tissue");
	run("Threshold...");
	call("ij.plugin.frame.ThresholdAdjuster.setMode", "Red");
	resetThreshold;
	setAutoThreshold("Otsu dark no-reset");
	getThreshold(lower, upper);
	call("ij.plugin.frame.ThresholdAdjuster.setMode", "Over/Under");
	setThreshold(0, lower);
	waitForUser("Adjust Cell Death Marker and press OK");
	//thCY3=35;
	//setThreshold(thCY3, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Invert");
	setBatchMode("hide");
	
	RoiManager.selectByName(roiName);
	run("Colors...", "foreground=black background=white selection=green");
	run("Clear Outside");
	run("Select None");
	
	
	/*
	run("Auto Local Threshold", "method=MidGrey radius=10 parameter_1=0 parameter_2=0 white");
	run("Make Binary");
	run("Fill Holes");
	*/
			
	run("Create Selection");
	type=selectionType();
	if( type != -1){
		Roi.setName("CY3");
		Roi.setStrokeColor("red")
		run("Add to Manager");	
		run("Select None");
	}
	
	// CHECK WHICH NUCLEI CONTAIN THE CY3 DEATH MARKER
	
	roiManager("Reset");
	run("Clear Results");
	
	// Analyze particles to identify nuclei in the mask
	selectWindow("nuclei");
	run("Analyze Particles...", "size=1-Inf show=Masks add in_situ");
	roiManager("Show None");
	nCells = roiManager("Count");
	
	// Duplicate the nuclei mask and clear it to create the CY5-positive mask
	selectWindow("nuclei");
	run("Select All");
	run("Duplicate...", "title=CY3positive");
	run("Select All");
	setBackgroundColor(255, 255, 255);
	run("Clear", "slice");
	setBackgroundColor(0,0,0);
	run("Select None");
	wait(100);
	
	// Measure the CY3 marker in the DAPI mask
	run("Clear Results");
	selectWindow("CY3Mask");
	run("Select None");
	roiManager("Deselect");
	selectWindow("CY3Mask");
	roiManager("show all without labels");
	roiManager("Measure");
	n = nResults;
	roiManager("Show None");
	
	// Filter out nuclei containing the CY3 marker and save the selection
	positiveRois = filterTableColum("Results", "%Area", ">", 5);
	
	print("Total Cells: " + n);
	print("Positive Cells: " + lengthOf(positiveRois));
	roiManager("select", positiveRois);
	roiManager("save selected", OutDir + File.separator + MyTitle_short + "_roisCY3+.zip");
	roiManager("Reset");
	roiManager("Open", OutDir + File.separator + MyTitle_short + "_roisCY3+.zip");
	selectWindow("CY3positive");
	run("Colors...", "foreground=black background=white selection=green");
	roiManager("Fill");
	
	nCY3 = roiManager("Count");
	run("Select None");
	
	roiManager("Show None");

	run("Collect Garbage");
	
	// CHECK ONE BY ONE WHICH NUCLEI CONTAIN CY5 MARKER
	
	roiManager("Reset");
	run("Clear Results");
	
	selectWindow("nuclei");
	run("Analyze Particles...", "size=1-Inf show=Masks add in_situ");
	roiManager("Show None");
	
	selectWindow("nuclei");
	run("Select All");
	run("Duplicate...", "title=CY5positive");
	run("Select All");
	setBackgroundColor(255, 255, 255);
	run("Clear", "slice");
	setBackgroundColor(0,0,0);
	run("Select None");
	wait(100);
		
	run("Clear Results");
	selectWindow("CY5Mask");
	run("Select None");
	roiManager("Deselect");
	selectWindow("CY5Mask");
	roiManager("Measure");
		
	n=nResults;
	
	positiveRois=filterTableColum("Results","%Area",">",5);
	
	print("Total Cells: "+n);
	print("positive Cells "+lengthOf(positiveRois));
	positiveRois=Table.getColumn("Index");
	roiManager("select", positiveRois);
	roiManager("save selected", OutDir+File.separator+MyTitle_short+"_roisCY5+.zip");
	roiManager("Reset");
	roiManager("Open", OutDir+File.separator+MyTitle_short+"_roisCY5+.zip");
	selectWindow("CY5positive");
	run("Colors...", "foreground=black background=white selection=green");
	roiManager("Fill");
		
	nCY5=roiManager("Count");
	
	run("Select None");

	roiManager("Show None");
	//run("Collect Garbage");
		
	// CHECK CELLS THAT HAVE BOTH THE CY5 and CY3eolina MARKERS.
		
	imageCalculator("AND create", "CY5positive", "CY3positive");
	rename("CY3+CY5+_Cells");
	roiManager("Reset");
	run("Clear Results");
	run("Analyze Particles...", "size=1-Inf show=Masks add in_situ");
	roiManager("Show None");
	nCY3_CY5 = roiManager("Count");
	run("Select None");
	roiManager("Show None");
	
	// RESULTS--
	
	// Write results:
	run("Clear Results");
	if (File.exists(output + File.separator + "QuantificationResults_IF_CardioDeath.xls")) {
	    // if exists add and modify
	    open(output + File.separator + "QuantificationResults_IF_CardioDeath.xls");
	    IJ.renameResults("Results");
	}
	i = nResults;
	setResult("Label", i, MyTitle);
	setResult("Tissue Area (um^2)", i, tissueArea);
	setResult(roiName+"Area (um^2)", i, roiArea);
	setResult("CY5positive Area (um^2)", i, cy5PositiveArea);
	setResult("Death Area (um^2)", i, roiArea-cy5PositiveArea);
	setResult("# Cardiomyocites CY5+CY3+", i, nCY3_CY5);
	saveAs("Results", output + File.separator + "QuantificationResults_IF_CardioDeath.xls");
	
	setBatchMode("exit and display");
	
	// Save 2D projection image of detected things:
	selectWindow(MyTitle);
	run("RGB Color");
	rename("imageToSave");
	close(MyTitle);
	selectWindow("imageToSave");
	roiManager("Reset");
	selectWindow("tissueMask");
	run("Create Selection");
	run("Add to Manager");
	close();
	selectWindow(roiName+"Mask");
	run("Create Selection");
	run("Add to Manager");
	close();
	selectWindow("CY5Mask");
	run("Create Selection");
	run("Add to Manager");
	close();
	selectWindow("CY3+CY5+_Cells");
	run("Create Selection");
	run("Add to Manager");
	close();
	selectWindow("imageToSave");
	roiManager("Select", 0);
	roiManager("Set Color", "yellow");
	roiManager("Set Line Width", 1);
	Overlay.addSelection;
	//run("Flatten");
	roiManager("Show None");
	roiManager("Select", 1);
	roiManager("Set Color", "magenta");
	roiManager("Set Line Width", 1);
	Overlay.addSelection;
	//run("Flatten");
	roiManager("Show None");
	roiManager("Select", 2);
	roiManager("Set Color", "green");
	roiManager("Set Line Width", 1);
	Overlay.addSelection;
	roiManager("Show None");
	roiManager("Select",3 );
	roiManager("Set Color", "red");
	roiManager("Set Line Width", 1);
	Overlay.addSelection;
	run("Flatten");
	wait(500);
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	close("\\Others");	
	
}


function deleteROIsFun(Mask, orig) {
		//Mask = "tissueMask";
		//orig = "selectROI";
	
		selectWindow(Mask);  
		run("Create Selection");
		selectWindow(orig);
		run("Restore Selection");
		

		
	    // Loop to delete multiple ROIs if desired
	    deleteROIs = getBoolean("Do you want to Delete other Detected Regions");
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
		        setForegroundColor(255,255,255);
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
	
function backgroundSubstract2DGPU(name, sigma) {
	
	/**
	 * Subtracts background from an image using GPU acceleration.
	 * 
	 * @param {string} name - The name of the input image.
	 * @param {number} sigma - The standard deviation for Gaussian blur.
	 */
	 
	// Load CLIJ GPU accelerator and CLIJ2 Macro Extensions
	run("CLIJx Version 0.32.1.1");
	run("CLIJ2 Macro Extensions", "cl_device=[]");
	
	//name="nucleiMask";
	sigma=50;
	
	// Clear CLIJ2
	Ext.CLIJ2_clear();
	
	// Push input image to GPU memory
	image1 = name;
	Ext.CLIJ2_push(image1);
	
	// Define output image name
	image2 = name + "_subtracted";
	
	// Set sigma values for Gaussian blur
	sigma_x = sigma;
	sigma_y = sigma;
	
	// Subtract background using CLIJx
	Ext.CLIJx_subtractBackground2D(image1, image2, sigma_x, sigma_y);
	
	// Pull result image from GPU memory
	Ext.CLIJ2_pull(image2);
	
	// Clear CLIJ2
	Ext.CLIJ2_clear();
	
	// Close input image
	close(image1);
	
	// Rename output image
	selectWindow(image2);
	rename(name);
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




