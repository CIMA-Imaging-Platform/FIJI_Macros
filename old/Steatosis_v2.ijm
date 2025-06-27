




// Summary:
// This script contains macros and functions for analyzing steatosis (fat deposition) in images.
// It provides two main functionalities:
// 1. "Steatosis Action Tool 1": Allows the user to analyze a single image file by selecting it through a file dialog.
// 2. "Steatosis Action Tool 2": Enables batch processing of multiple image files within a selected directory.

// Parameters:
// - r: Micra per pixel ratio for image analysis.
// - thTissue: Threshold value for tissue detection.
// - thFat: Threshold value for fat-deposit detection.
// - prominence: Prominence value for fat-deposit detection.
// - minFatSize: Minimum size of fat deposits for analysis.
// - maxFatSize: Maximum size of fat deposits for analysis.
// - minFatCirc: Minimum circularity of fat deposits for analysis.

// Note: Please ensure that the 'steatosis' function is defined elsewhere in the script or imported from another file.

// changelog September 2022
var r = 0.502, thTissue = 227, thFat = 190, prominence = 5, minFatSize = 60, maxFatSize = 3000, minFatCirc = 0.7; // Scanner 20x

// Macro for processing a single file
macro "Steatosis Action Tool 1 - Cf00T2d15IT6d10m" {
    // Prompt user to select a file
    name = File.openDialog("Select File");
    // Print selected file name
    print(name);
    // Perform steatosis analysis
    steatosis("-", "-", name);
    setBatchMode(false);
    showMessage("Done!");
}

// Macro for batch processing files in a directory
macro "Steatosis Action Tool 2 - C00fT0b11DT9b09iTcb09r" {
    // Prompt user to select a directory
    InDir = getDirectory("Choose a Directory");
    list = getFileList(InDir);
    L = lengthOf(list);

    // Iterate over files in the directory
    for (j = 0; j < L; j++) {
        if (endsWith(list[j], "jpg") || endsWith(list[j], "tif")) {
            // Perform steatosis analysis
            steatosis(InDir, InDir, list[j]);
            setBatchMode(false);
        }
    }
    showMessage("Done!");
}

function steatosis(output,InDir,name)
{

	run("Close All");
	
	if (InDir=="-") {open(name);}
	else {
		if (isOpen(InDir+name)) {}
		else { open(InDir+name); }
	}

	
	//getDimensions(width, height, channels, slices, frames);

roiManager("Reset");
run("Clear Results");
MyTitle=getTitle();
output=getInfo("image.directory");

OutDir = output+File.separator+"AnalyzedImages";
File.makeDirectory(OutDir);

aa = split(MyTitle,".");
MyTitle_short = aa[0];

//setBatchMode(true);
run("Colors...", "foreground=white background=black selection=green");

// DETECT TISSUE

run("Select All");
showStatus("Detecting tissue...");
run("RGB to Luminance");
rename("a");
	//thTissue=227;
setThreshold(0, thTissue);
run("Convert to Mask");
run("Median...", "radius=12");
run("Invert");
//run("Fill Holes");
run("Open");
run("Analyze Particles...", "size=5000-Infinity pixel show=Masks in_situ");
run("Invert");
run("Analyze Particles...", "size=100000-Infinity pixel show=Masks in_situ");
//run("Fill Holes");
run("Create Selection");
run("Add to Manager");	// ROI0 --> whole tissue
selectWindow("a");
close();


//--Detect deposits

// Seeds
run("Duplicate...", "title=orig");
run("8-bit");
run("Mean...", "radius=1");
run("Enhance Contrast", "saturated=0.35");
  // prominence=5
run("Find Maxima...", "prominence="+prominence+" output=[Single Points]");
rename("seeds");

// Fat mask
selectWindow("orig");
run("Duplicate...", "title=fatMask");
  //thFat=190;
setThreshold(thFat, 255);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Median...", "radius=1");
run("Analyze Particles...", "size=40-Inf pixel show=Masks exclude in_situ");

// Fat deposit edges
selectWindow("orig");
run("Find Edges");

// Marker-controlled watershed
run("Marker-controlled Watershed", "input=orig marker=seeds mask=fatMask binary calculate use");
selectWindow("orig-watershed");
rename("fatSegmented");
run("8-bit");
setThreshold(1, 255);
setOption("BlackBackground", false);
run("Convert to Mask");

//run("Analyze Particles...", "size=40-3000 circularity=0.70-1.00 pixel show=Masks in_situ");
run("Analyze Particles...", "size="+minFatSize+"-"+maxFatSize+" circularity="+minFatCirc+"-1.00 pixel show=Masks in_situ");
run("Select None");
roiManager("Select", 0);
setBackgroundColor(255,255,255);
run("Clear Outside");
run("Create Selection");
run("Add to Manager");	// ROI1 --> Fat deposits in tissue
selectWindow("orig");
close();

selectWindow("fatSegmented");
close();
selectWindow("fatMask");
close();
selectWindow("seeds");
close();


// RESULTS--

run("Clear Results");
selectWindow(MyTitle);	
run("Set Measurements...", "area redirect=None decimal=2");

// Tissue
roiManager("select", 0);
roiManager("Measure");
At=getResult("Area",0);
//in micra
Atm=At*r*r;

// Fat deposits
roiManager("select", 1);
roiManager("Measure");
Ap=getResult("Area",1);
//in micra
Apm=Ap*r*r;

// Ratio
r1=Apm/Atm*100;

run("Clear Results");
if(File.exists(output+File.separator+"Quantification_Steatosis.xls"))
{	
	//if exists add and modify
	open(output+File.separator+"Quantification_Steatosis.xls");
	IJ.renameResults("Results");
}
i=nResults;
setResult("Label", i, MyTitle); 
setResult("Tissue area (um2)",i,Atm);
setResult("Steatosis area (um2)",i,Apm);
setResult("Ratio Asteatosis/Atissue (%)",i,r1);			
saveAs("Results", output+File.separator+"Quantification_Steatosis.xls");
	


setBatchMode(false);
selectWindow(MyTitle);
roiManager("Show None");
roiManager("Select", 0);
roiManager("Set Color", "yellow");
roiManager("Set Line Width", 2);
run("Flatten");
roiManager("Show None");
roiManager("Select", 1);
roiManager("Set Color", "green");
roiManager("Set Line Width", 2);
run("Flatten");
saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
rename(MyTitle_short+"_analyzed.jpg");

selectWindow(MyTitle);
close();
selectWindow(MyTitle_short+"-1.jpg");
close();
setTool("zoom");

if (InDir!="-") {
close(); }

//showMessage("Done!");

}

macro "Steatosis Action Tool 1 Options" {
     Dialog.create("Parameters");

     Dialog.addMessage("Choose parameters")
     Dialog.addNumber("micra/px ratio", r);
     Dialog.addNumber("Threshold for tissue detection", thTissue); 
     Dialog.addNumber("Threshold for fat-deposit detection", thFat); 
     Dialog.addNumber("Tolerance for fat seed detection", prominence);      
     Dialog.addNumber("Min fat-deposit size", minFatSize);  
     Dialog.addNumber("Max fat-deposit size", maxFatSize); 
     Dialog.addNumber("Min fat-deposit circularity", minFatCirc); 
     Dialog.show();
     
     r= Dialog.getNumber();
     thTissue= Dialog.getNumber();
     thFat= Dialog.getNumber();
     prominence= Dialog.getNumber();
     minSize= Dialog.getNumber();     
     maxFatSize= Dialog.getNumber();     
     minFatCirc= Dialog.getNumber();           
}

macro "Steatosis Action Tool 2 Options" {
     Dialog.create("Parameters");

     Dialog.addMessage("Choose parameters")
     Dialog.addNumber("micra/px ratio", r);
     Dialog.addNumber("Threshold for tissue detection", thTissue); 
     Dialog.addNumber("Threshold for fat-deposit detection", thFat); 
     Dialog.addNumber("Tolerance for fat seed detection", prominence);      
     Dialog.addNumber("Min fat-deposit size", minFatSize);  
     Dialog.addNumber("Max fat-deposit size", maxFatSize); 
     Dialog.addNumber("Min fat-deposit circularity", minFatCirc); 
     Dialog.show();
     
     r= Dialog.getNumber();
     thTissue= Dialog.getNumber();
     thFat= Dialog.getNumber();
     prominence= Dialog.getNumber();
     minSize= Dialog.getNumber();     
     maxFatSize= Dialog.getNumber();     
     minFatCirc= Dialog.getNumber();    
}
