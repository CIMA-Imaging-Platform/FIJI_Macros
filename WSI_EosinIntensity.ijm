// 2022 November
// Possibility of selecting the analysis regions manually

var r=0.502, thTissue=180;	

macro "EosinIntensity Action Tool 1 - Cf0fT0c11ET8c11oTec11s"{

run("Close All");

name=File.openDialog("Select image file");
open(name);
wait(100);	

//--Parameters for the analysis

Dialog.create("Parameters for the analysis");
Dialog.addMessage("Choose parameters")	
Dialog.addNumber("Ratio micra/pixel", r);		
Dialog.addNumber("Threshold for tissue segmentation", thTissue);	
Dialog.show();	

r= Dialog.getNumber();
thTissue= Dialog.getNumber();

	
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

rename("orig");

//--Correct background by using the mode for contrast adjustment previously balancing the three RGB channels

setBatchMode(true);
run("Set Measurements...", "area mean modal redirect=None decimal=2");
run("Split Channels");
// Get modes:
selectWindow("orig (red)");
run("Measure");
selectWindow("orig (green)");
run("Measure");
selectWindow("orig (blue)");
run("Measure");
modRGB = newArray(3);
modRGB[0] = getResult("Mode", 0);
modRGB[1] = getResult("Mode", 1);
modRGB[2] = getResult("Mode", 2);
// Balance RGB channels:
Array.getStatistics(modRGB, min, max, mean, stdDev);
difR = max-modRGB[0];
difG = max-modRGB[1];
difB = max-modRGB[2];
selectWindow("orig (red)");
run("Add...", "value="+difR);
selectWindow("orig (green)");
run("Add...", "value="+difG);
selectWindow("orig (blue)");
run("Add...", "value="+difB);
// Merge and perform white balance:
run("Merge Channels...", "c1=[orig (red)] c2=[orig (green)] c3=[orig (blue)]");
rename("orig");
if(max>200) {
	setMinAndMax(0, max);
	run("Apply LUT");
}
run("Clear Results");
setBatchMode(false);


//--DETECT TISSUE

selectWindow("orig");
setBatchMode(true);
run("Select All");
showStatus("Detecting tissue...");
run("RGB to Luminance");
rename("a");
run("Mean...", "radius=1");
	//thTissue=180;
setThreshold(0, thTissue);
run("Convert to Mask");
run("Median...", "radius=1");
run("Analyze Particles...", "size=400-Infinity show=Masks exclude in_situ");
//run("Invert");
//run("Analyze Particles...", "size=400-Infinity show=Masks in_situ");
//run("Invert");
//run("Fill Holes");
run("Create Selection");
roiManager("Add");	// ROI0 --> tissue area
selectWindow("a");
close();


//--Possibility of manually selecting regions of analysis

selectWindow("orig");
setBatchMode(false);
setTool("freehand");
waitForUser("Please select an area to analyze and then press OK");
type=selectionType();
if(type==-1) {
	run("Select All");
}
roiManager("Add");	// ROI1 --> Manual region for analysis
q=getBoolean("Would you like to add another area to the analysis?");
while(q) {
	setTool("freehand");
	waitForUser("Select an area to analyze and then press OK");
	type=selectionType();
	if(type!=-1) {
		roiManager("Add");
		roiManager("Deselect");
		roiManager("Select", newArray(1,2));
		roiManager("Combine");
		roiManager("Add");
		roiManager("Deselect");
		roiManager("Select", newArray(1,2));
		roiManager("Delete");
	}	
	roiManager("select", 1);
	q=getBoolean("Would you like to add another area to the analysis?");
}


//--Calculate tissue ROI in selected area(s)

roiManager("Deselect");
roiManager("Select", newArray(0,1));
roiManager("AND");
roiManager("Add");	// ROI2 --> Tissue in selected area(s) of analysis
roiManager("Deselect");
run("Select None");


//--EOSIN INTENSITY

selectWindow("orig");
run("Colour Deconvolution", "vectors=[H&E 2] hide");
//selectWindow(MyTitle+"-(Colour_3)");
selectWindow("orig-(Colour_3)");
close();
selectWindow("orig-(Colour_1)");
close();
selectWindow("orig-(Colour_2)");
rename("eosin");


// RESULTS--

run("Clear Results");
selectWindow("eosin");
run("Select None");
run("Set Measurements...", "area mean redirect=None decimal=2");

// Selected tissue
roiManager("select", 2);
roiManager("Measure");
At = getResult("Area",0);
//in micra
Atm=At*r*r;
Ieos_inv = getResult("Mean",0);

//--Invert eosin value so that higher means more stained
Ieos = 255-Ieos_inv;


run("Clear Results");
if(File.exists(output+File.separator+"EosinQuantification.xls"))
{	
	//if exists add and modify
	open(output+File.separator+"EosinQuantification.xls");
	IJ.renameResults("Results");
}
i=nResults;
setResult("Label", i, MyTitle); 
setResult("Measured tissue area (um2)",i,Atm);
setResult("Eosin intensity in measured area",i,Ieos);
saveAs("Results", output+File.separator+"EosinQuantification.xls");
	

setBatchMode(false);
selectWindow("eosin");
roiManager("Show None");
roiManager("Select", 2);
roiManager("Set Color", "green");
roiManager("Set Line Width", 3);
run("Flatten");
saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_EosinAnalyzed.jpg");
rename(MyTitle_short+"_EosinAnalyzed.jpg");

selectWindow("orig");
close();
selectWindow("eosin");
close();
setTool("zoom");

showMessage("Done!");

}


