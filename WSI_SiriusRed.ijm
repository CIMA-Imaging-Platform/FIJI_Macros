
function macroInfo(){
	
// * Quantification of Sirius Red IHC on WSI Images Area  
// * Target User: General
// *  

	scripttitle= "Quantification of Sirius Red IHC WSImages";
	version= "1.02";
	date= "2023";
	
// *  Tests Images:

	imageAdquisition="Aperio: BrightField Whole Slide Imaging Images.";
	imageType="RGB";  
	voxelSize="Voxel size:  0.502 um xy";
	format="Format: Uncompressed .jpg";   
 
 //*  GUI User Requierments:
 //  	- save and load previous ROIS --> todo
 //*    - Interactive Threshold. --> done
 //*	- Delete Unwanted tissue and SR positive--> done
 //		- Single File and Batch Mode --> done
 //*    
 // Important Parameters: 
 
 	 parameter1="Resolution (micra pixel ratio) = 0.502 micras/pixel xy"; 
	 parameter2="Tissue Threshold (0-255) = Separate Tissue from Background";
	 parameter3="Sirius Red Threshold (0-255): Visual Interactive ";
	 parameter4="Background Compensation Method";
 	 parameter5="Choose Workflow, Automatic or Interactive.";
	 
	  
 //  2 Action tools:
		
	 buttom1="Im: Single File processing. Use Single file processing for fine tunning parameters";
	 buttom2="Dir: Batch Mode. Please tune parameters before using Batchmode";

//  OUTPUT

// Analyzed Images with ROIs

	excel="QuantificationResults_SiriusRed.xls";
	
	feature1="Label";
	feature2="Tissue Area (um2)";
	feature3="Positive Area (um2)";
	feature4="Ratio Ared/Atissue (%)";
	
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
	    +"<ol><font size=2  i><li>"+buttom1+"</li></ol>"
	    +"<p><font size=3  i>PARAMETERS:</i></p>"
	    +"<ul id=list-style-3><font size=2  i>"
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li>"
	    +"<li>"+parameter3+"</li>"
	    +"<li>"+parameter4+"</li>"
	    +"<li>"+parameter5+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");
	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
	   
}

var r=0.502, th_tissue=225, redThreshold=100, corrType="Global correction", minSize=10;

macro "SiriusRed_batch Action Tool 1 - Cf00T2d15IT6d10m"{

	run("Close All");
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	
	Dialog.create("IMAGE ANALYSIS SET UP");
	Dialog.addMessage("Adquisition Objective")
	Dialog.addNumber("micra/px ratio", r);
	Dialog.addMessage("Tissue Detection")
	Dialog.addSlider("Tissue threshold", 0, 255, th_tissue);
	Dialog.addMessage("Sirius Red Detection");
	Dialog.addSlider("Red threshold", 0, 255, redThreshold);
	//modeArray=newArray("Global correction","Tissue correction");
	//Dialog.addRadioButtonGroup("Choose background compensation for sirius red", modeArray, 1, 2, "Global correction");
	workflowArray=newArray("Interactive","Automatic");
	Dialog.addRadioButtonGroup("Choose Workflow", workflowArray, 1, 2, "Automatic");
	Dialog.show();
	
	r= Dialog.getNumber();
	th_tissue= Dialog.getNumber();
	redThreshold= Dialog.getNumber();
	//corrType= Dialog.getRadioButton();
	workflowType= Dialog.getRadioButton();
					
	//setBatchMode(true);
	print(name);
	siriusRed("-","-",name,r,th_tissue,redThreshold,corrType,workflowType,minSize);
	setBatchMode(false);
	showMessage("Done!");

		}
macro "SiriusRed_batch Action Tool 2 - C00fT0b11DT9b09iTcb09r"{

	run("Close All");
	InDir=getDirectory("Choose a Directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("IMAGE ANALYSIS SET UP");
	Dialog.addMessage("Adquisition Objective")
	Dialog.addNumber("micra/px ratio", r);
	Dialog.addMessage("Tissue Detection")
	Dialog.addSlider("Tissue threshold", 0, 255, th_tissue);
	Dialog.addMessage("Sirius Red Detection");
	Dialog.addSlider("Red threshold", 0, 255, redThreshold);
	//modeArray=newArray("Global correction","Tissue correction");
	//Dialog.addRadioButtonGroup("Choose background compensation for sirius red", modeArray, 1, 2, "Global correction");
	workflowArray=newArray("Interactive","Automatic");
	Dialog.addRadioButtonGroup("Choose Workflow", workflowArray, 1, 2, "Automatic");
	Dialog.show();

	r= Dialog.getNumber();
	th_tissue= Dialog.getNumber();
	redThreshold= Dialog.getNumber();
	//corrType= Dialog.getRadioButton();
	workflowType= Dialog.getRadioButton();

	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"tif")||endsWith(list[j],"jpg")){
			
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print(name);
			//setBatchMode(true);
			siriusRed(InDir,InDir,list[j],r,th_tissue,redThreshold,corrType,workflowType,minSize));
			setBatchMode(false);
		}
	}
	showMessage("Done!");
}


function siriusRed(output,InDir,name,r,th_tissue,redThreshold,corrType,workflowType,minSize){

	// Performs Sirius Red detection and analysis.
	// 
	// Parameters:
	// - output: Output directory for saving analyzed images and results.
	// - InDir: Input directory where the image is located.
	// - name: Name of the image file.
	// - r: Micra/pixel ratio.
	// - th_tissue: Tissue threshold value.
	// - redThreshold: Red threshold value for Sirius Red detection.
	// - corrType: Type of background compensation ("Global correction" or "Tissue correction").

	close("*");
	close("Threshold");
	roiManager("Reset");
	run("Clear Results");
	
	if (InDir=="-") {open(name);}
	else {
		if (isOpen(InDir+name)) {}
		else { open(InDir+name); }
	}

	getDimensions(width, height, channels, slices, frames);
	run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width="+r+" pixel_height=+"+r+" voxel_depth=1.0000 frame=[0 sec] origin=0,0");

	MyTitle=getTitle();
	output=getInfo("image.directory");

	run("Colors...", "foreground=black background=white selection=green");

	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);

	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	setBatchMode(false);

	
	//start
	
	run("Select All");
	showStatus("Detecting background...");

	run("Duplicate...", "title=[lum]");
	run("Split Channels");
	selectWindow("lum (blue)");
	close();
	selectWindow("lum (red)");
	close();
	selectWindow("lum (green)");
	rename("a");
	
	setAutoThreshold("Huang");
	setThreshold(0, th_tissue);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=1");
	run("Invert");
	//run("Fill Holes");
	run("Open");
	//run("Analyze Particles...", "size=300-Infinity pixel show=Masks in_situ");
	run("Invert");
	run("Analyze Particles...", "size=5000-Infinity pixel show=Masks in_situ");
	run("Create Selection");
	roiManager("Add");
	selectWindow("a");
	close();

	showStatus("Separating colors...");
	
	//--Colour Deconvolution
	//MyTitle=getTitle();
	selectWindow(MyTitle);
	run("Select All");
	run("Colour Deconvolution", "vectors=[User values] hide [r1]=0.09617791 [g1]=0.6905216 [b1]=0.7168889 [r2]=0.12630461 [g2]=0.2563811 [b2]=0.958288 [r3]=0.8249893 [g3]=0.5651483 [b3]=0.001");
	selectWindow(MyTitle+"-(Colour_2)");
	close();
	selectWindow(MyTitle+"-(Colour_3)");
	close();
	selectWindow(MyTitle+"-(Colour_1)");
	rename("positive");

	
	//--Process red channel
	
	/*
	 * 
	 * 
	//mode subtraction: global for all image mode subtraction, not global for tissue mode subtraction
	if(globalMode) {
		run("Clear Results");
		run("Set Measurements...", "area mean modal redirect=None decimal=2");
		run("Select All");
		run("Measure");
		mod = getResult("Mode", 0);
		if(mod>200) {
			dif = 255-mod;
			run("Add...", "value="+dif);
		}
		run("Clear Results");
	}
	else {
		run("Clear Results");
		run("Set Measurements...", "area mean modal redirect=None decimal=2");
		roiManager("select", 0);
		run("Measure");
		mod = getResult("Mode", 0);
		if(mod>200) {
			dif = 255-mod;
			run("Select None");
			run("Add...", "value="+dif);
		}
		run("Clear Results");
	}
	*/
	
	showStatus("Detecting sirius red...");
	
	if (workflowType == "Interactive"){
	 
		// Detecting Sirius red-positive regions
		selectWindow("positive");
		setBatchMode("show");
		showStatus("Detecting sirius red...");
		run("Threshold...");
		setOption("BlackBackground", true);
		call("ij.process.ImageProcessor.setUnderColor", 0,255,0);
		call("ij.process.ImageProcessor.setOverColor", 255,255,255);
		call("ij.plugin.frame.ThresholdAdjuster.setMode", "Over/Under");
		setThreshold(100, 255);
		waitForUser("Select PicoSirius Red Threshold");
		getThreshold(lower, upper);
		setThreshold(0, lower);
		//setThreshold(0, redThreshold);
		setOption("BlackBackground", false);
		selectWindow("positive");
		setBatchMode("hide");
		run("Convert to Mask");
		run("Create Selection");
		roiManager("Add");
		selectWindow(MyTitle);
		setBatchMode("show");
		run("Restore Selection");
		
		
		// Delete unwanted ROIS	
		deleteROIs=getBoolean("Do you want to Delete unwanted Regions");
		
		while (deleteROIs){
			
			selectWindow(MyTitle);
					
			nRois=roiManager("count");
			if (nRois>1){
				roiManager("select", 1);
				roiManager("delete");
			}
			
			// DELETE
			setTool("freehand");
			
			waitForUser("Please Draw ROI to delete and press ok when ready");
			
			//check if we have a selection
			type = selectionType();
			if (type==-1)	{
				showMessage("Edition", "You should select a region to delete. Otherwise none will be deleted.");
				exit();
			}	
	
			selectWindow("positive");
			//setBatchMode("show");
			run("Restore Selection");
			setForegroundColor(255, 255, 255);
			run("Fill", "slice");
			run("Create Selection");
			selectWindow(MyTitle);
			run("Restore Selection");
			showMessage("Selection deleted");
			selectWindow(MyTitle);
			deleteROIs=getBoolean("Do you want to Delete another unwanted Regions");
			
			
		} 
	}
	
	if (workflowType == "Automatic"){
		selectWindow("positive");
		setBatchMode("show");
		showStatus("Detecting sirius red...");
		setThreshold(0, redThreshold);
		setOption("BlackBackground", false);
		run("Convert to Mask");
		run("Create Selection");
		roiManager("add");
	}
	
	close("Threshold");
	
	//Ratio and results
	selectWindow("positive");
	//run("Properties...", "channels=1 slices=1 frames=1 unit=pixel pixel_width=1.0000 pixel_height=1.0000 voxel_depth=1.0000 frame=[0 sec] origin=0,0");
	run("Analyze Particles...", "size="+minSize+"-Infinity pixel circularity=0.00-1.00 show=Masks clear in_situ");
		
	
	//measure Tissue and positive
	selectWindow(MyTitle);		
	run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width="+r+" pixel_height=+"+r+" voxel_depth=1.0000 frame=[0 sec] origin=0,0");
	
	run("Clear Results");	
	selectWindow("positive");
	run("Set Measurements...", "area redirect=None decimal=2");
	
	selectWindow(MyTitle);	
	roiManager("select", 0);
	roiManager("Measure");
	roiManager("select", 1);
	roiManager("Measure");
	
	
	Tm=getResult("Area",0); //in micra
	T=Tm/(r*r);
	Pm=getResult("Area",1); //in micra
	P=Pm/(r*r);

	
	selectWindow("positive");
	setBatchMode(false);
	run("Close");
	
	run("Clear Results");

	r1=Pm/Tm*100;


	//RESULTS print and save image
	if(File.exists(output+"QuantificationResults_SiriusRed.xls"))
	{
		//if exists add and modify
		open(output+"QuantificationResults_SiriusRed.xls");
		IJ.renameResults("Results");
	}
	i=nResults;
	setResult("[Label]", i, MyTitle); 
	setResult("Tissue Area (um2)",i,Tm);	
	setResult("Positive Area (um2)",i,Pm);
	setResult("Ratio Ared/Atissue (%)",i,r1);
	saveAs("Results", output+"QuantificationResults_SiriusRed.xls");	

		
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
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	rename(MyTitle_short+"_analyzed.jpg");
	close("\\Others");
}

