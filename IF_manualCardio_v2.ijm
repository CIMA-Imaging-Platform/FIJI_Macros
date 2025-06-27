/*
 * MANUAL CARDIOMYOCITYES count
 * manual selection of cardiomyocites, measure area and equivalent diameter
 * Target User: Leire Tapia Villanueva.
 *  
 *  Images: 
 *    - Fluerescence Microscopy :  RGB images. DAPI and Green Channel are selected.
 *    - Format .jpg   
 *  
 *  GUI Requierments:
 *    - User must draw cell countour. 
 *    - automatic detection Nuclei.
 *  
 *  Important Parameters
 * 	  - pixel ratio - var r=0.502 // Scanner 20X
 * 	  - thDAPI=25;	
 *    
 *  OUTPUT: 
 *		setResult("Label", i, "C"+(i+1));		
		setResult("Area CM (micra²)",i,a);
		setResult("Equivalent diameter (micra)",i,d);
		setResult("Area nucleus (micra²)",i,An);
 *     
 *  Author: Mikel Ariz 
 *  Modified : Tomás Muñoz tmsantoro@unav.es
 *  Date : December 2022
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


function macroInfo(){
	scripttitle= "MANUAL CARDIOMYOCTYES : manual selection of cardiomyocites, measure area and equivalent diameter ";
	version= "1.03";
	date= "December 2022";
	
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
	    +"<ul id=list-style-3><font size=2  i><li>Fluerescence Microscopy :  RGB images. 20x</li><li>8bit bit Images </li><li>Resolution: 0.502 um </li<li>Format .tif</li></i></ul>"
	    +"<p><font size=3 i>Action tools (Buttons)</i></p>"
	    +"<ul><font size=2  i><li>M: Single File Processing</li></ul>"
	    +"<p><font size=3  i>Steps to follow</i></p><ol><li>Select File by dragging</li><li>Press M: Manual CM</li><li>Introduce parameters</li><li>Draw Manualy Cells Contour</li><li>Follow instructions</li></ol>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=2  i>AnalyzedImages : Visualize Segmented Images</i></p>"
	    +"<p><font size=2  i>Excel FileName.xls</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>CM ID<li>CM Area (um2)</li><li>Equivalent Diameter (um)</li><li>Nucleus Area (um2)</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}



var r=0.502, thDAPI=25;	// Scanner 20X

macro "manualCardio Action Tool - Cf00T4d14M"
{

	roiManager("reset");
	run("Clear Results");
	
	macroInfo(); 
	
	var r=0.502, thDAPI=25;	// Scanner 20X

	Dialog.create("Parameters");
	Dialog.addMessage("Choose parameters")	
	Dialog.addNumber("Ratio micra/pixel", r);
	Dialog.addNumber("Nuclei threshold", thDAPI);
	Dialog.show();	
	r= Dialog.getNumber();		
	thDAPI= Dialog.getNumber();	
	
	run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width="+r+" pixel_height=+"+r+" voxel_depth=1.0000 frame=[0 sec] origin=0,0");
	run("Set Measurements...", "area redirect=None decimal=2");
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	OutDir = output+File.separator+"AnalyzedImages/";
	File.makeDirectory(OutDir);
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	selectWindow(MyTitle);
	setTool("zoom");
	
	// Manage cardiomyocite selection
	q=getBoolean("Do you want to select a cardiomyocyte?");
	
	while(q){
		
		roiManager("Reset");		
		run("Clear Results");
		setTool("freehand");;	
		roiManager("Show All");	// show to avoid drawing one already measured	
		
		// load previous rois--
		if(File.exists(OutDir+File.separator+MyTitle_short+"_CariomyocitesROIs.zip"))
		{	
			//if exists add and modify
			roiManager("Open", OutDir+File.separator+MyTitle_short+"_CariomyocitesROIs.zip");
		}
	
		
		//roiManager("Show None");
		waitForUser("Please, draw the cardiomyocyte and press ok when ready");
		type = selectionType();
	  	if (type==-1){	//if there is no selection, select the whole image
		      waitForUser("Tienes que seleccionar un cardiomiocito antes de pulsar OK");
	  	}
		roiManager("add");
		nCardio=roiManager("count");
		roiManager("select", nCardio-1);
		run("Measure");
		a=getResult("Area",0);
		
		roiManager("deselect");
		
		// WRITE ROIS--
		roiManager("Save",  OutDir+File.separator+MyTitle_short+"_CariomyocitesROIs.zip");
				
		//calculate equivalent diameter
		d=2*sqrt(a/PI);
	
		//--Create a DAPI image by splitting RGB:	
		run("Duplicate...", "title=cm");
		run("Duplicate...", "title=cmMask");
		run("Select None");
		run("Split Channels");
		selectWindow("cmMask (green)");
		close();
		selectWindow("cmMask (red)");
		close();
		selectWindow("cmMask (blue)");
		rename("dapi");
		  //thDAPI = 25;
		setThreshold(thDAPI, 255);
		setOption("BlackBackground", false);
		run("Convert to Mask");
		run("Median...", "radius=1");
		
		//Check if nucleus inside the cell
		
		run("Create Selection");
		typeSelection=selectionType();

		if (typeSelection != -1){
			run("Keep Largest Region");
			selectWindow("dapi");
			close();
			selectWindow("dapi-largest");
			rename("dapi");
			run("Create Selection");
			run("Measure");
			An=getResult("Area",1);
		
		}else{
			An=0;
		}
		
		selectWindow("dapi");	
		close();
		selectWindow("cm");	
		run("Restore Selection");
		run("Select None");
		close("cm");
		
		

						
		// WRITE RESULTS--
		run("Clear Results");
		if(File.exists(OutDir+File.separator+MyTitle_short+".xls"))
		{		
			//if exists add and modify
			open(OutDir+File.separator+MyTitle_short+".xls");
			IJ.renameResults("Results");
		}
		i=nResults;
		setResult("[Label]", i, "C"+(i+1));		
		setResult("Area CM (micra²)",i,a);
		setResult("Equivalent diameter (micra)",i,d);
		setResult("Area nucleus (micra²)",i,An);
		saveAs("Results", OutDir+File.separator+MyTitle_short+".xls");
			
		
		q=getBoolean("Do you want to add another cardiomyocyte?");
		setTool("zoom");
	}
	
	
	selectWindow(MyTitle);
	roiManager("Show All with labels");
	roiManager("Set Color", "red");
	roiManager("Set Line Width", 1);
	run("Flatten");
	saveAs("Jpeg", OutDir+MyTitle_short+"_analyzed.jpg");
	
	selectWindow(MyTitle);
	close();
	
	showMessage("Done!");

}




