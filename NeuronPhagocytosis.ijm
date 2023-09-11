// changelog July 2021
// manual selection of analysis regions
// automatic green and red signal detection in 3D
// red-green 3D colocalization quantification

var cGreen=2, cRed=1, thGreen=50, thRed=50, minSizeGreen=20, minSizeRed=20;		

macro "QIF Action Tool 1 - Cf00T2d15IT6d10m"{
	
	run("Close All");
	
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	print("Processing "+name);
	
	Dialog.create("Parameters for the analysis");
	// Channels:
	Dialog.addMessage("Choose channel numbers")	
	Dialog.addNumber("Green marker", cGreen);	
	Dialog.addNumber("Red marker", cRed);
	// Segmentation:
	Dialog.addMessage("Choose analysis parameters")		
	Dialog.addNumber("Green threshold", thGreen);	
	Dialog.addNumber("Red threshold", thRed);
	Dialog.addNumber("Min green particle size (px)", minSizeGreen);	
	Dialog.addNumber("Min red particle size (px)", minSizeRed);	
	Dialog.show();	
	cGreen= Dialog.getNumber();
	cRed= Dialog.getNumber();
	thGreen= Dialog.getNumber();
	thRed= Dialog.getNumber();
	minSizeGreen= Dialog.getNumber();
	minSizeRed= Dialog.getNumber();	
	
	//setBatchMode(true);
	qif("-","-",name,cGreen,cRed,thGreen,thRed,minSizeGreen,minSizeRed);
	setBatchMode(false);
	showMessage("Quantification finished!");

}

macro "QIF Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	run("Close All");
	
	InDir=getDirectory("Choose Tiles' directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("Parameters for the analysis");
	// Channels:
	Dialog.addMessage("Choose channel numbers")	
	Dialog.addNumber("Green marker", cGreen);	
	Dialog.addNumber("Red marker", cRed);
	// Segmentation:
	Dialog.addMessage("Choose analysis parameters")		
	Dialog.addNumber("Green threshold", thGreen);	
	Dialog.addNumber("Red threshold", thRed);
	Dialog.addNumber("Min green particle size (px)", minSizeGreen);	
	Dialog.addNumber("Min red particle size (px)", minSizeRed);	
	Dialog.show();	
	cGreen= Dialog.getNumber();
	cRed= Dialog.getNumber();
	thGreen= Dialog.getNumber();
	thRed= Dialog.getNumber();
	minSizeGreen= Dialog.getNumber();
	minSizeRed= Dialog.getNumber();	
	
	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"czi")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print("Processing "+name);
			//setBatchMode(true);
			qif(InDir,InDir,list[j],cGreen,cRed,thGreen,thRed,minSizeGreen,minSizeRed);
			setBatchMode(false);
			}
	}
	
	showMessage("Quantification finished!");

}


function qif(output,InDir,name,cGreen,cRed,thGreen,thRed,minSizeGreen,minSizeRed)
{

run("Close All");

if (InDir=="-") {
	run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
	}
else {
	run("Bio-Formats Importer", "open=["+InDir+name+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
	}	


Stack.setDisplayMode("composite");

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
rename("orig");


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
run("Median...", "radius=1 stack");
//run("Analyze Particles...", "size=10-Infinity pixel show=Masks in_situ stack");
run("Analyze Particles...", "size="+minSizeGreen+"-Infinity pixel show=Masks in_situ stack");

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
roiManager("Save", OutDir+"ROI_"+MyTitle_short+"_Green.zip");
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
run("Analyze Particles...", "size="+minSizeRed+"-Infinity pixel show=Masks in_situ stack");

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
roiManager("Save", OutDir+"ROI_"+MyTitle_short+"_Red.zip");
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
roiManager("Open", OutDir+"ROI_"+MyTitle_short+"_Green.zip");
roiManager("Open", OutDir+"ROI_"+MyTitle_short+"_Red.zip");
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
roiManager("Save", OutDir+"ROI_"+MyTitle_short+"_GreenRedColoc.zip");
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
roiManager("Open", OutDir+"ROI_"+MyTitle_short+"_Green.zip");
roiManager("Open", OutDir+"ROI_"+MyTitle_short+"_Red.zip");
roiManager("Open", OutDir+"ROI_"+MyTitle_short+"_GreenRedColoc.zip");
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
if(File.exists(output+File.separator+"Results.xls"))
{
	//if exists add and modify
	open(output+File.separator+"Results.xls");
	IJ.renameResults("Results");
}
i=nResults;
setResult("Label", i, MyTitle); 
setResult("Green-marker volume ("+unit+"^3)", i, Vg);
setResult("Red-marker volume ("+unit+"^3)", i, Vr);
setResult("Green-Red coloc volume ("+unit+"^3)", i, Vc); 
//setResult("Avg green intensity in coloc volume", i, IcgAvg);
//setResult("Avg red intensity in coloc volume", i, IcrAvg);				
saveAs("Results", output+File.separator+"Results.xls");


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
saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
rename(MyTitle_short+"_analyzed.jpg");
wait(500);
if (InDir!="-") {
close(); }

selectWindow("green");
close();
selectWindow("greenMask");
close();
selectWindow("red");
close();
selectWindow("redMask");
close();
selectWindow("imageToSave");
close();
selectWindow("imageToSave-1");
close();
selectWindow("imageToSave-2");
close();
selectWindow("orig");
close();

//Clear unused memory
wait(500);
run("Collect Garbage");


}




