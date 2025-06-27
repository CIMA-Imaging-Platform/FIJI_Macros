/*
 * 3D COLOCALIZACION OF NEURO BIOMARKERS
 * Target User: Leyre Basurco y Leyre Ayerra
 *  
 *  Images: 
 *    - Confocal 3D Z stack Image. 2 Channel 
 *	  - 8 bit
 *	  - Voxel size: 0.3120x0.3120x0.53 micron^3
 *	  - Format .czi   
 *  
 *  GUI Requierments:
 *		// manual selection of analysis regions
 *		// automatic Protein and Neuron signal detection in 3D
 *		// Neuron-Protein 3D colocalization quantification
 *		  
 *	Action Tools:	  
 *	 Im - Single file processing
 *	 Dir - Batch mode
 *		  
 *  Important Parameters
 *    - Channel order cProtein=2, cNeuron=1, 
 *    - Thresholds: thProtein=30, thNeuron=30, 
 *    - Particle Size filter: minSizeProtein=20, minSizeNeuron=20;		
 *    
 *  OUTPUT: 
 *  setResult("Protein-marker volume ("+unit+"^3)", i, Vg);
	setResult("Neuron-marker volume ("+unit+"^3)", i, Vr);
	setResult("Protein-Neuron coloc volume ("+unit+"^3)", i, Vc); 
	
	Colocalization Image 
   
 *  Author: Mikel Ariz 
 *  Commented by: Tomás Muñoz
 *  Date :changelog July 2021
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


function infoMacro(){
	scripttitle= "3D COLOCALIZACION OF NEURON FIBERs BIOMARKERS  ";
	version= "1.03";
	date= "July 2021";
	
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
	    +"<ul><font size=2  i><li>Confocal 3D Z stack Image. 2 Channel</li><li> 8 bit</li><li>Voxel size: 0.3120x0.3120x0.53 micron^3</li><li>Format .czi </li></ul>"
	    +"<p><font size=3 i>Action tools (Buttons)</i></p>"
	    +"<ul><font size=2  i><li> Im:  Single file Quantification</li>"
	    +"<font size=2  i><li> Dir: Batch mode. All images within the selected folder are quantified</li></ul>"
	    +"<p><font size=3  i>Steps for the User</i></p><ol><li>Press Im: to test behaviour on a set of images </li><li>Introduce Parameters: testing</li><li>Once tested and decided optimal parameter with Im --> Press Dir for Bath Mode</li></ol>"
	    +"<p><font size=3  i>PARAMETERS:</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>Channel order: Choose Channel order; by default cProtein=2, cNeuron=1.</li><li> Markers Thresholds: Intensity threshold to segment ROI. Higher values means more restrictive. Less Area is segmented. by default thProtein=30, thNeuron=30</li><li>Particle Size filter (pixels): by default minSizeProtein=20, minSizeNeuron=20</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=2  i>AnalyzedImages_Coloc folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=2  i>Excel Colocalization_Results.xls</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>Protein-marker volume um^3</li><li>Neuron-marker volume um^3</li><li>Protein-Neuron coloc volume um^3</li><li>Ratio of coloc wrt total volume (%): Normalize Metric taking into account total amount of both markers Ratio = Colocalized Volume  / (Volume marker 1 + Volume marker 2)</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
	}




var cProtein=2, cNeuron=1, thProtein=30, thNeuron=30, minSizeProtein=20, minSizeNeuron=20;		

macro "QIF Action Tool 1 - Cf00T2d15IT6d10m"{
	
	infoMacro();
	
	run("Close All");
	
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	print("Processing "+name);
	
	Dialog.create("Parameters for the analysis");
	// Channels:
	Dialog.addMessage("Choose channel numbers")	
	Dialog.addNumber("Protein marker", cProtein);	
	Dialog.addNumber("Neuron marker", cNeuron);
	// Segmentation:
	Dialog.addMessage("Choose analysis parameters")		
	Dialog.addNumber("Protein threshold", thProtein);	
	Dialog.addNumber("Neuron threshold", thNeuron);
	Dialog.addNumber("Min Protein particle size (px)", minSizeProtein);	
	Dialog.addNumber("Min Neuron particle size (px)", minSizeNeuron);	
	Dialog.show();	
	cProtein= Dialog.getNumber();
	cNeuron= Dialog.getNumber();
	thProtein= Dialog.getNumber();
	thNeuron= Dialog.getNumber();
	minSizeProtein= Dialog.getNumber();
	minSizeNeuron= Dialog.getNumber();	
	
	//setBatchMode(true);
	qif("-","-",name,cProtein,cNeuron,thProtein,thNeuron,minSizeProtein,minSizeNeuron);
	setBatchMode(false);
	showMessage("Quantification finished!");

}

macro "QIF Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	infoMacro();
	
	run("Close All");
	
	InDir=getDirectory("Choose Tiles' directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("Parameters for the analysis");
	// Channels:
	Dialog.addMessage("Choose channel numbers")	
	Dialog.addNumber("Protein marker", cProtein);	
	Dialog.addNumber("Neuron marker", cNeuron);
	// Segmentation:
	Dialog.addMessage("Choose analysis parameters")		
	Dialog.addNumber("Protein threshold", thProtein);	
	Dialog.addNumber("Neuron threshold", thNeuron);
	Dialog.addNumber("Min Protein particle size (px)", minSizeProtein);	
	Dialog.addNumber("Min Neuron particle size (px)", minSizeNeuron);	
	Dialog.show();	
	cProtein= Dialog.getNumber();
	cNeuron= Dialog.getNumber();
	thProtein= Dialog.getNumber();
	thNeuron= Dialog.getNumber();
	minSizeProtein= Dialog.getNumber();
	minSizeNeuron= Dialog.getNumber();	
	
	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"czi")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print("Processing "+name);
			//setBatchMode(true);
			qif(InDir,InDir,list[j],cProtein,cNeuron,thProtein,thNeuron,minSizeProtein,minSizeNeuron);
			setBatchMode(false);
			}
	}
	
	showMessage("Quantification finished!");

}


function qif(output,InDir,name,cProtein,cNeuron,thProtein,thNeuron,minSizeProtein,minSizeNeuron)
{
	
	run("Close All");
	
	if (InDir=="-") {
		run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
		}
	else {
		run("Bio-Formats Importer", "open=["+InDir+name+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
		}	
	
	
	Stack.setDisplayMode("composite");
	
	run("Colors...", "foreground=black background=white selection=yellow");
	Stack.getDimensions(width, height, channels, slices, frames);
	
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	OutDir = output+File.separator+"AnalyzedImages_Coloc/";
	File.makeDirectory(OutDir);
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	getVoxelSize(rx, ry, rz, unit);
	
	selectWindow(MyTitle);
	rename("orig");
	
	
	// DETECT Protein--
	
	selectWindow("orig");
	run("Duplicate...", "title=Protein duplicate channels="+cProtein);
	run("Subtract Background...", "rolling=20 stack");	

	//--Steerable filter
	Stack.getDimensions(width, height, channels, slices, frames);
	getVoxelSize(vx, vy, vz, unit);
	print("Voxel size: "+vx+"x"+vy+"x"+vz+" "+unit); 
	
	run("Tubeness", "sigma="+vx+" use");
	selectWindow("Protein");
	close();
	selectWindow("tubeness of Protein");
	rename("Protein");
	
	//--Remove now first and last slices:
	setSlice(slices);
	run("Delete Slice");
	setSlice(1);
	run("Delete Slice");
	run("Green");
	run("Enhance Contrast", "saturated=0.35");
	Stack.getDimensions(width, height, channels, slices, frames);
	
	run("Duplicate...", "title=ProteinMask duplicate range=1-"+slices);
	run("8-bit");
	setAutoThreshold("Huang dark");
	setThreshold(thProtein, 255);
	//setThreshold(30, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark");
	run("Median...", "radius=1 stack");
	//run("Analyze Particles...", "size=10-Infinity pixel show=Masks in_situ stack");
	run("Analyze Particles...", "size="+minSizeProtein+"-Infinity pixel show=Masks in_situ stack");
	
	// Save Protein signal ROIs:
	roiManager("Reset");
	flagProtein=newArray(slices);
	Array.fill(flagProtein, 0); 
	for (i=1;i<(slices+1);i++){
		setSlice(i);
		run("Create Selection");
		// Check if we have a selection for current slice, and draw a pixel if not
		type = selectionType();
		  if (type==-1)	{
			makeRectangle(2,2,1,1);	
			flagProtein[i-1]=1;
		}
		run("Add to Manager");
	}
	roiManager("Save", OutDir+"ROI_"+MyTitle_short+"_Protein.zip");
	selectWindow("ProteinMask");
	//close();
	// Create a 2D mask projecting all the 3D selections:
	roiManager("Deselect");
	roiManager("Combine");
	run("Create Mask");
	rename("ProteinProjMask");
	
	
	
	// DETECT Neuron--
	selectWindow("orig");
	run("Duplicate...", "title=Neuron duplicate channels="+cNeuron);
	run("Subtract Background...", "rolling=20 stack");	
	//--Steerable filter
	Stack.getDimensions(width, height, channels, slices, frames);
	getVoxelSize(vx, vy, vz, unit);
	print("Voxel size: "+vx+"x"+vy+"x"+vz+" "+unit);
	
	run("Tubeness", "sigma="+vx+" use");
	selectWindow("Neuron");
	close();
	selectWindow("tubeness of Neuron");
	rename("Neuron");
	 
	
	//--Remove now first and last slices:
	setSlice(slices);
	run("Delete Slice");
	setSlice(1);
	run("Delete Slice");
	run("Red");
	run("Enhance Contrast", "saturated=0.35");
	Stack.getDimensions(width, height, channels, slices, frames);
	
	run("Duplicate...", "title=NeuronMask duplicate range=1-"+slices);
	run("8-bit");
	setAutoThreshold("Huang dark");
	setThreshold(thNeuron, 255);
	//setThreshold(50, 255);
	run("Convert to Mask", "method=Default background=Dark");
	run("Median...", "radius=1 stack");
	//run("Analyze Particles...", "size=20-Infinity pixel show=Masks in_situ stack");
	run("Analyze Particles...", "size="+minSizeNeuron+"-Infinity pixel show=Masks in_situ stack");
	
	// Save Neuron signal ROIs:
	roiManager("Reset");
	flagNeuron=newArray(slices);
	Array.fill(flagNeuron, 0); 
	for (i=1;i<(slices+1);i++){
		setSlice(i);
		run("Create Selection");
		// Check if we have a selection for current slice, and draw a pixel if not
		type = selectionType();
		  if (type==-1)	{
			makeRectangle(3,3,1,1);	
			flagNeuron[i-1]=1;
		}
		run("Add to Manager");
	}
	roiManager("Save", OutDir+"ROI_"+MyTitle_short+"_Neuron.zip");
	selectWindow("NeuronMask");
	//close();
	// Create a 2D mask projecting all the 3D selections:
	roiManager("Deselect");
	roiManager("Combine");
	run("Create Mask");
	rename("NeuronProjMask");
	
	
	// Protein-Neuron COLOCALIZATION
	selectWindow("orig");
	roiManager("Reset");
	roiManager("Open", OutDir+"ROI_"+MyTitle_short+"_Protein.zip");
	roiManager("Open", OutDir+"ROI_"+MyTitle_short+"_Neuron.zip");
	flagColoc=newArray(slices);
	Array.fill(flagColoc, 0); 
	for (i=1;i<(slices+1);i++){
		setSlice(i);
		roiManager("Deselect");
		roiManager("Select", 0);
		roiManager("select", newArray(0,slices-i+1));	
		roiManager("AND");
		// Check if we have a selection, and draw a pixel if not
		type = selectionType();
		  if (type==-1)	{
			makeRectangle(4,4,1,1);	
			flagColoc[i-1]=1;
		}
		roiManager("Add");	
		roiManager("Deselect");
		roiManager("Select", 0);
		roiManager("select", newArray(0,slices-i+1));
		roiManager("Delete");
	}
	roiManager("Save", OutDir+"ROI_"+MyTitle_short+"_ProteinNeuronColoc.zip");
	// Create a 2D mask projecting all the 3D selections:
	roiManager("Deselect");
	roiManager("Combine");
	run("Create Mask");
	rename("colocProjMask");
	
	
	// MEASURE--
	run("Clear Results");
	run("Set Measurements...", "area mean Neuronirect=None decimal=2");
	
	// load ROIs
	roiManager("Reset");
	roiManager("Open", OutDir+"ROI_"+MyTitle_short+"_Protein.zip");
	roiManager("Open", OutDir+"ROI_"+MyTitle_short+"_Neuron.zip");
	roiManager("Open", OutDir+"ROI_"+MyTitle_short+"_ProteinNeuronColoc.zip");
	// initialize variables
	Ag=newArray(slices);
	//Ig=newArray(slices);
	Ar=newArray(slices);
	//Ir=newArray(slices);
	Ac=newArray(slices);
	//Icg=newArray(slices);
	//Icr=newArray(slices);
	Agt=0;
	Art=0;
	Act=0;
	// loop over slices
	for (i=0;i<slices;i++){
		run("Clear Results");
		// Measure Protein
		selectWindow("Protein");
		roiManager("Select", i);
		roiManager("Measure");
		Ag[i]=getResult("Area",0);
		//Ig[i]=getResult("Mean",0);
		if (flagProtein[i]==1) {
			Ag[i]=0;
			//Ig[i]=0;
		}
		Agt=Agt+Ag[i];
		// Measure Neuron
		selectWindow("Neuron");
		roiManager("Select", i+slices);
		roiManager("Measure");
		Ar[i]=getResult("Area",1);
		//Ir[i]=getResult("Mean",1);
		if (flagNeuron[i]==1) {
			Ar[i]=0;
			//Ir[i]=0;
		}
		Art=Art+Ar[i];
		// Measure colocalization
		selectWindow("Protein");
		roiManager("Select", i+2*slices);
		roiManager("Measure");
		Ac[i]=getResult("Area",2);
		//Icg[i]=getResult("Mean",2);
		roiManager("Deselect");
		selectWindow("Neuron");
		roiManager("Select", i+2*slices);
		roiManager("Measure");
		//Icr[i]=getResult("Mean",3);
		if (flagColoc[i]==1) {
			Ac[i]=0;
			//Icg[i]=0;
			//Icr[i]=0;
		}
		Act=Act+Ac[i];
	}
	
	// total Protein signal volume
	Vg=Agt*rz;
	// total Neuron signal volume
	Vr=Art*rz;
	// total Protein-Neuron colocalization volume
	Vc=Act*rz;
	
	/*// average Protein and Neuron intensities in colocalization volume
	IcgAvg = 0;
	IcrAvg = 0;
	for (i=0;i<slices;i++){
		IcgAvg = IcgAvg + Icg[i]*Ac[i]/Act;
		IcrAvg = IcrAvg + Icr[i]*Ac[i]/Act;
	}*/
	
	// ratio of colocalization
	rCol = Vc/(Vg+Vr)*100;
	
	// Write results:
	run("Clear Results");
	if(File.exists(output+File.separator+"Colocalization_Results.xls"))
	{
		//if exists add and modify
		open(output+File.separator+"Colocalization_Results.xls");
		IJ.renameResults("Results");
	}
	i=nResults;
	setResult("Label", i, MyTitle); 
	setResult("Protein-marker volume ("+unit+"^3)", i, Vg);
	setResult("Neuron-marker volume ("+unit+"^3)", i, Vr);
	setResult("Protein-Neuron coloc volume ("+unit+"^3)", i, Vc); 
	setResult("Ratio of coloc wrt total volume (%)", i, rCol); 
	//setResult("Avg Protein intensity in coloc volume", i, IcgAvg);
	//setResult("Avg Neuron intensity in coloc volume", i, IcrAvg);				
	saveAs("Results", output+File.separator+"Colocalization_Results.xls");
	
	
	selectWindow("orig");
	run("RGB Color", "slices keep");
	rename("temp");
	wait(100);
	run("Z Project...", "projection=[Average Intensity]");
	rename("imageToSave");
	//run("Enhance Contrast", "saturated=0.35");
	selectWindow("temp");
	close();
	
	// Save 2D projection image of detected things:
	selectWindow("imageToSave");
	roiManager("Reset");
	selectWindow("ProteinProjMask");
	run("Create Selection");
	run("Add to Manager");
	close();
	selectWindow("NeuronProjMask");
	run("Create Selection");
	run("Add to Manager");
	close();
	selectWindow("colocProjMask");
	run("Create Selection");
	run("Add to Manager");
	close();
	selectWindow("imageToSave");
	roiManager("Select", 0);
	roiManager("Set Color", "Green");
	roiManager("Set Line Width", 1);
	run("Flatten");
	roiManager("Show None");
	roiManager("Select", 1);
	roiManager("Set Color", "Green");
	roiManager("Set Line Width", 1);
	run("Flatten");
	roiManager("Show None");
	roiManager("Select", 2);
	roiManager("Set Color", "yellow");
	roiManager("Set Line Width", 1);
	run("Flatten");
	wait(500);
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	rename(MyTitle_short+"_analyzed.jpg");
	wait(500);
	if (InDir!="-") {
	close(); }
	
	selectWindow("Protein");
	close();
	selectWindow("ProteinMask");
	close();
	selectWindow("Neuron");
	close();
	selectWindow("NeuronMask");
	close();
	selectWindow("imageToSave");
	close();
	selectWindow("imageToSave-1");
	close();
	selectWindow("orig");
	close();
	
	//Clear unused memory
	wait(500);
	run("Collect Garbage");


}




