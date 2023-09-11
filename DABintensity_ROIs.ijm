// changelog February 2022
// Manual selection of areas for the analysis
// Background subtraction for white balance
// Threshold DAB signal and quantify average intensity of positive areas


var r=0.502, th_brown=240;	

macro "BrownDetection Action Tool 1 - Cf00T2d15IT6d10m"{


name=File.openDialog("Select File");
print(name);
	
open(name);

roiManager("Reset");
run("Clear Results");
MyTitle=getTitle();
output=getInfo("image.directory");

OutDir = output+File.separator+"AnalyzedImages";
File.makeDirectory(OutDir);

aa = split(MyTitle,".");
MyTitle_short = aa[0];

rename("orig");

setBatchMode(true);
run("Colors...", "foreground=white background=black selection=green");

//MANUALLY SELECT AREA OF INTEREST

setTool("freehand");
waitForUser("Please, select an area for the analysis and press ok when ready");
type = selectionType();
  if (type==-1)	//if there is no selection, select the whole image
      run("Select All");
run("Add to Manager");	// ROI0 --> area to quantify
q=getBoolean("Do you want to add more areas?");
while(q){
	waitForUser("Please, select an area to add and press ok when ready");
	roiManager("Add");
	roiManager("Deselect");
	roiManager("Select", newArray(0,1));
	roiManager("Combine");
	roiManager("Add");
	roiManager("Deselect");
	roiManager("Select", newArray(0,1));
	roiManager("Delete");
	roiManager("Select", 0);				
	q=getBoolean("Do you want to add more areas?");	
}


selectWindow("orig");
run("Select None");
run("Subtract Background...", "rolling=100 light");

//--DAB

run("Colour Deconvolution", "vectors=[H&E DAB] hide");
//selectWindow(MyTitle+"-(Colour_3)");
selectWindow("orig-(Colour_2)");
close();
selectWindow("orig-(Colour_1)");
close();
selectWindow("orig-(Colour_3)");
rename("brown");

run("Duplicate...", "title=brownMask");
setAutoThreshold("Default");
	//th_brown=150;
setThreshold(0, th_brown);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Median...", "radius=2");
run("Analyze Particles...", "size=30-Infinity show=Masks in_situ");
run("Create Selection");
flagNoBrown=false;
type=selectionType();
if(type==-1) {
	flagNoBrown=true;
	makeRectangle(1, 1, 1, 1);
}
run("Add to Manager");	// ROI1 --> DAB+ signal 
close();

// Save just brown in tissue
roiManager("Deselect");
roiManager("Select", 0);
roiManager("Select", newArray(0,1));
roiManager("AND");
type=selectionType();
if(type==-1) {
	flagNoBrown=true;
	makeRectangle(1, 1, 1, 1);
}
roiManager("Add");
roiManager("Deselect");
roiManager("Select", 1);
roiManager("Delete");

// RESULTS--

run("Clear Results");
selectWindow("brown");	
run("Invert");	// invert brown image for intensity measurements
run("Set Measurements...", "area mean redirect=None decimal=2");

// Tissue
roiManager("select", 0);
roiManager("Measure");
At=getResult("Area",0);
//in micra
Atm=At*r*r;

// Staining
roiManager("select", 1);
roiManager("Measure");
Ap=getResult("Area",1);
Iavg=getResult("Mean",1);
//in micra
Apm=Ap*r*r;
if(flagNoBrown) {
	Apm=0;
	Iavg=NaN;
}

run("Clear Results");
if(File.exists(output+File.separator+"Results.xls"))
{
	
	//if exists add and modify
	open(output+File.separator+"Results.xls");
	IJ.renameResults("Results");
}
i=nResults;
setResult("Label", i, MyTitle); 
setResult("Area of analysis (um2)",i,Atm);
setResult("DAB+ area (um2)",i,Apm);
setResult("DAB+ avg intensity",i,Iavg);			
saveAs("Results", output+File.separator+"Results.xls");

setBatchMode(false);

selectWindow("orig");
roiManager("Show None");
roiManager("Select", 0);
roiManager("Set Color", "yellow");
roiManager("Set Line Width", 2);
run("Flatten");
roiManager("Show None");
roiManager("Select", 1);
roiManager("Set Color", "green");
roiManager("Set Line Width", 2);
run("Flatten");
saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
rename(MyTitle_short+"_analyzed.jpg");

selectWindow("brown");
close();
selectWindow("orig");
close();
setTool("zoom");
selectWindow("orig-1");
close();

showMessage("Done!");

}


macro "BrownDetection Action Tool 1 Options" {
     Dialog.create("Parameters");

     Dialog.addMessage("Choose parameters")
     Dialog.addNumber("micra/px ratio", r);
     Dialog.addNumber("Threshold for brown detection", th_brown);  
     Dialog.show();
     
     r= Dialog.getNumber();
     th_brown= Dialog.getNumber();  
             
}
