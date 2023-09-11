// changelog June 2021
// Nuclei detection in dapi
// Detection of cells positive for green and red

var prominence=15, thNuclei=40, cDAPI=1, cGreen=2, cRed=3, cytoBand=5, minGreenSize=10, minRedSize=10, thTissue=5, thGreen=50, thRed=50;

macro "QIF Action Tool 1 - Cf00T2d15IT6d10m"{
	
	run("ROI Manager...");
	run("Close All");
	
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	print("Processing "+name);
	
	Dialog.create("Parameters for the analysis");
	// Channels:
	Dialog.addMessage("Choose channel numbers")	
	Dialog.addNumber("DAPI", cDAPI);	
	Dialog.addNumber("Green marker", cGreen);	
	Dialog.addNumber("Red marker", cRed);
	// Tissue segmentation options:
	Dialog.addMessage("Tissue parameters");	
	Dialog.addNumber("Tissue threshold", thTissue);	
	// Nuclei segmentation options:
	Dialog.addMessage("Cell segmentation parameters");
	Dialog.addNumber("DAPI threshold", thNuclei);
	Dialog.addNumber("Prominence for nuclei detection", prominence);
	Dialog.addNumber("Cytoplasm width (microns)", cytoBand);
	Dialog.addMessage("Green signal parameters");
	Dialog.addNumber("Green threshold", thGreen);
	Dialog.addNumber("Min green object size (px)", minGreenSize);
	Dialog.addMessage("Red signal parameters");
	Dialog.addNumber("Red threshold", thRed);
	Dialog.addNumber("Min red object size (px)", minRedSize);
	// Thresholding method for green:
	//modeArray=newArray("Huang","Otsu","IsoData","Moments","Triangle","MaxEntropy","Minimum");
	//Dialog.addRadioButtonGroup("Choose the method for Green marker thresholding", modeArray, 1, 7, "Huang");
	// Thresholding method for red:
	//Dialog.addRadioButtonGroup("Choose the method for Red marker thresholding", modeArray, 1, 7, "Huang");
	Dialog.show();	
	cDAPI= Dialog.getNumber();
	cGreen= Dialog.getNumber();
	cRed= Dialog.getNumber();
	thTissue= Dialog.getNumber();
	thNuclei= Dialog.getNumber();
	prominence= Dialog.getNumber();
	cytoBand= Dialog.getNumber();
	thGreen= Dialog.getNumber();
	minGreenSize= Dialog.getNumber();
	thRed= Dialog.getNumber();
	minRedSize= Dialog.getNumber();
	//thMethodGreen=Dialog.getRadioButton();	
	//thMethodRed=Dialog.getRadioButton();
	
	//setBatchMode(true);
	qif("-","-",name,cDAPI,cGreen,cRed,thTissue,thNuclei,prominence,cytoBand,thGreen,minGreenSize,thRed,minRedSize);
	setBatchMode(false);
	showMessage("Quantification finished!");

}

macro "QIF Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	run("ROI Manager...");
	run("Close All");
	
	InDir=getDirectory("Choose Tiles' directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("Parameters for the analysis");
	// Channels:
	Dialog.addMessage("Choose channel numbers")	
	Dialog.addNumber("DAPI", cDAPI);	
	Dialog.addNumber("Green marker", cGreen);	
	Dialog.addNumber("Red marker", cRed);
	// Tissue segmentation options:
	Dialog.addMessage("Tissue parameters");	
	Dialog.addNumber("Tissue threshold", thTissue);	
	// Nuclei segmentation options:
	Dialog.addMessage("Cell segmentation parameters");
	Dialog.addNumber("DAPI threshold", thNuclei);
	Dialog.addNumber("Prominence for nuclei detection", prominence);
	Dialog.addNumber("Cytoplasm width (microns)", cytoBand);
	Dialog.addMessage("Green signal parameters");
	Dialog.addNumber("Green threshold", thGreen);
	Dialog.addNumber("Min green object size (px)", minGreenSize);
	Dialog.addMessage("Red signal parameters");
	Dialog.addNumber("Red threshold", thRed);
	Dialog.addNumber("Min red object size (px)", minRedSize);
	// Thresholding method for green:
	//modeArray=newArray("Huang","Otsu","IsoData","Moments","Triangle","MaxEntropy","Minimum");
	//Dialog.addRadioButtonGroup("Choose the method for Green marker thresholding", modeArray, 1, 7, "Huang");
	// Thresholding method for red:
	//Dialog.addRadioButtonGroup("Choose the method for Red marker thresholding", modeArray, 1, 7, "Huang");
	Dialog.show();	
	cDAPI= Dialog.getNumber();
	cGreen= Dialog.getNumber();
	cRed= Dialog.getNumber();
	thTissue= Dialog.getNumber();
	thNuclei= Dialog.getNumber();
	prominence= Dialog.getNumber();
	cytoBand= Dialog.getNumber();
	thGreen= Dialog.getNumber();
	minGreenSize= Dialog.getNumber();
	thRed= Dialog.getNumber();
	minRedSize= Dialog.getNumber();
	//thMethodGreen=Dialog.getRadioButton();	
	//thMethodRed=Dialog.getRadioButton();
	
	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"tif")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print("Processing "+name);
			//setBatchMode(true);
			qif(InDir,InDir,list[j],cDAPI,cGreen,cRed,thTissue,thNuclei,prominence,cytoBand,thGreen,minGreenSize,thRed,minRedSize);
			setBatchMode(false);
			}
	}
	
	showMessage("Quantification finished!");

}


function qif(output,InDir,name,cDAPI,cGreen,cRed,thTissue,thNuclei,prominence,cytoBand,thGreen,minGreenSize,thRed,minRedSize)
{

run("Close All");

if (InDir=="-") {
	run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
	}
else {
	run("Bio-Formats Importer", "open=["+InDir+name+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
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
Stack.setChannel(cDAPI);
run("Blue");
Stack.setChannel(cGreen);
run("Green");
Stack.setChannel(cRed);
run("Red");
wait(100);

run("RGB Color");
rename("merge");


run("Colors...", "foreground=black background=white selection=green");
run("Set Measurements...", "area mean redirect=None decimal=2");


//--DETECT TISSUE

print("---- Segmenting tissue ----");
setBatchMode(true);
showStatus("Detecting tissue...");
selectWindow("orig");
run("Duplicate...", "title=tissue duplicate");
run("8-bit");
run("Subtract Background...", "rolling=200 stack");
run("Gaussian Blur...", "sigma=4 stack");
run("Threshold...");
	//thTissue=2;
setThreshold(thTissue, 255);
setOption("BlackBackground", false);
run("Convert to Mask", "method=Default background=Dark");
run("Invert LUT");
run("Z Project...", "projection=[Max Intensity]");
selectWindow("MAX_tissue");
selectWindow("tissue");
close();
selectWindow("MAX_tissue");
rename("tissue");
run("Invert LUT");
run("Median...", "radius=12");
run("Analyze Particles...", "size=5000-Infinity pixel show=Masks in_situ");
run("Invert");
wait(100);
run("Analyze Particles...", "size=20000-Infinity pixel show=Masks in_situ");
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
run("Subtract Background...", "rolling=60");
	// prominence=15
run("Find Maxima...", "prominence="+prominence+" output=[Single Points]");
rename("dapiMaxima");

selectWindow("nucleiMask");
	//thNuclei=40;
setThreshold(thNuclei,255);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Median...", "radius=1");
run("Fill Holes");
run("Select All");
run("Analyze Particles...", "size=20-Infinity pixel show=Masks in_situ");

roiManager("Select", 0);
setBackgroundColor(255, 255, 255);
run("Clear Outside");
run("Select All");

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
roiManager("Reset");
run("Analyze Particles...", "size=0-Infinity show=Masks add in_situ");
roiManager("Show None");

selectWindow("cellEdges");
close();
selectWindow("cellMask");
close();
selectWindow("nucleiMask");
close();
selectWindow("dapiMaxima");
close();
selectWindow("cellEdges-watershed");
rename("cellMask");


// DETECT RED CELLS

selectWindow("orig");
run("Duplicate...", "title=red duplicate channels="+cRed);
run("Subtract Background...", "rolling=50");
	//thGreen=50;
setThreshold(thRed,255);
//setAutoThreshold(thMethodGreen+" dark");
setOption("BlackBackground", false);
run("Convert to Mask");

//--AND between green mask and cell mask so that green in individual cells is left and 
// size filtering may be applied to detect positive cells with a certain no. of positive pixels
imageCalculator("AND", "red","cellMask");

run("Analyze Particles...", "size="+minRedSize+"-Infinity pixel show=Masks in_situ");

nCells=roiManager("Count");
selectWindow("cellMask");
run("Select All");
setBackgroundColor(255, 255, 255);
run("Clear", "slice");
wait(100);

run("Clear Results");
selectWindow("red");
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

selectWindow("red");
close();


// PROCESS GREEN TO DETECT RED&GREEN CELLS

selectWindow("orig");
run("Select None");
run("Duplicate...", "title=green duplicate channels="+cGreen);
run("Subtract Background...", "rolling=50");
//setAutoThreshold(thMethodRed+" dark");
setThreshold(thGreen,255);
setOption("BlackBackground", false);
run("Convert to Mask");

//--AND between red mask and green cell mask so that red in individual cells is left and 
// size filtering may be applied to detect positive cells with a certain no. of positive pixels
imageCalculator("AND", "green","cellMask");

//run("Analyze Particles...", "size=3-Infinity pixel show=Masks in_situ");
run("Analyze Particles...", "size="+minGreenSize+"-Infinity pixel show=Masks in_situ");

// DETECT GREEN-POSITIVE CELLS AMONG RED CELLS

selectWindow("cellMask");
run("Duplicate...", "title=redCellMask");
wait(100);
selectWindow("cellMask");
roiManager("Reset");
run("Analyze Particles...", "size=0-Infinity show=Masks add in_situ");
roiManager("Show None");
nCellsRed=roiManager("Count");
selectWindow("cellMask");
run("Select All");
setBackgroundColor(255, 255, 255);
run("Clear", "slice");
wait(100);

run("Clear Results");
selectWindow("green");
run("Select None");
roiManager("Deselect");
roiManager("Measure");
selectWindow("cellMask");	// fill in cellMask with only marker-positive cells in the comparment
for (i=0; i<nCellsRed; i++)
{
	Ii=getResult("Mean",i);	
	if (Ii!=0) {	
			roiManager("Select", i);
		run("Fill", "slice");
		}  	 	
}
run("Select None");
roiManager("Reset");

selectWindow("green");
close();

//--Count number of red and green positive cells:
selectWindow("cellMask");
run("Select All");
run("Analyze Particles...", "size=0-Infinity pixel show=Masks display clear in_situ");
nCellsRedGreen = nResults;

//--Green-red cell densities:
dCellsRedGreen = nCellsRedGreen/Atissue*1000000;			// Density in cells/mm2


// Write results:
run("Clear Results");
if(File.exists(output+File.separator+"QIF_results.xls"))
{	
	//if exists add and modify
	open(output+File.separator+"QIF_results.xls");
	wait(500);
	IJ.renameResults("Results");
	wait(500);
}
i=nResults;
wait(100);
setResult("Label", i, MyTitle); 
setResult("Total tissue area (um2)", i, Atissue); 
setResult("# Cells in total tissue", i, nCells); 
setResult("# Red positive cells", i, nCellsRed); 
setResult("# Red-green positive cells", i, nCellsRedGreen); 
setResult("Density of red-green positive cells (cells/mm2)", i, dCellsRedGreen);
saveAs("Results", output+File.separator+"QIF_results.xls");
	

// DRAW:

//--Red cells
selectWindow("merge");
setBatchMode(false);
roiManager("Deselect");
run("Select None");
selectWindow("redCellMask");
run("Select None");
run("Create Selection");
//run("Find Maxima...", "prominence=10 light output=[Point Selection]");
//setTool("multipoint");
//run("Point Tool...", "type=Hybrid color=Green size=Small counter=0");
roiManager("add");
selectWindow("merge");
roiManager("select", 0);
roiManager("Set Color", "yellow");
roiManager("Set Line Width", 2);
run("Flatten");
wait(200);

selectWindow("merge-1");
setBatchMode(false);
roiManager("Deselect");
run("Select None");
selectWindow("cellMask");
run("Select None");
run("Create Selection");
//run("Find Maxima...", "prominence=10 light output=[Point Selection]");
//setTool("multipoint");
//run("Point Tool...", "type=Hybrid color=Green size=Small counter=0");
roiManager("add");
selectWindow("merge-1");
roiManager("select", 1);
roiManager("Set Color", "magenta");
roiManager("Set Line Width", 2);
run("Flatten");
wait(200);


run("Enhance Contrast...", "saturated=0.3");
saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
wait(100);
rename(MyTitle_short+"_analyzed.jpg");

if (InDir!="-") {
close(); }

selectWindow("cellMask");
close();
selectWindow("redCellMask");
close();
selectWindow("merge");
close();
selectWindow("merge-1");
close();
selectWindow("orig");
close();

//Clear unused memory
wait(500);
run("Collect Garbage");

//showMessage("Done!");

}



