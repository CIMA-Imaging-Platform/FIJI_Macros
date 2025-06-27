

function macroInfo(){
	
// * Title  
	scripttitle =  "Volumetric Analysis of 3D Bacteria Biofilm ";
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

	excel = "QuantificationResults_IF3D_BiofilmQuantification.xls";
	
	feature1  = "Label";
	feature2  = "Biofilm volume (um3)";
	feature3  = "Total volume (um3)";
	feature4  = "Biofilm density (%)";
	feature5  = "Biofilm surface area (um2)";
	feature6  = "Biofilm roughness";
	feature7  = "Biofilm avg thickness (um)";
	feature8  = "Biofilm avg thickness in non-zero voxels (um)";
	
	
/*  	  
 *  version: 1.02 
 *  Author: Mikel Ariz  
 *  Commented by: Tomas Muñoz 2023 
 *  Date : 2015
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
	    +"<ol><font size = 2  i><li>"+buttom1+"</li></ol>"
	    +"<p><font size = 3  i>PARAMETERS:</i></p>"
	    +"<ul id = list-style-3><font size = 2  i>"
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li></ul>"
	    +"<p><font size = 3  i>Quantification Results: </i></p>"
	    +"<p><font size = 3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size = 3  i>Excel "+excel+"</i></p>"
	    +"<ul id = list-style-3><font size = 2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li></ul>"
	    +"<h0><font size = 5></h0>"
	    +"");
	   //+"<P4><font size = 2> For more detailed instructions see "+"<p4><a href = https://www.protocols.io/edit/movie-timepoint-copytoclipboaMarker2-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}



// changelog February 2022
// Segmentation of the biofilm in 3D
// Quantification of biofilm volume

var cHoechst=1, cMarker1=2, thBac=60, minBacSize=20;

macro "BiofilmQuantification3D Action Tool 1 - Cf00T2d15IT6d10m"{
	
	run("Close All");
	
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	print("Processing "+name);

	Dialog.create("Parameters for the analysis");
	Dialog.addNumber("Channel Hoechstchst", cHoechst);
	Dialog.addNumber("Channel Bacteria 1", cMarker1);
	Dialog.addNumber("Threshold for bacteria", thBac);	
	Dialog.addNumber("Min bacteria size (px)", minBacSize);	
	Dialog.show();	
	cHoechst =  Dialog.getNumber();
	cMarker1 =  Dialog.getNumber();
	thBac= Dialog.getNumber();
	minBacSize= Dialog.getNumber();
		
	//setBatchMode(true);
	biofilm3d("-","-",name,cHoechst,cMarker1,thBac,minBacSize);
	setBatchMode(false);
	showMessage("Biofilm quantified!");

}

macro "BiofilmQuantification3D Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	run("Close All");
	
	InDir=getDirectory("Choose Tiles' directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("Parameters for the analysis");
	Dialog.addNumber("Channel Hoechstchst", cHoechst);
	Dialog.addNumber("Channel Bacteria 1", cMarker1);
	Dialog.addNumber("Threshold for bacteria", thBac);	
	Dialog.addNumber("Min bacteria size (px)", minBacSize);	
	Dialog.show();	
	cHoechst =  Dialog.getNumber();
	cMarker1 =  Dialog.getNumber();
	thBac= Dialog.getNumber();
	minBacSize= Dialog.getNumber();

	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"czi") || endsWith(list[j],"tif")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print("Processing "+name);
			//setBatchMode(true);
			biofilm3d(InDir,InDir,list[j],cHoechst,cMarker1,thBac,minBacSize);
			setBatchMode(false);
			}
	}
	
	showMessage("Biofilm quantified!");

}


function biofilm3d(output,InDir,name,cHoechst,cMarker1,thBac,minBacSize)
{

	run("Close All");
	
	if (InDir == "-") {
		//run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");	
		open(name);
	}else{
		//run("Bio-Formats Importer", "open=["+InDir+name+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		open(InDir+name);
	}
			
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	rename("orig");
	
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	setBatchMode(true);
		
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	run("Colors...", "foreground=black background=white selection=yellow");
	
	Stack.getDimensions(width, height, channels, slices, frames);
	getVoxelSize(vx, vy, vz, unit);
	Array.print(newArray(vx,vy,vz,unit));
	run("Set Measurements...", "area mean redirect=None decimal=2");
	
	//--PROCESS Hoechst
	selectWindow("orig");
	run("Duplicate...", "title=Hoechst duplicate channels="+cHoechst);
	run("Subtract Background...", "rolling=20 stack");
	
		//--Preprocessing
	run("Median...", "radius = 1 stack");
	run("Unsharp Mask...", "radius = 5 mask = 0.60 stack");
		
	autoThreshold("Hoechst","Huang");
			
		//--Post-processing
	run("Median...", "radius = 1 stack");
	minBacSize=50;
	run("Analyze Particles...", "size="+minBacSize+"-Infinity pixel show=Masks in_situ stack");
	run("Clear Results");
	
	//--PROCESS Marker1
	selectWindow("orig");
	run("Duplicate...", "title=BiofilmSeg duplicate channels="+cMarker1);
	run("Subtract Background...", "rolling=20 stack");
	
		//--Preprocessing
	run("Median...", "radius=1 stack");
	run("Unsharp Mask...", "radius=5 mask=0.60 stack");
	
	autoThreshold("BiofilmSeg","Huang");
	
	//--Post-processing
	//run("Close-", "stack");
	run("Median...", "radius=1 stack");
	minBacSize=50;
	run("Analyze Particles...", "size="+minBacSize+"-Infinity pixel show=Masks in_situ stack");
	
	getVoxelSize(vx, vy, vz, unit);
	Array.print(newArray(vx,vy,vz,unit));
	
	selectWindow("orig");
	run("Duplicate...", "title=imageToSave duplicate ");
	addOverlay3D("imageToSave","Hoechst",cHoechst,"blue");
	addOverlay3D("imageToSave","BiofilmSeg",cMarker1,"red");
		
	//--Save binary segmentation image
	//selectWindow("final");
	selectWindow("imageToSave");
	wait(100);
	saveAs("Tiff", output+File.separator+"AnalyzedImages"+File.separator+MyTitle+"_BiofilmSegmentation_Overlay.tif");
	
	//--RESULTS
	
	run("Clear Results");
	
	//--Calculate volume fraction 
	selectWindow("Hoechst");
	run("Analyze Regions 3D", "volume surface_area surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
	selectWindow("Hoechst-morpho");
	IJ.renameResults("Results");
	Vol_Hoechst = getResult("Volume", 0);	// biofilm volume
	//Surf_bio = getResult("SurfaceArea", 0);	// biofilm volume
	//Rough_bio = Surf_bio/Vol_bio;	// biofilm roughness
	
	run("Clear Results");
		
	//--Calculate volume fraction 
	selectWindow("BiofilmSeg");
	run("Analyze Regions 3D", "volume surface_area surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
	
	selectWindow("BiofilmSeg-morpho");
	IJ.renameResults("Results");
	Vol_fish = getResult("Volume", 0);	// biofilm volume
	//Surf_bio = getResult("SurfaceArea", 0);	// biofilm volume
	//Rough_bio = Surf_bio/Vol_bio;	// biofilm roughness
	
	//--Calculate total volume
	selectWindow("Hoechst");
	getVoxelSize(vx, vy, vz, unit);
	Stack.getDimensions(width, height, channels, slices, frames);
	Vtotal = width*height*slices*vx*vy*vz;		// total scanned volume

	//--Hoechst ratio
	rHoechst = Vol_Hoechst/Vtotal*100;	

	//--Fish ratio
	rFish = Vol_fish/Vtotal*100;	
	
	
	//--CALCULATE AVERAGE BIOFILM THICKNESS
	
	selectWindow("BiofilmSeg");
	run("Select None");
	run("Invert LUT");
	run("Divide...", "value=255 stack");
	run("Z Project...", "projection=[Sum Slices]");
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_BiofilmLocalThickness.tif");
	rename("BiofilmSeg_projection");
	run("Clear Results");
	run("Select All");
	run("Measure");
	setAutoThreshold("Default dark");
	setThreshold(0.5000, 100000000);
	run("Create Selection");
	run("Measure");
	run("Select None");
	resetThreshold();
	Thick_bio = getResult("Mean", 0);	// biofilm avg thickness
	Thick_nz_bio = getResult("Mean", 1);	// biofilm avg thickness in non-zero positions
	// in microns
	Thick_bio = Thick_bio*vz;
	Thick_nz_bio = Thick_nz_bio*vz;
	
	//--Save results
	run("Clear Results");
	if(File.exists(output+File.separator+"QuantificationResults_IF3D_BiofilmQuantification.xls"))
	{	
		//if exists add and modify
		open(output+File.separator+"QuantificationResults_IF3D_BiofilmQuantification.xls");
		IJ.renameResults("Results");
	}
	i=nResults;
	setResult("[Label]", i, MyTitle); 
	setResult("FOV volume (um3)",i,Vtotal);
	setResult("Hoechst volume (um3)",i,Vol_Hoechst);
	setResult("Hoechst density (%)",i,rHoechst);
	setResult("Fish volume (um3)",i,Vol_fish);
	setResult("Fish density (%)",i,rFish);
	setResult("Ratio Fish/Hoechst",i,Vol_fish/Vol_Hoechst);
	//setResult("Biofilm surface area (um2)",i,Surf_bio);
	//setResult("Biofilm roughness",i,Rough_bio);
	setResult("Biofilm avg thickness (um)",i,Thick_bio);
	setResult("Biofilm avg thickness in non-zero voxels (um)",i,Thick_nz_bio);
	saveAs("Results", output+File.separator+"QuantificationResults_IF3D_BiofilmQuantification.xls");
	
	//run("Synchronize Windows");
	
	if (InDir!="-") {
	close(); }
		 
	//Clear unused memory
	wait(500);
	run("Collect Garbage");
	
	close("*");
		
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
	

