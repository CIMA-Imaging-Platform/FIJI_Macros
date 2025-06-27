

function macroInfo(){
	
// * Target User: General
// *  

	scripttitle= "Quantification of Clustered Cells Area on PhaseContrast Microscopy ";
	version= "1.01";
	date= "2023";
	

// *  Tests Images:

	imageAdquisition="PhaseContrast Microscopy Images.";
	imageType="RGB";  
	voxelSize="Voxel size:  introduce by user [um/xy]";
	format="Format: Uncompressed .jpg";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button.
 
	 parameter1="Resolution (micra pixel ratio) = 0.502 micras/pixel xy"; 
	 parameter2="Min Cluster size (pixels)";
	 
	  
 //  2 Action tools:
		
	 buttom1="Im: Single File processing. Use Single file processing for fine tunning parameters";
	 buttom2="Dir: Batch Mode. Please tune parameters before using Batchmode";

//  OUTPUT

// Analyzed Images with ROIs

	excel="Results_PHC_ClusterArea.xls";
	feature1="Image Label";
	feature2="# Total Cluster";
	feature3="ID Cluster";
	feature4="Area of Cluster (um2)"
	
/*  	  
 *  version: 1.02 
 *  Author: Tomas Muñoz  
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
	    +"<li>"+parameter2+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}




var r=0.502,  minSize=10, maxSize=1000 ;		// PHCield  5x ¿?

macro "CD8count Action Tool 1 - Cf00T2d15IT6d10m"{
	
	//just one file
	name=File.openDialog("Select image file");
	//print(name);
	print("Processing "+name);
	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Choose parameters")	
	Dialog.addNumber("Ratio micra/pixel", r);		
	Dialog.addNumber("Min Cluster size", minSize);	
	Dialog.show();	
	
	r= Dialog.getNumber();		
	minSize= Dialog.getNumber(); 
	
	//setBatchMode(true);
	clusterArea("-","-",name,r,minSize);
	setBatchMode(false);
	showMessage("CD8 quantified!");

}

macro "CD8count Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	InDir=getDirectory("Choose images directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Choose parameters")	
	Dialog.addNumber("Ratio micra/pixel", r);		
	Dialog.addNumber("Min Cluster size", minSize);	
	Dialog.show();	
	
	r= Dialog.getNumber();		
	minSize= Dialog.getNumber(); 
	
	
	for (j=0; j<L; j++)
	{
		if (endsWith(list[j],"ed.tif") || endsWith(list[j],"ed.jpg")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print("Processing "+name);
			//setBatchMode(true);
			clusterArea(InDir,InDir,list[j],rminSize);
			setBatchMode(false);
			}
	}
	
	showMessage("CD8 quantified!");

}


function clusterArea(output,InDir,name,r,minSize)
{

	run("Close All");
	roiManager("Reset");
	run("Clear Results");
	
	setBatchMode(true);
	run("Collect Garbage");
	
	if (InDir=="-") {open(name);}
	else {
		if (isOpen(InDir+name)) {}
		else { open(InDir+name); }
	}
		
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	run("Colors...", "foreground=black background=white selection=green");
	run("Set Measurements...", "area mean area_fraction redirect=None decimal=2");
	
	// DETECT FOV
	run("Select All");
	
	//Segment Tumor Tissue -> Low Intensity and High density Hemtoxilin
	selectWindow("blue");
	run("Duplicate...", "title=tumor");
	run("Mean...", "radius=1");
	run("Threshold...");
	setAutoThreshold("Default");
	//thTissue=180;
	setThreshold(0, thTissue);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=6");
	run("Analyze Particles...", "size=20000-Infinity show=Masks in_situ");
	run("Invert");
	run("Analyze Particles...", "size=1000-Infinity show=Masks in_situ");
	run("Invert");
	roiManager("Show None");
	run("Create Selection");
	Roi.setName("TumorTissue");
	Roi.setStrokeColor("green")
	run("Add to Manager");	// ROI1 
	close("tumor");
	
	// MEASURE AREA OF ANALYSIS--
	selectWindow(MyTitle);
	run("Select All");
	roiManager("Select", 0);
	roiManager("Measure");
	At=getResult("Area",0);
	Atm=At*r*r;
	run("Clear Results");
	
	// DRAW TISSUE:
	roiManager("Set Color", "yellow");
	roiManager("Set Line Width", 2);
	run("Flatten");
	wait(100);
	rename("orig");
	
	// DETECT BROWN STAINING
	selectWindow("brown");
	run("Mean...", "radius=1");
	run("Threshold...");
	setAutoThreshold("Default");
	//thBrown=175;
	setThreshold(0, thBrown);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Analyze Particles...", "size=1-3000 show=Masks in_situ");
	
	
	/*//Identify posible artefacts
	run("Duplicate...", "title=artefacts");
	run("Analyze Particles...", "size=1000-Infinity show=Masks in_situ");
	run("Create Selection");
	run("Enlarge...", "enlarge=10");
	Roi.setName("artefacts");
	Roi.setStrokeColor("black")
	run("Add to Manager");	// ROI1 2*/
	
	roiManager("Select", 0);
	setBackgroundColor(255, 255, 255);
	run("Clear Outside");
	run("Create Selection");
	Roi.setName("+InmunoCells");
	Roi.setStrokeColor("red")
	run("Add to Manager");	// ROI1 --> Whole brown
	
	
	
	// SEGMENT BLUE CELLS
	selectWindow("blue");
	run("Mean...", "radius=2");
	run("Threshold...");
	setAutoThreshold("Default");
	setAutoThreshold("Otsu");
	//thBlue = 125;
	setThreshold(0, thBlue);
	//waitForUser("Adjust threshold for cell segmentation and press OK when ready");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	//run("Fill Holes");
	run("Median...", "radius=2");
	run("Watershed");
	roiManager("Select", 0);
	run("Clear Outside");
	run("Select All");
	//minSize=10;
	//maxSize=1000;
	run("Analyze Particles...", "size="+minSize+"-"+maxSize+" pixel show=Masks in_situ");
	
	// transform selection to individual points
	run("Find Maxima...", "prominence=10 light output=[Single Points]");
	rename("blueMaxima");
	
	// Generate cellMask by enlarging the mask of nuclei
	selectWindow("blueMaxima");
	run("Duplicate...", "title=cellMask");
	run("Create Selection");
	cellRadiusPx = 10;
	run("Enlarge...", "enlarge="+cellRadiusPx);
	setForegroundColor(0, 0, 0);
	run("Fill", "slice");
	
	selectWindow("cellMask");
	run("Select All");
	run("Duplicate...", "title=cellEdges");
	run("Find Edges");
	
	// MARKER-CONTROLLED WATERSHED
	run("Marker-controlled Watershed", "input=cellEdges marker=blueMaxima mask=cellMask binary calculate use");
	
	selectWindow("cellEdges-watershed");
	run("8-bit");
	setThreshold(1, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Analyze Particles...", "size=0-Infinity show=Masks add in_situ");
	roiManager("Show None");
	
	selectWindow("cellEdges");
	close();
	selectWindow("cellMask");
	close();
	selectWindow("blueMaxima");
	close();
	selectWindow("cellEdges-watershed");
	rename("cellMask");
	selectWindow("blue");
	close();
	
	n=roiManager("Count");
	nCells=n-2;
	
	roiManager("Save", OutDir+File.separator+MyTitle_short+"_ROIs.zip");
	
	
	// CHECK ONE BY ONE WHICH CELLS CONTAIN CD8
	
	selectWindow("cellMask");
	run("Duplicate...", "title=positCellMask");
	run("Select All");
	setBackgroundColor(255, 255, 255);
	run("Clear", "slice");
	wait(100);
	
	run("Clear Results");
	selectWindow("brown");
	run("Select None");
	roiManager("Deselect");
	roiManager("Measure");
	selectWindow("positCellMask");	// fill in cellMask only cells positive for CD8
	for (i=2; i<n; i++)
	{
		Aperc=getResult("%Area",i);	
		if (Aperc>=minBrownPerc) {	
	  		roiManager("Select", i);
			run("Fill", "slice");
	  	}  	 	
	}
	run("Select None");
	roiManager("Reset");
	run("Analyze Particles...", "size=0-Infinity pixel show=Masks add in_situ");
	nCD8=roiManager("Count");
	run("Select None");
	
	
	selectWindow("Threshold");
	run("Close");
	
	selectWindow("brown");
	close();
	selectWindow(MyTitle);
	close();
	
	roiManager("Show None");
	
	
	// Write results:
	run("Clear Results");
	if(File.exists(output+File.separator+"Quantification_CD8count.xls"))
	{	
		//if exists add and modify
		open(output+File.separator+"Quantification_CD8count.xls");
		IJ.renameResults("Results");
	}
	i=nResults;
	setResult("[Label]", i, MyTitle); 
	setResult("# total cells", i, nCells);
	setResult("# CD8+ cells", i, nCD8);
	setResult("Area of tissue (um2)", i, Atm); 
	saveAs("Results", output+File.separator+"Quantification_CD8count.xls");
	
	
	// DRAW:
	
	selectWindow("orig");
	
	/*
	// Draw all cells
	selectWindow("cellMask");
	run("Select None");
	//run("Find Maxima...", "noise=10 output=[Point Selection] light");
	//setTool("multipoint");
	//run("Point Tool...", "type=Hybrid  color=Red size=Tiny counter=0");
	run("Create Selection");
	selectWindow("orig");
	run("Restore Selection");
	roiManager("Set Color", "red");
	roiManager("Set Line Width", 1);
	run("Flatten");
	wait(100);*/
	
	
	// Draw CD8-positive cells
	if(nCD8!=0) { 
		selectWindow("positCellMask");
		run("Select None");
		//run("Find Maxima...", "noise=10 output=[Point Selection] light");
		//setTool("multipoint");
		//run("Point Tool...", "type=Hybrid  color=Green size=Tiny counter=0");
		run("Create Selection");
		selectWindow("orig");
		run("Restore Selection");
		roiManager("Set Color", "green");
		roiManager("Set Line Width", 1);
	}
	run("Flatten");
	wait(200);
	
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	rename(MyTitle_short+"_analyzed.jpg");
	
	/*
	selectWindow("orig");
	close();
	selectWindow("orig-1");
	close();
	selectWindow("positCellMask");
	close();
	selectWindow("cellMask");
	close();
	*/
	close("*");
	
	setBatchMode(false);
	
	//showMessage("Done!");

}



