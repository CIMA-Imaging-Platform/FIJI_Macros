// changelog November2021
// manual selection of cell to analyze
// manual selection of Z-slices to project
// measurement of 2D aspect ratio of the nucleus


var cDAPI=4, thBlue=80;		

macro "AspectRatio Action Tool 1 - Ca3fT0b11AT8b11R"{


Dialog.create("Parameters");
Dialog.addMessage("Choose parameters")
Dialog.addNumber("DAPI channel", cDAPI);
Dialog.addNumber("Threshold for DAPI", thBlue);
Dialog.show();
cDAPI= Dialog.getNumber();
thBlue= Dialog.getNumber();


Stack.setDisplayMode("composite");

run("Set Measurements...", "area mean perimeter fit shape redirect=None decimal=2");
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

// SELECT CELL TO ANALYZE

setTool("freehand");
Stack.setSlice(round(slices/2));
run("Channels Tool...");
getSelectionBounds(x, y, w, h);
if(w==width){
	waitForUser("Please select a cell to analyze and press ok when ready");
}
wait(200);
waitForUser("Go to the first slice of the cell and press OK");
Stack.getPosition(ch1, sl1, fr1);
waitForUser("Go to the last slice of the cell and press OK");
Stack.getPosition(ch2, sl2, fr2);

// Create stack cropped to selection:
run("Duplicate...", "title=nucl duplicate channels="+cDAPI+" slices="+sl1+"-"+sl2);
run("Select None");


// DETECT NUCLEUS FROM DAPI IN 2D PROJECTION--
selectWindow("nucl");
run("Z Project...", "projection=[Average Intensity]");
rename("nuclProj");
run("8-bit");
run("Duplicate...", "title=nuclMask");
setAutoThreshold("Huang dark");
	//thBlue=80;
setThreshold(thBlue, 255);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Median...", "radius=1");
run("Fill Holes");
run("Keep Largest Region");
rename("result");
selectWindow("nuclMask");
close();

// QUANTIFY ASPECT RATIO AND SAVE FITTED ELLIPSE--
selectWindow("result");
run("Create Selection");
roiManager("Add");
run("Measure");
AspRat = getResult("AR", 0);
run("Fit Ellipse");
roiManager("Add");

// QUANTIFY NUCLEUS VOLUME IN 3D--
selectWindow("nucl");
run("8-bit");
  //thBlue=80;
setThreshold(thBlue, 255);
setOption("BlackBackground", false);
run("Convert to Mask", "method=Default background=Dark");
run("Median...", "radius=1 stack");
run("Fill Holes", "stack");
run("Keep Largest Region");
selectWindow("nucl");
close();
selectWindow("nucl-largest");
rename("nucl");
run("Clear Results");
run("Create Selection");
run("Select None");
run("Statistics");
V=getResult("Voxels",0);
getVoxelSize(vx, vy, vz, unit);
Vm=V*vx*vy*vz;
close();


// Write results:
run("Clear Results");
if(File.exists(output+File.separator+"AspectRatios.xls"))
{		
	//if exists add and modify
	open(output+File.separator+"AspectRatios.xls");
	IJ.renameResults("Results");
}
i=nResults;
setResult("Label", i, MyTitle); 
setResult("Aspect Ratio", i, AspRat);
setResult("Nuclear volume ("+unit+"^3)", i, Vm);
saveAs("Results", output+File.separator+"AspectRatios.xls");


// DRAW--
selectWindow("nuclProj");
run("Select None");
rename("img");
roiManager("Show None");
roiManager("Select", 0);
roiManager("Set Color", "green");
roiManager("Set Line Width", 1);
run("Flatten");
roiManager("Show None");
roiManager("Select", 1);
roiManager("Set Color", "yellow");
roiManager("Set Line Width", 1);
run("Flatten");
wait(200);
saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_nuclAspRat.jpg");
rename(MyTitle_short+"_nuclAspRat.jpg");


selectWindow("result");
close();
selectWindow("img");
close();
selectWindow("img-1");
close();

setTool("zoom");
selectWindow(MyTitle);
run("Select None");
selectWindow(MyTitle_short+"_nuclAspRat.jpg");

showMessage("Done!");

}

