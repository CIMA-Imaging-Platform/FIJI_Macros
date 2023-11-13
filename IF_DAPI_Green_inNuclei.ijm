// changelog January 2021
// Segment and quantify DAPI and green areas and obtain ratio DAPI/green


function macroInfo(){
	
// * "Quantifiaction of DAPI, GFP IF Intensity within Nucleus";
// * Target User: General
// *  

	scripttitle= "Quantifiaction of DAPI, GFP IF Intensity within Nucleus";
	version= "1.03";
	date= "2021";
	

// *  Tests Images:

	imageAdquisition="Confocal: DAPI + GFP .";
	imageType="8bit";  
	voxelSize="Voxel size:  unkown um xy";
	format="Format: Zeiss .czi";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button 
  		
	parameter1="Introduce Channel Order"; 
	parameter2="Introduce Channel Thresholds for Segmentation (8bit): Separate estructures, The higher threshold, the less structures are selected";
	parameter3="Min GFP particle size (px)";
	 
//  2 Action tools:
	buttom1="Im: Single File processing";
	buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs

	excel="IF_quantification.xls";
	feature1="Image Label";
	feature2="DAPI area (um2)";
	feature3="Green total area (um2)";
	feature4="Green in nuclei area (um2)";
	feature5="Ratio Agreen/Adapi in nuclei";
	feature6="Avg Total Green Intensity";
	feature7="Avg Green Intensity in nuclei";
	
	
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
	    +"<p><font size=3  i>PARAMETERS:  </i></p>"
	    +"<ul id=list-style-3><font size=2  i>"
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li>"
	    +"<li>"+parameter3+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li><li>"+feature5+"</li><li>"+feature6+"</li><li>"+feature7+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}


var cDAPI=1, cGreen=2, thDAPI=18, thGreen=15, minGreenSize=10;

macro "IF_DAPI_Green Action Tool 1 - Cf00T2d15IT6d10m"{
	
	run("ROI Manager...");
	
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	print("Processing "+name);
	
	Dialog.create("Parameters for the analysis");
	// Channels:
	Dialog.addMessage("Choose channel numbers")	
	Dialog.addNumber("DAPI", cDAPI);	
	Dialog.addNumber("Green", cGreen);	
	// Thresholds:
	Dialog.addMessage("Choose thresholds")	
	Dialog.addNumber("DAPI", thDAPI);	
	Dialog.addNumber("Green", thGreen);
	// Min size for green:
	Dialog.addMessage("Choose minimum particle size")	
	Dialog.addNumber("Min green particle size (px)", minGreenSize);
	Dialog.show();	
	cDAPI= Dialog.getNumber();
	cGreen= Dialog.getNumber();
	thDAPI=Dialog.getNumber();
	thGreen= Dialog.getNumber();
	minGreenSize= Dialog.getNumber();

	//setBatchMode(true);
	if_dapi_green("-","-",name,cDAPI,cGreen,thDAPI,thGreen,minGreenSize);
	setBatchMode(false);
	showMessage("Immunofluorescence quantified!");

}

macro "IF_DAPI_Green Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	run("ROI Manager...");
	
	InDir=getDirectory("Choose Tiles' directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("Parameters for the analysis");
	// Channels:
	Dialog.addMessage("Choose channel numbers")	
	Dialog.addNumber("DAPI", cDAPI);	
	Dialog.addNumber("Green", cGreen);	
	// Thresholds:
	Dialog.addMessage("Choose thresholds")	
	Dialog.addNumber("DAPI", thDAPI);	
	Dialog.addNumber("Green", thGreen);
	// Min size for green:
	Dialog.addMessage("Choose minimum particle size")	
	Dialog.addNumber("Min green particle size (px)", minGreenSize);
	Dialog.show();	
	cDAPI= Dialog.getNumber();
	cGreen= Dialog.getNumber();
	thDAPI=Dialog.getNumber();
	thGreen= Dialog.getNumber();
	minGreenSize= Dialog.getNumber();
	
	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"czi")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print("Processing "+name);
			setBatchMode(true);
			if_dapi_green(InDir,InDir,list[j],cDAPI,cGreen,thDAPI,thGreen,minGreenSize);
			setBatchMode(false);
			}
	}
	
	showMessage("Immunofluorescence quantified!");

}


function if_dapi_green(output,InDir,name,cDAPI,cGreen,thDAPI,thGreen,minGreenSize)
{

	run("Close All");
	
	if (InDir=="-") {
		run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
		}
	else {
		run("Bio-Formats Importer", "open=["+InDir+name+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
		}	
	
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	rename("orig");
	Stack.setDisplayMode("composite");
	/*Stack.setChannel(1);
	run("Grays");
	Stack.setChannel(2);
	run("Green");
	Stack.setChannel(3);
	run("Blue");
	Stack.setChannel(4);
	run("Cyan");
	Stack.setChannel(5);
	run("Red");
	Stack.setChannel(6);
	run("Magenta");
	Stack.setDisplayMode("composite");
	Stack.setActiveChannels("1111110");
	wait(100);*/
	
	// BACKGROUND CORRECTION
	
	Stack.setChannel(cDAPI);
	run("Subtract Background...", "rolling=70 slice");
	Stack.setChannel(cGreen);
	run("Subtract Background...", "rolling=30 slice");
	
	// PROCESSING
	
	run("RGB Color");
	rename("merge");
	
	run("Colors...", "foreground=black background=white selection=yellow");
	run("Set Measurements...", "area redirect=None decimal=5");
	
	getDimensions(width, height, channels, slices, frames);
		
	// SEGMENT NUCLEI FROM DAPI:
	
	selectWindow("orig");
	run("Duplicate...", "title=DAPI duplicate channels="+cDAPI);
	//run("Enhance Contrast", "saturated=0.35");
	run("8-bit");
	setAutoThreshold("Otsu dark");
	//setThreshold(17, 255);
	setThreshold(thDAPI, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=2");
	run("Close-");
	//run("Watershed");
	run("Fill Holes");
	run("Analyze Particles...", "size=80-Infinity pixel show=Masks in_situ");
	run("Create Selection");
	type=selectionType;
	if(type==-1) {
		exit("No nucleus detected with current DAPI threshold for image"+MyTitle+". Try lowering the threshold. Program terminated.");
	}
	roiManager("Add");	// ROI0 --> Nuclei
	selectWindow("DAPI");
	close();
	
	
	// SEGMENT GREEN-POSITIVE AREA:
	
	flagGreen=false;
	selectWindow("orig");
	run("Duplicate...", "title=green duplicate channels="+cGreen);
	//run("Enhance Contrast", "saturated=0.35");
	run("8-bit");
	//setThreshold(26, 255);
	setThreshold(thGreen, 255);
	run("Convert to Mask");
	//run("Median...", "radius=1");
	run("Analyze Particles...", "size="+minGreenSize+"-Infinity pixel show=Masks in_situ");
	run("Create Selection");
	type=selectionType;
	if(type==-1) {
		makeRectangle(1,1,1,1);
		flagGreen=true;	
	}
	roiManager("Add");	// ROI1 --> Green-positive pixels
	close();
	
	
	// GREEN SIGNAL IN NUCLEI:
	
	flagGreenNuclei=false;
	roiManager("Select", newArray(0,1));
	roiManager("AND");
	type=selectionType;
	if(type==-1) {
		makeRectangle(1,1,1,1);
		flagGreenNuclei=true;	
	}
	roiManager("Add");	// ROI2 --> Green-positive pixels in nuclei
	
	
	// MEASUREMENTS:
	
	run("Set Measurements...", "area mean redirect=None decimal=5");
	selectWindow("orig");
	run("Duplicate...", "title=green duplicate channels="+cGreen);
	run("Clear Results");
	roiManager("deselect");
	roiManager("Select", 0);
	roiManager("Measure");
	roiManager("Select", 1);
	roiManager("Measure");
	roiManager("Select", 2);
	roiManager("Measure");
	
	Adapi=getResult("Area", 0);
	Agreen=getResult("Area", 1);
	Igreen=getResult("Mean", 1);
	if(flagGreen) {
		Agreen=0;	
		Igreen=0;	
	}
	AgreenNucl=getResult("Area", 2);
	IgreenNucl=getResult("Mean", 2);
	if(flagGreenNuclei) {
		AgreenNucl=0;	
		IgreenNucl=0;	
	}
	
	r1=AgreenNucl/Adapi;
	
	selectWindow("orig");
	close();
	selectWindow("green");
	close();
	
	// Write results:
	run("Clear Results");
	if(File.exists(output+File.separator+"IF_quantification.xls"))
	{	
		//if exists add and modify
		open(output+File.separator+"IF_quantification.xls");
		IJ.renameResults("Results");
	}
	i=nResults;
	setResult("Label", i, MyTitle); 
	setResult("DAPI area (um2)", i, Adapi); 
	setResult("Green total area (um2)", i, Agreen); 
	setResult("Green in nuclei area (um2)", i, AgreenNucl); 
	setResult("Ratio Agreen/Adapi in nuclei", i, r1); 
	setResult("Avg Total Green Intensity", i, Igreen); 
	setResult("Avg Green Intensity in nuclei", i, IgreenNucl); 
	saveAs("Results", output+File.separator+"IF_quantification.xls");
		
	
	
	// DRAW:
	
	selectWindow("merge");
	setBatchMode(false);
	roiManager("Deselect");
	roiManager("Select", 0);
	roiManager("Set Color", "yellow");
	roiManager("Set Line Width", 1);
	run("Flatten");
	roiManager("Show None");
	roiManager("Select", 1);
	roiManager("Set Color", "red");
	roiManager("Set Line Width", 1);
	run("Flatten");
	roiManager("Show None");
	roiManager("Select", 2);
	roiManager("Set Color", "green");
	roiManager("Set Line Width", 1);
	run("Flatten");
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	wait(500);
	rename(MyTitle_short+"_analyzed.jpg");
	
	
	selectWindow("merge");
	close();
	selectWindow("merge-1");
	close();
	selectWindow("merge-2");
	close();
	
	if (InDir!="-") {
	close(); }
	
	//showMessage("Done!");

}


