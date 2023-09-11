// changelog December 2020

// Automatic tissue detection
// Cell nuclei segmentation from blue (HE)
// Determination of cell by applying known diameter of T linphocites (10um)
// Brown signal (CD3) segmentation for positive cell determination


var r=0.502, cellDiameter=10, thTissue=230, thBlue=160, thBrown=105, minSize=10, maxSize=10000;		// Escáner 20x

macro "LymphTcount Action Tool 1 - Cf00T2d15IT6d10m"{
	
	//just one file
	name=File.openDialog("Select image file");
	//print(name);
	print("Processing "+name);
	
	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Choose parameters")	
	Dialog.addNumber("Ratio micra/pixel", r);		
	Dialog.addNumber("Cell diameter (microns)", cellDiameter);		
	Dialog.addNumber("Threshold for tissue segmentation", thTissue);
	Dialog.addNumber("Threshold for nuclei segmentation in HE", thBlue); 
	Dialog.addNumber("Threshold for CD3+ segmentation", thBrown);
	Dialog.addNumber("Min nucleus size", minSize);	
	Dialog.addNumber("Max nucleus size", maxSize);		
	Dialog.show();	
	
	r= Dialog.getNumber();
	cellDiameter= Dialog.getNumber();
	thTissue= Dialog.getNumber();
	thBlue= Dialog.getNumber();
	thBrown= Dialog.getNumber(); 		
	minSize= Dialog.getNumber(); 		
	maxSize= Dialog.getNumber(); 

	//setBatchMode(true);
	lymphT("-","-",name,r,cellDiameter,thTissue,thBlue,thBrown,minSize,maxSize);
	setBatchMode(false);
	showMessage("CD3 quantified!");

}

macro "LymphTcount Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	InDir=getDirectory("Choose images directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Choose parameters")	
	Dialog.addNumber("Ratio micra/pixel", r);		
	Dialog.addNumber("Cell diameter (microns)", cellDiameter);		
	Dialog.addNumber("Threshold for tissue segmentation", thTissue);
	Dialog.addNumber("Threshold for nuclei segmentation in HE", thBlue); 
	Dialog.addNumber("Threshold for CD3+ segmentation", thBrown);
	Dialog.addNumber("Min nucleus size", minSize);	
	Dialog.addNumber("Max nucleus size", maxSize);		
	Dialog.show();	
	
	r= Dialog.getNumber();
	cellDiameter= Dialog.getNumber();
	thTissue= Dialog.getNumber();
	thBlue= Dialog.getNumber();
	thBrown= Dialog.getNumber(); 		
	minSize= Dialog.getNumber(); 		
	maxSize= Dialog.getNumber(); 
	
	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"jpg")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print("Processing "+name);
			//setBatchMode(true);
			lymphT(InDir,InDir,list[j],r,cellDiameter,thTissue,thBlue,thBrown,minSize,maxSize);
			setBatchMode(false);
			}
	}
	
	showMessage("CD3 quantified!");

}


function lymphT(output,InDir,name,r,cellDiameter,thTissue,thBlue,thBrown,minSize,maxSize)
{

if (InDir=="-") {open(name);}
else {
	if (isOpen(InDir+name)) {}
	else { open(InDir+name); }
}


cellRadiusPx = round(cellDiameter/(2*r));

roiManager("Reset");
run("Clear Results");
MyTitle=getTitle();
output=getInfo("image.directory");

OutDir = output+File.separator+"AnalyzedImages";
File.makeDirectory(OutDir);

aa = split(MyTitle,".");
MyTitle_short = aa[0];

run("Colors...", "foreground=black background=white selection=green");
run("Set Measurements...", "area mean redirect=None decimal=2");

// DETECT TISSUE
run("Select All");
showStatus("Detecting tissue...");
run("RGB to Luminance");
rename("a");
run("Threshold...");
//setAutoThreshold("Huang");
//getThreshold(lower, upper);
	//th_tissue=200;
setThreshold(0, thTissue);
run("Convert to Mask");
run("Median...", "radius=12");
run("Analyze Particles...", "size=50000-Infinity pixel show=Masks in_situ");
run("Invert");
run("Analyze Particles...", "size=5000-Infinity pixel show=Masks in_situ");
run("Invert");
run("Create Selection");
run("Add to Manager");	// ROI0 --> whole tissue
selectWindow("a");
close();

// MEASURE AREA OF ANALYSIS--
selectWindow(MyTitle);
run("Select All");
roiManager("Select", 0);
roiManager("Measure");
At=getResult("Area",0);
Atm=At*r*r;
run("Clear Results");

// DRAW TISSUE:
roiManager("Set Color", "yellow");
roiManager("Set Line Width", 2);
run("Flatten");
wait(100);
rename("orig");

//setBatchMode(true);

// SEPARATE STAINING CHANNELS--
selectWindow(MyTitle);
roiManager("Show None");
run("Select All");
showStatus("Deconvolving channels...");
run("Colour Deconvolution", "vectors=[H&E DAB] hide");
selectWindow(MyTitle+"-(Colour_2)");
close();
selectWindow(MyTitle+"-(Colour_1)");
rename("blue");
selectWindow(MyTitle+"-(Colour_3)");
rename("brown");


// DETECT BROWN STAINING
selectWindow("brown");
run("Threshold...");
setAutoThreshold("Huang");
//waitForUser("Adjust threshold for CD3 segmentation and press OK");
//getThreshold(lower, upper);
	//thBrown=120;
setThreshold(0, thBrown);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Close-");
//run("Fill Holes");
run("Median...", "radius=1");
run("Analyze Particles...", "size=8-Infinity show=Masks in_situ");
roiManager("Select", 0);
setBackgroundColor(255, 255, 255);
run("Clear Outside");
run("Select All");
//run("Create Selection");
//type = selectionType();
//  if (type==-1) {	//if there is no selection, select one pixel
//      makeRectangle(1,1,1,1);
//  }
//run("Add to Manager");	// ROI1 --> Brown-staining regions in ROI0
//close();



// SEGMENT BLUE CELLS
selectWindow("blue");
run("Mean...", "radius=2");
run("Threshold...");
setAutoThreshold("Default");
setAutoThreshold("Huang");
   //thBlue = 140;
setThreshold(0, thBlue);
//waitForUser("Adjust threshold for cell segmentation and press OK when ready");
setOption("BlackBackground", false);
run("Convert to Mask");
run("Fill Holes");
run("Median...", "radius=2");
run("Watershed");
roiManager("Select", 0);
run("Clear Outside");
run("Select All");
//run("Analyze Particles...", "size=15-5000 pixel show=Masks in_situ");
run("Analyze Particles...", "size="+minSize+"-"+maxSize+" pixel show=Masks in_situ");

// transform selection to individual points
run("Find Maxima...", "prominence=10 light output=[Single Points]");
rename("blueMaxima");

// Generate cellMask by enlarging the mask of nuclei
selectWindow("blueMaxima");
run("Duplicate...", "title=cellMask");
run("Create Selection");
	// cellRadiusPx = 10;
run("Enlarge...", "enlarge="+cellRadiusPx);
setForegroundColor(0, 0, 0);
run("Fill", "slice");

selectWindow("cellMask");
run("Select All");
run("Duplicate...", "title=cellEdges");
run("Find Edges");

// MARKER-CONTROLLED WATERSHED
run("Marker-controlled Watershed", "input=cellEdges marker=blueMaxima mask=cellMask binary calculate use");

selectWindow("cellEdges-watershed");
run("8-bit");
setThreshold(1, 255);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Analyze Particles...", "size=0-Infinity show=Masks add in_situ");
roiManager("Show None");

selectWindow("cellEdges");
close();
selectWindow("cellMask");
close();
selectWindow("blueMaxima");
close();
selectWindow("cellEdges-watershed");
rename("cellMask");
selectWindow("blue");
close();

n=roiManager("Count");
nCells=n-1;


// CHECK ONE BY ONE WHICH CELLS CONTAIN CD3

selectWindow("cellMask");
run("Duplicate...", "title=positCellMask");
run("Select All");
setBackgroundColor(255, 255, 255);
run("Clear", "slice");
wait(100);

run("Clear Results");
selectWindow("brown");
run("Select None");
roiManager("Deselect");
roiManager("Measure");
selectWindow("positCellMask");	// fill in cellMask only nuclei positive por RNA
for (i=1; i<n; i++)
{
	Ii=getResult("Mean",i);	
	if (Ii!=0) {	//if there is RNA spot, negative cell --> delete ROI
  		roiManager("Select", i);
		run("Fill", "slice");
  	}  	 	
}
run("Select None");
roiManager("Reset");
run("Analyze Particles...", "size=0-Infinity pixel show=Masks add in_situ");
nLymphT=roiManager("Count");
run("Select None");


selectWindow("Threshold");
run("Close");

selectWindow("brown");
close();
selectWindow(MyTitle);
close();

roiManager("Show None");


// Write results:
run("Clear Results");
if(File.exists(output+File.separator+"Total.xls"))
{	
	//if exists add and modify
	open(output+File.separator+"Total.xls");
	IJ.renameResults("Results");
}
i=nResults;
setResult("Label", i, MyTitle); 
setResult("# Cells", i, nCells);
setResult("# T cells", i, nLymphT);
setResult("Area of tissue (um2)", i, Atm); 
saveAs("Results", output+File.separator+"Total.xls");


// DRAW:

selectWindow("orig");


// Draw all cells
selectWindow("cellMask");
run("Select None");
//run("Find Maxima...", "noise=10 output=[Point Selection] light");
//setTool("multipoint");
//run("Point Tool...", "type=Hybrid  color=Red size=Tiny counter=0");
run("Create Selection");
selectWindow("orig");
run("Restore Selection");
roiManager("Set Color", "red");
roiManager("Set Line Width", 1);
run("Flatten");
wait(100);


// Draw CD3-positive cells
if(nLymphT!=0) { 
selectWindow("positCellMask");
run("Select None");
//run("Find Maxima...", "noise=10 output=[Point Selection] light");
//setTool("multipoint");
//run("Point Tool...", "type=Hybrid  color=Green size=Tiny counter=0");
run("Create Selection");
selectWindow("orig-1");
run("Restore Selection");
roiManager("Set Color", "green");
roiManager("Set Line Width", 1);
}
run("Flatten");
wait(200);

saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
rename(MyTitle_short+"_analyzed.jpg");

selectWindow("orig");
close();
selectWindow("orig-1");
close();
selectWindow("positCellMask");
close();
selectWindow("cellMask");
close();

setTool("zoom");

setBatchMode(false);

if (InDir!="-") {
close(); }

//showMessage("Done!");

}

macro "CD3count Action Tool Options" {
	Dialog.create("Parameters");
	
	Dialog.addMessage("Choose parameters")	
	Dialog.addNumber("Ratio micra/pixel", r);		
	Dialog.addNumber("Cell diameter (microns)", cellDiameter);		
	Dialog.addNumber("Threshold for tissue segmentation", thTissue);
	Dialog.addNumber("Threshold for nuclei segmentation in HE", thBlue); 
	Dialog.addNumber("Threshold for CD3+ segmentation", thBrown);
	Dialog.addNumber("Min nucleus size", minSize);	
	Dialog.addNumber("Max nucleus size", maxSize);		
	Dialog.show();	
	
	r= Dialog.getNumber();
	cellDiameter= Dialog.getNumber();
	thTissue= Dialog.getNumber();
	thBlue= Dialog.getNumber();
	thBrown= Dialog.getNumber(); 		
	minSize= Dialog.getNumber(); 		
	maxSize= Dialog.getNumber(); 			
}


