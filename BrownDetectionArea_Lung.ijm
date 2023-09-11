// Changelog June 2021
// Automatic tissue detection adapted for muscle

var r=0.502, th_tissue=245, th_brown=160, minSize=10;	

macro "BrownDetection Action Tool 1 - Cf00T2d15IT6d10m"{
	//just one file
	name=File.openDialog("Select File");
	print("Processing "+name);

	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Choose parameters")	
    Dialog.addNumber("micra/px ratio", r);
    Dialog.addNumber("Threshold for tissue detection", th_tissue); 
    Dialog.addNumber("Threshold for brown detection", th_brown);  
    Dialog.addNumber("Min size of stained particles (px)", minSize);  
    Dialog.show();
    r= Dialog.getNumber();
    th_tissue= Dialog.getNumber();
    th_brown= Dialog.getNumber();  
    minSize= Dialog.getNumber();  
    
	//setBatchMode(true);
	browndetection("-","-",name,r,th_tissue,th_brown,minSize);
	setBatchMode(false);
	showMessage("Done!");

}

macro "BrownDetection Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	InDir=getDirectory("Choose a Directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Choose parameters")	
    Dialog.addNumber("micra/px ratio", r);
    Dialog.addNumber("Threshold for tissue detection", th_tissue); 
    Dialog.addNumber("Threshold for brown detection", th_brown);  
    Dialog.addNumber("Min size of stained particles (px)", minSize);  
    Dialog.show();
    r= Dialog.getNumber();
    th_tissue= Dialog.getNumber();
    th_brown= Dialog.getNumber();  
    minSize= Dialog.getNumber(); 

	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"jpg")||endsWith(list[j],"tif")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print(name);
			//setBatchMode(true);
			browndetection(InDir,InDir,list[j],r,th_tissue,th_brown,minSize);
			setBatchMode(false);
			}
	}
	showMessage("Done!");
}


function browndetection(output,InDir,name,r,th_tissue,th_brown,minSize)
{
	
	if (InDir=="-") {open(name);}
	else {
		if (isOpen(InDir+name)) {}
		else { open(InDir+name); }
	}

	
	//getDimensions(width, height, channels, slices, frames);

roiManager("Reset");
run("Clear Results");
MyTitle=getTitle();
output=getInfo("image.directory");

OutDir = output+File.separator+"AnalyzedImages";
File.makeDirectory(OutDir);

setBatchMode(true);
run("Colors...", "foreground=white background=black selection=green");

// Mode subtraction for background correction:
run("Set Measurements...", "area mean modal redirect=None decimal=2");
run("Measure");
mod = getResult("Mode", 0);
dif = 255-mod;
run("Add...", "value=16");
run("Clear Results");

// DETECT TISSUE
run("Select All");
showStatus("Detecting tissue...");
run("RGB to Luminance");
rename("a");
run("Threshold...");
//setAutoThreshold("Huang");
//getThreshold(lower, upper);
	//th_tissue=245;
setThreshold(0, th_tissue);
run("Convert to Mask");
run("Median...", "radius=6");
run("Close-");
run("Invert");
run("Open");
run("Analyze Particles...", "size=100-Infinity pixel show=Masks in_situ");
run("Invert");
//run("Analyze Particles...", "size=50000-Infinity pixel show=Masks in_situ");
//run("Fill Holes");
run("Create Selection");
run("Add to Manager");	// ROI0 --> whole tissue
selectWindow("a");
close();



//BROWN--

flagBrown=false;

run("Colour Deconvolution", "vectors=[H&E DAB] hide");
//selectWindow(MyTitle+"-(Colour_3)");
selectWindow(MyTitle+"-(Colour_2)");
close();
selectWindow(MyTitle+"-(Colour_1)");
close();
selectWindow(MyTitle+"-(Colour_3)");

run("Threshold...");
setAutoThreshold("Default");
	//th_brown=160;
setThreshold(0, th_brown);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Median...", "radius=1");
//run("Analyze Particles...", "size=10-Infinity show=Masks in_situ");
run("Analyze Particles...", "size="+minSize+"-Infinity show=Masks in_situ");
roiManager("Show None");
run("Create Selection");
type=selectionType();
if(type==-1) {
	makeRectangle(1, 1, 1, 1);
	flagBrown=true;
}
run("Add to Manager");	// ROI1 --> Whole brown
close();

// Save just brown in tissue
roiManager("Deselect");
roiManager("Select", 0);
roiManager("Select", newArray(0,1));
roiManager("AND");
type=selectionType();
if(type==-1) {
	makeRectangle(1, 1, 1, 1);
	flagBrown=true;
}
roiManager("Add");
roiManager("Deselect");
roiManager("Select", 1);
roiManager("Delete");

// RESULTS--

run("Clear Results");
selectWindow(MyTitle);	
run("Set Measurements...", "area redirect=None decimal=2");

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
//in micra
Apm=Ap*r*r;

if (flagBrown) {
	Apm=0;
}

// Ratio
r1=Apm/Atm*100;

run("Clear Results");
if(File.exists(output+File.separator+"Total.xls"))
{
	//if exists add and modify
	open(output+File.separator+"Total.xls");
	IJ.renameResults("Results");
}
i=nResults;
setResult("Label", i, MyTitle); 
setResult("Tissue area (micra²)",i,Atm);
setResult("Stained area (micra²)",i,Apm);
setResult("Ratio Astained/Atissue (%)",i,r1);			
saveAs("Results", output+File.separator+"Total.xls");


aa = split(MyTitle,".");
MyTitle_short = aa[0];

setBatchMode(false);
selectWindow(MyTitle);
rename("orig");

roiManager("Show None");
roiManager("Select", 0);
roiManager("Set Color", "yellow");
roiManager("Set Line Width", 1);
run("Flatten");
roiManager("Show None");
roiManager("Select", 1);
roiManager("Set Color", "green");
roiManager("Set Line Width", 1);
run("Flatten");
saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
rename(MyTitle_short+"_analyzed.jpg");

selectWindow("Threshold");
run("Close");
selectWindow("orig");
close();
setTool("zoom");
selectWindow("orig-1");
close();

if (InDir!="-") {
close(); }

//showMessage("Done!");

}

