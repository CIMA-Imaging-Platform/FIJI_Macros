function macroInfo(){
	
// * Semiautomatic segmentation of 3D organs in microCT images  
// * Target User: General
// *  

	scripttitle= "Automatic segmentation of 3D Lung in microCT images";
	version= "1.02";
	date= "2025";
	

// *  Tests Images:

	imageAdquisition="microCT images";
	imageType="3D tiff";  
	voxelSize="Voxel size: unknown ";
	format="Format: tif";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button 

	 

 //  2 Action tools:
	buttom1="Dir: Folder File processing";
 	excel = "CT_LungVolumeResults";
 	
 	feature1 = "Whole Lung, Right Lung and Left Lung: Volume, Intensity Distribution Mean and Std "


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

	
	//image1="../templateImages/cartilage.jpg";
	//descriptionActionsTools="
	
	showMessage("ImageJ Script", "<html>"
		+"<style>h{margin-top: 5px; margin-bottom: 5px;} p{margin: 0px;padding: 0px;} ol{margin-left: 20px;padding: 5px;} #list-style-3 {list-style-type: circle;.container {max-width: 1200px; margin: 0 auto; padding: 0px; }</style>"
	    +"<h1><font size=6 color=Teal href=https://cima.cun.es/en/research/technology-platforms/image-platforms>CIMA: Imaging Platform</h1>"
	    +"<h1><font size=5 color=Purple><i>Software Development Service</i></h1>"
	    +"<p><font size=2 color=Purple><i>ImageJ Macros</i></p>"
	    +"<h2><font size=3 color=black>"+scripttitle+"</h2>"
	    +"<p><font size=2>Modified by Tomas Mu&ntilde;oz Santoro</p>"
	    +"<p><font size=2>Version: "+version+" ("+date+")</p>"
	    +"<p><font size=2> contact tmsantoro@unav.es</p>" 
	    +"<p><font size=2> Available for use/modification/sharing under the "+"<p4><a href=https://opensource.org/licenses/MIT/>MIT License</a></p>"
	    +"<h2><font size=3 color=black>Developed for</h2>"
	    +"<p><font size=3  i>Input Images</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+imageAdquisition +"</li><li>"+imageType+"</li><li>"+voxelSize+"</li><li>"+format+"</li></ul>"
	    +"<p><font size=3 i>Action tools (Buttons)</i></p>"
	    +"<ol><font size=2  i><li>"+buttom1+"</li></ol>"
	    +"<p><font size=3  i>PARAMETERS: </i></p>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li</ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}


var r=20;

macro "CT_LungVolume_Auto Action Tool 1 - Ca3fT0b10CT8b10ETfb10LTfb10L"{

	run("Fresh Start");
	roiManager("Reset");
	close("ROI Manager");
	run("Clear Results");
	run("Remove Overlay");
	close("*");	
	
	// Open just one file
	name=File.openDialog("Select File");	
	open(name);

	macroInfo();

	r=1;
	
	MyTitle_short = File.nameWithoutExtension;
	fname=getInfo("image.directory");	
	outDir = fname+File.separator+"AnalyzedImages/";
	
	if (!File.exists(outDir)){
		File.makeDirectory(outDir);				
	}
	
	roiManager("Reset");
	run("ROI Manager...");
	run("Options...", "iterations=1 count=1");
	rename("orig");
	
	setVoxelSize(r,r,r, "voxel");
	
	//-- Lungs Segmentation 
	run("Reslice [/]...", "output=1 start=Top");
	close("orig");
	rename("orig");
	
	run("Duplicate...", "title=LungMask duplicate");
	getDimensions(width, height, channels, slices, frames);
	for (i = 1; i <= slices; i++) {
		setSlice(i);
		run("Enhance Local Contrast (CLAHE)", "blocksize=30 histogram=256 maximum=2.50 mask=*None* fast_(less_accurate)");
	}
	run("3D Fast Filters","filter=Median radius_x_pix=2.0 radius_y_pix=2.0 radius_z_pix=2.0 Nb_cpus=16");
	close("LungMask");
	rename("LungMask");
	run("Duplicate...", "title=AirwaysMask duplicate");
	
	selectWindow("LungMask");
	getDimensions(width, height, channels, slices, frames);
	setSlice(floor(slices/2));
	setThreshold(37500, 41500, "raw");
	waitForUser("threshold for Lung segmentation");
	setOption("BlackBackground", false);	
	run("Convert to Mask", "method=Huang background=Dark");
	run("Analyze Particles...", "size=100-Infinity pixel show=Masks stack in_situ");
	run("3D Fast Filters","filter=Median radius_x_pix=1.0 radius_y_pix=1.0 radius_z_pix=1.0 Nb_cpus=16");
	run("Convert to Mask", "method=Huang background=Dark");
	run("Invert","stack");
	run("Analyze Particles...", "size=20-Infinity pixel show=Masks stack in_situ");
	run("Invert","stack");
	run("Connected Component Labeling");
	waitForUser;
	run("Keep Largest Label");
	close("LungMask");
	close("*Connected*");
	rename("LungMask");
	run("Convert to Mask", "method=Huang background=Dark");
	close("*3D*");
	run("Median...", "radius=1 stack");
	
	//-- Airways Segmentation 
	selectWindow("AirwaysMask");
	getDimensions(width, height, channels, slices, frames);
	setSlice(floor(slices/2));
	run("Enhance Contrast", "saturated=0.35");
	run("Apply LUT", "stack");
	setThreshold(0, 2500, "raw");
	waitForUser("threshold for Lung segmentation");
	setOption("BlackBackground", false);	
	run("Convert to Mask", "method=Huang background=Dark");
	run("Analyze Particles...", "size=10-150 pixel show=Masks exclude stack in_situ");
	run("3D Fast Filters","filter=Median radius_x_pix=2.0 radius_y_pix=2.0 radius_z_pix=4.0 Nb_cpus=16");
	close("AirwaysMask");
	rename("AirwaysMask");
	run("Convert to Mask", "method=Huang background=Dark");
	run("Dilate","stack");
	run("Dilate","stack");
	
	imageCalculator("Substract create stack", "LungMask","AirwaysMask");
	close("LungMask");	
	rename("Lungs");
	close("*mask");
	
	run("Analyze Particles...", "size=250-Infinity pixel show=Masks exclude stack in_situ");
	run("Connected Component Labeling");
	run("Keep Largest Label");
	close("Lungs");
	close("*Connected*");
	rename("Lungs");
	setSlice(nSlices/2);
	run("Convert to Mask", "method=Huang background=Dark");
	run("Median...", "radius=1 stack");
	
	selectWindow("Lungs");
	run("Duplicate...","title=filledLungs duplicate");
	run("Fill Holes","stack");
	
	//--Measure organ volume
	selectWindow("Lungs");
	run("Intensity Measurements 2D/3D", "input=orig labels=Lungs mean stddev max min median mode numberofvoxels volume");
	IJ.renameResults("Results");
	lungVolume = getResult("Volume", 0);
	lungMeanIntensity = getResult("Mean", 0);
	lungStdIntensity = getResult("StdDev", 0);
	
	run("Clear Results");

	//--Measure filled organ volume
	selectWindow("filledLungs");
	run("Intensity Measurements 2D/3D", "input=orig labels=filledLungs mean stddev max min median mode numberofvoxels volume");
	IJ.renameResults("Results");
	filledLungVolume = getResult("Volume", 0);
	filledLungMeanIntensity = getResult("Mean", 0);
	filledLungStdIntensity = getResult("StdDev", 0);
	
	run("Clear Results");

	//--Measure organ volume
	selectWindow("Lungs");
	run("Z Project...", "projection=[Sum Slices]");
	waitForUser("Select Lung of Interest");
	selectWindow("Lungs");
	run("Restore Selection");	
	run("Duplicate...", "title=RightLung ignore duplicate");
	run("Duplicate...", "title=LeftLung ignore duplicate");
	selectWindow("filledLungs");
	run("Restore Selection");
	run("Duplicate...", "title=filledRightLung ignore duplicate");
	run("Duplicate...", "title=filledLeftLung ignore duplicate");
	close("SUM*");
	
	selectWindow("RightLung");
	setForegroundColor(0, 0, 0);
	setBackgroundColor(255, 255, 255);
	run("Clear Outside", "stack");
	run("Select None");
	
	selectWindow("filledRightLung");
	run("Clear Outside", "stack");
	run("Select None");
		
	selectWindow("LeftLung");
	setForegroundColor(255,255,255);
	setBackgroundColor(0,0,0);
	run("Fill", "stack");
	run("Select None");
	
	selectWindow("filledLeftLung");
	setForegroundColor(255,255,255);
	setBackgroundColor(0,0,0);
	run("Fill", "stack");
	run("Select None");
			
	run("Intensity Measurements 2D/3D", "input=orig labels=RightLung mean stddev max min median mode numberofvoxels volume");
	IJ.renameResults("Results");
	lungRVolume = getResult("Volume", 0);
	lungRMeanIntensity = getResult("Mean", 0);
	lungRStdIntensity = getResult("StdDev", 0);
			
	run("Clear Results");
	
	run("Intensity Measurements 2D/3D", "input=orig labels=filledRightLung mean stddev max min median mode numberofvoxels volume");
	IJ.renameResults("Results");
	filledLungRVolume = getResult("Volume", 0);
	filledLungRMeanIntensity = getResult("Mean", 0);
	filledLungRStdIntensity = getResult("StdDev", 0);
			
	run("Clear Results");
	
	run("Intensity Measurements 2D/3D", "input=orig labels=LeftLung mean stddev max min median mode numberofvoxels volume");
	IJ.renameResults("Results");
	lungLVolume = getResult("Volume", 0);
	lungLMeanIntensity = getResult("Mean", 0);
	lungLStdIntensity = getResult("StdDev", 0);
	
	run("Clear Results");
	
	run("Intensity Measurements 2D/3D", "input=orig labels=filledLeftLung mean stddev max min median mode numberofvoxels volume");
	IJ.renameResults("Results");
	filledLungLVolume = getResult("Volume", 0);
	filledLungLMeanIntensity = getResult("Mean", 0);
	filledLungLStdIntensity = getResult("StdDev", 0);
	
	run("Clear Results");
		
	//--Write results
	close("Results");
	run("Clear Results");	
	if(File.exists(fname+File.separator+"CT_LungVolumeResults.xls"))
	{
		open(fname+File.separator+"CT_LungVolumeResults.xls");
		IJ.renameResults("Results");
	}
	i=nResults;
	setResult("Label", i, MyTitle_short); 
	setResult("Lung Volume (mm^3)",i,lungVolume);
	setResult("Lung Mean Intensity",i,lungMeanIntensity);
	setResult("Lung Std Intensity",i,lungStdIntensity);
	setResult("Right Lung Volume (mm^3)",i,lungRVolume);
	setResult("Right Lung Mean Intensity",i,lungRMeanIntensity);
	setResult("Right Lung Std Intensity",i,lungRStdIntensity);
	setResult("Left Lung Volume (mm^3)",i,lungLVolume);
	setResult("Left Lung Mean Intensity",i,lungLMeanIntensity);
	setResult("Left Lung Std Intensity",i,lungLStdIntensity);
	setResult("Filled Lung Volume (mm^3)",i,filledLungVolume);
	setResult("Filled Lung Mean Intensity",i,filledLungMeanIntensity);
	setResult("Filled Lung Std Intensity",i,filledLungStdIntensity);
	setResult("Filled Right Lung Volume (mm^3)",i,filledLungRVolume);
	setResult("Filled Right Lung Mean Intensity",i,filledLungRMeanIntensity);
	setResult("Filled Right Lung Std Intensity",i,filledLungRStdIntensity);
	setResult("Filled Left Lung Volume (mm^3)",i,filledLungLVolume);
	setResult("Filled Left Lung Mean Intensity",i,filledLungLMeanIntensity);
	setResult("Filled Left Lung Std Intensity",i,filledLungLStdIntensity);
	saveAs("Results", fname+File.separator+"CT_LungVolumeResults.xls");
	
	selectWindow("Lungs");
	run("Select None");
	saveAs("Tiff", outDir+MyTitle_short+"_LungMask.tif");
	
	addOverlay3D("orig","LeftLung",1,"blue");
	addOverlay3D("orig","RightLung",1,"magenta");

	selectWindow("orig");
	saveAs("Tiff", outDir+MyTitle_short+"_Analyzed.tif");
	close("\\Others");		
	showMessage("Lungs quantified and saved!");

}


function addOverlay3D(rawImage,maskImage,channel,color){
		
		selectWindow(rawImage);
		getDimensions(width, height, channels, slices, frames);
		
		setBatchMode(true);
		RoiManager.associateROIsWithSlices(true);	
		// Ensure the image is a stack
		if (slices > 1) {
		    // Loop through each slice
		    for (i = 1; i <= slices; i++) {
		    	selectWindow(maskImage);
		        setSlice(i);
		        
		        // Create an ROI from the binary image
		        run("Create Selection");
		        type=selectionType();
		        if(type!=-1){
		        	selectWindow(rawImage);
		        	setSlice(i);
		           	run("Restore Selection");
		           	Roi.setPosition(i);
		        	Overlay.addSelection(color);
					Overlay.setPosition(i);
	
		        }
		    }
		}else{
		    print("The image is not a stack.");
		}

		setBatchMode("exit and display");
		run("Select None");
}
































