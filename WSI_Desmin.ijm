// Changelog March 2023
// Automatic tissue detection adapted from BrownDetectionArea

function macroInfo(){
	
// * Quantification of Brown WSI Images Area  
// * Target User: General
// *  

	scripttitle= "Quantification of Brown Desmin Stained Area removing nonspecific stained around vessels";
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
	 parameter3="Brown Marker Threshold (8bit) = Separate Brown(+) ROIs form Brown(-) ROIs";
	 parameter4="Vessels nonspecific ROI (pixel): Removing desmin (XX) pixels distance from vessels contour.";
	 
 
 //  2 Action tools:
	 buttom1="Im: Single File processing";
	 buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs

	excel="ResultsCuantificacionDesmina.xls";
	feature1="Image Label";
	feature2="Tissue Area (micra²)";
	feature3="Stained area (micra²)";
	feature4="Ratio Area stained/Area tissue (%)"



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
	    +"<p><font size=3  i>PARAMETERS: </i></p>"
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
	



var r=0.502, th_tissue=230, th_brown=160, vessels=15;

macro "Desmin Action Tool 1 - Cf00T2d15IT6d10m"{
	
	macroInfo();
	
	//just one file
	name=File.openDialog("Select File");
	

	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Choose parameters")	
    Dialog.addNumber("micra/px ratio", r);
    Dialog.addNumber("Threshold for tissue detection", th_tissue); 
    Dialog.addNumber("Threshold for brown detection", th_brown);  
    Dialog.addNumber("Size Vessels", vessels);  
    Dialog.show();
    r= Dialog.getNumber();
    th_tissue= Dialog.getNumber();
    th_brown= Dialog.getNumber();  
    vessels= Dialog.getNumber();  
    
	//setBatchMode(true);
	browndetection("-","-",name,r,th_tissue,th_brown,vessels);
	setBatchMode(false);
	showMessage("Done!");

}

macro "Desmin Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	
	macroInfo();
	
	InDir=getDirectory("Choose a Directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Choose parameters")	
    Dialog.addNumber("micra/px ratio", r);
    Dialog.addNumber("Threshold for tissue detection", th_tissue); 
    Dialog.addNumber("Threshold for brown detection", th_brown);  
    Dialog.addNumber("Size Vessels", vessels); 
    Dialog.show();
    r= Dialog.getNumber();
    th_tissue= Dialog.getNumber();
    th_brown= Dialog.getNumber();  
    vessels= Dialog.getNumber();  

	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"jpg")||endsWith(list[j],"tif")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print(name);
			//setBatchMode(true);
			browndetection(InDir,InDir,list[j],r,th_tissue,th_brown,vessels);
			setBatchMode(false);
			}
	}
	showMessage("Done!");
}


function browndetection(output,InDir,name,r,th_tissue,th_brown,vessels)
{
	
	if (InDir=="-") {open(name);}
	else {
		if (isOpen(InDir+name)) {}
		else { open(InDir+name); }
	}

	
	//getDimensions(width, height, channels, slices, frames);
	
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	print("Processing "+MyTitle);
	setBatchMode(true);
	run("Colors...", "foreground=white background=black selection=green");
	
	// DETECT TISSUE
	run("Select All");
	showStatus("Detecting tissue...");
	print("Detecting tissue...");
	run("RGB to Luminance");
	rename("a");
	run("Threshold...");
	//setAutoThreshold("Huang");
	//getThreshold(lower, upper);
	th_tissue=230;
	setThreshold(0, th_tissue);
	run("Convert to Mask");
	run("Median...", "radius=12");
	run("Invert");
	run("Fill Holes");
	run("Analyze Particles...", "size=3000-Infinity pixel show=Masks in_situ");
	run("Invert");
	
	// ROI1 --> whole tissue
	run("Create Selection"); 	
	run("Add to Manager");
	run("Select None");
	selectWindow("a");
	run("Duplicate...", " ");
	run("Fill Holes");
	imageCalculator("XOR create", "a","a-1");
	
	// ROI2 --> Vessels
	selectWindow("Result of a");
	run("Create Selection");
	print("Detecting vessels...");
	run("Add to Manager");	
	run("Select None");
	close("Result of a");
	close("a-1");
	close("a");
	close("Threshold");
	
	
	//BROWN--
	
	flagBrown=false;
		selectWindow(MyTitle);
	run("Colour Deconvolution", "vectors=[H&E DAB] hide");
	//selectWindow(MyTitle+"-(Colour_3)");
	close(MyTitle+"-(Colour_2)");
	close(MyTitle+"-(Colour_1)");
	print("Segmenting Desmin");
	selectWindow(MyTitle+"-(Colour_3)");
	run("Threshold...");
	setAutoThreshold("Default");
	th_brown=160;
	setThreshold(0, th_brown);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	close("Threshold");
	run("Median...", "radius=1");
	roiManager("Show None");
	
	//Enlarge 
	roiManager("Select", 1);
	run("Enlarge...", "enlarge="+vessels);
	setForegroundColor(255, 255, 255);
	run("Fill", "slice");
	
	run("Create Selection");
	type=selectionType();
	if(type==-1) {
		makeRectangle(1, 1, 1, 1);
		flagBrown=true;
	}
	run("Add to Manager");	// ROI1 --> Whole brown
	close();
	
	
	// RESULTS--
	
	run("Clear Results");
	selectWindow(MyTitle);	
	run("Set Measurements...", "area redirect=None decimal=2");
	print("Saving Results");
	
	// Tissue
	roiManager("select", 0);
	roiManager("Measure");
	At=getResult("Area",0);
	//in micra
	Atm=At*r*r;
	
	// Staining
	roiManager("select", 2);
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
	if(File.exists(output+File.separator+"ResultsCuantificacionDesmina.xls"))
	{
		//if exists add and modify
		open(output+File.separator+"ResultsCuantificacionDesmina.xls");
		IJ.renameResults("Results");
	}
	i=nResults;
	setResult("Label", i, MyTitle); 
	setResult("Tissue area (micra²)",i,Atm);
	setResult("Stained area (micra²)",i,Apm);
	setResult("Ratio Astained/Atissue (%)",i,r1);			
	saveAs("Results", output+File.separator+"ResultsCuantificacionDesmina.xls");
	
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	setBatchMode(false);
	selectWindow(MyTitle);
	rename("orig");
	
	roiManager("Show None");
	roiManager("Select", 0);
	roiManager("Set Color", "yellow");
	roiManager("Set Line Width", 2);
	run("Flatten");
	roiManager("Show None");
	roiManager("Select", 2);
	roiManager("Set Color", "green");
	roiManager("Set Line Width", 1);
	run("Flatten");
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	rename(MyTitle_short+"_analyzed.jpg");
	
	close("orig");
	setTool("zoom");
	close("orig-1");

	
	if (InDir!="-") {
	close(); }
	
	//showMessage("Done!");

}

