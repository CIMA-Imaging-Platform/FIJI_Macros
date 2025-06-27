// changelog May 2022

// Automatic tissue detection
// Cell nuclei segmentation from blue (HE)
// Determination of cell by applying known diameter of T limphocytes (10um)
// Brown signal (CD3) segmentation for positive cell determination
// Measure for each cell the % of pixels positive for CD3 and set a minimum % to classify the cell as CD3+


function macroInfo(){
	
// * Quantification of Brown WSI Images Area  
// * Target User: General
// *  

	scripttitle= "Quantification of CD3(+) Cells on WSImages ";
	version= "1.03";
	date= "2024";
	

// *  Tests Images:

	imageAdquisition="Aperio: BrightField Whole Slide Imaging Images.";
	imageType="RGB";  
	voxelSize="Voxel size:  0.502 um xy";
	format="Format: Uncompressed .jpg";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button.
 
	 parameter1="Resolution (micra pixel ratio) = 0.502 micras/pixel xy"; 
	 parameter2="Estimated Cell diameter (microns)";
	 parameter3="Tissue Threshold (8bit) = Separate Tissue from Background";
	 parameter4="Threshold for nuclei segmentation in HE (8bit)";
	 parameter5="Threshold for CD3+ segmentation (8bit) = Separate CD3(+) from CD(-)";
	 parameter6="Min Nucleus size (pixels)";
	 parameter7="Max Nucleus size (pixels)";
	 parameter8="Min percentage of CD3+(area within the cell) for positive cells (%)";
	 
	  
 //  2 Action tools:
		
	 buttom1="Im: Single File processing. Use Single file processing for fine tunning parameters";
	 buttom2="Dir: Batch Mode. Please tune parameters before using Batchmode";

//  OUTPUT

// Analyzed Images with ROIs

	excel="Quantification_CD3count.xls";
	feature1="Image Label";
	feature2="# total cells";
	feature3="# CD3+ cells";
	feature4="Area of tissue (um2)"
	
/*  	  
 *  version: 1.02 
 *  Author: Mikel Ariz  
 *  Commented by: Tomas Muñoz 2023 
 *  Date : 2015
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
	    +"<li>"+parameter2+"</li>"
	    +"<li>"+parameter3+"</li>"
	    +"<li>"+parameter4+"</li>"
	    +"<li>"+parameter5+"</li>"
	    +"<li>"+parameter6+"</li>"
	    +"<li>"+parameter7+"</li>"
	    +"<li>"+parameter8+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}



var r=0.502, cellDiameter=7, thTissue=230 , thBlue=150, thBrown=100, minSize=10, maxSize=8000, minBrownPerc=10, bck=false;		// Escáner 20x

macro "CD3count Action Tool 1 - Cf00T2d15IT6d10m"{
	
	//just one file
	name=File.openDialog("Select image file");
	//print(name);
	print("Processing "+name);
	
	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Choose parameters")	
	Dialog.addNumber("Ratio micra/pixel", r);		
	Dialog.addNumber("Cell diameter (microns)", cellDiameter);		
	Dialog.addNumber("Threshold for tissue segmentation", thTissue);
	Dialog.addNumber("Threshold for nuclei segmentation in HE", thBlue); 
	Dialog.addNumber("Threshold for CD3+ segmentation", thBrown);
	Dialog.addNumber("Min nucleus size", minSize);	
	Dialog.addNumber("Max nucleus size", maxSize);	
	Dialog.addNumber("Min percentage of CD3+ for positive cells (%)", minBrownPerc);
	Dialog.addCheckbox("Correct Background Ilumination", bck);
	Dialog.show();	
	
	r= Dialog.getNumber();
	cellDiameter= Dialog.getNumber();
	thTissue= Dialog.getNumber();
	thBlue= Dialog.getNumber();
	thBrown= Dialog.getNumber(); 		
	minSize= Dialog.getNumber(); 		
	maxSize= Dialog.getNumber(); 
	minBrownPerc= Dialog.getNumber(); 
	bck=Dialog.getCheckbox();

	//setBatchMode(true);
	CD3("-","-",name,r,cellDiameter,thTissue,thBlue,thBrown,minSize,maxSize,minBrownPerc,bck);
	setBatchMode(false);
	showMessage("CD3 quantified!");

}

macro "CD3count Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	InDir=getDirectory("Choose images directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Choose parameters")	
	Dialog.addNumber("Ratio micra/pixel", r);		
	Dialog.addNumber("Cell diameter (microns)", cellDiameter);		
	Dialog.addNumber("Threshold for tissue segmentation", thTissue);
	Dialog.addNumber("Threshold for nuclei segmentation in HE", thBlue); 
	Dialog.addNumber("Threshold for CD3+ segmentation", thBrown);
	Dialog.addNumber("Min nucleus size", minSize);	
	Dialog.addNumber("Max nucleus size", maxSize);	
	Dialog.addNumber("Min percentage of CD3+ for positive cells (%)", minBrownPerc);	
	Dialog.addCheckbox("Correct Background Ilumination", bck);
	Dialog.show();	
	
	r= Dialog.getNumber();
	cellDiameter= Dialog.getNumber();
	thTissue= Dialog.getNumber();
	thBlue= Dialog.getNumber();
	thBrown= Dialog.getNumber(); 		
	minSize= Dialog.getNumber(); 		
	maxSize= Dialog.getNumber(); 
	minBrownPerc= Dialog.getNumber();
	bck=Dialog.getCheckbox();

	
	for (j=0; j<L; j++)
	{
		if (endsWith(list[j],"ed.tif") || endsWith(list[j],"ed.jpg")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print("Processing "+name);
			//setBatchMode(true);
			CD3(InDir,InDir,list[j],r,cellDiameter,thTissue,thBlue,thBrown,minSize,maxSize,minBrownPerc,bck);
			setBatchMode(false);
			}
	}
	
	showMessage("CD3 quantified!");

}


function CD3(output,InDir,name,r,cellDiameter,thTissue,thBlue,thBrown,minSize,maxSize,minBrownPerc,bck)
{

	run("Close All");
	roiManager("Reset");
	run("Clear Results");
	
	setBatchMode(true);
	run("Collect Garbage");
	//run("Memory & Threads...", "maximum=15000 parallel=16 run");
	
	if (InDir=="-") {open(name);}
	else {
		if (isOpen(InDir+name)) {}
		else { open(InDir+name); }
	}
		
	cellRadiusPx = round(cellDiameter/(2*r));
	
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	run("Colors...", "foreground=black background=white selection=green");
	run("Set Measurements...", "area mean area_fraction redirect=None decimal=2");
	
	
	// DETECT TISSUE
	run("Select All");
	showStatus("Detecting tissue...");
	run("RGB to Luminance");
	if(bck){
		run("Subtract Background...", "rolling=200 light");
	}
	rename("a");
	run("Threshold...");
	//setAutoThreshold("Huang");
	getThreshold(lower, upper);
		//th_tissue=200;
	setThreshold(0, thTissue);
	run("Convert to Mask");
	run("Median...", "radius=6");
	run("Analyze Particles...", "size=500-Infinity pixel show=Masks in_situ");
	run("Invert");
	run("Analyze Particles...", "size=1000-Infinity pixel show=Masks in_situ");
	run("Invert");
	run("Create Selection");
	run("Add to Manager");	// ROI0 --> whole tissue
	selectWindow("a");
	close();
	
	
	// MEASURE AREA OF ANALYSIS--
	selectWindow(MyTitle);
	run("Select All");
	roiManager("Select", 0);
	roiManager("Measure");
	At=getResult("Area",0);
	Atm=At*r*r;
	run("Clear Results");
	
	// DRAW TISSUE:
	roiManager("Set Color", "yellow");
	roiManager("Set Line Width", 2);
	run("Flatten");
	wait(100);
	rename("imageToSave");
	
	// SEPARATE STAINING CHANNELS--
	selectWindow(MyTitle);
	roiManager("Show None");
	run("Select All");
	showStatus("Deconvolving channels...");
	run("Colour Deconvolution", "vectors=[H&E DAB] hide");
	selectWindow(MyTitle+"-(Colour_2)");
	close();
	selectWindow(MyTitle+"-(Colour_1)");
	rename("blue");
	selectWindow(MyTitle+"-(Colour_3)");
	rename("brown");
	
	// DETECT BROWN STAINING
	selectWindow("brown");
	run("Mean...", "radius=1");
	run("Threshold...");
	setAutoThreshold("Default");
	//thBrown=175;
	setThreshold(0, thBrown);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Analyze Particles...", "size=1-Inf show=Masks in_situ");
	
	
	/*//Identify posible artefacts
	run("Duplicate...", "title=artefacts");
	run("Analyze Particles...", "size=1000-Infinity show=Masks in_situ");
	run("Create Selection");
	run("Enlarge...", "enlarge=10");
	Roi.setName("artefacts");
	Roi.setStrokeColor("black")
	run("Add to Manager");	// ROI1 2*/
	
	roiManager("Select", 0);
	setBackgroundColor(255, 255, 255);
	run("Clear Outside");
	run("Create Selection");
	markerArea=getValue("Area");
	markerArea=markerArea*r*r;
	//print(markerArea);
	
	Roi.setName("+InmunoCells");
	Roi.setStrokeColor("red")
	run("Add to Manager");	// ROI1 --> Whole brown
	
	// SEGMENT BLUE CELLS	
	selectWindow("blue");
	run("Duplicate...", "title=nucleusMask");
	run("Median...", "radius=2");
	run("Threshold...");
	setAutoThreshold("Default");
	setAutoThreshold("Otsu");
	thBlue = 150;
	setThreshold(0, thBlue);
	//waitForUser("Adjust threshold for cell segmentation and press OK when ready");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	//run("Fill Holes");
	run("Median...", "radius=2");
	run("Morphological Filters", "operation=Opening element=Disk radius=2");
	selectWindow("nucleusMask-Opening");
	run("Watershed");
	roiManager("Select", 0);
	run("Clear Outside");
	run("Select All");
	//minSize=10;
	run("Analyze Particles...", "size="+minSize+"-Inf pixel show=Masks in_situ");
	
	// transform selection to individual points
	selectWindow("blue");
	run("Mean...", "radius=2");
	selectWindow("nucleusMask-Opening");
	run("Create Selection");
	selectWindow("blue");
	run("Restore Selection");
	run("Find Maxima...", "prominence=10 light output=[Single Points]");
	rename("blueMaxima");
	close("nucleusMask*");
	
	// Generate cellMask by enlarging the mask of nuclei
	selectWindow("blueMaxima");
	run("Duplicate...", "title=cellMask");
	run("Create Selection");
	//cellRadiusPx = 10;
	run("Enlarge...", "enlarge="+cellRadiusPx);
	setForegroundColor(0, 0, 0);
	run("Fill", "slice");
	
	selectWindow("cellMask");
	run("Select All");
	run("Duplicate...", "title=cellEdges");
	run("Find Edges");
	
	// MARKER-CONTROLLED WATERSHED
	run("Marker-controlled Watershed", "input=cellEdges marker=blueMaxima mask=cellMask binary calculate use");
	
	selectWindow("cellEdges-watershed");
	run("8-bit");
	setThreshold(1, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Analyze Particles...", "size=0-Infinity show=Masks add in_situ");
	roiManager("Show None");
	
	selectWindow("cellEdges");
	close();
	selectWindow("cellMask");
	close();
	selectWindow("blueMaxima");
	close();
	selectWindow("cellEdges-watershed");
	rename("cellMask");
	selectWindow("blue");
	close();
	
	n=roiManager("Count");
	nCells=n-2;
	
	roiManager("Save", OutDir+File.separator+MyTitle_short+"_ROIs.zip");
	
	
	// CHECK ONE BY ONE WHICH CELLS CONTAIN CD3
	
	selectWindow("cellMask");
	run("Duplicate...", "title=positCellMask");
	run("Select All");
	setBackgroundColor(255, 255, 255);
	run("Clear", "slice");
	wait(100);
	
	run("Clear Results");
	selectWindow("brown");
	run("Select None");
	roiManager("Deselect");
	roiManager("Measure");
		
	positiveRois=filterTableColum("Results", "%Area",">", minBrownPerc);
	
	print("Total Cells: "+nCells);
	print("positive Cells "+lengthOf(positiveRois));
	roiManager("select", positiveRois);
	roiManager("save selected", OutDir+File.separator+MyTitle_short+"_roisCD3.zip");
	roiManager("Reset");
	roiManager("Open", OutDir+File.separator+MyTitle_short+"_roisCD3.zip");
	selectWindow("positCellMask");
	run("Colors...", "foreground=black background=white selection=green");
	roiManager("Fill");
	nCD3=roiManager("Count");
	nCD3=nCD3-1;
	run("Select None");
	nCD3=roiManager("Count");
	run("Select None");
	
	
	selectWindow("Threshold");
	run("Close");
	
	selectWindow("brown");
	close();
	selectWindow(MyTitle);
	close();
	
	roiManager("Show None");
	
	
	// Write results:
	run("Clear Results");
	if(File.exists(output+File.separator+"Quantification_CD3count.xls"))
	{	
		//if exists add and modify
		open(output+File.separator+"Quantification_CD3count.xls");
		IJ.renameResults("Results");
	}
	i=nResults;
	setResult("[Label]", i, MyTitle); 
	setResult("Area of tissue (um2)", i, Atm); 
	setResult("Area of CD3 (um2)", i, markerArea); 
	setResult("# cells detected", i, nCells);
	setResult("# CD3+ cells", i, nCD3);
	saveAs("Results", output+File.separator+"Quantification_CD3count.xls");
	
	
	// DRAW:
	
	selectWindow("imageToSave");
	
	/*
	// Draw all cells
	selectWindow("cellMask");
	run("Select None");
	//run("Find Maxima...", "noise=10 output=[Point Selection] light");
	//setTool("multipoint");
	//run("Point Tool...", "type=Hybrid  color=Red size=Tiny counter=0");
	run("Create Selection");
	selectWindow("imageToSave");
	run("Restore Selection");
	roiManager("Set Color", "red");
	roiManager("Set Line Width", 1);
	run("Flatten");
	wait(100);*/
	
	
	// Draw CD3-positive cells
	if(nCD3!=0) {
		roiManager("Show All without labels");
		
	}
	run("Flatten");
	wait(200);
	
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	rename(MyTitle_short+"_analyzed.jpg");
	
	
	close("*");
	setBatchMode(false);
	


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




