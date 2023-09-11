// Changelog January 2023
// Align serial sections of GFP and GP100 and count positive cells for each marker and both markers simultaneously
// Possibility of manually deleting tissue parts due to edge effect

macro "GFP_GP100 Action Tool 1 - Ca3fT0b11AT8b11lTcb11iTfb11g"{

run("Close All");
InDir=getDirectory("Choose a Directory");
list=getFileList(InDir);
L=lengthOf(list);

for (j=0; j<L; j++)
{
	if(startsWith(list[j],"GFP_")){
		//analyze
		//d=InDir+list[j]t;
		name=list[j];
		print(name);

		open(InDir+name);
	
	
		roiManager("Reset");
		run("Clear Results");
		MyTitle=getTitle();
		output=getInfo("image.directory");
		
		OutDirAligned = output+File.separator+"Aligned";
		File.makeDirectory(OutDirAligned);
		
		aa = split(MyTitle,".");
		MyTitle_short = aa[0];
		
		rename("1_GFP");
		
		subject = substring(MyTitle_short, 4);
		
		//--Open GP100 image
		open(InDir+"GP100_"+subject+".jpg");
		
		rename("2_GP100");
		
		//setBatchMode(true);
		run("Colors...", "foreground=white background=black selection=green");
		
		//--ALIGN IMAGES THROUGH REGISTRATION USING SIFT
		
		run("Images to Stack", "method=[Copy (center)] name=Stack title=[] use");
		selectWindow("Stack");
		run("Linear Stack Alignment with SIFT", "initial_gaussian_blur=1.60 steps_per_scale_octave=3 minimum_image_size=64 maximum_image_size=1024 feature_descriptor_size=4 feature_descriptor_orientation_bins=8 closest/next_closest_ratio=0.92 maximal_alignment_error=25 inlier_ratio=0.05 expected_transformation=Rigid interpolate");
		wait(100);
		selectWindow("Stack");
		close();
		rename("StackAligned");
		run("Stack to Images");
		
		selectWindow("StackAligned-0001");
		rename("GFP");
		saveAs("Jpeg", OutDirAligned+File.separator+"GFP_"+subject+"_aligned.jpg");
		rename("GFP");
		
		selectWindow("StackAligned-0002");
		rename("GP100");
		saveAs("Jpeg", OutDirAligned+File.separator+"GP100_"+subject+"_aligned.jpg");
		rename("GP100");

		run("Close All");

	}

}

showMessage("Images aligned!");

}


//--PROCESS ALIGNED IMAGES

var r=0.502, cellDiameter=20, thTissue=220, thBlue=120, thGFP=90, thGP100=140, minSize=10, maxSize=10000, minBrownPerc=60, minColocPerc=1;

macro "GFP_GP100 Action Tool 2 - C00fT0b11IT4b11mTfb11g"{

	run("Close All");
	
	name=File.openDialog("Select a GFP image");
	//print(name);
	print("Processing "+name);

	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Choose parameters")	
	Dialog.addNumber("Ratio micra/pixel", r);		
	Dialog.addNumber("Cell diameter (microns)", cellDiameter);		
	Dialog.addNumber("Threshold for tissue segmentation", thTissue);
	Dialog.addNumber("Threshold for nuclei segmentation in HE", thBlue); 
	Dialog.addNumber("Threshold for GFP+ segmentation", thGFP);
	Dialog.addNumber("Threshold for GP100+ segmentation", thGP100);
	Dialog.addNumber("Min nucleus size", minSize);	
	Dialog.addNumber("Max nucleus size", maxSize);	
	Dialog.addNumber("Min DAB percentage for positive (%)", minBrownPerc);	
	Dialog.addNumber("Min coloc percentage for double-positive (%)", minColocPerc);	
	Dialog.show();	
	
	r= Dialog.getNumber();
	cellDiameter= Dialog.getNumber();
	thTissue= Dialog.getNumber();
	thBlue= Dialog.getNumber();
	thGFP= Dialog.getNumber(); 		
	thGP100= Dialog.getNumber(); 		
	minSize= Dialog.getNumber(); 		
	maxSize= Dialog.getNumber(); 
	minBrownPerc= Dialog.getNumber();
	minColocPerc= Dialog.getNumber();
	
	cd3("-","-",name,r,cellDiameter,thTissue,thBlue,thGFP,thGP100,minSize,maxSize,minBrownPerc,minColocPerc);
	setBatchMode(false);		
			
	showMessage("GFP and GP100 quantified!");

}


function cd3(output,InDir,name,r,cellDiameter,thTissue,thBlue,thGFP,thGP100,minSize,maxSize,minBrownPerc,minColocPerc)
{

open(name);

cellRadiusPx = round(cellDiameter/(2*r));

roiManager("Reset");
run("Clear Results");
MyTitle=getTitle();
output=getInfo("image.directory");

OutDir = output+File.separator+"AnalyzedImages";
File.makeDirectory(OutDir);

aa = split(MyTitle,".");
MyTitle_short = aa[0];

rename("GFP");

subject = substring(MyTitle_short, 4);

//--Open GP100 image
open(output+"GP100_"+subject+".jpg");

rename("GP100");


run("Colors...", "foreground=black background=white selection=green");
run("Set Measurements...", "area mean area_fraction redirect=None decimal=2");

// DETECT TISSUE IN GFP IMAGE

selectWindow("GFP");
run("Select All");
showStatus("Detecting tissue...");
run("RGB to Luminance");
rename("a");

//--Elliminate possible black contour introduced by the SIFT alignment:
run("Duplicate...", "title=a2");
setThreshold(0, 1);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Create Selection");
type=selectionType();
if(type!=-1) {
	selectWindow("a");
	run("Restore Selection");
	setBackgroundColor(255, 255, 255);
	run("Clear", "slice");
	run("Select All");
}
selectWindow("a2");
close();

selectWindow("a");
run("Select All");
	//thTissue=220;
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


//setBatchMode(true);


//--CREATE TISSUE MASK
selectWindow("GFP");
roiManager("Select", 0);
run("Create Mask");
rename("tissueMask");


//--CREATE MASK OF NON-QUANTIFICATION AREA

selectWindow("GFP");
run("Select None");
roiManager("show none");
setTool("freehand");
waitForUser("Draw an area to exclude from quantification in GFP image");
type=selectionType();
if(type==-1) {
	makeRectangle(1,1,1,1);
	run("Create Mask");
	rename("noGFP");
}
else {
	run("Create Mask");
	rename("noGFP");
	selectWindow("GFP");
	q=getBoolean("Would you like to exclude another area?");
	while(q) {
		waitForUser("Draw an area to exclude from quantification in GFP image");
		type=selectionType();
		if(type==-1) {
			makeRectangle(1,1,1,1);
		}
		selectWindow("noGFP");
		run("Restore Selection");
		setForegroundColor(0, 0, 0);
		run("Fill", "slice");
		run("Create Selection");
		selectWindow("GFP");
		run("Restore Selection");
		q=getBoolean("Would you like to exclude another area?");	
	}
}

selectWindow("GP100");
wait(100);
run("Select None");
roiManager("show none");
waitForUser("Draw an area to exclude from quantification in GP100 image");
type=selectionType();
if(type==-1) {
	makeRectangle(1,1,1,1);
	run("Create Mask");
	rename("noGP100");
}
else {
	run("Create Mask");
	rename("noGP100");
	selectWindow("GP100");
	q=getBoolean("Would you like to exclude another area?");
	while(q) {
		waitForUser("Draw an area to exclude from quantification in GP100 image");
		type=selectionType();
		if(type==-1) {
			makeRectangle(1,1,1,1);
		}
		selectWindow("noGP100");
		run("Restore Selection");
		setForegroundColor(0, 0, 0);
		run("Fill", "slice");
		run("Create Selection");
		selectWindow("GP100");
		run("Restore Selection");
		q=getBoolean("Would you like to exclude another area?");	
	}
}

imageCalculator("OR", "noGFP","noGP100");
selectWindow("noGP100");
close();
selectWindow("noGFP");
rename("noQuantMask");

imageCalculator("AND", "noQuantMask","tissueMask");
imageCalculator("XOR", "tissueMask","noQuantMask");	// keep in tissueMask just the region to analyze
selectWindow("noQuantMask");
close();


// MEASURE AREA OF ANALYSIS--
run("Clear Results");
selectWindow("tissueMask");
run("Create Selection");
roiManager("add");
run("Measure");
At=getResult("Area",0);
Atm=At*r*r;
run("Clear Results");

// DRAW TISSUE:
selectWindow("GFP");
run("Select None");
roiManager("Select", 1);
roiManager("Set Color", "red");
roiManager("Set Line Width", 5);
run("Flatten");
wait(100);
rename("GFP_toSave");
selectWindow("GP100");
run("Select None");
roiManager("Select", 1);
roiManager("Set Color", "red");
roiManager("Set Line Width", 5);
run("Flatten");
wait(100);
rename("GP100_toSave");


roiManager("Reset");

////////////////////////////////////
//--DETECT POSITIVE CELLS IN GFP
////////////////////////////////////

// SEPARATE STAINING CHANNELS--
selectWindow("GFP");
roiManager("Show None");
run("Select All");
showStatus("Deconvolving channels...");
run("Colour Deconvolution", "vectors=[H&E DAB] hide");
selectWindow("GFP-(Colour_2)");
close();
selectWindow("GFP-(Colour_1)");
rename("blue");
selectWindow("GFP-(Colour_3)");
rename("brown");

// DETECT BROWN STAINING
selectWindow("brown");
	//thGFP=90;
setThreshold(0, thGFP);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Close-");
run("Fill Holes");
run("Median...", "radius=1");
run("Analyze Particles...", "size=8-Infinity show=Masks in_situ");
//roiManager("Select", 0);
selectWindow("tissueMask");
run("Create Selection");
selectWindow("brown");
run("Restore Selection");
setBackgroundColor(255, 255, 255);
run("Clear Outside");
run("Select All");

// SEGMENT BLUE CELLS
selectWindow("blue");
run("Mean...", "radius=2");
   //thBlue = 120;
setThreshold(0, thBlue);
//waitForUser("Adjust threshold for cell segmentation and press OK when ready");
setOption("BlackBackground", false);
run("Convert to Mask");
//run("Fill Holes");
run("Median...", "radius=2");
run("Watershed");
selectWindow("tissueMask");
run("Create Selection");
selectWindow("blue");
run("Restore Selection");
setBackgroundColor(255, 255, 255);
run("Clear Outside");
run("Select All");
//run("Analyze Particles...", "size=10-10000 pixel show=Masks in_situ");
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
nCells=n;


// CHECK ONE BY ONE WHICH CELLS CONTAIN GFP

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
selectWindow("positCellMask");	// fill in cellMask only cells positive for GFP
  //minBrownPerc=80;
for (i=0; i<n; i++)
{
	Aperc=getResult("%Area",i);	
	if (Aperc>=minBrownPerc) {	
  		roiManager("Select", i);
		run("Fill", "slice");
  	}  	 	
}
run("Select None");
roiManager("Reset");
run("Analyze Particles...", "size=0-Infinity pixel show=Masks add in_situ");
nGFP=roiManager("Count");
run("Select None");

selectWindow("brown");
close();
selectWindow("cellMask");
close();
selectWindow("positCellMask");
rename("GFPposit");
run("Select None");
roiManager("Show None");


////////////////////////////////////
//--DETECT POSITIVE CELLS IN GP100
////////////////////////////////////

roiManager("reset");

// SEPARATE STAINING CHANNELS--
selectWindow("GP100");
roiManager("Show None");
run("Select All");
showStatus("Deconvolving channels...");
run("Colour Deconvolution", "vectors=[H&E DAB] hide");
selectWindow("GP100-(Colour_2)");
close();
selectWindow("GP100-(Colour_1)");
rename("blue");
selectWindow("GP100-(Colour_3)");
rename("brown");

// DETECT BROWN STAINING
selectWindow("brown");
	//thGP100=160;
setThreshold(0, thGP100);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Close-");
run("Fill Holes");
run("Median...", "radius=1");
run("Analyze Particles...", "size=8-Infinity show=Masks in_situ");
//roiManager("Select", 0);
selectWindow("tissueMask");
run("Create Selection");
selectWindow("brown");
run("Restore Selection");
setBackgroundColor(255, 255, 255);
run("Clear Outside");
run("Select All");

// SEGMENT BLUE CELLS
selectWindow("blue");
run("Mean...", "radius=2");
   //thBlue = 120;
setThreshold(0, thBlue);
//waitForUser("Adjust threshold for cell segmentation and press OK when ready");
setOption("BlackBackground", false);
run("Convert to Mask");
//run("Fill Holes");
run("Median...", "radius=2");
run("Watershed");
selectWindow("tissueMask");
run("Create Selection");
selectWindow("blue");
run("Restore Selection");
setBackgroundColor(255, 255, 255);
run("Clear Outside");
run("Select All");
//run("Analyze Particles...", "size=10-10000 pixel show=Masks in_situ");
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
nCells=n;


// CHECK ONE BY ONE WHICH CELLS CONTAIN GP100

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
selectWindow("positCellMask");	// fill in cellMask only cells positive for GFP
  //minBrownPerc=80;
for (i=0; i<n; i++)
{
	Aperc=getResult("%Area",i);	
	if (Aperc>=minBrownPerc) {	
  		roiManager("Select", i);
		run("Fill", "slice");
  	}  	 	
}
run("Select None");
roiManager("Reset");
run("Analyze Particles...", "size=0-Infinity pixel show=Masks add in_situ");
nGP100=roiManager("Count");
run("Select None");

selectWindow("brown");
close();
selectWindow("cellMask");
close();
selectWindow("positCellMask");
rename("GP100posit");
run("Select None");
roiManager("Show None");


////////////////////////////////////////////////////////
//--Check one by one which GFP+ cells are also GP100+
////////////////////////////////////////////////////////

selectWindow("GFPposit");
roiManager("reset");
run("Analyze Particles...", "size=0-Infinity pixel show=Masks add in_situ");
n = roiManager("count");

run("Duplicate...", "title=positCellMask");
run("Select All");
setBackgroundColor(255, 255, 255);
run("Clear", "slice");
wait(100);

run("Clear Results");
selectWindow("GP100posit");
run("Select None");
roiManager("Deselect");
roiManager("Measure");
selectWindow("positCellMask");	// fill in cellMask only cells positive for GFP
  //minColocPerc=30;
for (i=0; i<n; i++)
{
	Aperc=getResult("%Area",i);	
	if (Aperc>=minColocPerc) {	
  		roiManager("Select", i);
		run("Fill", "slice");
  	}  	 	
}
run("Select None");
roiManager("Reset");
run("Analyze Particles...", "size=0-Infinity pixel show=Masks add in_situ");
nDouble=roiManager("Count");
run("Select None");

selectWindow("positCellMask");
rename("DoublePosit");
run("Select None");
roiManager("Show None");



//--Write results:
run("Clear Results");
if(File.exists(output+File.separator+"Quantification_GFP_GP100.xls"))
{	
	//if exists add and modify
	open(output+File.separator+"Quantification_GFP_GP100.xls");
	IJ.renameResults("Results");
}
i=nResults;
setResult("Label", i, MyTitle); 
setResult("Area of tissue analyzed (um2)", i, Atm); 
setResult("# GFP+ cells", i, nGFP);
setResult("# GP100+ cells", i, nGP100);
setResult("# GFP+/GP100+ cells", i, nDouble);
saveAs("Results", output+File.separator+"Quantification_GFP_GP100.xls");


//--DRAW GFP:

selectWindow("GFP_toSave");

// Draw GFP+ cells
selectWindow("GFPposit");
run("Select None");
run("Create Selection");
selectWindow("GFP_toSave");
run("Restore Selection");
roiManager("Set Color", "green");
roiManager("Set Line Width", 3);
run("Flatten");
wait(100);

// Draw GFP+/GP100+ cells
if(nDouble!=0) { 
selectWindow("DoublePosit");
run("Select None");
run("Create Selection");
selectWindow("GFP_toSave-1");
run("Restore Selection");
roiManager("Set Color", "yellow");
roiManager("Set Line Width", 3);
}
run("Flatten");
wait(200);

saveAs("Jpeg", OutDir+File.separator+"GFP_"+subject+"_analyzed.jpg");
rename("GFP_"+subject+"_analyzed.jpg");

selectWindow("GFP_toSave");
close();
selectWindow("GFP_toSave-1");
close();
selectWindow("GFPposit");
close();
selectWindow("DoublePosit");
close();


//--DRAW GP100:

selectWindow("GP100_toSave");

// Draw GP100+ cells
selectWindow("GP100posit");
run("Select None");
run("Create Selection");
selectWindow("GP100_toSave");
run("Restore Selection");
roiManager("Set Color", "green");
roiManager("Set Line Width", 3);
run("Flatten");
wait(100);

saveAs("Jpeg", OutDir+File.separator+"GP100_"+subject+"_analyzed.jpg");
rename("GP100_"+subject+"_analyzed.jpg");

selectWindow("GP100_toSave");
close();
selectWindow("GP100posit");
close();

selectWindow("GP100");
close();
selectWindow("GFP");
close();
selectWindow("tissueMask");
close();

setTool("zoom");

setBatchMode(false);

if (InDir!="-") {
close();
close(); }

//showMessage("Done!");

}






