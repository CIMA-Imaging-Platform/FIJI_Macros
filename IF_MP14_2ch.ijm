// changelog September 2022
// automatic cell segmentation in 3D stack
// automatic nuclei segmentation in 3D stack
// volume and intensity measurements for 1 cytoplasmic protein

var thProjection=22, thCell=20, thNucl=40, cCytoPr=1, cDAPI=2;			

macro "MP14 Action Tool 1 - Cf00T2d15IT6d10m"{

	run("Close All");
	//just one file
	name=File.openDialog("Select File");
	//print(name);
 	
 	Dialog.create("Channels");
	Dialog.addMessage("Choose channel numbers")		
	Dialog.addNumber("Cytoplasmic protein", cCytoPr);
	Dialog.addNumber("DAPI", cDAPI);		
	Dialog.show();		
	cCytoPr= Dialog.getNumber();
	cDAPI= Dialog.getNumber();
	
	//setBatchMode(true);
	print(name);
	ifnuclcyto3d("-","-",name,cCytoPr,cDAPI);
	setBatchMode(false);
	showMessage("Done!");

		}
		
macro "MP14 Action Tool 2 - C00fT0b11DT9b09iTcb09r"{

	run("Close All");
	InDir=getDirectory("Choose a Directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("Channels");
	Dialog.addMessage("Choose channel numbers")			
	Dialog.addNumber("Cytoplasmic protein", cCytoPr);
	Dialog.addNumber("DAPI", cDAPI);		
	Dialog.show();		
	cCytoPr= Dialog.getNumber();
	cDAPI= Dialog.getNumber();

	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"czi")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print(name);
			//setBatchMode(true);
			ifnuclcyto3d(InDir,InDir,list[j],cCytoPr,cDAPI);
			setBatchMode(false);
			}
	}
	showMessage("Done!");
		}


function ifnuclcyto3d(output,InDir,name,cCytoPr,cDAPI)
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
Stack.setChannel(cCytoPr);	// cytoplasmic protein
//run("Green");
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
run("Split Channels");
// Cytoplasmic protein:
selectWindow("C"+cCytoPr+"-orig");
run("Subtract Background...", "rolling=50 stack");
rename("CytoPr");
// DAPI:
selectWindow("C"+cDAPI+"-orig");
run("Subtract Background...", "rolling=50 stack");
rename("DAPI");

// Re-order and merge channels:

run("Merge Channels...", "c1=CytoPr c2=DAPI create keep");
Stack.setDisplayMode("composite");
Stack.setChannel(cCytoPr);	// cytoplasmic protein
//run("Green");
Stack.setChannel(cDAPI);	// DAPI
run("Blue");
rename("orig");


// SET DISPLAY RANGES

Stack.setChannel(cCytoPr);
getMinAndMax(min1, max1);
setMinAndMax(min1, max1);

setBatchMode(true);


// CREATE CELL MASK IN THE 3D PROJECTION

selectWindow("orig");
run("RGB Color", "slices keep");
run("8-bit");
rename("temp");
run("Z Project...", "projection=[Sum Slices]");
rename("projection");
selectWindow("projection");
run("8-bit");
	//thProjection=22;
setThreshold(thProjection, 255);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Median...", "radius=1");
run("Analyze Particles...", "size=60-Infinity show=Masks exclude in_situ");	// add projections as ROIs
selectWindow("temp");
close();

// USE NUCLEI TO CALCULATE SEEDS:
selectWindow("DAPI");
run("Z Project...", "projection=[Sum Slices]");
rename("DAPIprojection");
run("8-bit");
	//thProjection=22;
setThreshold(thProjection, 255);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Median...", "radius=1");
run("Watershed");
run("Analyze Particles...", "size=8-Infinity show=Masks in_situ");
run("Find Maxima...", "noise=10 output=[Point Selection] light");
run("Create Mask");

selectWindow("projection");
run("Duplicate...", "title=projection_edges");
run("Find Edges");

// MARKER-CONTROLLED WATERSHED
run("Marker-controlled Watershed", "input=projection_edges marker=Mask mask=projection binary calculate use");

selectWindow("projection_edges-watershed");
run("8-bit");
setThreshold(1, 255);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Analyze Particles...", "size=0-Infinity show=Masks add in_situ");
nCells=roiManager("Count");
close();
selectWindow("projection_edges");
close();
selectWindow("projection");
close();
selectWindow("Mask");
close();
selectWindow("DAPIprojection");
close();


// CREATE CELL MASK IN EVERY SLICE FROM THE TWO CHANNELS
selectWindow("orig");
run("RGB Color", "slices keep");
run("8-bit");
rename("cellMask");
run("Threshold...");
setAutoThreshold("Huang dark");
//setThreshold(5, 255);
   //thCell=20;
setThreshold(thCell, 255);
setOption("BlackBackground", false);
run("Convert to Mask", "method=Default background=Dark");
run("Median...", "radius=2 stack");
run("Invert", "stack");
setThreshold(0, 128);
setOption("BlackBackground", false);
run("Convert to Mask", "method=Default background=Default");
run("Close-", "stack");
run("Fill Holes", "stack");
roiManager("Combine");
run("Clear Outside", "stack");
run("Select None");


// CREATE NUCLEI MASK IN EVERY SLICE 
selectWindow("DAPI");
//run("Duplicate...", "title=nucleiMask duplicate range=1-"+slices);
rename("nucleiMask");
run("8-bit");
run("Threshold...");
setAutoThreshold("Huang dark");
//setThreshold(5, 255);
   //thNucl=40;
setThreshold(thNucl, 255);
setOption("BlackBackground", false);
run("Convert to Mask", "method=Default background=Dark");
run("Median...", "radius=2 stack");
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
roiManager("Combine");
run("Clear Outside", "stack");
run("Select None");

// CREATE CYTOPLASM MASK IN EVERY SLICE
imageCalculator("XOR create stack", "nucleiMask","cellMask");
rename("cytoMask");
//run("Invert", "stack");	// cytoplasm en black, background in white


// MEASURE VOLUMES AND GREEN INTENSITIES IN NUCLEUS AND CYTOPLASM FOR EACH CELL:

run("Set Measurements...", "area mean perimeter fit shape redirect=None decimal=2");
Vcell=newArray(nCells);
Vnucl=newArray(nCells);
Vcyto=newArray(nCells);
IcytoPr=newArray(nCells);
Sph=newArray(nCells);
SurfAr=newArray(nCells);
rSV=newArray(nCells);
AspRat=newArray(nCells);
Roundness=newArray(nCells);
Circ=newArray(nCells);
Perim=newArray(nCells);
PerimEllip=newArray(nCells);
rPer=newArray(nCells);
for(i=0;i<nCells;i++) 
{
	
	// Whole cell 2D-projection:
	run("Clear Results");
	selectWindow("cellMask");
	roiManager("Deselect");
	roiManager("Select", i);
	run("Measure");
	AspRat[i]=getResult("AR",0);
	Roundness[i]=getResult("Round",0);
	Circ[i]=getResult("Circ.",0);
	Perim[i]=getResult("Perim.",0);
	run("Fit Ellipse");
	run("Measure");
	PerimEllip[i]=getResult("Perim.",1);
	// Ratio between real perimeter and adjusted ellipse perimeter:
	rPer[i] = Perim[i]/PerimEllip[i];
	
	// Whole cell:
	run("Clear Results");
	selectWindow("cellMask");
	run("Select None");
	run("Duplicate...", "title=aa duplicate range=1-"+slices);
	roiManager("Deselect");
	roiManager("Select", i);
	setBackgroundColor(255, 255, 255);
	run("Clear Outside", "stack");
	run("Select None");	
	run("Analyze Regions 3D", "volume surface_area mean_breadth sphericity surface_area_method=[Crofton (13 dirs.)] euler_connectivity=C26");
	//run("Particle Analysis 3D", "volume surface sphericity surface=[Crofton (13 dirs.)] euler=C26");
	selectWindow("aa-morpho");
	IJ.renameResults("Results");
	Sph[i]=getResult("Sphericity",0);
	SurfAr[i]=getResult("SurfaceArea",0);
	selectWindow("aa");
	close();
	
	// Nucleus:
	selectWindow("nucleiMask");
	run("Duplicate...", "title=aa duplicate range=1-"+slices);
	roiManager("Deselect");
	roiManager("Select", i);
	setBackgroundColor(255, 255, 255);
	run("Clear Outside", "stack");
	run("Select None");	
	Aacc=0;	
	for (j=0;j<slices;j++){				
		run("Clear Results");
		selectWindow("aa");
		setSlice(j+1);
		run("Create Selection");
		type = selectionType();
	  	if (type!=-1)
	  	{
	  		setSlice(j+1);
	  		run("Restore Selection");
	  		run("Measure");
	  		Ai=getResult("Area",0);	  		
	  		Aacc=Aacc+Ai;	  		
	  	}
	}
	Vnucl[i]=Aacc*depth;	
	selectWindow("aa");
	close();

	// Cytoplasm:
	selectWindow("cytoMask");
	run("Duplicate...", "title=aa duplicate range=1-"+slices);
	roiManager("Deselect");
	roiManager("Select", i);
	setBackgroundColor(255, 255, 255);
	run("Clear Outside", "stack");
	run("Select None");	
	Aacc=0;
	Iacc=0;
	for (j=0;j<slices;j++){				
		run("Clear Results");
		selectWindow("aa");
		setSlice(j+1);
		run("Create Selection");
		type = selectionType();
	  	if (type!=-1)
	  	{
	  		selectWindow("CytoPr");
	  		setSlice(j+1);
	  		run("Restore Selection");
	  		run("Measure");
	  		temp=getResult("Area",0);
	  		temp2=getResult("Mean",0);
	  		Aacc=Aacc+temp;
	  		Iacc=Iacc+temp2*temp;	// weigh each slice intensity with the area of the ROI
	  	}
	}
	Vcyto[i]=Aacc*depth;
	IcytoPr[i]=Iacc/Aacc;
	selectWindow("aa");
	close();

	Vcell[i] = Vnucl[i]+Vcyto[i];

	// Ratio Surface/Volume
	rSV[i] = SurfAr[i]/Vcell[i];
		
}

// Write results:
run("Clear Results");
if(File.exists(output+File.separator+"Total.xls"))
{	
	//if exists add and modify
	open(output+File.separator+"Total.xls");
	IJ.renameResults("Results");
}
for(j=0;j<nCells;j++){
	i=nResults;
	setResult("Label", i, MyTitle); 
	setResult("# Cell", i, j+1); 	
	setResult("Iavg cyto prot", i, IcytoPr[j]);
	setResult("Vol cell ("+unit+"^3)", i, Vcell[j]);
	setResult("Vol nucl ("+unit+"^3)", i, Vnucl[j]);
	setResult("Vol cyto ("+unit+"^3)", i, Vcyto[j]);
	setResult("Cell sphericity", i, Sph[j]);
	setResult("Cell surface area ("+unit+"^2)", i, SurfAr[j]);
	setResult("Ratio surface/volume", i, rSV[j]);
	setResult("2D-proj aspect ratio", i, AspRat[j]);
	setResult("2D-proj roundness", i, Roundness[j]);
	setResult("2D-proj circularity", i, Circ[j]);
	setResult("2D-proj perimeter", i, Perim[j]);
	setResult("2D-proj ellipse-perimeter", i, PerimEllip[j]);
	setResult("2D-proj Ratio perim/ellipPerim", i, rPer[j]);						 
}			
saveAs("Results", output+File.separator+"Total.xls");


setBatchMode(false);

// DRAW:
selectWindow("orig");
run("RGB Color", "slices keep");
rename("temp");
run("Z Project...", "projection=[Sum Slices]");
rename("merge");
selectWindow("temp");
close();

selectWindow("nucleiMask");
run("Z Project...", "projection=[Min Intensity]");
rename("nuclProj");
roiManager("Deselect");
roiManager("Combine");
run("Clear Outside");
run("Create Selection");
selectWindow("merge");
run("Restore Selection");
roiManager("Set Color", "yellow");
roiManager("Set Line Width", 1);
run("Flatten");
wait(500);

selectWindow("merge-1");
roiManager("Show All");
roiManager("Show None");
roiManager("Show All with Labels");
roiManager("Set Color", "red");
roiManager("Set Line Width", 1);
run("Flatten");

wait(500);
saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");	
wait(500);
rename(MyTitle_short+"_analyzed.jpg");

if (InDir!="-") {
close(); }

selectWindow("Threshold");
run("Close");
selectWindow("merge");
close();
selectWindow("merge-1");
close();
selectWindow("nucleiMask");
close();
//selectWindow("cellMask");
//close();
//selectWindow("cytoMask");
//close();
selectWindow("CytoPr");
close();
selectWindow("nuclProj");
close();
selectWindow("orig");
close();

setTool("zoom");

}

macro "MP14 Action Tool 1 Options" {
        Dialog.create("Parameters");

	Dialog.addMessage("Choose parameters")	
	Dialog.addNumber("Projection threshold", thProjection);	
	Dialog.addNumber("Cell threshold", thCell);	
	Dialog.addNumber("Nucleus threshold", thNucl);		
	Dialog.show();	
	thProjection= Dialog.getNumber();
	thCell= Dialog.getNumber();
	thNucl= Dialog.getNumber();	
}

macro "MP14 Action Tool 2 Options" {
        Dialog.create("Parameters");
 
	Dialog.addMessage("Choose parameters")	
	Dialog.addNumber("Projection threshold", thProjection);	
	Dialog.addNumber("Cell threshold", thCell);	
	Dialog.addNumber("Nucleus threshold", thNucl);		
	Dialog.show();	
	thProjection= Dialog.getNumber();
	thCell= Dialog.getNumber();
	thNucl= Dialog.getNumber();		
}



