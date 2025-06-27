

function macroInfo(){

// * Target User: General
// *  

	scripttitle= "Nuclear and Cytoplasm Protein IF Quantification ";
	version= "1.03";
	date= "2024"
	

// *  Tests Images:

	imageAdquisition="Confocal: 3 CHANNEL --> DAPI , Cyto, Protien of Interest";
	imageType="8bit";  
	voxelSize="Voxel size:  unkown um xy";
	format="Format: Zeiss .czi";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button 
 
 	  		
	parameter1="Introduce Channel Order, DAPI, Cyto and Protien for the Analysis"; 
	parameter2="Introduce Threshold for Cyto Segmentation (8bit): Separate Cyto from Background, The higher threshold, the less Cyto is selected"; 
	parameter3="Introduce Threshold for Nuclear DAPI Segmentation (8bit): Separate Nucleus from other Cyto structures, The higher threshold, the less Nucleus area is selected"; 
	parameter4="Introduce Threshold for Protein(+)/(-) Segmentation(8bit)";
	
		 
//  2 Action tools:
	buttom1="Im: Single File processing";
	buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs

	excel="QuantificationResutls_IF_NuclCyto_Phenotype.xls";
	feature1="[Label]"; 
	feature2="# Total Cells "; 
	feature3="Total Cyto area (um2)"; 
	feature4="Total Protein Area (um2)"; 
	feature5="Nuclei Protein Area (um2)"; 
	feature6="Cyto Protein Area (um2)"; 
	feature7="Nuclei Protein Mean Intensity"; 
	feature8="Nuclei Protein Std Intensity"; 
	feature9="Cyto Protein Mean Intensity"; 
	feature10="Cyto Protein Std Intensity"; 
	feature11= "Field of View FOV(um2)"

		
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
	    +"<p><font size=3  i>PARAMETERS:  </i></p>"
	    +"<ul id=list-style-3><font size=2  i>"
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li>"
	    +"<li>"+parameter3+"</li>"
	    +"<li>"+parameter4+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature11+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li>"
	    +"<li>"+feature5+"</li><li>"+feature6+"</li><li>"+feature7+"</li><li>"+feature8+"</li>"
	    +"<li>"+feature9+"</li><li>"+feature10+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");
}

var  cDAPI=2, cProtein=1, cCyto=3, thCyto=10, thDAPI=20, thProtein=35;

macro "QIF Action Tool 1 - Cf00T2d15IT6d10m"{
	
	macroInfo();
	
	run("ROI Manager...");
	
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	print("Processing "+name);
	
	Dialog.create("Parameters for the analysis");
	
/// Channels:
	Dialog.addMessage("Choose channel numbers")	
	Dialog.addNumber("DAPI", cDAPI);	
	Dialog.addNumber("Cyto", cCyto);	
	Dialog.addNumber("Protein for analysis", cProtein);
// Cyto segmentation options:
	Dialog.addMessage("Choose threshold for Cyto segmentation")	
	Dialog.addSlider("Cyto threshold", 0, 255, thCyto);	

// NULCEI segmentation options:
	Dialog.addMessage("Choose threshold for Nuclei segmentation")	
	Dialog.addSlider("Dapi threshold", 0, 255, thDAPI);	

// Protein segmentation options:
	Dialog.addMessage("Choose threshold for Protein segmentation")	
	Dialog.addSlider("Protein threshold", 0, 255, thProtein);	
	Dialog.show();

	cDAPI= Dialog.getNumber();
	cCyto= Dialog.getNumber();
	cProtein= Dialog.getNumber();
	
	thCyto= Dialog.getNumber();
	thDAPI= Dialog.getNumber();
	thProtein= Dialog.getNumber();
	
	//setBatchMode(true);
	ifNuclCytoPhenotype("-","-",name,cDAPI,cProtein,cCyto,thCyto,thDAPI,thProtein);
	setBatchMode(false);
	showMessage("QIF done!");

}

macro "QIF Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	run("ROI Manager...");
	
	InDir=getDirectory("Choose Tiles' directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("Parameters for the analysis");

// Channels:
	Dialog.addMessage("Choose channel numbers")	
	Dialog.addNumber("DAPI", cDAPI);	
	Dialog.addNumber("Cyto", cCyto);	
	Dialog.addNumber("Protein for analysis", cProtein);
// Cyto segmentation options:
	Dialog.addMessage("Choose threshold for Cyto segmentation")	
	Dialog.addSlider("Cyto threshold", 0, 255, thCyto);	

// NULCEI segmentation options:
	Dialog.addMessage("Choose threshold for Nuclei segmentation")	
	Dialog.addSlider("Dapi threshold", 0, 255, thDAPI);	

// Protein segmentation options:
	Dialog.addMessage("Choose threshold for Protein segmentation")	
	Dialog.addSlider("Protein threshold", 0, 255, thProtein);	
	Dialog.show();

	cDAPI= Dialog.getNumber();
	cCyto= Dialog.getNumber();
	cProtein= Dialog.getNumber();
	
	thCyto= Dialog.getNumber();
	thDAPI= Dialog.getNumber();
	thProtein= Dialog.getNumber();
	
	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"tif") || endsWith(list[j],".czi")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print("Processing "+name);
			//setBatchMode(true);
			ifNuclCytoPhenotype(InDir,InDir,list[j],cDAPI,cProtein,cCyto,thCyto,thDAPI,thProtein);
			setBatchMode(false);
			}
	}
	
	showMessage("QIF done!");

}


function ifNuclCytoPhenotype(output,InDir,name,cDAPI,cProtein,cCyto,thCyto,thDAPI,thProtein)
{

	run("Close All");
	
	if (InDir=="-") {
		run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
		}
	else {
		run("Bio-Formats Importer", "open=["+InDir+name+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
		}	

	//setBatchMode(true);
	//cDAPI=2;
	//cProtein=1;
	
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	rename("orig");
	
	getDimensions(width, height, channels, slices, frames);
	getVoxelSize(rx, ry, rz, unit);
	
	FOV=width*height*rx*ry;
	
	// Create composite and merge only if we have less than 8 channels:
	if (channels<8) {	
		Stack.setDisplayMode("composite");
		run("RGB Color");
		rename("merge");
	}
	else{
		selectWindow("orig");
		run("Duplicate...", "title=dapi duplicate channels="+cDAPI);
		selectWindow("orig");
		run("Duplicate...", "title=Protein duplicate channels="+cProtein);
		selectWindow("orig");
		run("Duplicate...", "title=Protein duplicate channels="+cCyto);
		run("Merge Channels...", "c1=Protein c2=compart c3=dapi create");
		run("RGB Color");
		rename("merge");
		selectWindow("Composite");
		close();
	}
	
	run("Enhance Contrast", "saturated=0.1");	
	run("Colors...", "foreground=black background=white selection=green");
	run("Set Measurements...", "area mean redirect=None decimal=2");
	
	//--DETECT Cyto
	setBatchMode(true);
	
	print("---- Segmenting Cyto ----");
	showStatus("Detecting Cyto...");
	selectWindow("merge");
	run("RGB to Luminance");
	rename("cytoMask");
	//run("Subtract Background...", "rolling=200 stack");
	run("Select All");
	run("Median...", "radius=1 stack");
	mode=getValue("Mode");
	run("Subtract...", "value="+mode);
	run("Threshold...");
	//thCyto=10;
	setThreshold(thCyto, 255);
	//setAutoThreshold("Otsu dark");
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark");
	run("Median...", "radius=2");
	run("Create Selection");
	ACyto = getValue("Area");
	
	run("Add to Manager");
	//close("cytoMask");
	
	selectWindow("merge");
	roiManager("Select", 0);
	roiManager("Set Color", "Green");
	roiManager("Set Line Width", 1);
	run("Flatten");
	wait(200);
	selectWindow("merge");
	close();
	selectWindow("merge-1");
	rename("merge");
	roiManager("reset");

	// SEGMENT NUCLEI FROM DAPI:
	selectWindow("orig");
	run("Duplicate...", "title=nucleiMask duplicate channels="+cDAPI);
	run("Select None");
	run("8-bit");
	run("Mean...", "radius=3");
	run("Subtract Background...", "rolling=300");
	
	selectWindow("nucleiMask");
	//setAutoThreshold("Default dark");
	//getThreshold(lower, upper);
	//thDAPI=20;
	setThreshold(thDAPI, 255);
	
	//setAutoThreshold(thMethodNucl+" dark");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=1");
	run("Fill Holes");
	run("Select All");
	run("Analyze Particles...", "size=100-Infinity pixel show=Masks in_situ");
	
	selectWindow("nucleiMask");
	run("Duplicate...", "title=EDM duplicate ");
	run("Distance Map");
	run("Log");
	//run("Brightness/Contrast...");
	run("Enhance Contrast", "saturated=0.1");
	run("Apply LUT");
	run("Find Maxima...", "prominence=10 light output=[Single Points]");
	rename("nucleiMaxima");
	close("EDM");
	
	selectWindow("nucleiMask");
	run("Select All");
	run("Duplicate...", "title=nucleiEdges");
	run("Find Edges");

	// Protein-CONTROLLED WATERSHED
	run("Marker-controlled Watershed", "input=nucleiEdges Protein=nucleiMaxima mask=nucleiMask binary calculate use");
	
	selectWindow("nucleiEdges-watershed");
	run("8-bit");
	setThreshold(1, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	roiManager("Reset");
	run("Analyze Particles...", "size=0-Infinity show=Masks add in_situ");
	roiManager("Show None");
	
	close("nucleiEdges");
	close("nucleiMask");
	close("nucleiMaxima");

	selectWindow("nucleiEdges-watershed");
	rename("nucleiMask");
	
	nCells=roiManager("Count");
	
	// SEGMENT Protein PIXELS
	
	selectWindow("orig");
	run("Duplicate...", "title=ProteinMask duplicate channels="+cProtein);
	run("Select None");
	run("8-bit");
	setAutoThreshold("Otsu dark");
	getThreshold(lower, upper);
	//thProtein=35;
	setThreshold(thProtein, upper);
	
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...","radius=1");
	run("Analyze Particles...", "size=5-Infinity pixel show=Masks in_situ");

	selectWindow("cytoMask");	
	run("Create Selection");
	selectWindow("ProteinMask");
	run("Restore Selection");
	run("Clear Outside");
	run("Create Selection");
	ProteinArea=getValue("Area");
	
	selectWindow("orig");
	run("Duplicate...", "title=Protein duplicate channels="+cProtein);

	
	// GET NUCLEAR AND CYTOPLASMIC COMPARTMENTS
	selectWindow("ProteinMask");
	run("Select None");
	run("Duplicate...", "title=ProteinNuclei duplicate ");
	run("Duplicate...", "title=ProteinCyto duplicate ");
	run("Select None");
	
	imageCalculator("AND","ProteinNuclei" ,"nucleiMask");
	run("Create Selection");
	type=selectionType() ;
	if (type != -1){
		ProteinNucleiArea=getValue("Area");
		selectWindow("Protein");
		run("Restore Selection");
		ProteinNucleiMeanI=getValue("Mean");
		//print(ProteinNucleiMeanI);
		ProteinNucleiStdI=getValue("StdDev");
		//print(ProteinNucleiStdI);
	}else{
		ProteinNucleiArea=0;
		ProteinNucleiMeanI=0;
		ProteinNucleiStdI=0;
	}
	
	
	imageCalculator("Substract","ProteinCyto" ,"nucleiMask");
	run("Create Selection");
	if (type != -1){
		ProteinCytoArea=getValue("Area");
		selectWindow("Protein");
		run("Restore Selection");
		ProteinCytoMeanI=getValue("Mean");
		ProteinCytoStdI=getValue("StdDev");
	}else{
		ProteinCytoArea=0;
		ProteinCytoMeanI=0;
		ProteinCytoStdI=0;
	}
	
	
	// Write results:
	run("Clear Results");
	if(File.exists(output+File.separator+"QuantificationResutls_IF_NuclCyto_Phenotype.xls"))
	{	
		//if exists add and modify
		open(output+File.separator+"QuantificationResutls_IF_NuclCyto_Phenotype.xls");
		wait(500);
		IJ.renameResults("Results");
		wait(500);
	}
	i=nResults;
	wait(100);
	setResult("[Label]", i, MyTitle); 
	setResult("FOV (um2)", i, FOV); 
	setResult("[# Total Cells]", i, nCells); 
	setResult("Total Cells area (um2)", i, ACyto); 
	setResult("Total Protein Area (um2)", i, ProteinArea); 
	setResult("Nuclei Protein Area (um2)", i, ProteinNucleiArea); 
	setResult("Cyto Protein Area (um2)", i, ProteinCytoArea); 
	setResult("Nuclei Protein Mean Intensity", i, ProteinNucleiMeanI); 
	setResult("Nuclei Protein Std Intensity", i, ProteinNucleiStdI); 
	setResult("Cyto Protein Mean Intensity", i, ProteinCytoMeanI); 
	setResult("Cyto Protein Std Intensity", i, ProteinCytoStdI); 
	saveAs("Results", output+File.separator+"QuantificationResutls_IF_NuclCyto_Phenotype.xls");
	
	// DRAW:
	
	setBatchMode("exit and display");

	selectWindow("merge");
	setBatchMode(false);
	roiManager("Deselect");
	run("Select None");
	
	// Cytoplasmic compartment:
	selectWindow("ProteinNuclei");
	run("Create Selection");
	selectWindow("merge");
	run("Restore Selection");
	Overlay.addSelection;
	Overlay.addSelection("magenta");
	run("Flatten");
	wait(200);
	selectWindow("merge");
	close();
	selectWindow("merge-1");
	rename("merge");
	
	// Cytoplasmic compartment:
	selectWindow("merge");
	selectWindow("ProteinCyto");
	run("Create Selection");
	selectWindow("merge");
	run("Restore Selection");
	Overlay.addSelection("red");
	run("Flatten");
	wait(200);
	selectWindow("merge");
	close();
	selectWindow("merge-1");
	rename("merge");
	
	selectWindow("merge");
	roiManager("Show All");
	roiManager("Show All with labels");
	roiManager("Set Color", "blue");
	roiManager("Set Line Width", 1);
	run("Flatten");
	wait(200);
	selectWindow("merge");
	close();
	selectWindow("merge-1");
	rename("merge");
	roiManager("reset");
	
	close("*Mask");
	close("Protein*");
	
	selectWindow("merge");
	saveAs("Tiff",OutDir+File.separator+MyTitle_short+"_Analyzed.tiff");
	close("\\Others");
	
	//Clear unused memory
	wait(500);
	run("Collect Garbage");
	
	//showMessage("Done!");

}



