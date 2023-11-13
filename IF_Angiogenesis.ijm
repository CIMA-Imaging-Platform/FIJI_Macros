// changelog March 2023

// Manual selection of area of analysis
// Automatic tissue detection
// Possibility of deleting regions of tissue
// Automatic detection of vessels in green
// Count vessels and measure area

var r=0.502, thTissue=5, thVess=55, minSizeUm=100, maxSizeUm=200000, maxLumenSizeUm=10000;		


macro "AngiogenesisIF Action Tool 1 - C0a0T0d10AT8d10nTfd10g"{

run("Close All");

//just one file
name=File.openDialog("Select image file");
//print(name);
print("Processing "+name);

Dialog.create("Parameters for the analysis");
Dialog.addMessage("Choose parameters")	
//Dialog.addNumber("Ratio micra/pixel", r);		
Dialog.addNumber("Threshold for tissue segmentation", thTissue);
Dialog.addNumber("Threshold for vessel segmentation", thVess);
Dialog.addNumber("Min vessel size (um2)", minSizeUm);	
Dialog.addNumber("Max vessel size (um2)", maxSizeUm);
Dialog.addNumber("Max lumen size (um2)", maxLumenSizeUm);		
Dialog.show();	

//r= Dialog.getNumber();
thTissue= Dialog.getNumber();
thVess= Dialog.getNumber();	
minSizeUm= Dialog.getNumber(); 		
maxSizeUm= Dialog.getNumber(); 
maxLumenSizeUm= Dialog.getNumber(); 
		

open(name);

//minSize = round(minSizeUm/(r*r));
//maxSize = round(maxSizeUm/(r*r));
//maxLumenSize = round(maxLumenSizeUm/(r*r));
minSize = minSizeUm;
maxSize = maxSizeUm;
maxLumenSize = maxLumenSizeUm;


roiManager("Reset");
run("Clear Results");
MyTitle=getTitle();
output=getInfo("image.directory");

OutDir = output+File.separator+"AnalyzedImages";
File.makeDirectory(OutDir);

aa = split(MyTitle,".");
MyTitle_short = aa[0];

run("Colors...", "foreground=black background=white selection=green");
run("Set Measurements...", "area mean area_fraction redirect=None decimal=2");


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


//--DETECT TISSUE

run("Select All");
showStatus("Detecting tissue...");
run("RGB to Luminance");
rename("a");
	//thTissue=5;
setThreshold(thTissue, 255);
run("Convert to Mask");
run("Median...", "radius=4");
run("Close-");
run("Invert");
run("Analyze Particles...", "size=200000-Infinity pixel show=Masks in_situ");
run("Invert");
//run("Analyze Particles...", "size=5000-Infinity pixel show=Masks in_situ");
run("Analyze Particles...", "size="+maxLumenSize+"-Infinity pixel show=Masks in_situ");
run("Create Selection");
run("Add to Manager");	// ROI1 --> whole tissue
selectWindow("a");
close();


//--Tissue in selected region of analysis
roiManager("deselect");
roiManager("Select", newArray(0,1));
roiManager("AND");
roiManager("Add");
roiManager("Deselect");
roiManager("Select", newArray(0,1));
roiManager("Delete");


//--POSSIBILITY OF DELETING TISSUE REGIONS

selectWindow("orig");
roiManager("select", 0);
q=getBoolean("Tissue detected. Would you like to elliminate any tissue region from the analysis?");
while(q) {
	waitForUser("Select a region to elliminate from the analysis and then press OK");
	type=selectionType();
	if(type!=-1) {
		roiManager("add");
		roiManager("deselect");
		roiManager("Select", newArray(0,1));
		roiManager("AND");
		roiManager("Add");
		roiManager("Deselect");
		roiManager("Select", newArray(0,2));
		roiManager("XOR");
		roiManager("Add");
		roiManager("Deselect");
		roiManager("Select", newArray(0,1,2));
		roiManager("Delete");
		roiManager("deselect");
	}
	selectWindow("orig");
	roiManager("select", 0);
	q=getBoolean("Would you like to elliminate any other tissue region from the analysis?");
}


//--MEASURE AREA OF ANALYSIS

selectWindow("orig");
run("Select All");
roiManager("Select", 0);
roiManager("Measure");
At=getResult("Area",0);
run("Clear Results");


//setBatchMode(true);

//--SEPARATE STAINING CHANNELS

selectWindow("orig");
roiManager("Show None");
run("Select All");
run("Duplicate...", "title=orig1");
run("Split Channels");
selectWindow("orig1 (red)");
close();
selectWindow("orig1 (blue)");
//rename("blue");
close();
selectWindow("orig1 (green)");
rename("green");
run("Green");


//--DETECT CAPILLARIES

selectWindow("green");
run("Mean...", "radius=3");
  // thVess=55;
setThreshold(thVess, 255);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Median...", "radius=2");
run("Close-");
roiManager("Select", 0);
setBackgroundColor(255, 255, 255);
run("Clear Outside");
run("Select All");
run("Fill Holes");
//run("Analyze Particles...", "size=100-200000 show=Masks display clear in_situ");
run("Analyze Particles...", "size="+minSize+"-"+maxSize+" show=Masks display clear in_situ");
run("Create Selection");
roiManager("Add");

nVess = nResults;



//--Measure areas:
run("Clear Results");
selectWindow("orig");
roiManager("Select", 1);
roiManager("Measure");
Avess=getResult("Area",0);

//ratio
r1 = Avess/At*100;


//--Write results:
run("Clear Results");
if(File.exists(output+File.separator+"Quantification_angiogenesis.xls"))
{	
	//if exists add and modify
	open(output+File.separator+"Quantification_angiogenesis.xls");
	IJ.renameResults("Results");
}
i=nResults;
setResult("Label", i, MyTitle); 
setResult("Analyzed area of tissue (um2)", i, At); 
setResult("Area of vessels (um2)", i, Avess);
setResult("Ratio Avess/Atot (%)", i, r1);
setResult("# Vessels", i, nVess);
saveAs("Results", output+File.separator+"Quantification_angiogenesis.xls");


// DRAW:

selectWindow("orig");
roiManager("Show None");
roiManager("Select", 0);
roiManager("Set Color", "yellow");
roiManager("Set Line Width", 2);
run("Flatten");
wait(100);
selectWindow("orig-1");
roiManager("Select", 1);
roiManager("Set Color", "red");
roiManager("Set Line Width", 2);
run("Flatten");
wait(200);

saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzedArea.jpg");
rename(MyTitle_short+"_analyzedArea.jpg");

selectWindow("orig");
close();
selectWindow("orig-1");
close();
selectWindow("green");
close();

setTool("zoom");

run("Collect Garbage");

showMessage("Done!");

}

