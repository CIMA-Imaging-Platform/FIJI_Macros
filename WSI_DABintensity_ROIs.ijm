
// changelog February 2022
// Manual selection of areas for the analysis
// Background subtraction for white balance
// Threshold DAB signal and quantify average intensity of positive areas


function macroInfo(){
	
// * Quantification of Brown WSI Images Area  
// * Target User: General
// *  

	scripttitle= "Quantificication of DAB Intensity of ROIs drawn manually";
	version= "1.03";
	date= "2022";
	

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
//	 parameter2="Tissue Threshold (8bit) = Separate Tissue from Background";
	 parameter3="Brown Marker Threshold (8bit) = Separate Brown(+) ROIs form Brown(-) ROIs";
	 
     
 //  2 Action tools:
	 buttom1="Im: Single File processing";
	 buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs

	excel="Results.xls";
	feature1="Image Label";
	feature2="Area of analysis (um2)";
	feature3="DAB+ area (um2)";
	feature4="DAB+ avg intensity";
	
/*  	  
 *  version: 1.02 
 *  Author: Mikel Ariz  
 *  Commented by: Tomas Muñoz 2023 
 *  Date : 2022
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
	//    +"<li>"+parameter2+"</li>"
	    +"<li>"+parameter3+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");
	    
	    
	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}



var r=0.502, th_brown=240;	

macro "BrownDetection Action Tool 1 - Cf00T2d15IT6d10m"{

	macroInfo();
	
	name=File.openDialog("Select File");
	print(name);
		
	open(name);
	
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	rename("orig");
	
	setBatchMode(true);
	run("Colors...", "foreground=white background=black selection=green");
	
	//MANUALLY SELECT AREA OF INTEREST
	
	setTool("freehand");
	waitForUser("Please, select an area for the analysis and press ok when ready");
	type = selectionType();
	  if (type==-1)	//if there is no selection, select the whole image
	      run("Select All");
	run("Add to Manager");	// ROI0 --> area to quantify
	q=getBoolean("Do you want to add more areas?");
	while(q){
		waitForUser("Please, select an area to add and press ok when ready");
		roiManager("Add");
		roiManager("Deselect");
		roiManager("Select", newArray(0,1));
		roiManager("Combine");
		roiManager("Add");
		roiManager("Deselect");
		roiManager("Select", newArray(0,1));
		roiManager("Delete");
		roiManager("Select", 0);				
		q=getBoolean("Do you want to add more areas?");	
	}
	
	
	selectWindow("orig");
	run("Select None");
	run("Subtract Background...", "rolling=100 light");
	
	//--DAB
	
	run("Colour Deconvolution", "vectors=[H&E DAB] hide");
	//selectWindow(MyTitle+"-(Colour_3)");
	selectWindow("orig-(Colour_2)");
	close();
	selectWindow("orig-(Colour_1)");
	close();
	selectWindow("orig-(Colour_3)");
	rename("brown");
	
	run("Duplicate...", "title=brownMask");
	setAutoThreshold("Default");
		//th_brown=150;
	setThreshold(0, th_brown);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=2");
	run("Analyze Particles...", "size=30-Infinity show=Masks in_situ");
	run("Create Selection");
	flagNoBrown=false;
	type=selectionType();
	if(type==-1) {
		flagNoBrown=true;
		makeRectangle(1, 1, 1, 1);
	}
	run("Add to Manager");	// ROI1 --> DAB+ signal 
	close();
	
	// Save just brown in tissue
	roiManager("Deselect");
	roiManager("Select", 0);
	roiManager("Select", newArray(0,1));
	roiManager("AND");
	type=selectionType();
	if(type==-1) {
		flagNoBrown=true;
		makeRectangle(1, 1, 1, 1);
	}
	roiManager("Add");
	roiManager("Deselect");
	roiManager("Select", 1);
	roiManager("Delete");
	
	// RESULTS--
	
	run("Clear Results");
	selectWindow("brown");	
	run("Invert");	// invert brown image for intensity measurements
	run("Set Measurements...", "area mean redirect=None decimal=2");
	
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
	Iavg=getResult("Mean",1);
	//in micra
	Apm=Ap*r*r;
	if(flagNoBrown) {
		Apm=0;
		Iavg=NaN;
	}
	
	run("Clear Results");
	if(File.exists(output+File.separator+"Results.xls"))
	{
		
		//if exists add and modify
		open(output+File.separator+"Results.xls");
		IJ.renameResults("Results");
	}
	i=nResults;
	setResult("Label", i, MyTitle); 
	setResult("Area of analysis (um2)",i,Atm);
	setResult("DAB+ area (um2)",i,Apm);
	setResult("DAB+ avg intensity",i,Iavg);			
	saveAs("Results", output+File.separator+"Results.xls");
	
	setBatchMode(false);
	
	selectWindow("orig");
	roiManager("Show None");
	roiManager("Select", 0);
	roiManager("Set Color", "yellow");
	roiManager("Set Line Width", 2);
	run("Flatten");
	roiManager("Show None");
	roiManager("Select", 1);
	roiManager("Set Color", "green");
	roiManager("Set Line Width", 2);
	run("Flatten");
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	rename(MyTitle_short+"_analyzed.jpg");
	
	selectWindow("brown");
	close();
	selectWindow("orig");
	close();
	setTool("zoom");
	selectWindow("orig-1");
	close();
	
	showMessage("Done!");

}


macro "BrownDetection Action Tool 1 Options" {
     Dialog.create("Parameters");

     Dialog.addMessage("Choose parameters")
     Dialog.addNumber("micra/px ratio", r);
     Dialog.addNumber("Threshold for brown detection", th_brown);  
     Dialog.show();
     
     r= Dialog.getNumber();
     th_brown= Dialog.getNumber();  
             
}
