// changelog March 2023
// Segment and quantify green signal per nucleus

// changelog January 2021
// Segment and quantify DAPI and green areas and obtain ratio DAPI/green


function macroInfo(){
	
// "Quantifiaction of DAPI, GFP IF Intensity within each Nuclei";
// * Target User: General
// *  

	scripttitle= "Quantifiaction of DAPI, GFP IF Intensity within each Nuclei";
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
  		
	parameter1="Introduce Channel Thresholds for Segmentation (8bit): Separate estructures, The higher threshold, the less structures are selected"; 
	parameter2="Prominence for local maxima detection: The higher the value, the more structures will be joined together";
	parameter3="Radius for smoothing: Smooth signal whithin structures in case they present heteregeneus signal";
		 
//  2 Action tools:
	buttom1="Im: Single File processing";
	buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs

	excel="IF_quantification_perImage.xls";
	feature1="Image Label";
	feature2="Cells ID";
	feature3="Nuclear area (um2)";
	feature4="Avg green signal in nucleus";
	
	
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
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}



var cDAPI=1, cGreen=2, prominence=10, thDAPI=70, radSmooth=6;

macro "IF_DAPI_Green Action Tool 1 - Cf00T2d15IT6d10m"{

	run("Close All");
	
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
	Dialog.addMessage("Nuclear segmentation parameters")	
	Dialog.addNumber("DAPI threshold", thDAPI);	
	Dialog.addNumber("Prominence for maxima detection", prominence);
	Dialog.addNumber("Radius for smoothing", radSmooth);
	
	Dialog.show();	
	cDAPI= Dialog.getNumber();
	cGreen= Dialog.getNumber();
	thDAPI=Dialog.getNumber();
	prominence= Dialog.getNumber();
	radSmooth= Dialog.getNumber();
	
	//setBatchMode(true);
	if_dapi_green("-","-",name,cDAPI,cGreen,thDAPI,prominence,radSmooth);
	setBatchMode(false);
	showMessage("Immunofluorescence quantified!");

}

macro "IF_DAPI_Green Action Tool 2 - C00fT0b11DT9b09iTcb09r"{

	run("Close All");
	
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
	Dialog.addMessage("Nuclear segmentation parameters")	
	Dialog.addNumber("DAPI threshold", thDAPI);	
	Dialog.addNumber("Prominence for maxima detection", prominence);
	Dialog.addNumber("Radius for smoothing", radSmooth);
	
	Dialog.show();	
	cDAPI= Dialog.getNumber();
	cGreen= Dialog.getNumber();
	thDAPI=Dialog.getNumber();
	prominence= Dialog.getNumber();
	radSmooth= Dialog.getNumber();
	
	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"czi")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print("Processing "+name);
			setBatchMode(true);
			if_dapi_green(InDir,InDir,list[j],cDAPI,cGreen,thDAPI,prominence,radSmooth);
			setBatchMode(false);
			}
	}
	
	showMessage("Immunofluorescence quantified!");

}


function if_dapi_green(output,InDir,name,cDAPI,cGreen,thDAPI,prominence,radSmooth)
{
	
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
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(cGreen);
	run("Subtract Background...", "rolling=30 slice");
	run("Enhance Contrast", "saturated=0.35");
	
	// PROCESSING
	
	run("RGB Color");
	rename("merge");
	
	run("Colors...", "foreground=black background=white selection=yellow");
	run("Set Measurements...", "area mean redirect=None decimal=5");
	
	
	getDimensions(width, height, channels, slices, frames);
	
	
	
	// SEGMENT NUCLEI FROM DAPI:
	
	selectWindow("orig");
	  // cDAPI=1;
	run("Duplicate...", "title=nucleiMask duplicate channels="+cDAPI);
	run("8-bit");
	run("Mean...", "radius="+radSmooth);
	wait(100);
	//run("Subtract Background...", "rolling=300");
	run("Duplicate...", "title=dapi");
	selectWindow("nucleiMask");
		// prominence=10
	run("Find Maxima...", "prominence="+prominence+" output=[Single Points]");
	rename("dapiMaxima");
	
	selectWindow("nucleiMask");
		//thMethodNucl="Default";
	//setAutoThreshold(thMethodNucl+" dark");
	setAutoThreshold("Default dark");
	getThreshold(lower, upper);
	   //thDAPI=38;
	setThreshold(thDAPI,upper);
	if (InDir=="-") {
		run("Threshold...");
		waitForUser("Set threshold and press OK when ready");
	}
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=1");
	run("Fill Holes");
	run("Select All");
	run("Analyze Particles...", "size=20-Infinity pixel show=Masks in_situ");
	
	// Generate cellMask by enlarging the mask of nuclei
	run("Duplicate...", "title=cellMask");
	run("Create Selection");
		//cytoBand=5;
	//run("Enlarge...", "enlarge="+cytoBand);
	setForegroundColor(0, 0, 0);
	run("Fill", "slice");
	
	selectWindow("dapiMaxima");
	run("Select None");
	run("Restore Selection");
	setBackgroundColor(255, 255, 255);
	run("Clear Outside");
	run("Select None");
	
	selectWindow("cellMask");
	run("Select All");
	run("Duplicate...", "title=cellEdges");
	run("Find Edges");
	
	// MARKER-CONTROLLED WATERSHED
	run("Marker-controlled Watershed", "input=cellEdges marker=dapiMaxima mask=cellMask binary calculate use");
	
	selectWindow("cellEdges-watershed");
	run("8-bit");
	setThreshold(1, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	//roiManager("Reset");
	//run("Analyze Particles...", "size=0-Infinity show=Masks add in_situ");
	//roiManager("Show None");
	
	selectWindow("cellEdges");
	close();
	selectWindow("cellMask");
	close();
	selectWindow("dapiMaxima");
	close();
	selectWindow("nucleiMask");
	close();
	selectWindow("cellEdges-watershed");
	rename("cellMask");
	
	run("Select None");
	run("Analyze Particles...", "size=0-Infinity pixel show=Masks display clear add in_situ");
	nCells = nResults;
	
	
	//--Measure green signal in nuclei
	
	run("Clear Results");
	selectWindow("orig");
	run("Duplicate...", "title=green duplicate channels="+cGreen);
	//run("Enhance Contrast", "saturated=0.35");
	selectWindow("green");
	roiManager("Deselect");
	roiManager("Measure");
	InuclG = newArray(nCells);
	Anucl = newArray(nCells);
	for (i = 0; i < nCells; i++) {
		I = getResult("Mean", i);
		A = getResult("Area", i);
		InuclG[i] = I;
		Anucl[i] = A;
	}
	
	selectWindow("orig");
	close();
	selectWindow("green");
	close();
	selectWindow("cellMask");
	close();
	
	
	// Write results:
	run("Clear Results");
	for (j = 0; j < nCells; j++) {
		i=nResults;
		setResult("Label", i, MyTitle); 
		setResult("# cell", i, j+1); 
		setResult("Nuclear area (um2)", i, Anucl[j]); 
		setResult("Avg green signal in nucleus", i, InuclG[i]); 	
	}
	saveAs("Results", output+File.separator+"IF_quantification_"+MyTitle_short+".xls");
		
	
	
	// DRAW:
	
	selectWindow("merge");
	setBatchMode(false);
	roiManager("Deselect");
	roiManager("Show All without labels");
	roiManager("Show All with labels");
	roiManager("Set Color", "yellow");
	roiManager("Set Line Width", 1);
	run("Flatten");
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	wait(500);
	rename(MyTitle_short+"_analyzed.jpg");
	
	
	selectWindow("merge");
	close();
	
	
	if (InDir!="-") {
	close(); }
	
	//showMessage("Done!");

}


