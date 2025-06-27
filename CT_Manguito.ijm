// changelog August 2021
// manual selection of analysis regions
// automatic inflammation (green) and fat (red) signal detection in 2D
// definition of peripheral ring, with interactive ring-width definition, for with-or-without-ring quantification of markers

var cInflam=2, cFat=1, ringWidth=50, thInflam=30, thFat=30, minSizeInflam=20, minSizeFat=20;		

macro "QIF Action Tool 1 - Cf00T1d10MT9d10gTfd10t"{
	
run("Close All");

//just one file
name=File.openDialog("Select File");
//print(name);
print("Processing "+name);


//--Define parameters for the analysis

Dialog.create("Parameters for the analysis");
// Channels:
Dialog.addMessage("Choose channel numbers")	
Dialog.addNumber("Inflammation marker", cInflam);	
Dialog.addNumber("Fat marker", cFat);
// Analysis parameters:
Dialog.addMessage("Choose analysis parameters")		
// Peripheral ring width
Dialog.addNumber("Peripheral ring width (um)", ringWidth);
// Segmentation
Dialog.addNumber("Inflammation threshold", thInflam);	
Dialog.addNumber("Fat threshold", thFat);
Dialog.addNumber("Min inflammation particle size (px)", minSizeInflam);	
Dialog.addNumber("Min fat particle size (px)", minSizeFat);	
Dialog.show();	
cInflam= Dialog.getNumber();
cFat= Dialog.getNumber();
ringWidth= Dialog.getNumber();
thInflam= Dialog.getNumber();
thFat= Dialog.getNumber();
minSizeInflam= Dialog.getNumber();
minSizeFat= Dialog.getNumber();	


//--Open input image

run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");



Stack.setDisplayMode("composite");

run("Colors...", "foreground=black background=white selection=yellow");
Stack.getDimensions(width, height, channels, slices, frames);

roiManager("Reset");
run("Clear Results");
MyTitle=getTitle();
output=getInfo("image.directory");

OutDir = output+File.separator+"AnalyzedImages/";
File.makeDirectory(OutDir);

aa = split(MyTitle,".");
MyTitle_short = aa[0];

getVoxelSize(rx, ry, rz, unit);

selectWindow(MyTitle);
rename("orig");


//--MANUAL SELECTION OF TISSUE

setTool("freehand");
waitForUser("Please draw the contour of the tissue to analyze and press OK when ready");
type=selectionType();
if(type==-1) {
	exit("No tissue selected. Program terminated.");
}
roiManager("Add");	// Roi0 -> Tissue


//--MANUAL SELECTION OF HOLES IN THE TISSUE

h=getBoolean("Do you need to remove holes from the tissue?", "Remove holes", "Continue");
if(!h) {	// if no hole added draw a 1px rectangle
	makeRectangle(1, 1, 1, 1);
	roiManager("Add");	// Roi1 -> Hole
}
else {
	run("Select None");
	waitForUser("Please draw the contour of a hole in the tissue and press OK when ready");
	roiManager("Add");	// Roi1 -> Hole
	roiManager("Select", newArray(0,1));
	roiManager("AND");
	type=selectionType();
	if(type==-1) {
		makeRectangle(1, 1, 1, 1);
		roiManager("Add");	// Roi1 -> Hole
	}
	else {
		roiManager("Add");	// Roi1 -> Hole
	}
	roiManager("Deselect");
	roiManager("Select", 1);
	roiManager("Delete");
	roiManager("Show All");
	roiManager("Show All without labels");
	h=getBoolean("Do you need to remove more holes from the tissue?", "Remove more holes", "Continue with the analysis");
}
while(h) {
	run("Select None");
	waitForUser("Please draw the contour of a hole in the tissue and press OK when ready");
	roiManager("Add");	// Roi2 -> Hole
	roiManager("Select", newArray(0,2));
	roiManager("AND");
	type=selectionType();
	if(type==-1) {
		makeRectangle(1, 1, 1, 1);
		roiManager("Add");	// Roi2 -> Hole
	}
	else {
		roiManager("Add");	// Roi2 -> Hole
	}
	roiManager("Deselect");
	roiManager("Select", 2);
	roiManager("Delete");
	// Merge holes in one ROI:
	roiManager("Deselect");
	roiManager("Select", newArray(1,2));
	roiManager("Combine");
	roiManager("Add");	// Roi1 -> Combined holes
	roiManager("Deselect");
	roiManager("Select", newArray(1,2));
	roiManager("Delete");
	// Show
	roiManager("Show All");
	roiManager("Show All without labels");
	h=getBoolean("Do you need to remove more holes from the tissue?", "Remove more holes", "Continue with the analysis");	
}

roiManager("Show None");


//--PERIPHERAL RING DEFINITION

roiManager("Select", 0);
run("Enlarge...", "enlarge=-"+ringWidth);	// Negative ring width to shrink
roiManager("Add");	// Roi2 -> Inner ring tissue
// Remove hole from inner ring:
roiManager("Select", newArray(1,2));
roiManager("AND");
type=selectionType();
if (type==-1) {
	makeRectangle(1, 1, 1, 1);
}
roiManager("Add");
roiManager("Deselect");
roiManager("Select", newArray(2,3));
roiManager("XOR");
roiManager("Add");
roiManager("Deselect");
roiManager("Select", newArray(2,3));
roiManager("Delete");
//
roiManager("Show All");
roiManager("Show All without labels");
waitForUser("Check the peripheral ring and press OK");
q=getBoolean("Do you need to readjust the ring width?", "Readjust ring", "Continue the analysis");
while(q) {
	ringWidth = getNumber("Enter new ring width (um)", ringWidth);
	roiManager("Deselect");
	roiManager("Select", 2);
	roiManager("Delete");
	roiManager("Select", 0);
	run("Enlarge...", "enlarge=-"+ringWidth);	// Negative ring width to shrink
	roiManager("Add");
	// Remove holes from inner ring:
	roiManager("Select", newArray(1,2));
	roiManager("AND");
	type=selectionType();
	if (type==-1) {
		makeRectangle(1, 1, 1, 1);
	}
	roiManager("Add");
	roiManager("Deselect");
	roiManager("Select", newArray(2,3));
	roiManager("XOR");
	roiManager("Add");
	roiManager("Deselect");
	roiManager("Select", newArray(2,3));
	roiManager("Delete");
	//
	roiManager("Show All");
	roiManager("Show All without labels");
	waitForUser("Check the peripheral ring and press OK");
	q=getBoolean("Do you need to readjust the ring width?", "Readjust ring", "Continue the analysis");
}

roiManager("Show None");

// Remove holes from outer ring:
roiManager("Deselect");
roiManager("Select", newArray(0,1));
roiManager("XOR");
roiManager("Add");
roiManager("Deselect");
roiManager("Select", newArray(0,1));
roiManager("Delete");	

// Rename ROIs to reorder them
roiManager("Select", 0);
roiManager("Rename", "2");
roiManager("Select", 1);
roiManager("Rename", "1");
roiManager("Deselect");
roiManager("Sort");		// Roi0 -> Whole tissue. Roi1 -> Inner tissue


// DETECT INFLAMMATION--

selectWindow("orig");
run("Select All");
run("Duplicate...", "title=inflam duplicate channels="+cInflam);
run("8-bit");
run("Subtract Background...", "rolling=50");	
setAutoThreshold("Huang dark");
setThreshold(thInflam, 255);
//setThreshold(30, 255);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Median...", "radius=1");
//run("Analyze Particles...", "size=20-Infinity pixel show=Masks in_situ");
run("Analyze Particles...", "size="+minSizeInflam+"-Infinity pixel show=Masks in_situ");
run("Create Selection");
type = selectionType();
flatInflam = false;
if (type==-1)	{
	makeRectangle(1,1,1,1);	
	flagInflam=true;
}
run("Add to Manager");	
close();


roiManager("Deselect");
roiManager("Select", newArray(0,2));
roiManager("AND");	
roiManager("Add");	// Roi2 -> Inflammation in total tissue
roiManager("Deselect");
roiManager("Select", newArray(1,2));
roiManager("AND");
roiManager("Add");	// Roi3 -> Inflammation in inner ring
roiManager("Deselect");
roiManager("Select", 2);
roiManager("Delete");


// DETECT FAT--

selectWindow("orig");
run("Select All");
run("Duplicate...", "title=fat duplicate channels="+cFat);
run("8-bit");
run("Subtract Background...", "rolling=50");	
setAutoThreshold("Huang dark");
setThreshold(thFat, 255);
//setThreshold(30, 255);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Median...", "radius=1");
//run("Analyze Particles...", "size=20-Infinity pixel show=Masks in_situ");
run("Analyze Particles...", "size="+minSizeFat+"-Infinity pixel show=Masks in_situ");
run("Create Selection");
type = selectionType();
flagFat = false;
if (type==-1)	{
	makeRectangle(2,2,1,1);	
	flagFat=true;
}
run("Add to Manager");	
close();

roiManager("Deselect");
roiManager("Select", newArray(0,4));
roiManager("AND");	
roiManager("Add");	// Roi4 -> Fat in total tissue
roiManager("Deselect");
roiManager("Select", newArray(1,4));
roiManager("AND");
roiManager("Add");	// Roi5 -> Fat in inner ring
roiManager("Deselect");
roiManager("Select", 4);
roiManager("Delete");


// MEASURE--

run("Clear Results");
run("Set Measurements...", "area mean redirect=None decimal=2");
selectWindow("orig");
roiManager("Select", 0);
roiManager("Measure");
roiManager("Select", 2);
roiManager("Measure");
roiManager("Select", 3);
roiManager("Measure");
roiManager("Select", 4);
roiManager("Measure");
roiManager("Select", 5);
roiManager("Measure");
Atissue=getResult("Area", 0);
Ainflam=getResult("Area", 1);
AinflamIn=getResult("Area", 2);
Afat=getResult("Area", 3);
AfatIn=getResult("Area", 4);

rInflam1 = Ainflam/Atissue*100;
rInflam2 = AinflamIn/Atissue*100;
rFat = Afat/Atissue*100;
rFat2 = AfatIn/Atissue*100;

// Write results:
run("Clear Results");
if(File.exists(output+File.separator+"Results.xls"))
{
	//if exists add and modify
	open(output+File.separator+"Results.xls");
	IJ.renameResults("Results");
}
i=nResults;
setResult("Label", i, MyTitle); 
setResult("Tissue total area (um2)", i, Atissue);
setResult("Inflammation total area (um2)", i, Ainflam);				
setResult("Inflammation inner area (um2)", i, AinflamIn);				
setResult("Fat total area (um2)", i, Afat);
setResult("Fat inner area (um2)", i, AfatIn);
setResult("Ratio inflamm total (%)", i, rInflam1);
setResult("Ratio inflamm inner (%)", i, rInflam2);
setResult("Ratio fat total (%)", i, rFat);
setResult("Ratio fat inner (%)", i, rFat2);
saveAs("Results", output+File.separator+"Results.xls");


//--Save images

selectWindow("orig");
run("RGB Color");
rename("imageToSave");
wait(100);
selectWindow("imageToSave");
roiManager("Select", 0);
roiManager("Set Color", "cyan");
roiManager("Set Line Width", 2);
run("Flatten");
roiManager("Show None");
roiManager("Select", 1);
roiManager("Set Color", "cyan");
roiManager("Set Line Width", 2);
run("Flatten");
roiManager("Show None");
roiManager("Select", 2);
roiManager("Set Color", "yellow");
roiManager("Set Line Width", 1);
run("Flatten");
roiManager("Show None");
roiManager("Select", 4);
roiManager("Set Color", "magenta");
roiManager("Set Line Width", 1);
run("Flatten");
wait(500);
saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
rename(MyTitle_short+"_analyzed.jpg");
wait(500);

selectWindow("imageToSave");
close();
selectWindow("imageToSave-1");
close();
selectWindow("imageToSave-2");
close();
selectWindow("imageToSave-3");
close();
selectWindow("orig");
close();

//Clear unused memory
wait(500);
run("Collect Garbage");

showMessage("Quantification finished!");

}




