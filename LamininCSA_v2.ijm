// changelog: January 2021
// Automatic detection of fibers using processing similar to Adiposoft
// Abres las imágenes independientes de los dos canales (rojo y azul), y el programa te pide que le digas cuál es cuál
// Added detection of centralized nuclei vs. not-centralized to original LamininCSA

var erodeIter=2;	// Auto2, 10x, fluorescencia

// BUTTON FOR TISSUE DETECTION
macro "LamininCSA Action Tool 1 - C0f0T4d15Dio"
{	

// Ask for confirmation to perform a new detection
q=getBoolean("Are you sure you want to carry out a new detection?");
if(!q) 
{
	showMessage("No detection will be performed");
	exit();
}

roiManager("Reset");
run("Clear Results");
MyTitle=getTitle();
output=getInfo("image.directory");

OutDir = output+File.separator+"Results";
File.makeDirectory(OutDir);

aa = split(MyTitle,".");
temp = aa[0];
//ll = lengthOf(temp);
//MyTitle_short = substring(temp,0,ll-3);
aaa = split(temp,"_");
MyTitle_short = aaa[0];

//save info
print("\\Clear");
print(output);
print(OutDir);
print(MyTitle);
selectWindow("Log");
saveAs("Text",OutDir+File.separator+"imInfo.txt");
run("Close");

/*
if(aa[1]=="tif") {
	if(endsWith(temp,"_c1"))
		open(output+MyTitle_short+"_c2.tif");
	else if(endsWith(temp,"_c2"))
		open(output+MyTitle_short+"_c1.tif");
	else
		exit("Wrong input image");
	
	selectWindow(MyTitle_short+"_c1.tif");
	rename("laminin");	
	selectWindow(MyTitle_short+"_c2.tif");
	rename("dapi");	
}
else
	exit("Wrong input image");
*/

waitForUser("Please select the Laminin image window and press OK");
rename("laminin");
selectWindow("laminin");
run("8-bit");
run("Green");
run("Set Scale...", "distance=0 known=0 unit=pixel");	// remove scale
run("Enhance Contrast...", "saturated=0.4");
waitForUser("Please select the DAPI image window and press OK");
rename("dapi");	
selectWindow("dapi");
run("8-bit");
run("Blue");
run("Set Scale...", "distance=0 known=0 unit=pixel");
run("Enhance Contrast...", "saturated=0.4");


// POSSIBILITY OF DELETING A REGION FROM THE IMAGE:
selectWindow("laminin");
q=getBoolean("Would you like to elliminate a region from the image?");
if(q) {
	setTool("freehand");
	waitForUser("Select the region you want to delete and press OK");
	type=selectionType();
	if(type==-1) {
		showMessage("No region has been selected. Nothing will be deleted");
	}
	else {
		run("Add to Manager");
		selectWindow("laminin");
		roiManager("Deselect");
		roiManager("Select", 0);
		setForegroundColor(0, 0, 0);
		run("Fill", "slice");
		run("Select None");
		selectWindow("dapi");
		roiManager("Deselect");
		roiManager("Select", 0);
		setForegroundColor(0, 0, 0);
		run("Fill", "slice");
		run("Select None");
		roiManager("Deselect");
		roiManager("Select", 0);
		roiManager("Delete");	
		run("Select None");
	}
	q=getBoolean("Would you like to elliminate another region from the image?");
}



selectWindow("laminin");

run("Colors...", "foreground=white background=black selection=green");
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");

//setBatchMode(true);

run("Duplicate...", "title=orig");

run("8-bit");
run("Enhance Contrast...", "saturated=0.4");
run("Threshold...");
setAutoThreshold("Huang dark");
waitForUser("Select threshold and press OK when ready");
setOption("BlackBackground", false);
run("Convert to Mask");
run("Invert");
run("Median...", "radius=2");

run("Duplicate...", "title=a");
run("Distance Map");
run("Find Maxima...", "noise=10 output=[Segmented Particles] light");

imageCalculator("AND create", "orig","a Segmented");
selectWindow("Result of orig");
run("Analyze Particles...", "size=800-35000 show=Masks display exclude clear add in_situ");
rename("fiberMask");

roiManager("Show All without labels");
roiManager("Show All");
roiManager("Show None");

//show detection on a merged image
selectWindow("orig");
close();
selectWindow("a");
close();
selectWindow("a Segmented");
close();
selectWindow("Threshold");
run("Close");
selectWindow("laminin");
run("Merge Channels...", "c2=laminin c3=dapi keep");
rename("merge");
roiManager("Show All with labels");
setTool("zoom");


//save segmented fibers
selectWindow("fiberMask");
saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_fiberMask.tif");
wait(100);
rename("fiberMask");

selectWindow("merge");
showMessage("Automatic detection of fibers finished!");

}


macro "LamininCSA Action Tool 2 - C0f0T4d14a"{
	
// ADD

selectWindow("merge");
setTool("freehand");
waitForUser("Please draw a fiber to add and press ok when ready");
//check if we have a selection
type = selectionType();
  if (type==-1)	{
	showMessage("Edition", "You should draw a fiber to add. Nothing will be added.");
	exit();
  }
//run("Add to Manager");
selectWindow("fiberMask");
run("Restore Selection");
setForegroundColor(0, 0, 0);
run("Fill", "slice");
run("Select None");

//get info of original image
selectWindow("laminin");
dir=getInfo("image.directory");		
Fstring=File.openAsString(dir+File.separator+"Results"+File.separator+"imInfo.txt");
strA=split(Fstring,"\n");
output=strA[0];
OutDir=strA[1];
MyTitle=strA[2];

aa = split(MyTitle,".");
temp = aa[0];
//ll = lengthOf(temp);
//MyTitle_short = substring(temp,0,ll-3);
aaa = split(temp,"_");
MyTitle_short = aaa[0];

//save segmented fibers
selectWindow("fiberMask");
saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_fiberMask.tif");
wait(100);
rename("fiberMask");

roiManager("Reset");
run("Analyze Particles...", "size=0-Inf show=Masks display exclude clear add in_situ");
selectWindow("merge");
roiManager("Show All with labels");
setTool("zoom");

showMessage("Fiber added");

}


macro "LamininCSA Action Tool 3 - C0f0T4d14d"{

// DELETE

selectWindow("merge");
run("Select None");
setTool("hand");
waitForUser("Please select a fiber to delete and press ok when ready");
//check if we have a selection
type = selectionType();
  if (type==-1)	{
	showMessage("Edition", "You should select a fiber to delete. Nothing will be deleted.");
	exit();
  }	
selectWindow("fiberMask");
run("Restore Selection");
setForegroundColor(255, 255, 255);
run("Fill", "slice");
run("Select None");

//get info of original image
selectWindow("laminin");
dir=getInfo("image.directory");		
Fstring=File.openAsString(dir+File.separator+"Results"+File.separator+"imInfo.txt");
strA=split(Fstring,"\n");
output=strA[0];
OutDir=strA[1];
MyTitle=strA[2];

aa = split(MyTitle,".");
temp = aa[0];
//ll = lengthOf(temp);
//MyTitle_short = substring(temp,0,ll-3);
aaa = split(temp,"_");
MyTitle_short = aaa[0];

//save segmented fibers
selectWindow("fiberMask");
saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_fiberMask.tif");
wait(100);
rename("fiberMask");

roiManager("Reset");
run("Analyze Particles...", "size=0-Inf show=Masks display exclude clear add in_situ");
selectWindow("merge");
roiManager("Show All with labels");
setTool("zoom");

showMessage("Fiber deleted");

}


macro "LamininCSA Action Tool 4 - C00fT4d14C"{

// Ask for confirmation to perform a new fiber classification
q=getBoolean("Are you sure you want to carry out a new fiber classification?");
if(!q) 
{
	showMessage("No action will be performed");
	exit();
}

erodeIter = getNumber("Contour shrinkage for determination of nucleus centralization",erodeIter);

// If there is already a ResultImage, close it to create the new one
temp=getTitle();
if (temp=="ResultImage") {
	close();
}

//get info of original image
selectWindow("laminin");
dir=getInfo("image.directory");		
Fstring=File.openAsString(dir+File.separator+"Results"+File.separator+"imInfo.txt");
strA=split(Fstring,"\n");
output=strA[0];
OutDir=strA[1];
MyTitle=strA[2];

aa = split(MyTitle,".");
temp = aa[0];
//ll = lengthOf(temp);
//MyTitle_short = substring(temp,0,ll-3);
aaa = split(temp,"_");
MyTitle_short = aaa[0];

// NUCLEI DETECTION 

selectWindow("dapi");
run("Subtract Background...", "rolling=50");
run("Mean...", "radius=2");
run("Enhance Contrast...", "saturated=0.4");

run("Find Maxima...", "noise=8 output=[Single Points]");
//run("Find Maxima...", "noise="+noiseTol+" output=[Single Points]");
rename("dapiMaxima");

// Threshold dapi image:
selectWindow("dapi");
run("Duplicate...", "title=dapiMask");
run("Threshold...");
setAutoThreshold("Default dark");
waitForUser("Select threshold and press OK when ready");
setOption("BlackBackground", false);
run("Convert to Mask");
run("Analyze Particles...", "size=2-Inf pixel show=Masks in_situ");
run("Create Selection");
type = selectionType();
  if (type==-1)	{
  	makeRectangle(1,1,1,1);
  }
//roiManager("Add");
selectWindow("dapiMaxima");
run("Select None");
run("Restore Selection");
setBackgroundColor(255, 255, 255);
run("Clear Outside");
run("Select None");

selectWindow("dapiMask");
close();
selectWindow("Threshold");
run("Close");


// CHECK ONE BY ONE WHICH FIBERS CONTAIN A NUCLEUS INSIDE:

// Create a mask for centralized-nucleus fibers and for not-centralized nucleus fibers:
selectWindow("dapiMaxima");
run("Duplicate...", "title=centFibers");
run("Select All");
setBackgroundColor(255, 255, 255);
run("Clear", "slice");
wait(100);
run("Duplicate...", "title=notCentFibers");

// Create mask of eroded fibers:
selectWindow("fiberMask");
roiManager("Show None");
run("Select None");
	// erodeIter=2;
for (i = 0; i < erodeIter; i++) {
	run("Erode");
}
roiManager("Reset");
run("Analyze Particles...", "size=0-Inf add");

// Measure eroded fibers with dapi maxima:
run("Set Measurements...", "area mean redirect=None decimal=5");
run("Clear Results");
selectWindow("dapiMaxima");
run("Select None");
roiManager("Deselect");
roiManager("Measure");

// Paint in black the ones that have a centralized nucleus
selectWindow("centFibers");	
for (i=0; i<nResults; i++)
{
	Ii=getResult("Mean",i);	
	if (Ii!=0) {	
  		roiManager("Select", i);
  		setForegroundColor(0, 0, 0);
		run("Fill", "slice");
  	}  	 	
}
run("Select None");

// Paint in black the ones that do not have a centralized nucleus
selectWindow("notCentFibers");	
for (i=0; i<nResults; i++)
{
	Ii=getResult("Mean",i);	
	if (Ii==0) {	
  		roiManager("Select", i);
  		setForegroundColor(0, 0, 0);
		run("Fill", "slice");
  	}  	 	
}
run("Select None");

// Dilate again eroded fibers with centralized nucleus:
selectWindow("centFibers");	
	// erodeIter=2;
for (i = 0; i < erodeIter; i++) {
	run("Dilate");
}

// Dilate again eroded fibers with not-centralized nucleus:
selectWindow("notCentFibers");	
	// erodeIter=2;
for (i = 0; i < erodeIter; i++) {
	run("Dilate");
}

// DRAW:

selectWindow("merge");
roiManager("Show None");
selectWindow("dapiMaxima");
run("Find Maxima...", "noise=10 output=[Point Selection] light");
setTool("multipoint");
run("Point Tool...", "type=Dot color=Cyan size=Tiny counter=0");
selectWindow("merge");
run("Restore Selection");
run("Flatten");
wait(50);
rename("mergeNuclei");

roiManager("Reset");
selectWindow("notCentFibers");
run("Analyze Particles...", "size=0-Inf add");
selectWindow("mergeNuclei");
roiManager("Show All without labels");
roiManager("Set Color", "magenta");
roiManager("Set Line Width", 1);
run("Flatten");

roiManager("Reset");
selectWindow("centFibers");
run("Analyze Particles...", "size=0-Inf add");
selectWindow("mergeNuclei-1");
roiManager("Show All without labels");
roiManager("Set Color", "yellow");
roiManager("Set Line Width", 1);
run("Flatten");
wait(50);
rename("ResultImage");

selectWindow("mergeNuclei-1");
close();
selectWindow("merge");
close();
selectWindow("dapiMaxima");
close();
//selectWindow("fiberMask");
//close();


// SAVE MASKS:

selectWindow("centFibers");
saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_centFiberMask.tif");
wait(100);
rename("centFibers");

selectWindow("notCentFibers");
saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_notCentFiberMask.tif");
wait(100);
rename("notCentFibers");

selectWindow("ResultImage");
setTool("zoom");
showMessage("Automatic classification of fibers finished! Centralized-nucleus fibers are shown in YELLOW. Not-centralized-nucleus fibers are shown in MAGENTA");
	
}


macro "LamininCSA Action Tool 5 - C00fT0d14<T7514_Tfd14>"{

// Choose class change:
Dialog.create("Classification edition");
modeArray=newArray("Centralized to Not-centralized","Not-centralized to centralized");
Dialog.addMessage("Please choose the change direction")
Dialog.addRadioButtonGroup("Workflows", modeArray,2, 1, "Centralized to Not-centralized");
Dialog.show();
changeDir=Dialog.getRadioButton();

if (changeDir=="Centralized to Not-centralized") 
{
	selectWindow("ResultImage");
	close();
	
	roiManager("Reset");
	selectWindow("notCentFibers");
	run("Analyze Particles...", "size=0-Inf add");
	selectWindow("mergeNuclei");
	roiManager("Show All without labels");
	roiManager("Set Color", "magenta");
	roiManager("Set Line Width", 1);
	run("Flatten");
	
	roiManager("Reset");
	selectWindow("centFibers");
	run("Analyze Particles...", "size=0-Inf add");
	selectWindow("mergeNuclei-1");
	roiManager("Show All without labels");
	roiManager("Set Color", "yellow");
	roiManager("Set Line Width", 1);
	rename("ResultImage");

	selectWindow("ResultImage");
	waitForUser("Please select the fiber you want to mark as NOT-CENTRALIZED");
	//check if we have a selection
	type = selectionType();
	  if (type==-1)	{
		showMessage("Edition", "You should select a fiber to change. Nothing will be changed.");
		exit();
	  }	
	selectWindow("notCentFibers");
	run("Restore Selection");
	setForegroundColor(0, 0, 0);
	run("Fill", "slice");
	selectWindow("centFibers");
	run("Restore Selection");
	setForegroundColor(0, 0, 0);
	run("Clear", "slice");

	selectWindow("ResultImage");
	close();

	//get info of original image
	selectWindow("laminin");
	dir=getInfo("image.directory");		
	Fstring=File.openAsString(dir+File.separator+"Results"+File.separator+"imInfo.txt");
	strA=split(Fstring,"\n");
	output=strA[0];
	OutDir=strA[1];
	MyTitle=strA[2];
	
	aa = split(MyTitle,".");
	temp = aa[0];
	aaa = split(temp,"_");
	MyTitle_short = aaa[0];
	
	// SAVE MASKS:
	
	selectWindow("centFibers");
	run("Select None");
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_centFiberMask.tif");
	wait(100);
	rename("centFibers");
	
	selectWindow("notCentFibers");
	run("Select None");
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_notCentFiberMask.tif");
	wait(100);
	rename("notCentFibers");

	roiManager("Reset");
	selectWindow("notCentFibers");
	run("Analyze Particles...", "size=0-Inf add");
	selectWindow("mergeNuclei");
	roiManager("Show All without labels");
	roiManager("Set Color", "magenta");
	roiManager("Set Line Width", 1);
	run("Flatten");
	
	roiManager("Reset");
	selectWindow("centFibers");
	run("Analyze Particles...", "size=0-Inf add");
	selectWindow("mergeNuclei-1");
	roiManager("Show All without labels");
	roiManager("Set Color", "yellow");
	roiManager("Set Line Width", 1);
	run("Flatten");
	wait(50);
	rename("ResultImage");

	selectWindow("mergeNuclei-1");
	close();

	selectWindow("ResultImage");
	showMessage("Fiber corrected! Centralized-nucleus fibers are shown in YELLOW. Not-centralized-nucleus fibers are shown in MAGENTA");
	
}

else
{
	selectWindow("ResultImage");
	close();
	
	roiManager("Reset");
	selectWindow("centFibers");
	run("Analyze Particles...", "size=0-Inf add");
	selectWindow("mergeNuclei");
	roiManager("Show All without labels");
	roiManager("Set Color", "yellow");
	roiManager("Set Line Width", 1);
	run("Flatten");
	
	roiManager("Reset");
	selectWindow("notCentFibers");
	run("Analyze Particles...", "size=0-Inf add");
	selectWindow("mergeNuclei-1");
	roiManager("Show All without labels");
	roiManager("Set Color", "magenta");
	roiManager("Set Line Width", 1);
	rename("ResultImage");
	
	selectWindow("ResultImage");
	waitForUser("Please select the fiber you want to mark as CENTRALIZED");
	//check if we have a selection
	type = selectionType();
	  if (type==-1)	{
		showMessage("Edition", "You should select a fiber to change. Nothing will be changed.");
		exit();
	  }	
	selectWindow("centFibers");
	run("Restore Selection");
	setForegroundColor(0, 0, 0);
	run("Fill", "slice");
	selectWindow("notCentFibers");
	run("Restore Selection");
	setForegroundColor(0, 0, 0);
	run("Clear", "slice");

	selectWindow("ResultImage");
	close();

	//get info of original image
	selectWindow("laminin");
	dir=getInfo("image.directory");		
	Fstring=File.openAsString(dir+File.separator+"Results"+File.separator+"imInfo.txt");
	strA=split(Fstring,"\n");
	output=strA[0];
	OutDir=strA[1];
	MyTitle=strA[2];
	
	aa = split(MyTitle,".");
	temp = aa[0];
	aaa = split(temp,"_");
	MyTitle_short = aaa[0];
	
	// SAVE MASKS:
	
	selectWindow("centFibers");
	run("Select None");
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_centFiberMask.tif");
	wait(100);
	rename("centFibers");
	
	selectWindow("notCentFibers");
	run("Select None");
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_notCentFiberMask.tif");
	wait(100);
	rename("notCentFibers");

	roiManager("Reset");
	selectWindow("notCentFibers");
	run("Analyze Particles...", "size=0-Inf add");
	selectWindow("mergeNuclei");
	roiManager("Show All without labels");
	roiManager("Set Color", "magenta");
	roiManager("Set Line Width", 1);
	run("Flatten");
	
	roiManager("Reset");
	selectWindow("centFibers");
	run("Analyze Particles...", "size=0-Inf add");
	selectWindow("mergeNuclei-1");
	roiManager("Show All without labels");
	roiManager("Set Color", "yellow");
	roiManager("Set Line Width", 1);
	run("Flatten");
	wait(50);
	rename("ResultImage");

	selectWindow("mergeNuclei-1");
	close();

	selectWindow("ResultImage");
	showMessage("Fiber corrected! Centralized-nucleus fibers are shown in YELLOW. Not-centralized-nucleus fibers are shown in MAGENTA");
	
}

	
}



macro "LamininCSA Action Tool 6 - Ca3fT4d14F"{

// FINISH AND SAVE RESULTS

// Ask for confirmation to process final results
q=getBoolean("Are you sure you want to finish and store results?");
if(!q) 
{
	showMessage("Nothing will be stored");
	exit();
}


// DETERMINE MICRONS/PIXEL RATIO:

Dialog.create("Image calibration for measurements");
// Imaging device options:
modeArray=newArray("Auto2 10x","Vectra 10x");
Dialog.addMessage("Choose imaging device")
Dialog.addRadioButtonGroup("Options", modeArray, 2, 1, "Auto2 10x");
Dialog.show();	
device=Dialog.getRadioButton();

if(device=="Auto2 10x") {
	r=0.6465;
}
else if (device=="Vectra 10x") {
	r=0.993;
}

//get info of original image
selectWindow("laminin");
dir=getInfo("image.directory");		
Fstring=File.openAsString(dir+File.separator+"Results"+File.separator+"imInfo.txt");
strA=split(Fstring,"\n");
output=strA[0];
OutDir=strA[1];
MyTitle=strA[2];

aa = split(MyTitle,".");
temp = aa[0];
aaa = split(temp,"_");
MyTitle_short = aaa[0];

selectWindow("laminin");
close();
selectWindow("dapi");
close();
selectWindow("fiberMask");
close();


// RESULTS

run("Set Measurements...", "area redirect=None decimal=2");
run("Clear Results");
roiManager("Reset");

// CENTRALIZED-NUCLEUS FIBERS:

selectWindow("centFibers");
run("Select None");
run("Analyze Particles...", "display");

// Get number of fibers
nFibers1=nResults;
// Get average cross-sectional area
run("Summarize");
avgCSA1=getResult("Area",nFibers1);
avgCSAm1 = avgCSA1*r*r;	//in micras
// Get equivalent diameter (A=PI*r²):
avgEqDiam1 = 2*sqrt(avgCSAm1/PI);

CSAm1=newArray(nFibers1);
EqDiam1=newArray(nFibers1);
for(i=0;i<nFibers1;i++){	
	temp=getResult("Area",i);
	CSAm1[i]=temp*r*r;//in micra
	EqDiam1[i]=2*sqrt(CSAm1[i]/PI);	
}

// NOT-CENTRALIZED-NUCLEUS FIBERS:

run("Clear Results");
selectWindow("notCentFibers");
run("Select None");
run("Analyze Particles...", "display");

// Get number of fibers
nFibers2=nResults;
// Get average cross-sectional area
run("Summarize");
avgCSA2=getResult("Area",nFibers2);
avgCSAm2 = avgCSA2*r*r;	//in micras
// Get equivalent diameter (A=PI*r²):
avgEqDiam2 = 2*sqrt(avgCSAm2/PI);

CSAm2=newArray(nFibers2);
EqDiam2=newArray(nFibers2);
for(i=0;i<nFibers2;i++){	
	temp=getResult("Area",i);
	CSAm2[i]=temp*r*r;//in micra
	EqDiam2[i]=2*sqrt(CSAm2[i]/PI);	
}


// Write results - Individual CSA of each fiber:

run("Clear Results");

for(i=0;i<nFibers1;i++){	
	setResult("# Fiber", i, i+1);
	setResult("Fiber type", i, "Centralized-nucleus");
	setResult("Cross-Sectional Area (micra²)",i,CSAm1[i]);
	setResult("Equivalent Diameter (micra)",i,EqDiam1[i]);
}

for(i=0;i<nFibers2;i++){	
	setResult("# Fiber", i+nFibers1, i+1+nFibers1);
	setResult("Fiber type", i+nFibers1, "Not-centralized-nucleus");
	setResult("Cross-Sectional Area (micra²)",i+nFibers1,CSAm2[i]);
	setResult("Equivalent Diameter (micra)",i+nFibers1,EqDiam2[i]);
}

selectWindow("Results");
saveAs("Results", OutDir+File.separator+MyTitle_short+".xls");


// Average results:

run("Clear Results");
if(File.exists(OutDir+File.separator+"AverageResults.xls"))
{
	
	//if exists add and modify
	open(OutDir+File.separator+"AverageResults.xls");
	IJ.renameResults("Results");
}
i=nResults;
setResult("Label", i, MyTitle_short); 
setResult("Number of centralized-nucleus fibers", i, nFibers1); 
setResult("Avg CSA of centralized-nucleus fibers (um2)", i, avgCSAm1); 
setResult("Avg fiber diameter of centralized-nucleus fibers (um)", i, avgEqDiam1);
setResult("Number of not-centralized-nucleus fibers", i, nFibers2); 
setResult("Avg CSA of not-centralized-nucleus fibers (um2)", i, avgCSAm2); 
setResult("Avg fiber diameter of not-centralized-nucleus fibers (um)", i, avgEqDiam2);
saveAs("Results", OutDir+File.separator+"AverageResults.xls");


setBatchMode(false);

selectWindow("notCentFibers");
close();
selectWindow("centFibers");
close();
selectWindow("mergeNuclei");
close();
selectWindow("ResultImage");
saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_analyzed.tif");


showMessage("Done");

}

