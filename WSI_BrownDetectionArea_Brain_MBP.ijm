function macroInfo(){
	
// * Quantification of Brown WSI Images Area  adapted for Brain tissue
// * Target User: General
// *  

	scripttitle= "Quantification of Brown Stained Area: Parameters adapted for Brain tissue";
	version= "1.03";
	date= "2015";
	

// *  Tests Images:

	imageAdquisition="Aperio: BrightField Whole Slide Imaging Images.";
	imageType="RGB";  
	voxelSize="Voxel size:  0.502 um xy";
	format="Format: Uncompressed .jpg";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button 
	 parameter1="Resolution (micra pixel ratio) = 0.502 micras/pixel xy"; 
	 parameter2="Tissue Threshold (8bit) = Separate Tissue from Background";
	 parameter3="Brown Marker Threshold (8bit)= Separate Brown(+) ROIs form Brown(-) ROIs";
	 parameter4="Min size of stained particles (px): Size Filter."
 
 //  2 Action tools:
	 buttom1="Im: Single File processing";
	 buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs

	excel="WSI_BrownArea_Brain_Results.xls";
	feature1="Image Label";
	feature2="Tissue Area (micra²)";
	feature3="Stained area (micra²)";
	feature4="Ratio Area stained/Area tissue (%)"

/*  	  
 *  version: 1.02 
 *  Author: Mikel Ariz  
 *  Commented by: Tomas Muñoz 2023 
 *  Date : // Changelog June 2021
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
	    +"<ol><font size=2  i><li>"+buttom1+"</li>"
	    +"<li>"+buttom2+"</li></ol>"
	    +"<p><font size=3  i>PARAMETERS: Right Click on Action tools  </i></p>"
	    +"<ul id=list-style-3><font size=2  i>"
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li>"
	    +"<li>"+parameter3+"</li>"
	    +"<li>"+parameter4+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}


var r=0.502, th_tissue=243, th_brown=145, minSize=5;	

macro "BrownDetection Action Tool 1 - Cf00T2d15IT6d10m"{
	
	run("Fresh Start");
	run("Collect Garbage");
	
	//just one file
	macroInfo();
	name=File.openDialog("Select File");
	print("Processing "+name);

	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Choose parameters")	
    Dialog.addNumber("micra/px ratio", r);
    Dialog.addNumber("Threshold for tissue detection", th_tissue); 
    Dialog.addNumber("Threshold for brown detection", th_brown);  
    Dialog.addNumber("Min size of stained particles (px)", minSize);  
    Dialog.show();
    r= Dialog.getNumber();
    th_tissue= Dialog.getNumber();
    th_brown= Dialog.getNumber();  
    minSize= Dialog.getNumber();  
    
	//setBatchMode(true);
	browndetection("-","-",name,r,th_tissue,th_brown,minSize);
	setBatchMode(false);
	showMessage("Done!");

}

macro "BrownDetection Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	run("Fresh Start");
	run("Collect Garbage");
	
	macroInfo();
	InDir=getDirectory("Choose a Directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Choose parameters")	
    Dialog.addNumber("micra/px ratio", r);
    Dialog.addNumber("Threshold for tissue detection", th_tissue); 
    Dialog.addNumber("Threshold for brown detection", th_brown);  
    Dialog.addNumber("Min size of stained particles (px)", minSize);  
    Dialog.show();
    r= Dialog.getNumber();
    th_tissue= Dialog.getNumber();
    th_brown= Dialog.getNumber();  
    minSize= Dialog.getNumber(); 

	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"jpg")||endsWith(list[j],"tif")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print(name);
			//setBatchMode(true);
			browndetection(InDir,InDir,list[j],r,th_tissue,th_brown,minSize);
			setBatchMode(false);
			}
	}
	showMessage("Done!");
}


function browndetection(output,InDir,name,r,th_tissue,th_brown,minSize)
{
	
	if (InDir=="-") {open(name);}
	else {
		if (isOpen(InDir+name)) {}
		else { open(InDir+name); }
	}


	//getDimensions(width, height, channels, slices, frames);
	
	roiManager("Reset");
	run("Clear Results");
	run("Options...", "iterations=1 count=1");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	setBatchMode(true);
	run("Colors...", "foreground=white background=black selection=green");
	
	// DETECT TISSUE
	
	run("Select All");
	showStatus("Detecting tissue...");
	run("RGB to Luminance");
	rename("a");
		
	
	modeBckg=correctBackground("a");
	
	run("Median...", "radius=1");
	//run("Subtract Background...", "rolling=200 light");
	
	getHistogram(values, counts, 256);
	peaks=Array.findMinima(counts, 20);
	Array.print(peaks);
	thTissue=Array.findMaxima(peaks, 100);
	print(peaks[thTissue[0]]);
	th_tissue=peaks[thTissue[0]];
	
	if (th_tissue > 250){
		th_tissue=peaks[thTissue[0]-1];
		print(th_tissue);
	}
	
	selectWindow("a");
	run("Threshold...");
	resetThreshold();
	setThreshold(0, th_tissue);
	setOption("BlackBackground", false);
	//th_tissue=235;
	//setThreshold(0, th_tissue);
	run("Convert to Mask");
	run("Median...", "radius=4");
	run("Invert");
	run("Analyze Particles...", "size=1000-Infinity pixel show=Masks in_situ");
	run("Invert");
	run("Analyze Particles...", "size=20000-Infinity pixel show=Masks in_situ");
	//run("Fill Holes");
	run("Create Selection");
	run("Add to Manager");	// ROI0 --> whole tissue
	close("a");
	
	//BROWN--7
	flagBrown=false;
	
	run("Colour Deconvolution", "vectors=[H&E DAB] hide");
	//selectWindow(MyTitle+"-(Colour_3)");
	selectWindow(MyTitle+"-(Colour_2)");
	close();
	selectWindow(MyTitle+"-(Colour_1)");
	roiManager("select", 0);
	medianTissue=getValue("Median");
	print(medianTissue);
	close();
	selectWindow(MyTitle+"-(Colour_3)");
	roiManager("select", 0);
	medianMarker=getValue("Median");
	print(medianMarker);
	
	// Correcting background and processing red channel
	showStatus("Correcting background...");
		
	run("Threshold...");
	setAutoThreshold("Default");
	//th_brown=160;
	setThreshold(0, th_brown);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Analyze Particles...", "size=5-Infinity show=Masks in_situ");
	run("Analyze Particles...", "size="+minSize+"-Infinity show=Masks in_situ");
	roiManager("Show None");
	run("Create Selection");
	type=selectionType();
	if(type==-1) {
		makeRectangle(1, 1, 1, 1);
		flagBrown=true;
	}
	run("Add to Manager");	// ROI1 --> Whole brown
	close();
	
	// Save just brown in tissue
	roiManager("Deselect");
	roiManager("Select", 0);
	roiManager("Select", newArray(0,1));
	roiManager("AND");
	type=selectionType();
	if(type==-1) {
		makeRectangle(1, 1, 1, 1);
		flagBrown=true;
	}
	roiManager("Add");
	roiManager("Deselect");
	roiManager("Select", 1);
	roiManager("Delete");
	
	// RESULTS--
	
	run("Clear Results");
	selectWindow(MyTitle);	
	run("Set Measurements...", "area redirect=None decimal=2");
	
	// Tissue
	roiManager("select", 0);
	roiManager("Measure");
	At=getResult("Area",0);
	//in micra
	Atm=At*r*r;
	
	// Staining
	roiManager("select", 1);
	roiManager("Measure");
	Ap=getResult("Area",1);
	//in micra
	Apm=Ap*r*r;
	
	if (flagBrown) {
		Apm=0;
	}
	
	// Ratio
	r1=Apm/Atm*100;
	
	run("Clear Results");
	if(File.exists(output+File.separator+"WSI_BrownArea_Brain_Results.xls"))
	{
		//if exists add and modify
		open(output+File.separator+"WSI_BrownArea_Brain_Results.xls");
		IJ.renameResults("Results");
	}
	i=nResults;
	setResult("[Label]", i, MyTitle); 
	setResult("background", i, modeBckg);
	setResult("HE", i, medianTissue);
	setResult("Marker", i, medianMarker);
	setResult("thTissue", i, th_tissue);
	setResult("thMarker", i, th_brown);
	setResult("minSize", i, minSize);
	setResult("Tissue area (micra2)",i,Atm);
	setResult("Stained area (micra2)",i,Apm);
	setResult("Ratio Astained/Atissue (%)",i,r1);			
	saveAs("Results", output+File.separator+"WSI_BrownArea_Brain_Results.xls");
	
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	setBatchMode(false);
	selectWindow(MyTitle);
	rename("orig");
	
	roiManager("Show None");
	roiManager("Select", 0);
	roiManager("Set Color", "yellow");
	run("Flatten");
	roiManager("Show None");
	roiManager("Select", 1);
	roiManager("Set Color", "green");
	run("Flatten");
	saveAs("Jpeg", OutDir+File.separator+MyTitle+"_analyzed.jpg");
	rename(MyTitle_short+"_analyzed.jpg");
	
	selectWindow("Threshold");
	run("Close");
	selectWindow("orig");
	close();
	setTool("zoom");
	selectWindow("orig-1");
	close();
	
	if (InDir!="-") {
	close(); }
	
	close("*");
	run("Collect Garbage");
	//showMessage("Done!");

}


function correctBackground(image) {
	/**
	 * Adjusts the background intensity of an image based on pixel intensity mode.
	 * Supports global and tissue-specific correction modes.
	 * 
	 * @param {string} image - Name of the image window to correct.
	 * @returns {number} mode - The mode of pixel intensity used for adjustment.
	 * 
	 * Modes:
	 * - **Global Correction**: Calculates the mode for the entire image. If mode > 200, adjusts brightness by adding (255 - mode) to all pixels.
	 * - **Tissue-Specific Correction**: Calculates the mode within a selected ROI. Adjustment logic for this mode is incomplete.
	 * 
	 * Requirements:
	 * - For tissue-specific correction, an ROI must be present in the ROI Manager.
	 * 
	 * Note: Global correction is enabled by default.
	 */

	
	
    // Set to true for global background correction; false for tissue-specific correction.
    globalMode = true;

    if (globalMode) {
        // Global background correction
        run("Clear Results");
        run("Set Measurements...", "area mean modal redirect=None decimal=2");
        run("Select All");
        
        // Get the mode of pixel intensity
        mode = getValue("Mode");
        print(mode);

        // Adjust brightness if mode exceeds threshold
        if (mode > 200) {
            dif = 255 - mode;
            selectWindow(image);
            run("Add...", "value=" + dif);
        }

        // Clear measurement results
        run("Clear Results");
    } else {
        // Tissue-specific background correction
        run("Clear Results");
        run("Set Measurements...", "area mean modal redirect=None decimal=2");

        // Assume ROI is preloaded in the ROI Manager
        selectWindow("a");
        roiManager("select", 0);
        run("Measure");

        // Get the mode of pixel intensity within the ROI
        mode = getResult("Mode", 0);

        if (mode > 200) {
            selectWindow(image);
            dif = 255 - mode;
            run("Select None");
        }

        // Clear measurement results
        run("Clear Results");
    }

    return mode; // Return the measured mode
}
