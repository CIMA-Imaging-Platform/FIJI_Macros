 /*
 * Nucleus and Cytomplasm InmunoFlourescence Signal Quantification 
 * Target User:   
 *  
 *  Tests Images: 
 *    - Confocal: 2 channel images. 2D Images
 *    - 16 bit 
 *    - Voxel size: 0.1613x0.1613x1 micron^3
 *    - Format .czi  
 *  
 *  GUI User Requierments:
 *    - Choose parameters
 *    
 *  Important Parameters:
 * 	  - thresholds:   thBlue=60,  thGreen=15
 * 	  - smoothing=10; For smoothing heterogenius DAPI signal and help maxima detection. 		
 * 	  - prominence=3 For Maxima Detection --> input to Guided Watershed
 * 	  - erodeRad=1 Not in use
 * 	  
 * 
 *   2 Action tools:
 *    Im: Single File processing. 
 *    DIR: Batch Mode. Select Folder: All images within the folder will be quantified
 *    
 *   OUTPUT
 
 		setResult("Label", i, MyTitle_short); 
		setResult("# Monocyte", i, j+1); 
		setResult("Area nucl (um2)", i, An[j]);
		setResult("Area monocyte (um2)", i, Am[j]);	
		setResult("Igreen nucl", i, In[j]); 
		setResult("Igreen cyto", i, Ic[j]); 
		setResult("Igreen whole cell", i, Iall[j]);		 
  	  
 *  version: 1.02 
 *  Author: Mikel Ariz  
 *  Commented by: Tomas Muñoz 2023 
 *  Date : changelog May2018
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
	scripttitle= "NUCLEUS AND CYTO InmoFluorescemce QUANTIFICATION";
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
	    +"<ul id=list-style-3><font size=2  i><li>  Confocal: 2 channel 2D images. DAPI and Marker of Interest .</li><li>16 bit Images </li><li>Resolution: 0.1613x0.1613x1 micron^3</li<li>Format .czi</li></i></ul>"
	    +"<p><font size=3 i>Action tools (Buttons)</i></p>"
	    +"<ol><font size=2  i><li>Im : Single File Selection</li>"
	    +"<li> DIR: Batch Mode. Select Folder: All images within the folder will be quantified .</li></ol>"
	    +"<p><font size=3  i>Parameters</i></p>"
	    +"<ul id=list-style-3><font size=2  i>"
	    +"<li>DAPI and Green Threshold: Intensity Threshold: separates ROIs from background</li>"
	    +"<li>Smoothing Filter for Nuclei detection: Helps separate nuclei in case single nuclei is segmented as multiples. Ej values: 2,4 or 8</li>"
	    +"<li>Prominence for Nuclei detection: Higher value means that close nuclei might be segmented as single one. Ej values: 5,10 or 15</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=2  i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=2  i>Excel Quantification_Monocytes.xls</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>#Monocytes</li><li>Area Nuclei (um2)<li>Area monocyte (um2)</li>"
	    +"<li>Igreen nucli</li><li>Igreen cyto</li><li>Igreen whole cell</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
	}
	


var thBlue=60, thGreen=15, prominence=15,  erodeRad=0, smoothing=2;

macro "IFnuclCyto3D Action Tool 1 - Cf00T2d15IT6d10m"{
	
	info();
	
	run("Close All");
	run("Collect Garbage");
	//just one file
	name=File.openDialog("Select File");
	//print(name);

	Dialog.create("Parameters");
	Dialog.addMessage("Choose parameters")	
	Dialog.addNumber("DAPI threshold", thBlue);
	Dialog.addNumber("Green threshold", thGreen);	
	//Dialog.addNumber("Erosion radius (px)", erodeRad);	
	Dialog.addNumber("Prominence for cell separation", prominence);	
	Dialog.addNumber("Smoothing for cell separation", smoothing);	
	Dialog.show();	
	thBlue= Dialog.getNumber();	
	thGreen= Dialog.getNumber();	
//	erodeRad= Dialog.getNumber();	
	prominence= Dialog.getNumber();	
	smoothing= Dialog.getNumber();	
	
	//setBatchMode(true);
	print(name);
	ifnuclcyto3d("-","-",name,thBlue,thGreen,erodeRad,prominence,smoothing);
	setBatchMode(false);
	showMessage("Done!");
	
}
		
macro "IFnuclCyto3D Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	info();
	
	run("Close All");
	run("Collect Garbage");
	InDir=getDirectory("Choose a Directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("Parameters");
	Dialog.addMessage("Choose parameters")	
	Dialog.addNumber("DAPI threshold", thBlue);
	Dialog.addNumber("Green threshold", thGreen);	
	//Dialog.addNumber("Erosion radius (px)", erodeRad);	
	Dialog.addNumber("Prominence for cell separation", prominence);	
	Dialog.addNumber("Smoothing for cell separation", smoothing);	
	Dialog.show();	
	thBlue= Dialog.getNumber();	
	thGreen= Dialog.getNumber();	
//	erodeRad= Dialog.getNumber();	
	prominence= Dialog.getNumber();	
	smoothing= Dialog.getNumber();			

	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"czi")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print(name);
			//setBatchMode(true);
			ifnuclcyto3d(InDir,InDir,list[j],thBlue,thGreen,erodeRad,prominence,smoothing);
			setBatchMode(false);
			}
	}
	showMessage("Done!");
}


function ifnuclcyto3d(output,InDir,name,thBlue,thGreen,erodeRad,prominence,smoothing)
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
	Stack.setChannel(1);
	run("Blue");
	Stack.setChannel(2);
	run("Green");
	
	
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
	
	
	run("RGB Color");
	rename("merge");
	
	run("Colors...", "foreground=black background=white selection=red");
	run("Set Measurements...", "area mean display redirect=None decimal=2");
	
	
	// DETECT NUCLEI -- DAPI SIGNAL
	
	selectWindow(MyTitle);
	wait(100);
	run("Duplicate...", "title=blue duplicate channels=1");
	wait(100);
	selectWindow("blue");
	run("Subtract Background...", "rolling=50");	
	run("8-bit");
	wait(100);
	setAutoThreshold("Default dark");
	//thBlue=50;
	setThreshold(thBlue, 255);
	wait(100);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=1");
	//run("Watershed");
	run("Analyze Particles...", "size=50-Infinity pixel show=Masks display exclude clear in_situ");
	
	
	/*
	for (i = 0; i < erodeRad; i++) {
		run("Erode");
	}*/
	
	/*
	run("Morphological Filters", "operation=Erosion element=Disk radius="+erodeRad);
	wait(100);
	selectWindow("blue");
	wait(100);
	close();
	selectWindow("blue-Erosion");
	rename("blue");
	*/
		
	// MEASURE MONOCYTE SIZES: BOTH CHANNELS 
	
	selectWindow("merge");
	run("Duplicate...", "title=cellMask");
	run("8-bit");
	run("Mean...", "radius=1");
	run("Subtract Background...", "rolling=50");
	
	//smoothed for maxima detection
	run("Duplicate...", "title=smoothed");
	//smoothing=2;
	run("Mean...", "radius="+smoothing);
	//prominence=3
	run("Find Maxima...", "prominence="+prominence+" output=[Single Points]");
	rename("nuclSeeds");
	selectWindow("smoothed");
	close();

	selectWindow("cellMask");
	setAutoThreshold("Huang dark");
	//thGreen=15;
	setThreshold(thGreen, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	;
	run("Median...", "radius=1");
	run("Fill Holes");
	run("Analyze Particles...", "size=2.5-Infinity show=Masks exclude in_situ");
	run("Create Selection");

	selectWindow("nuclSeeds");
	run("Select None");
	run("Restore Selection");
	setBackgroundColor(255, 255, 255);
	run("Clear Outside");
	run("Select None");
	
	selectWindow("cellMask");
	run("Select All");
	run("Duplicate...", "title=cellEdges");
	wait(100);
	run("Find Edges");
	wait(100);
	
	// MARKER-CONTROLLED WATERSHED
	run("Marker-controlled Watershed", "input=cellEdges marker=nuclSeeds mask=cellMask binary calculate use");
	wait(100);
	
	selectWindow("cellEdges-watershed");
	run("8-bit");
	setThreshold(1, 255);
	wait(100);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	
	selectWindow("cellEdges");
	close();
	selectWindow("cellMask");
	close();
	selectWindow("nuclSeeds");
	close();
	selectWindow("cellEdges-watershed");
	rename("cellMask");

	
	//--Update nuclei mask:
	selectWindow("blue");
	imageCalculator("AND", "blue","cellMask");
	wait(100);
	run("Analyze Particles...", "size=50-Infinity pixel show=Masks display exclude clear in_situ");
	
	nCells=nResults;
	print("nCells Segmented: "+nCells);
	An=newArray(nCells);
	for(i=0;i<nCells;i++){
		An[i]=getResult("Area",i);
	}
	
	selectWindow("blue");
	run("Create Selection");
	run("Add to Manager");
	selectWindow("blue");
	close();
	

	selectWindow("cellMask");
	run("Analyze Particles...", "size=10-Infinity pixel circularity=0.00-1.00 show=Masks add in_situ");
	
	// Delete cells without nucleus
	n=roiManager("count");
	print(n);
	nc = n-1;
	ncFinal = nc;
	for(i=1;i<=nc;i++){
		selectWindow("cellMask");
		roiManager("Deselect");
		roiManager("Show None");
		// Check if current cytoplasm is from a cell with nucleus
		roiManager("Select", 1);
		roiManager("Select", newArray(0,1));		
		roiManager("AND");
		type = selectionType();
	  	if (type==-1)
	  	{
	  		roiManager("Deselect");
	  		roiManager("Select", 1);
	  		setBackgroundColor(255, 255, 255);
			run("Clear", "slice");	
			ncFinal=ncFinal-1;		
	  	}
	  	roiManager("Deselect");
		roiManager("Select", 1);
		roiManager("Delete");	
	}
	
	run("Select None");
	run("Clear Results");
	//run("Analyze Particles...", "size=100-Infinity show=Masks display exclude clear in_situ");
	run("Analyze Particles...", "size=100-Infinity pixel show=Masks display add in_situ");
	
	//waitFor("");
	
	nCells2=nResults;
	print("nCells with Dapi signal: "+nCells2);
	Am=newArray(nCells2);
	for(i=0;i<nCells2;i++){
		Am[i]=getResult("Area",i);
	}
	
	selectWindow("cellMask");
	close();
	
	
	/*// DETECT GREEN--
	
	selectWindow("green");
	run("Duplicate...", "title=greenMask");
	run("Subtract Background...", "rolling=50");	// Largest nuclei radius ~10-12px
	run("8-bit");
	setAutoThreshold("Huang dark");
	setThreshold(thGreen, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=2");
	//run("Watershed");
	run("Analyze Particles...", "size=10-Infinity circularity=0.00-1.00 show=Masks exclude add in_situ");
	
	// Delete cells without nucleus
	n=roiManager("count");
	nc = n-1;
	ncFinal = nc;
	for(i=1;i<=nc;i++){
		selectWindow("greenMask");
		roiManager("Deselect");
		roiManager("Show None");
		// Check if current cytoplasm is from a cell with nucleus
		roiManager("Select", 0);
		roiManager("Select", newArray(0,1));		
		roiManager("AND");
		type = selectionType();
	  	if (type==-1)
	  	{
	  		roiManager("Deselect");
	  		roiManager("Select", 1);
	  		setBackgroundColor(255, 255, 255);
			run("Clear", "slice");	
			ncFinal=ncFinal-1;		
	  	}
	  	roiManager("Deselect");
		roiManager("Select", 1);
		roiManager("Delete");	
	}
	// Add remaining cytoplasms
	run("Analyze Particles...", "size=10-Infinity circularity=0.00-1.00 show=Masks exclude add in_situ");
	selectWindow("greenMask");
	close();*/
	
	
	// PROCESS GREEN ROIs
	
	selectWindow(MyTitle);
	run("Duplicate...", "title=green duplicate channels=2");
	selectWindow("green");
	n=roiManager("count");
	print(n);

	nc = n-1;
	In=newArray(nc);
	Ic=newArray(nc);
	Iall=newArray(nc);
	for(i=1;i<=nc;i++){
		// Measure signal in whole cell:
		roiManager("Deselect");
		roiManager("Select", i);	
		run("Measure");
		Iall[i-1]=getResult("Mean",nResults-1);
		// Measure signal in nucleus:
		roiManager("Deselect");
		roiManager("Select", newArray(0,i));
		roiManager("AND");
		run("Add to Manager");
		run("Measure");
		In[i-1]=getResult("Mean",nResults-1);
		// Measure signal in cytoplasm:
		roiManager("Deselect");
		roiManager("Select", newArray(i,i+nc));
		roiManager("XOR");
		type = selectionType();
	  	if (type==-1)
	  	{
	  		Ic[i-1]=0;	
	  	}
	  	else
	  	{
			run("Measure");
			Ic[i-1]=getResult("Mean",nResults-1);
	  	}
	}
	
	/*
	Array.print(An);
	Array.print(Am);
	Array.print(In);
	Array.print(Ic);
	Array.print(Iall);
	*/
	
	
	// Write results:
	run("Clear Results");
	if(File.exists(output+File.separator+"Quantification_Monocytes.xls"))
	{	
		//if exists add and modify
		open(output+File.separator+"Quantification_Monocytes.xls");
		IJ.renameResults("Results");
	}
	for(j=0;j<nc;j++){
		i=nResults;
		setResult("[Label]", i, MyTitle_short); 
		setResult("# Monocyte", i, j+1); 
		setResult("Area nucl (um2)", i, An[j]);
		setResult("Area monocyte (um2)", i, Am[j]);	
		setResult("Igreen nucl", i, In[j]); 
		setResult("Igreen cyto", i, Ic[j]); 
		setResult("Igreen whole cell", i, Iall[j]);		 
	}
	
	saveAs("Results", output+File.separator+"Quantification_Monocytes.xls");
	
	// DRAW:
	for(i=1;i<=nc;i++){
		roiManager("Deselect");
		roiManager("Select", nc+1);
		roiManager("Delete");
	}
	roiManager("Deselect");
	//roiManager("Select", 0);
	//roiManager("Delete");
	//roiManager("Deselect");
	
	
	
	selectWindow("green");
	run("Select None");
	roiManager("Show None");
	close();
	
	selectWindow("merge");
	run("Select None");
	roiManager("Select", 0);
	roiManager("Set Color", "cyan");
	roiManager("Set Line Width", 1);
	run("Flatten");
	roiManager("Delete");
	roiManager("Deselect");
	
	selectWindow("merge-1");
	roiManager("Show All");
	roiManager("Show None");
	roiManager("Show All with Labels");
	roiManager("Set Color", "magenta");
	roiManager("Set Line Width", 1);
	run("Flatten");
	
	wait(500);
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");	
	wait(500);
	rename(MyTitle_short+"_analyzed.jpg");
	
	if (InDir!="-") {
	close(); }
	
	selectWindow("merge");
	close();
	selectWindow("merge-1");
	close();
	selectWindow(MyTitle);
	close();
	
	run("Collect Garbage");

}


