// changelog Feb 2022
// Automatic tissue detection
// Use DAPI to segment nuclei 
// Detect positive red signal in nuclei as Foci
// Quantify Atissue, Afoci and IavgFoci


var prominence=0.15, cDAPI=1, cMarker=2, minMarkerSize=10, thTissue=3, thDAPI=20, thFoci=100;

macro "QIF Action Tool 1 - Cf00T2d15IT6d10m"{
	
	run("ROI Manager...");
	
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	print("Processing "+name);
	
	Dialog.create("Parameters for the analysis");
	// Channels:
	Dialog.addMessage("Choose channel numbers")	
	Dialog.addNumber("DAPI", cDAPI);	
	Dialog.addNumber("Foci marker", cMarker);
	// Tissue segmentation options:
	Dialog.addMessage("Choose threshold for tissue segmentation")	
	Dialog.addNumber("Tissue threshold", thTissue);	
	// Nuclei segmentation options:
	modeArray=newArray("Huang","Otsu","IsoData","Moments","Triangle","MaxEntropy","Minimum");
	Dialog.addMessage("Choose segmentation options")
	//Dialog.addRadioButtonGroup("Methods", modeArray, 1, 7, "Otsu");
	Dialog.addNumber("Threshold for DAPI", thDAPI);
	// Foci segmentation options:
	Dialog.addNumber("Threshold for Foci", thFoci);
	Dialog.addNumber("Min size of foci (px)", minMarkerSize);
	Dialog.show();	
	cDAPI= Dialog.getNumber();
	cMarker= Dialog.getNumber();
	thTissue= Dialog.getNumber();
	thDAPI= Dialog.getNumber();
	thFoci= Dialog.getNumber();
	minMarkerSize= Dialog.getNumber();

	//setBatchMode(true);
	qif("-","-",name,cDAPI,cMarker,thTissue,thDAPI,thFoci,minMarkerSize);
	setBatchMode(false);
	showMessage("Foci quantified!");

}

macro "QIF Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	run("ROI Manager...");
	
	InDir=getDirectory("Choose Tiles' directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("Parameters for the analysis");
	// Channels:
	Dialog.addMessage("Choose channel numbers")	
	Dialog.addNumber("DAPI", cDAPI);	
	Dialog.addNumber("Foci marker", cMarker);
	// Tissue segmentation options:
	Dialog.addMessage("Choose threshold for tissue segmentation")	
	Dialog.addNumber("Tissue threshold", thTissue);	
	// Nuclei segmentation options:
	modeArray=newArray("Huang","Otsu","IsoData","Moments","Triangle","MaxEntropy","Minimum");
	Dialog.addMessage("Choose segmentation options")
	//Dialog.addRadioButtonGroup("Methods", modeArray, 1, 7, "Otsu");
	Dialog.addNumber("Threshold for DAPI", thDAPI);
	// Foci segmentation options:
	Dialog.addNumber("Threshold for Foci", thFoci);
	Dialog.addNumber("Min size of foci (px)", minMarkerSize);
	Dialog.show();	
	cDAPI= Dialog.getNumber();
	cMarker= Dialog.getNumber();
	thTissue= Dialog.getNumber();
	thDAPI= Dialog.getNumber();
	thFoci= Dialog.getNumber();
	minMarkerSize= Dialog.getNumber();
	
	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"tif")||endsWith(list[j],"czi")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print("Processing "+name);
			//setBatchMode(true);
			qif(InDir,InDir,list[j],cDAPI,cMarker,thTissue,thDAPI,thFoci,minMarkerSize);
			setBatchMode(false);
			}
	}
	
	showMessage("Foci quantified!");

}


function qif(output,InDir,name,cDAPI,cMarker,thTissue,thDAPI,thFoci,minMarkerSize)
{

run("Close All");

if(endsWith(name,"czi")) {
	if (InDir=="-") {
		run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
		}
	else {
		run("Bio-Formats Importer", "open=["+InDir+name+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
		}	
}
else {
	if (InDir=="-") {
		open(name);
	}
	else {
		open(InDir+name); 
	}	
}

//setBatchMode(true);

roiManager("Reset");
run("Clear Results");
MyTitle=getTitle();
output=getInfo("image.directory");

OutDir = output+File.separator+"AnalyzedImages";
File.makeDirectory(OutDir);

aa = split(MyTitle,".");
MyTitle_short = aa[0];

rename("orig");

getDimensions(width, height, channels, slices, frames);

Stack.setDisplayMode("composite");

run("RGB Color");
rename("merge");

run("Colors...", "foreground=black background=white selection=green");
run("Set Measurements...", "area mean redirect=None decimal=2");


//--DETECT TISSUE

print("---- Segmenting tissue ----");
setBatchMode(true);
showStatus("Detecting tissue...");
selectWindow("merge");
run("Duplicate...", "title=tissue duplicate");
run("8-bit");
//--Correct background by mode subtraction
run("Clear Results");
run("Set Measurements...", "area mean modal redirect=None decimal=2");
run("Measure");
mod=getResult("Mode",0);
run("Subtract...", "value="+mod);
run("Clear Results");
//--Further processing
run("Gaussian Blur...", "sigma=4");
	//thTissue=3;
setThreshold(thTissue, 255);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Options...", "iterations=1 count=1 do=Close");
run("Median...", "radius=8");
run("Analyze Particles...", "size=200000-Infinity pixel show=Masks in_situ");
run("Invert");
wait(100);
run("Analyze Particles...", "size=10000-Infinity pixel show=Masks in_situ");
run("Invert");
wait(100);
run("Create Selection");
run("Add to Manager");	// ROI0 --> whole tissue
selectWindow("tissue");
close();
setBatchMode(false);

selectWindow("merge");
roiManager("Select", 0);
run("Measure");
Atissue = getResult("Area", 0);
run("Clear Results");
roiManager("Set Color", "white");
roiManager("Set Line Width", 2);
run("Flatten");
wait(200);
selectWindow("merge");
close();
selectWindow("merge-1");
rename("merge");


// SEGMENT NUCLEI FROM DAPI:

selectWindow("orig");
run("Duplicate...", "title=nucleiMask duplicate channels="+cDAPI);
run("Mean...", "radius=3");
run("Subtract Background...", "rolling=300");
run("8-bit");
//setAutoThreshold("Default dark");
//getThreshold(lower, upper);
	 //thDAPI=20;
setThreshold(thDAPI, 255);
//setAutoThreshold(thMethodNucl+" dark");
setOption("BlackBackground", false);
run("Convert to Mask");
run("Median...", "radius=1");
run("Fill Holes");
run("Select All");
run("Analyze Particles...", "size=20-Infinity pixel show=Masks in_situ");
roiManager("Select", 0);
setBackgroundColor(255, 255, 255);
run("Clear Outside");
run("Create Selection");
run("Add to Manager");	// ROI1 --> nuclei mask
close();


//--PROCESS FOCI

selectWindow("orig");
run("Select None");
run("Duplicate...", "title=foci duplicate channels="+cMarker);
run("Clear Results");
run("Set Measurements...", "area mean modal redirect=None decimal=2");
run("Measure");
mod=getResult("Mode",0);
run("Subtract...", "value="+mod);
run("Clear Results");
run("Duplicate...", "title=fociMask");
run("Mean...", "radius=3");
run("8-bit");
	//thFoci=100;
setThreshold(thFoci, 255);
//setAutoThreshold(thMethodNucl+" dark");
setOption("BlackBackground", false);
run("Convert to Mask");
roiManager("Select", 1);
run("Clear Outside");
run("Select None");
run("Analyze Particles...", "size="+minMarkerSize+"-Infinity pixel show=Masks in_situ");
run("Create Selection");
run("Add to Manager");	// ROI2 --> foci mask
close();


// MEASUREMENTS:

run("Clear Results");
selectWindow("foci");
roiManager("Deselect");
roiManager("Select", 2);
roiManager("Measure");
Afoci=getResult("Area",0);
IavgFoci=getResult("Mean",0);

selectWindow("foci");
close();
selectWindow("orig");
close();


// Write results:
run("Clear Results");
if(File.exists(output+File.separator+"Foci_results.xls"))
{	
	//if exists add and modify
	open(output+File.separator+"Foci_results.xls");
	wait(500);
	IJ.renameResults("Results");
	wait(500);
}
i=nResults;
wait(100);
setResult("Label", i, MyTitle); 
setResult("Total tissue area (um2)", i, Atissue); 
setResult("Foci area (um2)", i, Afoci); 
setResult("Foci average intensity", i, IavgFoci); 
saveAs("Results", output+File.separator+"Foci_results.xls");

	
// DRAW:

selectWindow("merge");
setBatchMode(false);
roiManager("Deselect");
run("Select None");
roiManager("Select", 2);
roiManager("Set Color", "cyan");
roiManager("Set Line Width", 1);
run("Flatten");
selectWindow("merge-1");
saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
wait(100);
rename(MyTitle_short+"_analyzed.jpg");

if (InDir!="-") {
close(); }

selectWindow("merge");
close();

setTool("zoom");

//Clear unused memory
wait(500);
run("Collect Garbage");

//showMessage("Done!");

}



