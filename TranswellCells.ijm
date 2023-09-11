// changelog September 2022

var thTissue=235, thCells=135, minCellSize=140;	

macro "TranswellCells Action Tool 1 - Cf00T2d15IT6d10m"{
	//just one file
	name=File.openDialog("Select File");
	//print(name);
					//setBatchMode(true);
					print(name);
					transwellcells("-","-",name);
					setBatchMode(false);
					showMessage("Done!");

		}
macro "TranswellCells Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	InDir=getDirectory("Choose a Directory");
	list=getFileList(InDir);
	L=lengthOf(list);

			for (j=0; j<L; j++)
			{
				if(endsWith(list[j],"tif")||endsWith(list[j],"czi")){
					//analyze
					//d=InDir+list[j]t;
					name=list[j];
					print(name);
					//setBatchMode(true);
					transwellcells(InDir,InDir,list[j]);
					setBatchMode(false);
					}
			}
			showMessage("Done!");
		}


function transwellcells(output,InDir,name)
{
	
run("Close All");

if(endsWith(name,"czi")) {
	if (InDir=="-") {
		run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
		}
	else {
		run("Bio-Formats Importer", "open=["+InDir+name+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
		}	
}
else {
	if (InDir=="-") {
		open(name);
	}
	else {
		open(InDir+name); 
	}	
}
	
	//getDimensions(width, height, channels, slices, frames);

roiManager("Reset");
run("Clear Results");
MyTitle=getTitle();
output=getInfo("image.directory");

aa = split(MyTitle,".");
MyTitle_short = aa[0];

OutDir = output+File.separator+"AnalyzedImages";
File.makeDirectory(OutDir);

run("Colors...", "foreground=white background=black selection=green");
Stack.setDisplayMode("composite");

// Create RGB image to work with:
run("RGB Color");
rename("orig");
selectWindow(MyTitle);
close();


setBatchMode(true);

// DETECT TISSUE

run("Select All");
showStatus("Detecting tissue...");
run("RGB to Luminance");
rename("a");
/*
run("Threshold...");
//setAutoThreshold("Huang");
//getThreshold(lower, upper);
	//thTissue=235;
setThreshold(0, thTissue);
run("Convert to Mask");
run("Median...", "radius=12");
run("Analyze Particles...", "size=50000-Infinity pixel show=Masks in_situ");
run("Invert");
run("Analyze Particles...", "size=300-Infinity pixel show=Masks in_situ");
run("Invert");
run("Create Selection");
*/
run("Select All");
run("Add to Manager");	// ROI0 --> whole tissue
selectWindow("a");
close();


// SEGMENT CELLS--

run("Duplicate...", "title=cellMask");
run("8-bit");
run("Mean...", "radius=2");
  //setThreshold(0, 135);
setThreshold(0, thCells);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Median...", "radius=1");
//run("Analyze Particles...", "size=140-Infinity show=Masks in_situ");
run("Analyze Particles...", "size="+minCellSize+"-Infinity show=Masks in_situ");
run("Select None");
roiManager("Select", 0);
setBackgroundColor(255,255,255);
run("Clear Outside");
run("Create Selection");
run("Add to Manager");	// ROI1 --> Cells in tissue
close();


// RESULTS--

run("Clear Results");
selectWindow("orig");	
run("Set Measurements...", "area redirect=None decimal=2");

// Tissue
roiManager("select", 0);
roiManager("Measure");
At=getResult("Area",0);

// Cells
roiManager("select", 1);
roiManager("Measure");
Ap=getResult("Area",1);

// Ratio
r1=Ap/At*100;

run("Clear Results");
if(File.exists(output+File.separator+"QuantificationResults.xls"))
{
	
	//if exists add and modify
	open(output+File.separator+"QuantificationResults.xls");
	IJ.renameResults("Results");
}
i=nResults;
setResult("Label", i, MyTitle); 
setResult("Tissue area (um2)",i,At);
setResult("Cells area (um2)",i,Ap);
setResult("Ratio Acells/Atissue (%)",i,r1);			
saveAs("Results", output+File.separator+"QuantificationResults.xls");
	

// DRAW--

setBatchMode(false);
selectWindow("orig");
roiManager("Show None");
roiManager("Select", 0);
roiManager("Set Color", "red");
roiManager("Set Line Width", 2);
run("Flatten");
roiManager("Show None");
roiManager("Select", 1);
roiManager("Set Color", "green");
roiManager("Set Line Width", 2);
run("Flatten");
saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
rename(MyTitle_short+"_analyzed.jpg");

selectWindow("orig");
close();
setTool("zoom");
selectWindow("orig-1");
close();

if (InDir!="-") {
close(); }

//showMessage("Done!");

}

macro "TranswellCells Action Tool 1 Options" {
     Dialog.create("Parameters");

     Dialog.addMessage("Choose parameters")
     Dialog.addNumber("Threshold for tissue detection", thTissue); 
     Dialog.addNumber("Threshold for cell detection", thCells);  
     Dialog.addNumber("Minimum cell size (um2)", minCellSize);  
     Dialog.show();
     thTissue= Dialog.getNumber();
     thCells= Dialog.getNumber();  
     minCellSize= Dialog.getNumber();             
}

macro "TranswellCells Action Tool 2 Options" {
     Dialog.create("Parameters");

     Dialog.addMessage("Choose parameters")
     Dialog.addNumber("Threshold for tissue detection", thTissue); 
     Dialog.addNumber("Threshold for cell detection", thCells);  
     Dialog.addNumber("Minimum cell size (um2)", minCellSize);  
     Dialog.show();
     thTissue= Dialog.getNumber();
     thCells= Dialog.getNumber();  
     minCellSize= Dialog.getNumber();  
}
