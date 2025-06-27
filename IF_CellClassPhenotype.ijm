/* 
 *  IF CELL CLASS
 * 
 * TOOL for AUTOMATIC CLASSIFICATION OF CELL PHENOTYPES 
 * Target User: GENERAL.
 *  
 *  Images: 
 *    - Confocal Microscopy : 2 channel images. (DAPI + PhenotpeMarker)
 *    - 8 bits
 *    - Format .czi   
 		  
 *  GUI Requierments:
 *    - Single and Batch Buttons
 *    - User must choose parameters
 *    
 *  Algorithms
 *    - Nuclei Segmentation : MARKER-CONTROLLED WATERSHED  
 * 		   	Use DAPI to segment nuclei. 
 *    		Preprocessing: flagConstrast ; radSmooth
 *    		Watershed: prominence
 *    	
 *    - Phenotyping:
 *    		Detect +/- Cells Presence phTypeamine inside Nuclei	
 *    		cytoBand: radius region if marker is cytoplasm or nuclear.
 *    		Masking AND operator: cell and phenotypes. 
 *    	
 *   OUTPUT Results:
		setResult("Label", i, MyTitle); 
		setResult("# total cells", i, nCells); 
		setResult("# phenotype+ cells", i, nphType);
		setResult("# % phenotype+ cells", i, nphType/nCells);
		setResult("Iavg of phenotype+ cells", i, Ipos);
		setResult("Iavg of phenotype- cells", i, Ineg);
		setResult("Istd of phenotype+ cells", i, Ipos_std);
		setResult("Istd of phenotype- cells", i, Ineg_std); 
 *   
 *     
 *  Author: Tomás Muñoz Santoro
 *  Date : 01/10/2023
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
	
	scripttitle= "TOOL for AUTOMATIC CLASSIFICATION OF CELL PHENOTYPES";
	version= "1.023";
	date= "22/06/2023";
	
	//image1="../templateImages/cartilage.jpg";
	//descriptionActionsTools="
	
	showMessage("ImageJ Script", "<html>"
		+"<style>h{margin-top: 5px; margin-bottom: 5px;} p{margin: 0px;padding: 0px;} ol{margin-left: 20px;padding: 5px;} #list-style-3 {list-style-type: circle;.container {max-width: 1800px; margin: 5px auto; padding: 0px; }</style>"
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
	    +"<ul id=list-style-3><font size=2  i><li>Confocal : 2 channel DAPI + Phenotype marker</li><li>8 bit Images </li><li>Format .czi or .tiff</li></i></ul>"
	    +"<p><font size=3 i>Action tools (Buttons)</i></p>"
	    +"<ol><font size=2  i><li>Im : Single File Quantification</li>"
	    +"<li> Dir : Batch Mode. Select Folder: All images within the folder will be quantified</li></ol>"
	    +"<p><font size=3  i>Parameters</i></p>"
	    +"<p2><font size=3  i>Nuclear Segmentation: Please adjust Parameters to your images<p2>"
	    +"<ul id=list-style-3><font size=2  i><li>DAPI threshold:Signal Threshold, Higher Number means Less Area Segmented</li>"
	    +"<li>Prominence Maxima Detection: Difference between Signal Local Maximas. Higher Number multiple close cells could be segmented as just one.</li>"
	    +"<li>Radius for smoothing: Use in case DAPI within the cell presents heterogeneus signal.</li></ul></p2>"
	    +"<p><font size=3  i>Cell Phenotype Classification: Determine the theshold between +/- Cells</i></p>"
	    +"<ul id=list-style-3><li>Phenotype Threshold(8bit): Signal Threshold to determine Positive and Negative Cells, Higher Number means Less Area Segmented</li>"
	    +"<li>Cell %: min % Area within the cell with Marker. Higher % means, Less cells will be positive</li></ul>"
	    +"<p><font size=3  i>Quantification Results (Excel) </i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>ImageName</li><li>#Cells</li><li>Marker+ Cells</li><li>% Marker+ Cells</li><li>Mean and Std Intensity of Marker+ and Marker- Cells</li></i></ul>"
	    +"<h0><font size=5> </h0>"
	    +"<h0><font size=5> </h0>");
	    
	  //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
	}
	


setOption("DebugMode", true);
setOption("ExpandableArrays", true);
setOption("WaitForCompletion", true);
Table.showRowIndexes(false);


var cDAPI=1, cphType=2;  
var thNucl=90, thPhen=60, minMarkerPerc=5; 
var flagContrast=false, radSmooth=2, prominence=15, cytoBand=0;
	

/*SINGLE FILE*/
macro "QIF Action Tool 1 - Cf00T2d15IT6d10m"{

	macroInfo();
	
	run("Close All");
	wait(500);
	run("Collect Garbage");
	
	run("ROI Manager...");
	
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	print("Processing "+name);
	
	Dialog.create("Parameters for the analysis");
	// Cell segmentation options:
	Dialog.addMessage("Cell segmentation")
	Dialog.addNumber("DAPI Channel", cDAPI);
	Dialog.addNumber("Marker Channel", cphType);
	Dialog.addNumber("DAPI threshold", thNucl);
	Dialog.addNumber("Prominence for maxima detection", prominence);
	Dialog.addNumber("Radius for smoothing", radSmooth);
	Dialog.addCheckbox("Adjust contrast", flagContrast);
	
	// Markers' segmentation options:
	Dialog.addMessage("Phenotype Marker");
	Dialog.addString("Phenotype Marker", "GPF");
	Dialog.addNumber("Phenotype threshold", thPhen);
	Dialog.addNumber("Min presence of positive marker per cell (%)", minMarkerPerc);
	
	Dialog.show();	
	
	//get paremeters
	cDAPI= Dialog.getNumber();
	cphType= Dialog.getNumber();
	thNucl= Dialog.getNumber();
	prominence= Dialog.getNumber();
	radSmooth= Dialog.getNumber();
	flagContrast= Dialog.getCheckbox();
	phName=Dialog.getString();
	thPhen= Dialog.getNumber();
	minMarkerPerc= Dialog.getNumber();
		
	qif("-","-",name,thNucl,prominence,radSmooth,flagContrast,phName,thPhen,minMarkerPerc,cDAPI,cphType);
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
	// Cell segmentation options:
	Dialog.addMessage("Cell segmentation")
	Dialog.addNumber("DAPI Channel", cDAPI);
	Dialog.addNumber("Marker Channel", cphType);
	Dialog.addNumber("DAPI threshold", thNucl);
	Dialog.addNumber("Prominence for maxima detection", prominence);
	Dialog.addNumber("Radius for smoothing", radSmooth);
	Dialog.addCheckbox("Adjust contrast", flagContrast);
	
	// Markers' segmentation options:
	Dialog.addMessage("Phenotype Marker");
	Dialog.addString("Phenotype Marker", "GPF");
	Dialog.addNumber("Phenotype threshold", thPhen);
	Dialog.addNumber("Min presence of positive marker per cell (%)", minMarkerPerc);
	
	Dialog.show();	
	
	//get paremeters
	cDAPI= Dialog.getNumber();
	cphType= Dialog.getNumber();
	thNucl= Dialog.getNumber();
	prominence= Dialog.getNumber();
	radSmooth= Dialog.getNumber();
	flagContrast= Dialog.getCheckbox();
	phName=Dialog.getString();
	thPhen= Dialog.getNumber();
	minMarkerPerc= Dialog.getNumber();
	
		
	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"tif")||endsWith(list[j],"czi")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print("Processing "+list[j]);
		
			//setBatchMode(true);
			qif(InDir,InDir,list[j],thNucl,prominence,radSmooth,flagContrast,phName,thPhen,minMarkerPerc,cDAPI,cphType);
			
			}
		close("*");
	}
	
	showMessage("QIF done!");

}

/* Function Level 1
	qif: quantify inmunoFluorescence
*/


function qif(output,InDir,name,thNucl,prominence,radSmooth,flagContrast,phName,thPhen,minMarkerPerc,cDAPI,cphType){


	if (InDir=="-") {
		openFileFormat(name);
		}
	else {
		file=InDir+name;
		openFileFormat(file);
		}


	/*
 	For testing
	cDAPI=1;
	radSmooth=4;
	prominence=200;
	thNucl=660;
	flagContrast=false;*/
	
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	//--Keep only marker channels and elliminate autofluorescence:
	run("Duplicate...", "title=orig duplicate channels=1-7");
	run("Make Composite", "display=Composite");

	getDimensions(width, height, channels, slices, frames);
	
	Stack.setChannel(cDAPI);
	if(flagContrast) {
		run("Enhance Contrast", "saturated=0.35");
	}
	if(flagContrast) {
		run("Enhance Contrast", "saturated=0.35");
	}
	Stack.setDisplayMode("composite");
	wait(100);
	
	run("RGB Color");
	rename("merge");
	
	run("Colors...", "foreground=white background=black selection=green");
	run("Set Measurements...", "area mean standard modal area_fraction redirect=None decimal=2");

	// SEGMENT NUCLEI FROM DAPI:
	
	selectWindow("orig");
    //cDAPI=1;
	run("Duplicate...", "title=nucleiMask duplicate channels="+cDAPI);
	run("8-bit");
	
	//flagContrast=false;
	if(flagContrast) {
		run("Enhance Contrast", "saturated=0.35");
	}
	
	run("Mean...", "radius="+radSmooth);
	
	run("Find Maxima...", "prominence="+prominence+" output=[Single Points]");
	rename("dapiMaxima");

	selectWindow("nucleiMask");
	setAutoThreshold("Default dark");
	getThreshold(lower, upper);
	//thNucl=95;
	setThreshold(thNucl,upper);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=2");
	//run("Fill Holes");
	run("Select All");
	run("Analyze Particles...", "size=50-Infinity pixel show=Masks in_situ");
	
	// Generate cellMask by enlarging the mask of nuclei
	run("Duplicate...", "title=cellMask");
	run("Create Selection");
	type=selectionType();
	if(type!=-1) {
		//cytoBand=5;
		run("Enlarge...", "enlarge="+cytoBand);
		setForegroundColor(0, 0, 0);
		run("Fill", "slice");
	}

	selectWindow("dapiMaxima");
	run("Select None");
	run("Restore Selection");
	setBackgroundColor(255, 255, 255);
	run("Clear Outside");
	run("Select None");
	
	selectWindow("cellMask");
	run("Select All");
	run("Duplicate...", "title=cellEdges");
	run("Find Edges");
	
	// MARKER-CONTROLLED WATERSHED
	run("Marker-controlled Watershed", "input=cellEdges marker=dapiMaxima mask=cellMask binary calculate use");
	selectWindow("cellEdges-watershed");
	run("8-bit");
	setThreshold(1, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	//roiManager("Reset");
	//run("Analyze Particles...", "size=0-Infinity show=Masks add in_situ");
	//roiManager("Show None");
	

	
	selectWindow("cellEdges");
	close();
	selectWindow("cellMask");
	close();
	selectWindow("dapiMaxima");
	close();
	selectWindow("cellEdges-watershed");
	rename("cellMask");
	
	run("Select None");
	run("Analyze Particles...", "size=0-Infinity pixel show=Masks display clear in_situ");
	nCells = nResults;
	selectWindow("Results");
	run("Clear Results");

	
	////////////////////
	//--PHENOTYPING...
	////////////////////
	
	//--phTypeamine
	nphType = findPhenotype(phName, cphType, thPhen, minMarkerPerc, "nuclear");
	print("Number of phType+ cells: "+nphType);
	
	//--Negative cell mask:
	imageCalculator("XOR", "cellMask",phName);

	//--Measure phType intensity of positive and negative cells:
	
	run("Set Measurements...", "area mean standard redirect=None decimal=2");
	selectWindow("orig");
	Stack.setChannel(cphType);

	
	// Positive cells:
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
	
	// Negative cells:
	selectWindow("cellMask");
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
	if(File.exists(output+File.separator+"Quantification_"+phName+"CellPhenotype.xls"))
	{	
		//if exists add and modify
		open(output+File.separator+"Quantification_"+phName+"CellPhenotype.xls");
		wait(500);
		IJ.renameResults("Results");
		wait(500);
	}
	i=nResults;
	wait(100);
	setResult("[Label]", i, MyTitle); 
	setResult("# total cells", i, nCells); 
	setResult("# "+phName+" cells", i, nphType);
	setResult("# % "+phName+"+ cells", i, (nphType/nCells)*100);
	setResult("Iavg of "+phName+"+ cells", i, Ipos);
	setResult("Iavg of "+phName+"- cells", i, Ineg);
	setResult("Istd of "+phName+"+ cells", i, Ipos_std);
	setResult("Istd of "+phName+"- cells", i, Ineg_std); 
	saveAs("Results", output+File.separator+"Quantification_"+phName+"CellPhenotype.xls");
		
	
	// SAVE DETECTIONS:
	
	roiManager("Reset");
	
	// All cells:
	selectWindow("cellMask");
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

	close("nucleiMask");
	close(phName);

	//Flatten ROIS
	selectWindow("merge");
	roiManager("Select", 0);
	roiManager("Set Color", "#00FFFF");
	roiManager("rename", "AllCells");
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
	selectWindow(MyTitle);
	run("Select None");
	run("Duplicate...", "title=phType duplicate channels="+cphType);

	roiManager("Select", 0);
	roiManager("Set Color", "#00FFFF");
	roiManager("rename", "AllCells");
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
	
	/*
	phName="phTypeamine";
	thMarker=350;
	ch=2;
	markerLoc="nuclear";
	*/

	
	if(markerLoc=="nuclear") {
		maskToUse="nucleiMask";
		
	}
	else {
		maskToUse="cellMask";
	}
	
	selectWindow("orig");
	run("Select None");
	run("Duplicate...", "title="+phName+"mask duplicate channels="+ch);
	run("Set Measurements...", "area mean standard modal area_fraction redirect=None decimal=2");

	
	//Remove background 
	selectWindow(maskToUse);
	run("Invert");
	run("Create Selection");
	run("Select None");
	run("Invert");
	selectWindow(phName+"mask");
	run("Restore Selection");
	run("Measure");
	bg=getResult("Mode", 0);
	run("Select None");
	run("Subtract...", "value="+bg);
	selectWindow(phName+"mask");
	run("Clear Results");


	
	//Detection 
	selectWindow(phName+"mask");
	run("8-bit");
	setAutoThreshold("Default dark");
	getThreshold(lower, upper);
	//thMarker=350;
	print(thMarker);
	setThreshold(thMarker, upper);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	//--AND between marker mask and tumoral cell mask so that marker in individual cells is left and 
	// size filtering may be applied to detect positive cells with a certain no. of positive pixels
	imageCalculator("AND", phName+"mask",maskToUse);
	//run("Analyze Particles...", "size=20-Infinity pixel show=Masks in_situ");


	//--Detect marker-positive cells in the tumor
	selectWindow("cellMask");
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
	selectWindow(phName+"mask");
	run("Select None");
	roiManager("Deselect");
	roiManager("Measure");
	selectWindow(phName);	// fill in marker mask with only marker-positive cells in the tumor


	for (i=0; i<n; i++)
	{
		Aperc=getResult("%Area",i);	
		if (Aperc>=minMarkerPerc) {	
	  		roiManager("Select", i);
			run("Fill", "slice");
	  	}	 	 	
	}

	
	run("Select None");
	roiManager("Reset");
	
	//--Count number of marker-positive cells in the tumor:
	selectWindow(phName);
	run("Select None");
	run("Analyze Particles...", "size=0-Infinity pixel show=Masks display clear in_situ");
	nMarkerCells = nResults;
	
	selectWindow(phName+"mask");
	close();
	selectWindow(phName);
		
	return nMarkerCells;
	
}


function openFileFormat(file){
		
	if(endsWith(file,".jpg")||endsWith(file,".tif")){
			open(file);
	}else if(endsWith(file,".czi") || endsWith(file,".svs")){
		run("Bio-Formats Importer", "open=["+file+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	}
}




