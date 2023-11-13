// changelog Jan 2022

var prominence=0.15, cDAPI=3, cRed=1, cGreen=2, thDAPI=12, minBacteriaSize=8, minRed=1, minGreen=1;

macro "BacteriaIF Action Tool 1 - Cf00T2d15IT6d10m"{
	
	run("ROI Manager...");
	
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	print("Processing "+name);
	
	Dialog.create("Parameters for the analysis");
	// Channels:
	Dialog.addMessage("Choose channel numbers")	
	Dialog.addNumber("DAPI", cDAPI);	
	Dialog.addNumber("Red marker", cRed);	
	Dialog.addNumber("Green marker", cGreen);
	// Bacteria segmentation options:
	modeArray=newArray("Huang","Otsu","IsoData","Moments","Triangle","MaxEntropy","Minimum");
	Dialog.addMessage("Choose bacteria segmentation options")
	Dialog.addNumber("Threshold for DAPI", thDAPI);
	Dialog.addNumber("Prominence for maxima detection", prominence);
	Dialog.addNumber("Min. bacteria size (px)", minBacteriaSize);	
	Dialog.addNumber("Min. red average signal", minRed);	
	Dialog.addNumber("Min. green average signal", minGreen);	
	Dialog.show();	
	cDAPI= Dialog.getNumber();
	cRed= Dialog.getNumber();
	cGreen= Dialog.getNumber();	
	thDAPI= Dialog.getNumber();
	prominence= Dialog.getNumber();
	minBacteriaSize= Dialog.getNumber();
	minRed= Dialog.getNumber();
	minGreen= Dialog.getNumber();
	
	//setBatchMode(true);
	bacteriaIF("-","-",name,cDAPI,cRed,cGreen,thDAPI,prominence,minBacteriaSize,minRed,minGreen);
	setBatchMode(false);
	showMessage("Bacteria quantified!");

}

macro "BacteriaIF Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	run("ROI Manager...");
	
	InDir=getDirectory("Choose Tiles' directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("Parameters for the analysis");
	// Channels:
	Dialog.addMessage("Choose channel numbers")	
	Dialog.addNumber("DAPI", cDAPI);	
	Dialog.addNumber("Red marker", cRed);	
	Dialog.addNumber("Green marker", cGreen);
	// Bacteria segmentation options:
	modeArray=newArray("Huang","Otsu","IsoData","Moments","Triangle","MaxEntropy","Minimum");
	Dialog.addMessage("Choose bacteria segmentation options")
	Dialog.addNumber("Threshold for DAPI", thDAPI);
	Dialog.addNumber("Prominence for maxima detection", prominence);
	Dialog.addNumber("Min. bacteria size (px)", minBacteriaSize);	
	Dialog.addNumber("Min. red average signal", minRed);	
	Dialog.addNumber("Min. green average signal", minGreen);	
	Dialog.show();	
	cDAPI= Dialog.getNumber();
	cRed= Dialog.getNumber();
	cGreen= Dialog.getNumber();	
	thDAPI= Dialog.getNumber();
	prominence= Dialog.getNumber();
	minBacteriaSize= Dialog.getNumber();
	minRed= Dialog.getNumber();
	minGreen= Dialog.getNumber();
	
	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"czi")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print("Processing "+name);
			//setBatchMode(true);
			bacteriaIF(InDir,InDir,list[j],cDAPI,cRed,cGreen,thDAPI,prominence,minBacteriaSize,minRed,minGreen);
			setBatchMode(false);
			}
	}
	
	showMessage("Bacteria quantified!");

}


function bacteriaIF(output,InDir,name,cDAPI,cRed,cGreen,thDAPI,prominence,minBacteriaSize,minRed,minGreen)
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
	
run("RGB Color");
rename("merge");

run("Enhance Contrast", "saturated=0.35");

run("Colors...", "foreground=black background=white selection=green");
run("Set Measurements...", "area mean redirect=None decimal=2");



// SEGMENT BACTERIA FROM DAPI:

selectWindow("orig");
run("Duplicate...", "title=cellMask duplicate channels="+cDAPI);
run("Mean...", "radius=1");
run("Subtract Background...", "rolling=20");
	// prominence=0.15
run("Find Maxima...", "prominence="+prominence+" output=[Single Points]");
rename("dapiMaxima");

selectWindow("cellMask");
run("8-bit");
//setAutoThreshold("Default dark");
//getThreshold(lower, upper);
	 //thDAPI=20;
setThreshold(thDAPI, 255);
//setAutoThreshold(thMethodNucl+" dark");
setOption("BlackBackground", false);
run("Convert to Mask");
//run("Median...", "radius=1");
//run("Fill Holes");
run("Select All");
  //minBacteriaSize=8;
run("Analyze Particles...", "size="+minBacteriaSize+"-Infinity pixel show=Masks in_situ");
run("Create Selection");
	
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
selectWindow("dapiMaxima");
close();
selectWindow("cellEdges-watershed");
rename("cellMask");


//--DETECT RED AND GREEN SIGNALS TO KEEP ONLY BACTERIA WITH AT LEAST Iavg=1 FOR BOTH CHANNELS

nBacteriaAll=roiManager("Count");
IredAll = newArray(nBacteriaAll);
IgreenAll = newArray(nBacteriaAll);
run("Set Measurements...", "area mean redirect=None decimal=2");

//--Red
selectWindow("orig");
run("Select None");
  cRed=1;
run("Duplicate...", "title=red duplicate channels="+cRed);
run("Clear Results");
selectWindow("red");
roiManager("Deselect");
roiManager("Measure");
for (i = 0; i < nBacteriaAll; i++) {	
	IredAll[i] = getResult("Mean", i);
}

//--Green
selectWindow("orig");
run("Select None");
  cGreen=2;
run("Duplicate...", "title=green duplicate channels="+cGreen);
run("Clear Results");
selectWindow("green");
roiManager("Deselect");
roiManager("Measure");
for (i = 0; i < nBacteriaAll; i++) {	
	IgreenAll[i] = getResult("Mean", i);
}

//--Keep only those bacteria with Ired and Igreen over 1:
selectWindow("cellMask");
run("Select All");
run("Duplicate...", "title=allBacteriaMask");
selectWindow("cellMask");
run("Select All");
setBackgroundColor(255, 255, 255);
run("Clear", "slice");
wait(100);
for (i=0; i<nBacteriaAll; i++)
{
	if (IredAll[i]>=minRed && IgreenAll[i]>=minGreen) {	
  		roiManager("Select", i);
		run("Fill", "slice");
  	}  	 	
}
run("Select None");
roiManager("Reset");
run("Analyze Particles...", "size=0-Infinity show=Masks add in_situ");


//--QUANTIFY RED AND GREEN PROTEINS IN FINAL BACTERIA

nBacteria=roiManager("Count");
print("# bacteria: "+nBacteria);

Abact = newArray(nBacteria);
Ired = newArray(nBacteria);
Igreen = newArray(nBacteria);
Rat_g_r = newArray(nBacteria);

//--Red
run("Clear Results");
selectWindow("red");
roiManager("Deselect");
roiManager("Measure");
for (i = 0; i < nBacteria; i++) {
	Abact[i] = getResult("Area", i);
	Ired[i] = getResult("Mean", i);
}
selectWindow("red");
close();

//--Green
run("Clear Results");
selectWindow("green");
roiManager("Deselect");
roiManager("Measure");
for (i = 0; i < nBacteria; i++) {
	Igreen[i] = getResult("Mean", i);
	if(Ired[i]==0 || Igreen[i]==0) {
		Rat_g_r[i] = NaN;
	}
	else {
		Rat_g_r[i] = Igreen[i]/Ired[i];
	}
}
selectWindow("green");
close();

selectWindow("orig");
close();

//--Write results:

// Individual bacteria results:
run("Clear Results");
if(File.exists(output+File.separator+"Bacteria_results_individual.xls"))
{	
	//if exists add and modify
	open(output+File.separator+"Bacteria_results_individual.xls");
	wait(500);
	IJ.renameResults("Results");
	wait(500);
}
for (k = 0; k < nBacteria; k++) {
	i=nResults;
	setResult("Label", i, MyTitle);
	setResult("Area (um2)", i, Abact[k]); 
	setResult("Red avg intensity", i, Ired[k]); 
	setResult("Green avg intensity", i, Igreen[k]); 
	setResult("Green-red ratio", i, Rat_g_r[k]); 
}
saveAs("Results", output+File.separator+"Bacteria_results_individual.xls");

// Average bacteria results:
run("Clear Results");
Array.getStatistics(Abact, minAbact, maxAbact, meanAbact, stdAbact);
Array.getStatistics(Ired, minIred, maxIred, meanIred, stdIred);
Array.getStatistics(Igreen, minIgreen, maxIgreen, meanIgreen, stdIgreen);
Array.getStatistics(Rat_g_r, minRat_g_r, maxRat_g_r, meanRat_g_r, stdRat_g_r);

if(File.exists(output+File.separator+"Bacteria_results_averages.xls"))
{	
	//if exists add and modify
	open(output+File.separator+"Bacteria_results_averages.xls");
	wait(500);
	IJ.renameResults("Results");
	wait(500);
}
i=nResults;
wait(100);
setResult("Label", i, MyTitle);
setResult("# total bacteria", i, nBacteriaAll); 
setResult("# quantified bacteria", i, nBacteria); 
setResult("Area bacteria avg (um2)", i, meanAbact); 
setResult("Red intensity avg", i, meanIred); 
setResult("Green intensity avg", i, meanIgreen); 
setResult("Green-red ratio avg", i, meanRat_g_r); 
setResult("Area std (um2)", i, stdAbact); 
setResult("Red intensity std", i, stdIred); 
setResult("Green intensity std", i, stdIgreen); 
setResult("Green-red ratio std", i, stdRat_g_r); 
saveAs("Results", output+File.separator+"Bacteria_results_averages.xls");


// DRAW:

selectWindow("merge");
run("Enhance Contrast...", "saturated=0.35");
roiManager("Reset");
selectWindow("allBacteriaMask");
run("Create Selection");
roiManager("Add");
selectWindow("merge");
roiManager("Select", 0);
roiManager("Set Color", "yellow");
roiManager("Set Line Width", 1);
run("Flatten");
selectWindow("cellMask");
run("Create Selection");
roiManager("Add");
selectWindow("merge-1");
roiManager("Select", 1);
roiManager("Set Color", "#A500FF");
roiManager("Set Line Width", 1);
run("Flatten");
saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
wait(100);
rename(MyTitle_short+"_analyzed.jpg");

if (InDir!="-") {
close(); }

selectWindow("cellMask");
close();
selectWindow("allBacteriaMask");
close();
selectWindow("merge");
close();
selectWindow("merge-1");
close();

//Clear unused memory
wait(500);
run("Collect Garbage");

//showMessage("Done!");

}



