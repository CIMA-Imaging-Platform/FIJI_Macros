// changelog March 2020
// manual selection of analysis regions
// automatic green and red signal detection in 3D
// red-green 3D colocalization quantification

var cDAPI=1, cGreen=3, cRed=2, thGreen=30, thRed=50, minProtSize=10, minRNAsize=20, maxRNAsize=500;		


macro "IFcoloc3D Action Tool 1 - C00fT2d15IT6d10m"{
	
// open just one file
name=File.openDialog("Select File");	
run("Bio-Formats", "open=["+name+"] autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT");

Stack.setDisplayMode("composite");
Stack.setChannel(cGreen);
run("Green");

run("Colors...", "foreground=black background=white selection=yellow");
Stack.getDimensions(width, height, channels, slices, frames);

roiManager("Reset");
run("Clear Results");
MyTitle=getTitle();
output=getInfo("image.directory");

OutDir = output+File.separator+"AnalyzedImages/";
File.makeDirectory(OutDir);

aa = split(MyTitle,".");
MyTitle_short = aa[0];

getVoxelSize(rx, ry, rz, unit);

selectWindow(MyTitle);
run("RGB Color", "slices keep");
rename("temp");
wait(100);
run("Z Project...", "projection=[Sum Slices]");
rename("Projection");

selectWindow("temp");
close();
selectWindow("Projection");
setTool("rectangle");

showMessage("Initialization complete! You can now analyze colocalization in specific regions of the image")

}


macro "IFcoloc3D Action Tool 2 - Cf00T0d13CT9d10oTfd10l"{


//roiManager("Reset");
//check if we have a selection
type = selectionType();
  if (type==-1)	{
	showMessage("No cell has been selected. No analysis will be performed.");
	exit();}
roiManager("Add");	// ROI N --> CELL SELECTION IN WHOLE IMAGE
//run("Duplicate...", "title=orig");
n=roiManager("count");	// current ROI analysis number

roiname="R"+n;
//print(roiname);
n=n-1;

if(isOpen("Projection")){
	selectWindow("Projection");
	close();		
}


run("Clear Results");
MyTitle=getTitle();
output=getInfo("image.directory");

OutDir = output+File.separator+"AnalyzedImages/";
//File.makeDirectory(OutDir);

aa = split(MyTitle,".");
MyTitle_short = aa[0];

getVoxelSize(rx, ry, rz, unit);
Stack.getDimensions(width, height, channels, slices, frames);

selectWindow(MyTitle);
run("RGB Color", "slices keep");
rename("temp");
wait(100);
run("Z Project...", "projection=[Sum Slices]");
rename("Projection");

selectWindow("temp");
close();
selectWindow("Projection");


// CROP TO THE SELECTED REGION OF ANALYSIS
selectWindow(MyTitle);
run("Select None");
roiManager("Select", n);
run("Duplicate...", "title=orig duplicate");

roiManager("Save", OutDir+"ROIsAnalysis_"+MyTitle_short+".zip");


// DETECT GREEN--
selectWindow("orig");
run("Duplicate...", "title=green duplicate channels="+cGreen);
run("Subtract Background...", "rolling=20 stack");	
run("Duplicate...", "title=greenMask duplicate range=1-"+slices);
run("8-bit");
setAutoThreshold("Huang dark");
setThreshold(thGreen, 255);
//setThreshold(30, 255);
setOption("BlackBackground", false);
run("Convert to Mask", "method=Default background=Dark");
//run("Median...", "radius=1 stack");
//run("Analyze Particles...", "size=10-Infinity pixel show=Masks in_situ stack");
run("Analyze Particles...", "size="+minProtSize+"-Infinity pixel show=Masks in_situ stack");

// Save green signal ROIs:
roiManager("Reset");
flagGreen=newArray(slices);
Array.fill(flagGreen, 0); 
for (i=1;i<(slices+1);i++){
	setSlice(i);
	run("Create Selection");
	// Check if we have a selection for current slice, and draw a pixel if not
	type = selectionType();
	  if (type==-1)	{
		makeRectangle(2,2,1,1);	
		flagGreen[i-1]=1;
	}
	run("Add to Manager");
}
roiManager("Save", OutDir+"ROI_"+MyTitle_short+"_"+roiname+"_Green.zip");
selectWindow("greenMask");
//close();
// Create a 2D mask projecting all the 3D selections:
roiManager("Deselect");
roiManager("Combine");
run("Create Mask");
rename("greenProjMask");



// DETECT RED--
selectWindow("orig");
run("Duplicate...", "title=red duplicate channels="+cRed);
run("Subtract Background...", "rolling=20 stack");	
run("Duplicate...", "title=redMask duplicate range=1-"+slices);
run("8-bit");
setAutoThreshold("Huang dark");
setThreshold(thRed, 255);
//setThreshold(50, 255);
run("Convert to Mask", "method=Default background=Dark");
run("Median...", "radius=1 stack");
//run("Analyze Particles...", "size=20-Infinity pixel show=Masks in_situ stack");
run("Analyze Particles...", "size="+minRNAsize+"-"+maxRNAsize+" pixel show=Masks in_situ stack");

// Save red signal ROIs:
roiManager("Reset");
flagRed=newArray(slices);
Array.fill(flagRed, 0); 
for (i=1;i<(slices+1);i++){
	setSlice(i);
	run("Create Selection");
	// Check if we have a selection for current slice, and draw a pixel if not
	type = selectionType();
	  if (type==-1)	{
		makeRectangle(3,3,1,1);	
		flagRed[i-1]=1;
	}
	run("Add to Manager");
}
roiManager("Save", OutDir+"ROI_"+MyTitle_short+"_"+roiname+"_Red.zip");
selectWindow("redMask");
//close();
// Create a 2D mask projecting all the 3D selections:
roiManager("Deselect");
roiManager("Combine");
run("Create Mask");
rename("redProjMask");


// GREEN-RED COLOCALIZATION
selectWindow("orig");
roiManager("Reset");
roiManager("Open", OutDir+"ROI_"+MyTitle_short+"_"+roiname+"_Green.zip");
roiManager("Open", OutDir+"ROI_"+MyTitle_short+"_"+roiname+"_Red.zip");
flagColoc=newArray(slices);
Array.fill(flagColoc, 0); 
for (i=1;i<(slices+1);i++){
	setSlice(i);
	roiManager("Deselect");
	roiManager("Select", 0);
	roiManager("select", newArray(0,slices-i+1));	
	roiManager("AND");
	// Check if we have a selection, and draw a pixel if not
	type = selectionType();
	  if (type==-1)	{
		makeRectangle(4,4,1,1);	
		flagColoc[i-1]=1;
	}
	roiManager("Add");	
	roiManager("Deselect");
	roiManager("Select", 0);
	roiManager("select", newArray(0,slices-i+1));
	roiManager("Delete");
}
roiManager("Save", OutDir+"ROI_"+MyTitle_short+"_"+roiname+"_GreenRedColoc.zip");
// Create a 2D mask projecting all the 3D selections:
roiManager("Deselect");
roiManager("Combine");
run("Create Mask");
rename("colocProjMask");


// MEASURE--
run("Clear Results");
run("Set Measurements...", "area mean redirect=None decimal=2");

// load ROIs
roiManager("Reset");
roiManager("Open", OutDir+"ROI_"+MyTitle_short+"_"+roiname+"_Green.zip");
roiManager("Open", OutDir+"ROI_"+MyTitle_short+"_"+roiname+"_Red.zip");
roiManager("Open", OutDir+"ROI_"+MyTitle_short+"_"+roiname+"_GreenRedColoc.zip");
// initialize variables
Ag=newArray(slices);
//Ig=newArray(slices);
Ar=newArray(slices);
//Ir=newArray(slices);
Ac=newArray(slices);
//Icg=newArray(slices);
//Icr=newArray(slices);
Agt=0;
Art=0;
Act=0;
// loop over slices
for (i=0;i<slices;i++){
	run("Clear Results");
	// Measure green
	selectWindow("green");
	roiManager("Select", i);
	roiManager("Measure");
	Ag[i]=getResult("Area",0);
	//Ig[i]=getResult("Mean",0);
	if (flagGreen[i]==1) {
		Ag[i]=0;
		//Ig[i]=0;
	}
	Agt=Agt+Ag[i];
	// Measure red
	selectWindow("red");
	roiManager("Select", i+slices);
	roiManager("Measure");
	Ar[i]=getResult("Area",1);
	//Ir[i]=getResult("Mean",1);
	if (flagRed[i]==1) {
		Ar[i]=0;
		//Ir[i]=0;
	}
	Art=Art+Ar[i];
	// Measure colocalization
	selectWindow("green");
	roiManager("Select", i+2*slices);
	roiManager("Measure");
	Ac[i]=getResult("Area",2);
	//Icg[i]=getResult("Mean",2);
	roiManager("Deselect");
	selectWindow("red");
	roiManager("Select", i+2*slices);
	roiManager("Measure");
	//Icr[i]=getResult("Mean",3);
	if (flagColoc[i]==1) {
		Ac[i]=0;
		//Icg[i]=0;
		//Icr[i]=0;
	}
	Act=Act+Ac[i];
}

// total green signal volume
Vg=Agt*rz;
// total red signal volume
Vr=Art*rz;
// total green-red colocalization volume
Vc=Act*rz;

/*// average green and red intensities in colocalization volume
IcgAvg = 0;
IcrAvg = 0;
for (i=0;i<slices;i++){
	IcgAvg = IcgAvg + Icg[i]*Ac[i]/Act;
	IcrAvg = IcrAvg + Icr[i]*Ac[i]/Act;
}*/

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
setResult("Region", i, roiname);
setResult("Protein volume ("+unit+"^3)", i, Vg);
setResult("RNA volume ("+unit+"^3)", i, Vr);
setResult("Prot-RNA coloc volume ("+unit+"^3)", i, Vc); 
//setResult("Avg green intensity in coloc volume", i, IcgAvg);
//setResult("Avg red intensity in coloc volume", i, IcrAvg);				
saveAs("Results", output+File.separator+"Total.xls");
	

selectWindow("orig");
run("RGB Color", "slices keep");
rename("temp");
wait(100);
run("Z Project...", "projection=[Sum Slices]");
rename("imageToSave");
selectWindow("temp");
close();

// Save 2D projection image of detected things:
selectWindow("imageToSave");
roiManager("Reset");
selectWindow("greenProjMask");
run("Create Selection");
run("Add to Manager");
close();
selectWindow("redProjMask");
run("Create Selection");
run("Add to Manager");
close();
selectWindow("colocProjMask");
run("Create Selection");
run("Add to Manager");
close();
selectWindow("imageToSave");
roiManager("Select", 0);
roiManager("Set Color", "green");
roiManager("Set Line Width", 1);
run("Flatten");
roiManager("Show None");
roiManager("Select", 1);
roiManager("Set Color", "red");
roiManager("Set Line Width", 1);
run("Flatten");
roiManager("Show None");
roiManager("Select", 2);
roiManager("Set Color", "yellow");
roiManager("Set Line Width", 1);
run("Flatten");
wait(500);
saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_"+roiname+"_analyzed.jpg");
//rename(MyTitle_short+"_analyzed.jpg");
wait(500);
close();

selectWindow("imageToSave");
close();
selectWindow("imageToSave-1");
close();
selectWindow("imageToSave-2");
close();
selectWindow("orig");
close();



// COLOC 2 PLUGIN

imageCalculator("OR create stack", "greenMask","redMask");
rename("coloc2mask");
run("Invert LUT");
selectWindow("greenMask");
close();
selectWindow("redMask");
close();

run("Coloc 2", "channel_1=green channel_2=red roi_or_mask=coloc2mask threshold_regression=Costes show_save_pdf_dialog display_images_in_result spearman's_rank_correlation manders'_correlation 2d_intensity_histogram psf=3 costes_randomisations=10");



//selectWindow("Threshold");
//run("Close");
selectWindow("green");
close();
selectWindow("red");
close();
selectWindow("coloc2mask");
close();


selectWindow(MyTitle);
roiManager("Reset");
roiManager("Open", OutDir+"ROIsAnalysis_"+MyTitle_short+".zip");
setTool("rectangle");
roiManager("Show All without labels");
roiManager("Show None");
roiManager("Show All");
roiManager("Show All with labels");

showMessage("Colocalization analysis finished!");

}

macro "IFcoloc3D Action Tool 1 Options" {
        Dialog.create("Parameters");

	Dialog.addMessage("Parameters for the analysis")	
	// Channels:
	Dialog.addMessage("Choose channel numbers")	
	Dialog.addNumber("DAPI", cDAPI);	
	Dialog.addNumber("Protein", cGreen);	
	Dialog.addNumber("RNA", cRed);
	// Segmentation:
	Dialog.addMessage("Choose segmentation parameters")		
	Dialog.addNumber("Protein threshold", thGreen);	
	Dialog.addNumber("RNA threshold", thRed);
	Dialog.addNumber("Min Protein particle size", minProtSize);	
	Dialog.addNumber("Min RNA particle size", minRNAsize);	
	Dialog.addNumber("Max RNA particle size", maxRNAsize);	
	Dialog.show();	
	cDAPI= Dialog.getNumber();
	cGreen= Dialog.getNumber();
	cRed= Dialog.getNumber();
	thGreen= Dialog.getNumber();
	thRed= Dialog.getNumber();
	minProtSize= Dialog.getNumber();
	minRNAsize= Dialog.getNumber();	
	maxRNAsize= Dialog.getNumber();
}

macro "IFcoloc3D Action Tool 2 Options" {
        Dialog.create("Parameters");

	Dialog.addMessage("Parameters for the analysis")	
	// Channels:
	Dialog.addMessage("Choose channel numbers")	
	Dialog.addNumber("DAPI", cDAPI);	
	Dialog.addNumber("Protein", cGreen);	
	Dialog.addNumber("RNA", cRed);
	// Segmentation:
	Dialog.addMessage("Choose segmentation parameters")		
	Dialog.addNumber("Protein threshold", thGreen);	
	Dialog.addNumber("RNA threshold", thRed);
	Dialog.addNumber("Min Protein particle size", minProtSize);	
	Dialog.addNumber("Min RNA particle size", minRNAsize);	
	Dialog.addNumber("Max RNA particle size", maxRNAsize);	
	Dialog.show();	
	cDAPI= Dialog.getNumber();
	cGreen= Dialog.getNumber();
	cRed= Dialog.getNumber();	
	thGreen= Dialog.getNumber();
	thRed= Dialog.getNumber();
	minProtSize= Dialog.getNumber();
	minRNAsize= Dialog.getNumber();	
	maxRNAsize= Dialog.getNumber();	
}



