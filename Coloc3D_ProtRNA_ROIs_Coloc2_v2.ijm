 /*
 * COLOCALIZATION 3D ProtRNA 
 * Target User:   
 *  
 *  Tests Images: 
 *    - Confocal: 2 channel images.  
 *    - 16 bit 1388x1040
 *    - Voxel size: 0.1024x0.1024x0.25 micron^3
 *    - Format .czi  
 *  
 *  GUI User Requierments:
 *    - manual selection of analysis regions
 *    - user must test the parameters
 *    
 *  Important Parameters:
 * 	  - channel order: cDAPI=1, cGreen=3, cRed=2, 
 * 	  - thresholds: thBlue=40, thGreen=30, thRed=50, 
 * 	  - particlesSize: minProtSize=10, minRNAsize=20, maxRNAsize=500;		
 * 
 *   2 Action tools:
 *    Im: File Selection. 
 *    Coloc: 
 *     - automatic green and red signal segmentation in 3D.
 *	   - red-green 3D colocalization quantification.
 * 	  
 *  version: 1.02 
 *  Author: Mikel Ariz  
 *  Commented by: Tomas Muñoz 
 *  Date : changelog March 2020
 *  
 */

//	MIT License
//	Copyright (c) 2023 Tomas Muñoz tmsantoro@unav.es
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.

function info(){
	scripttitle= "COLOCALIZATION Prot-RNA 3D";
	version= "1.02";
	date= "2022";
	
	//image1="../templateImages/cartilage.jpg";
	//descriptionActionsTools="
	
	showMessage("ImageJ Script", "<html>"
		+"<style>h{margin-top: 5px; margin-bottom: 5px;} p{margin: 0px;padding: 0px;} ol{margin-left: 20px;padding: 5px;} #list-style-3 {list-style-type: circle;.container {max-width: 1200px; margin: 0 auto; padding: 0px; }</style>"
	    +"<h1><font size=6 color=Teal href=https://cima.cun.es/en/research/technology-platforms/image-platforms>CIMA: Imaging Platform</h1>"
	    +"<h1><font size=5 color=Purple><i>Software Development Service</i></h1>"
	    +"<p><font size=2 color=Purple><i>ImageJ Macros</i></p>"
	    +"<h2><font size=3 color=black>"+scripttitle+"</h2>"
	    +"<p><font size=2>Modified by Tomas Mu&ntilde;oz Santoro</p>"
	    +"<p><font size=2>Version: "+version+" ("+date+")</p>"
	    +"<p><font size=2> contact tmsantoro@unav.es</p>" 
	    +"<p><font size=2> Available for use/modification/sharing under the "+"<p4><a href=https://opensource.org/licenses/MIT/>MIT License</a></p>"
	    +"<h2><font size=3 color=black>Developed for</h2>"
	    +"<p><font size=3  i>Input Images</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>  Confocal: 3 channel images. DAPI, Protein, RNA .</li><li>16 bit Images </li><li>Resolution: 0.1024x0.1024x0.25 micron^3</li<li>Format .czi</li></i></ul>"
	    +"<p><font size=3 i>Action tools (Buttons)</i></p>"
	    +"<ol><font size=2  i><li>Im : Single File Selection</li>"
	    +"<li> Coloc : Automatic Prot and RNA Signal segmentation and .</li></ol>"
	    +"<p><font size=3  i>Parameters (Right Click for each Button)</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>DAPI, Prot and RNA Channels Order </li>"
	    +"<li>DAPI, Prot and RNA Threshold: Signal Threshold, Higher Number means Less Area Segmented</li>"
	    +"<li>Min / Max Size : Size Filter</li></ul>"
	    +"<p><font size=3  i>Quantification Results (Excel) </i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>#Cells</li><li>Protein Volume [um^3]</li><li> RNA Volume [um^3]</li<li>Prot-RNA Coloc Volume [um^3]</li></i></ul>"
	    +"<h0><font size=5> </h0>"
	    +"");
	    
	  //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
	}
	

	
var cDAPI=1, cGreen=3, cRed=2, thBlue=40, thGreen=30, thRed=50, minProtSize=10, minRNAsize=20, maxRNAsize=500;		


macro "IFcoloc3D Action Tool 1 - C00fT2d15IT6d10m"{
	
info();

run("Close All");
	
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
setTool("freehand");

showMessage("Initialization complete! You can now analyze colocalization in specific regions of the image")

}


macro "IFcoloc3D Action Tool 2 - Cf00T0d13CT9d10oTfd10l"{

info();
selectWindow("Projection");
waitForUser("Please select an area of analysis and then press OK");
//check if we have a selection
type = selectionType();
if (type==-1)	{
	run("Select All");
}
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


// DETECT NUCLEI FROM DAPI--

selectWindow("orig");
type=selectionType();
if(type!=-1) {
	setBackgroundColor(0,0,0);
	run("Clear Outside");
}
run("Select All");
roiManager("Reset");
run("Duplicate...", "title=blue duplicate channels="+cDAPI);
run("Z Project...", "projection=[Sum Slices]");
rename("projectionDAPI");
run("8-bit");
waitForUser;
run("Mean...", "radius=2");
	//thBlue=40;
setThreshold(thBlue, 255);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Median...", "radius=2");
run("Open");
run("Fill Holes");
run("Adjustable Watershed", "tolerance=4");
run("Analyze Particles...", "size=8-Infinity show=Masks add in_situ");	// add projections as ROIs
nCells=roiManager("Count");
//print(nCells);

//Save image
selectWindow("orig");
run("RGB Color", "slices keep");
rename("temp");
wait(100);
run("Z Project...", "projection=[Sum Slices]");
rename("merge");
roiManager("Show All");
roiManager("Show None");
roiManager("Show All with Labels");
roiManager("Set Color", "white");
roiManager("Set Line Width", 2);
run("Labels...", "color=white font=20 show draw");
run("Flatten");
wait(500);
rename("imageToSave");
//saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
//wait(500);
//close();
//run("Labels...", "color=white font=12 show draw");

selectWindow("merge");
close();
selectWindow("temp");
close();

selectWindow("blue");
run("8-bit");
waitForUser;
run("Mean...", "radius=2");
	//thBlue=40;
setThreshold(thBlue, 255);
setOption("BlackBackground", false);
run("Convert to Mask", "method=Default background=Dark");
run("Median...", "radius=2 stack");
run("Close-", "stack");
run("Fill Holes", "stack");
roiManager("Combine");
setBackgroundColor(255,255,255);
run("Clear Outside", "stack");
run("Select None");
run("Analyze Particles...", "size=10-Infinity pixel show=Masks in_situ stack");
selectWindow("blue");
rename("nucleiMask3D");

// DETECT PROTEIN -- GREEN-- 
selectWindow("orig");
run("Duplicate...", "title=green duplicate channels="+cGreen);
run("Subtract Background...", "rolling=20 stack");	
run("Duplicate...", "title=greenMask duplicate range=1-"+slices);
run("8-bit");
waitForUser;
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
	// check the nuclei mask in 3D for current slice
	selectWindow("nucleiMask3D");
	setSlice(i);
	run("Create Selection");
	type = selectionType();
	if (type==-1)	{
	  	makeRectangle(1,1,1,1);	
	}
	// clear any green signal outside the nuclei mask for current slice
	selectWindow("greenMask");
	setSlice(i);
	run("Restore Selection");
	setBackgroundColor(255,255,255);
	run("Clear Outside", "slice");
	run("Select None");
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


// DETECT RNA -- RED--
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
	// check the nuclei mask in 3D for current slice
	selectWindow("nucleiMask3D");
	setSlice(i);
	run("Create Selection");
	type = selectionType();
	if (type==-1)	{
	  	makeRectangle(1,1,1,1);	
	}
	// clear any red signal outside the nuclei mask for current slice
	selectWindow("redMask");
	setSlice(i);
	run("Restore Selection");
	setBackgroundColor(255,255,255);
	run("Clear Outside", "slice");
	run("Select None");
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


// PROTEIN - RNA -- GREEN-RED COLOCALIZATION
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
if(File.exists(output+File.separator+"QuantificationResults.xls"))
{	
	//if exists add and modify
	open(output+File.separator+"QuantificationResults.xls");
	IJ.renameResults("Results");
}
i=nResults;
setResult("Label", i, MyTitle); 
setResult("Region", i, roiname);
setResult("# cells analyzed", i, nCells); 
setResult("Protein volume ("+unit+"^3)", i, Vg);
setResult("RNA volume ("+unit+"^3)", i, Vr);
setResult("Prot-RNA coloc volume ("+unit+"^3)", i, Vc); 
//setResult("Avg green intensity in coloc volume", i, IcgAvg);
//setResult("Avg red intensity in coloc volume", i, IcrAvg);				
saveAs("Results", output+File.separator+"QuantificationResults.xls");
	

selectWindow("projectionDAPI");
close();
selectWindow("nucleiMask3D");
close();

waitForUser;

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
rename(MyTitle_short+"_"+roiname+"_analyzed.jpg");
wait(500);
//close();


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

selectWindow(MyTitle_short+"_"+roiname+"_analyzed.jpg");
setTool("freehand");

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
	Dialog.addNumber("DAPI threshold", thBlue);	
	Dialog.addNumber("Protein threshold", thGreen);	
	Dialog.addNumber("RNA threshold", thRed);
	Dialog.addNumber("Min Protein particle size", minProtSize);	
	Dialog.addNumber("Min RNA particle size", minRNAsize);	
	Dialog.addNumber("Max RNA particle size", maxRNAsize);	
	Dialog.show();	
	cDAPI= Dialog.getNumber();
	cGreen= Dialog.getNumber();
	cRed= Dialog.getNumber();
	thBlue= Dialog.getNumber();
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
	Dialog.addNumber("DAPI threshold", thBlue);	
	Dialog.addNumber("Protein threshold", thGreen);	
	Dialog.addNumber("RNA threshold", thRed);
	Dialog.addNumber("Min Protein particle size", minProtSize);	
	Dialog.addNumber("Min RNA particle size", minRNAsize);	
	Dialog.addNumber("Max RNA particle size", maxRNAsize);	
	Dialog.show();	
	cDAPI= Dialog.getNumber();
	cGreen= Dialog.getNumber();
	cRed= Dialog.getNumber();
	thBlue= Dialog.getNumber();
	thGreen= Dialog.getNumber();
	thRed= Dialog.getNumber();
	minProtSize= Dialog.getNumber();
	minRNAsize= Dialog.getNumber();	
	maxRNAsize= Dialog.getNumber();
}



