function macroInfo(){
	
// * Quantification of 3D IF stack   
// * Target User: General
// *  

	scripttitle= "IF Quantification of Nucleus 2D Morphology and Orentation Descriptors in ZStacks";
	version= "1.01";
	date= "2023";
	
// *  Tests Images:

	imageAdquisition="Multiphoton : ";
	imageType="IF 3D Stack multiple channels. DAPI 8 bit";  
	voxelSize="Voxel size:  unknown um xy";
	format="Format: original czi";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button 
 
 	parameter1="Select DAPI channel:"; 
 	parameter2="Select Cell cito channel"; 
 	//parameter3="Nucleus Threshold";
 	 	 
 //  2 Action tools:
	 buttom1="Im: Single File processing";
//	 buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

 //  STEPS
	 step1="Select Single file to analyze";
	 step2="Select slice position";
	 step3="Draw Reference fiber orientation";
	 	 
//  OUTPUT

// Analyzed Images with ROIs

	excel="Results of selected Zslice and 2D Projection of whole 3D ZStack . ";
	feature1="Image Label"; 
	feature2="# Cell"; 
	feature3="Nuclei surface area (microns^2)";
	feature4="2D Aspect Ratio (AR)";
	feature5="2D Roundness";
	feature6="2D Circularity";
	feature7="2D Feret Diameter";
	feature7="2D Reference Angle: Degrees measured from Horizontal axis";
	feature8="2D Relative Nuclei Angle";
	
/*  	  
 *  version: 1.01 
 *  Author: Tomas Muñoz  
 *  Commented by: Tomas Muñoz 2023 
 *  Date : 2023
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
	    +"<p><font size=3  i>PARAMETERS:</i></p>"
	    +"<ul id=list-style-3><font size=2  i>"
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li></ul>"
	    +"<p><font size=3  i>STEPS:</i></p>"
	    +"<ul id=list-style-3><font size=2  i>"
	    +"<li>"+step1+"</li>"
	    +"<li>"+step2+"</li>"
	    +"<li>"+step3+"</li></ul>"
	    +"<p><font size=3 i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3 i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li>"
	    +"<li>"+feature5+"</li><li>"+feature6+"</li><li>"+feature7+"</li><li>"+feature8+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}
                            


setOption("DebugMode", true);
setOption("ExpandableArrays", true);
setOption("WaitForCompletion",true);
Table.showRowIndexes(false);

var cDAPI=3; 
var cNuclPr1=2;	

macro "IF3D_CellNucleusAlignment Action Tool 1 - Cf00T2d15IT6d10m"{
	
	close("*");
	roiManager("reset");
	run("Clear Results");
	close("Results");
	
	macroInfo();
	
	run("Fresh Start");
	
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	
	run("Bio-Formats", "open=["+name+"] autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT");
		 	
 	Dialog.create("Channels");
	Dialog.addMessage("Choose channel order")	
	Dialog.addNumber("DAPI", cDAPI);
	Dialog.addNumber("Fibers", cNuclPr1);
	Dialog.show();
	
	cDAPI= Dialog.getNumber();
	cNuclPr1= Dialog.getNumber();
	
	//setBatchMode(true);
	print(name);
	
	ifnucl2d("-","-",name,cDAPI,cNuclPr1);
	
}



function ifnucl2d(output,InDir,name,cDAPI,cNuclPr1)
{
	//cDAPI=3; 
	//cNuclPr1=2;
	
	setBatchMode(false);
	Stack.setDisplayMode("composite");
	run("Colors...", "foreground=black background=white selection=red");
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

	Stack.setDisplayMode("composite");
	getDimensions(width, height, channels, slices, frames);
	Stack.setSlice(floor(slices/2));
	Stack.setChannel(cDAPI);
	run("Blue");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(cNuclPr1);
	run("Enhance Contrast", "saturated=0.35");
	
	//REFERENCE FIBER ORENTATION
	roiManager("Reset");
	run("Clear Results");
	setTool("line");
	waitForUser("Draw a fiber and press OK when ready");
	getLocationAndSize(x, y, width, height);
	call("ij.gui.ImageWindow.setNextLocation", x, y);
	type = selectionType();
	while(type==-1){
		setTool("line");
		waitForUser("ERROR: no reference line drawn. Please draw fiber.");
		type = selectionType();
	}
	roiManager("Add");
	run("Create Mask");
	call("ij.gui.ImageWindow.setNextLocation", x, y);
	rename("referenceFiber");
	//selectWindow("QuantSlice_"+currentSlice);

	//Horizontal AXIS AS REFERENCE
	// Get fiber angle and place it in 1st or 2nd quadrant: 0-180
	selectWindow(MyTitle);
	roiManager("Select",0);
	refAng=getValue("Angle");

	if (refAng<0) {
		refAng = refAng+180;
	}
	showMessage("Reference fiber updated!: Angle :"+refAng);
	
	//IMAGES TO ANALAYZE ( 2D PROJECTION + MULTIPLE Z SLICES);
	
	images=newArray();
	
	//SUM OF SLICES PROJECTION 
	setBatchMode(true);
    selectWindow(MyTitle);
    call("ij.gui.ImageWindow.setNextLocation", x, y);
    run("Duplicate...", "duplicate title=stackDAPI channels="+cDAPI);
    run("Subtract Background...", "rolling=100 stack");
	run("Median...", "radius=1 stack");
    run("Z Project...", "projection=[Max Intensity]");
    rename("2D_PROJECTION");
    run("Subtract Background...", "rolling=100 stack");
    close("stackDAPI");
    images[0]="2D_PROJECTION";
    setBatchMode(false);
    selectWindow(MyTitle);
     
		
	//Z slices and Channel selection
	q=true;
	slices=newArray();
	nslicesAnalyze=0;
	//cDAPI=3;
	//call("ij.gui.ImageWindow.setNextLocation", x, y);
	while(q) {
		//SLICE TO ANALYZE
		selectWindow(MyTitle);
		waitForUser("Select the Z slice to Analyze");
		Stack.getPosition(channel, slice, frame);
		slices[nslicesAnalyze]=slice;
		run("Duplicate...", "title=ZSlice_"+slices[nslicesAnalyze]+" duplicate channels="+cDAPI+" slices="+slice);
		call("ij.gui.ImageWindow.setNextLocation", x, y);
		run("Subtract Background...", "rolling=100 stack");
		run("Median...", "radius=1 stack");
		q=getBoolean("Would you like to add another Z Slice?");
		nslicesAnalyze+=1;
		images[nslicesAnalyze]="ZSlice_"+slices[nslicesAnalyze-1];
		selectWindow(MyTitle);
	}

	//Array.print(images);
	
	/* SEGMENTATION WITH GUIDED WATERSHED .... wrong markers..

	//PREPROCESSING --> ORIGINAL IMAGES PRESENT SALT NOISE ALL OVER THE IMAGE, POOR HETERGENEUS SIGNAL... 
	
	run("Enhance Local Contrast (CLAHE)", "blocksize=150 histogram=200 maximum=2 mask=*None* fast_(less_accurate)");
	run("Duplicate...", "title=nucleus3DMask duplicate");
	//run("Threshold...");
	setAutoThreshold("Otsu dark no-reset stack");
	//setThreshold(35, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Otsu background=Dark");
	run("Analyze Particles...", "size=50-Infinity pixel show=Masks stack in_situ");

	//Morphological filters 			
	selectWindow("nucleus3DMask");
    run("Morphological Filters", "operation=Closing element=Disk radius=1");
    run("Morphological Filters", "operation=Opening element=Disk radius=1");
   //run("Morphological Filters", "operation=[White Top Hat] element=Disk radius=50");
    close("nucleus3DMask");
    close("nucleus3DMask-Closing");
    selectWindow("nucleus3DMask-Closing-Opening");
    rename("nucleus3DMask_morpho");
    
    run("Analyze Particles...", "size=500-Infinity pixel show=Masks stack in_situ");
    */
        
    //SEGMENTATION METHOD:  STARDIST 2D SEGMENTATION.
    roiManager("reset");
           
    close(MyTitle);
    	
	for (i = 0; i < lengthOf(images); i++) {
		
		im=images[i];
	
		starDist2D(im);
		
	}	
		
	close("referenceFiber");
   	
   	showMessage("Done!");
   	 	

	
	
}	

function starDist2D(im){
	call("ij.gui.ImageWindow.setNextLocation", x, y);
  	run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input':"+im+", 'modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'0.0', 'percentileTop':'100.0', 'probThresh':'0.479071', 'nmsThresh':'0.2', 'outputType':'Label Image', 'nTiles':'1', 'excludeBoundary':'2', 'roiPosition':'Automatic', 'verbose':'false', 'showCsbdeepProgress':'false', 'showProbAndDist':'false'], process=[false]");
	
	//COMPUTE FERET DIAMETERS LENGTHS AND ORENTATIONS. FROM LABALLED IMAGE
	selectWindow("Label Image");
	run("Label Size Filtering", "operation=Greater_Than size=1000");
	close("Label Image");
	run("Label image to ROIs", "rm=[RoiManager[visible=true]]");
	run("ROIs to Label image");
	close("Label-sizeFilt");
	selectWindow("ROIs2Label_Label-sizeFilt");
	
	run("Max. Feret Diameters", "label=[ROIs2Label_Label-sizeFilt] show image=[ROIs2Label_Label-sizeFilt]");
			
	IJ.renameResults("Results");
	nNucleus=nResults;
	print(nNucleus);
	selectWindow("Results");
	feretDiameter=Table.getColumn("Diameter");
	angleFeretDiameter=Table.getColumn("Orientation");
	
	//COMPUTE SHAPE DESCRIPTORS FROM ROI MANAGER
	selectWindow("ROIs2Label_Label-sizeFilt");
	run("Set Measurements...", "area shape redirect=None decimal=2");
	roiManager("Measure");
	
	area=Table.getColumn("Area");
	circ=Table.getColumn("Circ.");
	AR=Table.getColumn("AR");
	//Solid=Table.getColumn("Solidity");
	Round=Table.getColumn("Round");
	
	labels=Array.getSequence(nNucleus+1);
	labels=Array.slice(labels,1,nNucleus+1);
		
	//GET NUCLEI RELATIVE ANGLE
	nCells = nResults;
	cellAngRel = newArray(nCells);
	refAnglColumn = newArray(nCells);
	
	for (i=0; i<nCells; i++)
	{
		area[i]=area[i]*vxW*vxH;
		
		//1º and 2º quandrant0-180
		angleFeretDiameter[i]=180-angleFeretDiameter[i];
		refAnglColumn[i]=refAng;
		cellAngRel[i] = angleFeretDiameter[i]-refAng;
		
		if(abs(cellAngRel[i])>90){
			cellAngRel[i]=abs(cellAngRel[i])-180;
		}

	}
	
	/*
	print(refAng);
	Array.print(angleFeretDiameter);
	Array.print(cellAngRel);*/
		
	run("Clear Results");
	close("Results");
	
	Table.create("metrics");
	Table.setColumn("CellID", labels);
	Table.setColumn("Area", area);
	Table.setColumn("AR", AR);
	Table.setColumn("Circularity", circ);
	Table.setColumn("Round", Round);
	//Table.setColumn("Solidity", Solid);
	Table.setColumn("FeretDiameter",feretDiameter);
	//Table.setColumn("OrientationAngle",angleFeretDiameter);
	Table.setColumn("Ref_Angle",refAnglColumn);
	Table.setColumn("Relative_CellAngle",cellAngRel);
	IJ.renameResults("Results");

	//SAVE RESULTS
	run("Read and Write Excel", "file=["+output+File.separator+MyTitle+".xlsx] dataset_label=["+MyTitle+im+"_Morphology and Orientation]");
	close(im+"_Metrics");
	
	
	//SAVE LABELLED IMAGE
		
	selectWindow(im);
	roiManager("Show All with labels");
	selectWindow("ROIs2Label_Label-sizeFilt");
	run("Create Mask");
	run("Create Selection");
	selectWindow(im);
	run("Colors...", "selection=red");
	run("Restore Selection");
	run("Flatten");
	close(im);
	
	selectWindow("referenceFiber");
	run("Create Selection");
	
	selectWindow(im+"-1");
	run("Colors...", "selection=green");
	run("Restore Selection");
	run("Flatten");
	close(im+"-1");
	close("Mask");
	
	close("ROIs2Label_Label-sizeFilt");
	rename(MyTitle+im);
	saveAs("Jpeg", OutDir+File.separator+MyTitle+"_"+im+"_analyzed.jpg");	
		
			
}
	
	

	
	




