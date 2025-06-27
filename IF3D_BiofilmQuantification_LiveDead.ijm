
function macroInfo(){
	
// * Title  
	scripttitle =  "Volumetric Analysis of 3D Bacteria Life Dead ";
	version =  "1.02";
	date =  "2023";
	

// *  Tests Images:

	imageAdquisition = "IF Confocal 2 Channels : Syt - IP  ";
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
	 parameter2 = "Threshold for dead bacteria";
	 parameter3 = "Min bacteria size (px)";
	 
	  
 //  2 Action tools:
		
	 buttom1 = "Im: Single File processing. Use Single file processing for fine tunning parameters";
	 buttom2 = "Dir: Batch Mode. Please tune parameters before using Batchmode";

//  OUTPUT

// Analyzed Images with ROIs

	excel = "QuantificationResults_IF3D_BiofilmQuantification_Colultivos.xls";
	
	feature1  = "Label";
	feature2  = "Total biofilm volume (um3)";
	feature3  = "Live volume (um3)";
	feature4  = "Dead volume (um3)";
	feature5  = "Vlive/Vbiofilm (%)";
	feature6  = "Vdead/Vbiofilm (%)";
	feature7  = "Biofilm in most dense slice (%)";
	feature8  = "Rlive in most dense slice (%)";
	feature9  = "Rdead in most dense slice (%)";
	
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
	    +"<ol><font size = 2  i><li>"+buttom1+"</li><li>"+buttom2+"</li></ol>"
	    +"<p><font size = 3  i>PARAMETERS:</i></p>"
	    +"<ul id = list-style-3><font size = 2  i>"
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li>"
    	+"<li>"+parameter3+"</li></ul>"
    	+"<p><font size = 3  i> Quantification Results: </i></p>"
	    +"<p><font size = 3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size = 3  i>Excel "+excel+"</i></p>"
	    +"<ul id = list-style-3><font size = 2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li>"
	    +"<li>"+feature5+"</li><li>"+feature6+"</li><li>"+feature7+"</li><li>"+feature8+"</li>"
	    +"<li>"+feature9+"</li></ul>"
	    +"<h0><font size = 5></h0>"
	    +"");
	   //+"<P4><font size = 2> For more detailed instructions see "+"<p4><a href = https://www.protocols.io/edit/movie-timepoint-copytoclipboaMarker2-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}





// changelog February 2022
// Segmentation of the biofilm in 3D
// Quantification of biofilm volume

var cLife=2 , cDead=1 , displacement=1, thBac=50, thBacDead=30, minBacSize=30;

macro "BiofilmQuantification3D Action Tool 1 - Cf00T2d15IT6d10m"{
	
	run("Close All");
	
	macroInfo();
	
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	print("Processing "+name);

	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Introduce Channel Order")	
	Dialog.addNumber("Live Channel", cLife);	
	Dialog.addNumber("Dead Channel",cDead);	
	Dialog.addNumber("Threshold for all bacteria", thBac);	
	Dialog.addNumber("Threshold for dead bacteria", thBacDead);	
	Dialog.addNumber("Min bacteria size (px)", minBacSize);	
	Dialog.show();	
	
	cLife= Dialog.getNumber();
	cDead= Dialog.getNumber();
	thBac= Dialog.getNumber();
	thBacDead= Dialog.getNumber();
	minBacSize= Dialog.getNumber();
		
	//setBatchMode(true);
	biofilm3d("-","-",name,displacement,cLife,cDead,thBac,thBacDead,minBacSize);
	setBatchMode(false);
	showMessage("Biofilm quantified!");

}

macro "BiofilmQuantification3D Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	run("Close All");
	
	macroInfo();
	
	InDir=getDirectory("Choose Tiles' directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Introduce Channel Order")	
	Dialog.addNumber("Live Channel", cLife);	
	Dialog.addNumber("Dead Channel",cDead);	
	Dialog.addNumber("Threshold for all bacteria", thBac);	
	Dialog.addNumber("Threshold for dead bacteria", thBacDead);	
	Dialog.addNumber("Min bacteria size (px)", minBacSize);	
	Dialog.show();	
	
	cLife= Dialog.getNumber();
	cDead= Dialog.getNumber();
	thBac= Dialog.getNumber();
	thBacDead= Dialog.getNumber();
	minBacSize= Dialog.getNumber();

	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"czi") || endsWith(list[j],"tif")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print("Processing "+name);
			//setBatchMode(true);
			biofilm3d(InDir,InDir,list[j],displacement,cLife,cDead,thBac,thBacDead,minBacSize);
			setBatchMode(false);
			}
	}
	
	showMessage("Biofilm quantified!");

}


function biofilm3d(output,InDir,name,displacement,cLife,cDead,thBac,thBacDead,minBacSize)
{
	
	run("Close All");
	
	if (InDir=="-") {
		run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		}
	else {
		run("Bio-Formats Importer", "open=["+InDir+name+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		}	
	
	
	run("Set Measurements...", "area mean min redirect=None decimal=2");
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	run("Colors...", "foreground=black background=white selection=yellow");
	
	Stack.getDimensions(width, height, channels, slices, frames);
	getVoxelSize(vx, vy, vz, unit);
	FOV=(width*height*slices)*(vx*vy*vz); 
	
	rename("orig");
			
	run("Make Composite");
	Stack.setChannel(cLife);
	run("Green");
	//run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(cDead);
	run("Red");
	//run("Enhance Contrast", "saturated=0.35");
	
	setBatchMode(true);
	
	/*
	//--Background subtraction
	run("Duplicate...", "title=filtered duplicate");
	selectWindow("orig");
	run("Mean...", "radius=3 stack");
	selectWindow("filtered");
	run("Mean...", "radius=50 stack");
	imageCalculator("Subtract stack", "orig","filtered");
	selectWindow("filtered");
	close();
	*/
	
	run("Subtract Background...", "rolling=20 stack");
	
	//--PROCESS LIVE
	
	selectWindow("orig");
	run("Duplicate...", "title=live duplicate channels="+cLife+"");
	
	//--Preprocessing
	//run("Unsharp Mask...", "radius=5 mask=0.60 stack");
	setMinAndMax(15, 255);
	run("Apply LUT", "stack");
	
	run("3D Fast Filters","filter=Mean radius_x_pix=1.0 radius_y_pix=1.0 radius_z_pix=1.0 Nb_cpus=16");
	close("live");
	rename("live");
	
	//--Thresholding methods
	
	//autoThreshold("live","Otsu");
	//percHistMode("live");
	fixThreshold("live",thBac);
	
	
	//--Post-processing
	//run("Close-", "stack");
	run("Median...", "radius=1 stack");
	//minBacSize=50;
	run("Analyze Particles...", "size="+minBacSize+"-Infinity pixel show=Masks in_situ stack");
	
		
	//--PROCESS DEAD BACTERIA
	
	selectWindow("orig");
	run("Duplicate...", "title=dead duplicate channels="+cDead+"");
	
	//--Preprocessing
	setMinAndMax(15, 255);
	run("Apply LUT", "stack");
	
	run("3D Fast Filters","filter=Mean radius_x_pix=1.0 radius_y_pix=1.0 radius_z_pix=1.0 Nb_cpus=16");
	close("dead");
	rename("dead");
	
	//--Thresholding Mehtods
				
	//autoThreshold("dead","Otsu");
	//percHistMode("dead");
	fixThreshold("dead",thBacDead);
	

	
	//--Post-processing
	//run("Close-", "stack");
	run("Median...", "radius=1 stack");
	//minBacSize=50;
	run("Analyze Particles...", "size="+minBacSize+"-Infinity pixel show=Masks in_situ stack");
	
	
	//--Final live bacteria mask
	imageCalculator("AND create stack", "dead","live");
	rename("deadInLive");
	imageCalculator("XOR stack", "live","deadInLive");
	selectWindow("deadInLive");
	close();
	selectWindow("live");
	run("Analyze Particles...", "size="+minBacSize+"-Infinity pixel show=Masks in_situ stack");

	selectWindow("orig");
	run("Duplicate...", "title=imageToSave duplicate ");
	Stack.setChannel(cLife);
	run("Green");
	Stack.setChannel(cDead);
	run("Red");
			
	addOverlay3D("imageToSave","live",cLife,"green");
	addOverlay3D("imageToSave","dead",cDead,"red");
	
	selectWindow("imageToSave");	
	saveAs("Tiff", output+File.separator+"AnalyzedImages"+File.separator+MyTitle+"_LifeDead_Overlay.tif");
	
	//--COMBINE MASKS
	

	
	//--Whole biofilm mask
	imageCalculator("OR create stack", "live","dead");
	rename("biofilm");
	
	//--Save binary segmentation masks
	selectWindow("biofilm");
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_BiofilmSegmentation_All.tif");
	wait(100);
	rename("biofilm");
	selectWindow("live");
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_BiofilmSegmentation_Live.tif");
	wait(100);
	rename("live");
	selectWindow("dead");
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_BiofilmSegmentation_Dead.tif");
	wait(100);
	rename("dead");
	
	
	
	//--RESULTS
	
	//--Calculate total biofilm volume
	run("Clear Results");
	selectWindow("biofilm");
	run("Analyze Regions 3D", "volume surface_area surface_area_method = [Crofton (13 dirs.)] euler_connectivity = C26");
	selectWindow("biofilm-morpho");
	IJ.renameResults("Results");
	if(nResults==0) {
		Vbiofilm = 0;
	}
	else {
		Vbiofilm = getResult("Volume", 0);			// biofilm volume
	}
	
	
	//--Calculate dead volume
	run("Clear Results");
	selectWindow("dead");
	run("Analyze Regions 3D", "volume surface_area surface_area_method = [Crofton (13 dirs.)] euler_connectivity = C26");
	selectWindow("dead-morpho");
	IJ.renameResults("Results");
	if(nResults==0) {
		Vdead = 0;
	}
	else {
		Vdead = getResult("Volume", 0);			// dead volume
	}
	
	//--Calculate live volume
	Vlive = Vbiofilm-Vdead;
	
	//--Live bacteria ratio
	if(Vbiofilm==0) {
		rLive = 0;
	}
	else {
		rLive = Vlive/Vbiofilm*100;						
	}
	
	//--Dead bacteria ratio
	rDead = 100-rLive;
	
	
	//--Measure the most dense slice:
	
	selectWindow("biofilm");
	run("Select None");
	getDimensions(width, height, channels, slices, frames);
	run("Set Measurements...", "area mean area_fraction redirect=None decimal=2");
	run("Clear Results");
	setSlice(1);
	run("Measure");
	Amax = getResult("%Area", 0);
	slMax=1;
	for (i = 1; i < slices; i++) {
		run("Clear Results");
		setSlice(i+1);
		run("Measure");
		A = getResult("%Area", 0);
		if(A>Amax) {
			Amax = A;
			slMax = i+1;
		}
	}
	// Biofilm:
	AmaxBiofilm = Amax;
	// Live:
	run("Clear Results");
	selectWindow("live");
	run("Select None");
	setSlice(slMax);
	run("Measure");
	AmaxLiveTotal = getResult("%Area", 0);
	AmaxLiveRel = AmaxLiveTotal/AmaxBiofilm*100;
	// Dead:
	AmaxDeadRel = 100-AmaxLiveRel;
	
	
	//--Save results
	run("Clear Results");
	if(File.exists(output+File.separator+"IF3D_BiofilmQuantification_LiveDead.xls"))
	{	
		//if exists add and modify
		open(output+File.separator+"IF3D_BiofilmQuantification_LiveDead.xls");
		IJ.renameResults("Results");
	}
	i=nResults;
	setResult("[Label]", i, MyTitle);
	setResult("FOV volume (um3)",i,FOV);
	setResult("Total biofilm volume (um3)",i,Vbiofilm);
	setResult("Live volume (um3)",i,Vlive);
	setResult("Dead volume (um3)",i,Vdead);
	setResult("Vlive/Vbiofilm (%)",i,rLive);
	setResult("Vdead/Vbiofilm (%)",i,rDead);
	setResult("Biofilm in most dense slice (%)",i,AmaxBiofilm);
	setResult("Rlive in most dense slice (%)",i,AmaxLiveRel);
	setResult("Rdead in most dense slice (%)",i,AmaxDeadRel);
	saveAs("Results", output+File.separator+"IF3D_BiofilmQuantification_LiveDead.xls");
	
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
	run("Gaussian Blur...", "sigma=1 stack");
		
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
	getDimensions(width, height, channels, slices, frames);
	run("Clear Results");
	for (sl=2; sl<=slices; sl++) {
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
	PercHist=50;
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
	
	run("Clear Results");
	
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
	//run("Enhance Contrast", "saturated=0.1");
	//run("Apply LUT", "stack");
	//run("Gaussian Blur...", "sigma=2 stack");
		
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
	
