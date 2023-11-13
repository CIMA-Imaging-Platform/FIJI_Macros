 /*
 *  AUTOMATIC QUANTIFICATION OF NUCLEAR 3D STRUCTURES 
 * Target User:   
 *  
 *  Tests Images: 
 *    - Confocal: 2 channel images. 3D Stack Images
 *    - 16 bit 
 *    - Voxel size: 0.1024x0.1024x0.25 micron^3
 *    - Format .czi  
 *  
 *  GUI User Requierments:
 *    - Choose parameters
 *    
 *  Important Parameters:
 * 	  - Channels cRed=1, cDAPI=3;	
 * 	  - thresholds:  tolerance=10, thRedDots=80, 
 * 	  - particlesSize: minSizeRedDots=10;		
 * 
 *   2 Action tools:
 *    Im: File Selection. 
 *    DIR: Batch Mode. Select Folder: All images within the folder will be quantified
 *     
 * 	  
 *  version: 1.02 
 *  Author: Mikel Ariz  
 *  Commented by: Tomas Muñoz 
 *  Date : changelog March 2021
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

function info(){
	scripttitle= "AUTOMATIC 2D/3D QUANTIFICATION OF #N NUCLEAR Marker DOT STRUCTURES / CELL   ";
	version= "1.02";
	date= "2022";
	
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
	    +"<ul id=list-style-3><font size=2  i><li>  Confocal: 2 channel images. DAPI and Marker of Interest .</li><li>16 bit Images </li><li>Resolution: 0.1024x0.1024x0.25 micron^3</li<li>Format .czi</li></i></ul>"
	    +"<p><font size=3 i>Action tools (Buttons)</i></p>"
	    +"<ol><font size=2  i><li>Im : Single File Selection</li>"
	    +"<li> DIR: Batch Mode. Select Folder: All images within the folder will be quantified .</li></ol>"
	    +"<p><font size=3  i>Parameters</i></p>"
	    +"<ul id=list-style-3><font size=2  i>"
	    +"<li>DAPI, Prot Channel order</li>"
	    +"<li>Tolerance for Nuclei detection: Difference between two DAPI local Maxima. Higher value, close nuclei might be segmented as single one</li>"
	    +"<li>Marker Threshold: Intensity Threshold to separate Marker Dots from Basal Signal</li>"
	    +"<li>Size Filter for Marker Accumulation Dots</li></ul>"
	    +"<p><font size=3  i>Quantification Results (Excel) </i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>#Cells</li><li>#Dots for each Cell</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");
	    
	  //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
	}
	

var tolerance=10, thRedDots=80, minSizeRedDots=10, cRed=1, cDAPI=3;		

macro "NuclearRedDots3D Action Tool 1 - Cf00T2d15IT6d10m"{
	
	info();
	
	run("Close All");
	//just one file
	name=File.openDialog("Select File");
	print(name);
	
	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Choose channel numbers");
	Dialog.addNumber("DAPI", cDAPI);	
	Dialog.addNumber("Marker Dots", cRed);	
	Dialog.addMessage("Choose parameters")	
	Dialog.addNumber("Tolerance for nuclei detection", tolerance);	
	Dialog.addNumber("Threshold for red dots detection", thRedDots);	
	Dialog.addNumber("Min size for red dots (pixels)", minSizeRedDots);

	Dialog.show();	
	cDAPI= Dialog.getNumber();
	cRed= Dialog.getNumber();

	tolerance= Dialog.getNumber();
	thRedDots= Dialog.getNumber();
	minSizeRedDots= Dialog.getNumber();
						
	reddots("-","-",name,tolerance,thRedDots,minSizeRedDots,cRed,cDAPI);
	setBatchMode(false);
	showMessage("Done!");

}
		
macro "NuclearRedDots3D Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	info();
	
	run("Close All");
	InDir=getDirectory("Choose a Directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Choose parameters")	
	Dialog.addNumber("Tolerance for nuclei detection", tolerance);	
	Dialog.addNumber("Threshold for red dots detection", thRedDots);	
	Dialog.addNumber("Min size for red dots (pixels)", minSizeRedDots);
	Dialog.addMessage("Choose channel numbers");	
	Dialog.addNumber("Red Dots", cRed);	
	Dialog.addNumber("DAPI", cDAPI);	
	Dialog.show();	
	tolerance= Dialog.getNumber();
	thRedDots= Dialog.getNumber();
	minSizeRedDots= Dialog.getNumber();
	cRed= Dialog.getNumber();
	cDAPI= Dialog.getNumber();

	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"czi")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print(name);
			//setBatchMode(true);
			reddots(InDir,InDir,list[j],tolerance,thRedDots,minSizeRedDots,cRed,cDAPI);
			setBatchMode(false);
			}
	}
	showMessage("Done!");
}


function reddots(output,InDir,name,tolerance,thRedDots,minSizeRedDots,cRed,cDAPI)
{
	
if (InDir=="-") {
	//open(name);
	run("Bio-Formats", "open=["+name+"] autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT");
	}
else {
	if (isOpen(InDir+name)) {}
	else { 
		//open(InDir+name);
		run("Bio-Formats", "open=["+InDir+name+"] autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT");
		}
	}

	Stack.setDisplayMode("composite");
	//Stack.setActiveChannels("101");
	
	run("Colors...", "foreground=black background=white selection=yellow");
	Stack.getDimensions(width, height, channels, slices, frames);
	
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	getVoxelSize(vx, vy, vz, unit);
	
	// Create a merged projection:
	run("Z Project...", "projection=[Max Intensity]");
	rename("proj");
	run("RGB Color");
	rename("mergeProj");
	selectWindow("proj");
	close();
	
	
	//--SEGMENT NUCLEI--
	
	selectWindow(MyTitle);
	//run("Duplicate...", "title=nucleiMask duplicate channels=3 slices=1-"+slices);
	run("Duplicate...", "title=nucleiMask duplicate channels="+cDAPI+" slices=1-"+slices);
	
	//--Segment first in the summed projection to create a mask of individual cells:
	
	run("Z Project...", "projection=[Sum Slices]");
	rename("nucleiProjection");
	run("8-bit");
	run("Duplicate...", "title=temp");
	run("Mean...", "radius=16");
		//tolerance=60;
	run("Find Maxima...", "prominence="+tolerance+" output=[Single Points]");
	//run("Find Maxima...", "noise="+tolerance+" output=[Single Points]");
	//run("Find Maxima...", "noise=60 output=[Single Points]");
	rename("dapiMaxima");
	selectWindow("temp");
	close();
	
	selectWindow("nucleiProjection");
	setAutoThreshold("Huang dark");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	//run("Median...", "radius=1");
	run("Fill Holes");
	run("Select All");
	run("Analyze Particles...", "size=40-Infinity pixel show=Masks in_situ");
	
	run("Create Selection");
	selectWindow("dapiMaxima");
	run("Select None");
	run("Restore Selection");
	setBackgroundColor(255, 255, 255);
	run("Clear Outside");
	run("Select None");
	
	selectWindow("nucleiProjection");
	run("Select All");
	run("Duplicate...", "title=nucleiEdges");
	run("Find Edges");
	
	//--MARKER-CONTROLLED WATERSHED
	run("Marker-controlled Watershed", "input=nucleiEdges marker=dapiMaxima mask=nucleiProjection binary calculate use");
	selectWindow("nucleiEdges-watershed");
	run("8-bit");
	setThreshold(1, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	roiManager("Reset");
	run("Analyze Particles...", "size=0-Infinity show=Masks add in_situ");
	roiManager("Show None");
	
	selectWindow("nucleiEdges");
	close();
	selectWindow("nucleiProjection");
	close();
	selectWindow("dapiMaxima");
	close();
	selectWindow("nucleiEdges-watershed");
	rename("nucleiProjection");
	close();
	
	
	//--Segment nuclei now in each slice
	
	selectWindow("nucleiMask");
	setSlice(round(slices/2));
	run("Mean...", "radius=3 stack");
	setAutoThreshold("Huang dark");
	//setThreshold(9, 255);
	run("Convert to Mask", "method=Huang background=Dark");
	run("Fill Holes", "stack");
	
	
	//--SEGMENT RED DOTS--
	
	selectWindow(MyTitle);
	//run("Duplicate...", "title=redDots duplicate channels=1 slices=1-"+slices);
	run("Duplicate...", "title=redDots duplicate channels="+cRed+" slices=1-"+slices);
	run("8-bit");
	//--Mask red channel with the nuclei mask
	for (i = 1; i <= slices; i++) {
		selectWindow("nucleiMask");
		setSlice(i);
		run("Create Selection");
		type=selectionType();
		if(type!=-1) {
			selectWindow("redDots");
			setSlice(i);
			run("Restore Selection");
			setBackgroundColor(0, 0, 0);
			run("Clear Outside", "slice");
		}
		else {
			selectWindow("redDots");
			setSlice(i);
			run("Select All");
			setBackgroundColor(0, 0, 0);
			run("Clear", "slice");
		}
	}
	
	
	
	//--Use 3D object counter to segment red dots
	run("Clear Results");
	run("3D OC Options", "volume nb_of_obj._voxels integrated_density mean_gray_value centroid dots_size=1 font_size=10 redirect_to=none");
	run("3D Objects Counter", "threshold="+thRedDots+" slice=1 min.="+minSizeRedDots+" max.=7077888 centroids statistics");
	//run("3D Objects Counter", "threshold=80 slice=1 min.=10 max.=7077888 centroids statistics");
	
	//--Process map of detected centroids
	selectWindow("Centroids map of redDots");
	rename("Centroids");
	setThreshold(1, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark");
	run("Invert LUT");
	run("Divide...", "value=255 stack");	// each centroid is a '1'
	run("Z Project...", "projection=[Sum Slices]");	// sum-projection to add centroids if some of them are on the same x-y
	rename("CentroidSum");
	roiManager("Show None");
	roiManager("Deselect");
	roiManager("Combine");
	run("Clear Outside");	// clear possible centroids that lie outside the nuclei projection mask
	run("Select None");
	
	
	//--MEASURE
	run("Clear Results");
	run("Set Measurements...", "area mean integrated redirect=None decimal=0");
	roiManager("Deselect");
	roiManager("Measure");
	nCells = nResults;
	nRedDots = newArray(nCells);
	for (i = 0; i < nCells; i++) {
		nRedDots[i] = getResult("RawIntDen", i);
	}
	
	//--Write results
	run("Clear Results");
	if(File.exists(output+File.separator+"QuantifiedRedDots.xls"))
	{	
		//if exists add and modify
		open(output+File.separator+"QuantifiedRedDots.xls");
		IJ.renameResults("Results");
	}
	for(j=0;j<nCells;j++){
		i=nResults;	
		if(j==0) { 
			setResult("Label", i, MyTitle);
		}
		setResult("# Cell", i, j+1); 
		setResult("Number of Marker Dots", i, nRedDots[j]);					 
	}			
	saveAs("Results", output+File.separator+"QuantifiedRedDots.xls");
	
	
	//--DRAW
	selectWindow("Centroids");
	close();
	selectWindow("nucleiMask");
	close();
	selectWindow("redDots");
	close();
	
	waitForUser;
	
	selectWindow("CentroidSum");
	run("Find Maxima...", "prominence=0.01 output=[Point Selection]");
	selectWindow("mergeProj");
	run("Restore Selection");
	run("Enlarge...", "enlarge=1 pixel");
	//run("Point Tool...", "type=Circle color=Yellow size=Tiny counter=0");
	run("Flatten");
	wait(100);
	roiManager("Show All");
	roiManager("Set Color", "magenta");
	roiManager("Set Line Width", 1);
	run("Flatten");
	wait(100);
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");	
	wait(100);
	rename(MyTitle_short+"_analyzed.jpg");
	
	if (InDir!="-") {
		close(); }
			
	selectWindow("mergeProj");
	close();
	selectWindow("mergeProj-1");
	close();
	selectWindow("CentroidSum");
	close();
	selectWindow(MyTitle);
	close();
	
}
	
	
	
