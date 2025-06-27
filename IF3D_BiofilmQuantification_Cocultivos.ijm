
function macroInfo(){
	
// * Title  
	scripttitle =  "Volumetric Analysis of 3D Cocultive Bacteria Biofilms ";
	version =  "1.02";
	date =  "2023";
	

// *  Tests Images:

	imageAdquisition = "IF Confocal 2 Channel  ";
	imageType = "3D 8 bit";  
	voxelSize = "Voxel size:  unknown";
	format = "Format: czi";   
 
 //*  GUI User Requierments:
 //  	- save and load previous ROIS --> todo
 //*    - Interactive Threshold. --> done
 //*	- Delete Unwanted tissue and SR positive--> done
 //		- Single File and Batch Mode --> done
 //*    
 // Important Parameters: 
 
 	 parameter1 = "Threshold for all bacteria";
	 parameter2 = "Min bacteria size (px)";
	 
	  
 //  2 Action tools:
		
	 buttom1 = "Im: Single File processing. Use Single file processing for fine tunning parameters";
	 buttom2 = "Dir: Batch Mode. Please tune parameters before using Batchmode";

//  OUTPUT

// Analyzed Images with ROIs

	excel = "Results_IF3D_BiofilmQuantification_Colultivos.xls";
	
	feature1  = "Label";
	feature2  = "Total biofilm volume (um3)";
	feature3  = "Marker1 volume (um3)";
	feature4  = "Marker2 volume (um3)";
	feature5  = "VMarker1/Vbiofilm (%)";
	feature6  = "VMarker2/Vbiofilm (%)";
	feature7  = "Marker1 surface area (um2)";
	feature8  = "Marker1 roughness";
	feature9  = "Marker1 avg thickness (um)";
	feature10 = "Marker1 avg thickness in non-zero voxels (um)";
	feature11 = "Marker2 surface area (um2)";
	feature12 = "Marker2 roughness";
	feature13 = "Marker2 avg thickness (um)"
	feature14 = "Marker2 avg thickness in non-zero voxels (um)";
	feature15 = "Biofilm surface area (um2)";
	feature16 = "Biofilm roughness";
	feature17 = "Biofilm avg thickness (um)";
	feature18 = "Biofilm avg thickness in non-zero voxels (um)";
	
/*  	  
 *  version: 1.02 
 *  Author: Mikel Ariz  
 *  Commented by: Tomas Muñoz 2023 
 *  Date : 2023
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

	
	//image1 = "../templateImages/cartilage.jpg";
	//descriptionActionsTools = "
	
	showMessage("ImageJ Script", "<html>"
		+"<style>h{margin-top: 5px; margin-bottom: 5px;} p{margin: 0px;padding: 0px;} ol{margin-left: 20px;padding: 5px;} #list-style-3 {list-style-type: circle;.container {max-width: 1200px; margin: 0 auto; padding: 0px; }</style>"
	    +"<h1><font size = 6 color = Teal href = https://cima.cun.es/en/research/technology-platforms/image-platforms>CIMA: Imaging Platform</h1>"
	    +"<h1><font size = 5 color = Purple><i>Software Development Service</i></h1>"
	    +"<p><font size = 2 color = Purple><i>ImageJ Macros</i></p>"
	    +"<h2><font size = 3 color = black>"+scripttitle+"</h2>"
	    +"<p><font size = 2>Modified by Tomas Mu&ntilde;oz Santoro</p>"
	    +"<p><font size = 2>Version: "+version+" ("+date+")</p>"
	    +"<p><font size = 2> contact tmsantoro@unav.es</p>" 
	    +"<p><font size = 2> Available for use/modification/sharing under the "+"<p4><a href = https://opensource.org/licenses/MIT/>MIT License</a></p>"
	    +"<h2><font size = 3 color = black>Developed for</h2>"
	    +"<p><font size = 3  i>Input Images</i></p>"
	    +"<ul id = list-style-3><font size = 2  i><li>"+imageAdquisition +"</li><li>"+imageType+"</li><li>"+voxelSize+"</li><li>"+format+"</li></ul>"
	    +"<p><font size = 3 i>Action tools (Buttons)</i></p>"
	    +"<ol><font size = 2  i><li>"+buttom1+"</li><li>"+buttom2+"</li></ol>"
	    +"<p><font size = 3  i>PARAMETERS:</i></p>"
	    +"<ul id = list-style-3><font size = 2  i>"
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li></ul>"
    	+"<p><font size = 3  i> Quantification Results: </i></p>"
	    +"<p><font size = 3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size = 3  i>Excel "+excel+"</i></p>"
	    +"<ul id = list-style-3><font size = 2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li>"
	    +"<li>"+feature5+"</li><li>"+feature6+"</li><li>"+feature7+"</li><li>"+feature8+"</li>"
	    +"<li>"+feature9+"</li><li>"+feature10+"</li><li>"+feature11+"</li><li>"+feature12+"</li>"
	    +"<li>"+feature13+"</li><li>"+feature14+"</li><li>"+feature15+"</li><li>"+feature16+"</li>"
	    +"<li>"+feature17+"</li><li>"+feature18+"</li></ul>"
	    +"<h0><font size = 5></h0>"
	    +"");
	   //+"<P4><font size = 2> For more detailed instructions see "+"<p4><a href = https://www.protocols.io/edit/movie-timepoint-copytoclipboaMarker2-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}



var cHoechst=1, cMarker1=2, cMarker2=3, displacement = 1, thBac = 50, minBacSize = 20;
var nameBacteria1="Fn", nameBacteria2="Rd";

macro "BiofilmQuantification3D Action Tool 1 - Cf00T2d15IT6d10m"{
		
	run("Close All");
	
	macroInfo();
	
	//just one file
	name = File.openDialog("Select File");
	//print(name);
	print("Processing "+name);

	Dialog.create("Parameters for the analysis");
	//Dialog.addNumber("Displacement (slices)", displacement);
	Dialog.addNumber("Channel Hoechstchst", cHoechst);
	Dialog.addNumber("Channel Bacteria 1", cMarker1);
	Dialog.addString("Introduce Name Bacteria 1", nameBacteria1);
	Dialog.addNumber("Channel Bacteria 2", cMarker2);	
	Dialog.addString("Introduce Name Bacteria 2", nameBacteria2);
	Dialog.addNumber("Threshold for all bacteria", thBac);	
	Dialog.addNumber("Min bacteria size (px)", minBacSize);	
	Dialog.show();	
	cHoechst =  Dialog.getNumber();
	cMarker1 =  Dialog.getNumber();
	nameBacteria1 = Dialog.getString();
	cMarker2 =  Dialog.getNumber();
	nameBacteria2 = Dialog.getString();
	thBac =  Dialog.getNumber();
	minBacSize =  Dialog.getNumber();
		
	//setBatchMode(true);
	biofilm3d("-","-",name,cMarker1,nameBacteria1,cMarker2,nameBacteria2,displacement,thBac,minBacSize);
	setBatchMode(false);
	showMessage("Biofilm quantified!");

}

macro "BiofilmQuantification3D Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	run("Close All");
	
	macroInfo();
	
	InDir = getDirectory("Choose Tiles' directory");
	list = getFileList(InDir);
	L = lengthOf(list);

	Dialog.create("Parameters for the analysis");
	//Dialog.addNumber("Displacement (slices)", displacement);
	Dialog.addNumber("Channel Hoechstchst", cHoechst);
	Dialog.addNumber("Channel Bacteria 1", cMarker1);
	Dialog.addString("Introduce Name Bacteria 1", nameBacteria1);
	Dialog.addNumber("Channel Bacteria 2", cMarker2);	
	Dialog.addString("Introduce Name Bacteria 2", nameBacteria2);
	Dialog.addNumber("Threshold for all bacteria", thBac);	
	Dialog.addNumber("Min bacteria size (px)", minBacSize);	
	Dialog.show();	
	cHoechst =  Dialog.getNumber();
	cMarker1 =  Dialog.getNumber();
	nameBacteria1 = Dialog.getString();
	cMarker2 =  Dialog.getNumber();
	nameBacteria2 = Dialog.getString();
	thBac =  Dialog.getNumber();
	minBacSize =  Dialog.getNumber();
	
	for (j = 0; j<L; j++)
	{
		if (endsWith(list[j],"czi") || endsWith(list[j],"tif")) {
			//analyze
			//d = InDir+list[j]t;
			name = list[j];
			print("Processing "+name);
			//setBatchMode(true);
			biofilm3d(InDir,InDir,list[j],cMarker1,nameBacteria1,cMarker2,nameBacteria2,displacement,thBac,minBacSize);
			setBatchMode(false);
			}
	}
	
	showMessage("Biofilm quantified!");

}


function biofilm3d(output,InDir,name,cMarker1,nameBacteria1,cMarker2,nameBacteria2,displacement,thBac,minBacSize)
{
		
	if (InDir == "-") {
		//run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");	
		open(name);
	}else{
		//run("Bio-Formats Importer", "open=["+InDir+name+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		open(InDir+name);
	}

	
	roiManager("Reset");
	run("Clear Results");
	MyTitle = getTitle();
	output = getInfo("image.directory");
	
	OutDir  =  output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	aa  =  split(MyTitle,".");
	MyTitle_short  =  aa[0];
	
	run("Colors...", "foreground = black background = white selection = yellow");
	run("Set Measurements...", "area mean display redirect = None decimal = 2");
	
	Stack.getDimensions(width, height, channels, slices, frames);
	getVoxelSize(vx, vy, vz, unit);
	FOV=(width*height*slices)*(vx*vy*vz); 
	
	rename("orig");
	run("Make Composite");
	Stack.setChannel(cHoechst);
	run("Blue");
	Stack.setChannel(cMarker1);
	run("Red");
	Stack.setChannel(cMarker2);
	run("Green");
	
	setBatchMode(true);
	
	/* 
	//--Further processing to remove planktonic bacteria
	selectWindow("Marker1");
	initSl  =  displacement+1;
	run("Duplicate...", "title = displaced duplicate range = "+initSl+"-"+slices);
	selectWindow("Marker1");
	run("Duplicate...", "title = first duplicate range = 1-"+displacement);
	for (i  =  0; i < displacement; i++) {
		selectWindow("Marker1");
		Stack.getDimensions(width, height, channels, slices, frames);
		setSlice(slices);
		run("Delete Slice");
	}
	imageCalculator("AND stack", "Marker1","displaced");
	selectWindow("displaced");
	close();
	run("Concatenate...", "  title = final image1 = first image2 = Marker1 image3 = [-- None --]");
	run("Analyze Particles...", "size = "+minBacSize+"-Infinity pixel show = Masks in_situ stack");
	rename("Marker1");
	*/
	
	//--PROCESS Hoechst
	selectWindow("orig");
	run("Duplicate...", "title=Hoechst duplicate channels="+cHoechst);
	run("Subtract Background...", "rolling=20 stack");
	
	//--Preprocessing
	run("Median...", "radius = 1 stack");
	run("Unsharp Mask...", "radius = 5 mask = 0.60 stack");
		
	autoThreshold("Hoechst","Huang");
			
	//--Post-processing
	//run("Close-", "stack");
	run("Median...", "radius = 1 stack");
	minBacSize=50;
	run("Analyze Particles...", "size="+minBacSize+"-Infinity pixel show=Masks in_situ stack");
	run("Clear Results");		
	
	//--PROCESS Marker1
	selectWindow("orig");
	run("Duplicate...", "title="+nameBacteria1+" duplicate channels="+cMarker1);
	run("Subtract Background...", "rolling=20 stack");
	
	//--Preprocessing
	run("Median...", "radius = 1 stack");
	run("Unsharp Mask...", "radius = 5 mask = 0.60 stack");
		
	autoThreshold(nameBacteria1,"Huang");
			
	//--Post-processing
	//run("Close-", "stack");
	run("Median...", "radius = 1 stack");
	minBacSize=50;
	run("Analyze Particles...", "size="+minBacSize+"-Infinity pixel show=Masks in_situ stack");
	run("Clear Results");
	 
	//--PROCESS Marker2
	
	selectWindow("orig");
	run("Duplicate...", "title="+nameBacteria2+" duplicate channels="+cMarker2);
	run("Subtract Background...", "rolling=20 stack");
	
	//--Preprocessing
	run("Median...", "radius = 1 stack");
	run("Unsharp Mask...", "radius = 5 mask = 0.60 stack");
	
	fixThreshold(nameBacteria2,50);
	//autoThreshold(nameBacteria2,"Huang");
	
	//--Post-processing
	//run("Close-", "stack");
	
	minBacSize=200;
	run("Analyze Particles...", "size="+minBacSize+"-Infinity pixel show=Masks in_situ stack");
	run("Clear Results");
	
	
	//--COMBINE MASKS
	
	//--Whole biofilm mask
	imageCalculator("OR create stack", nameBacteria1,nameBacteria2);
	rename("biofilm");
	
	//--Save binary segmentation masks
	selectWindow("biofilm");
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_BiofilmSegmentation_All.tif");
	wait(100);
	rename("biofilm");
	/*selectWindow(nameBacteria1);
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_BiofilmSegmentation_"+nameBacteria1+".tif");
	wait(100);
	rename(nameBacteria1);
	selectWindow(nameBacteria2);
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_BiofilmSegmentation_"+nameBacteria2+".tif");
	wait(100);
	rename(nameBacteria2);
	*/
	
	selectWindow("orig");
	run("Duplicate...", "title=imageToSave duplicate ");
	Stack.setChannel(cHoechst);
	run("Blue");
	Stack.setChannel(cMarker1);
	run("Green");
	Stack.setChannel(cMarker2);
	run("Red");
	
	addOverlay3D("imageToSave","Hoechst",cHoechst,"blue");
	addOverlay3D("imageToSave",nameBacteria1,cMarker1,"green");
	addOverlay3D("imageToSave",nameBacteria2,cMarker2,"red");
	
	selectWindow("imageToSave");	
	saveAs("Tiff", output+File.separator+"AnalyzedImages"+File.separator+MyTitle+"_BiofilmSegmentation_Overlay.tif");
		
	
	//--RESULTS
	
	//--Quantify Hoechst
	run("Clear Results");
	selectWindow("Hoechst");
	run("Analyze Regions 3D", "volume surface_area centroid surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
	selectWindow("Hoechst-morpho");
	IJ.renameResults("Results");
	VHoechst  =  getResult("Volume", 0);			// Marker1 volume
	//Surf_Marker1  =  getResult("SurfaceArea", 0);	// Marker1 surface area
	//Rough_Marker1  =  Surf_Marker1/VMarker1;		// Marker1 roughness
	zCentroidHoechst=getResult("Centroid.Z",0); 
		
	//--Quantify Marker1
	run("Clear Results");
	selectWindow(nameBacteria1);
	run("Analyze Regions 3D", "volume surface_area centroid surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
	selectWindow(nameBacteria1+"-morpho");
	IJ.renameResults("Results");
	VMarker1  =  getResult("Volume", 0);			// Marker1 volume
	//Surf_Marker1  =  getResult("SurfaceArea", 0);	// Marker1 surface area
	//Rough_Marker1  =  Surf_Marker1/VMarker1;		// Marker1 roughness
	zCentroidMarker1=getResult("Centroid.Z",0); 
	
	//--Quantify Marker2
	run("Clear Results");
	selectWindow(nameBacteria2);
	run("Analyze Regions 3D", "volume surface_area centroid surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");;
	selectWindow(nameBacteria2+"-morpho");
	IJ.renameResults("Results");
	VMarker2  =  getResult("Volume", 0);			// Marker2 volume
	//Surf_Marker2  =  getResult("SurfaceArea", 0);	// Marker2 surface area
	//Rough_Marker2  =  Surf_Marker2/VMarker2;		// Marker2 roughness
	zCentroidMarker2=getResult("Centroid.Z",0);
	
	//--Quantify combined biofilm
	run("Clear Results");
	selectWindow("biofilm");
	run("Analyze Regions 3D", "volume surface_area centroid surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
	selectWindow("biofilm-morpho");
	IJ.renameResults("Results");
	Vbiofilm  =  VMarker1+VMarker2;					// Biofilm volume
	//Surf_bio  =  getResult("SurfaceArea", 0);		// Biofilm surface area
	//Rough_bio  =  Surf_bio/Vbiofilm;				// Biofilm roughness
	zCentroidBiofilm=getResult("Centroid.Z",0);
	
	//--Ratios
	rMarker1  =  VMarker1/Vbiofilm*100;	
	rMarker2  =  VMarker2/Vbiofilm*100;		
	
	rFish1Hoe=VMarker1/VHoechst;
	rFish2Hoe=VMarker2/VHoechst;
	
	
	//--ANALYSIS OF Z DISTRIBUTION
	
	selectWindow("biofilm");
	Stack.getDimensions(width, height, channels, slices, frames);
	getVoxelSize(vx, vy, vz, unit);
	
	i  =  1;
	flagStart = true;
	while(flagStart) {
		selectWindow("biofilm");
		setSlice(i);
		run("Create Selection");
		type  =  selectionType();
		if(type! = -1) {
			flagStart = false;
			start  =  i;
		}
		i++;
	}
	
	//Array.print(newArray(start,slices));
			
	VMarker1_z  =  newArray(slices-start+1);
	VMarker2_z  =  newArray(slices-start+1);
	VMarker1_z_norm  =  newArray(slices-start+1);
	VMarker2_z_norm  =  newArray(slices-start+1);

	for (i  =  start; i < =  slices; i++) {
		
		// Current Z from the beginning of the biofilm:
		z  =  i-start;
		
		// Marker1
		selectWindow(nameBacteria1);
		setSlice(i);
		run("Create Selection");
		type  =  selectionType();
		if(type! = -1) {		
			run("Clear Results");
			run("Measure");
			A  =  getResult("Area", 0);
			VMarker1_z[z]  =  A*vz;
			// Normalized in percentage:
			VMarker1_z_norm[z]  =  VMarker1_z[z]/VMarker1*100;
		}
		else {
			VMarker1_z[z]  =  0;
			VMarker1_z_norm[z]  =  0;
		}
	
		// Marker2
		selectWindow(nameBacteria2);
		setSlice(i);
		run("Create Selection");
		type  =  selectionType();
		if(type! = -1) {		
			run("Clear Results");
			run("Measure");
			A  =  getResult("Area", 0);
			VMarker2_z[z]  =  A*vz;
			// Normalized in percentage:
			VMarker2_z_norm[z]  =  VMarker2_z[z]/VMarker2*100;
		}
		else {
			VMarker2_z[z]  =  0;
			VMarker2_z_norm[z]  =  0;
		}
		
	}
	/*
	//--Save results
	run("Clear Results");
	for (i  =  start; i < =  slices; i++) {
		z  =  i-start;
		setResult("Z",z,z);
		setResult("V"+nameBacteria1+" (um3)",z,VMarker1_z[z]);
		setResult("V"+nameBacteria2+" (um3)",z,VMarker2_z[z]);
		setResult("V"+nameBacteria1+" (%)",z,VMarker1_z_norm[z]);
		setResult("V"+nameBacteria2+" (%)",z,VMarker2_z_norm[z]);
	}
	saveAs("Results", output+File.separator+MyTitle_short+"_Zs.xls");
	//saveAs("Results", output+File.separator+MyTitle_short+"_Zs.csv");
	*/
	
	
	//--CALCULATE AVERAGE BIOFILM THICKNESS
	
	//--Hoechst
	selectWindow("Hoechst");
	run("Select None");
	run("Invert LUT");
	run("Divide...", "value=255 stack");
	run("Z Project...", "projection = [Sum Slices]");
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_"+nameBacteria1+"LocalThickness.tif");
	rename("Hoechst_projection");
	run("Clear Results");
	run("Select All");
	run("Measure");
	setAutoThreshold("Default dark");
	setThreshold(1, 1000);
	run("Create Selection");
	run("Measure");
	run("Select None");
	resetThreshold();
	Thick_Hoechst  =  getResult("Mean", 0);	// biofilm avg thickness
	Thick_nz_Hoechst  =  getResult("Mean", 1);	// biofilm avg thickness in non-zero positions
	// in microns
	Thick_Hoechst  =  Thick_Hoechst*vz;
	Thick_nz_Hoechst  =  Thick_nz_Hoechst*vz;
		
	
	//--Marker1
	selectWindow(nameBacteria1);
	run("Select None");
	run("Invert LUT");
	run("Divide...", "value=255 stack");
	run("Z Project...", "projection = [Sum Slices]");
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_"+nameBacteria1+"LocalThickness.tif");
	rename(nameBacteria1+"_projection");
	run("Clear Results");
	run("Select All");
	run("Measure");
	setAutoThreshold("Default dark");
	setThreshold(1, 1000);
	run("Create Selection");
	run("Measure");
	run("Select None");
	resetThreshold();
	Thick_Marker1  =  getResult("Mean", 0);	// biofilm avg thickness
	Thick_nz_Marker1  =  getResult("Mean", 1);	// biofilm avg thickness in non-zero positions
	// in microns
	Thick_Marker1  =  Thick_Marker1*vz;
	Thick_nz_Marker1  =  Thick_nz_Marker1*vz;
	
	//--Marker2
	selectWindow(nameBacteria2);
	run("Select None");
	
	//run("Invert LUT");
	run("Divide...", "value=255 stack");
	
	run("Z Project...", "projection = [Sum Slices]");
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_"+nameBacteria2+"LocalThickness.tif");
	rename("Marker2_projection");
	run("Clear Results");
	run("Select All");
	run("Measure");
	setAutoThreshold("Default dark");
	setThreshold(0.5000, 1000);
	run("Create Selection");
	run("Measure");
	run("Select None");
	resetThreshold();
	Thick_Marker2  =  getResult("Mean", 0);	// biofilm avg thickness
	Thick_nz_Marker2  =  getResult("Mean", 1);	// biofilm avg thickness in non-zero positions
	// in microns
	Thick_Marker2  =  Thick_Marker2*vz;
	Thick_nz_Marker2  =  Thick_nz_Marker2*vz;
	
	//--Combined biofilm
	selectWindow("biofilm");
	run("Select None");
	
	//run("Invert LUT");
	run("Divide...", "value=255 stack");
	
	run("Z Project...", "projection = [Sum Slices]");
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_BiofilmLocalThickness.tif");
	rename("biofilm_projection");
	run("Clear Results");
	run("Select All");
	run("Measure");
	setAutoThreshold("Default dark");
	setThreshold(0.5000, 1000);
	run("Create Selection");
	run("Measure");
	run("Select None");
	resetThreshold();
	Thick_bio  =  getResult("Mean", 0);	// biofilm avg thickness
	Thick_nz_bio  =  getResult("Mean", 1);	// biofilm avg thickness in non-zero positions
	// in microns
	Thick_bio  =  Thick_bio*vz;
	Thick_nz_bio  =  Thick_nz_bio*vz;
	
	excel = "Results_IF3D_BiofilmQuantification_Colultivos"+nameBacteria1+"-"+nameBacteria2+".xls";
	
	//--Save results
	run("Clear Results");
	if(File.exists(output+File.separator+excel))
	{	
		//if exists add and modify
		open(output+File.separator+excel);
		IJ.renameResults("Results");
	}
	i = nResults;
	setResult("[Label]", i, MyTitle); 
	setResult("FOV volume (um3)",i,FOV);
	setResult("Total biofilm volume (um3)",i,Vbiofilm);
	setResult("Hoechst volume (um3)",i,VHoechst);
	setResult(nameBacteria1+" volume (um3)",i,VMarker1);
	setResult(nameBacteria2+" volume (um3)",i,VMarker2);
	setResult("V"+nameBacteria1+"/Vbiofilm (%)",i,rMarker1);
	setResult("V"+nameBacteria2+"/Vbiofilm (%)",i,rMarker2);
	setResult(nameBacteria1+"/VHoechst (%)",i,rFish1Hoe);
	setResult(nameBacteria2+"/VHoechst (%)",i,rFish2Hoe);
	setResult("Hoechst Z-Centroid",i,zCentroidHoechst);
	setResult("Hoechst avg thickness (um)",i,Thick_Hoechst);
	setResult("Hoechst avg thickness in non-zero voxels (um)",i,Thick_nz_Hoechst);
	//setResult(nameBacteria1+" surface area (um2)",i,Surf_Marker1);
	//setResult(nameBacteria1+" roughness",i,Rough_Marker1);
	setResult(nameBacteria1+" Z-Centroid",i,zCentroidMarker1);
	setResult(nameBacteria1+" avg thickness (um)",i,Thick_Marker1);
	setResult(nameBacteria1+" avg thickness in non-zero voxels (um)",i,Thick_nz_Marker1);
	//setResult(nameBacteria2+" surface area (um2)",i,Surf_Marker2);
	//setResult(nameBacteria2+" roughness",i,Rough_Marker2);
	setResult(nameBacteria2+" Z-Centroid",i,zCentroidMarker2);
	setResult(nameBacteria2+" avg thickness (um)",i,Thick_Marker2);
	setResult(nameBacteria2+" avg thickness in non-zero voxels (um)",i,Thick_nz_Marker2);
	//setResult("Biofilm surface area (um2)",i,Surf_bio);
	//setResult("Biofilm roughness",i,Rough_bio);
	setResult("Biofilm Z-Centroid",i,zCentroidBiofilm);
	setResult("Biofilm avg thickness (um)",i,Thick_bio);
	setResult("Biofilm avg thickness in non-zero voxels (um)",i,Thick_nz_bio);
	saveAs("Results", output+File.separator+excel);
	close("*");
	
	//run("Synchronize Windows");
			 
	//Clear unused memory
	wait(500);
	run("Collect Garbage");
		
}


function autoThreshold(image,method){

	selectWindow(image);
	
	// Find Slice with Max Signal
	run("Select All");
	run("Measure Stack...");
	selectWindow("Results");
	meanSliceI=Table.getColumn("Mean");
	Array.getStatistics(meanSliceI, min, max, mean, stdDev);
	Array.print(newArray(min, max, mean, stdDev));
	maxMarker1=Array.findMaxima(meanSliceI,stdDev);
	Array.print(maxMarker1);
	selectWindow(image);
	if (maxMarker1[0]==0){
		setSlice(1);
	}else{
		setSlice(maxMarker1[0]+1);
	}
	run("Enhance Contrast", "saturated=0.1");
	run("Apply LUT", "stack");
	run("Gaussian Blur...", "sigma=2 stack");
		
	//--Thresholding
	if(method == "Huang"){
		setAutoThreshold("Huang dark");
	}
	if(method == "Otsu"){ 
		setAutoThreshold("Otsu dark stack");
	}
	/*
	run("Threshold...");
	//setAutoThreshold("Otsu dark stack");*/
	run("Convert to Mask", "method=Huang background=Dark");
}


function percHistMode(image){

	//--Calculate threshold as PercHist % of the mode in the histogram
	
	selectWindow(image);
	//calculate stack histogram
	setSlice(1);
	getHistogram(valuesStack,countsStack,256);
	run("Clear Results");
	for (sl=2; sl<=nSlices; sl++) {
		setSlice(sl);
		getHistogram(values,counts,256);
		for (i = 0; i < 256; i++) {
			countsStack[i] += counts[i]; 
		}	
	}
	// max count value
	Array.getStatistics(countsStack, min, maxCount, mean, stdDev);
	// intensity at which the count is max
	iMaxCount = Array.findMaxima(countsStack, 500);
	// search for intensity at which the peak of the histogram descends below PercHist
	cCount = maxCount;
	cInt = iMaxCount[0];
	while(cCount >= maxCount*PercHist*0.01) {	//multiply by 0.01 because PercHist value is in %
		cInt = cInt+1;
		cCount = countsStack[cInt];
	}
	// current intensity, at which the counts are below desired % of the histogram peak, is our threshold for bacteria
	thBac = cInt;
		
	//--Thresholding
	setThreshold(thBac, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark");
	
}

function fixThreshold(image,thBac){
	
	selectWindow(image);
	
	// Find Slice with Max Signal
	run("Select All");
	run("Measure Stack...");
	selectWindow("Results");
	meanSliceI=Table.getColumn("Mean");
	Array.getStatistics(meanSliceI, min, max, mean, stdDev);
	Array.print(newArray(min, max, mean, stdDev));
	maxMarker1=Array.findMaxima(meanSliceI,stdDev);
	Array.print(maxMarker1);
	selectWindow(image);
	if (maxMarker1[0]==0){
		setSlice(1);
	}else{
		setSlice(maxMarker1[0]+1);
	}
	run("Enhance Contrast", "saturated=0.1");
	run("Apply LUT", "stack");
	run("Gaussian Blur...", "sigma=2 stack");
		
	selectWindow(image);
	setThreshold(thBac, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark");
}
	
function addOverlay3D(rawImage,maskImage,channel,color){
		
		selectWindow(rawImage);
		getDimensions(width, height, channels, slices, frames);
		RoiManager.associateROIsWithSlices(true);	
		
		// Ensure the image is a stack
		if (slices > 1) {
		    // Loop through each slice
		    for (i = 1; i <= slices; i++) {
		    	selectWindow(maskImage);
		        setSlice(i);
		        selectWindow(maskImage);
		        // Create an ROI from the binary image
		        run("Create Selection");
		        wait(5);
		        type=selectionType();
		        if(type!=-1){
		        	Roi.setPosition(channel, i, 0);
		        	selectWindow(rawImage);
		        	Stack.setChannel(channel);
		        	run("Restore Selection");
					Overlay.addSelection(color);
					Overlay.setPosition(channel, i, 0);
	
		        }
		    }
		}else{
		    print("The image is not a stack.");
		}
	}
	
