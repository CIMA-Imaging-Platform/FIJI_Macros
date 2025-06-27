
function macroInfo(){
	
// * Automatic Cell Classification based on Single and Double Phenotypes
// * Target User: Sheila
// *  

	scripttitle= "Automatic Cell Classification based on Single and Double Phenotypes";
	version= "1.01";
	date= "2024";
	
// *  Tests Images:

	imageAdquisition=" VECTRA POLARIS Images: 4 Channel: DAPI + 3 Markers: RNA, HDV , Virus";
	imageType="2D 8 bit ";  
	voxelSize="Voxel size: unknown um xy";
	format="Format: Uncompressed .qptiff";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button 
	
	parameter1="DAPI, Alb, HDV, F480 Channel Order"; 
	 
 //  2 Action tools:
	buttom1="RNA: Single File processing";
 //	buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs

	excel="QuantificationResults.xls";
	feature1="Tissue Area (um^2)";
	feature2="# Cells";
	feature3="# Alb+ cells";
	feature4="# HDV+ cells"; 
	feature5="# F480+ cells"; 
	feature6="# Alb-HDV+ cells"; 
	feature7="# HDV-F480+ cells"; 
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
	    +"<ol><font size=2  i><li>"+buttom1+"</li></ol>"
	    +"<p><font size=3  i>PARAMETERS: </i></p>"
	    +"<ul id=list-style-3><font size=2  i>"
	    +"<li>"+parameter1+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li><li>"+feature5+"</li><li>"+feature6+"</li><li>"+feature7+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}


var cDAPI=1, cHDV=3, cALB=2, cF480=4, nuclEnlargement=2;


macro "IF_CellClassDoublePhenotype Action Tool 1 - Ca3fT0b10CT8b10ETfb10LTfb10L"{
	
	/**
	 * Analyzes a confocal microscopy image stack to quantify cell phenotypes.
	 * 
	 * This macro performs the following steps:
	 * 1. Opens a single file selected by the user.
	 * 2. Sets up dialog for choosing channel numbers.
	 * 3. Performs tissue segmentation and calculates tissue area.
	 * 4. Segments nuclei from DAPI channel.
	 * 5. Segments other markers (tested with ALB, HDV, F480) to identify different cell types.
	 * 6. Counts cells positive for each marker.
	 * 7. Saves ROIs and results.
	 * 8. Draws markers on the image for visualization.
	 * 9. Saves the analyzed image.
	 * 
	 * @param {number} cDAPI - Channel number for DAPI staining.
	 * @param {number} cHDV - Channel number for HDV staining.
	 * @param {number} cALB - Channel number for ALB staining.
	 * @param {number} cF480 - Channel number for F480 staining.
	 * @param {number} nuclEnlargement - Enlargement factor for nuclei segmentation.
	 * @param {number} sigma - The standard deviation for Gaussian blur in background subtraction.
	 */
	
		
	macroInfo();
	
	/* TESTING PARAMS
	cDAPI=1;
	cHDV=3;
	cALB=2;
	cF480=4;
	nuclEnlargement=2;
	*/
		
	// Open just one file
	name=File.openDialog("Select File");	
	run("Bio-Formats", "open=["+name+"] autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT");
		
	Dialog.create("Channels");
	Dialog.addMessage("Choose channel numbers");	
	Dialog.addNumber("DAPI", cDAPI);	
	Dialog.addNumber("ALB", cALB);	
	Dialog.addNumber("HDV", cHDV);
	Dialog.addNumber("F480", cF480);
	Dialog.show();	
	cDAPI= Dialog.getNumber();
	cALB= Dialog.getNumber();
	cHDV= Dialog.getNumber();
	cF480= Dialog.getNumber();
		
		
	// Clear initialization of ROI manager and results table
	run("Collect Garbage");
	roiManager("Reset");
	run("Clear Results");
	RoiManager.associateROIsWithSlices(true);
	setOption("ExpandableArrays", true);
	setOption("WaitForCompletion", true);
	
	// Set color configuration and measurements
	run("Colors...", "foreground=white background=black selection=green");
	run("Set Measurements...", "area mean redirect=None decimal=2");
		
	// Set batch mode 
	setBatchMode(true);
	
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
	run("RGB Color");
	run("RGB to Luminance");
	rename("merge");
	// Convert image to binary mask
	setThreshold(6, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=6");
	
	// Analyze particles to identify tissue regions
	run("Analyze Particles...", "size=20000-Infinity show=Masks exclude in_situ");
	run("Invert");
	run("Analyze Particles...", "size=1000-Infinity show=Masks in_situ");
	run("Invert");
	run("Keep Largest Region");
	
	// Add segmented tissue region to ROI manager
	roiManager("Show None");
	run("Create Selection");
	Roi.setName("Tissue");
	Roi.setStrokeColor("green");
	run("Add to Manager");	// ROI1 --> WHOLE TISSUE
	roiManager("measure");
	tissueArea=getResult("Area", 0);
	run("Select None");
	close("merge");
	close("merge-largest");
	
	// Post-processing: Clear outside tissue region
	selectWindow(MyTitle);
	roiManager("select", 0);
	run("Colors...", "foreground=white background=black selection=green");
	run("Clear Outside","stack");
	run("Select None");
	
	//run("Collect Garbage");
	
	// SEGMENT NUCLEI FROM DAPI:

	// Duplicate the image and apply mean filtering
	selectWindow(MyTitle);
	//cDAPI=1;
	run("Duplicate...", "title=nucleiMask duplicate channels="+cDAPI);
	run("Mean...", "radius=4");
	
	// Background subtraction using GPU acceleration
	backgroundSubstract2DGPU("nucleiMask",100)
	
	// Apply thresholding and morphological operations to segment nuclei
	setAutoThreshold("Otsu dark");
	//setThreshold(8,255);
	run("Convert to Mask");
	run("Median...", "radius=2");
	//run("Fill Holes");
	run("Select All");
	run("Analyze Particles...", "size=50-3500 pixel show=Masks in_situ");
	RoiManager.selectByName("Tissue");
	setBackgroundColor(255,255,255);
	run("Clear Outside");
	setBackgroundColor(0,0,0);
	run("Select None");
	
	// Perform marker-controlled watershed segmentation
	run("Duplicate...", "title=EDM duplicate ");
	run("Distance Map");
	run("Enhance Contrast", "saturated=0.01");
	run("Apply LUT");
	run("Find Maxima...", "prominence=20 light output=[Single Points]");
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
	roiManager("Save", OutDir+File.separator+MyTitle_short+"_roisDAPI.zip");

	
	//run("Collect Garbage");
		
	// SEGMENT 1st MARKER: ALBUMIN membrane or nuclear marker ()
	
	// Duplicate the image and apply background subtraction
	selectWindow(MyTitle);
	//cALB=2;
	run("Duplicate...", "title=membraneMask duplicate channels="+cALB);
	
	backgroundSubstract2DGPU("membraneMask",200.0);
	
	// Apply thresholding and morphological operations to segment Albumin marker
	setThreshold(6, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=2");
	run("Analyze Particles...", "size=100-Infinity pixel show=Masks in_situ");
	run("Create Selection");
	Roi.setName("Albumina");
	Roi.setStrokeColor("green")
	run("Add to Manager");	// ROI2 --> Watershed NUCLEI
	run("Select None");
	
	// SEGMENT 2nd MARKER: membrane marker (HDV) Virus
	selectWindow(MyTitle);
	//cHDV=3;
	run("Select None");
	run("Duplicate...", "title=HDVmask duplicate channels="+cHDV);
	
	backgroundSubstract2DGPU("HDVmask",100.0)
	
	// Apply thresholding and morphological operations to segment HDV marker
	setThreshold(15, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=1");
	run("Analyze Particles...", "size=50-Infinity pixel show=Masks in_situ");
	run("Create Selection");
	Roi.setName("HDV");
	Roi.setStrokeColor("magenta");
	run("Add to Manager");	// ROI2 --> Watershed NUCLEI
	run("Select None");
	
	// SEGMENT 3rd MARKER: RNA ¿?
	selectWindow(MyTitle);
	//cF480=4;
	run("Select None");
	run("Duplicate...", "title=particleMask duplicate channels="+cF480);
	
	backgroundSubstract2DGPU("particleMask",30.0);
	
	// Apply thresholding and morphological operations to segment RNA marker
	setThreshold(15, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=1");
	run("Analyze Particles...", "size=3-2000 pixel show=Masks in_situ");
	run("Create Selection");
	Roi.setName("particles");
	Roi.setStrokeColor("yellow");
	run("Add to Manager");	// ROI2 --> Watershed NUCLEI
	run("Select None");
	
	close(MyTitle);

	//run("Collect Garbage");
	
	// CHECK WHICH NUCLEI CONTAIN THE HDV MARKER
	
	roiManager("Reset");
	run("Clear Results");
	
	// Analyze particles to identify nuclei in the mask
	selectWindow("nucleiMask");
	run("Analyze Particles...", "size=1-Inf show=Masks add in_situ");
	roiManager("Show None");
	n = roiManager("Count");
	nCells = n - 1;
	
	// Duplicate the nuclei mask and clear it to create the HDV-positive mask
	selectWindow("nucleiMask");
	run("Select All");
	run("Duplicate...", "title=HDVpositive");
	run("Select All");
	setBackgroundColor(255, 255, 255);
	run("Clear", "slice");
	setBackgroundColor(0,0,0);
	run("Select None");
	wait(100);
	
	// Measure the HDV marker in the HDV mask
	run("Clear Results");
	selectWindow("HDVmask");
	run("Select None");
	roiManager("Deselect");
	selectWindow("HDVmask");
	roiManager("show all without labels");
	roiManager("Measure");
	n = nResults;
	roiManager("Show None");
	
	// Filter out nuclei containing the HDV marker and save the selection
	positiveRois = filterTableColum("Results", "Mean", ">", 0);
	
	print("Total Cells: " + n);
	print("Positive Cells: " + lengthOf(positiveRois));
	roiManager("select", positiveRois);
	roiManager("save selected", OutDir + File.separator + MyTitle_short + "_roisHDV.zip");
	roiManager("Reset");
	roiManager("Open", OutDir + File.separator + MyTitle_short + "_roisHDV.zip");
	selectWindow("HDVpositive");
	run("Colors...", "foreground=black background=white selection=green");
	roiManager("Fill");
	
	nHDV = roiManager("Count");
	nHDV = nHDV - 1;
	run("Select None");
	
	roiManager("Show None");

	
	//run("Collect Garbage");
	
	// CHECK ONE BY ONE WHICH NUCLEI CONTAIN MACROPHAGE MARKER
	
	roiManager("Reset");
	run("Clear Results");
	
	selectWindow("nucleiMask");
	run("Analyze Particles...", "size=1-Inf show=Masks add in_situ");
	roiManager("Show None");
	
	selectWindow("nucleiMask");
	run("Select All");
	run("Duplicate...", "title=particlePositive");
	run("Select All");
	setBackgroundColor(255, 255, 255);
	run("Clear", "slice");
	setBackgroundColor(0,0,0);
	run("Select None");
	wait(100);
		
	run("Clear Results");
	selectWindow("particleMask");
	run("Dilate");
	run("Dilate");
	run("Select None");
	roiManager("Deselect");
	selectWindow("particleMask");
	roiManager("Measure");
		
	n=nResults;
	
	positiveRois=filterTableColum("Results","Mean",">",0);
	
	print("Total Cells: "+n);
	print("positive Cells "+lengthOf(positiveRois));
	positiveRois=Table.getColumn("Index");
	roiManager("select", positiveRois);
	roiManager("save selected", OutDir+File.separator+MyTitle_short+"_roisMacro.zip");
	roiManager("Reset");
	roiManager("Open", OutDir+File.separator+MyTitle_short+"_roisMacro.zip");
	selectWindow("particlePositive");
	run("Colors...", "foreground=black background=white selection=green");
	roiManager("Fill");
		
	nMacrophages=roiManager("Count");
	nMacrophages=nMacrophages-1;
	run("Select None");

	roiManager("Show None");
	//run("Collect Garbage");
	
	// CHECK ONE BY ONE WHICH NUCLEI CONTAIN MEMBRANE ALBUMIN MARKER
	
	roiManager("Reset");
	run("Clear Results");
	
	selectWindow("nucleiMask");
	run("Analyze Particles...", "size=1-Inf show=Masks add in_situ");
	roiManager("Show None");
	
	selectWindow("nucleiMask");
	run("Select All");
	run("Duplicate...", "title=ALBpositive");
	run("Select All");
	setBackgroundColor(255, 255, 255);
	run("Clear", "slice");
	setBackgroundColor(0,0,0);
	run("Select None");
	wait(100);
		
	run("Clear Results");
	selectWindow("membraneMask");
	run("Dilate");
	run("Select None");
	roiManager("Deselect");
	roiManager("Measure");
	n=nResults;

	positiveRois=filterTableColum("Results","Mean",">",0);
	
	print("Total Cells: "+n);
	print("positive Cells "+lengthOf(positiveRois));
	roiManager("select", positiveRois);
	roiManager("save selected", OutDir+File.separator+MyTitle_short+"_roisALB.zip");
	roiManager("Reset");
	roiManager("Open", OutDir+File.separator+MyTitle_short+"_roisALB.zip");
	selectWindow("ALBpositive");
	run("Colors...", "foreground=black background=white selection=green");
	roiManager("Fill");
		
	nAlb=roiManager("Count");
	nAlb=nAlb-1;
	run("Select None");
	
	roiManager("Show None");
	//run("Collect Garbage");
	
	// CHECK CELLS THAT HAVE BOTH THE VIRUS AND THE ALBUMINA MARKERS
	imageCalculator("AND create", "HDVpositive", "AlbuminaPositive");
	rename("HDV-ALB_positive");
	roiManager("Reset");
	run("Clear Results");
	run("Analyze Particles...", "size=1-Inf show=Masks add in_situ");
	roiManager("Show None");
	nHdvAlb = roiManager("Count");
	nHdvAlb = nHdvAlb - 1;
	run("Select None");
	roiManager("Show None");
	
	// CHECK CELLS THAT HAVE BOTH THE VIRUS AND THE PARTICLE MARKERS
	imageCalculator("AND create", "HDVpositive", "particlePositive");
	rename("HDV-Macrophage_positive");
	roiManager("Reset");
	run("Clear Results");
	run("Analyze Particles...", "size=1-Inf show=Masks add in_situ");
	roiManager("Show None");
	nHdvMacro = roiManager("Count");
	nHdvMacro = nHdvMacro - 1;
	run("Select None");
	roiManager("Show None");

	// RESULTS--
	
	// Write results:
	run("Clear Results");
	if (File.exists(output + File.separator + "QuantificationResults.xls")) {
	    // if exists add and modify
	    open(output + File.separator + "QuantificationResults.xls");
	    IJ.renameResults("Results");
	}
	i = nResults;
	setResult("Label", i, MyTitle);
	setResult("Tissue Area (um^2)", i, tissueArea);
	setResult("# Cells", i, nCells);
	setResult("# Alb+ cells", i, nAlb);
	setResult("# HDV+ cells", i, nHDV);
	setResult("# F480+ cells", i, nMacrophages);
	setResult("# Alb-HDV+ cells", i, nHdvAlb);
	setResult("# HDV-F480+ cells", i, nHdvMacro);
	saveAs("Results", output + File.separator + "QuantificationResults.xls");
	
	run("Collect Garbage");
	
	setBatchMode("exit and display");
	roiManager("Show None");
	roiManager("Show None");
	
	close("*ask");

	
	// DRAW--
	
	// Select the merged image window and clear any existing selections
	selectWindow("merge");
	run("Select None");
	
	// Select the HDV-positive window and clear any existing selections
	selectWindow("HDVpositive");
	run("Select None");
	
	// Find maxima in the HDV-positive image and mark them with magenta points
	run("Find Maxima...", "noise=10 output=[Point Selection] light");
	setTool("multipoint");
	run("Point Tool...", "type=Hybrid color=Magenta cross=Magenta marker=Small");
	
	// If there are HDV-positive cells, restore the selection in the merged image
	selectWindow("merge");
	if (nHDV != 0) {
	    run("Restore Selection");
	}
	
	// Enhance contrast and flatten the image
	run("In [+]", " ");
	run("In [+]", " ");
	run("In [+]", " ");
	run("In [+]", " ");
	run("In [+]", " ");
	run("In [+]", " ");
	run("In [+]", " ");
	run("In [+]", " ");
	run("In [+]", " ");
	run("In [+]", " ");
	run("In [+]", " ");
	run("Flatten");
	
	// Rename and close windows
	rename("hdv");
	wait(200);
	close("merge");
	close("HDVpositive");
	
	// Repeat the same process for ALB-positive and particle-positive windows
    // Marking ALB-positive cells with green points and particle-positive cells with yellow points
	
	selectWindow("ALBpositive");
	run("Select None");
	run("Find Maxima...", "noise=10 output=[Point Selection] light");
	setTool("multipoint");
	run("Point Tool...", "type=Hybrid selection=Green cross=Green marker=Small");
	selectWindow("hdv");
	if (nAlb!=0) {
		run("Restore Selection");
	}
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("Flatten");
	rename("hdv_alb");
	wait(1000);
	close("hdv");
	close("ALBpositive");
	
	// Repeat the same process as above with particle-positive cells

	
	selectWindow("particlePositive");
	run("Select None");
	run("Find Maxima...", "noise=10 output=[Point Selection] light");
	setTool("multipoint");
	run("Point Tool...", "type=Hybrid selection=Yellow cross=Yellow marker=Small");
	selectWindow("hdv_alb");
	if (nMacrophages!=0) {
		run("Restore Selection");
	}
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("Flatten");
	rename("hdv_alb_macro");
	wait(200);
	close("hdv_alb");
	close("particlePositive");

	// Repeat the process for HDV-ALB-positive and HDV-Macrophage-positive windows
	// Marking HDV-ALB-positive cells with red and HDV-Macrophage-positive cells with yellow points

	
	
	selectWindow("HDV-ALB_positive");
	run("Select None");
	run("Find Maxima...", "noise=10 output=[Point Selection] light");
	setTool("multipoint");
	run("Point Tool...", "type=Hybrid selection=Red cross=Green marker=Small");
	selectWindow("hdv_alb_macro");
	if (nHdvAlb!=0) {
		run("Restore Selection");
	}
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("Flatten");
	rename("hdv_alb_macro_HA");
	wait(200);
	close("hdv_alb_macro");
	close("HDV-ALB_positive");
	
	selectWindow("HDV-Macrophage_positive");
	run("Select None");
	run("Find Maxima...", "noise=10 output=[Point Selection] light");
	setTool("multipoint");
	run("Point Tool...", "selection=Red cross=Yellow marker=Small");
	selectWindow("hdv_alb_macro_HA");
	if (nHdvMacro!=0) {
		run("Restore Selection");
	}
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("Flatten");
	rename("hdv_alb_macro_HA_HM");
	close("hdv_alb_macro_HA");
	wait(200);
	close("HDV-Macrophage_positive");
	
	selectWindow("hdv_alb_macro_HA_HM");
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	wait(100);
	rename(MyTitle_short+"_analyzed.jpg");
	
	close("*");
	setBatchMode("exit and display");
	setTool("zoom");
	showMessage("Done!");
	

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
	run("CLIJ2 Macro Extensions", "cl_device=[NVIDIA GeForce RTX 4060 Laptop GPU]");
	
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


