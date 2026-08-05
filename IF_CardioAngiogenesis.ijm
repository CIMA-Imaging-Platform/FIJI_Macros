

function macroInfo(){
	
// * Automatic Cell Classification based on Single and Double Phenotypes
// * Target User: Sheila
// *  b

	scripttitle= "Automatic Cardio Vessels Detection based on Double Phenotype (SMA+CD31+)";
	version= "1.01";
	date= "2026";
	
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
	
	parameter1="DAPI, SMA-CY5, CD31-CY3 Channel Order"; 
	 
 //  2 Action tools:
	buttom1="Im: Single File processing";
 	buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs

	excel="QuantificationResults_IF_CardioAngiogenesis.xls";
	feature1="# Vessels";
	feature2="Area Vessels CD31+ SMA+ (um^2)";
	feature3="Area Tissue of Interest (um^2)";; 
	feature4="% Ratio Area Vessels / Area Tissue Interest ";; 
		
/*
 *  version: 1.01 
 *  Author by: Tomas Muñoz 2026
 *  Date : 2026
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

var cDAPI=1, cCY3=2, cCY5=3, thCD31=30, thSMA=50, minVesselSize=100, minPer=10; 

macro "IF_CardioAngiogenesis Action Tool 1 - Cf00T2d15IT6d10m"{
		
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
	run("Make Composite", "display=Composite");
	
	Dialog.create("Channels");
	Dialog.addMessage("Choose channel numbers");	
	Dialog.addNumber("DAPI", cDAPI);	
	Dialog.addNumber("Vesses CD31", cCY3);	
	Dialog.addNumber("Vesses SMA", cCY5);
    Dialog.addSlider("Define CY3+ Threshold", 0, 255, thCD31);
	Dialog.addSlider("Define CY5+ Threshold", 0, 255, thSMA);
	Dialog.addNumber("Min Vessel size (px)", minVesselSize);
	Dialog.addNumber("Min %Area Dounble Positive  (px)", minPer);
  
	Dialog.show();	
	cDAPI= Dialog.getNumber();
	cCY3= Dialog.getNumber();
	cCY5= Dialog.getNumber();
	thCD31= Dialog.getNumber();
	thSMA= Dialog.getNumber();
	minVesselSize= Dialog.getNumber();
	minPer= Dialog.getNumber();
		
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
	
	Stack.setChannel(cDAPI);
	run("Blue");
	Stack.setChannel(cCY3);
	run("Yellow");
	Stack.setChannel(cCY5);
	run("Red");
	
	// TISSUE SEGMENTATION 
	// TOO MANY ARTEFACTS ON CY3 AND CY5 CHANNELS --> USE JUST DAPI BACKGROUND FOR TISSUE
	
	run("Duplicate...", "title=tissueMask duplicate channels="+cDAPI+"-"+cDAPI);
	run("Enhance Contrast", "saturated=0.35");             
	run("Apply LUT");
	run("8-bit");
	run("Gamma...", "value=0.50");
	run("Gaussian Blur...", "sigma=2");
	// Convert image to binary mask
	setAutoThreshold("Intermodes dark no-reset");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=5");
	run("Analyze Particles...", "size=25000-Infinity pixel show=Masks in_situ");
	

	// Add segmented tissue region to ROI manager
	selectWindow(MyTitle);
	run("Duplicate...", "title=imToSave duplicate");
	selectWindow("imToSave");
	run("8-bit");
	Stack.setChannel(cDAPI);
	run("Blue");
	setMinAndMax(0,125);
	Stack.setChannel(cCY3);
	run("Yellow");
	setMinAndMax(3,15);
	Stack.setChannel(cCY5);
	run("Red");
	setMinAndMax(0,125);
	run("Make Composite", "display=Composite");
	run("RGB Color");
	close("imToSave")
	rename("imToSave");
	deleteROIsFun("tissueMask", "imToSave");
	
	selectWindow("tissueMask");
	roiManager("Show None");
	run("Create Selection");
	Roi.setName("Tissue");
	Roi.setStrokeColor("Red");
	run("Add to Manager");	// ROI1 --> WHOLE TISSUE
	run("Select None");
	close("merge*");
	run("Clear Results");
	close("Results");
	
	selectWindow("imToSave");
	// Introduce area of Interest to quantify: -->
 	setTool("freehand");
	waitForUser("Select ROI for Analysis: infarction Area");
	type = selectionType();
	if (type==-1)	{
		run("Select All");
	 	roiName="WholeImage";
	 	Roi.setName(roiName);
		run("Add to Manager");
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
	Roi.setName(roiName);
	run("Add to Manager");
	roiManager("deselect");
	roiManager("select",1);
	roiManager("delete");
	roiManager("select",1);
	run("Create Mask");
	rename(roiName+"Mask");
	
	run("Create Selection");
	areaROItissue = getValue("Area");
	run("Select None");	
	
	selectWindow("imToSave");
	close("TissueMask");
	

	setBatchMode(false);
	
	// SEGMENT 2nd MARKER: vessels marker CD31
	
	print("Detecting CD31 positive Regions...");
	selectWindow(MyTitle);
	//cCY3=2;
	run("Select None");
	run("Duplicate...", "title=CD31+VesselsMask duplicate channels="+cCY3);
	selectWindow("CD31+VesselsMask");
	run("8-bit");
	setMinAndMax(3,25);
	run("Apply LUT");
	run("Gaussian Blur...", "sigma=2");
	run("Subtract Background...", "rolling=50");
	setThreshold(thCD31, 255);
	
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Morphological Filters", "operation=Closing element=Disk radius=5");
	run("Median...", "radius=2");
	//minVesselSize = 200;
	run("Analyze Particles...", "size="+minVesselSize+"-Infinity pixel show=Masks in_situ");
	close("CD31+VesselsMask");
	rename("CD31+VesselsMask");

	//DISCARD BORDERS AND OUTSIDE REGIONS
	selectWindow(roiName+"Mask");
	run("Invert");
	run("Analyze Particles...", "size=100000-Infinity pixel show=Masks in_situ");
	run("Invert");
	run("Morphological Filters", "operation=Erosion element=Disk radius=30");
	rename("clearOutside");

	selectWindow("clearOutside");
	run("Create Selection");
	selectWindow("CD31+VesselsMask");
	run("Restore Selection");
	setBackgroundColor(255,255,255);
	run("Clear Outside");
	setBackgroundColor(0,0,0);
	run("Select None");
	
	run("Create Selection");
	Roi.setName("CD31+");
	run("Add to Manager");
	run("Select None");
	roiManager("show none");
		
	// SEGMENT 3nd MARKER: SMA+ marker - madure vessels
	print("Detecting SMA positive Regions...");
	selectWindow(MyTitle);
	run("Duplicate...", "title=SMA+VesselsMask duplicate channels="+cCY5);
	selectWindow("SMA+VesselsMask");
	run("8-bit");
	run("Subtract Background...", "rolling=50");
	setThreshold(thSMA, 255);
		
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Morphological Filters", "operation=Closing element=Disk radius=5");
	run("Median...", "radius=1");
	run("Analyze Particles...", "size="+minVesselSize+"-Infinity pixel show=Masks in_situ");
	close("SMA+VesselsMask");
	rename("SMA+VesselsMask");
		
	selectWindow("clearOutside");
	run("Create Selection");
	selectWindow("SMA+VesselsMask");
	run("Restore Selection");
	setBackgroundColor(255,255,255);
	run("Clear Outside");
	setBackgroundColor(0,0,0);
	run("Select None");
	
	run("Create Selection");
	Roi.setName("SMA+");
	run("Add to Manager");
	run("Select None");
	roiManager("show none");
	
	//Detect Vessels from Marker.
	print("Detecting CD31+ SMA+ positive Vessels...");
	selectWindow("SMA+VesselsMask");
	run("Duplicate...", "title=SMAcontour ignore");
	run("Create Selection");
	run("Enlarge...", "enlarge=+5");
	run("Clear");
	imageCalculator("AND create", "SMAcontour","CD31+VesselsMask");
	rename("CD31+SMA+");
	run("Create Selection");
	Roi.setName("CD31+SMA+");
	run("Add to Manager"); 
	run("Select None");
	roiManager("show none");
	
	imageCalculator("OR create", "SMA+VesselsMask","CD31+VesselsMask");
	rename("vesselsMask");
	run("Create Selection");
	Roi.setName("vesselsMask");
	run("Add to Manager");
	run("Select None");
	roiManager("show none");
	
	roiManager("Reset");
	run("Clear Results");
	run("Set Measurements...", "area mean perimeter shape area_fraction redirect=None decimal=2");
	selectWindow("vesselsMask");
	run("Analyze Particles...", "size=100-Inf pixel show=Masks in_situ add composite");
	selectWindow("CD31+SMA+");
	run("Select None");
	roiManager("Measure");
	vesselsRois = filterTableColum("Results", "%Area", ">", minPer);
	print("Total Vessels: " + lengthOf(vesselsRois));
	roiManager("select", vesselsRois);
	roiManager("save selected", OutDir + File.separator + MyTitle_short + "_roisVessels.zip");
	roiManager("Reset");
	roiManager("Open", OutDir + File.separator + MyTitle_short + "_roisVessels.zip");
	setBatchMode("exit and display");
		
	close("*SMA*");
	close("clearOutside");
	
	selectWindow(roiName+"Mask");
	run("From ROI Manager");
	run("Create Mask");
	rename("positiveVesselsMask");
	roiManager("reset");
	run("Create Selection");
	run("Add to Manager");
		
	selectWindow(roiName+"Mask");
	run("Remove Overlay");
	
	run("Clear Results");
	close("Results");
	roiManager("measure");
	aVess = getResult("Area", 0);
			
	//ratio
	r1 = aVess/areaROItissue*100;
		
	//--Write results:
	run("Clear Results");
	if(File.exists(output+File.separator+"Quantification_angiogenesis.xls"))
	{	
		//if exists add and modify
		open(output+File.separator+"Quantification_angiogenesis.xls");
		IJ.renameResults("Results");
	}
	i=nResults;
	setResult("Label", i, MyTitle); 
	setResult("# Vessels", i, lengthOf(vesselsRois)); 
	setResult("Analyzed area of tissue (um2)", i, areaROItissue); 
	setResult("Area of vessels (um2)", i, aVess);
	setResult("Ratio Avess/Atot (%)", i, r1);
	//setResult("# Vessels", i, nVess);
	saveAs("Results", output+File.separator+"QuantificationResults_IF_CardioAngiogenesis.xls");
	
	selectWindow("imToSave");
	selectWindow(roiName+"Mask");
	run("Create Selection");
	selectWindow("imToSave");
	run("Restore Selection");
	Roi.setStrokeColor("Magenta");
	Overlay.addSelection;
	selectWindow("positiveVesselsMask");
	run("Create Selection");
	selectWindow("imToSave");
	run("Restore Selection");
	Roi.setStrokeColor("Yellow");
	Overlay.addSelection;
	run("Flatten");
	wait(500);
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	rename(MyTitle_short+"_analyzed.jpg");
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




