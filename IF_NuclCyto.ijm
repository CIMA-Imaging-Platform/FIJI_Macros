
function macroInfo(){
	
// * Title  
	scripttitle =  "Nucleus and Cytomplasm InmunoFlourescence Signal Quantification ";
	version =  "1.02";
	date =  "2025";
	

// *  Tests Images:

	imageAdquisition = "IF Confocal 2 Channel: DAPI + Marker";
	imageType = "2D - 8 bit";  
	voxelSize = "Voxel size:  unknown";
	format = "Format: czi";   
 
 //*  GUI User Requierments:
 //  	- save and load previous ROIS --> todo
 //*    - Interactive Threshold. --> done
 //*	- Delete Unwanted tissue and SR positive--> done
 //		- Single File and Batch Mode --> done
 //*    
 // Important Parameters: 
 
 	parameter1 = "DAPI Channel order";
	parameter2 = "Marker Channel order";
	parameter3 = "DAPI threshold: Nuclei signal segmentation: [0 - 255]";
	parameter4 = "Marker threshold: Marker positive signal segmentation: [0 - 255]";	
	parameter5 = "Prominence for cell separation: [1-10]";	
	parameter6 = "Smoothing for cell separation:[0,2,4]";
	 
	  
 //  2 Action tools:
		
	 buttom1 = "Im: Single File processing. Use Single file processing for fine tunning parameters";
	 buttom2 = "Dir: Batch Mode. Please tune parameters before using Batchmode";

//  OUTPUT

// Analyzed Images with ROIs

	excel = "QuantificationResults_IF_NuclCyto.xls";
	feature1 = "[Label]"; 
	feature2 = "# ID Cell"; 
	feature3 = "Area nucl (um2)";
	feature4 = "Area Cell (um2)";	
	feature5 = "meanIMarker nucl"; 
	feature6 = "meanIMarker cyto"; 
	feature7 = "meanIMarker whole cell";		 
	
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

	
	//image1 = "../templateImages/cartilage.jpg";
	//descriptionActionsTools = "
	
	showMessage("ImageJ Script", "<html>"
		+"<style>h{margin-top: 5px; margin-bottom: 5px;} p{margin: 0px;padding: 0px;} ol{margin-left: 20px;padding: 5px;} #list-style-3 {list-style-type: circle;.container {max-width: 1200px; margin: 0 auto; padding: 0px; }</style>"
	    +"<h1><font size = 6 color = Teal href = https://cima.cun.es/en/research/technology-platforms/image-platforms>CIMA: Imaging Platform</h1>"
	    +"<h1><font size = 5 color = Purple><i>Software Development Service</i></h1>"
	    +"<p><font size = 2 color = Purple><i>ImageJ Macros</i></p>"
	    +"<h2><font size = 3 color = black>"+scripttitle+"</h2>"
	    +"<p><font size = 2>Modified by Tomas Mu&ntilde;oz Santoro</p>"
	    +"<p><font size = 2>Version: "+version+" ("+date+")</p>"
	    +"<p><font size = 2> contact tmsantoro@unav.es</p>" 
	    +"<p><font size = 2> Available for use/modification/sharing under the "+"<p4><a href = https://opensource.org/licenses/MIT/>MIT License</a></p>"
	    +"<h2><font size = 3 color = black>Developed for</h2>"
	    +"<p><font size = 3  i>Input Images</i></p>"
	    +"<ul id = list-style-3><font size = 2  i><li>"+imageAdquisition +"</li><li>"+imageType+"</li><li>"+voxelSize+"</li><li>"+format+"</li></ul>"
	    +"<p><font size = 3 i>Action tools (Buttons)</i></p>"
	    +"<ol><font size = 2  i><li>"+buttom1+"</li><li>"+buttom2+"</li></ol>"
	    +"<p><font size = 3  i>PARAMETERS:</i></p>"
	    +"<ul id = list-style-3><font size = 2  i>"
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li>"
	    +"<li>"+parameter3+"</li>"
	    +"<li>"+parameter4+"</li>"	    
	    +"<li>"+parameter5+"</li>"
	    +"<li>"+parameter6+"</li></ul>"
	    +"<p><font size = 3  i>Quantification Results: </i></p>"
	    +"<p><font size = 3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size = 3  i>Excel "+excel+"</i></p>"
	    +"<ul id = list-style-3><font size = 2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li><li>"+feature5+"</li><li>"+feature6+"</li><li>"+feature7+"</li></ul>"
	    +"<h0><font size = 5></h0>"
	    +"");
	   //+"<P4><font size = 2> For more detailed instructions see "+"<p4><a href = https://www.protocols.io/edit/movie-timepoint-copytoclipboaMarker2-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}



var cDapi =  2, cMarker = 1, thDapi = 20 , thMarker = 40, prominence = 3,  erodeRad = 0, smoothing = 2; 

macro "IF_NuclCyto Action Tool 1 - Cf00T2d15IT6d10m"{

	run("Close All");
	run("Collect Garbage");

	//just one file
	name = File.openDialog("Select File");
	
	if (endsWith(name, ".jpg") || endsWith(name, ".tif")) {
			open(name);
	} else if (endsWith(name, ".czi") || endsWith(name, ".svs")) {
			run("Bio-Formats Importer", "open=[" + name + "] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	}
	
	macroInfo();
	
	Dialog.create("Parameters");
	Dialog.addNumber("DAPI Channel", cDapi);
	Dialog.addNumber("Marker Channel", cMarker);	
	Dialog.addNumber("DAPI threshold", thDapi);
	Dialog.addNumber("Marker threshold", thMarker);	
	//Dialog.addNumber("Erosion radius (px)", erodeRad);	
	Dialog.addNumber("Prominence for cell separation", prominence);	
	Dialog.addNumber("Smoothing for cell separation", smoothing);	
	Dialog.show();	
	
	cDapi = Dialog.getNumber();
	cMarker = Dialog.getNumber();
	thDapi  =  Dialog.getNumber();	
	thMarker = Dialog.getNumber();	
//	erodeRad= Dialog.getNumber();	
	prominence =  Dialog.getNumber();	
	smoothing =  Dialog.getNumber();	
	
	//setBatchMode(true);
	print(name);
	IF_NuclCyto("-","-",name,cDapi,cMarker,thDapi,thMarker,erodeRad,prominence,smoothing);
	setBatchMode(false);
	showMessage("Done!");
	
}
		
macro "IF_NuclCyto Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	run("Close All");	
	run("Collect Garbage");

	macroInfo();
	
	InDir = getDirectory("Choose a Directory");
	list = getFileList(InDir);
	L = lengthOf(list);

	Dialog.create("Parameters");
	Dialog.addNumber("DAPI Channel", cDapi);
	Dialog.addNumber("Marker Channel", cMarker);	
	Dialog.addNumber("DAPI threshold", thDapi);
	Dialog.addNumber("Marker threshold", thMarker);	
	//Dialog.addNumber("Erosion radius (px)", erodeRad);	
	Dialog.addNumber("Prominence for cell separation", prominence);	
	Dialog.addNumber("Smoothing for cell separation", smoothing);	
	Dialog.show();	
	
	cDapi = Dialog.getNumber();
	cMarker = Dialog.getNumber();
	thDapi  =  Dialog.getNumber();	
	thMarker = Dialog.getNumber();	
//	erodeRad= Dialog.getNumber();	
	prominence =  Dialog.getNumber();	
	smoothing =  Dialog.getNumber();	

	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"czi")){
			//analyze
			//d = InDir+list[j]t;
			name = list[j];
			print(name);
			//setBatchMode(true);
			IF_NuclCyto(InDir,InDir,list[j],cDapi,cMarker,thDapi,thMarker,erodeRad,prominence,smoothing);
			setBatchMode(false);
			}
	}
	showMessage("Done!");
}


function IF_NuclCyto(output,InDir,name,cDapi,cMarker,thDapi,thMarker,erodeRad,prominence,smoothing)
{
		
	if (InDir=="-") {
		if (endsWith(name, ".jpg") || endsWith(name, ".tif")) {
			open(name);
		} else if (endsWith(name, ".czi") || endsWith(name, ".svs")) {
			run("Bio-Formats Importer", "open=[" + name + "] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		}
	}else {
		
		if (endsWith(InDir+name, ".jpg") || endsWith(InDir+name, ".tif")) {
			open(file);
		} else if (endsWith(InDir+name, ".czi") || endsWith(InDir+name, ".svs")) {
			run("Bio-Formats Importer", "open=[" + InDir+name + "] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		}
	}
	
	Stack.setDisplayMode("composite");
	run("Colors...", "foreground=black background=white selection=yellow");
	Stack.getDimensions(width, height, channels, slices, frames);
	
	roiManager("Reset");
	run("Clear Results");
	MyTitle = getTitle();
	output = getInfo("image.directory");
	
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	setBatchMode(true);
	
	run("RGB Color");
	rename("merge");
	
	run("Colors...", "foreground=black background=white selection=red");
	run("Set Measurements...", "area mean display redirect=None decimal=2");
	
	
	// SEGMENT NUCLEI -- DAPI SIGNAL
	selectWindow(MyTitle);
	run("Duplicate...", "title=Nucleus duplicate channels="+cDapi);
	selectWindow("Nucleus");
	run("Subtract Background...", "rolling=50");
	run("Mean...", "radius="+smoothing+" slice");
	run("8-bit");
	setAutoThreshold("Default dark");
	//thDapi = 50;
	setThreshold(thDapi, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Morphological Filters", "operation=Closing element=Disk radius=2");
	run("Median...", "radius=1");
	//run("Watershed");
	run("Analyze Particles...", "size=200-Infinity pixel show=Masks  clear in_situ");
	close("Nucleus");
	rename("Nucleus");
	
	selectWindow("Nucleus");
	run("Duplicate...", "title=nuclSeeds");
	run("Distance Map");
	//prominence=3;
	run("Find Maxima...", "prominence="+prominence+" light output=[Single Points]");
	close("nuclSeeds");
	rename("nuclSeeds");
	
	
	// SEGMENT MERKER SIGNAL
	
	selectWindow(MyTitle);
	run("Duplicate...", "title=cytoMarker channel="+cMarker);
	setAutoThreshold("Huang dark");
	//thMarker=15;
	setThreshold(thMarker, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Morphological Filters", "operation=Closing element=Disk radius=2");
	run("Median...", "radius=1");
	run("Fill Holes");
	run("Analyze Particles...", "size=100-Infinity show=Masks in_situ");
	
	close("cytoMarker");
	rename("cytoMarker");
	run("Create Selection");
	selectWindow("nuclSeeds");
	run("Select None");
	run("Restore Selection");
	setBackgroundColor(255, 255, 255);
	run("Clear Outside");
	run("Select None");
	
	selectWindow("cytoMarker");
	run("Select All");
	run("Duplicate...", "title=cytoEdges");
	run("Find Edges");
	
	// MARKER-CONTROLLED WATERSHED
	run("Marker-controlled Watershed", "input=cytoEdges marker=nuclSeeds mask=cytoMarker binary calculate use");
	wait(100);
	
	selectWindow("cytoEdges-watershed");
	run("8-bit");
	setThreshold(1, 255);
	wait(100);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	
	close("cytoEdges");
	close("cytoMarker");
	close("nuclSeeds");
	selectWindow("cytoEdges-watershed");
	rename("cellMask");
	
	//--Update nuclei mask:
	selectWindow("Nucleus");
	imageCalculator("AND", "Nucleus","cellMask");
	run("Analyze Particles...", "size=50-Infinity pixel show=Masks display clear in_situ");
	
	nCells = nResults;
	print("nCells Segmented: "+nCells);
	An = newArray(nCells);
	for(i=0;i<nCells;i++){
		An[i] = getResult("Area",i);
	}
	
	selectWindow("Nucleus");
	run("Create Selection");
	run("Add to Manager");
	close("Nucleus");
	

	selectWindow("cellMask");
	run("Analyze Particles...", "size=10-Infinity pixel circularity=0.00-1.00 show=Masks add in_situ");
	
	// Delete cells without nucleus
	n = roiManager("count");
	print(n);
	nc  =  n-1;
	ncFinal  =  nc;
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
			ncFinal = ncFinal-1;		
	  	}
	  	roiManager("Deselect");
		roiManager("Select", 1);
		roiManager("Delete");	
	}
	
	run("Select None");
	run("Clear Results");
	//run("Analyze Particles...", "size = 100-Infinity show=Masks display exclude clear in_situ");
	run("Analyze Particles...", "size=100-Infinity pixel show=Masks display add in_situ");
	
	//waitFor("");
	
	nCells2 = nResults;
	print("nCells with Dapi signal: "+nCells2);
	Am = newArray(nCells2);
	for(i=0;i<nCells2;i++){
		Am[i]=getResult("Area",i);
	}
	
	selectWindow("cellMask");
	close();
		
	
	// PROCESS Marker ROIs
	
	selectWindow(MyTitle);
	run("Duplicate...", "title=Marker duplicate channels="+cMarker);
	selectWindow("Marker");
	setBatchMode("show");
	n = roiManager("count");
	print(n);

	nc = n-1;
	In = newArray(nc);
	Ic = newArray(nc);
	Iall = newArray(nc);
	for(i=1;i<=nc;i++){
		// Measure signal in whole cell:
		roiManager("Deselect");
		roiManager("Select", i);	
		run("Measure");
		Iall[i-1] = getResult("Mean",nResults-1);
		// Measure signal in nucleus:
		roiManager("Deselect");
		roiManager("Select", newArray(0,i));
		roiManager("AND");
		run("Add to Manager");
		run("Measure");
		In[i-1] = getResult("Mean",nResults-1);
		// Measure signal in cytoplasm:
		roiManager("Deselect");
		roiManager("Select", newArray(i,i+nc));
		roiManager("XOR");
		type = selectionType();
	  	if (type==-1)
	  	{
	  		Ic[i-1] = 0;	
	  	}
	  	else
	  	{
			run("Measure");
			Ic[i-1] = getResult("Mean",nResults-1);
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
	if(File.exists(output+File.separator+"QuantificationResults_IF_NuclCyto.xls"))
	{	
		//if exists add and modify
		open(output+File.separator+"QuantificationResults_IF_NuclCyto.xls");
		IJ.renameResults("Results");
	}
	for(j=0;j<nc;j++){
		i = nResults;
		setResult("[Label]", i, MyTitle_short); 
		setResult("# ID Cell", i, j+1); 
		setResult("Area nucl (um2)", i, An[j]);
		setResult("Area Cell (um2)", i, Am[j]);	
		setResult("meanIMarker nucl", i, In[j]); 
		setResult("meanIMarker cyto", i, Ic[j]); 
		setResult("meanIMarker whole cell", i, Iall[j]);		 
	}
	
	saveAs("Results", output+File.separator+"QuantificationResults_IF_NuclCyto.xls");
	
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
	
	selectWindow("Marker");
	run("Select None");
	roiManager("Show None");
	close();
	
	selectWindow("merge");
	run("Select None");
	roiManager("Select", 0);
	roiManager("Set Color", "cyan");
	roiManager("Set Line Width", 1);
	run("Flatten");
	wait(500);
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
	
	setBatchMode("exit and display");
	
	run("Collect Garbage");

}


