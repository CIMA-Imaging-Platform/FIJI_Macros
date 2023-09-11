// changelog January 2021
// Segment and quantify DAPI and green areas and obtain ratio DAPI/green

var cDAPI=1, cGreen=2, thDAPI=18, thGreen=15, minGreenSize=10;

macro "IF_DAPI_Green Action Tool 1 - Cf00T2d15IT6d10m"{
	
	run("ROI Manager...");
	
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	print("Processing "+name);
	
	Dialog.create("Parameters for the analysis");
	// Channels:
	Dialog.addMessage("Choose channel numbers")	
	Dialog.addNumber("DAPI", cDAPI);	
	Dialog.addNumber("Green", cGreen);	
	// Thresholds:
	Dialog.addMessage("Choose thresholds")	
	Dialog.addNumber("DAPI", thDAPI);	
	Dialog.addNumber("Green", thGreen);
	// Min size for green:
	Dialog.addMessage("Choose minimum particle size")	
	Dialog.addNumber("Min green particle size (px)", minGreenSize);
	Dialog.show();	
	cDAPI= Dialog.getNumber();
	cGreen= Dialog.getNumber();
	thDAPI=Dialog.getNumber();
	thGreen= Dialog.getNumber();
	minGreenSize= Dialog.getNumber();

	//setBatchMode(true);
	if_dapi_green("-","-",name,cDAPI,cGreen,thDAPI,thGreen,minGreenSize);
	setBatchMode(false);
	showMessage("Immunofluorescence quantified!");

}

macro "IF_DAPI_Green Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	run("ROI Manager...");
	
	InDir=getDirectory("Choose Tiles' directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("Parameters for the analysis");
	// Channels:
	Dialog.addMessage("Choose channel numbers")	
	Dialog.addNumber("DAPI", cDAPI);	
	Dialog.addNumber("Green", cGreen);	
	// Thresholds:
	Dialog.addMessage("Choose thresholds")	
	Dialog.addNumber("DAPI", thDAPI);	
	Dialog.addNumber("Green", thGreen);
	// Min size for green:
	Dialog.addMessage("Choose minimum particle size")	
	Dialog.addNumber("Min green particle size (px)", minGreenSize);
	Dialog.show();	
	cDAPI= Dialog.getNumber();
	cGreen= Dialog.getNumber();
	thDAPI=Dialog.getNumber();
	thGreen= Dialog.getNumber();
	minGreenSize= Dialog.getNumber();
	
	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"czi")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print("Processing "+name);
			setBatchMode(true);
			if_dapi_green(InDir,InDir,list[j],cDAPI,cGreen,thDAPI,thGreen,minGreenSize);
			setBatchMode(false);
			}
	}
	
	showMessage("Immunofluorescence quantified!");

}


function if_dapi_green(output,InDir,name,cDAPI,cGreen,thDAPI,thGreen,minGreenSize)
{

run("Close All");

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

rename("orig");
Stack.setDisplayMode("composite");
/*Stack.setChannel(1);
run("Grays");
Stack.setChannel(2);
run("Green");
Stack.setChannel(3);
run("Blue");
Stack.setChannel(4);
run("Cyan");
Stack.setChannel(5);
run("Red");
Stack.setChannel(6);
run("Magenta");
Stack.setDisplayMode("composite");
Stack.setActiveChannels("1111110");
wait(100);*/


// BACKGROUND CORRECTION

Stack.setChannel(cDAPI);
run("Subtract Background...", "rolling=70 slice");
Stack.setChannel(cGreen);
run("Subtract Background...", "rolling=30 slice");

// PROCESSING

run("RGB Color");
rename("merge");

run("Colors...", "foreground=black background=white selection=yellow");
run("Set Measurements...", "area redirect=None decimal=5");


getDimensions(width, height, channels, slices, frames);


// SEGMENT NUCLEI FROM DAPI:

selectWindow("orig");
run("Duplicate...", "title=DAPI duplicate channels="+cDAPI);
//run("Enhance Contrast", "saturated=0.35");
run("8-bit");
setAutoThreshold("Otsu dark");
//setThreshold(17, 255);
setThreshold(thDAPI, 255);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Median...", "radius=2");
run("Close-");
//run("Watershed");
run("Fill Holes");
run("Analyze Particles...", "size=80-Infinity pixel show=Masks in_situ");
run("Create Selection");
type=selectionType;
if(type==-1) {
	exit("No nucleus detected with current DAPI threshold for image"+MyTitle+". Try lowering the threshold. Program terminated.");
}
roiManager("Add");	// ROI0 --> Nuclei

selectWindow("DAPI");
close();


// SEGMENT GREEN-POSITIVE AREA:

flagGreen=false;
selectWindow("orig");
run("Duplicate...", "title=green duplicate channels="+cGreen);
//run("Enhance Contrast", "saturated=0.35");
run("8-bit");
//setThreshold(26, 255);
setThreshold(thGreen, 255);
run("Convert to Mask");
//run("Median...", "radius=1");
run("Analyze Particles...", "size="+minGreenSize+"-Infinity pixel show=Masks in_situ");
run("Create Selection");
type=selectionType;
if(type==-1) {
	makeRectangle(1,1,1,1);
	flagGreen=true;	
}
roiManager("Add");	// ROI1 --> Green-positive pixels
close();


// GREEN SIGNAL IN NUCLEI:

flagGreenNuclei=false;
roiManager("Select", newArray(0,1));
roiManager("AND");
type=selectionType;
if(type==-1) {
	makeRectangle(1,1,1,1);
	flagGreenNuclei=true;	
}
roiManager("Add");	// ROI2 --> Green-positive pixels in nuclei


// MEASUREMENTS:

run("Set Measurements...", "area mean redirect=None decimal=5");
selectWindow("orig");
run("Duplicate...", "title=green duplicate channels="+cGreen);
run("Clear Results");
roiManager("deselect");
roiManager("Select", 0);
roiManager("Measure");
roiManager("Select", 1);
roiManager("Measure");
roiManager("Select", 2);
roiManager("Measure");

Adapi=getResult("Area", 0);
Agreen=getResult("Area", 1);
Igreen=getResult("Mean", 1);
if(flagGreen) {
	Agreen=0;	
	Igreen=0;	
}
AgreenNucl=getResult("Area", 2);
IgreenNucl=getResult("Mean", 2);
if(flagGreenNuclei) {
	AgreenNucl=0;	
	IgreenNucl=0;	
}

r1=AgreenNucl/Adapi;

selectWindow("orig");
close();
selectWindow("green");
close();

// Write results:
run("Clear Results");
if(File.exists(output+File.separator+"IF_quantification.xls"))
{	
	//if exists add and modify
	open(output+File.separator+"IF_quantification.xls");
	IJ.renameResults("Results");
}
i=nResults;
setResult("Label", i, MyTitle); 
setResult("DAPI area (um2)", i, Adapi); 
setResult("Green total area (um2)", i, Agreen); 
setResult("Green in nuclei area (um2)", i, AgreenNucl); 
setResult("Ratio Agreen/Adapi in nuclei", i, r1); 
setResult("Avg Total Green Intensity", i, Igreen); 
setResult("Avg Green Intensity in nuclei", i, IgreenNucl); 
saveAs("Results", output+File.separator+"IF_quantification.xls");
	


// DRAW:

selectWindow("merge");
setBatchMode(false);
roiManager("Deselect");
roiManager("Select", 0);
roiManager("Set Color", "yellow");
roiManager("Set Line Width", 1);
run("Flatten");
roiManager("Show None");
roiManager("Select", 1);
roiManager("Set Color", "red");
roiManager("Set Line Width", 1);
run("Flatten");
roiManager("Show None");
roiManager("Select", 2);
roiManager("Set Color", "green");
roiManager("Set Line Width", 1);
run("Flatten");
saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
wait(500);
rename(MyTitle_short+"_analyzed.jpg");


selectWindow("merge");
close();
selectWindow("merge-1");
close();
selectWindow("merge-2");
close();

if (InDir!="-") {
close(); }

//showMessage("Done!");

}


