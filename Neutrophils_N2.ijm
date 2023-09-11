// changelog October 2022
// Use DAPI to segment nuclei and determine cytoplasm as a ring of X microns around
// Detect all neutrophil population using the red (Cy3) marker, and detect the percentage of N2-type neutrophils (anti-inflammatory) using the green (FITC) marker


var prominence=3, cytoBand=3;
var cDAPI=1, cFITC=2, cCy3=3;  
var minFITCPerc=0.001, minCy3Perc=5, thFITC=35, thCy3=45, thDAPI=25;

macro "QIF Action Tool 1 - Ca3fT0d12NT9d122"{

run("Close All");
	
//just one file
name=File.openDialog("Select File");
//print(name);
print("Processing "+name);
	
	Dialog.create("Parameters for the analysis");
	// Channels:
	Dialog.addMessage("Channels")
	Dialog.addNumber("DAPI channel", cDAPI);
	Dialog.addNumber("FITC channel", cFITC);
	Dialog.addNumber("Cy3 channel", cCy3);
	// Cell segmentation options:
	//modeArray=newArray("Default","Otsu","IsoData","Moments","Triangle","MaxEntropy","Minimum");
	Dialog.addMessage("Cell segmentation")
	//Dialog.addRadioButtonGroup("Thresholding method for DAPI", modeArray, 1, 7, "Default");
	Dialog.addNumber("DAPI threshold", thDAPI);
	Dialog.addNumber("Prominence for maxima detection", prominence);
	Dialog.addNumber("Cytoplasm width (microns)", cytoBand);
	// Markers' segmentation options:
	Dialog.addMessage("Neutrophil detection")
	Dialog.addNumber("FITC threshold", thFITC)
	Dialog.addNumber("Cy3 threshold", thCy3)	
	Dialog.addNumber("Min presence of FITC marker per cell (%)", minFITCPerc);
	Dialog.addNumber("Min presence of Cy3 marker per cell (%)", minCy3Perc);
	
	Dialog.show();	
	cDAPI= Dialog.getNumber();
	cFITC= Dialog.getNumber();
	cCy3= Dialog.getNumber();	
	thDAPI= Dialog.getNumber();
	prominence= Dialog.getNumber();
	cytoBand= Dialog.getNumber();	
	thFITC= Dialog.getNumber();
	thCy3= Dialog.getNumber();	
	minFITCPerc= Dialog.getNumber();
	minCy3Perc= Dialog.getNumber();


open(name);
//run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
	
roiManager("Reset");
run("Clear Results");
MyTitle=getTitle();
output=getInfo("image.directory");

OutDir = output+File.separator+"AnalyzedImages";
File.makeDirectory(OutDir);

aa = split(MyTitle,".");
MyTitle_short = aa[0];


rename("orig");

//--SELECT AREA OF ANALYSIS

setTool("Freehand");
waitForUser("Please select the area of lesion and press OK");
type = selectionType();
if(type==-1) {
	run("Select All");
}
run("Crop");
roiManager("add");	// ROI 0 --> Region of analysis in the crop
run("Select None");


selectWindow("orig");
run("Make Composite", "display=Composite");

getDimensions(width, height, channels, slices, frames);

Stack.setChannel(cDAPI);
run("Blue");
run("Set Label...", "label=DAPI");
Stack.setChannel(cFITC);
run("Green");
run("Set Label...", "label=FITC");
Stack.setChannel(cCy3);
run("Red");
run("Set Label...", "label=Cy3");
Stack.setDisplayMode("composite");
Stack.setActiveChannels("111");
wait(100);


run("RGB Color");
rename("merge");

run("Colors...", "foreground=black background=white selection=red");
run("Set Measurements...", "area mean area_fraction redirect=None decimal=2");


//--POSSIBILITY OF ELLIMINATING REGIONS FOR THE ANALYSIS

selectWindow("merge");
q=getBoolean("Would you like to exclude any area from the analysis?");
while(q) {
	waitForUser("Select an area to exclude and then press OK");
	type=selectionType();
	if(type==-1) {
		makeRectangle(1,1,1,1);
	}
	roiManager("add");
	roiManager("deselect");
	roiManager("Select", newArray(0,1));
	roiManager("AND");
	roiManager("Add");
	roiManager("Select", newArray(0,2));
	roiManager("XOR");
	roiManager("Add");
	roiManager("Select", newArray(0,1,2));
	roiManager("delete");
	roiManager("deselect");
	selectWindow("merge");
	run("Select None");
	q=getBoolean("Would you like to exclude any other area from the analysis?");
}

//--Generate a mask for later:
selectWindow("merge");
roiManager("Select", 0);
run("Create Mask");
rename("analysisMask");
selectWindow("merge");
run("Select None");



/*
//--DETECT TISSUE

print("---- Segmenting tissue ----");
setBatchMode(true);
showStatus("Detecting tissue...");
selectWindow("merge");
run("Duplicate...", "title=tissue");
run("8-bit");
run("Gaussian Blur...", "sigma=4 stack");
//run("Threshold...");
	//thTissue=8;
setThreshold(thTissue, 255);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Invert LUT");
run("Median...", "radius=12");
run("Analyze Particles...", "size=5000-Infinity pixel show=Masks in_situ");
run("Invert");
wait(100);
run("Analyze Particles...", "size=20000-Infinity pixel show=Masks in_situ");
run("Create Selection");
run("Add to Manager");	// ROI0 --> whole tissue
selectWindow("tissue");
close();
setBatchMode(false);
*/


// SEGMENT NUCLEI FROM DAPI:

selectWindow("orig");
  // cDAPI=1;
run("Duplicate...", "title=nucleiMask duplicate channels="+cDAPI);
//run("8-bit");
run("Mean...", "radius=3");
run("Subtract Background...", "rolling=300");
run("Enhance Contrast", "saturated=0.35");
run("Duplicate...", "title=dapi");
selectWindow("nucleiMask");
	// prominence=3
run("Find Maxima...", "prominence="+prominence+" output=[Single Points]");
rename("dapiMaxima");

selectWindow("nucleiMask");
	//thMethodNucl="Default";
//setAutoThreshold(thMethodNucl+" dark");
setAutoThreshold("Default dark");
getThreshold(lower, upper);
   //thDAPI=27;
setThreshold(thDAPI,upper);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Median...", "radius=1");
run("Fill Holes");
run("Select All");
run("Analyze Particles...", "size=20-Infinity pixel show=Masks in_situ");

// Generate cellMask by enlarging the mask of nuclei
run("Duplicate...", "title=cellMask");
run("Create Selection");
	//cytoBand=3;
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

selectWindow("dapi");
close();
selectWindow("cellMask");
run("Select None");



/*
//--SEGMENT TUMOR CELLS

selectWindow("orig");
  // cGFAP=7;
run("Duplicate...", "title=tumor duplicate channels="+cGFAP);
//run("8-bit");
run("Mean...", "radius=3");
run("Enhance Contrast", "saturated=0.35");
	// thMethodTum="Default";
//setAutoThreshold(thMethodTum+" dark");
    // thGFAP=2.4;
setThreshold(thGFAP,255);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Median...", "radius=1");
run("Analyze Particles...", "size=30-Infinity pixel show=Masks in_situ");
run("Invert");
run("Median...", "radius=4");
run("Analyze Particles...", "size=400-Infinity pixel show=Masks in_situ");
run("Invert");
selectWindow("tumor");
roiManager("Select", 0);
setBackgroundColor(255, 255, 255);
run("Clear Outside");
run("Select None");
run("Create Selection");
roiManager("Add");		// Roi1 --> Tumor region
run("Select None");
//close();

selectWindow("merge");
roiManager("Select", 1);
roiManager("Set Color", "#A500FF");
roiManager("Set Line Width", 4);
run("Flatten");
saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_TissueAndTumorSegmentation.jpg");
wait(100);
close();
selectWindow("merge");
close();
selectWindow("orig");

//--Measure tumor area
run("Clear Results");
roiManager("Select", 1);
run("Measure");
run("Select None");
Atumor = getResult("Area", 0);
run("Clear Results");


// CHECK ONE BY ONE WHICH CELLS ARE PART OF THE TUMOR

selectWindow("cellMask");
roiManager("Reset");
run("Analyze Particles...", "size=0-Infinity show=Masks add in_situ");
roiManager("Show None");
nCells=roiManager("Count");
selectWindow("cellMask");
run("Select All");
setBackgroundColor(255, 255, 255);
run("Clear", "slice");
wait(100);

run("Clear Results");
selectWindow("tumor");
run("Select None");
roiManager("Deselect");
roiManager("Measure");
selectWindow("cellMask");	// fill in cellMask only nuclei positive por RNA
for (i=0; i<nCells; i++)
{
	Ii=getResult("Mean",i);	
	if (Ii!=0) {	//if there is RNA spot, negative cell --> delete ROI
  		roiManager("Select", i);
		run("Fill", "slice");
  	}  	 	
}
run("Select None");
roiManager("Reset");

//--Count number of cells in the tumor compartment:
selectWindow("cellMask");
run("Select None");
run("Analyze Particles...", "size=0-Infinity pixel show=Masks display clear in_situ");
nCellsTumor = nResults;

selectWindow("tumor");
//close();
selectWindow("nucleiMask");
//close();
imageCalculator("AND", "nucleiMask","cellMask");	//keep only tumoral nuclei
*/

imageCalculator("AND", "nucleiMask","cellMask");


////////////////////
//--PHENOTYPING...
////////////////////

//--Subtract background for marker detection
selectWindow("orig");
run("Subtract Background...", "rolling=15");

//--FITC
nFITC = Find_Phenotype("FITC", cFITC, thFITC, minFITCPerc, "cytoplasmic");

//--Cy3
nCy3 = Find_Phenotype("Cy3", cCy3, thCy3, minCy3Perc, "cytoplasmic");


//--DOUBLE POSITIVES

//--FITC+/Cy3+
imageCalculator("AND", "FITC","Cy3");
rename("Cy3_FITC");
run("Select None");
run("Analyze Particles...", "size=0-Infinity pixel show=Masks display clear in_situ");
nFITC = nResults;


//--EXCLUDE POSITIVE CELLS IF THEY ARE OUTSIDE THE DEFINED ANALYSIS REGION

// Recover analysis ROI
selectWindow("analysisMask");
run("Create Selection");
roiManager("add");
run("Clear Results");
run("Measure");
Atot = getResult("Area", 0);


selectWindow("Cy3");
roiManager("Select", 0);
setBackgroundColor(255, 255, 255);
run("Clear Outside");
run("Select None");
run("Analyze Particles...", "size=0-Infinity pixel show=Masks display clear in_situ");
nCy3 = nResults;

selectWindow("Cy3_FITC");
roiManager("Select", 0);
setBackgroundColor(255, 255, 255);
run("Clear Outside");
run("Select None");
run("Analyze Particles...", "size=0-Infinity pixel show=Masks display clear in_situ");
nFITC = nResults;

// Ratio:
rN2 = nFITC/nCy3*100;


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
setResult("Area of lesion (um2)", i, Atot); 
setResult("ALL neutrophils", i, nCy3); 
setResult("N2 neutrophils", i, nFITC); 
setResult("Ratio N2/ALL (%)", i, rN2); 
saveAs("Results", output+File.separator+"QuantificationResults.xls");
	


// SAVE DETECTIONS:

selectWindow("merge");
roiManager("Select", 0);
roiManager("Set Color", "#A500FF");
roiManager("Set Line Width", 3);
run("Flatten");
wait(100);

// All neutrophils
selectWindow("Cy3");
run("Create Selection");
type = selectionType();
if(type==-1) { makeRectangle(1,1,1,1); }
roiManager("Add");
close();
selectWindow("merge-1");
roiManager("Select", 1);
roiManager("Set Color", "white");
roiManager("rename", "neutrophils");
roiManager("Set Line Width", 2);
run("Flatten");
wait(100);

// N2 neutrophils
selectWindow("Cy3_FITC");
run("Create Selection");
type = selectionType();
if(type==-1) { makeRectangle(1,1,1,1); }
roiManager("Add");
close();
selectWindow("merge-2");
roiManager("Select", 2);
roiManager("Set Color", "yellow");
roiManager("rename", "N2_neutrophils");
roiManager("Set Line Width", 2);
run("Flatten");
wait(100);

saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_Analyzed.jpg");
wait(100);
rename(MyTitle_short+"_Analyzed.jpg");

selectWindow("nucleiMask");
close();
selectWindow("cellMask");
close();
selectWindow("analysisMask");
close();
selectWindow("merge");
close();
selectWindow("merge-1");
close();
selectWindow("merge-2");
close();
selectWindow("orig");
close();

//Clear unused memory
wait(500);
run("Collect Garbage");

showMessage("Done!");

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
run("Mean...", "radius=2");
  //thMarker=30;  
setThreshold(thMarker, 255);
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



