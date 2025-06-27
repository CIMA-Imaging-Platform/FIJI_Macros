/* 
 *  IF Macrophage CLASS
 * 
 * TOOL for AUTOMATIC CLASSIFICATION OF Macrophage PHENOTYPES 
 * Target User: GENERAL.
 *  
 *  Images: 
 *    - Confocal Microscopy : 2 channel images. (Macrophage + PhenotpeMarker)
 *    - 16 bits
 *    - Format .czi   
 		  
 *  GUI Requierments:
 *    - Single and Batch Buttons
 *    - User must choose parameters
 *    	
 *    - Phenotyping:
 *    		Detect +/- Macrophages Presence Marker inside macrophage	
 *    	    	
 *   OUTPUT Results:
		setResult("Label", i, MyTitle); 
		setResult("# total Macrophages", i, nMacrophages); 
		setResult("# phenotype+ Macrophages", i, nphType);
		setResult("# % phenotype+ Macrophages", i, nphType/nMacrophages);
		setResult("Iavg of phenotype+ Macrophages", i, Ipos);
		setResult("Iavg of phenotype- Macrophages", i, Ineg);
		setResult("Istd of phenotype+ Macrophages", i, Ipos_std);
		setResult("Istd of phenotype- Macrophages", i, Ineg_std); 
 *   
 *     
 *  Author: Tomás Muñoz Santoro
 *  Date : 01/04/2025
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


function macroInfo(){
	
// * "Quantifiaction of DAPI, GFP IF Intensity within Nucleus";
// * Target User: General
// *  

	scripttitle= "AUTOMATIC CLASSIFICATION OF MACROPHAGE PHENOTYPES ";
	version= "1.02";
	date= "2025";
	

// *  Tests Images:

	imageAdquisition="MULTIPLEX: Macrophage marker + Phenotype Marker of Interest .";
	imageType="16bit";  
	voxelSize="Voxel size:  unkown um xy";
	format="Format: Zeiss .ome.tif";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button 
  		
	parameter1 = "Macrophage and Phenotype Order ";
	parameter2 = "Macrophage and Phenotype Intensity Threshold";
	parameter3 = "(%) Min presence of positive marker per Macrophage ";
	parameter4 = "Contrast Adjustment for each Channel";
	parameter5 = "Macrophage Adjust Min";
	parameter6 = "Macrophage Adjust Max";
	parameter7 = "Marker Adjust Min";
	parameter8 = "Marker Adjust Max";
	
	 
//  2 Action tools:
	buttom1="Im: Single File processing";
	buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs

	excel = "IF_quantification.xls";
	feature1 = "[Label]"; 
	feature2 = "# Total Macrophages"; 
	feature3 = "# Marker+ Macrophages";
	feature5 = "Average Intensity of Marker+ Macrophages";
	feature6 = "Average Intensity of Marker- Macrophages";
	feature7 = "STD Intensity of Marker+ Macrophages";
	feature8 = "STD Intensity of Marker- Macrophages"; 
	
	
	/*  	  
 *  version: 1.02 
 *  Author: Mikel Ariz  
 *  Commented by: Tomas Muñoz 2023  
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
	    +"<p><font size=3  i>PARAMETERS:  </i></p>"
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
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature5+"</li><li>"+feature6+"</li><li>"+feature7+"</li><li>"+feature8+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}



setOption("DebugMode", true);
setOption("ExpandableArrays", true);
setOption("WaitForCompletion", true);
Table.showRowIndexes(false);

var cMacro=3, cphType=2, minSizeMacro=200, maxCircularity=0.75;
var thMacro=25, thPhen=80, minMarkerPerc=50 ,flagContrast = true;
var minMacroI = 15 , maxMacroI =250 , minPhenI = 150, maxPhenI = 500;


/*SINGLE FILE*/
macro "QIF Action Tool 1 - Cf00T2d15IT6d10m"{

	run("Close All");
	wait(500);
	run("Collect Garbage");
	
	run("ROI Manager...");
	
	//just one file
	name=File.openDialog("Select File");
	openFileFormat(name);
	
	Dialog.create("Parameters for the analysis");
	// Macrophage segmentation options:
	Dialog.addMessage("Macrophage segmentation")
	Dialog.addNumber("Macrophage Channel", cMacro);
	Dialog.addNumber("Macrophage threshold", thMacro);
	Dialog.addNumber("Macrophage minSize", minSizeMacro);
	
	// Markers' segmentation options:
	Dialog.addMessage("Phenotype Marker");
	Dialog.addString("Phenotype Marker", "mCherry");
	Dialog.addNumber("Marker Channel", cphType);
	Dialog.addNumber("Phenotype threshold", thPhen);
	Dialog.addNumber("Min presence of positive marker per Macrophage (%)", minMarkerPerc);
	
	Dialog.addCheckbox("Adjust Contrast", flagContrast);
	Dialog.addNumber("Macrophage Adjust Min", minMacroI);
	Dialog.addNumber("Macrophage Adjust Max", maxMacroI);
	Dialog.addNumber("Marker Adjust Min", minPhenI);
	Dialog.addNumber("Marker Adjust Max", maxPhenI);
	
	macroInfo();
	Dialog.show();
	
	//print(name);
	print("Processing "+name);
		
	//get paremeters
	cMacro = Dialog.getNumber();
	thMacro = Dialog.getNumber();
	minSizeMacro = Dialog.getNumber();
	
	phName = Dialog.getString();
	cphType = Dialog.getNumber();
	thPhen = Dialog.getNumber();
	minMarkerPerc = Dialog.getNumber();
	
	flagContrast = Dialog.getCheckbox();
	minMacroI = Dialog.getNumber();
	maxMacroI = Dialog.getNumber();
	minPhenI = Dialog.getNumber();
	maxPhenI = Dialog.getNumber();
			
	qif("-","-",name,cMacro,thMacro,minSizeMacro,phName,cphType,thPhen,minMarkerPerc,flagContrast,minMacroI,maxMacroI,minPhenI,maxPhenI);
	showMessage("QIF done!");

}

/*BATCH MODE*/
macro "QIF Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	macroInfo();
	
	run("Close All");
	
	run("ROI Manager...");

	wait(500);
	run("Collect Garbage");
	

	InDir=getDirectory("Choose images' directory");
	list=getFileList(InDir);
	L=lengthOf(list);
	
	Dialog.create("Parameters for the analysis");
	// Macrophage segmentation options:
	Dialog.addMessage("Macrophage segmentation")
	Dialog.addNumber("Macrophage Channel", cMacro);
	Dialog.addNumber("Macrophage threshold", thMacro);
	Dialog.addNumber("Macrophage minSize", minSizeMacro);
	
	// Markers' segmentation options:
	Dialog.addMessage("Phenotype Marker");
	Dialog.addString("Phenotype Marker", "mCherry");
	Dialog.addNumber("Marker Channel", cphType);
	Dialog.addNumber("Phenotype threshold", thPhen);
	Dialog.addNumber("Min presence of positive marker per Macrophage (%)", minMarkerPerc);
	
	Dialog.addCheckbox("Adjust Contrast", flagContrast);
	Dialog.addNumber("Macrophage Adjust Min", minMacroI);
	Dialog.addNumber("Macrophage Adjust Max", maxMacroI);
	Dialog.addNumber("Marker Adjust Min", minPhenI);
	Dialog.addNumber("Marker Adjust Max", maxPhenI);
	
	macroInfo();
	Dialog.show();
	
	//get paremeters
	cMacro = Dialog.getNumber();
	thMacro = Dialog.getNumber();
	minSizeMacro = Dialog.getNumber();
	
	phName = Dialog.getString();
	cphType = Dialog.getNumber();
	thPhen = Dialog.getNumber();
	minMarkerPerc = Dialog.getNumber();
	
	flagContrast = Dialog.getCheckbox();
	minMacroI = Dialog.getNumber();
	maxMacroI = Dialog.getNumber();
	minPhenI = Dialog.getNumber();
	maxPhenI = Dialog.getNumber();

		
	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"tif")||endsWith(list[j],"czi")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print("Processing "+list[j]);
		
			//setBatchMode(true);
			qif(InDir,InDir,list[j],cMacro,minSizeMacro,thMacro,phName,cphType,thPhen,minMarkerPerc,flagContrast,minMacroI,maxMacroI,minPhenI,maxPhenI);
			
			}
		close("*");
	}
	
	showMessage("QIF done!");

}



/* Function Level 1
	qif: quantify inmunoFluorescence
*/


function qif(output,InDir,name,cMacro,thMacro,minSizeMacro,phName,cphType,thPhen,minMarkerPerc,flagContrast,minMacroI,maxMacroI,minPhenI,maxPhenI){
	

	if (InDir != "-") {
		file=InDir+name;
		openFileFormat(file);
	}


	/*
 	For testing
	cMacro=1;
	radSmooth=4;
	prominence=200;
	thMacro=660;
	flagContrast=false;
	*/
	
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	//--Keep only marker channels and elliminate autofluorescence:
	//run("Duplicate...", "title=orig duplicate channels=1-7");
	rename("orig");
	run("Make Composite", "display=Composite");

	getDimensions(width, height, channels, slices, frames);
	run("Colors...", "foreground=white background=black selection=green");
	run("Set Measurements...", "area mean standard modal area_fraction redirect=None decimal=2");
	run("Options...", "iterations=1 count=1");
	setOption("ScaleConversions", true);
	
	setBatchMode(true);
	
	// SEGMENT MACROPHAGE FROM F480:
	
	selectWindow("orig");
    //cMacro=3;
	run("Duplicate...", "title=macrophageMask duplicate channels="+cMacro);
	if (flagContrast){	
		resetMinAndMax;
		setMinAndMax(minMacroI, maxMacroI);
		run("Apply LUT");
	}
		
	run("8-bit");
	run("Subtract Background...", "rolling=25");

	selectWindow("macrophageMask");
	
	setAutoThreshold("Huang dark");
	getThreshold(lower, upper);
	//thMacro=40;
	setThreshold(thMacro,upper);
		
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=2");
	run("Fill Holes");
			
	run("Morphological Filters", "operation=Closing element=Disk radius=2");
	close("macrophageMask");
	rename("macrophageMask");
	run("Select All");
	run("Analyze Particles...", "size="+minSizeMacro+"-Infinity pixel circularity=0.00-"+maxCircularity+" show=Masks in_situ");
	run("Fill Holes");
	
	run("Adjustable Watershed", "tolerance=4.5");
	close("Segmentation*");
	
	run("Analyze Particles...", "size=0-Infinity pixel show=Masks display clear in_situ");
		
	nMacrophages = nResults;
	selectWindow("Results");
	run("Clear Results");
	
		
	////////////////////
	//--PHENOTYPING...
	////////////////////
	
	selectWindow("orig");
	run("Select None");
	run("Duplicate...", "title="+phName+"Mask duplicate channels="+cphType);
	
	//run("Brightness/Contrast...");
	if (flagContrast){	
		resetMinAndMax;
		setMinAndMax(minPhenI, maxPhenI);
		run("Apply LUT");
	}		
	run("8-bit");
	run("Subtract Background...", "rolling=25");
		
	//--phTypeamine
	nphType = findPhenotype(phName, cphType, thPhen, minMarkerPerc, "Nuclear");
	print("Number of phType+ Macrophages: "+nphType);

	//--Negative Macrophage Mask:
	imageCalculator("XOR", "macrophageMask",phName);
	

	//--Measure phType intensity of positive and negative Macrophages:
	
	run("Set Measurements...", "area mean standard redirect=None decimal=2");
	selectWindow("orig");
	Stack.setChannel(cphType);
	
	// Positive Macrophages:
	selectWindow(phName);
	run("Create Selection");
	type=selectionType();
	if(type!=-1) {
		run("Clear Results");
		selectWindow("orig");
		run("Restore Selection");
		Stack.setChannel(cphType);
		run("Measure");
		Ipos = getResult("Mean", 0);
		Ipos_std = getResult("StdDev", 0);

	}
	else {
		Ipos = 0;
		Ipos_std = 0;
	}
	
	// Negative Macrophages:
	selectWindow("macrophageMask");
	run("Create Selection");
	type=selectionType();
	if(type!=-1) {
		run("Clear Results");
		selectWindow("orig");
		run("Restore Selection");
		Stack.setChannel(cphType);
		run("Measure");
		Ineg = getResult("Mean", 0);
		Ineg_std = getResult("StdDev", 0);

	}
	else {
		Ineg = 0;
		Ineg_std = 0;
	}
	
	
	//--Write results:
	run("Clear Results");
	if(File.exists(output+File.separator+"Quantification_"+phName+"MacrophagePhenotype.xls"))
	{	
		//if exists add and modify
		open(output+File.separator+"Quantification_"+phName+"MacrophagePhenotype.xls");
		wait(500);
		IJ.renameResults("Results");
		wait(500);
	}
	i=nResults;
	wait(100);
	setResult("[Label]", i, MyTitle); 
	setResult("# total Macrophages", i, nMacrophages); 
	setResult("# "+phName+" Macrophages", i, nphType);
	setResult("# % "+phName+"+ Macrophages", i, (nphType/nMacrophages)*100);
	setResult("Iavg of "+phName+"+ Macrophages", i, Ipos);
	setResult("Iavg of "+phName+"- Macrophages", i, Ineg);
	setResult("Istd of "+phName+"+ Macrophages", i, Ipos_std);
	setResult("Istd of "+phName+"- Macrophages", i, Ineg_std); 
	saveAs("Results", output+File.separator+"Quantification_"+phName+"MacrophagePhenotype.xls");
		
	// SAVE DETECTIONS:
	setBatchMode("exit and display");
	roiManager("Reset");
	
	// All Macrophages:
	selectWindow("macrophageMask");
	run("Create Selection");
	type = selectionType();
	if(type==-1) { makeRectangle(1,1,1,1); }
	roiManager("Add");
	close();
	
	// phType
	selectWindow(phName);
	run("Create Selection");
	type = selectionType();
	if(type==-1) { makeRectangle(1,1,1,1); }
	roiManager("Add");
	close();
	
	close("macrophageMask");
	close(phName);
	
	selectWindow("orig");
	Stack.setDisplayMode("color");
	run("Select None");
	Stack.setChannel(cMacro);
	Stack.setActiveChannels(cMacro);
	resetMinAndMax;
	
	setMinAndMax(minMacroI,maxMacroI);
	run("Apply LUT","slice");
	
	Stack.setChannel(cphType);
	Stack.setActiveChannels(cphType);
	resetMinAndMax;
	
	setMinAndMax(minPhenI,maxPhenI);
	run("Apply LUT","slice");
	
	Stack.setDisplayMode("Composite");
	run("RGB Color");
	rename("merge");

	//Flatten ROIS
	selectWindow("merge");
	roiManager("Select", 0);
	roiManager("Set Color", "#00FFFF");
	roiManager("rename", "AllMacrophages");
	roiManager("Set Line Width", 1);
	run("Flatten");
	wait(100);
	selectWindow("merge-1");
	roiManager("Select", 1);
	roiManager("Set Color", "#FF00FF");
	roiManager("rename", "phType+");
	roiManager("Set Line Width", 1);
	run("Flatten");
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	wait(100);
	rename(MyTitle_short+"_analyzed.jpg");

	
	//Flatten ROIS Phenotype channel
	selectWindow("orig");
	run("Select None");
	run("Duplicate...", "title=phType duplicate channels="+cphType);

	roiManager("Select", 0);
	roiManager("Set Color", "#00FFFF");
	roiManager("rename", "AllMacrophages");
	roiManager("Set Line Width", 1);
	run("Flatten");
	wait(200);
	selectWindow("phType-1");
	roiManager("Select", 1);
	roiManager("Set Color", "#FF00FF");
	roiManager("rename", "phType+");
	roiManager("Set Line Width", 1);
	run("Flatten");
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_"+phName+".jpg");
	wait(200);
	rename(MyTitle_short+"_"+phName+".jpg");
	
	roiManager("Save", OutDir+File.separator+MyTitle_short+"_"+phName+"RoiSet.zip");
	
	close("orig");
	close("m*");
	close("phType*");
	
	//Clear unused memory
	wait(500);
	run("Collect Garbage");

	
	//showMessage("Done!");

}

/* Function Level 2
	Find_Phenotype
	openFileFormat
*/


function findPhenotype(phName, ch, thMarker, minMarkerPerc, markerLoc) {
	

	/*phName="mCherry";
	thMarker=350;
	ch=2;
	markerLoc="Cyto";*/

	
	if(markerLoc=="Nuclear") {
		MaskToUse="macrophageMask";
		
	}else {
		MaskToUse=phName+"Mask";
	}
	
	//Remove background 
	selectWindow(MaskToUse);
	run("Invert");
	run("Create Selection");
	run("Select None");
	run("Invert");
	selectWindow(phName+"Mask");
	run("Restore Selection");
	run("Measure");
	bg=getResult("Mode", 0);
	run("Select None");
	run("Subtract...", "value="+bg);
	selectWindow(phName+"Mask");
	run("Clear Results");

	//Detection 
	run("Select None");
	selectWindow(phName+"Mask");
	run("8-bit");
	setAutoThreshold("Default dark");
	getThreshold(lower, upper);
	//thMarker=175;
	print(thMarker);
	setThreshold(thMarker, upper);

	setOption("BlackBackground", false);
	run("Convert to Mask");
	
	//--AND between marker Mask and tumoral Macrophage Mask so that marker in individual Macrophages is left and 
	// size filtering may be applied to detect positive Macrophages with a certain no. of positive pixels
	imageCalculator("AND", phName+"Mask",MaskToUse);
	//run("Analyze Particles...", "size=20-Infinity pixel show=Masks in_situ");
		
	//--Detect marker-positive Macrophages in the tumor
	selectWindow("macrophageMask");
	run("Select None");
	run("Duplicate...", "title="+phName);
	roiManager("Reset");
	run("Analyze Particles...", "size=0-Infinity show=Masks add in_situ");
	roiManager("Show None");
	n=roiManager("Count");
	selectWindow(phName);
	run("Select All");
	setBackgroundColor(255, 255, 255);
	run("Clear", "slice");
	wait(100);
	run("Clear Results");
	selectWindow(phName+"Mask");
	run("Select None");
	roiManager("Deselect");
	roiManager("Measure");
	selectWindow(phName);	// fill in marker Mask with only marker-positive Macrophages in the tumor

	positiveRois=filterTableColum("Results", "%Area",">", minMarkerPerc);
	
	print("Total Macrophages: "+n);
	print("positive Macrophages "+lengthOf(positiveRois));
	if (lengthOf(positiveRois)>0){;
		roiManager("select", positiveRois);
		roiManager("save selected", OutDir+File.separator+MyTitle_short+"_RoisMacrophages"+phName+".zip");
		roiManager("Reset");
		roiManager("Open", OutDir+File.separator+MyTitle_short+"_RoisMacrophages"+phName+".zip");
		selectWindow(phName);
		run("Colors...", "foreground=black background=white selection=green");
		roiManager("Fill");
		nMarkerMacrophages=roiManager("Count");
	
	}else{
		
		nMarkerMacrophages=0;
		
	}

	run("Select None");
	selectWindow(phName+"Mask");
	close();
	selectWindow(phName);

	
	return nMarkerMacrophages;
	
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
	 

	/*
	 //TEST PARAMETERS
	 tableName="Results";
	 columnName="%Area";
	 filterType=">";
	 threshold=50;
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

	if (i == lengthOf(column)){
		positiveRois=newArray();
	}else{
		// Get the updated indices of rows that meet the filtering criteria
		positiveRois = Table.getColumn("Index");
	}
	
	// Return the array of positive indices
	return positiveRois;
}



function openFileFormat(file){
			
	if(endsWith(file,".jpg")||endsWith(file,".tif")){
		if (!endsWith(file,"ome.tif")){
			open(file);
		}else{
			run("Bio-Formats", "open=["+file+"] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
		}
	}else if(endsWith(file,".czi") || endsWith(file,".svs") || endsWith(file,"ome.tif")){
		//run("Bio-Formats Importer", "open=["+file+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
		run("Bio-Formats", "open=["+file+"] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
	}
}
	



