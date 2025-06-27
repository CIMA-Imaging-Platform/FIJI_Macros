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
 *   Imagelabel+SegmentationResults.xls
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
	date= "March 2023";
	
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
	    +"<ul><font size=2  i><li>DT: Start Automatic Detection</li>"
	    +"<font size=2  i><li>+: Add Cardiomyocyte to RioManager</li>"
	    +"<font size=2  i><li>-: Remove Cardiomyocyte from RioManager</li>"
	    +"<font size=2  i><li>F: Press Finish to Quantify the Detected Cardiomyocytes</li></ul>"
	    +"<p><font size=3  i>Steps for the User</i></p><ol><li>Select File</li><li>Press DT </li><li>Introduce Parameters</li><li>Remove unwanted Regions</li><li>Edit with + AND - Bottons</li><li>Press F to Quantify</li><li>Press DT to open next Image</li></ol>"
	    +"<p><font size=3  i>PARAMETERS: Must be adjusted for each batch of images</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>Threshold for Tissue Segmentation: Intensity Threshold to separate Background from Tissue. Higher values will detect less tissue</li><li>Threshold for Cardiomyocyte Segmentation: Intensity Threshold diferenciate tissue and Cardiomyocytes. Higher values will detect less cardiomyocytes</li>"
	    +"<li>Separate joined Cardiomyocytes: Higher values will join Cells. Use 5,10,20</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=2  i>Result folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=2  i>Excel Quantification_Cardiomyocytes.xls</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>Image Label</li><li>#Cardiomyocytes<li>Tissue Area (um2)</li></ul>"
	    +"<p><font size=2  i>Excel Image_name+SegmentationResults.xls</i></p>"
	    +"<ul id=list-style-3><li>Cardiomyocyte ID</li><li>Area of Cardiomyocyte (um2)</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
	}


close("*");
var info=fileInfo(File.name);
var OutDir=info[0];
var MyTitle=info[1];
var MyTitle_short=info[2];

var ID=getImageID();


var r=0.50; //Elvectra 0.5um pixel --> 20x
var tissueThrhld=6;
var AglutininaThd=25;
var prominence=5;


// BUTTON FOR TISSUE DETECTION

macro "Aglutinina Action Tool 1 - C0f0T0d14DTcd14T"
{	
	
/*
 * This ImageJ macro, named "Aglutinina Action Tool 1", facilitates the automatic detection of tissue using Aglutinina staining. 
 * It prompts the user to set parameters for the analysis, including thresholds for tissue and membrane segmentation, as well as 
 * the option to separate joined cells. 
 * After parameter input, it segments the tissue using Aglutinina staining, which involves enhancing contrast, thresholding, creating a distance map, 
 * finding maxima, and analyzing particles. 
 * The macro then prompts the user to edit the detection with the provided buttons and finalize the process by pressing F. 
 * Output messages indicate the completion of the automatic detection process. 
 */

	if (!isOpen(ID)){
		fileInfo(File.name);
	}
	roiManager("Reset");
	run("Clear Results");
	
	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("PARAMETERS")	
	Dialog.addNumber("Threshold for Tissue segmentation", tissueThrhld);
	Dialog.addNumber("Threshold for Membrane segmentation", AglutininaThd);
	Dialog.addNumber("Separate joined Cells", prominence);
	Dialog.show();	
	
	tissueThrhld= Dialog.getNumber();
	AglutininaThd= Dialog.getNumber();
	prominence= Dialog.getNumber();
	

	run("Set Scale...", "distance=1 known="+r+" unit=um");

	/* Edit Region of Interest 
	 */
	 selectRoi(MyTitle);

	/* Segmentation Aglutinina 
	 *  enhance contrast - Thresholding - Distance map - FindMaxima - SegmentedParticles
	 *  param: 
	 *  	Threshold: 25
	 *  	FindMaxima :
	 *  		- Prominence 5 
	 *  	Analyze Particles: 
	 *  		- Size: 500-35000
	 */

	cellSegmentation("Aglutinina","dapi",tissueThrhld,AglutininaThd,prominence);
	
	showMessage("Automatic Detection Finished!");
	showMessage("Please Edit the Detection with the + and - buttons and press F when you are done");

}
	
macro "Aglutinina Action Tool 2 - C0f0T6e15+"
{

	 /**
	 * This ImageJ macro, named "Aglutinina Action Tool 2", provides functionality to add fibers to the detection.
	 * It prompts the user to draw a fiber to add and then fills the selected region with a mask. 
	 * After that, it analyzes the particles within the mask and displays the selection added message.
	 */

		
	// ADD
	setBatchMode(false);
	run("Select None");
	selectWindow("merge");
	setTool("freehand");
	waitForUser("Please draw a fiber to add and press ok when ready");
	//check if we have a selection
	type = selectionType();
	  if (type==-1)	{
		showMessage("Edition", "You should draw a fiber to add.Otherwise nothing will be added.");
		exit();
	  }
	  
	//run("Add to Manager");
	
	selectWindow("cellMask");
	run("Restore Selection");
	setForegroundColor(0, 0, 0);
	run("Fill", "slice");
	run("Select None");
	
	roiManager("Reset");
	selectWindow("cellMask");
	run("Analyze Particles...", "size=0-Inf show=Masks exclude add in_situ");
	selectWindow("merge");
	roiManager("Show All with labels");
	setTool("zoom");
	showMessage("Selection added");

}


macro "Aglutinina Action Tool 3 - C0f0T7e20-"
{
	 
	/**
	 * This ImageJ macro, named "Aglutinina Action Tool 3", provides functionality to delete fibers from the detection.
	 * It prompts the user to select a fiber to delete and then fills the selected region with a mask to delete it. 
	 * After that, it analyzes the particles within the mask and displays the selection deleted message.
	 */
	 
	// DELETE
	setBatchMode(false);
	run("Select None");
	selectWindow("merge");
	run("Select None");
	setTool("hand");
	waitForUser("Please select a fiber to delete and press ok when ready");
	
	//check if we have a selection
	type = selectionType();
	  if (type==-1)	{
		showMessage("Edition", "You should select a fiber to delete. Nothing will be deleted.");
		exit();
	}	
	
	selectWindow("cellMask");
	run("Restore Selection");
	setForegroundColor(255, 255, 255);
	run("Fill", "slice");
	run("Select None");
	
	roiManager("Reset");
	run("Analyze Particles...", "size=0-Inf show=Masks exclude add in_situ");
	selectWindow("merge");
	roiManager("Show All with labels");
	setTool("zoom");
	
	showMessage("Selection deleted");

}


macro "Aglutinina Action Tool 4 - Cf00T4d14F"{

	/**
	 * This ImageJ macro, named "Aglutinina Action Tool 4", completes the process of detecting cardiomyocytes by measuring various parameters 
	 * and saving the results.
	 * It prompts the user to confirm before processing the final results.
	 * It measures the area of the whole tissue and cardiomyocytes
	 * calculates statistics such as mean, minimum, maximum, and standard deviation of cardiomyocyte sizes, and saves the results in separate files.
	 * The results are saved in "Quantification_Cardiomyocytes.xls" and "MyTitle_short+SegmentationResults.xls" files.
	 */



	// FINISH AND SAVE RESULTS
	
	setBatchMode(false);
	
	// DETERMINE MICRONS/PIXEL RATIO:
	run("Set Measurements...", "area redirect=None decimal=2");	
	
	// Ask for confirmation to process final results
	q=getBoolean("Are you sure you want to finish and store results?");
	if(!q) 
	{
		showMessage("Nothing will be stored");
		exit();
	}

	//Measure WHOLE TISSUE
	roiManager("Show None");
	selectWindow("tissue");
	setBatchMode("show");
	run("Create Selection");
	run("Set Scale...", "distance=1 known="+r+" unit=µm");
	run("Set Measurements...", "area redirect=None decimal=1");	
	run("Measure");
	tissueArea=getResult("Area",0,"Results");
	run("Clear Results");

	//Measure Cardiomyocytes
	selectWindow("merge");
	run("Restore Selection");
	roiManager("Set Color", "yellow");
	run("Flatten");
	selectWindow("merge-1");
	nROIS=roiManager("Count");
	cellsID=Array.getSequence(nROIS);
	//print(cellsID[0]);
	roiManager("Select",cellsID);
	roiManager("Set Color", "green");
	roiManager("Show All with Labels");
	run("Flatten");
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"cardiomyocytes.tif");	
	
	selectWindow("merge");
	run("Set Scale...", "distance=1 known="+r+" unit=µm");
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
	
	

	selectWindow(MyTitle_short+"cardiomyocytes.tif");
	close("\\Others");
	
	run("Clear Results");

	//Save Area Results
	run("Input/Output...", "jpeg=85 gif=-1 file=.csv use_file copy_column save_column");
	if (File.exists(OutDir+ File.separator+MyTitle_short+"SegmentationResults.xls"))
	{	//if exists add and modify
		File.delete(OutDir+ File.separator+MyTitle_short+"SegmentationResults.xls");
		IJ.renameResults(MyTitle_short+"SegmentationResults");
		for (i = 0; i < lengthOf(cellsIndex); i++) {
			setResult("CardiomyocytesID", i,cellsIndex[i],MyTitle_short+"SegmentationResults");
			setResult("Area of tissue (um2)", i, cellsArea[i],MyTitle_short+"SegmentationResults"); 
		}
			
		saveAs(MyTitle_short+"SegmentationResults", OutDir+File.separator+MyTitle_short+"SegmentationResults.xls");
		
	}else {
		IJ.renameResults(MyTitle_short+"SegmentationResults");
		for (i = 0; i < lengthOf(cellsIndex); i++) {
			setResult("CardiomyocytesID", i,cellsIndex[i],MyTitle_short+"SegmentationResults");
			setResult("Area of tissue (um2)", i, cellsArea[i],MyTitle_short+"SegmentationResults"); 
		}
		saveAs(MyTitle_short+"SegmentationResults", OutDir+File.separator+MyTitle_short+"SegmentationResults.xls");
	}

	close(MyTitle_short+"SegmentationResults.xls");

	close("Results");

	run("Input/Output...", "jpeg=85 gif=-1 file=.csv use_file copy_column save_column");
	if(File.exists(OutDir+File.separator+"Quantification_Cardiomyocytes.xls"))
	{	
		//if exists add and modify
		open(OutDir+File.separator+"Quantification_Cardiomyocytes.xls");
		IJ.renameResults("Results");
	}else{
		IJ.renameResults("Results");
	}

	i=nResults;
	print(i);
	setResult("[Label]", i, MyTitle_short,"Results"); 
	setResult("# total Cardiomyocytes", i, lengthOf(cellsIndex),"Results");
	setResult("Area of tissue (um2)", i, tissueArea,"Results"); 
	setResult("Cardiomyocytes MeanSize (um2)", i, meanSize,"Results"); 
	setResult("Cardiomyocytes stdSize (um2)", i, stdSize,"Results"); 
	setResult("Cardiomyocytes MaxSize (um2)", i, maxSize,"Results"); 
	setResult("Cardiomyocytes MinSize (um2)", i, minSize,"Results"); 
	
	saveAs("Results", OutDir+File.separator+"Quantification_Cardiomyocytes.xls");
	close("Quantification_Cardiomyocytes.xls");

	Dialog.create("DONE!");
	
}



function fileInfo(name)
{	
	/* Retrieves information about the selected file.
	 * 
	 * @param {string} name - The name of the file.
	 * @return {array} fileDirs - An array containing the output directory, full title, and short title.
	 *                           - Output directory where results will be saved.
	 *                           - Full title of the selected file.
	 *                           - Short title extracted from the full title.
	 */
	
	infoMacro(); // Run predefined macro to gather information
	close("*"); // Close all open windows
	roiManager("Reset"); // Reset ROI manager
	run("Clear Results"); // Clear previous results
	
	// Open file dialog to select file
	open(File.openDialog("Select File"));
	MyTitle = getTitle(); // Get title of the selected file
	output = getInfo("image.directory"); // Get directory information
	OutDir = output + File.separator + "Results"; // Output directory for saving results
	File.makeDirectory(OutDir); // Create output directory if it doesn't exist
	aa = split(MyTitle,"."); 
	temp = aa[0]; 
	aaa = split(temp,"_"); 
	MyTitle_short = aaa[0];
	fileDirs = newArray(OutDir, MyTitle, MyTitle_short); 
	return fileDirs; // Return array containing directory and titles
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
	setBatchMode(true);
	run("Duplicate...", "title=orig");
	run("Split Channels");	
	
	// Close unnecessary channels
	close("orig (red)");
	selectWindow("orig (blue)");
	rename("dapi");
	setBatchMode("show");
	
	// Process Aglutinina - GFP channel
	selectWindow("orig (green)");
	rename("Aglutinina");
	run("8-bit");
	run("Green");
	run("Set Scale...", "distance=0 known=0 unit=pixel");	// Remove scale
	run("Enhance Contrast...", "saturated=0.4");
	setBatchMode("show");
	
	setBatchMode(false);

	// Option to delete a region from the image
	selectWindow("Aglutinina");
	q = getBoolean("Would you like to eliminate a region from the image?");
	while (q) {
		setTool("freehand");
		waitForUser("Select the region you want to delete and press OK");
		type = selectionType();
		if (type == -1) {
			showMessage("No region has been selected. Nothing will be deleted");
		} else {
			run("Add to Manager");
			selectWindow("Aglutinina");
			roiManager("Deselect");
			roiManager("Select", 0);
			setForegroundColor(0, 0, 0);
			run("Fill", "slice");
			run("Select None");
			selectWindow("dapi");
			roiManager("Deselect");
			roiManager("Select", 0);
			setForegroundColor(0, 0, 0);
			run("Fill", "slice");
			run("Select None");
			roiManager("Deselect");
			roiManager("Select", 0);
			roiManager("Delete");	
			run("Select None");				
		}
		selectWindow("Aglutinina");
		q = getBoolean("Would you like to eliminate another region from the image?");
	}
}
}


function cellSegmentation(membrane,nucleus,tissueThrhld,AglutininaThd,prominence)
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
	
	selectWindow(membrane); 
	run("Colors...", "foreground=white background=black selection=green"); 

	// Tissue Area Segmentation
	setBatchMode(true); 
	run("Duplicate...", "title=tissue"); 
	run("8-bit"); 
	run("Enhance Contrast...", "saturated=0.1"); 
	run("Threshold..."); 
	setThreshold(tissueThrhld, 255); 
	setOption("BlackBackground", true); 
	run("Convert to Mask"); 
	close("Threshold"); 
	run("Analyze Particles...", "size=20000-Infinity show=Masks in_situ"); 
	run("Median...", "radius=3"); 
	run("Create Selection"); 
	Roi.setStrokeColor("yellow"); 
	run("Add to Manager"); 
	roiManager("Show None"); 
	run("Select None"); 
	
	// Membrane Segmentation
	selectWindow(membrane); 
	run("Duplicate...", "title=cellMask"); 
	run("8-bit"); 
	run("Enhance Contrast...", "saturated=0.1"); 
	run("Apply LUT");
	run("Subtract Background...", "rolling=50");
	run("Kuwahara Filter", "sampling=1");
	run("Threshold..."); 
	setThreshold(AglutininaThd, 255); 
	setOption("BlackBackground", true); 
	run("Convert to Mask"); 
	close("Threshold"); 
	
	// Cardiomyocytes Count
	run("Analyze Particles...", "size=100-Infinity show=Masks in_situ"); 
	run("Invert"); 
	run("Analyze Particles...", "size=100-Infinity show=Masks in_situ"); 
	roiManager("Select", 0); 
	run("Enlarge...", "enlarge=-3"); 
	run("Clear Outside"); 
	roiManager("Select", 0); 
	roiManager("Delete");	
	run("Select None"); 
	run("Analyze Particles...", "size=100-Infinity show=Masks in_situ"); 
	run("Duplicate...", "title=EDM"); 
	run("Distance Map"); 
	run("Find Maxima...", "prominence=" + prominence + " output=[Single Points]"); 
	close("EDM"); 
	selectWindow(membrane); 
	run("Duplicate...", "title=cellEdges"); 
	run("8-bit"); 
	run("Enhance Contrast...", "saturated=0.4"); 
	imageCalculator("Multiply create 32-bit", "cellEdges","cellMask"); 
	run("Variance...", "radius=2"); 
	close("cellEdges"); 
	selectWindow("Result of cellEdges"); 
	rename("cellEdges"); 
	run("Marker-controlled Watershed", "input=cellEdges marker=[EDM Maxima] mask=cellMask binary calculate use"); 
	close("cellMask"); 
	selectWindow("cellEdges-watershed"); 
	run("8-bit"); 
	setThreshold(1, 255); 
	setOption("BlackBackground", false); 
	run("Convert to Mask"); 
	run("Analyze Particles...", "size=100-30000 show=Masks add in_situ"); 
	rename("cellMask");
	setBatchMode("show");
	close("cellE*"); 
	
	// Merge Channels
	selectWindow("tissue"); 
	setBatchMode("show"); 
	selectWindow(membrane); 
	run("Merge Channels...", "c2=" + membrane + " c3=" + nucleus + " keep"); 
	setBatchMode("show"); 
	rename("merge"); 
	roiManager("Show All with labels"); 
	selectWindow("tissue"); 
	run("Create Selection"); 
	selectWindow("merge"); 
	run("Restore Selection"); 
	Roi.setStrokeColor("yellow"); 
	setTool("zoom");	
	close(membrane); 
	close(nucleus); 
	close("E*"); 
	close("orig"); 
	setBatchMode(false); 


	
}
	




















