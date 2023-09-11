// changelog March 2023
// Segment and quantify green signal per nucleus

var cDAPI=1, cGreen=2, prominence=10, thDAPI=70, radSmooth=6;

macro "IF_DAPI_Green Action Tool 1 - Cf00T2d15IT6d10m"{

	run("Close All");
	
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
	Dialog.addMessage("Nuclear segmentation parameters")	
	Dialog.addNumber("DAPI threshold", thDAPI);	
	Dialog.addNumber("Prominence for maxima detection", prominence);
	Dialog.addNumber("Radius for smoothing", radSmooth);
	
	Dialog.show();	
	cDAPI= Dialog.getNumber();
	cGreen= Dialog.getNumber();
	thDAPI=Dialog.getNumber();
	prominence= Dialog.getNumber();
	radSmooth= Dialog.getNumber();
	
	//setBatchMode(true);
	if_dapi_green("-","-",name,cDAPI,cGreen,thDAPI,prominence,radSmooth);
	setBatchMode(false);
	showMessage("Immunofluorescence quantified!");

}

macro "IF_DAPI_Green Action Tool 2 - C00fT0b11DT9b09iTcb09r"{

	run("Close All");
	
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
	Dialog.addMessage("Nuclear segmentation parameters")	
	Dialog.addNumber("DAPI threshold", thDAPI);	
	Dialog.addNumber("Prominence for maxima detection", prominence);
	Dialog.addNumber("Radius for smoothing", radSmooth);
	
	Dialog.show();	
	cDAPI= Dialog.getNumber();
	cGreen= Dialog.getNumber();
	thDAPI=Dialog.getNumber();
	prominence= Dialog.getNumber();
	radSmooth= Dialog.getNumber();
	
	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"czi")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print("Processing "+name);
			setBatchMode(true);
			if_dapi_green(InDir,InDir,list[j],cDAPI,cGreen,thDAPI,prominence,radSmooth);
			setBatchMode(false);
			}
	}
	
	showMessage("Immunofluorescence quantified!");

}


function if_dapi_green(output,InDir,name,cDAPI,cGreen,thDAPI,prominence,radSmooth)
{

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
run("Enhance Contrast", "saturated=0.35");
Stack.setChannel(cGreen);
run("Subtract Background...", "rolling=30 slice");
run("Enhance Contrast", "saturated=0.35");

// PROCESSING

run("RGB Color");
rename("merge");

run("Colors...", "foreground=black background=white selection=yellow");
run("Set Measurements...", "area mean redirect=None decimal=5");


getDimensions(width, height, channels, slices, frames);



// SEGMENT NUCLEI FROM DAPI:

selectWindow("orig");
  // cDAPI=1;
run("Duplicate...", "title=nucleiMask duplicate channels="+cDAPI);
run("8-bit");
run("Mean...", "radius="+radSmooth);
wait(100);
//run("Subtract Background...", "rolling=300");
run("Duplicate...", "title=dapi");
selectWindow("nucleiMask");
	// prominence=10
run("Find Maxima...", "prominence="+prominence+" output=[Single Points]");
rename("dapiMaxima");

selectWindow("nucleiMask");
	//thMethodNucl="Default";
//setAutoThreshold(thMethodNucl+" dark");
setAutoThreshold("Default dark");
getThreshold(lower, upper);
   //thDAPI=38;
setThreshold(thDAPI,upper);
if (InDir=="-") {
	run("Threshold...");
	waitForUser("Set threshold and press OK when ready");
}
setOption("BlackBackground", false);
run("Convert to Mask");
run("Median...", "radius=1");
run("Fill Holes");
run("Select All");
run("Analyze Particles...", "size=20-Infinity pixel show=Masks in_situ");

// Generate cellMask by enlarging the mask of nuclei
run("Duplicate...", "title=cellMask");
run("Create Selection");
	//cytoBand=5;
//run("Enlarge...", "enlarge="+cytoBand);
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
//roiManager("Reset");
//run("Analyze Particles...", "size=0-Infinity show=Masks add in_situ");
//roiManager("Show None");

selectWindow("cellEdges");
close();
selectWindow("cellMask");
close();
selectWindow("dapiMaxima");
close();
selectWindow("nucleiMask");
close();
selectWindow("cellEdges-watershed");
rename("cellMask");

run("Select None");
run("Analyze Particles...", "size=0-Infinity pixel show=Masks display clear add in_situ");
nCells = nResults;


//--Measure green signal in nuclei

run("Clear Results");
selectWindow("orig");
run("Duplicate...", "title=green duplicate channels="+cGreen);
//run("Enhance Contrast", "saturated=0.35");
selectWindow("green");
roiManager("Deselect");
roiManager("Measure");
InuclG = newArray(nCells);
Anucl = newArray(nCells);
for (i = 0; i < nCells; i++) {
	I = getResult("Mean", i);
	A = getResult("Area", i);
	InuclG[i] = I;
	Anucl[i] = A;
}

selectWindow("orig");
close();
selectWindow("green");
close();
selectWindow("cellMask");
close();


// Write results:
run("Clear Results");
for (j = 0; j < nCells; j++) {
	i=nResults;
	setResult("Label", i, MyTitle); 
	setResult("# cell", i, j+1); 
	setResult("Nuclear area (um2)", i, Anucl[j]); 
	setResult("Avg green signal in nucleus", i, InuclG[i]); 	
}
saveAs("Results", output+File.separator+"IF_quantification_"+MyTitle_short+".xls");
	


// DRAW:

selectWindow("merge");
setBatchMode(false);
roiManager("Deselect");
roiManager("Show All without labels");
roiManager("Show All with labels");
roiManager("Set Color", "yellow");
roiManager("Set Line Width", 1);
run("Flatten");
saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
wait(500);
rename(MyTitle_short+"_analyzed.jpg");


selectWindow("merge");
close();


if (InDir!="-") {
close(); }

//showMessage("Done!");

}


