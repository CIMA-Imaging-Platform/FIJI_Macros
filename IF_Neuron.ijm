

function macroInfo(){
	
// " InmunoFlourescence Quantification of Rafe Structures whithin 2 Channels;
// * Target User: General
// *  

	scripttitle= " InmunoFlourescence Quantification of Rafe Structures whithin 2 Channels";
	version= "1.03";
	date= "X";
	

// *  Tests Images:

	imageAdquisition="Vectra Polaris: IF WSI.";
	imageType="8bit";  
	voxelSize="Voxel size:  unkown um xy";
	format="Format: qptiff or .jpg";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button 
 
 	  		
	parameter1="Introduce Threshold for Green Marker (8bit): Separate G(+) and G(-)"; 
	parameter2="Introduce Threshold for Red Marker (8bit): Separate R(+) and R(-)"; 
			 
//  2 Action tools:
	buttom1="Im: Single File processing";
	
//  OUTPUT

// Analyzed Images with ROIs

	
	excel="Results.xls";
	feature1="Image Label"; 	
	feature2="Bkg I G";
	feature3="Bkg I R";
	feature4="Rafe total I G";
	feature5="Rafe total I R";
	feature6="Rafe dorsal I G";
	feature7="Rafe dorsal I R";
	feature8="Rafe ventral I G";
	feature9="Rafe ventral I R";
	feature10="Lateral wing I G";
	feature11="Lateral wing I R";
	feature12="Rafe caudal I G";
	feature13="Rafe caudal I R";
		
	
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
	    +"<ol><font size=2  i><li>"+buttom1+"</li></ol>"
	    +"<p><font size=3  i>PARAMETERS: Right Click on Action tool  </i></p>"
	    +"<ul id=list-style-3><font size=2  i>"
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li>"
	    +"<li>"+feature5+"</li><li>"+feature6+"</li><li>"+feature7+"</li><li>"+feature8+"</li>"
	    +"<li>"+feature9+"</li><li>"+feature10+"</li><li>"+feature11+"</li><li>"+feature12+"</li><li>"+feature13+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

var thGreen=20, thRed=20;

macro "IF_Brain Action Tool - Ca3fT0d12BT9d12r"{	
	
	macroInfo();
	
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	run("Colors...", "foreground=black background=white selection=yellow");
	run("Set Measurements...", "area redirect=None decimal=2");
	
	selectWindow(MyTitle);	
	rename("orig");
	
	Stack.setDisplayMode("composite");
	Stack.setChannel(1);
	
	
	// MANUAL SELECTION OF ROIs
	
	setTool("freehand");
	flag_rafeTotal=false;
	flag_rafeDorsal=false;
	flag_rafeVentral=false;
	flag_lateralWing1=false;
	flag_lateralWing2=false;
	flag_rafeCaudal=false;
	
	//--1) Rafe total
	run("Select None");
	waitForUser("Draw a contour for 'Rafe total' and press OK");
	type = selectionType();
	  if (type==-1) {	//if there is no selection, select one pixel
	  	      makeRectangle(1,1,1,1);
	  	      flag_rafeTotal=true;
	  }
	run("Add to Manager");	// ROI0 --> Rafe total
	
	//--2) Rafe dorsal
	run("Select None");
	waitForUser("Draw a contour for 'Rafe dorsal' and press OK");
	type = selectionType();
	  if (type==-1) {	//if there is no selection, select one pixel
	  	      makeRectangle(1,1,1,1);
	  	      flag_rafeDorsal=true;
	  }
	run("Add to Manager");	// ROI1 --> Rafe dorsal
	
	//--3) Rafe ventral
	run("Select None");
	waitForUser("Draw a contour for 'Rafe ventral' and press OK");
	type = selectionType();
	  if (type==-1) {	//if there is no selection, select one pixel
	  	      makeRectangle(1,1,1,1);
	  	      flag_rafeVentral=true;
	  }
	run("Add to Manager");	// ROI2 --> Rafe ventral
	
	//--4) Lateral wing (there are two, join together in a single region
	run("Select None");
	waitForUser("Draw a contour for 'Lateral wing 1' and press OK");
	type = selectionType();
	  if (type==-1) {	//if there is no selection, select one pixel
	  	      makeRectangle(1,1,1,1);
	  	      flag_lateralWing1=true;
	  }
	run("Add to Manager");	// ROI3 --> Lateral wing 1
	run("Select None");
	waitForUser("Draw a contour for 'Lateral wing 2' and press OK");
	type = selectionType();
	  if (type==-1) {	//if there is no selection, select one pixel
	  	      makeRectangle(1,1,1,1);
	  	      flag_lateralWing2=true;
	  }
	run("Add to Manager");	// ROI4 --> Lateral wing 2
	roiManager("deselect");
	roiManager("Select", newArray(3,4));
	roiManager("Combine");
	roiManager("Add");		// ROI3 --> Lateral wing
	roiManager("deselect");
	roiManager("Select", newArray(3,4));
	roiManager("delete");
	flag_lateralWing = flag_lateralWing1 & flag_lateralWing2;
	
	
	//--5) Rafe caudal
	run("Select None");
	waitForUser("Draw a contour for 'Rafe caudal' and press OK");
	type = selectionType();
	  if (type==-1) {	//if there is no selection, select one pixel
	  	      makeRectangle(1,1,1,1);
	  	      flag_rafeCaudal=true;
	  }
	run("Add to Manager");	// ROI4 --> Rafe caudal
	
	
	//--MANUAL SELECTION OF BACKGROUND REGION
	
	//--Basal region for background measurement
	run("Select None");
	waitForUser("Draw a background region and press OK");
	run("Add to Manager");	// ROI5 --> Background region
	
	//--Measure background
	
	run("Clear Results");
	run("Set Measurements...", "area mean redirect=None decimal=2");
	selectWindow("orig");
	Stack.setChannel(1);	//green
	wait(100);
	resetMinAndMax();
	wait(100);
	roiManager("Select", 5);
	wait(100);
	roiManager("Measure");
	Stack.setChannel(2);	//red
	wait(100);
	resetMinAndMax();
	wait(100);
	roiManager("Measure");
	wait(100);
	IbkgGreen = getResult("Mean", 0);
	IbkgRed = getResult("Mean", 1);
	
	
	//--PROCESS GREEN
	
	selectWindow("orig");
	run("Select None");
	run("Duplicate...", "title=green duplicate channels=1");
	run("Subtract...", "value="+IbkgGreen);
	setBatchMode(true);
	run("Duplicate...", "title=greenMask");
	  //thGreen=20;
	setThreshold(thGreen, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=2");
	run("Analyze Particles...", "size=40-Infinity pixel show=Masks in_situ");
	run("Create Selection");
	roiManager("Add");	// ROI6 --> All green
	wait(100);
	close();
	setBatchMode(false);
	
	//--PROCESS RED
	
	selectWindow("orig");
	run("Select None");
	run("Duplicate...", "title=red duplicate channels=2");
	run("Subtract...", "value="+IbkgRed);
	setBatchMode(true);
	run("Duplicate...", "title=redMask");
	  //thRed=20;
	setThreshold(thRed, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=2");
	run("Analyze Particles...", "size=40-Infinity pixel show=Masks in_situ");
	run("Create Selection");
	roiManager("Add");	// ROI7 --> All red
	wait(100);
	close();
	setBatchMode(false);
	
	//--MEASUREMENTS
	
	selectWindow("orig");
	run("Select None");
	
	//--GREEN SIGNAL
	
	selectWindow("green");
	run("Clear Results");
	//--1) Rafe total
	roiManager("deselect");
	roiManager("Select", newArray(0,6));
	roiManager("AND");
	run("Measure");
	//--2) Rafe dorsal
	roiManager("deselect");
	roiManager("Select", newArray(1,6));
	roiManager("AND");
	run("Measure");
	//--3) Rafe ventral
	roiManager("deselect");
	roiManager("Select", newArray(2,6));
	roiManager("AND");
	run("Measure");
	//--4) Lateral wing
	roiManager("deselect");
	roiManager("Select", newArray(3,6));
	roiManager("AND");
	run("Measure");
	//--5) Rafe caudal
	roiManager("deselect");
	roiManager("Select", newArray(4,6));
	roiManager("AND");
	run("Measure");
	//--Measures
	I1green = getResult("Mean", 0);
	I2green = getResult("Mean", 1);
	I3green = getResult("Mean", 2);
	I4green = getResult("Mean", 3);
	I5green = getResult("Mean", 4);
	
	//--RED SIGNAL
	
	selectWindow("red");
	run("Clear Results");
	//--1) Rafe total
	roiManager("deselect");
	roiManager("Select", newArray(0,7));
	roiManager("AND");
	run("Measure");
	//--2) Rafe dorsal
	roiManager("deselect");
	roiManager("Select", newArray(1,7));
	roiManager("AND");
	run("Measure");
	//--3) Rafe ventral
	roiManager("deselect");
	roiManager("Select", newArray(2,7));
	roiManager("AND");
	run("Measure");
	//--4) Lateral wing
	roiManager("deselect");
	roiManager("Select", newArray(3,7));
	roiManager("AND");
	run("Measure");
	//--5) Rafe caudal
	roiManager("deselect");
	roiManager("Select", newArray(4,7));
	roiManager("AND");
	run("Measure");
	//--Measures
	I1red = getResult("Mean", 0);
	I2red = getResult("Mean", 1);
	I3red = getResult("Mean", 2);
	I4red = getResult("Mean", 3);
	I5red = getResult("Mean", 4);
	
	
	//--Manage missing regions
	if(flag_rafeTotal) {
		I1green = NaN;
		I1red = NaN;
	}
	if(flag_rafeDorsal) {
		I2green = NaN;
		I2red = NaN;
	}
	if(flag_rafeVentral) {
		I3green = NaN;
		I3red = NaN;
	}
	if(flag_lateralWing) {
		I4green = NaN;
		I4red = NaN;
	}
	if(flag_rafeCaudal) {
		I5green = NaN;
		I5red = NaN;
	}
	
	
	//--Write results:
	run("Clear Results");
	if(File.exists(output+File.separator+"Results.xls"))
	{	
		//if exists add and modify
		open(output+File.separator+"Results.xls");
		IJ.renameResults("Results");	
	}
	i=nResults;
	setResult("Label", i, MyTitle); 	
	setResult("Bkg G", i, IbkgGreen);
	setResult("Bkg R", i, IbkgRed);
	setResult("Rafe total G", i, I1green);
	setResult("Rafe total R", i, I1red);
	setResult("Rafe dorsal G", i, I2green);
	setResult("Rafe dorsal R", i, I2red);
	setResult("Rafe ventral G", i, I3green);
	setResult("Rafe ventral R", i, I3red);
	setResult("Lateral wing G", i, I4green);
	setResult("Lateral wing R", i, I4red);
	setResult("Rafe caudal G", i, I5green);
	setResult("Rafe caudal R", i, I5red);
	saveAs("Results", output+File.separator+"Results.xls");
	
		
	// DRAW--
	
	selectWindow("orig");
	close();
	run("Merge Channels...", "c1=red c2=green create");
	rename("mergeComposite");
	run("RGB Color");
	rename("merge");
	selectWindow("mergeComposite");
	close();
	
	//--Combined ROIs
	roiManager("deselect");
	roiManager("Select", newArray(0,1,2,3,4));
	roiManager("Combine");
	roiManager("Add");	// ROI8 --> Combined ROIs
	roiManager("deselect");
	roiManager("Select", newArray(6,8));
	roiManager("AND");
	roiManager("Add");	// ROI9 --> Green in ROIs
	roiManager("deselect");
	roiManager("Select", newArray(7,8));
	roiManager("AND");
	roiManager("Add");	// ROI10 --> Red in ROIs
	
	selectWindow("merge");
	roiManager("Select", 8);
	roiManager("Set Color", "magenta");
	roiManager("Set Line Width", 3);
	run("Flatten");
	roiManager("Show None");
	roiManager("Select", 9);
	roiManager("Set Color", "green");
	roiManager("Set Line Width", 1);
	run("Flatten");
	roiManager("Show None");
	roiManager("Select", 10);
	roiManager("Set Color", "red");
	roiManager("Set Line Width", 1);
	run("Flatten");
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	wait(500);
	
	
	selectWindow("merge");
	close();
	selectWindow("merge-1");
	close();
	selectWindow("merge-2");
	close();
	
	setTool("zoom");
	showMessage("Done!");
	
}
	
	
macro "IF_Brain Action Tool Options" {
		Dialog.create("Parameters");
		
		Dialog.addMessage("Choose parameters")	
		Dialog.addNumber("Green threshold", thGreen);
		Dialog.addNumber("Red threshold", thRed);
		Dialog.show();	
		
		thGreen= Dialog.getNumber();
		thRed= Dialog.getNumber();	
}
