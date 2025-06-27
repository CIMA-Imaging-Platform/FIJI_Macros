function macroInfo(){
	
// * Title  
	scripttitle =  "Quantification of Live Dead Bacteria";
	version =  "1.02";
	date =  "2023";
	

// *  Tests Images:

	imageAdquisition = "IF Confocal 2 Channel  ";
	imageType = "4D - 8 bit";  
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

	excel = "QuantificationResults_IF3_BiofilmQuantification.xls";
	
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

var cBiofilm=1, cMarker1=2, thBac=60, minBacSize=20;

macro "BiofilmQuantification3D Action Tool 1 - Cf00T2d15IT6d10m"{
	
	run("Close All");
		
	Dialog.create("PARAMETERS");
	Dialog.addMessage("SELECT WORKFLOW");
	workflowOptions=newArray("Time Series Analysis - FirstLayer","Time Series Analysis - Volumetric");
	Dialog.addRadioButtonGroup("", workflowOptions, 1, 2, "FirstLayer Analysis Through Time");
	Dialog.show();	
	
	workflowType= Dialog.getRadioButton();
	
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	print("Processing "+name);
		
	//setBatchMode(true);
	
	if (workflowType == "Time Series Analysis - FirstLayer"){
		biofilm2dTime("-","-",name,thBac,minBacSize);
	}
	if (workflowType == "Time Series Analysis - Volumetric"){
		biofilm4d("-","-",name,thBac,minBacSize);
	}
	setBatchMode(false);
	showMessage("Biofilm quantified!");

}

macro "BiofilmQuantification3D Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	run("Close All");
	
	InDir=getDirectory("Choose Tiles' directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("Parameters for the analysis");
	Dialog.addNumber("Threshold for bacteria", thBac);	
	Dialog.addNumber("Min bacteria size (px)", minBacSize);	
	Dialog.show();	
	//cBiofilm =  Dialog.getNumber();
	//cMarker1 =  Dialog.getNumber();
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
			biofilm2dTime(InDir,InDir,list[j],thBac,minBacSize);
			//biofilm4d(InDir,InDir,list[j],thBac,minBacSize);
			setBatchMode(false);
			}
	}
	
	showMessage("Biofilm quantified!");

}

function  biofilm2dTime(output,InDir,name,thBac,minBacSize){

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
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	output=getInfo("image.directory");
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	rename("orig");
	
	cropOutOfFocus("orig");
	
	selectWindow("inFocus");
	//selectWindow("orig");
	run("Duplicate...", "title=imageToSave duplicate slices=1");
	//run("Re-order Hyperstack ...", "channels=[Channels (c)] slices=[Frames (t)] frames=[Slices (z)]");
	run("Duplicate...", "title=firstSliceMask duplicate");
	close("inFocus");
	
	setBatchMode(true);
			
	run("Set Measurements...", "area mean redirect=None decimal=2");
	run("Colors...", "foreground=white background=black selection=yellow");
	run("Options...", "iterations=1 count=1 do=Nothing");

	//--PROCESS Biofilms
	selectWindow("firstSliceMask");
	Stack.getDimensions(width, height, channels, slices, FRAMES);
	getVoxelSize(vx, vy, vz, unit);

	//Array.print(newArray(width, height, channels, slices, frames));
			
    selectWindow("firstSliceMask");
    run("Subtract Background...", "rolling=100 stack");
    
    // Preprocessing steps to enhance image quality
    run("Median...", "radius=1 stack");
    run("Unsharp Mask...", "radius=5 mask=0.60 stack");
    	
    autoThreshold("firstSliceMask", "Huang");
    
    // Post-processing to clean up segmentation
    run("Median...", "radius=1 stack");
    //minBacSize = 25;
    run("Analyze Particles...", "size=" + minBacSize + "-Infinity pixel show=Masks in_situ stack");
    run("Clear Results");
    
    addOverlay2dTime("imageToSave", "firstSliceMask", 1, "green",1);
    selectWindow("imageToSave");
	saveAs("Tiff", output+File.separator+"AnalyzedImages"+File.separator+MyTitle+"_FirstLayerOverlay.tif");
	wait(100);
    rename("imageToSave");
    
    roiManager("reset");
    selectWindow("imageToSave");
 	run("To ROI Manager");
 	roiManager("Show All with labels");
	roiManager("Show None");
	
    // Clear intermediate results before generating new ones
    run("Clear Results");
 
 	run("Set Measurements...", "area redirect=None decimal=2");
 	roiManager("measure");
 	areaFirstSlice=Table.getColumn("Area");

    // Calculate total scanned volume (FOV)
    getVoxelSize(vx, vy, vz, unit);
    Stack.getDimensions(width, height, channels, slices, frames);
    FOV = 1024 * 1024 * vx * vy ; // Volume in cubic microns
    //print(FOV);
           
    rBiofilm = devideArrayByScalar(areaFirstSlice, FOV);
    rBiofilm = multiplyArrayByScalar(rBiofilm,100);
	// Save quantification results for the current frame
    run("Clear Results");
    if (File.exists(output + File.separator + "QuantificationResults_IF2dTime_BiofilmQuantification.xls")) {
        open(output + File.separator + "QuantificationResults_IF2dTime_BiofilmQuantification.xls");
        IJ.renameResults("Results");
    }
	
    for (i = 1; i <= lengthOf(rBiofilm); i++) {
    	    
	    j = nResults; // Append new results to existing table
	    setResult("[Label]", j, MyTitle);
	    setResult("Frame",j, i);
	    setResult("FOV Area (um^2)", j, FOV);
	    setResult("FirstLayer Biofilm Surface Area (um^2)", j, areaFirstSlice[i-1]);
	    setResult("FirstLayer Biofilm density (%)", j, rBiofilm[i-1]);
	    Table.update;
	}	 
	
    saveAs("Results", output + File.separator + "QuantificationResults_IF2dTime_BiofilmQuantification.xls");	
	close("*");
    
   	//Clear unused memory
	wait(500);
	run("Collect Garbage");
	
}



function biofilm4d(output,InDir,name,thBac,minBacSize)
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
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	output=getInfo("image.directory");
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	rename("orig");
	
	//cropOutOfFocus("orig");

	//selectWindow("inFocus");
	run("Duplicate...", "title=imageToSave duplicate ");

	setBatchMode(true);
			
	run("Colors...", "foreground=black background=white selection=yellow");
	
	run("Set Measurements...", "area mean redirect=None decimal=2");
	
	//--PROCESS Biofilms
	//selectWindow("inFocus");
	Stack.getDimensions(width, height, channels, slices, FRAMES);
	getVoxelSize(vx, vy, vz, unit);

	//Array.print(newArray(width, height, channels, slices, frames));
			
	for (i = 1; i <=FRAMES; i++){
	    
	    print("Processing frame: " + i);
	   //  selectWindow("inFocus");
	    i=1;
	    run("Duplicate...", "duplicate title=singleFrameBiofilm frames="+i);
	    run("Subtract Background...", "rolling=50 stack");
	   // print(i);
	    
	    // Preprocessing steps to enhance image quality
	    run("Median...", "radius=1 stack");
	    run("Unsharp Mask...", "radius=5 mask=0.60 stack");
	    
	    // Apply automatic thresholding using Otsu's method
	    autoThreshold("singleFrameBiofilm", "Huang");
	    
	    // Post-processing to clean up segmentation
	    run("Median...", "radius=1 stack");
	    minBacSize = 50;
	    run("Analyze Particles...", "size=" + minBacSize + "-Infinity pixel show=Masks in_situ stack");
	    run("Clear Results");
	    
	    // Add 4D overlay for visualization
	    addOverlay4D("imageToSave", "singleFrameBiofilm", cBiofilm, "green", i);
	    //print(i);
	 	    
	    // Clear intermediate results before generating new ones
	    run("Clear Results");

	    // Calculate 3D biofilm volume and morphology metrics
	    selectWindow("singleFrameBiofilm");
	    run("Analyze Regions 3D", "volume surface_area surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
	    selectWindow("singleFrameBiofilm-morpho");
	    IJ.renameResults("Results");
	    Vol_Biofilm = getResult("Volume", 0); // Extract biofilm volume
	    //print(i);
	    run("Clear Results");
	
	    // Calculate total scanned volume (FOV)
	    selectWindow("singleFrameBiofilm");
	    getVoxelSize(vx, vy, vz, unit);
	    Stack.getDimensions(width, height, channels, slices, frames);
	    FOV = 1024 * 1024 * slices * vx * vy * vz; // Volume in cubic microns
	    
	    // Compute biofilm volume density as a percentage of the total scanned volume
	    rBiofilm = (Vol_Biofilm / FOV) * 100;
		
	    // Calculate average biofilm thickness
	    selectWindow("singleFrameBiofilm");
	    run("Duplicate...", "duplicate title=BiofilmThickness");
	    run("Select None");
	    run("Invert LUT");
	    run("Divide...", "value=255 stack");
	    run("Z Project...", "projection=[Sum Slices]");
	    rename("BiofilmSeg_projection");
	    run("Clear Results");
	    run("Select All");
	    run("Measure");
	    setAutoThreshold("Default dark");
	    setThreshold(0.5, 1e8); // Define intensity range for thickness measurement
	    run("Create Selection");
	    run("Measure");
	    run("Select None");
	    resetThreshold();
	
	    // Extract average thickness metrics and convert to microns
	    Thick_bio = getResult("Mean", 0) * vz; // Average thickness
	    Thick_nz_bio = getResult("Mean", 1) * vz; // Non-zero thickness
	    
        //print(i);
        
        close("singleFrameBiofilm");
		
	    // Save quantification results for the current frame
	    run("Clear Results");
	    if (File.exists(output + File.separator + "QuantificationResults_IF4d_BiofilmQuantification.xls")) {
	        open(output + File.separator + "QuantificationResults_IF4d_BiofilmQuantification.xls");
	        IJ.renameResults("Results");
	    }
	    j = nResults; // Append new results to existing table
	    setResult("[Label]", j, MyTitle);
	    setResult("Frame",j, i);
	    setResult("FOV volume (um^3)", j, FOV);
	    setResult("Biofilm volume (um^3)", j, Vol_Biofilm);
	    setResult("Biofilm density (%)", j, rBiofilm);
	    setResult("Biofilm avg thickness (um)", j, Thick_bio);
	    setResult("Biofilm avg thickness in non-zero voxels (um)", j, Thick_nz_bio);
	    saveAs("Results", output + File.separator + "QuantificationResults_IF4d_BiofilmQuantification.xls");
	    
	}

	 
    // Final inspection or confirmation before processing next frame

	//--Save binary segmentation image
	//selectWindow("final");
	selectWindow("imageToSave");
	wait(100);
	saveAs("Tiff", output+File.separator+"AnalyzedImages"+File.separator+MyTitle+"_BiofilmSegmentation_Overlay.tif");
		
	//run("Synchronize Windows");
	
	if (InDir!="-") {
		close(); 
	}
		 
	//Clear unused memory
	wait(500);
	run("Collect Garbage");
	
	close("*");
		
}

 // Compute biofilm volume density as a percentage of the total scanned volume
function devideArrayByScalar(array,scalar){
	
	// * @return {array}  - An array.
	// * @param {scalar}  - float scalar.
			
		new=newArray();
		for (i = 0; i < lengthOf(array); i++) {
			new[i]=array[i]/scalar;
		}
		return new;
} 
	
function multiplyArrayByScalar(array,scalar){

// * @return {array}  - An array.
// * @param {scalar}  - float scalar.
	new=newArray();
	for (i = 0; i < lengthOf(array); i++) {
		new[i]=array[i]*scalar;
	}
	return new;
}

function cropOutOfFocus(image){

	function ArrayUnique(array) {
	    // Sort the array first
	    array = Array.sort(array);
	    
	    // Initialize an array to store unique values
	    uniqueA = newArray();
	    
	    // Iterate through the sorted array to find unique values
	    for (i = 0; i < array.length - 1; i++) {
	        // If the current element is different from the next element, it's unique
	        if (array[i] != array[i + 1]) {
	            uniqueA = Array.concat(uniqueA, array[i]);
	        }
	    }
	    
	    // Always add the last element since it's not checked in the loop
	    uniqueA = Array.concat(uniqueA, array[array.length - 1]);
	
	    return uniqueA;
	}
			
	// Function to calculate the mode of an array
	function calculateMode(array) {
	    uniqueArray = ArrayUnique(array);  // Get unique values from the array
	    maxCount = -1;                     // Variable to store the highest frequency
	    mode = -1;                          // Variable to store the mode value
	    
	    // Iterate over the unique values to count occurrences in the original array
	    for (i = 0; i < uniqueArray.length; i++) {
	        count = 0;
	        for (j = 0; j < array.length; j++) {
	            if (array[j] == uniqueArray[i]) {
	                count++;  // Increment the count for the current unique value
	            }
	        }
	        
	        // Update the mode if the current value has a higher count
	        if (count > maxCount) {
	            maxCount = count;
	            mode = uniqueArray[i];
	        }
	    }
	
	    return mode;
	}
	
	selectWindow(image);
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	output=getInfo("image.directory");
	getDimensions(width, height, channels, slices, F);
	run("Set Measurements...", "area mean standard min redirect=None decimal=2");
	
	setBatchMode(true);
	
	if (F>1){
		
		cutOffSlice=newArray();
		
		for (i = 1; i < F; i++) {
	
			// Find Slice with Max Signal
			run("Select All");
			run("Duplicate...", "duplicate title=Frame frames="+i);
			run("Measure Stack...", "channels slices order=czt(default)");
			close("Frame");
			selectWindow("Results");
			meanSliceI=Table.getColumn("Mean");
			run("Clear Results");
			Array.getStatistics(meanSliceI, min, max, mean, stdDev);
			
			//Array.print(newArray(min, max, mean, stdDev));
			maxMarker1=Array.findMaxima(meanSliceI,stdDev);
			//Array.print(maxMarker1);
			selectWindow(image);
			if (maxMarker1[0]==0){
				cutOffSlice[i-1]=1;
			}else{
				cutOffSlice[i-1]=maxMarker1[0]+1;
			}
			
			//Array.print(cutOffSlice);
		}
		
		mode=calculateMode(cutOffSlice);
		
		selectWindow(image);
		run("Duplicate...", "title=inFocus duplicate slices="+mode+"-"+slices);
		close(image);
		
		selectWindow("inFocus");
		saveAs("Tiff", output+File.separator+MyTitle+"_inFocus.tif");
		rename("inFocus");
		setBatchMode("exit and display");
				
	}
}




function autoThreshold(image,method){

	selectWindow(image);
	
	// Find Slice with Max Signal
	run("Select All");
	run("Measure Stack...");
	selectWindow("Results");
	meanSliceI=Table.getColumn("Mean");
	Array.getStatistics(meanSliceI, min, max, mean, stdDev);
	//Array.print(newArray(min, max, mean, stdDev));
	maxMarker1=Array.findMaxima(meanSliceI,stdDev);
	//Array.print(maxMarker1);
	selectWindow(image);
	if (maxMarker1[0]==0){
		setSlice(1);
	}else{
		setSlice(maxMarker1[0]+1);
	}
		
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



function fixThreshold(image,thBac){
	
	selectWindow(image);
	
	// Find Slice with Max Signal
	run("Select All");
	run("Measure Stack...");
	selectWindow("Results");
	meanSliceI=Table.getColumn("Mean");
	Array.getStatistics(meanSliceI, min, max, mean, stdDev);
	//Array.print(newArray(min, max, mean, stdDev));
	maxMarker1=Array.findMaxima(meanSliceI,stdDev);
	//Array.print(maxMarker1);
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

function addOverlay2dTime(rawImage,maskImage,channel,color,slice){
		
		selectWindow(rawImage);
		
		getDimensions(width, height, channels, slices, frames);
		Array.print(newArray(width, height, channels, slices, frames));
		RoiManager.associateROIsWithSlices(false);	
	
		// Ensure the image is a stack
		if (frames > 1) {
		    // Loop through each slice
		    for (f = 1; f <= frames; f++) {
		    	selectWindow(maskImage);
		    	// Create an ROI from the binary image
		        Stack.setFrame(f);
		        run("Select None");
		        run("Create Selection");
		        wait(5);
		        type=selectionType();
		        if(type!=-1){
		        	selectWindow(rawImage);
		        	Stack.setFrame(f);
    			    run("Restore Selection");
		          	//	Array.print(newArray(channel,s,frame));
        	       	selectWindow(rawImage);
					Overlay.addSelection(color);
					Overlay.setPosition(channel, slice, f);				
		        }

		    }
		}else{
		    print("The image is not a stack.");
		}
}


function addOverlay4D(rawImage,maskImage,channel,color,frame){
		
		selectWindow(rawImage);
		Stack.setFrame(frame);
		
		getDimensions(width, height, channels, slices, frames);
		RoiManager.associateROIsWithSlices(true);	
	
		// Ensure the image is a stack
		if (slices > 1) {
		    // Loop through each slice
		    for (s = 1; s <= slices; s++) {
		    	selectWindow(maskImage);
		        setSlice(s);
		        selectWindow(maskImage);
		        // Create an ROI from the binary image
		        run("Create Selection");
		        wait(5);
		        type=selectionType();
		        if(type!=-1){
		        	selectWindow(rawImage);
		        	Stack.setChannel(channel);
        			Stack.setFrame(frame);
    			    Stack.setSlice(s);
        	       	run("Restore Selection");
        	       	//	Array.print(newArray(channel,s,frame));
        	       	selectWindow(rawImage);
					Overlay.addSelection(color);
					Overlay.setPosition(channel, s, frame);				
		        }
		    }
		}else{
		    print("The image is not a stack.");
		}
}
	

