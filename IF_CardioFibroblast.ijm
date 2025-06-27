

function macroInfo(){
	
// * Automatic Cell Classification based on Single and Double Phenotypes
// * Target User: Sheila
// *  b

	scripttitle= "Automatic Fibroblast Count based on Double Phenotype (SMA+Cav-)";
	version= "1.01";
	date= "2024";
	
// *  Tests Images:

	imageAdquisition=" VECTRA POLARIS Images: 3 Channel: DAPI + 2 Markers: SMA CAV";
	imageType="2D 8 bit ";  
	voxelSize="Voxel size: unknown um xy";
	format="Format: Uncompressed .qptiff";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
  
 //*	Cuantificacion Fibroblastos en IF , DAPI + SMA . Eliminar los vasos 
 //*	------------------------------------------------------------------
 //*	Seleccionar zona de Infarto / PeriInfarto. --> #fibroblastos
 //*	
 //*	FIBROBLASTOS --> SMA+ (red) & CAVEOLINA-(green)
 //*	VASOS --> SMA+ (red) & CAVEOLINA+ (green)
	
 //*    
 // Important Parameters: click Im or Dir + right button 
	
	parameter1="DAPI, SMA CAV Channel Order"; 
	 
 //  2 Action tools:
	buttom1="Im: Single File processing";
 	buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs

	excel="QuantificationResults_IF_FibroblastCount.xls";
	feature1="Aortic Ring Tissue Area (um^2)";
	feature2="Infarction or PeriInfaction ROI Area (um^2)";
	feature3="# Fibroblasts Cells";; 
	
/*
 *  version: 1.01 
 *  Author: Mikel Ariz  
 *  Commented by: Tomas Muñoz 2024 
 *  Date : 2024
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

var cDAPI=1, cCAV=2, cSMA=3, thCAV=35, thSMA=24;

macro "IF_CellClassDoublePhenotype Action Tool 1 - Ca3fT0b10CT8b10ETfb10LTfb10L"{
	
	function deleteROIsFun(Mask, orig) {
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
	
	
	
	// Clear initialization of ROI manager and results table
	close("*");
	run("Collect Garbage");
	roiManager("Reset");
	run("Clear Results");
	run("Fresh Start");
	RoiManager.associateROIsWithSlices(true);
	setOption("ExpandableArrays", true);
	setOption("WaitForCompletion", true);
	
	macroInfo();
		
	/* TESTING PARAMS
	cDAPI=1;
	cSMA=3;
	cCAV=2;
	nuclEnlargement=2;
	*/
		
	// Open just one file
	name=File.openDialog("Select File");	
	open(name);
	//run("Bio-Formats", "open=["+name+"] autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT");
	run("Make Composite");
	
	Dialog.create("Channels");
	Dialog.addMessage("Choose channel numbers");	
	Dialog.addNumber("DAPI", cDAPI);	
	Dialog.addNumber("CAV", cCAV);	
	Dialog.addNumber("SMA", cSMA);
	Dialog.addSlider("Define CAV+ Threshold", 0, 255, thCAV);
	Dialog.addSlider("Define SMA+ Threshold", 0, 255, thSMA);
	
	Dialog.show();	
	cDAPI= Dialog.getNumber();
	cCAV= Dialog.getNumber();
	cSMA= Dialog.getNumber();
	thCAV= Dialog.getNumber();
	thSMA= Dialog.getNumber();
		
	
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
	
	// TISSUE SEGMENTATION
	run("Duplicate...", "title=merge duplicate ");
	run("Make Composite");
	run("RGB Color");
	run("RGB to Luminance");
	rename("merge");
	//run("Brightness/Contrast...");
	run("Enhance Contrast", "saturated=0.35");
	run("Apply LUT");
	// Convert image to binary mask
	run("Threshold...");
	//setAutoThreshold("Huang dark no-reset");
	setThreshold(25, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Invert");
	run("Watershed");
	run("Analyze Particles...", "size=1000-Infinity pixel show=Masks in_situ");
	run("Invert");
	run("Median", "radius=5");
	
	// Analyze particles to identify tissue regions
	run("Analyze Particles...", "size=20000-Infinity pixel show=Masks in_situ");
	run("Invert");
	run("Analyze Particles...", "size=1000-Infinity show=Masks in_situ");
	run("Invert");
	run("Keep Largest Region");
	rename("tissueMask");
	
	//waitForUser;
	
	selectWindow(MyTitle);
	run("Make Composite");
	run("RGB Color");
	rename("selectROI");
	run("Enhance Contrast", "saturated=0.35");	
	
	// Add segmented tissue region to ROI manager
	selectWindow("tissueMask");
	deleteROIsFun("tissueMask", "selectROI");
	
	selectWindow("tissueMask");
	roiManager("Show None");
	run("Create Selection");
	Roi.setName("Tissue");
	Roi.setStrokeColor("green");
	run("Add to Manager");	// ROI1 --> WHOLE TISSUE
	roiManager("measure");
	tissueArea=getResult("Area", 0);
	run("Select None");
	close("merge*");
	
	selectWindow("selectROI");

	// Introduce area of Interest to quantify: -->
 	setTool("polygon");
	waitForUser("Select ROI for Analysis: Infact / Peri Infact Area");
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
	

	
	// Post-processing: Clear outside tissue region
	selectWindow(MyTitle);
	
	// Set batch mode 
	setBatchMode(true);
	
	run("Select None");
	run("Duplicate...", "title="+roiName+" duplicate ");
	RoiManager.selectByName("Tissue");
	run("Colors...", "foreground=white background=black selection=green");
	run("Clear Outside","stack");
	run("Select None");
	run("RGB Color");
	run("RGB to Luminance");
	run("Enhance Contrast", "saturated=0.35");
	RoiManager.selectByName(roiName);
	run("Colors...", "foreground=white background=black selection=green");
	run("Clear Outside","stack");
	run("Select None");
	run("Threshold...");
	setAutoThreshold("Huang dark no-reset");
	//setThreshold(25, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=4");
	RoiManager.selectByName(roiName);
	roiManager("delete");
	run("Select None");
	
	// Analyze particles to identify tissue regions
	//run("Analyze Particles...", "size=20000-Infinity pixel show=Masks exclude in_situ");
	run("Invert");
	run("Analyze Particles...", "size=1000-Infinity show=Masks in_situ");
	run("Invert");
	run("Keep Largest Region");
	rename(roiName+"Mask");
	run("Create Selection");
	Roi.setName(roiName);
	run("Add to Manager");
	run("Analyze Particles...", "size=1-Infinity pixel show=Nothing display");
	roiArea=getResult("Area", 1);
	//waitForUser;
	close("*RGB*");
	close("luminance*");
	
	
	//run("Collect Garbage");
	
	// SEGMENT NUCLEI FROM DAPI:

	// Duplicate the image and apply mean filtering
	selectWindow(roiName);
	//cDAPI=1;
	run("Duplicate...", "title=nucleiMask duplicate channels="+cDAPI);
	// Apply thresholding and morphological operations to segment nuclei
	run("Median...", "radius=2");
	run("Enhance Contrast", "saturated=0.1");
	run("Apply LUT");
	
	RoiManager.selectByName(roiName);
	run("Colors...", "foreground=white background=black selection=green");
	run("Clear Outside");
	run("Select None");	

	// Background subtraction using GPU acceleration
	//backgroundSubstract2DGPU("nucleiMask",40);
	run("Subtract Background...", "rolling=60");
	
	selectWindow("nucleiMask");	
	run("Auto Local Threshold", "method=Bernsen  radius=8 parameter_1=20 parameter_2=0 white");
	run("Convert to Mask");
	run("Fill Holes");
	run("Adjustable Watershed", "tolerance=0.5");
	run("Analyze Particles...", "size=20-350 pixel show=Masks in_situ");
		
	selectWindow("nucleiMask");
	run("Create Selection");
	Roi.setName("nuclei");
	Roi.setStrokeColor("green");
	run("Add to Manager");	// ROI2 --> Watershed NUCLEI
	run("Select None");
	
	
	
	/*
	// Perform marker-controlled watershed segmentation
	selectWindow(MyTitle);
	//cDAPI=1;
	run("Duplicate...", "title=nucleiSignal duplicate channels="+cDAPI);
 
	
	run("Duplicate...", "title=EDM duplicate ");
	run("Distance Map");  
	//run("Subtract Background...", "rolling=50");
	backgroundSubstract2DGPU("nucleiSignal",100)
	run("Enhance Contrast", "saturated=0.05");
	run("Apply LUT");
	run("Mean...", "radius=2");
	
    selectWindow("nucleiMask");
    run("Create Selection");
    selectWindow("nucleiSignal");
    run("Restore Selection");
    run("Find Maxima...", "prominence=20 output=[Single Points]");
	rename("nucleiMaxima");
	
	
	selectWindow("nucleiMask");
	run("Select All");;
	run("Duplicate...", "title=nucleiEdges");
	run("Find Edges");
	
	// Apply marker-controlled watershed
	run("Marker-controlled Watershed", "input=nucleiEdges marker=nucleiMaxima mask=nucleiMask binary calculate use");
	selectWindow("nucleiEdges-watershed");
	run("8-bit");
	setThreshold(1, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Create Selection");
	Roi.setName("nuclei");
	Roi.setStrokeColor("green");
	run("Add to Manager");	// ROI2 --> Watershed NUCLEI
	run("Select None");
	
	// Cleanup and save segmented nuclei
	close("nucleiEdges");
	close("nucleiMask");
	close("nucleiMaxima");
	close("EDM");
	selectWindow("nucleiEdges-watershed");
	rename("nucleiMask");
	*/
	
	roiManager("Save", OutDir+File.separator+MyTitle_short+"_roisDAPI.zip");
	
	//run("Collect Garbage");
		
	// SEGMENT 1st MARKER: CAV membrane  marker ()
	
	// Duplicate the image and apply background subtraction
	selectWindow(roiName);
	//cCAV=2;
	run("Duplicate...", "title=cavMask duplicate channels="+cCAV);
	
	run("Subtract Background...", "rolling=100");
	//backgroundSubstract2DGPU("cavMask",100.0);
	
	RoiManager.selectByName(roiName);
	run("Colors...", "foreground=white background=black selection=green");
	run("Clear Outside");
	run("Select None");
		
	//run("Enhance Contrast", "saturated=0.1");
	//run("Apply LUT");
	
	// Apply thresholding and morphological operations to segment marker
	setAutoThreshold("Otsu dark no-reset");
	//run("Threshold...");
	//thCAV=35;
	setThreshold(thCAV, 255);
	run("Convert to Mask");
	run("Median...", "radius=3");
	/*
	run("Auto Local Threshold", "method=MidGrey radius=10 parameter_1=0 parameter_2=0 white");
	run("Make Binary");
	run("Fill Holes");
	run("Analyze Particles...", "size=10-Inf pixel show=Masks in_situ");*/
		
	run("Create Selection");
	type=selectionType();
	if( type != -1){
		Roi.setName("Caveolina");
		Roi.setStrokeColor("green")
		run("Add to Manager");	
		run("Select None");
	}
	
	// SEGMENT 2nd MARKER: vessels marker (SMA+) 
	selectWindow(roiName);
	//cSMA=3;
	run("Select None");
	run("Duplicate...", "title=smaMask duplicate channels="+cSMA);
	
	run("Subtract Background...", "rolling=50");
	//backgroundSubstract2DGPU("smaMask",50.0);
	resetMinAndMax();
	
	RoiManager.selectByName(roiName);
	run("Colors...", "foreground=white background=black selection=green");
	run("Clear Outside");
	run("Select None");
		
	setAutoThreshold("Otsu dark no-reset");
	//run("Threshold...");
	//setThreshold(24, 255);
	run("Convert to Mask");
	run("Median...", "radius=1");
	
	RoiManager.selectByName(roiName);
	setBackgroundColor(255,255,255);
	run("Clear Outside");
	setBackgroundColor(0,0,0);
	run("Select None");
	
	run("Analyze Particles...", "size=10-Infinity pixel show=Masks in_situ");
		
	run("Create Selection");
	Roi.setName("SMA");
	Roi.setStrokeColor("red");
	run("Add to Manager");	// ROI2 --> Watershed NUCLEI
	run("Select None");
	
	//Detect Vessels from SMA Marker.
	roiManager("Reset");
	run("Clear Results");
	
	selectWindow("smaMask");
	run("Analyze Particles...", "size=1-Infinity add");
	roiManager("Measure");
	vesselsRois = filterTableColum("Results", "%Area", "<", 95);
	print("Total Vessels: " + lengthOf(vesselsRois));
	roiManager("select", vesselsRois);
	roiManager("save selected", OutDir + File.separator + MyTitle_short + "_roisVessels.zip");
	roiManager("Reset");
	roiManager("Open", OutDir + File.separator + MyTitle_short + "_roisVessels.zip");
	//waitForUser;
	selectWindow("smaMask");
	run("Colors...", "foreground=white background=black selection=green");
	roiManager("Fill");
		
	
	// CHECK WHICH NUCLEI CONTAIN THE CAV MARKER
	
	roiManager("Reset");
	run("Clear Results");
	
	// Analyze particles to identify nuclei in the mask
	selectWindow("nucleiMask");
	run("Analyze Particles...", "size=1-Inf show=Masks add in_situ");
	roiManager("Show None");
	n = roiManager("Count");
	nCells = n - 1;
	
	// Duplicate the nuclei mask and clear it to create the SMA-positive mask
	selectWindow("nucleiMask");
	run("Select All");
	run("Duplicate...", "title=CAVnegative");
	run("Select All");
	setBackgroundColor(255, 255, 255);
	run("Clear", "slice");
	setBackgroundColor(0,0,0);
	run("Select None");
	wait(100);
	
	// Measure the CAV marker in the CAV mask
	run("Clear Results");
	selectWindow("cavMask");
	run("Select None");
	roiManager("Deselect");
	selectWindow("cavMask");
	roiManager("show all without labels");
	roiManager("Measure");
	n = nResults;
	roiManager("Show None");
	
	// Filter out nuclei containing the CAV marker and save the selection
	negativeRois = filterTableColum("Results", "%Area", "<", 10);
	
	print("Total Cells: " + n);
	print("Positive Cells: " + lengthOf(negativeRois));
	roiManager("select", negativeRois);
	roiManager("save selected", OutDir + File.separator + MyTitle_short + "_roisCAV-.zip");
	roiManager("Reset");
	roiManager("Open", OutDir + File.separator + MyTitle_short + "_roisCAV-.zip");
	selectWindow("CAVnegative");
	run("Colors...", "foreground=black background=white selection=green");
	roiManager("Fill");
	
	nCAV = roiManager("Count");
	nCAV = nCAV - 1;
	run("Select None");
	
	roiManager("Show None");

	run("Collect Garbage");
	
	// CHECK ONE BY ONE WHICH NUCLEI CONTAIN SMA MARKER
	
	roiManager("Reset");
	run("Clear Results");
	
	selectWindow("nucleiMask");
	run("Analyze Particles...", "size=1-Inf show=Masks add in_situ");
	roiManager("Show None");
	
	selectWindow("nucleiMask");
	run("Select All");
	run("Duplicate...", "title=SMApositive");
	run("Select All");
	setBackgroundColor(255, 255, 255);
	run("Clear", "slice");
	setBackgroundColor(0,0,0);
	run("Select None");
	wait(100);
		
	run("Clear Results");
	selectWindow("smaMask");
	run("Select None");
	roiManager("Deselect");
	selectWindow("smaMask");
	roiManager("Measure");
		
	n=nResults;
	
	positiveRois=filterTableColum("Results","%Area",">",5);
	
	print("Total Cells: "+n);
	print("positive Cells "+lengthOf(positiveRois));
	positiveRois=Table.getColumn("Index");
	roiManager("select", positiveRois);
	roiManager("save selected", OutDir+File.separator+MyTitle_short+"_roisSMA+.zip");
	roiManager("Reset");
	roiManager("Open", OutDir+File.separator+MyTitle_short+"_roisSMA+.zip");
	selectWindow("SMApositive");
	run("Colors...", "foreground=black background=white selection=green");
	roiManager("Fill");
		
	nSMA=roiManager("Count");
	nSMA=nSMA-1;
	run("Select None");

	roiManager("Show None");
	//run("Collect Garbage");
	
		
	// CHECK CELLS THAT HAVE BOTH THE SMA and Caveolina MARKERS.
	// Fibroblast --> SMA+ (red) & CAVEOLINA- (green)
	
	imageCalculator("AND create", "SMApositive", "CAVnegative");
	rename("CAV-SMA+_fibroblast");
	roiManager("Reset");
	run("Clear Results");
	run("Analyze Particles...", "size=1-Inf show=Masks add in_situ");
	roiManager("Show None");
	nCAV_SMA = roiManager("Count");
	nCAV_SMA = nCAV_SMA - 1;
	run("Select None");
	roiManager("Show None");
	
	// RESULTS--
	
	// Write results:
	run("Clear Results");
	if (File.exists(output + File.separator + "QuantificationResults_IF_CardioFibroblast.xls")) {
	    // if exists add and modify
	    open(output + File.separator + "QuantificationResults_IF_CardioFibroblast.xls");
	    IJ.renameResults("Results");
	}
	i = nResults;
	setResult("Label", i, MyTitle);
	setResult("Tissue Area (um^2)", i, tissueArea);
	setResult(roiName+"Area (um^2)", i, roiArea);
	setResult("# Fibroblast SMA+Cav-", i, nCAV_SMA);
	setResult("# Vessels SMA+", i, lengthOf(vesselsRois));
	saveAs("Results", output + File.separator + "QuantificationResults_IF_CardioFibroblast.xls");
	
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
	selectWindow("CAV-SMA+_fibroblast");
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
	roiManager("Set Color", "red");
	roiManager("Set Line Width", 1);
	Overlay.addSelection;
	run("Flatten");
	wait(500);
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed2DProjection.jpg");
	rename(MyTitle_short+"_analyzed.jpg");
	wait(500);
	//close();
	close("*tive*");
	close("*Save");
	
	run("Collect Garbage");
	
	setBatchMode("exit and display");
	roiManager("Show None");
	roiManager("Show None");
	
	close("*ask");
	
	
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
	
	name="nucleiMask";
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

