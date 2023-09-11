// changelog November 2020
// Nuclei detection in dapi
// RNA+ cell detection using RNA channel
// RNA+ macrophage detection by finding RNA and macrophage membrane marker colocalization
// RNA+ virus cell detection by finding RNA and virus marker colocalization
// All types cell counting

var cDAPI=1, cRNA=3, cMacroph=4, cVirus=2, nuclEnlargement=2;

macro "RNA Action Tool 1 - Ca3fT0b10RT8b10NTfb10A"{


roiManager("Reset");
run("Clear Results");
MyTitle=getTitle();
output=getInfo("image.directory");

OutDir = output+File.separator+"AnalyzedImages";
File.makeDirectory(OutDir);

aa = split(MyTitle,".");
MyTitle_short = aa[0];

Dialog.create("Channels");
Dialog.addMessage("Choose channel numbers");	
Dialog.addNumber("DAPI", cDAPI);	
Dialog.addNumber("RNA", cRNA);	
Dialog.addNumber("Macrophages", cMacroph);
Dialog.addNumber("Virus", cVirus);
Dialog.addMessage("Choose nuclei enlargement for marker search");
Dialog.addNumber("Enlargement (microns)", nuclEnlargement);
Dialog.show();	
cDAPI= Dialog.getNumber();
cRNA= Dialog.getNumber();
cMacroph= Dialog.getNumber();
cVirus= Dialog.getNumber();
nuclEnlargement= Dialog.getNumber();


run("RGB Color");
rename("merge");

run("Colors...", "foreground=black background=white selection=green");
run("Set Measurements...", "area mean redirect=None decimal=2");

getDimensions(width, height, channels, slices, frames);

//setBatchMode(true);


// SEGMENT RNA SPOTS:

selectWindow(MyTitle);
run("Duplicate...", "title=RNA duplicate channels="+cRNA);
run("Subtract Background...", "rolling=10");
setAutoThreshold("Otsu dark");
setOption("BlackBackground", false);
run("Convert to Mask");
run("Analyze Particles...", "size=3-Infinity pixel show=Masks in_situ");
run("Create Selection");
run("Add to Manager");		// ROI0 --> Mask of RNA spots
//close();


// SEGMENT NUCLEI FROM DAPI:

selectWindow(MyTitle);
run("Duplicate...", "title=nucleiMask duplicate channels="+cDAPI);
run("Mean...", "radius=6");
run("Subtract Background...", "rolling=60");
//run("Find Maxima...", "noise=[10 ] output=[Single Points]");
run("Find Maxima...", "prominence=15 output=[Single Points]");
rename("blueMaxima");

selectWindow("nucleiMask");
setAutoThreshold("Otsu dark");
setThreshold(20,255);
run("Convert to Mask");
run("Median...", "radius=1");
run("Fill Holes");
run("Select All");
run("Analyze Particles...", "size=20-Infinity pixel show=Masks in_situ");

// Generate cellMask by enlarging the mask of nuclei
run("Duplicate...", "title=cellMask");
run("Create Selection");
run("Enlarge...", "enlarge="+nuclEnlargement);
setForegroundColor(0, 0, 0);
run("Fill", "slice");

selectWindow("blueMaxima");
run("Select None");
run("Restore Selection");
setBackgroundColor(255, 255, 255);
run("Clear Outside");
run("Select None");

selectWindow("cellMask")
run("Select All");;
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

n=roiManager("Count");
nCells=n-1;

// CHECK ONE BY ONE WHICH NUCLEI CONTAIN RNA SPOTS

selectWindow("cellMask");
run("Select All");
setBackgroundColor(255, 255, 255);
run("Clear", "slice");
wait(100);

run("Clear Results");
selectWindow("RNA");
run("Select None");
roiManager("Deselect");
roiManager("Measure");
selectWindow("cellMask");	// fill in cellMask only nuclei positive por RNA
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



// SEGMENT MACROPHAGE MEMBRANE MARKER:

selectWindow(MyTitle);
run("Select None");
run("Duplicate...", "title=Macroph duplicate channels="+cMacroph);
run("Subtract Background...", "rolling=30");
setAutoThreshold("Otsu dark");
setOption("BlackBackground", false);
run("Convert to Mask");
run("Median...", "radius=1");
run("Analyze Particles...", "size=3-Infinity pixel show=Masks in_situ");
run("Create Selection");
run("Add to Manager");		// ROI0 --> Mask of Macrophage marker
//close();

// Go back to the mask of RNA-positive cells
selectWindow("cellMask");
run("Analyze Particles...", "size=20-Infinity pixel show=Masks add in_situ");
roiManager("Show None");
run("Select None");
n=roiManager("Count");
nRNA=n-1;

// CHECK ONE BY ONE WHICH NUCLEI CONTAIN MACROPHAGE MARKER
selectWindow("cellMask");
run("Select All");
run("Duplicate...", "title=MacrophMask");
run("Select All");
setBackgroundColor(255, 255, 255);
run("Clear", "slice");
wait(100);

run("Clear Results");
selectWindow("Macroph");
run("Select None");
roiManager("Deselect");
roiManager("Measure");
selectWindow("MacrophMask");	// fill in cellMask only nuclei positive por Macrophage marker
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
run("Analyze Particles...", "size=20-Infinity pixel show=Masks add in_situ");
nMacroph=roiManager("Count");
run("Select None");
roiManager("Reset");run("Duplicate...", "title=nucleiEdges");


// SEGMENT VIRUS MARKER:

selectWindow(MyTitle);
run("Select None");
run("Duplicate...", "title=Virus duplicate channels="+cVirus);
run("Subtract Background...", "rolling=60");
setAutoThreshold("Otsu dark");
setOption("BlackBackground", false);
run("Convert to Mask");
run("Median...", "radius=1");
run("Analyze Particles...", "size=3-Infinity pixel show=Masks in_situ");
run("Create Selection");
run("Add to Manager");		// ROI0 --> Mask of Virus marker
//close();

// Go back to the nucleiMask and keep only RNA-positive cells' nuclei:
selectWindow("nucleiMask");
run("Select None");
imageCalculator("AND", "nucleiMask","cellMask");
run("Analyze Particles...", "size=20-Infinity pixel show=Masks add in_situ");
roiManager("Show None");
run("Select None");


// CHECK ONE BY ONE WHICH NUCLEI CONTAIN VIRUS MARKER
selectWindow("nucleiMask");
run("Select All");
run("Duplicate...", "title=VirusMask");
run("Select All");
setBackgroundColor(255, 255, 255);
run("Clear", "slice");
wait(100);

run("Clear Results");
selectWindow("Virus");
run("Select None");
roiManager("Deselect");
roiManager("Measure");
selectWindow("VirusMask");	// fill in cellMask only nuclei positive for Virus
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
run("Analyze Particles...", "size=20-Infinity pixel show=Masks add in_situ");
nVirus=roiManager("Count");
run("Select None");
roiManager("Reset");


// CHECK CELLS THAT HAVE BOTH THE VIRUS AND THE MACROPHAGE MARKERS

imageCalculator("AND create", "MacrophMask","VirusMask");
selectWindow("Result of MacrophMask");
rename("Macroph-Virus");
run("Analyze Particles...", "size=20-Infinity pixel show=Masks add in_situ");
roiManager("Show None");
run("Select None");
nMacrophVirus=roiManager("Count");


selectWindow("Virus");
close();
selectWindow(MyTitle);
close();
selectWindow("nucleiEdges");
close();
selectWindow("Macroph");
close();
selectWindow("cellMask");
close();
selectWindow("RNA");
close();


// RESULTS--

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
setResult("# Cells", i, nCells);
setResult("# RNA+ cells", i, nRNA);
setResult("# RNA+ macrophages", i, nMacroph); 
setResult("# RNA+ virus", i, nVirus); 
setResult("# RNA+ macrophage-virus", i, nMacrophVirus); 
saveAs("Results", output+File.separator+"QuantificationResults.xls");
	

// DRAW--

selectWindow("merge");
run("Select None");

selectWindow("nucleiMask");
run("Select None");
run("Find Maxima...", "noise=10 output=[Point Selection] light");
setTool("multipoint");
run("Point Tool...", "selection=Green cross=White marker=Small");
selectWindow("merge");
run("Restore Selection");
run("Flatten");
wait(200);

selectWindow("MacrophMask");
run("Select None");
imageCalculator("AND", "MacrophMask","nucleiMask");	// Keep only macrophage nuclei in the mask
run("Select None");
run("Find Maxima...", "noise=10 output=[Point Selection] light");
setTool("multipoint");
run("Point Tool...", "selection=Magenta cross=White marker=Small");
selectWindow("merge-1");
if (nMacroph!=0) {
	run("Restore Selection");
}
run("Flatten");
wait(200);

selectWindow("VirusMask");
run("Select None");
run("Find Maxima...", "noise=10 output=[Point Selection] light");
setTool("multipoint");
run("Point Tool...", "selection=Yellow cross=White marker=Small");
selectWindow("merge-2");
if (nVirus!=0) {
	run("Restore Selection");
}
run("Flatten");
wait(200);

selectWindow("Macroph-Virus");
run("Select None");
imageCalculator("AND", "Macroph-Virus","nucleiMask");	// Keep only macrophage nuclei in the mask
run("Select None");
run("Find Maxima...", "noise=10 output=[Point Selection] light");
setTool("multipoint");
run("Point Tool...", "selection=Red cross=White marker=Small");
selectWindow("merge-3");
if (nMacroph!=0) {
	run("Restore Selection");
}
run("Flatten");
wait(200);

saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
wait(100);
rename(MyTitle_short+"_analyzed.jpg");

selectWindow("merge");
close();
selectWindow("merge-1");
close();
selectWindow("merge-2");
close();
selectWindow("merge-3");
close();
selectWindow("Macroph-Virus");
close();
selectWindow("VirusMask");
close();
selectWindow("MacrophMask");
close();
selectWindow("nucleiMask");
close();



setTool("zoom");

showMessage("Done!");


}




