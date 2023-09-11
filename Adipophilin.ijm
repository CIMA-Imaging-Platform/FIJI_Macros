//changelog November 2022
//manual selection of ROI to analyze
//manual ellimination of ROI inside selected region

var r=0.502, thTissue=233, thBrown=120;	

macro "BrownDetection Action Tool 1 - Ca50T0d15ATad15d"{
	
run("Close All");

name=File.openDialog("Select image file");
open(name);
wait(100);	

Dialog.create("Parameters for the analysis");
Dialog.addMessage("Choose parameters")
Dialog.addNumber("micra/px ratio", r);
Dialog.addNumber("Threshold for tissue detection", thTissue); 
Dialog.addNumber("Threshold for adipophilin detection", thBrown);  
Dialog.show();
r= Dialog.getNumber();
thTissue= Dialog.getNumber();
thBrown= Dialog.getNumber();     


roiManager("Reset");
run("Clear Results");
MyTitle=getTitle();
output=getInfo("image.directory");

OutDir = output+File.separator+"AnalyzedImages";
File.makeDirectory(OutDir);

aa = split(MyTitle,".");
MyTitle_short = aa[0];

setBatchMode(true);
run("Colors...", "foreground=black background=white selection=green");

rename("orig");

//--MANUALLY SELECT AREA OF INTEREST

setTool("freehand");
waitForUser("Please, select the dermis and press ok when ready");
type = selectionType();
  if (type==-1)	//if there is no selection, select the whole image
      run("Select All");
run("Add to Manager");	// ROI0 --> area of dermis


//--DETECT TISSUE
run("Select All");
setBatchMode(true);
showStatus("Detecting tissue...");
run("RGB to Luminance");
rename("a");
//setAutoThreshold("Huang");
//getThreshold(lower, upper);
	//thTissue=233;
setThreshold(0, thTissue);
run("Convert to Mask");
run("Median...", "radius=6");
run("Analyze Particles...", "size=500-Infinity pixel show=Masks in_situ");
run("Invert");
run("Analyze Particles...", "size=500-Infinity pixel show=Masks in_situ");
run("Invert");
roiManager("Select", 0);	
setBackgroundColor(255,255,255);
run("Clear Outside");
run("Select All");
run("Create Selection");
type = selectionType();
  if (type==-1) {	//if there is no selection, select one pixel
      makeRectangle(1,1,1,1);
  }
run("Add to Manager");	// ROI1 --> tissue in ROI0
selectWindow("a");
close();

setBatchMode(false);


//BROWN--

run("Colour Deconvolution", "vectors=[H&E DAB] hide");
//selectWindow(MyTitle+"-(Colour_3)");
selectWindow("orig-(Colour_2)");
close();
selectWindow("orig-(Colour_1)");
close();
selectWindow("orig-(Colour_3)");
rename("brown");

	//thBrown=120;
setThreshold(0, thBrown);
setOption("BlackBackground", false);
run("Convert to Mask");
//run("Median...", "radius=1");
run("Analyze Particles...", "size=5-Infinity show=Masks in_situ");
roiManager("Select", 1);	
setBackgroundColor(255,255,255);
run("Clear Outside");
run("Select All");
run("Create Selection");
type = selectionType();
  if (type==-1) {	//if there is no selection, select one pixel
      makeRectangle(2,2,1,1);
  }


//--Possibility of deleting positive signal regions

selectWindow("orig");
run("Restore Selection");
setTool("zoom");
q=getBoolean("Look at the detected regions of adipophilin. Do you want to elliminate a stained area?");
while(q){
	setTool("freehand");
	waitForUser("Please, select an area to elliminate and press ok when ready");
	selectWindow("orig");
	type=selectionType();
	if(type!=-1) {
		selectWindow("brown");
		run("Restore Selection");
		run("Clear", "slice");
		run("Create Selection");
		type = selectionType();
		if (type==-1) {	//if there is no selection, select one pixel
		  makeRectangle(2,2,1,1);
		}
		selectWindow("orig");
		run("Restore Selection");		
	}
	setTool("zoom");
	q=getBoolean("Do you want to elliminate another stained area?");	
}

selectWindow("brown");
run("Create Selection");
type = selectionType();
if (type==-1) {	//if there is no selection, select one pixel
  makeRectangle(2,2,1,1);
}
run("Add to Manager");	// ROI2 --> Adipofilin regions

selectWindow("brown");
close();	


// RESULTS--

run("Clear Results");
selectWindow("orig");	
run("Set Measurements...", "area redirect=None decimal=2");

// Tissue
roiManager("select", 1);
roiManager("Measure");
At=getResult("Area",0);
//in micra
Atm=At*r*r;

// Staining
roiManager("select", 2);
roiManager("Measure");
Ap=getResult("Area",1);
//in micra
Apm=Ap*r*r;

// Ratio
r1=Apm/Atm*100;

run("Clear Results");
if(File.exists(output+File.separator+"QuantificationResults.xls"))
{
	
	//if exists add and modify
	open(output+File.separator+"QuantificationResults.xls");
	IJ.renameResults("Results");
}
i=nResults;
setResult("Label", i, MyTitle); 
setResult("Tissue area (um2)",i,Atm);
setResult("Adipophilin area (um2)",i,Apm);
setResult("Ratio Aadipo/Atissue (%)",i,r1);			
saveAs("Results", output+File.separator+"QuantificationResults.xls");
	

//--DRAW

selectWindow("orig");
roiManager("Show None");
roiManager("Select", 1);
roiManager("Set Color", "red");
roiManager("Set Line Width", 2);
run("Flatten");
roiManager("Show None");
roiManager("Select", 2);
roiManager("Set Color", "green");
roiManager("Set Line Width", 2);
run("Flatten");
saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
rename(MyTitle_short+"_analyzed.jpg");

setTool("zoom");
selectWindow("orig");
close();
selectWindow("orig-1");
close();

showMessage("Done!");

}



