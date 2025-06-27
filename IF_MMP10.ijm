// changelog November 2021

// Image loads with annotated points
// Manual selection of cell, automatic segmentation of whole cell and green intensity quantification


var cGreen=2, cellThreshold=15;		


macro "MMP10 Action Tool 1 - C2b4T0d10MT7d10MTfd10P"
{

Dialog.create("Parameters");
Dialog.addMessage("Choose parameters")
Dialog.addNumber("Green channel", cGreen);
Dialog.addNumber("Cell threshold", cellThreshold);
Dialog.show();
cGreen= Dialog.getNumber();
cellThreshold= Dialog.getNumber();

	
roiManager("Reset");
run("Clear Results");
MyTitle=getTitle();
output=getInfo("image.directory");

OutDir = output+File.separator+"AnalyzedImages";
File.makeDirectory(OutDir);
	
aa = split(MyTitle,".");
MyTitle_short = aa[0];

run("Colors...", "foreground=black background=white selection=yellow");
run("Set Measurements...", "area mean redirect=None decimal=2");
//run("Set Scale...", "distance=0 known=0 unit=pixel");

roiManager("Add");	// Roi0 -> Points

selectWindow(MyTitle);
run("Select None");
setTool("freehand");
waitForUser("Select a cell for the analysis and press OK");
type=selectionType();
if(type==-1) {
	selectWindow(MyTitle);
	roiManager("Select", 0);
	roiManager("Delete");
	exit("No cell selected. Nothing will be quantified");
}


//--Segment cell

run("Duplicate...", "title=cell duplicate");
selectWindow("cell");
roiManager("Add");	// Roi1 -> Area for analysis
run("Select None");
run("RGB Color");
run("8-bit");
setAutoThreshold("Default dark");
//run("Threshold...");
setThreshold(cellThreshold, 255);
setOption("BlackBackground", false);
run("Convert to Mask");
roiManager("Select", 1);
setBackgroundColor(255, 255, 255);
run("Clear Outside");
run("Select None");
run("Open");
run("Analyze Particles...", "size=10-Infinity pixel show=Masks in_situ");
run("Create Selection");
roiManager("Add");	// Roi2 --> Segmented cell
close();


//--Quantify green signal

selectWindow("cell");
run("Select None");
Stack.setChannel(cGreen);
roiManager("Select", 2);
run("Measure");

Acell = getResult("Area", 0);
Igreen = getResult("Mean", 0);

// Write results:
run("Clear Results");
if(File.exists(output+File.separator+"QuantificationResults.xls"))
{	
	//if exists add and modify
	open(output+File.separator+"QuantificationResults.xls");
	IJ.renameResults("Results");
}
i=nResults;
cellNo = i+1;
setResult("Label", i, MyTitle); 
setResult("# cell", i, cellNo); 
setResult("Green avg intensity", i, Igreen); 
setResult("Cell Area (um2)", i, Acell); 
saveAs("Results", output+File.separator+"QuantificationResults.xls");


// DRAW

selectWindow("cell");
run("Select None");
run("RGB Color");
rename("img");
roiManager("Show None");
roiManager("Select", 2);
roiManager("Set Color", "yellow");
roiManager("Set Line Width", 1);
run("Flatten");
wait(200);
saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_cell"+cellNo+".jpg");
rename(MyTitle_short+"_cell"+cellNo+".jpg");

roiManager("Deselect");
roiManager("Select", newArray(1,2));
roiManager("Delete");
run("Select None");

selectWindow("img");
close();
selectWindow("cell");
close();

setTool("zoom");
waitForUser("Revise resulting image and press OK");

selectWindow(MyTitle_short+"_cell"+cellNo+".jpg");
close();

selectWindow(MyTitle);
run("Original Scale");
roiManager("Select", 0);
roiManager("Delete");

showMessage("Done!");

}



