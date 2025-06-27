
function macroInfo(){
	
// * Title

	scripttitle= "Automatic Field Split -> Separate Multiple Fields  ";
	version= "1.01";
	date= "04/09/2024";
	
// *  Tests Images:

	imageAdquisition=" Confocal";
	imageType="3D 8 bit ";  
	voxelSize="Voxel size: unknown um xy";
	format="Format: Uncompressed .qptiff";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button 
	
	parameter1="Number of Fields"; 
	 
 //  2 Action tools:
	buttom1="Im: Single File processing";
 	buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs

	feature1="SingeField Folders: individual images, tiff format ";
	
/*
 *  version: 1.01 
 *  Author: Tomas Muñoz 2024 
 *  Date : 2024
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
	    +"<ol><font size=2  i><li>"+buttom1+"</li><li>"+buttom2+"</li></ol>"
	    +"<p><font size=3  i>PARAMETERS: </i></p>"
	    +"<ul id=list-style-3><font size=2  i>"
	    +"<li>"+parameter1+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

}


var nSamples=6, nCols=3,nRows=2;

macro "IF_SplitSamples Action Tool 1 - Cf00T2d15IT6d10m"{

	close("*");
	macroInfo();
	
	// Open just one file
	name=File.openDialog("Select File");	
	run("Bio-Formats", "open=["+name+"] autoscale color_mode=Colorized view=Hyperstack stack_order=XYCZT");
		
	Dialog.create("SplitSamples");
	//Dialog.addNumber("Number of Samples", nSamples);
	Dialog.addNumber("Number of Columns", nCols);
	Dialog.addNumber("Number of Rows", nRows);
	Dialog.show();	
//	nSamples= Dialog.getNumber();
	nCols=Dialog.getNumber();
	nRows=Dialog.getNumber();
	
	OutDir=getDir("SELECT OUTPUT DIRECTORY");
	
	splitFields("-","-",name,OutDir,nSamples,nCols,nRows);
	
	showMessage("Fields splitted");
	close("*");
	
}

macro "IF_SplitSamples Action Tool 2 - C00fT0b11DT9b09iTcb09r"{

	close("*");
	macroInfo();
	
	InDir=getDirectory("Choose Tiles' directory");
	list=getFileList(InDir);
	L=lengthOf(list);
	
	OutDir=getDir("SELECT OUTPUT DIRECTORY");
	
	Dialog.create("SplitSamples");
	//Dialog.addNumber("Number of Samples", nSamples);
	Dialog.addNumber("Number of Columns", nCols);
	Dialog.addNumber("Number of Rows", nRows);
	Dialog.show();	
	//nSamples= Dialog.getNumber();
	nCols=Dialog.getNumber();
	nRows=Dialog.getNumber();
	
	
	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"czi")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print("Processing "+name);
			//setBatchMode(true);
			splitFields(InDir,InDir,list[j],OutDir,nSamples,nCols,nRows);
			setBatchMode(false);
			}
	}
	
	showMessage("Fields splitted");
	close("*");
	
}
	
	
function splitFields(InDir,InDir,name,OutDir,nSamples,nCols,nRows)
{				
	// Clear initialization of ROI manager and results table
	run("Collect Garbage");
	roiManager("Reset");
	run("Clear Results");
	close("*");


	RoiManager.associateROIsWithSlices(true);
	setOption("ExpandableArrays", true);
	setOption("WaitForCompletion", true);
	
	// Set color configuration and measurements
	run("Colors...", "foreground=white background=black selection=green");
	run("Set Measurements...", "area mean redirect=None decimal=2");
		
	// Set batch mode 
	setBatchMode(false);
	
	if (InDir=="-") {
		run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	}else {
		run("Bio-Formats Importer", "open=["+InDir+name+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	}	
	
	
	// Get file information
	MyTitle=getTitle();
	print(MyTitle);
		
	//OutDir = output+File.separator+"SplitSamples";
	//File.makeDirectory(OutDir);
		
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	rename(MyTitle_short);
	
	getDimensions(width, height, channels, slices, frames);
	getVoxelSize(rx,ry,rz, unit);
	setSlice(floor(slices/2));
		
	// Fields SEGMENTATION

	//nCols=3;
	//nRows=2;
	
	fieldX = (width/nCols);
	fieldY = (height/nRows);
	displacementXY=0;
	field=0;
	for (i = 0; i< nRows; i++) {
		for (j = 0; j <nCols; j++) {
			field+=1;
			//Array.print(newArray(nCols,nRows));
			//Array.print(newArray(i,j));
			selectWindow(MyTitle_short);
			makeRectangle(j*(displacementXY+fieldX),i*(displacementXY+fieldY), fieldX, fieldY);
			//Array.print(newArray(i*(displacementXY+fieldX),j*(displacementXY+fieldY),fieldX,fieldY));
			//waitForUser;
			run("Duplicate...", "duplicate");
			saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_Field-"+field);
		}
	}
	

}		
	
	








