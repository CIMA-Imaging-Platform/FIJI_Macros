/*
 * AUTOMATIC TIBIA CARTILAGE QUANTIFICATION"
 * Target User: F_Milagro.  
 *  
 *  Images: 
 *    - microCT : 1 channel images.  
 *    - 16 bit 512x512x512 
 *    - boxel 20 micras
 *    - Format .tif   
 *  
 *  GUI User Requierments:
 *    - None -- Target User needs the results directly. 
 *    
 *  Important Parameters:
 *    -  maxCartilageThickness.
 *    -  function TibiaHead: 30-50 Top Slices
 *    
 *  OUTPUT: 3 Action tools:
 * 	  - Automatic Cartilage Segmentation and Quantification of Cartilage: 
 * 	  		Volume mm^3 and Mean Intensity 16 bits
 * 	  		Creation of Local ThicknessMaps. in mm.
 * 	  		(InterSample Calibration with max 2mm thickness tube).
 * 	  - Manual Selection of Lateral an Medial Condyles ROIs 0.6x1.2 mm. whithin
 * 	    Previously calculated ThicknessMap. 
 * 	  		From ROIs quantify - mean, std, max and min Thickness.
 * 	  - Plot mean Thickness Profile across 1,1 mm.
 * 	  
 *  version: 1.3   
 *  Author: Tomás Muñoz 
 *  Date : 27/06/2023
 */

//	MIT License
//	Copyright (c) 2022 Nicholas Condon n.condon@uq.edu.au
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

scripttitle= "AUTOMATIC SEGMENTATION TIBIA CARTILAGE";
version= "1.03";
date= "27/06/2023";
descriptionDetails="Target - Condyle Cartilage - 40 top slices";
image1="../templateImages/cartilage.jpg";
/*descriptionActionsTools="
   

showMessage("ImageJ Script", "<html>"
	+"<style>h{margin-top: 5px; margin-bottom: 5px;} p{margin: 0px;padding: 0px;} ol{margin-left: 20px;padding: 5px;} #list-style-3 {list-style-type: circle;.container {max-width: 1200px; margin: 0 auto; padding: 0px; }</style>"
    +"<h1><font size=6 color=Teal href=https://cima.cun.es/en/research/technology-platforms/image-platforms>CIMA: Imaging Platform</h1>"
    +"<h1><font size=5 color=Purple><i>Software Development Service</i></h1>"
    +"<p><font size=2 color=Purple><i>ImageJ Macros</i></p>"
    +"<h2><font size=3 color=black>"+scripttitle+"</h2>"
    +"<p><font size=2>Created by Tomas Muñoz Santoro</p>"
    +"<p><font size=2>Version: "+version+" ("+date+")</p>"
    +"<p><font size=2> contact tmsantoro@unav.es</p>" 
    +"<p><font size=2> Available for use/modification/sharing under the "+"<p4><a href=https://opensource.org/licenses/MIT/>MIT License</a></p>"
    +"<h2><font size=3 color=black>Developed for</h2>"
    +"<p><font size=3  i>"+descriptionDetails+"</i></p>"
    +"<p><font size=3  i>Input Images</i></p>"
    +"<ul id=list-style-3><font size=2  i><li>microCT : Decalcification Mouse TIBIAs. PTA contrast.</li><li>Orentation Axial</li><li>16 bit 512x512x512</li><li>boxel 20 microns</li><li>Format .tif</li></i></ul>"
    +"<p><font size=3 i>Action tools (buttons)</i></p>"
    +"<ol><font size=2  i><li>T : Automatic Cartilage Segmentation and Quantification of Cartilage:</li>"
    +"<img src="+image1+" alt=CartilageSegmentation width=300 height=300>"
    +"<li> C : Manual Selection of Lateral an Medial Condyles ROIs 0.6x1.2 mm. whithin Previously calculated ThicknessMap.</li>"  
    +"<li> P : Plot mean Thickness Profile</li></ol>"  
  	+"<h0><font size=5> </h0>"
    +"");
    
  //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
setOption("DebugMode", true);
setOption("ExpandableArrays", true);
setOption("WaitForCompletion", true);
Table.showRowIndexes(false);


var maxCartilageThickness=4; //in pixels
var voxelSize=0.02; // mm


/* MAIN BUTTON FOR DETECTION AND QUANTIFICATION 

- Automatic Cartilage Segmentation and Quantification of Cartilage: 
 * 	  		Volume mm^3 and Mean Intensity 16 bits
 * 	  		Creation of Local ThicknessMaps. in mm.
 * 	  		(InterSample Calibration with max 2mm thickness tube).*/

macro "tibiaCartilage Action Tool 1 - C0f0T4d15Tio"{



	/*
	//FOR SINGLE FILE
	if (!isOpen(ID))
	{
		fileInfo(File.name);
	}*/

	
	// FOR BATCH MODE
	InDir=getDirectory("Choose a Directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	

	for (j = 0; j < L; j++) {

		close("*");
		roiManager("Reset");
		run("Clear Results");
		run("Select None");
		run("Colors...", "foreground=black background=white selection=green");

		//OpenFile single File 
		print(list[j]);
		
		if(!endsWith(list[j],".tif")){
		 	break
		}
			
		filePath=InDir+list[j];
		openFileFormat(filePath);
		MyTitle=getTitle();
		aa = split(MyTitle,".");
		temp = aa[0];
		aaa = split(temp,"_");
		MyTitle_short = aaa[0];
	
		output=getInfo("image.directory");
		OutDir = output+temp+"_Results";
		File.makeDirectory(OutDir);
		print(OutDir);
	
		fileDirs=newArray(OutDir, MyTitle, MyTitle_short,output);
		showStatus("FileSelected");
		print(MyTitle_short);	
	
		selectWindow(MyTitle);
		
		//Substract Ringing Artifacts
		setSlice(floor(nSlices/2));
		run("Subtract Background...", "rolling=20 stack");
	
		//Active Contours for contour inner and outer cartige edges.
		
		//Inner Cartilage edge == Inner Bone 
		innerBoneMask(MyTitle);
			
		//outer Cartilage: 
		selectWindow("innerTibiaMask");
		run("Duplicate...", "title=outerTibiaMask duplicate");
		outerCartilageMask("iMap","outerTibiaMask");
	

		//Masking Cartilage
		selectWindow("innerTibiaMask");
		run("Invert","stack");
		selectWindow("outerTibiaMask");
		run("Invert","stack");
		imageCalculator("Subtract create stack", "outerTibiaMask","innerTibiaMask");
		run("Make Binary", "method=Default background=Default");
		rename("cartilageMask");
		selectWindow(MyTitle);
		run("Duplicate...", "title=cartilageFat duplicate");
		run("8-bit");
		imageCalculator("Substract create stack", "cartilageFat","cartilageMask");
		rename("cartilage");
			
		//thresholding cartilage 
		selectWindow("cartilage");
		setAutoThreshold("Default dark no-reset stack");
		//run("Threshold...");
		setThreshold(26, 255);
		setOption("BlackBackground", false);
		run("Convert to Mask", "method=Default background=Dark");
	
		close("Result*");
		close("*Fat");

		run("Duplicate...", "title=cartilageEdges duplicate");
		run("Find Edges", "stack");
		run("Binary Overlay", "reference=["+MyTitle+"] binary=cartilageEdges overlay=Red");
		saveAs("Tiff", OutDir+File.separator+MyTitle+"_cartilage.tif");	
		close(MyTitle+"_cartilage.tif");
		
	
		run("Clear Results");
		close("Results");
		
		//Masking Cartilage
		run("Set Measurements...", "area mean display redirect=None decimal=2");
		selectWindow("cartilage");
		run("Select None");
		for (i = 1; i <= nSlices; i++) {
				selectWindow("cartilage");
			  	setSlice(i);
			   	run("Create Selection");
			   	type=selectionType();
			   	if (type !=-1){
		 		    selectWindow(MyTitle);
		 		    setSlice(i);
		 		    run("Restore Selection");
		 		    run("Measure");
	 		 	}
		}
		
		pos=nResults;
		//Cartilage intensity
		run("Summarize");
		meanIntensity=getResult("Mean", pos);
		print(meanIntensity);
						
		//Measure size of tibias head --> for normalization
		run("Clear Results");
		close("Results");
		run("Set Scale...", "distance=1 known=1 unit=pixel");
		selectWindow("innerTibiaMask");
		run("Z Project...", "projection=[Max Intensity]");
		run("Invert");
		run("Create Selection");
		
		tibiaHeadSize=getValue("Area");
		tibiaHeadSize=tibiaHeadSize*Math.pow(voxelSize,2); //in mm2
		print(tibiaHeadSize);
	
		//Cartilage Volume
		run("Clear Results");
		close("Results");
		selectWindow("cartilage");
		run("Analyze Particles...", "size=0-Infinity pixel show=Masks display in_situ stack");
		slices=nResults;
		run("Summarize");
		meanArea=getResult("Area", slices);
		cartilageVol=meanArea*slices*Math.pow(voxelSize,3); //in mm3
	
		resliceTop("cartilage");

		getDimensions(width, height, channels, slices, frames);
		makePoint(width-20, 20);
		run("Enlarge...", "enlarge="+5);
		run("Fill","stack");
		run("Select None");
				
		//Compute Local Thickness
		selectWindow("cartilage");
		run("Local Thickness (complete process)", "threshold=1");
		run("Multiply...", "value=0.02 stack"); //Local thickness result is in pixel by default
		rename("thicknessMap");
		run("Reslice [/]...", "output=1.000 start=Top avoid");
		run("Z Project...", "projection=[Max Intensity]");
		run("Fire");
		saveAs("Tiff", OutDir+File.separator+MyTitle+"_2DthicknessMap.tif");
		run("Calibration Bar...", "location=[Upper Right] fill=Black label=White number=5 decimal=3 font=12 zoom=1");
		saveAs("Tiff", OutDir+File.separator+MyTitle+"_2DthicknessMapCalibrated.tif");
		
				
		//Save Results
		print("Saving values in :"+output);
		run("Clear Results");
		if(File.exists(output+File.separator+"TIBIAS_cartilageThickness.xls"))
		{	
			//if exists add and modify
			open(output+File.separator+"TIBIAS_cartilageThickness.xls");
			IJ.renameResults("Results");
		}
		i=nResults;
		setResult("Label", i, MyTitle); 
		setResult("Tibia axial size (mm2)", i, tibiaHeadSize);
		setResult("Cartilage Volume (mm3)", i, cartilageVol); 
		setResult("Cartilage MeanIntensity (Hounsfield)", i, meanIntensity); 
		saveAs("Results", output+File.separator+"TIBIAS_cartilageThickness.xls");
	
			
		//Save Images
		print("Saving images in :"+OutDir);
		//3D projection
		selectWindow("thicknessMap");
		run("3D Project...", "projection=[Brightest Point] axis=X-Axis slice=1 initial=0 total=360 rotation=10 lower=1 upper=255 opacity=0 surface=100 interior=50");
		saveAs("Tiff", OutDir+File.separator+MyTitle+"_3DthicknessMap.tif");	
		//thicknessMap
		selectWindow("Reslice of thicknessMap");
		resliceTop("thicknessMap");
		saveAs("Tiff", OutDir+File.separator+MyTitle+"_StackThicknessMap.tif");	
		
		close("*");
		roiManager("Reset");
		run("Clear Results");
		run("Select None");
		run("Colors...", "foreground=black background=white selection=green");
		
	}	
		

}
/*
 * 	  - Manual Selection of Lateral an Medial Condyles ROIs 0.6x1.2 mm. whithin
 * 	    Previously calculated ThicknessMap. 
 * 	  		From ROIs quantify - mean, std, max and min Thickness.
*/

macro "tibiaCartilage Action Tool 2 - C0f0T4d15Cio"{



	InDir=getDirectory("Choose a Directory");
	list=getFileList(InDir);
	L=lengthOf(list);
	Array.print(list);

	for (i = 0; i < L; i++) {

		close("*");
		roiManager("Reset");
		run("Clear Results");
		run("Select None");
		run("Colors...", "foreground=black background=white selection=green");
		run("Set Measurements...", "area mean standard min display redirect=None decimal=5");

		//OpenFile single File 
		filePath=InDir+list[i];
		print(filePath);
		waitForUser; 
		if(endsWith(list[i],".jpg")||endsWith(list[i],".tif")){
		
			
			openFileFormat(filePath);
			MyTitle=getTitle();
			aa = split(MyTitle,".");
			temp = aa[0];
			aaa = split(temp,"_");
			MyTitle_short = aaa[0];
		
			output=getInfo("image.directory");
			OutDir = output+temp+"_Results";
			thicknesMapDir=OutDir+File.separator+list[i]+"_2DthicknessMap.tif";
			print(thicknesMapDir);
			openFileFormat(thicknesMapDir);
			thicknessMapTitle=getTitle();
			
			selectWindow(thicknessMapTitle);
			run("Set Scale...", "distance=1 known=0.02 unit=mm");
			getDimensions(width, height, channels, slices, frames);
	
			//measure Lateral condile	
			selectWindow(thicknessMapTitle);
			makeRectangle(width/2, height/2, 50, 30);
			waitForUser("Move the ROI to the LATERAL CONDILE and press OK");
			run("Rotate...");
			Roi.setName("LateralCondile");
			Overlay.addSelection;
			roiManager("add");
	
	
			//Measure Medial Condile
			selectWindow(thicknessMapTitle);
			makeRectangle(width/2, height/2, 50, 30);
			waitForUser("Move the ROI to the MEDIAL CONDILE and press OK");
			run("Rotate...");
			Roi.setName("MedialCondile");
			Overlay.addSelection;
			roiManager("add");
	
	
			waitForUser;
	
			RoiManager.select(0);
			meanLcondile=getValue("Mean");
			stdLcondile=getValue("StdDev");
			maxLcondile=getValue("Max");
			minLcondile=getValue("Min");
			print("Lateral Condile :");
			print("MeanThickness :"+meanLcondile);
			print("stdThickness :"+stdLcondile);
			
			
			RoiManager.select(1);
			meanMcondile=getValue("Mean");
			stdMcondile=getValue("StdDev");
			maxMcondile=getValue("Max");
			minMcondile=getValue("Min");
			print("Lateral Condile :");
			print("MeanThickness :"+meanMcondile);
			print("stdThickness :"+stdMcondile);
	
			
			//Save Images
			print("Saving images in :"+OutDir);
			selectWindow(thicknessMapTitle);
			roiManager("show all with labels");
			run("Flatten");
			waitForUser;
			saveAs("Tiff", OutDir+File.separator+MyTitle+"_condilesROIS.tif");	
			close("*");
	
			//Save Results
		
			print("Saving values in :"+output);
			run("Clear Results");
			if(File.exists(output+File.separator+"Condile_Thickness.xls"))
			{	
				//if exists add and modify
				open(output+File.separator+"Condile_Thickness.xls");
				IJ.renameResults("Results");
			}
			i=nResults;
			setResult("Label", i, MyTitle); 
			setResult("LateralCondile_meanThickness", i, meanLcondile); 
			setResult("LateralCondile_stdThickness", i, stdLcondile);
			setResult("LateralCondile_maxThickness", i, maxLcondile); 
			setResult("LateralCondile_minThickness", i, minLcondile);
			
			setResult("MedialCondile_meanThickness", i, meanMcondile); 
			setResult("MedialCondile_stdThickness", i, stdMcondile);  
			setResult("MedialCondile_maxThickness", i, maxMcondile); 
			setResult("MedialCondile_minThickness", i, minMcondile);
			
			saveAs("Results", output+File.separator+"Condile_Thickness.xls");
			
		}
	}
}

/*   - Plot mean Thickness Profile across 0.6 mm.*/

macro "tibiaCartilage Action Tool 3 - C0f0T4d15Pio"{

	close("*");
	roiManager("Reset");
	run("Clear Results");
	run("Select None");
	run("Colors...", "foreground=black background=white selection=green");
	run("Set Measurements...", "area mean standard min display redirect=None decimal=5");
	
	function openFileFormat(file){
		
		if(endsWith(file,".jpg")||endsWith(file,".tif")){
				open(file);
		}else if(endsWith(file,".czi") || endsWith(file,".svs")){
			run("Bio-Formats Importer", "open=["+file+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		}
	}
	name=File.openDialog("Select File");
	
	if(endsWith(name,".jpg")||endsWith(name,".tif")){
		
		openFileFormat(name);
	
		thicknessMapTitle=getTitle();
		aa = split(thicknessMapTitle,".");
		temp = aa[0];
		aaa = split(temp,"_");
		thicknessMapTitle_short = aaa[0];
	
		output=getInfo("image.directory");
	
		selectWindow(thicknessMapTitle);


		waitForUser("Container Box");
		run("Rotate... ");
		run("Select None");

		run("Abs");
		run("Multiply...", "value=1000");
		//run("Brightness/Contrast...");
		run("Enhance Contrast", "saturated=0.35");
		run("Calibration Bar...", "location=[Upper Left] fill=Black label=White number=5 decimal=1 font=12 zoom=1 overlay");
		
		//ROI
		getDimensions(width, height, channels, slices, frames);
		makeRectangle(width/3, height/2, 180, 50);
		waitForUser("Move the ROI");
		Roi.getCoordinates(xpoints, ypoints);
		run("Select None");
		width=xpoints[1]-xpoints[0];
		height=ypoints[3]-ypoints[0];
		roiMeanProfile=newArray(width);
		roiStdProfile=newArray(width);
		xAxis=newArray(width);
		x=xpoints[0];
		for (i = 0; i < width-1; i++) {
			xAxis[i]=x-xpoints[0];
			x+=20;
	    	makeLine(xpoints[0]+i, ypoints[0], xpoints[3]+i, ypoints[3]);
	    	currentProfile=getProfile();
			Array.getStatistics(currentProfile, min, max, mean, stdDev);
			roiMeanProfile[i]=mean;
			if (i/2-floor(i/2)!=0){
				roiStdProfile[i]=stdDev;	
			}else{
				roiStdProfile[i]=0;
			}
			
		}
		
		Plot.create("ROI Thickness", "Medial -----------> Lateral (microns)", "mean Thickness (microns)");
		Plot.add("line", xAxis, roiMeanProfile);
		Plot.setLegend("meanThickness", "top-right");
		Plot.add("error bars",roiStdProfile);
		Plot.setLegend("+/- std", "top-right");
	    Plot.show();
	    saveAs("Tiff", output+File.separator+thicknessMapTitle+"_ProfilePlot.tif");	

	    selectWindow(thicknessMapTitle);
	    waitForUser;
	    run("Crop");
	    makeRectangle(xpoints[0],ypoints[0], width, height);
	    Overlay.addSelection;
	    run("Flatten");
	    saveAs("Tiff", output+File.separator+thicknessMapTitle+"Calibrated");	
    

	}
}

/* Functions Level 1
 *  file info
 *  innerBoneMask
 *  outerCartilageMask
 */


function innerBoneMask(image){

	selectWindow(image);
	
	//Thresholding Tissue
	run("Duplicate...", "title=TibiaMask duplicate");
	setAutoThreshold("Default dark stack");
	//run("Threshold...");
	getThreshold(lower, upper);
	setThreshold(1200, upper);
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark");
	run("Median...", "radius=1 stack");
	run("Analyze Particles...", "size=1000-Infinity pixel show=Masks in_situ stack");
	
	/*Obtain InnerMask
	 * Mask Operations Close open edges. XY
	*/
	selectWindow("TibiaMask");
	run("Duplicate...", "title=fullTibiaMask duplicate");
	run("Fill Holes","stack");
	run("Duplicate...", "title=joinedTibiaMask duplicate");
	run("Invert","stack");
	run("Watershed", "stack");
	imageCalculator("XOR create stack","joinedTibiaMask","fullTibiaMask");
	run("Invert","stack");
	run("Analyze Particles...", "size=0-Infinity pixel show=Masks exclude in_situ stack");
	rename("linesXY");
	close("full*");
	close("joined*");
	imageCalculator("OR create stack", "TibiaMask","linesXY");
	selectWindow("Result of TibiaMask");
	rename("Tibia");
	close("*Mask");
	selectWindow("Tibia");
	run("Invert","stack");
	setOption("BlackBackground", false);
	run("Erode", "stack");
	run("Analyze Particles...", "size=500-25000 pixel show=Masks in_situ stack");

	
	/* Label 3D partigles -> larger correspond to inner bone  
	*/
		
	run("3D Watershed Split", "binary=Tibia seeds=Tibia radius=2");
	close("MAILLY");
	close("EDT");
	close("Tibia");
	selectWindow("Split");
	run("Keep Largest Label");
	close("Split");
	selectWindow("Split-largest");
	rename("innerTibiaMask");
	run("Invert","stack");

	// Determine the Tibia's head x slices max
	
	subStackIndex=getTibiaHead("innerTibiaMask");
	top=subStackIndex[0];
	bottom=subStackIndex[1];
	lateralEdge=subStackIndex[2];
	medialEdge=subStackIndex[3];

	//crop in Z
	selectWindow(image);
	run("Make Substack...", "delete slices="+top+"-"+bottom);
	close(image);
	selectWindow("Substack ("+top+"-"+bottom+")");
	rename(image);

	//crop in X
	resliceTop(image);
	run("Make Substack...", "delete slices="+lateralEdge+"-"+medialEdge);
	close(image);
	selectWindow("Substack ("+lateralEdge+"-"+medialEdge+")");
	rename(image);
	resliceTop(image);

	selectWindow("linesXY");
	selectWindow("linesXY");
	run("Make Substack...", "delete slices="+top+"-"+bottom);
	close("linesXY");
	selectWindow("Substack ("+top+"-"+bottom+")");
	rename("linesXY");

	//crop in X
	resliceTop("linesXY");
	run("Make Substack...", "delete slices="+lateralEdge+"-"+medialEdge);
	close("linesXY");
	selectWindow("Substack ("+lateralEdge+"-"+medialEdge+")");
	rename("linesXY");
	resliceTop("linesXY");

	
	/* Complete the mask with level sets xy and z 
	 */

	//AXIAL
	selectWindow(image);
	run("Duplicate...", "title=iMap duplicate");
	run("8-bit");
	setSlice(floor(nSlices/2));
	run("Enhance Contrast", "saturated=0.7");
	run("Apply LUT","stack");
	imageCalculator("Add create stack", "iMap","linesXY");
	close("iMap");
	selectWindow("Result of iMap");
	rename("iMap");
	//enhance edges while smoothing intensities 
	run("Kuwahara Filter", "sampling=4 stack");
	close("linesXY"); 
			
	activeContoursOutside("iMap","innerTibiaMask");
	
	//CORONAL
	resliceTop("iMap");
	resliceTop("innerTibiaMask");
	activeContoursOutside("iMap","innerTibiaMask");
	addBorder("innerTibiaMask");

	//Back to axial
	resliceTop("iMap");
	resliceTop("innerTibiaMask");
	activeContoursOutside("iMap","innerTibiaMask");



	
				
}

function outerCartilageMask(iMap,outerTibiaMask){

	
	
	//AXIAL
	activeContoursInside(iMap,outerTibiaMask,2);
	
	//CORONAL
	resliceTop(iMap);
	resliceTop(outerTibiaMask);
	activeContoursInside(iMap,outerTibiaMask,maxCartilageThickness);
	addBorder(outerTibiaMask);
	
	//Back to axial
	resliceTop(iMap);
	resliceTop(outerTibiaMask);

	
	
}


function fileInfo(name)
{	
		run("Close All");
		roiManager("Reset");
		run("Clear Results");
		
		/*
		InDir=getDirectory("Choose a Directory");
		list=getFileList(InDir);
		L=lengthOf(list);
		*/

		//For single File 
		filePath=File.openDialog("Select File");
		openFileFormat(filePath);
		MyTitle=getTitle();
		aa = split(MyTitle,".");
		temp = aa[0];
		aaa = split(temp,"_");
		MyTitle_short = aaa[0];

		output=getInfo("image.directory");
		OutDir = output+temp+"_Results";
		File.makeDirectory(OutDir);
		print(OutDir);
		
		fileDirs=newArray(OutDir, MyTitle, MyTitle_short,output);
		showStatus("FileSelected");
		print(MyTitle_short);	

		return  fileDirs;
} 

/* Functions Level 2
 *  getTibiaHead
 *  activeContoursOutside
 *  activeContoursInside
 *  resliceTop
 *  openFileFormat
 */



function activeContoursInside(iMap,innerTibiaMask,maxCartilageThickness){

		setBatchMode(true);
		selectWindow(innerTibiaMask);
		
		innerTibiaMask="outerTibiaMask";
		Stack.getDimensions(width, height, channels, slices, frames);
		run("Duplicate...", "title="+innerTibiaMask+"temp duplicate");

		setForegroundColor(0,0,0);
		setBackgroundColor(255,255,255);
		
		for (i = 1; i < slices+1; i++) {
			selectWindow(innerTibiaMask);
			setSlice(i);
			run("Create Selection");
			type=selectionType();	
			if (type != -1 ) {
				//maxCartilageThickness
				
				run("Enlarge...", "enlarge="+maxCartilageThickness);
				run("Fill","slice");
				
				// ACTIVE COUNTUORS FAILS!! --> open cartilage  ... 
				/*setForegroundColor(255,255,255);
				setBackgroundColor(0,0,0);
				selectWindow(iMap);
				setSlice(i);
				run("Duplicate...", "title="+iMap+"_slice");
				run("Restore Selection");
				//maxCartilageThickness
				run("Enlarge...", "enlarge="+maxCartilageThickness);
				run("Clear Outside");
				/*waitForUser;
				run("Level Sets", "method=[Active Contours] use_level_sets grey_value_threshold=100 distance_threshold=1 advection=1 propagation=1 curvature=0.5 grayscale=30 convergence=0.0050 region=inside");
				waitForUser;
				close("*progress*");
				run("Concatenate...", "  title="+innerTibiaMask+"temp image1="+innerTibiaMask+"temp image2=[Segmentation of "+iMap+"_slice]");
				close("Segmentation*");
				close("iMap_slice");*/
				
			}else{
				
				/*
				selectWindow(innerTibiaMask);
				setSlice(i);
				run("Duplicate...", "title=slice");
				run("Select All");
				run("Fill","Slice");
				run("Concatenate...", "  title="+innerTibiaMask+"temp image1="+innerTibiaMask+"temp image2=slice");*/
			}
		}

		
		setBackgroundColor(0,0,0);
		setForegroundColor(255,255,255);
		
		/*close(innerTibiaMask);
		selectWindow(iMap);
		Stack.getDimensions(width, height, channels, slices, frames);
		selectWindow(innerTibiaMask+"temp");
		//slices=512;
		//run("Make Substack...", "delete slices="+slices+1+"-"+2*slices);
		rename(innerTibiaMask);
		close(innerTibiaMask+"temp");
		*/
		setBatchMode(false);

}



function activeContoursOutside(iMap,innerTibiaMask){

		setBatchMode(true);
		selectWindow(innerTibiaMask);

		Stack.getDimensions(width, height, channels, slices, frames);
		run("Duplicate...", "title="+innerTibiaMask+"temp duplicate");
		
		setBackgroundColor(0,0,0);
		setForegroundColor(255,255,255);
		
		for (i = 1; i < slices+1; i++) {
			selectWindow(innerTibiaMask);
			setSlice(i);
			run("Create Selection");
			type=selectionType();
			print("processsing slice"+i);
			if (type != -1 ) {
				selectWindow(iMap);
				setSlice(i);
				run("Duplicate...", "title="+iMap+"_slice");
				run("Restore Selection");
				run("Level Sets", "method=[Active Contours] use_level_sets grey_value_threshold=50 distance_threshold=0.50 advection=2 propagation=1 curvature=1 grayscale=30 convergence=0.0050 region=outside");
				close("*progress*");
				run("Concatenate...", "  title="+innerTibiaMask+"temp image1="+innerTibiaMask+"temp image2=[Segmentation of "+iMap+"_slice]");
				close("Segmentation*");
				close("iMap_slice");
			}else{
				selectWindow("innerTibiaMask");
				setSlice(i);
				run("Duplicate...", "title=slice");
				run("Select All");
				//setForegroundColor(255,255,255);
				run("Fill","Slice");
				run("Concatenate...", "  title="+innerTibiaMask+"temp image1="+innerTibiaMask+"temp image2=slice");
			}
			
		}
		//setForegroundColor(0,0,0);
		close(innerTibiaMask);
		selectWindow(iMap);
		Stack.getDimensions(width, height, channels, slices, frames);
		selectWindow(innerTibiaMask+"temp");
		//slices=512;
		run("Make Substack...", "delete slices="+slices+1+"-"+2*slices);
		rename(innerTibiaMask);
		close(innerTibiaMask+"temp");
		setBatchMode(false);
}

function getTibiaHead(innerTibiaMask){
	
	selectWindow(innerTibiaMask);
	Stack.getDimensions(width, height, channels, slices, frames);
	for (i = 1; i < slices+1; i++) {
		selectWindow(innerTibiaMask);
		setSlice(i);
		run("Create Selection");
		type=selectionType();	
		if (type != -1 ) {
			top=i;
			break;
			}
	}

	run("Select None");
	top3=top-10;
	bottom=top+30; //IMPORTANT
	run("Make Substack...", "delete slices="+top3+"-"+bottom);
	close(innerTibiaMask);
	selectWindow("Substack ("+top3+"-"+bottom+")");
	rename(innerTibiaMask);

	resliceTop(innerTibiaMask);

	
	Stack.getDimensions(width, height, channels, slices, frames);
	for (i = 1; i < slices+1; i++) {
		selectWindow(innerTibiaMask);
		setSlice(i);
		run("Create Selection");
		type=selectionType();	
		if (type != -1 ) {
			lateralEdge=i;
			break;
			}
	}

	print(i);

	run("Select None");
	lateralEdge3=lateralEdge-20;
	medialEdge=lateralEdge+180;
	run("Make Substack...", "delete slices="+lateralEdge3+"-"+medialEdge);
	close(innerTibiaMask);
	selectWindow("Substack ("+lateralEdge3+"-"+medialEdge+")");
	rename(innerTibiaMask);
	resliceTop(innerTibiaMask);
		
	subStackIndex=newArray(top3,bottom,lateralEdge3,medialEdge);
	
	return subStackIndex;
}

function resliceTop(image){
	//Coronal to axial
	selectWindow(image);
	run("Select All");
	run("Reslice [/]...", "output=1.000 start=Top");
	close(image);
	rename(image);
		
} 	


function addBorder(image){
	
	selectWindow(image);
	run("Invert","stack");
	run("Duplicate...", "title=border duplicate");
	setForegroundColor(0,0,0);
	setBackgroundColor(255,255,255);
	run("Select All");
	run("Fill" , "stack");
	run("Enlarge...", "enlarge=-2");
	run("Clear Outside","stack");
	run("Select None");
	imageCalculator("Substract stack", image,"border");
	run("Invert","stack");
	close("Border");
	
}

function openFileFormat(file){
		
	if(endsWith(file,".jpg")||endsWith(file,".tif")){
			open(file);
	}else if(endsWith(file,".czi") || endsWith(file,".svs")){
		run("Bio-Formats Importer", "open=["+file+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	}
}

