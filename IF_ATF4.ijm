/*
 * AUTOMATIC CLASIFICATION OF ATF4 +/- CELLS
 * Target User: Maria Gonzalez
 *  
 *  Input Images: 
 *    - Confocal IF - 2 Channel : Dapi + ATF4. 
	  - 16 bit Images
	  - Format .czi   
 *  
 *  GUI Requierments:
	  - None
 *  
 *  Important Parameters
	- Channel order: cDAPI=1, cATF4=2;  
	- Pre-Processing: flagContrast=false, radSmooth=15;  
	- Segmentation: 
		Thresholding: thATF4=600, thNucl=660, 
		prominence=50, cytoBand=0; 
	- Classification: minMarkerPerc=15,

 *  OUTPUT:
 *  QuantificationResults.xls
		setResult("Label", i, MyTitle); 
		setResult("# total cells", i, nCells); 
		setResult("# ATF4+ cells", i, nATF4); 
		setResult("Iavg of ATF4+ cells", i, Ipos);
		setResult("Iavg of ATF4- cells", i, Ineg);
		setResult("Istd of ATF4+ cells", i, Ipos_std);
		setResult("Istd of ATF4- cells", i, Ineg_std); 

 *     
 *  Author: Mikel Ariz 
 *  Date : March 2023
 *  Commented by : Tomás Muñoz 
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
	scripttitle= "AUTOMATIC CLASIFICATION OF ATF4 +/- CELLS";
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
	    +"<ul><font size=2  i><li>Confocal IF - 2 Channel : Dapi + ATF4. </li><li>Resolution: unknown</li<li>Format .czi </li></i></ul>"
	    +"<p><font size=3 i>Action tools (Buttons)</i></p>"
	   	+"<ol><font size=2  i><li>Im : Single File Analysis: </li>"
	    +"<li> DIR: Batch Mode. Select Folder: All images within the folder will be quantified .</li></ol>"
	    +"<p><font size=3  i>Steps for the User</i></p><ol><li>Select File</li><li>Press Im or DIR </li><li>Introduce Parameters: Please tune the parameters for each image batch</li></ol>"
	    +"<p><font size=3  i>PARAMETERS:</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>DAPI Threshold:  (16 bit): Intensity Threshold to separate ATF4 + from ATF4 - Signal. Higher values will detect less Nuclei</li>"
	    +"<li>Prominence for Local Maxima Detection: Separate joined Nucleus.</li>"
	    +"<li>Radius for Smoothing: Use in case Dapi Signal not homogeneus inside each Nuclei.</li>"
	    +"<li>Cytoplasm width (microns): Creates a simulated Cytoplasm by growing Nuclei.</li>"
	    +"<li>ATF4 Theshold:  (16 bit): Intensity Threshold to separate ATF4 + from ATF4 - Signal. Higher values will detect less ATF4+. </li>"
	    +"<li>Cell %: Minimum presence of ATF4 + area within the cell</li></ul>"
	    +"<p><font size=3  i>Quantification Results:  </i></p>"
	    +"<p><font size=3  i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel QuantificationResults.xls</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>Image Label</li><li>Total # Cells</li><li>Total # of ATF4+ Cells</li>"
	    +"<li>ATF4 Mean and Std Intensity ATF4+ Cells</li><li>ATF4 Mean and Std Intensity ATF4- Cells</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
	}



var prominence=50, cytoBand=0;
var cDAPI=1, cATF4=2;  
var minMarkerPerc=15, thATF4=600, thNucl=660, flagContrast=false, radSmooth=15;

macro "QIF Action Tool 1 - Cf00T2d15IT6d10m"{

	infoMacro();

	run("Close All");
	
	run("ROI Manager...");
	
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	print("Processing "+name);
	
	Dialog.create("Parameters for the analysis");
	// Cell segmentation options:
	//modeArray=newArray("Default","Otsu","IsoData","Moments","Triangle","MaxEntropy","Minimum");
	Dialog.addMessage("Cell segmentation")
	//Dialog.addRadioButtonGroup("Thresholding method for DAPI", modeArray, 1, 7, "Default");
	Dialog.addNumber("DAPI threshold", thNucl);
	Dialog.addNumber("Prominence for local maxima detection", prominence);
	Dialog.addNumber("Radius for smoothing", radSmooth);
	Dialog.addNumber("Cytoplasm width (microns)", cytoBand);
	Dialog.addCheckbox("Adjust contrast", flagContrast);

	// Markers' segmentation options:
	Dialog.addMessage("ATF4 segmentation")
	Dialog.addNumber("ATF4 threshold", thATF4)
	Dialog.addNumber("Min presence of positive marker per cell (%)", minMarkerPerc);
	
	Dialog.show();	
	//thMethodNucl=Dialog.getRadioButton();
	thNucl= Dialog.getNumber();
	prominence= Dialog.getNumber();
	radSmooth= Dialog.getNumber();
	cytoBand= Dialog.getNumber();
	flagContrast= Dialog.getCheckbox();

//thMethodTum=Dialog.getRadioButton();	
	thATF4= Dialog.getNumber();
	minMarkerPerc= Dialog.getNumber();

	//setBatchMode(true);
	qif("-","-",name,flagContrast,thNucl,prominence,radSmooth,cytoBand,thATF4,minMarkerPerc);
	setBatchMode(false);
	showMessage("QIF done!");

}

macro "QIF Action Tool 2 - C00fT0b11DT9b09iTcb09r"{

	run("Close All");
	
	run("ROI Manager...");
	
	InDir=getDirectory("Choose images' directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("Parameters for the analysis");
	Dialog.addCheckbox("Adjust contrast", flagContrast);
	// Cell segmentation options:
	//modeArray=newArray("Default","Otsu","IsoData","Moments","Triangle","MaxEntropy","Minimum");
	Dialog.addMessage("Cell segmentation")
	//Dialog.addRadioButtonGroup("Thresholding method for DAPI", modeArray, 1, 7, "Default");
	Dialog.addNumber("DAPI threshold", thNucl);
	Dialog.addNumber("Prominence for maxima detection", prominence);
	Dialog.addNumber("Radius for smoothing", radSmooth);
	Dialog.addNumber("Cytoplasm width (microns)", cytoBand);
	// Markers' segmentation options:
	Dialog.addMessage("ATF4 segmentation")
	Dialog.addNumber("ATF4 threshold", thATF4)
	Dialog.addNumber("Min presence of positive marker per cell (%)", minMarkerPerc);
	
	Dialog.show();	
	flagContrast= Dialog.getCheckbox();
	//thMethodNucl=Dialog.getRadioButton();
	thNucl= Dialog.getNumber();
	prominence= Dialog.getNumber();
	radSmooth= Dialog.getNumber();
	cytoBand= Dialog.getNumber();
	//thMethodTum=Dialog.getRadioButton();	
	thATF4= Dialog.getNumber();
	minMarkerPerc= Dialog.getNumber();
	
	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"tif")||endsWith(list[j],"czi")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print("Processing "+name);
			//setBatchMode(true);
			qif(InDir,InDir,list[j],flagContrast,thNucl,prominence,radSmooth,cytoBand,thATF4,minMarkerPerc);
			setBatchMode(false);
			}
	}
	
	showMessage("QIF done!");

}


function qif(output,InDir,name,flagContrast,thNucl,prominence,radSmooth,cytoBand,thATF4,minMarkerPerc)
{

if (InDir=="-") {
	run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
	}
else {
	run("Bio-Formats Importer", "open=["+InDir+name+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
	}	


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
selectWindow(MyTitle);
close();
selectWindow("orig");
run("Make Composite", "display=Composite");

getDimensions(width, height, channels, slices, frames);

Stack.setChannel(cDAPI);
run("Blue");
if(flagContrast) {
	run("Enhance Contrast", "saturated=0.35");
}
run("Set Label...", "label=DAPI");
Stack.setChannel(cATF4);
run("Red");
if(flagContrast) {
	run("Enhance Contrast", "saturated=0.35");
}
run("Set Label...", "label=ATF4");
Stack.setDisplayMode("composite");
//Stack.setActiveChannels("1111111");
wait(100);

run("RGB Color");
rename("merge");

run("Colors...", "foreground=black background=white selection=green");
run("Set Measurements...", "area mean area_fraction redirect=None decimal=2");


// SEGMENT NUCLEI FROM DAPI:

selectWindow("orig");
  // cDAPI=1;
run("Duplicate...", "title=nucleiMask duplicate channels="+cDAPI);
//run("8-bit");
//run("Enhance Contrast", "saturated=0.35");
run("Mean...", "radius="+radSmooth);
wait(100);
//run("Subtract Background...", "rolling=300");
if(flagContrast) {
	run("Enhance Contrast", "saturated=0.35");
}
run("Duplicate...", "title=dapi");
selectWindow("nucleiMask");
	// prominence=50
run("Find Maxima...", "prominence="+prominence+" output=[Single Points]");
rename("dapiMaxima");

selectWindow("nucleiMask");
	//thMethodNucl="Default";
//setAutoThreshold(thMethodNucl+" dark");
setAutoThreshold("Default dark");
getThreshold(lower, upper);
   //thNucl=660;
setThreshold(thNucl,upper);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Median...", "radius=1");
run("Fill Holes");
run("Select All");
run("Analyze Particles...", "size=20-Infinity pixel show=Masks in_situ");

// Generate cellMask by enlarging the mask of nuclei
run("Duplicate...", "title=cellMask");
run("Create Selection");
	//cytoBand=5;
run("Enlarge...", "enlarge="+cytoBand);
setForegroundColor(0, 0, 0);
run("Fill", "slice");

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

/*//--Save cell segmentation image
selectWindow("cellMask");
run("Create Selection");
selectWindow("dapi");
run("Restore Selection");
run("Flatten");
saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_CellSegmentation.jpg");
wait(100);
close();
selectWindow("dapi");
close();
selectWindow("cellMask");
run("Select None");*/


////////////////////
//--PHENOTYPING...
////////////////////

//--ATF4
nATF4 = Find_Phenotype("ATF4", cATF4, thATF4, minMarkerPerc, "cytoplasmic");
print("Number of ATF4+ cells: "+nATF4);

//--Negative cell mask:
imageCalculator("XOR", "cellMask","ATF4");

//--Measure ATF4 intensity of positive and negative cells:

run("Set Measurements...", "area mean standard redirect=None decimal=2");
selectWindow("orig");
Stack.setChannel(cATF4);

// Positive cells:
selectWindow("ATF4");
run("Create Selection");
type=selectionType();
if(type!=-1) {
	run("Clear Results");
	selectWindow("orig");
	run("Restore Selection");
	Stack.setChannel(cATF4);
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
	Stack.setChannel(cATF4);
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
if(File.exists(output+File.separator+"QuantificationResults.xls"))
{	
	//if exists add and modify
	open(output+File.separator+"QuantificationResults.xls");
	wait(500);
	IJ.renameResults("Results");
	wait(500);
}
i=nResults;
wait(100);
setResult("Label", i, MyTitle); 
setResult("# total cells", i, nCells); 
setResult("# ATF4+ cells", i, nATF4); 
setResult("Iavg of ATF4+ cells", i, Ipos);
setResult("Iavg of ATF4- cells", i, Ineg);
setResult("Istd of ATF4+ cells", i, Ipos_std);
setResult("Istd of ATF4- cells", i, Ineg_std); 
saveAs("Results", output+File.separator+"QuantificationResults.xls");
	


// SAVE DETECTIONS:

roiManager("Reset");

// All cells:
selectWindow("cellMask");
run("Create Selection");
type = selectionType();
if(type==-1) { makeRectangle(1,1,1,1); }
roiManager("Add");
close();

// ATF4
selectWindow("ATF4");
run("Create Selection");
type = selectionType();
if(type==-1) { makeRectangle(1,1,1,1); }
roiManager("Add");
close();


selectWindow("merge");
roiManager("Select", 0);
roiManager("Set Color", "#00FFFF");
roiManager("rename", "AllCells");
roiManager("Set Line Width", 2);
run("Flatten");
wait(100);
selectWindow("merge-1");
roiManager("Select", 1);
roiManager("Set Color", "#FF00FF");
roiManager("rename", "ATF4");
roiManager("Set Line Width", 2);
run("Flatten");
saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
wait(100);
rename(MyTitle_short+"_analyzed.jpg");

if (InDir!="-") {
close(); }

selectWindow("nucleiMask");
close();
selectWindow("dapi");
close();
selectWindow("orig");
close();
selectWindow("merge");
close();
selectWindow("merge-1");
close();

//Clear unused memory
wait(500);
run("Collect Garbage");

//showMessage("Done!");

}


function Find_Phenotype(phName, ch, thMarker, minMarkerPerc, markerLoc) {

if(markerLoc=="nuclear") {
	maskToUse="nucleiMask";
}
else {
	maskToUse="cellMask";
}

selectWindow("orig");
run("Select None");
run("Duplicate...", "title="+phName+"mask duplicate channels="+ch);
//run("8-bit");
run("Mean...", "radius=6");
setAutoThreshold("Default dark");
getThreshold(lower, upper);
  //thMarker=600;  
setThreshold(thMarker, upper);
setOption("BlackBackground", false);
run("Convert to Mask");
//--AND between marker mask and tumoral cell mask so that marker in individual cells is left and 
// size filtering may be applied to detect positive cells with a certain no. of positive pixels
imageCalculator("AND", phName+"mask",maskToUse);
//run("Analyze Particles...", "size=20-Infinity pixel show=Masks in_situ");
//run("Analyze Particles...", "size="+minMarkerPerc+"-Infinity pixel show=Masks in_situ");

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



