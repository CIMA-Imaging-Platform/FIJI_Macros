// changelog January 2023
// Detect all vessels using the red (Cy3) marker, and detect the percentage of vessels that contain platelets using the green (FITC) marker


var cDAPI=1, cFITC=2, cCy3=3;  
var thFITC=20, thCy3=6, minPlatPerc=1;

macro "QIF Action Tool 1 - Ca3fT0d12VTad12P"{

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
	// Markers' segmentation options:
	Dialog.addMessage("Segmentation")
	Dialog.addNumber("FITC threshold", thFITC)
	Dialog.addNumber("Cy3 threshold", thCy3)	
	Dialog.addNumber("Min presence of platelet marker per vessel (%)", minPlatPerc);
		
	Dialog.show();	
	cDAPI= Dialog.getNumber();
	cFITC= Dialog.getNumber();
	cCy3= Dialog.getNumber();			
	thFITC= Dialog.getNumber();
	thCy3= Dialog.getNumber();	
	minPlatPerc= Dialog.getNumber();
	

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
waitForUser("Please select the area of analysis and press OK");
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
Stack.setActiveChannels("011");
wait(100);


run("Colors...", "foreground=black background=white selection=red");
run("Set Measurements...", "area mean area_fraction redirect=None decimal=2");

/*
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
*/

//--Generate a mask for later:
selectWindow("orig");
roiManager("Select", 0);
run("Create Mask");
rename("analysisMask");
selectWindow("orig");
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


//--SEGMENT VESSELS

selectWindow("orig");
run("Duplicate...", "title=vessels duplicate channels=3");
//--Background subtraction
run("Subtract Background...", "rolling=100");
//--Contrast enhancement
run("Enhance Contrast", "saturated=0.35");
run("Duplicate...", "title=cy3");
selectWindow("vessels");
//--Smoothing
run("Mean...", "radius=3");
//--Steerable filter
getVoxelSize(vx, vy, vz, unit);
//print("Voxel size: "+vx+"x"+vy+"x"+vz+" "+unit);
//run("Tubeness", "sigma="+vx+" use");
run("Tubeness", "sigma=3 use");
selectWindow("vessels");
close();
selectWindow("tubeness of vessels");
rename("vessels");
run("8-bit");
  // thCy3 = 6;
setThreshold(thCy3, 255);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Analyze Particles...", "size=10-Infinity show=Masks in_situ");


//--SEGMENT PLATELETS

selectWindow("orig");
run("Duplicate...", "title=platelets duplicate channels=2");
//--Background subtraction
run("Subtract Background...", "rolling=100");
//--Contrast enhancement
run("Enhance Contrast", "saturated=0.35");
run("Duplicate...", "title=fitc");
selectWindow("platelets");
//--Smoothing
run("Mean...", "radius=3");
  // thFITC = 15;
setThreshold(thFITC, 255);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Analyze Particles...", "size=3-Infinity show=Masks in_situ");


//--CONFINE BOTH VESSEL AND PLATELET MASKS TO THE ANALYSIS REGION

imageCalculator("AND", "vessels","analysisMask");
imageCalculator("AND", "platelets","analysisMask");


// CHECK ONE BY ONE WHICH VESSELS CONTAIN PLATELETS

selectWindow("vessels");
run("Duplicate...", "title=vesselsP");
roiManager("Reset");
run("Analyze Particles...", "size=0-Infinity show=Masks add in_situ");
roiManager("Show None");
nVessels=roiManager("Count");
selectWindow("vesselsP");
run("Select All");
setBackgroundColor(255, 255, 255);
run("Clear", "slice");
wait(100);

run("Clear Results");
selectWindow("platelets");
run("Select None");
roiManager("Deselect");
roiManager("Measure");
selectWindow("vesselsP");	// fill in cellMask only nuclei positive por RNA
for (i=0; i<nVessels; i++)
{	
	Aperc=getResult("%Area",i);	
	if (Aperc>=minPlatPerc) {	
  		roiManager("Select", i);
		run("Fill", "slice");
  	}  	 	
}
run("Select None");
roiManager("Reset");

//--Count number of vessels that are positive for platelets marker
selectWindow("vesselsP");
run("Select None");
run("Analyze Particles...", "size=0-Infinity pixel show=Masks display clear in_situ");
nVesselsP = nResults;

//--Percentage of vessels positive for platelets marker
nVessPlatPerc = nVesselsP/nVessels*100;

//--Area of vessels
selectWindow("vessels");
run("Clear Results");
run("Create Selection");
type=selectionType();
if(type==-1) {
	Avess = 0;
}
else {
	run("Measure");
	Avess = getResult("Area", 0);
}

//--Area of platelet marker in vessels
selectWindow("platelets");
run("Clear Results");
imageCalculator("AND", "platelets","vessels");
run("Create Selection");
type=selectionType();
if(type==-1) {
	Aplat = 0;
}
else {
	run("Measure");
	Aplat = getResult("Area", 0);
}

//--Percentage of vessel area positive for platelets marker
vessPlatPerc = Aplat/Avess*100;


//--Area of analysis
selectWindow("analysisMask");
run("Clear Results");
run("Create Selection");
run("Measure");
Atot = getResult("Area", 0);


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
setResult("Area of analysis (um2)", i, Atot); 
setResult("# total vessels", i, nVessels); 
setResult("# platelet-positive vessels", i, nVesselsP); 
setResult("Ratio of platelet-positive vessels (%)", i, nVessPlatPerc);
setResult("Area of vessels total (um2)", i, Avess);  
setResult("Area of vessels positive for platelets (um2)", i, Aplat);  
setResult("Ratio of platelet-positive area (%)", i, vessPlatPerc);
saveAs("Results", output+File.separator+"QuantificationResults.xls");
	

//--DRAW:

//--Create merge
run("Merge Channels...", "c1=cy3 c2=fitc create");
run("RGB Color");
rename("merge");
selectWindow("Composite");
close();

//--Create ROIs
selectWindow("analysisMask");
run("Create Selection");
roiManager("Add");

selectWindow("vessels");
run("Create Selection");
type=selectionType();
if(type==-1) {
	makeRectangle(1,1,1,1);
}
roiManager("Add");

selectWindow("vesselsP");
run("Create Selection");
type=selectionType();
if(type==-1) {
	makeRectangle(1,1,1,1);
}
roiManager("Add");

//--Overlay
selectWindow("merge");
roiManager("Select", 0);
roiManager("Set Color", "#A500FF");
roiManager("Set Line Width", 3);
run("Flatten");
wait(100);

selectWindow("merge-1");
roiManager("Select", 1);
roiManager("Set Color", "yellow");
roiManager("Set Line Width", 2);
run("Flatten");
wait(100);

selectWindow("merge-2");
roiManager("Select", 2);
roiManager("Set Color", "magenta");
roiManager("Set Line Width", 2);
run("Flatten");
wait(100);

saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_Analyzed.jpg");
wait(100);
rename(MyTitle_short+"_Analyzed.jpg");


selectWindow("vessels");
close();
selectWindow("vesselsP");
close();
selectWindow("platelets");
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



