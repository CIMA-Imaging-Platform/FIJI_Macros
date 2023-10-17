// changelog January 2023
// automatic nuclei segmentation in 3D stack
// EGFP avg and total signal per nuclei
// Red channel not used

var thProjection=45, thNucl=40, cEpig=2, cDAPI=3;			

	
macro "MP14 Action Tool 1 - C00fT0b11DT9b09iTcb09r"{

	run("Close All");
	InDir=getDirectory("Choose a Directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("Channels");
	Dialog.addMessage("Choose channel numbers")			
	Dialog.addNumber("Epigenetic marker", cEpig);
	Dialog.addNumber("DAPI", cDAPI);	
	Dialog.addNumber("Projection threshold", thProjection);	
	Dialog.addNumber("Nuclei threshold", thNucl);		
	Dialog.show();		
	cEpig= Dialog.getNumber();
	cDAPI= Dialog.getNumber();
	thProjection= Dialog.getNumber();
	thNucl= Dialog.getNumber();		

	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"czi")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print(name);
			//setBatchMode(true);
			ifnuclcyto3d(InDir,InDir,list[j],cEpig,cDAPI,thProjection,thNucl);
			setBatchMode(false);
			}
	}
	showMessage("Done!");
		}


function ifnuclcyto3d(output,InDir,name,cEpig,cDAPI,thProjection,thNucl)
{
	
if (InDir=="-") {
	//open(name);
	run("Bio-Formats", "open=["+name+"] autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT");
	}
else {
	if (isOpen(InDir+name)) {}
	else { 
		//open(InDir+name);
		run("Bio-Formats", "open=["+InDir+name+"] autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT");
		}
}

Stack.setDisplayMode("composite");
Stack.setChannel(cEpig);	// cytoplasmic protein
run("Green");
Stack.setChannel(cDAPI);	// DAPI
run("Blue");

run("Colors...", "foreground=black background=white selection=red");
Stack.getDimensions(width, height, channels, slices, frames);

roiManager("Reset");
run("Clear Results");
MyTitle=getTitle();
output=getInfo("image.directory");

OutDir = output+File.separator+"AnalyzedImages";
File.makeDirectory(OutDir);

aa = split(MyTitle,".");
MyTitle_short = aa[0];

getVoxelSize(vxW, vxH, depth, unit);
//print(depth);
//print(vxW);


// BACKGROUND CORRECTION

selectWindow(MyTitle);
rename("orig");

/*
run("Split Channels");
// Cytoplasmic protein:
selectWindow("C"+cEpig+"-orig");
run("Subtract Background...", "rolling=50 stack");
rename("CytoPr");
// DAPI:
selectWindow("C"+cDAPI+"-orig");
run("Subtract Background...", "rolling=50 stack");
rename("DAPI");

// Re-order and merge channels:

run("Merge Channels...", "c1=CytoPr c2=DAPI create keep");
Stack.setDisplayMode("composite");
Stack.setChannel(cEpig);	// cytoplasmic protein
//run("Green");
Stack.setChannel(cDAPI);	// DAPI
run("Blue");
rename("orig");


// SET DISPLAY RANGES

Stack.setChannel(cEpig);
getMinAndMax(min1, max1);
setMinAndMax(min1, max1);

setBatchMode(true);

*/

// CREATE NUCLEI MASK IN THE 3D PROJECTION OF DAPI

selectWindow("orig");
run("Duplicate...", "title=dapi duplicate channels="+cDAPI);
run("8-bit");
run("Subtract Background...", "rolling=200 stack");
run("Z Project...", "projection=[Sum Slices]");
rename("projMask");
selectWindow("projMask");
run("8-bit");
	//thProjection=22;
setThreshold(thProjection, 255);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Median...", "radius=1");
run("Analyze Particles...", "size=10-Infinity show=Masks exclude in_situ");	// add projections as ROIs
run("Create Selection");
roiManager("add");



// CREATE NUCLEI MASK IN EVERY SLICE 
selectWindow("dapi");
//run("Duplicate...", "title=nucleiMask duplicate range=1-"+slices);
rename("nucleiMask");
run("8-bit");
   //thNucl=30;
setThreshold(thNucl, 255);
setOption("BlackBackground", false);
run("Convert to Mask", "method=Default background=Dark");
run("Median...", "radius=1 stack");
run("Close-", "stack");
run("Fill Holes", "stack");
/*	// erodeRad=1
run("Morphological Filters (3D)", "operation=Erosion element=Ball x-radius="+erodeRad+" y-radius="+erodeRad+" z-radius="+erodeRad);
selectWindow("nucleiMask");
close();
selectWindow("nucleiMask-Erosion");
rename("nucleiMask");
run("Invert", "stack");
*/
roiManager("Select", 0);
setBackgroundColor(255, 255, 255);
run("Clear Outside", "stack");
run("Select None");

// MEASURE VOLUMES AND INTENSITIES IN NUCLEI:

selectWindow("orig");
run("Duplicate...", "title=epigMark duplicate channels="+cEpig);
run("Subtract Background...", "rolling=100 stack");

run("Set Measurements...", "area mean redirect=None decimal=2");
	
// Nucleus:
selectWindow("nucleiMask");
run("Select None");	
getDimensions(width, height, channels, slices, frames);
Aacc=0;	
Iacc=0;
for (j=0;j<slices;j++){				
	run("Clear Results");
	selectWindow("nucleiMask");
	setSlice(j+1);
	run("Create Selection");
	type = selectionType();
  	if (type!=-1)
  	{
  		selectWindow("epigMark");
  		setSlice(j+1);
  		run("Restore Selection");
  		run("Measure");
  		Ai=getResult("Area",0);	
  		Ii=getResult("Mean",0);	  	  		
  		Aacc=Aacc+Ai;	
  		Iacc=Iacc+Ii*Ai;  		
  	}
}
Vnucl=Aacc*depth;	
Iavg=Iacc/Aacc;
selectWindow("nucleiMask");
close();
selectWindow("projMask");
close();
selectWindow("epigMark");
close();


// Write results:
run("Clear Results");
if(File.exists(output+File.separator+"Quantification_Global.xls"))
{	
	//if exists add and modify
	open(output+File.separator+"Quantification_Global.xls");
	IJ.renameResults("Results");
}
i=nResults;
setResult("Label", i, MyTitle); 
setResult("Total nuclear volume (um3)", i, Vnucl); 	
setResult("Iavg epig marker", i, Iavg);			
saveAs("Results", output+File.separator+"Quantification_Global.xls");


setBatchMode(false);

// DRAW:

selectWindow("orig");
run("RGB Color", "slices keep");
rename("temp");
run("Z Project...", "projection=[Sum Slices]");
rename("merge");
selectWindow("temp");
close();

selectWindow("merge");
roiManager("Select", 0);
roiManager("Set Color", "red");
roiManager("Set Line Width", 2);
run("Flatten");
wait(500);
saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed_Global.jpg");	
wait(500);
rename(MyTitle_short+"_analyzed_Global.jpg");

if (InDir!="-") {
close(); }

selectWindow("merge");
close();
selectWindow("orig");
close();

setTool("zoom");

}



macro "MP14 Action Tool 2 - Cf00T2d15IT6d10m"{

run("Close All");
//just one file
name=File.openDialog("Select File");
//print(name);

Dialog.create("Channels");
Dialog.addMessage("Choose channel numbers")			
Dialog.addNumber("Epigenetic marker", cEpig);
Dialog.addNumber("DAPI", cDAPI);	
Dialog.addNumber("Projection threshold", thProjection);	
Dialog.addNumber("Nuclei threshold", thNucl);		
Dialog.show();		
cEpig= Dialog.getNumber();
cDAPI= Dialog.getNumber();
thProjection= Dialog.getNumber();
thNucl= Dialog.getNumber();

run("Bio-Formats", "open=["+name+"] autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT");

Stack.setDisplayMode("composite");
Stack.setChannel(cEpig);	// cytoplasmic protein
run("Green");
Stack.setChannel(cDAPI);	// DAPI
run("Blue");

run("Colors...", "foreground=black background=white selection=red");
Stack.getDimensions(width, height, channels, slices, frames);

roiManager("Reset");
run("Clear Results");
MyTitle=getTitle();
output=getInfo("image.directory");

OutDir = output+File.separator+"AnalyzedImages";
File.makeDirectory(OutDir);

aa = split(MyTitle,".");
MyTitle_short = aa[0];

getVoxelSize(vxW, vxH, depth, unit);
//print(depth);
//print(vxW);


// BACKGROUND CORRECTION

selectWindow(MyTitle);
rename("orig");

//--Epigenetic marker
selectWindow("orig");
run("Duplicate...", "title=epigMark duplicate channels="+cEpig);
run("Subtract Background...", "rolling=100 stack");

run("Set Measurements...", "area mean redirect=None decimal=2");

// SELECT NUCLEUS IN THE PROJECTION

selectWindow("orig");
run("Duplicate...", "title=dapi duplicate channels="+cDAPI);
run("8-bit");
run("Subtract Background...", "rolling=200 stack");
run("Z Project...", "projection=[Sum Slices]");
rename("projMask");
selectWindow("projMask");
run("8-bit");

//--Loop for one or many cells to measure
q=true;
cc=1;
while(q) {
	selectWindow("projMask");
	setTool("freehand");
	waitForUser("Draw the contour of a cell to analyze and press OK");
	type=selectionType();
	if(type!=-1) {
		roiManager("add");
		selectWindow("orig");
		roiManager("Select", 0);
		waitForUser("Go to the initial slice of the cell and press OK");
		initSl = getSliceNumber();
		waitForUser("Go to the final slice of the cell and press OK");
		endSl = getSliceNumber();

		//--Get dapi
		selectWindow("dapi");
		roiManager("Select", 0);
		run("Duplicate...", "title=cellDapi duplicate range="+initSl+"-"+endSl);
		roiManager("add");
		run("Select None");
		//--Get epigenetic marker
		selectWindow("epigMark");
		roiManager("Select", 0);
		run("Duplicate...", "title=cellEpig duplicate range="+initSl+"-"+endSl);
		run("Select None");

		//--Segment nucleus
		selectWindow("cellDapi");
		   //thNucl=40;
		setThreshold(thNucl, 255);
		setOption("BlackBackground", false);
		run("Convert to Mask", "method=Default background=Dark");
		run("Median...", "radius=1 stack");
		run("Close-", "stack");
		run("Fill Holes", "stack");
		roiManager("Select", 1);
		setBackgroundColor(255, 255, 255);
		run("Clear Outside", "stack");
		run("Select None");

		//--Measure volume and intensity in selected nucleus

		selectWindow("cellDapi");
		run("Select None");	
		getDimensions(width, height, channels, slices, frames);
		Aacc=0;	
		Iacc=0;
		for (j=0;j<slices;j++){				
			run("Clear Results");
			selectWindow("cellDapi");
			setSlice(j+1);
			run("Create Selection");
			type = selectionType();
		  	if (type!=-1)
		  	{
		  		selectWindow("cellEpig");
		  		setSlice(j+1);
		  		run("Restore Selection");
		  		run("Measure");
		  		Ai=getResult("Area",0);	
		  		Ii=getResult("Mean",0);	  	  		
		  		Aacc=Aacc+Ai;	
		  		Iacc=Iacc+Ii*Ai;  		
		  	}
		}
		Vnucl=Aacc*depth;	
		Iavg=Iacc/Aacc;
		selectWindow("cellDapi");
		close();		
		selectWindow("cellEpig");
		close();


		// Write results:
		run("Clear Results");
		if(File.exists(output+File.separator+"Quantification_IndividualCells.xls"))
		{	
			//if exists add and modify
			open(output+File.separator+"Quantification_IndividualCells.xls");
			IJ.renameResults("Results");
		}
		i=nResults;
		setResult("Label", i, MyTitle); 
		setResult("Cell number", i, cc); 
		setResult("Nuclear volume (um3)", i, Vnucl); 	
		setResult("Iavg epig marker", i, Iavg);			
		saveAs("Results", output+File.separator+"Quantification_IndividualCells.xls");

		//--Update cell counter:
		cc++;

		roiManager("reset");
		selectWindow("orig");
		setTool("zoom");
		waitForUser("Check if there are more cells you would like to analyze in the image and press OK when ready");
		
	}

	q=getBoolean("Would you like to analyze another cell?");
	
}

run("Close All");
showMessage("Done!");

}


















