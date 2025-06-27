function macroInfo(){
	
// * Automatic Nuclei and Cell Segmentation in IF 3D Images
// * Target User: Rosa Tordera, Ainhoa Garayo
//  changelog February2019
//  automatic cell segmentation in 3D stack
//  automatic nuclei segmentation in 3D stack
//  volume measurements.
// *  

	scripttitle= "Automatic Nuclei and Cell Segmentation in IF 3D Images";
	version= "1.03";
	date= "2015";
	

// *  Tests Images:

	imageAdquisition="Confocal: ";
	imageType="IF 3D 2 Channel: DAPI + Cell Marker.";  
	voxelSize="Voxel size:  0.502 um xy";
	format="czi";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button 
 
	 parameter1="Projection Threshold : Using DAPI Maxima Projection, Threshold to separate Nucleus from background "; 
	 parameter2="Cell Threshold: Threshold to separate Cell Signal from Background ";
	 parameter3="Nucleus Threshold: Threshold to separate Nucleus Signal from Background ";
	 parameter4="Radius to erode.";
 
 //  2 Action tools:
	 buttom1="Im: Single File processing";
	 buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs

	excel="QuantificationResutls_IF3D_NuclCyto.xls";

	feature1="# Cell ID"; 
	feature2="Vol nucl (microns^3)";
	feature3="Vol nucl (voxels)";
	feature4="Vol cyto (microns^3)";
	feature5="Vol cyto (voxels)";
	feature6="Vol cell (microns^3)";
	feature7="Vol cell (voxels)";				 
	feature8="Iavg nucl (0-255)";
	feature9="Iavg cyto (0-255)";
	feature10="Iavg cell (0-255)";				 
	feature11="Saturated voxels (%)";				 


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
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li>"
	    +"<li>"+parameter3+"</li>"
	    +"<li>"+parameter4+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li><li>"+feature5+"</li><li>"+feature6+"</li><li>"+feature7+"</li><li>"+feature8+"</li>"
	    +"<li>"+feature9+"</li><li>"+feature10+"</li><li>"+feature11+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}
	
var thProjection=30, thCell=8, thNucl=85, erodeRad=1;		

macro "IFnuclCyto3D Action Tool 1 - Cf00T2d15IT6d10m"{

	close("*");
	macroInfo();
	
	
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	//setBatchMode(true);
	print(name);
	ifnuclcyto3d("-","-",name);
	setBatchMode(false);
	showMessage("Done!");

}
		
macro "IFnuclCyto3D Action Tool 2 - C00fT0b11DT9b09iTcb09r"{

	close("*");
	macroInfo();
	
	InDir=getDirectory("Choose a Directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"czi") || endsWith(list[j],"tif")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print(name);
			//setBatchMode(true);
			ifnuclcyto3d(InDir,InDir,list[j]);
			setBatchMode(false);
			}
	}
	showMessage("Done!");
}



macro "IFnuclCyto3D Action Tool 1 Options" {
        Dialog.create("Parameters");

	Dialog.addMessage("Choose parameters")	
	Dialog.addNumber("Projection threshold", thProjection);	
	Dialog.addNumber("Cell threshold", thCell);	
	Dialog.addNumber("Nucleus threshold", thNucl);	
	Dialog.addNumber("Erosion radius", erodeRad);
	Dialog.show();	
	thProjection= Dialog.getNumber();
	thCell= Dialog.getNumber();
	thNucl= Dialog.getNumber();
	erodeRad= Dialog.getNumber();	
}

macro "IFnuclCyto3D Action Tool 2 Options" {
        Dialog.create("Parameters");
 
	Dialog.addMessage("Choose parameters")	
	Dialog.addNumber("Projection threshold", thProjection);	
	Dialog.addNumber("Cell threshold", thCell);	
	Dialog.addNumber("Nucleus threshold", thNucl);	
	Dialog.addNumber("Erosion radius", erodeRad);	
	Dialog.show();	
	thProjection= Dialog.getNumber();
	thCell= Dialog.getNumber();
	thNucl= Dialog.getNumber();	
	erodeRad= Dialog.getNumber();	
}


function ifnuclcyto3d(output,InDir,name)
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
	
	//print(thProjection);
	//print(thCell);
	//print(thNucl);
	
	Stack.setDisplayMode("composite");
	Stack.setChannel(1);
	run("Green");
	Stack.setChannel(2);
	run("Blue");
	
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
	
	getVoxelSize(vxW, vxH, depth, unit);
	//print(depth);
	//print(vxW);
	
	setBatchMode(true);
	
	// CREATE CELL MASK IN THE 3D PROJECTION
	selectWindow(MyTitle);
	run("RGB Color", "slices keep");
	run("8-bit");
	rename("temp");
	run("Z Project...", "projection=[Sum Slices]");
	rename("projection");
	run("8-bit");
	//thProjection=15;
	setThreshold(thProjection, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=2");
	run("Watershed");
	run("Analyze Particles...", "size=20-Infinity show=Masks exclude add in_situ");	// add projections as ROIs
	nCells=roiManager("Count");
	close();
	selectWindow("temp");
	close();
	
	
	// CREATE CELL MASK IN EVERY SLICE FROM THE TWO CHANNELS
	selectWindow(MyTitle);
	run("RGB Color", "slices keep");
	run("8-bit");
	rename("cellMask");
	run("Threshold...");
	setAutoThreshold("Huang dark");
	//setThreshold(5, 255);
	//thCell=8;
	setThreshold(thCell, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark");
	//run("Median...", "radius=3 stack");
	run("Median 3D...", "x=2 y=2 z=2");
	run("Invert", "stack");
	setThreshold(0, 128);
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Default");
	run("Close-", "stack");
	run("Fill Holes", "stack");
	
	
	// CREATE NUCLEI MASK IN EVERY SLICE 
	selectWindow(MyTitle);
	run("Duplicate...", "title=nucleiMask duplicate channels=2 slices=1-"+slices);
	run("8-bit");
	run("Threshold...");
	setAutoThreshold("Huang dark");
	//setThreshold(5, 255);
	//thNucl=30;
	setThreshold(thNucl, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark");
	run("Median 3D...", "x=2 y=2 z=2");
	run("Invert", "stack");
	setThreshold(0, 128);
	run("Convert to Mask", "method=Default background=Dark");
	run("Close-", "stack");
	run("Fill Holes", "stack");
	run("Invert", "stack");
	erodeRad=1;
	run("Morphological Filters (3D)", "operation=Erosion element=Ball x-radius="+erodeRad+" y-radius="+erodeRad+" z-radius="+erodeRad);
	selectWindow("nucleiMask");
	close();
	selectWindow("nucleiMask-Erosion");
	rename("nucleiMask");
	run("Invert", "stack");
	
	
	// CREATE CYTOPLASM MASK IN EVERY SLICE
	imageCalculator("XOR create stack", "nucleiMask","cellMask");
	rename("cytoMask");
	//run("Invert", "stack");	// cytoplasm en black, background in white
	
	
	// PREPARE GREEN IMAGE FOR MEASURES:
	selectWindow(MyTitle);
	run("Duplicate...", "title=greenStack duplicate channels=1 slices=1-"+slices);
	run("Set Measurements...", "area mean display redirect=None decimal=2");
	
	// CREATE MASK OF SATURATED VOXELS IN GREEN:
	selectWindow("greenStack");
	run("Duplicate...", "title=satVox duplicate range=1-"+slices);
	setThreshold(255, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark");
	
	
	// MEASURE VOLUMES AND GREEN INTENSITIES IN NUCLEUS AND CYTOPLASM FOR EACH CELL:
	Vcell=newArray(nCells);
	Vnucl=newArray(nCells);
	Vcyto=newArray(nCells);
	VcellVX=newArray(nCells);
	VnuclVX=newArray(nCells);
	VcytoVX=newArray(nCells);
	RsatVX=newArray(nCells);
	IAVGcell=newArray(nCells);
	IAVGnucl=newArray(nCells);
	IAVGcyto=newArray(nCells);
	for(i=0;i<nCells;i++) 
	{
		// Whole cell:
		selectWindow("cellMask");
		run("Duplicate...", "title=aa duplicate range=1-"+slices);
		roiManager("Deselect");
		roiManager("Select", i);
		setBackgroundColor(255, 255, 255);
		run("Clear Outside", "stack");
		run("Select None");	
		Aacc=0;
		Iacc=0;
		for (j=0;j<slices;j++){	
			run("Clear Results");
			selectWindow("aa");
			setSlice(j+1);
			run("Create Selection");
			type = selectionType();
		  	if (type!=-1)
		  	{
		  		selectWindow("greenStack");
		  		setSlice(j+1);
		  		run("Restore Selection");
		  		run("Measure");
		  		temp=getResult("Area",0);
		  		temp2=getResult("Mean",0);
		  		Aacc=Aacc+temp;
		  		Iacc=Iacc+temp2*temp;	// weigh each slice intensity with the area of the ROI
		  	}
		}
		Vcell[i]=Aacc*depth;
		VcellVX[i]=round(Aacc/(vxW*vxH));  // volume in number of voxels
		IAVGcell[i]=Iacc/Aacc;
		selectWindow("aa");
		close();
	
		// Nucleus:
		selectWindow("nucleiMask");
		run("Duplicate...", "title=aa duplicate range=1-"+slices);
		roiManager("Deselect");
		roiManager("Select", i);
		setBackgroundColor(255, 255, 255);
		run("Clear Outside", "stack");
		run("Select None");	
		Aacc=0;
		Iacc=0;
		for (j=0;j<slices;j++){				
			run("Clear Results");
			selectWindow("aa");
			setSlice(j+1);
			run("Create Selection");
			type = selectionType();
		  	if (type!=-1)
		  	{
		  		selectWindow("greenStack");
		  		setSlice(j+1);
		  		run("Restore Selection");
		  		run("Measure");
		  		temp=getResult("Area",0);
		  		temp2=getResult("Mean",0);
		  		Aacc=Aacc+temp;
		  		Iacc=Iacc+temp2*temp;	// weigh each slice intensity with the area of the ROI
		  	}
		}
		Vnucl[i]=Aacc*depth;
		VnuclVX[i]=round(Aacc/(vxW*vxH));  // volume in number of voxels
		IAVGnucl[i]=Iacc/Aacc;
		selectWindow("aa");
		close();
	
		// Cytoplasm:
		selectWindow("cytoMask");
		run("Duplicate...", "title=aa duplicate range=1-"+slices);
		roiManager("Deselect");
		roiManager("Select", i);
		setBackgroundColor(255, 255, 255);
		run("Clear Outside", "stack");
		run("Select None");	
		Aacc=0;
		Iacc=0;
		for (j=0;j<slices;j++){				
			run("Clear Results");
			selectWindow("aa");
			setSlice(j+1);
			run("Create Selection");
			type = selectionType();
		  	if (type!=-1)
		  	{
		  		selectWindow("greenStack");
		  		setSlice(j+1);
		  		run("Restore Selection");
		  		run("Measure");
		  		temp=getResult("Area",0);
		  		temp2=getResult("Mean",0);
		  		Aacc=Aacc+temp;
		  		Iacc=Iacc+temp2*temp;	// weigh each slice intensity with the area of the ROI
		  	}
		}
		Vcyto[i]=Aacc*depth;
		VcytoVX[i]=round(Aacc/(vxW*vxH));  // volume in number of voxels
		IAVGcyto[i]=Iacc/Aacc;
		selectWindow("aa");
		close();
	
		// Calculate % of saturated voxels in green:
		selectWindow("satVox");
		run("Duplicate...", "title=aa duplicate range=1-"+slices);
		roiManager("Deselect");
		roiManager("Select", i);
		setBackgroundColor(255, 255, 255);
		run("Clear Outside", "stack");
		run("Select None");
		Aacc=0;
		for (j=0;j<slices;j++){				
			run("Clear Results");
			setSlice(j+1);
			run("Create Selection");
			type = selectionType();
		  	if (type!=-1)
		  	{
		  		run("Measure");
		  		temp=getResult("Area",0);
		  		Aacc=Aacc+temp;
		  	}
		}	
		VsatVX=round(Aacc/(vxW*vxH));  // saturated volume in number of voxels
		RsatVX[i]=VsatVX/VcellVX[i]*100;  // percentage of saturated voxels in current cell
		selectWindow("aa");
		close();	
			
	}
	
	
	// Write results:
	run("Clear Results");
	if(File.exists(output+File.separator+"QuantificationResutls_IF3D_NuclCyto.xls"))
	{
		
		//if exists add and modify
		open(output+File.separator+"QuantificationResutls_IF3D_NuclCyto.xls");
		IJ.renameResults("Results");
			
		for(j=0;j<nCells;j++){
			i=nResults;
			setResult("[Label]", i, MyTitle); 
			setResult("# Cell", i, j+1); 
			setResult("Vol nucl ("+unit+"^3)", i, Vnucl[j]);
			setResult("Vol nucl (voxels)", i, VnuclVX[j]);
			setResult("Vol cyto ("+unit+"^3)", i, Vcyto[j]);
			setResult("Vol cyto (voxels)", i, VcytoVX[j]);
			setResult("Vol cell ("+unit+"^3)", i, Vcell[j]);
			setResult("Vol cell (voxels)", i, VcellVX[j]);				 
			setResult("Iavg nucl (0-255)", i, IAVGnucl[j]);
			setResult("Iavg cyto (0-255)", i, IAVGcyto[j]);
			setResult("Iavg cell (0-255)", i, IAVGcell[j]);				 
			setResult("Saturated voxels (%)", i, RsatVX[j]);	
		}	
		
		saveAs("Results", output+File.separator+"QuantificationResutls_IF3D_NuclCyto.xls");
		
	}
	else
	{
		
		for(j=0;j<nCells;j++){
			i=nResults;		
			setResult("[Label]", i, MyTitle); 
			setResult("# Cell", i, j+1); 
			setResult("Vol nucl ("+unit+"^3)", i, Vnucl[j]);
			setResult("Vol nucl (voxels)", i, VnuclVX[j]);
			setResult("Vol cyto ("+unit+"^3)", i, Vcyto[j]);
			setResult("Vol cyto (voxels)", i, VcytoVX[j]);
			setResult("Vol cell ("+unit+"^3)", i, Vcell[j]);
			setResult("Vol cell (voxels)", i, VcellVX[j]);				 
			setResult("Iavg nucl (0-255)", i, IAVGnucl[j]);
			setResult("Iavg cyto (0-255)", i, IAVGcyto[j]);
			setResult("Iavg cell (0-255)", i, IAVGcell[j]);		 
			setResult("Saturated voxels (%)", i, RsatVX[j]);
		}	
		saveAs("Results", output+File.separator+"QuantificationResutls_IF3D_NuclCyto.xls");
		
	}
	
	setBatchMode("exit and display");
	
	// DRAW:
	selectWindow(MyTitle);
	run("RGB Color", "slices keep");
	rename("temp");
	run("Z Project...", "projection=[Sum Slices]");
	rename("merge");
	selectWindow("temp");
	close();
	
	selectWindow("nucleiMask");
	run("Z Project...", "projection=[Min Intensity]");
	rename("nuclProj");
	roiManager("Deselect");
	roiManager("Combine");
	run("Clear Outside");
	run("Create Selection");
	selectWindow("merge");
	run("Restore Selection");
	roiManager("Set Color", "yellow");
	roiManager("Set Line Width", 1);
	run("Flatten");
	wait(500);
	
	selectWindow("merge-1");
	roiManager("Show All");
	roiManager("Show None");
	roiManager("Show All with Labels");
	roiManager("Set Color", "red");
	roiManager("Set Line Width", 1);
	run("Flatten");
	wait(500);
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	setBatchMode("show");	
	wait(500);
		
	if (InDir!="-") {
	close(); }
	
	selectWindow("Threshold");
	run("Close");
	close("merge");
	close("merge-1");
	close("nucleiMask");
	close("cellMask");
	close("cytoMask");
	close("greenStack");
	close("satVox");
	close("nuclProj");
	close(MyTitle);
	
	setBatchMode("exit and display");	


}

