// 2022 June
// Possibility of selecting the analysis region or deleting regions manually

var r=0.502, thTissue=236, thH=155, thE=150, minNecrosisSize=8000, borderWidth=150;	

macro "Necrosis Action Tool 1 - Cf0fT0c11NT8c11eTec11c"{

//--Parameters for the analysis

Dialog.create("Parameters for the analysis");
Dialog.addMessage("Choose parameters")	
Dialog.addNumber("Ratio micra/pixel", r);		
Dialog.addNumber("Threshold for tissue segmentation", thTissue);
	labels = newArray(2);
	labels[0] = "Use haematoxylin";
	labels[1] = "Use eosin";
	defaults = newArray(2);
	defaults[0] = true;
	defaults[1] = true;
Dialog.addCheckboxGroup(1, 2, labels, defaults);
Dialog.addNumber("Threshold for haematoxylin segmentation", thH); 
Dialog.addNumber("Threshold for eosin segmentation", thE); 
Dialog.addNumber("Min necrosis size (px)", minNecrosisSize);	
Dialog.addNumber("Tissue border width (px)", borderWidth);	
Dialog.show();	

r= Dialog.getNumber();
thTissue= Dialog.getNumber();
useH = Dialog.getCheckbox();
useE = Dialog.getCheckbox();
thH= Dialog.getNumber();
thE= Dialog.getNumber(); 		
minNecrosisSize= Dialog.getNumber(); 		
borderWidth= Dialog.getNumber(); 

	
roiManager("Reset");
run("Clear Results");
MyTitle=getTitle();
output=getInfo("image.directory");

OutDir = output+File.separator+"AnalyzedImages";
File.makeDirectory(OutDir);

aa = split(MyTitle,".");
MyTitle_short = aa[0];

//setBatchMode(true);
run("Colors...", "foreground=white background=black selection=green");

rename("orig");

//--Correct background by using the mode for contrast adjustment previously balancing the three RGB channels

setBatchMode(true);
run("Set Measurements...", "area mean modal redirect=None decimal=2");
run("Split Channels");
// Get modes:
selectWindow("orig (red)");
run("Measure");
selectWindow("orig (green)");
run("Measure");
selectWindow("orig (blue)");
run("Measure");
modRGB = newArray(3);
modRGB[0] = getResult("Mode", 0);
modRGB[1] = getResult("Mode", 1);
modRGB[2] = getResult("Mode", 2);
// Balance RGB channels:
Array.getStatistics(modRGB, min, max, mean, stdDev);
difR = max-modRGB[0];
difG = max-modRGB[1];
difB = max-modRGB[2];
selectWindow("orig (red)");
run("Add...", "value="+difR);
selectWindow("orig (green)");
run("Add...", "value="+difG);
selectWindow("orig (blue)");
run("Add...", "value="+difB);
// Merge and perform white balance:
run("Merge Channels...", "c1=[orig (red)] c2=[orig (green)] c3=[orig (blue)]");
rename("orig");
if(max>200) {
	setMinAndMax(0, max);
	run("Apply LUT");
}
run("Clear Results");
setBatchMode(false);


//--DETECT TISSUE

selectWindow("orig");
setBatchMode(true);
run("Select All");
showStatus("Detecting tissue...");
run("RGB to Luminance");
rename("a");
	//thTissue=236;
setThreshold(0, thTissue);
run("Convert to Mask");
run("Median...", "radius=8");
run("Options...", "iterations=3 count=1 do=Close");
run("Mean...", "radius=6");
setThreshold(126, 255);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Options...", "iterations=3 count=1 do=Open");
run("Analyze Particles...", "size=400000-Infinity pixel show=Masks exclude in_situ");
run("Invert");
run("Analyze Particles...", "size=1000-Infinity show=Masks in_situ");
run("Invert");
//run("Fill Holes");
run("Create Selection");
roiManager("Add");	// ROI0 --> tissue area
selectWindow("a");
close();


//--Possibility of manually deleting detected regions

setBatchMode(false);
selectWindow("orig");
roiManager("select", 0);
q=getBoolean("Would you like to manually delete a tissue region?");
while(q) {
	setTool("freehand");
	waitForUser("Delete a tissue region to delete and press OK");
	roiManager("Add");
	roiManager("Deselect");
	roiManager("Select", newArray(0,1));
	roiManager("AND");
	roiManager("Add");
	roiManager("Deselect");
	roiManager("Select", newArray(0,2));
	roiManager("XOR");
	roiManager("Add");
	roiManager("Deselect");
	roiManager("Select", newArray(0,1,2));
	roiManager("Delete");
	roiManager("select", 0);
	q=getBoolean("Would you like to manually delete another tissue region?");
}


//--NECROSIS


selectWindow("orig");
run("Colour Deconvolution", "vectors=[H&E 2] hide");
//selectWindow(MyTitle+"-(Colour_3)");
selectWindow("orig-(Colour_3)");
close();
selectWindow("orig-(Colour_1)");
rename("H");
selectWindow("orig-(Colour_2)");
rename("E");

//--Process haematoxylin

if(useH) {
	selectWindow("H");
	wait(50);
	run("Mean...", "radius=16");
	  //thH=155;
	setThreshold(thH, 245);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	selectWindow("H");
	run("Options...", "iterations=3 count=1 do=Close");
	//run("Analyze Particles...", "size=6000-Infinity show=Masks in_situ");
	run("Analyze Particles...", "size="+minNecrosisSize+"-Infinity show=Masks in_situ");
	run("Invert");
	run("Analyze Particles...", "size=600-Infinity show=Masks in_situ");
	run("Invert");
	roiManager("Select", 0);
	  //borderWidth=150;
	run("Enlarge...", "enlarge=-"+borderWidth);
	setBackgroundColor(255, 255, 255);
	run("Clear Outside");
	//run("Analyze Particles...", "size=6000-Infinity show=Masks in_situ");
	run("Analyze Particles...", "size="+minNecrosisSize+"-Infinity show=Masks in_situ");
	run("Create Selection");
	roiManager("Add");	// ROI1 --> necrosis area from haematoxylin
	close();
}
else {
	selectWindow("H");
	makeRectangle(1, 1, 1, 1);
	roiManager("Add");
	close();	
}


//--Process eosin

if(useE) {
	selectWindow("E");
	wait(50);
	run("Mean...", "radius=16");
	  //thE=150;
	setThreshold(0, thE);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	selectWindow("E");
	run("Options...", "iterations=3 count=1 do=Close");
	//run("Analyze Particles...", "size=6000-Infinity show=Masks in_situ");
	run("Analyze Particles...", "size="+minNecrosisSize+"-Infinity show=Masks in_situ");
	run("Invert");
	run("Analyze Particles...", "size=600-Infinity show=Masks in_situ");
	run("Invert");
	roiManager("Select", 0);
	  //borderWidth=150;
	run("Enlarge...", "enlarge=-"+borderWidth);
	setBackgroundColor(255, 255, 255);
	run("Clear Outside");
	//run("Analyze Particles...", "size=6000-Infinity show=Masks in_situ");
	run("Analyze Particles...", "size="+minNecrosisSize+"-Infinity show=Masks in_situ");
	run("Create Selection");
	roiManager("Add");	// ROI2 --> necrosis area from eosin
	close();
}
else {
	selectWindow("E");
	makeRectangle(1, 1, 1, 1);
	roiManager("Add");
	close();	
}

//--Combine both masks

roiManager("Deselect");
roiManager("Select", newArray(1,2));
roiManager("Combine");
roiManager("Add");	// ROI3 --> necrosis area from combined masks


//--Possibility of manually deleting detected regions

selectWindow("orig");
roiManager("select", 3);
q=getBoolean("Would you like to manually delete a region detected as necrotic?");
while(q) {
	setTool("freehand");
	waitForUser("Select a region to delete and press OK");
	type=selectionType();
	if(type!=-1) {		
		roiManager("Add");
		roiManager("Deselect");
		roiManager("Select", newArray(3,4));
		roiManager("AND");
		roiManager("Add");
		roiManager("Deselect");
		roiManager("Select", newArray(3,5));
		roiManager("XOR");
		roiManager("Add");
		roiManager("Deselect");
		roiManager("Select", newArray(3,4,5));
		roiManager("Delete");
	}
	roiManager("select", 3);
	q=getBoolean("Would you like to manually delete another necrotic region?");
}


//--Possibility of manually adding necrotic regions

selectWindow("orig");
roiManager("select", 3);
q=getBoolean("Would you like to manually add a region as necrotic?");
while(q) {
	setTool("freehand");
	waitForUser("Select a region to add and press OK");
	type=selectionType();
	if(type!=-1) {		
		roiManager("Add");
		roiManager("Deselect");
		roiManager("Select", newArray(3,4));
		roiManager("Combine");
		roiManager("Add");
		roiManager("Deselect");		
		roiManager("Select", newArray(3,4));
		roiManager("Delete");
	}
	roiManager("select", 3);
	q=getBoolean("Would you like to manually add another necrotic region?");	
}



// RESULTS--

run("Clear Results");
selectWindow("orig");
run("Select None");
run("Set Measurements...", "area redirect=None decimal=2");

// Tissue
roiManager("select", 0);
roiManager("Measure");
At=getResult("Area",0);
//in micra
Atm=At*r*r;

// Necrosis
roiManager("select", 3);
roiManager("Measure");
An=getResult("Area",1);
//in micra
Anm=An*r*r;

// Ratio
r1=Anm/Atm*100;

run("Clear Results");
if(File.exists(output+File.separator+"NecrosisQuantification.xls"))
{	
	//if exists add and modify
	open(output+File.separator+"NecrosisQuantification.xls");
	IJ.renameResults("Results");
}
i=nResults;
setResult("Label", i, MyTitle); 
setResult("Tissue area (um2)",i,Atm);
setResult("Necrosis area (um2)",i,Anm);
setResult("Ratio Anecrosis/Atissue (%)",i,r1);			
saveAs("Results", output+File.separator+"NecrosisQuantification.xls");
	

setBatchMode(false);
selectWindow("orig");
roiManager("Show None");
roiManager("Select", 0);
roiManager("Set Color", "red");
roiManager("Set Line Width", 5);
run("Flatten");
selectWindow("orig-1");
roiManager("Show None");
roiManager("Select", 3);
roiManager("Set Color", "green");
roiManager("Set Line Width", 5);
run("Flatten");
saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
rename(MyTitle_short+"_analyzed.jpg");

selectWindow("orig");
close();
setTool("zoom");
selectWindow("orig-1");
close();

showMessage("Done!");

}


