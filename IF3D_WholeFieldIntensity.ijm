function macroInfo(){
	
// * Quantification of Protein   
// * Target User: General
// *  
	scripttitle= "Quantification of Protein intensity distribution in IF 3D Stacks";
	version= "1.03";
	date= "2023";
	

// *  Tests Images:
	imageAdquisition="Confocal: ";
	imageType="IF Single or Multiple Channel ";  
	voxelSize="Voxel size:  0.502 um xy";
	format=".czi";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: 
 
	 parameter1="Select Channel to quantify"; 
		  
 //  2 Action tools:
		
	 buttom1="Im: Single File processing. Use Single file processing for fine tunning parameters";
	 buttom2="Dir: Batch Mode. Please tune parameters before using Batchmode";

//  OUTPUT

// Analyzed Images with ROIs

	excel="Protein_Quantification.xls";
	feature1="Label Image"; 
	feature2="Area (microns^2)"; 
	feature3="MeanIntensity"; 
	feature4="StdDevIntensity"; 
	feature5="MaxIntensity"; 
	feature6="MinIntensity"; 
	
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
	    +"<p><font size=3  i>PARAMETERS: Right Click on Action tools  </i></p>"
	    +"<ul id=list-style-3><font size=2  i>"
	    +"<li>"+parameter1+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li><li>"+feature5+"</li><li>"+feature6+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}


var ch=1;

setOption("ExpandableArrays", true);
setOption("WaitForCompletion", true);

macro "BiofilmQuantification3D Action Tool 1 - Cf00T2d15IT6d10m"{
	
	run("Close All");
	
	macroInfo();
	
	//just one file
	path=File.openDialog("Select File");
	//print(name);
	output = File.getParent(path);
  	name = File.getName(path);
	
	Dialog.create("Parameters for the analysis");
	Dialog.addNumber("Channel to analyze",ch);	
	Dialog.show();	
	ch= Dialog.getNumber();
		
	//setBatchMode(true);
	
	setBatchMode(true);
	metrics=ifquant("-","-",path,ch);
	setBatchMode(false);
	showMessage("Field quantified!");
		
	//--RESULTS
	
	j=0;
	Table.create("Metrics");
	Table.set("[Label]", j, name); 
	Table.set("Area (microns^2)", j, metrics[0]); 
	Table.set("MeanIntensity", j, metrics[1]); 
	Table.set("StdDevIntensity", j, metrics[2]); 
	Table.set("MinIntensity", j, metrics[3]); 
	Table.set("MaxIntensity", j, metrics[4]); 
	IJ.renameResults("Results");
	run("Read and Write Excel", "stack_results dataset_label=[PROTEIN INTENSITY DISTRIBUTION]] file=["+output+File.separator+"ProteinQuantification.xlsx]");
		
	//Clear unused memory
	run("Collect Garbage");
		
}

macro "BiofilmQuantification3D Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	run("Close All");
	
	InDir=getDirectory("Choose Tiles' directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("Parameters for the analysis");
	Dialog.addNumber("Channel to analyze",ch);	
	Dialog.show();	
	ch= Dialog.getNumber();
	
	
	setBatchMode(true);
	
	labels=newArray();
	area=newArray();
	meanIntensity=newArray();
	stdIntensity=newArray();
	minIntensity=newArray();
	maxIntensity=newArray();
	czifiles=0;
		
	for (j=0; j<L; j++)
	{
		
		if(endsWith(list[j],"czi")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print("Processing "+name);
			//setBatchMode(true);
			metrics=ifquant(InDir,InDir,list[j],ch);
			labels[czifiles]=list[j];
			area[czifiles]=metrics[0];
			meanIntensity[czifiles]=metrics[1];
			stdIntensity[czifiles]= metrics[2];
			minIntensity[czifiles]=metrics[3];
			maxIntensity[czifiles]=metrics[4];
			czifiles+=1;
			}
	}
	setBatchMode(false);
	Table.create("Metrics");
	Table.setColumn("[Label]",labels); 
	Table.setColumn("Area (microns^2)",area); 
	Table.setColumn("MeanIntensity",meanIntensity); 
	Table.setColumn("StdDevIntensity",stdIntensity); 
	Table.setColumn("MinIntensity",minIntensity); 
	Table.setColumn("MaxIntensity",maxIntensity); 
	IJ.renameResults("Results");

	run("Read and Write Excel", "stack_results dataset_label=[PROTEIN INTENSITY DISTRIBUTION] file=["+InDir+File.separator+"ProteinQuantification.xlsx]");
	
	
	showMessage("finish!");
	
		
	/*--RESULTS
	//--Save results
	run("Clear Results");
	if(File.exists(output+File.separator+"ProteinQuantification.xls"))
	{	
		//if exists add and modify
		open(output+File.separator+"ProteinQuantification.xls");
		IJ.renameResults("Results");
	}
	i=nResults;
	setResult("[Label]", i, MyTitle); 
	setResult("Area (microns^2)", i, areaMicrons); 
	setResult("MeanIntensity", i, mean); 
	setResult("StdDevIntensity", i, std); 
	setResult("MaxIntensity", i, min); 
	setResult("MinIntensity", i, max); 
	saveAs("Results", output+File.separator+"ProteinQuantification.xls");
	*/
	
	
		
	//run("Synchronize Windows");
	if (InDir!="-") {
	close(); }
		 
	//Clear unused memory
	run("Collect Garbage");
	
	
	
}

function ifquant(output,InDir,name,ch)
{
	
	run("Close All");
	
	if (InDir=="-") {
		run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		}
	else {
		run("Bio-Formats Importer", "open=["+InDir+name+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		}	
	
	roiManager("Reset");
	run("Clear Results");
	close("Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	run("Colors...", "foreground=black background=white selection=red");
	
	Stack.getDimensions(width, height, channels, slices, frames);
	run("Set Measurements...", "area mean standard min redirect=None decimal=2");
	getPixelSize(unit, pixelWidth, pixelHeight);
	
	rename("orig");
	run("Duplicate...", "title=Protein duplicate channels="+ch);
	run("Median...", "radius=1 stack");
	
	//--Projection
	run("Z Project...", "projection=[Sum Slices]");
	run("Duplicate...", "title=ProteinMask");
	run("16-bit");

	//BACKGROUND AND PROTEIN SEGMENTATION -- OTSU
	
	//run("Threshold...");
	setAutoThreshold("Huang dark no-reset stack");
	//setThreshold(16, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	
	//--Post-processing
	//run("Close-", "stack");
	run("Median...", "radius=1 stack");
	run("Morphological Filters", "operation=Opening element=Disk radius=1");
	run("Morphological Filters", "operation=Closing element=Disk radius=1");
	close("proteinMask");
	close("ProteinMask-Opening");
	selectWindow("ProteinMask-Opening-Closing");
	rename("ProteinMask");
	run("Create Selection");
	
	
	selectWindow("SUM_Protein");
	run("Restore Selection");
	
	run("Measure");

	run("Select None");
	areaPix=getResult("Area",0);
	areaMicrons=areaPix*pixelWidth*pixelHeight;
	mean=getResult("Mean",0);
	std=getResult("StdDev",0);
	min=getResult("Min",0);
	max=getResult("Max",0);

	run("Clear Results");
	selectWindow("SUM_Protein");
	run("8-bit");
	run("Restore Selection");
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_ProteinProjection.tif");
	run("Flatten");
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_ProteinProjection_Segmented.tif");

	close("\\Others");
			
	results=newArray(areaMicrons,mean,std,min,max);
	
	return results;
			
}
	




