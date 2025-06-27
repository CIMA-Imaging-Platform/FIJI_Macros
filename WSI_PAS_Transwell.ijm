function macroInfo(){
	
// * Quantification of Brown WSI Images Area  
// * Target User: General
// *  

	scripttitle= "Quantification of PAS Stained Cells in Transwell";
	version= "1.03";
	date= "2025";
	

// *  Tests Images:

	imageAdquisition="Scanner: BrightField Images.";
	imageType="RGB";  
	voxelSize="Voxel size:  0.502 um xy";
	format="Format: Uncompressed /.jpg";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button 
	//parameter1="Resolution (micra pixel ratio) = 0.502 micras/pixel xy"; 
	//parameter1="Tissue Threshold (8bit) = Separate Tissue from Background";
	 parameter1="PAS Threshold (8bit) = Separate Cells from Tissue";
	 parameter2="Min Cell Size (pixels)";
	 parameter3="Automatic parameter Optimization";
	 
 //  2 Action tools:
	 buttom1="Im: Single File processing";
	 buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs

	excel="QuantificationResults_WSI_TransWellCells.xls";
	feature1="Image Label";
	feature2="Tissue Area (micra²)";
	feature3="Cells area (micra²)";
	feature4="Ratio Area Cells stained/Area Tissue(%)"

/*  	  
 *  version: 1.01 
 *  Commented by: Tomas Muñoz 2025 
 *  Date : 2025
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
	    +"<li>"+parameter3+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}


var thTissue=235, thCells=85, minCellSize=400, auto=false;	

macro "TranswellCells Action Tool 1 - Cf00T2d15IT6d10m"{
	
	close("*");
	
	//just one file
	name=File.openDialog("Select File");
	//print(name);

	open(name);
	
	macroInfo();
	
	Dialog.create("PARAMETERS FOR THE ANALYSIS");
	//Dialog.addSlider("Threshold for Tissue Segmentation  ", 0, 255, thTissue); 
	Dialog.addSlider("Threshold for Possitive PAS Segmentation  ", 0, 255, thCells); 
	Dialog.addNumber("Min Cell Size (pixels)", minCellSize);
	Dialog.addCheckbox("Automatic --> Optimize Parameters", auto);
	Dialog.show();	
	
	//thTissue= Dialog.getNumber();
	thCells= Dialog.getNumber();
	minCellSize= Dialog.getNumber();
	auto=Dialog.getCheckbox();
	
	close("*");
	
	//setBatchMode(true);
	print(name);
	transwellcellsPAS("-","-",name,thTissue,thCells,minCellSize,auto);
	setBatchMode(false);
	showMessage("Done!");

		}
macro "TranswellCells Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	close("*");
	
	InDir=getDirectory("Choose a Directory");
	list=getFileList(InDir);
	L=lengthOf(list);
	
	macroInfo();
		
	Dialog.create("PARAMETERS FOR THE ANALYSIS");
	//Dialog.addSlider("Threshold for Tissue Segmentation  ", 0, 255, thTissue); 
	Dialog.addSlider("Threshold for Possitive PAS Segmentation  ", 0, 255, thCells); 
	Dialog.addNumber("Min Cell Size (pixels)", minCellSize);
	Dialog.addCheckbox("Automatic --> Optimize Parameters", auto);
	Dialog.show();	
	
	//thTissue= Dialog.getNumber();
	thCells= Dialog.getNumber();
	minCellSize= Dialog.getNumber();
	auto=Dialog.getCheckbox();
	
	auto=false;

	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"tif")||endsWith(list[j],"czi")||endsWith(list[j],"jpg")){
				//analyze
				//d=InDir+list[j]t;
				name=list[j];
				print(name);
				//setBatchMode(true);
				transwellcellsPAS(InDir,InDir,list[j],thTissue,thCells,minCellSize,auto);
				setBatchMode(false);
		}
	}
		showMessage("Done!");
}


function transwellcellsPAS(output,InDir,name,thTissue,thCells,minCellSize,auto)
{
		
	run("Close All");
	
	if (InDir=="-") {
		if(endsWith(name,"czi")) {
			run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
		} else {
			open(name);
		}		
	} else {
		
		if(endsWith(name,"czi")) {
			run("Bio-Formats Importer", "open=["+InDir+name+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
		
		} else {
			open(InDir+name); 
		}
	}	
			
	
	/*	
	thTissue=235;
	thCells=80;
	minCellSize=140;	
	*/
	
	a=getImageInfo();
	//print(a);
	
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	run("Colors...", "foreground=white background=black selection=green");
	getDimensions(width, height, channels, slices, frames);
	setVoxelSize(0.502, 0.502, 1, "um");
	
	if (channels >1 ){
		Stack.setDisplayMode("composite");
	}

	
	// Create RGB image to work with:
	run("RGB Color");
	rename("orig");
	
	setBatchMode(true);
	
	//PREPROCESSING
	print("Preprocessig..");
	run("RGB to Luminance");
	rename("lum");
	run("Median...", "radius=2");
	run("Select All");
	run("Clear Results");
	mode=getValue("Mode");
	run("Add...", "value="+255-mode);
	run("Clear Results");
	
	
	if (mode>220){
		print("Input Image --> Whole Slide");
		wsi=true;
	}else{
		print("Input Image --> Tile ");
		wsi=false;
	}
	
	//SEGMENTATION
	print("Segmenting Tissue and PAS Positive Regions..");
	//auto=false;
	if (auto){

		optTh=kmeanSearchParam("lum",4);
		th_tissue=optTh[0]+10;
		thCells=optTh[1];
	
	}else{
		
		if (wsi){		
			// SEGMENT TISSUE
			selectWindow("lum");
			getHistogram(values, counts, 256);
			peaks=Array.findMinima(counts, 100);
			peaks=Array.sort(peaks);
			//Array.print(peaks);
			posThTissue=Array.findMaxima(peaks,50);
			//Array.print(posThTissue);
			//print(peaks[posThTissue[0]]);
			th_tissue=peaks[posThTissue[0]];
			//print(th_tissue);
		
			if (th_tissue > 250){
				th_tissue=peaks[posThTissue[0]-1];
				//print(th_tissue);
				if (th_tissue > 225){
					th_tissue=peaks[posThTissue[0]-1];
					//print(th_tissue);
				}
			}
			
			th_tissue=th_tissue-5;
			
		}else{
			th_tissue=255;
		
		}
	}

	selectWindow("lum");
	run("Duplicate...", "title=tissueMask ignore");
	run("Threshold...");
	//setAutoThreshold("Huang");
	//getThreshold(lower, upper);
		//thTissue=235;
	setThreshold(0, th_tissue);
	setOption("BlackBackground", false);
	run("Convert to Mask");

	// SEGMENT CELLS--
	selectWindow("lum");
	run("Duplicate...", "title=positive ignore");
	run("Median...", "radius=1");
	//thCells=85;
	//setThreshold(0, 135);
	setThreshold(0, thCells);
	setOption("BlackBackground", false);
	run("Convert to Mask");

	//POSTPROCESSING
	
	selectWindow("tissueMask");
	run("Analyze Particles...", "size=2000-Infinity show=Masks in_situ");
	run("Invert");
	run("Analyze Particles...", "size=2000-Infinity show=Masks in_situ");
	run("Invert");
	
	selectWindow("tissueMask");
	run("Create Selection");
	run("Enlarge...", "enlarge=-20 pixel");
	setBackgroundColor(255, 255, 255);
	run("Clear Outside");
	setBackgroundColor(0, 0,0);
	run("Create Selection");
	run("Add to Manager");
	
	selectWindow("positive");
	run("Median...", "radius=2");
	
	//minCellSize=400;
	run("Analyze Particles...", "size="+minCellSize+"-Infinity pixel show=Masks in_situ");
	//run("Analyze Particles...", "size="+minCellSize+"-Infinity pixel show=Masks in_situ");
	
	//DELETE REGIONS OUTSIDE
	
	if (InDir=="-"){
		deleteTissueRegions("orig","tissueMask");
	}
	
	wait(100);
	selectWindow("positive");
	run("Select None");
	roiManager("Select", 0);
	setBackgroundColor(255,255,255);
	run("Clear Outside");
	setBackgroundColor(0,0,0);
	run("Create Selection");
	run("Add to Manager");	// ROI1 --> Cells in tissue
	close();
	
	// RESULTS--
	print("Calculating Metrics of Interest..");
		
	run("Clear Results");
	selectWindow("orig");	
	run("Set Measurements...", "area redirect=None decimal=2");
	
	// Tissue
	roiManager("select", 0);
	roiManager("Measure");
	At=getResult("Area",0);
	
	// Cells
	roiManager("select", 1);
	roiManager("Measure");
	Ap=getResult("Area",1);
	
	// Ratio
	r1=Ap/At*100;
	
	run("Clear Results");
	if(File.exists(output+File.separator+"QuantificationResults_WSI_PAS_Transwell.xls"))
	{
		
		//if exists add and modify
		open(output+File.separator+"QuantificationResults_WSI_PAS_Transwell.xls");
		IJ.renameResults("Results");
	}
	i=nResults;
	setResult("[Label]", i, MyTitle); 
	setResult("Tissue Th ",i,th_tissue);
	setResult("Positive Th ",i,thCells);
	setResult("Tissue area (um2)",i,At);
	setResult("PAS area (um2)",i,Ap);
	setResult("Ratio APAS/Atissue (%)",i,r1);			
	saveAs("Results", output+File.separator+"QuantificationResults_WSI_PAS_Transwell.xls");
			
	// DRAW--
	setBatchMode("exit and display");
	print("Saving Labelled Image and Result Metrics ..");
	
	selectWindow("orig");
	roiManager("Show None");
	run("Select None");
	roiManager("Select", 0);
	roiManager("Set Color", "red");
	run("Flatten");
	roiManager("Show None");
	roiManager("Select", 1);
	roiManager("Set Color", "green");
	run("Flatten");
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	rename(MyTitle_short+"_analyzed.jpg");
	close("\\Others");
	
	if (InDir!="-") {
	close(); }
	
	//showMessage("Done!");

}


function kmeanSearchParam(im,k){
		
			setBatchMode(true);
			print("Clustering Regions..");
			run("Set Measurements...", "area mean standard modal min redirect=None decimal=2");
			selectWindow(im);
			run("8-bit");
			getDimensions(width, height, channels, slices, frames);
			makeRectangle(0, 0, floor(width/2), floor(height/2));
			run("Duplicate...", "title=crop");
			run("k-means Clustering ...", "number_of_clusters="+k+" cluster_center_tolerance=0.10000000 enable_randomization_seed randomization_seed=48");
			
			wait(100);
			
			print("Calculating Opt Parameters..");
					
			clusters=newArray(k);
			for (i = 0; i < k; i++) {
				selectWindow("Clusters");
				run("Duplicate...", "title=Clusters-"+i);
				setAutoThreshold("Default");
				//run("Threshold...");
				setThreshold(i, i);
				setOption("BlackBackground", false);
				run("Convert to Mask");
				run("Create Selection");
				selectWindow(im);
				run("Restore Selection");
				//run("Measure");
				//cluster0=getResult("Max", 0);
				clusters[i]=getValue("Max");
			}
						
			rankClusters=Array.rankPositions(clusters);
			//Array.print(rankClusters);
			//Array.print(clusters);
		
			
			selectWindow("Clusters-"+rankClusters[0]);
			//rename("positive");
		
			selectWindow("Clusters-"+rankClusters[k-1]);
			//rename("tissueMask");
			//run("Select None");
			//run("Invert");
		
			
			close("Cluster*");
			close("crop");
			
			print("Threshold for positive regions: "+clusters[rankClusters[0]]);
			print("Threshold for tissue regions: "+clusters[rankClusters[k-2]]);
			
			t1=clusters[rankClusters[0]];
			t2=clusters[rankClusters[k-2]];
			
			thOp=newArray(t2,t1);
			
			return thOp;
}


function deleteTissueRegions(im,mask){
		
		selectWindow("orig");
		roiManager("Select",0);
		
		print("Manual Editing..");
		// Delete unwanted ROIS	
		deleteROIs=getBoolean("Do you want to Delete unwanted Regions");
						
		while (deleteROIs)
		 {
			
			// DELETE
			setTool("freehand");
			selectWindow(im);
			roiManager("select", 0);
	
			waitForUser("Please Draw ROI to delete and press ok when ready");
			
			//check if we have a selection
			type = selectionType();
			if (type==-1)	{
				showMessage("Edition", "You should select a fiber to delete. Nothing will be deleted.");
				exit();
			}	
			selectWindow(mask);
			run("Restore Selection");
			setForegroundColor(255, 255, 255);
			run("Fill", "slice");
			run("Create Selection");
			selectWindow(im);
			run("Restore Selection");
			run("Add to Manager");	// ROI1 --> Cells in tissue
			selectWindow(im);
			deleteROIs=getBoolean("Do you want to Delete another unwanted Regions");
									
			nRois=roiManager("count");
			if (nRois>1){
				roiManager("select", 0);
				roiManager("delete");
				
			}
			run("Select None");	
		} 
}
	

