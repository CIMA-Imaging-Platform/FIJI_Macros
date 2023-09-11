// changelog September 2022
// Use DAPI to segment nuclei and determine cytoplasm as a ring of X microns around

// New features wrt to v2:
// - Work with 32-bit images to avoid false positives when there is only background signal
// - New thresholds for all markers (32-bit float images)
// - Define min % of cell with positive expression of marker, instead of min number of pixels

// New features wrt to v3:
// - Problem of eritrocites resulting in false detections of Foxp3+ or CD11b+ cells. Work with dual thresholds for those two markers: lowTH and highTH.
//   Cell classification: CD11b > highTH && Foxp3 < lowTH --> CD11b+ cell
//                        Foxp3 > highTH && CD11b < lowTH --> Foxp3+ cell
//						  CD11b > highTH && Foxp3 > lowTH --> Eritrocite
//						  Foxp3 > highTH && CD11b > lowTH --> Eritrocite
//						  Foxp3 > lowTH  && CD11b > lowTH --> Eritrocite

// New features wrt to v4:
// - Detection of CD163+/CD11b+ cells (and update of CD163+ and CD11b+ counts)
// - Higher threshold for CD163 to avoid false detections in patients with higher background for this marker
// - Independent minMarkerPerc for Foxp3, so we can set it lower and detect better eritrocites (they tend to express CD11b more extensively than Foxp3)


var prominence=50, cytoBand=0;
var cDAPI=1, cATF4=2;  
var minMarkerPerc=15, thATF4=600, thNucl=660, flagContrast=false, radSmooth=15;

macro "QIF Action Tool 1 - Cf00T2d15IT6d10m"{

	run("Close All");
	
	run("ROI Manager...");
	
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	print("Processing "+name);
	
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



