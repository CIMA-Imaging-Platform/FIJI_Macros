
function macroInfo(){
	
// * Quantification of Brown WSI Images Area  
// * Target User: Luisa Statello
// *  

	scripttitle= "Semi-Automatic Quantification of Nuclelos Intensity in IF Confocal Zstack Images";
	version= "1.03";
	date= "2023";
	

// *  Tests Images:

	imageAdquisition="Confocal Z Stack Images. Multiple Channels";
	imageType="8bit";  
	voxelSize="Voxel size:  unknown um xy";
	format="Format: Zeiss .czi";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button 
	 parameter1="Introduce the position of the Nucleolina Channel"; 
	 parameter2="Introduce estimated Nucleolo membrane thicknes (pixels): default 3";
	 

 //  2 Action tools:
	 buttom1="Im: Open File";
	 buttom2="D: Quantify current Image.";

//  OUTPUT

// Analyzed Images with ROIs

	excel="AverageResults.csv";
	feature1="Image Label ID";
	feature2="Nuclei ID";
	feature3="Number of Nucleolos Quantified";
	feature4="Average Size (um2) Nuclei Nucleolos";
	feature5="Mean Intenisty Nucleoplasma";
	feature6="Mean Intenisty Nucleolo";
	feature7="Mean Intenisty Nucleolo Membrane";
	
/*  	  
 *  version: 1.02 
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
	    +"<ol><font size=2  i><li>"+buttom1+"</li>"
	    +"<li>"+buttom2+"</li></ol>"
	    +"<p><font size=3  i>PARAMETERS: Right Click on Action tools  </i></p>"
	    +"<ul id=list-style-3><font size=2  i>"
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li><li>"+feature5+"</li><li>"+feature6+"</li><li>"+feature7+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}
	
/* Nucleolos 
 *  
 */
 
 
var auto=false;
var nucleusAnalysis=true;
var prominence=2;
var membrane=3;

 
 
var info=fileInfo(File.name);
var OutDir=info[0];
var MyTitle=info[1];
var MyTitle_short=info[2];

var cAF647=2;

	
macro "Nucleo los Action Tool 1 - C0f0T2d15IT6d10m"
{	
	run("Close All");
	setBatchMode(false);
	
	macroInfo();
	
	
	fileInfo(File.name);	
	
}

// BUTTON FOR TISSUE DETECTION

macro "Nucleolos Action Tool 1 - C0f0T4d15Dio"
{

	roiManager("Reset");
	run("Clear Results");
	run("Colors...", "foreground=black background=white selection=green");
	
	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Introduce Channel Order:  ")
	Dialog.addNumber("Nucleolina", cAF647);
	Dialog.addMessage("Parameters")			
	//Dialog.addNumber("Prominence", prominence);
	Dialog.addNumber("Membrane thickness (pixels)", membrane);
	//Dialog.addCheckbox("Automatic Detection", false);
	Dialog.show();

	//prominence= Dialog.getNumber();
	cAF647= Dialog.getNumber();
	membrane= Dialog.getNumber();
	//print(thNuclei);
		
	
	//auto=Dialog.getCheckbox(); 	
	
	print(MyTitle);
	selectWindow(MyTitle);
	run("Duplicate...", "title=orig duplicate");
	selectWindow("orig");
	run("Split Channels");
	selectWindow("C"+cAF647+"-orig");
	run("Z Project...", "projection=[Max Intensity]");
	close("C1-orig");
	close("C2-orig");
	close("C3-orig");
	close(MyTitle);
	
	// Segment Nucleus
	selectWindow("MAX_C"+cAF647+"-orig");
	rename("maxProjection");
	segmentNucleus("maxProjection");
	selectWindow("maxProjection");
	roiManager("show all");

	/* Within Nucleus --> Level sets, identify Nucleolos
	*/
	wait(1000);
	setBatchMode(false);
	roiManager("show none");
	n=roiManager("count");
	run("Set Measurements...", "area mean standard modal min mean display redirect=None decimal=2");
	run("Duplicate...", "title=NucleolosMask");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Select All");
	setForegroundColor(255, 255, 255);
	run("Fill", "slice");
	
	if (!auto){
		detectNucleolos("maxProjection",0);		  	 	
	}else if(auto){
		for (i=0; i<n; i++)
		{	detectNucleolos("maxProjection",i);		  	 	
		}
	}
	
	saveResults(membrane);
}


function fileInfo(name)
{	
		run("Close All");
		
		roiManager("Reset");
		run("Clear Results");
		path=File.openDialog("Select File");
		
		run("Bio-Formats Importer", "open=["+path+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		Stack.setChannel(2);
		MyTitle=getTitle();
		output=getInfo("image.directory");
		OutDir = output+File.separator+"Results";
		File.makeDirectory(OutDir);
		aa = split(MyTitle,".");
		temp = aa[0];
		aaa = split(temp,"_");
		MyTitle_short = aaa[0];
		fileDirs=newArray(OutDir, MyTitle, MyTitle_short);
		print("FileSelected");
		print(MyTitle_short);		
		return  fileDirs;
}



function segmentNucleus(image) 
{	

	print("Segmenting Nucleus....");
	selectWindow(image);
	run("Duplicate...", "title=SegNucleus");
	run("Subtract Background...", "rolling=150");
	run("Threshold...");
	setAutoThreshold("Default dark no-reset");
	//thNucleus=800;
	waitForUser("Select Threshold for Nucleus Segmentation");
	getThreshold(lower, upper);
	setThreshold(lower, upper);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Analyze Particles...", "size=1000-Infinity pixel show=Masks");
	close("SegNucleus");
	selectWindow("Mask of SegNucleus");
	rename("SegNucleus")
	setBatchMode(true);
	close("Threshold");
	run("Fill Holes");
	run("Median...", "radius=2 stack");
	run("Duplicate...", "title=SegNucleus-1");
	run("Distance Map");
	
	// transform selection to individual points
	//prominence=5;
	run("Find Maxima...", "prominence="+prominence+" light output=[Single Points]");
	//print(prominence);
	rename("nucleusMaxima");
	
	selectWindow("SegNucleus");
	run("Duplicate...", "title=edgesNucleus");
	run("Find Edges");
	
	// MARKER-CONTROLLED WATERSHED
	run("Marker-controlled Watershed", "input=edgesNucleus marker=nucleusMaxima mask=SegNucleus binary calculate use");
	selectWindow("edgesNucleus-watershed");
	run("8-bit");
	setThreshold(1, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Analyze Particles...", "size=1000-Inf pixel show=Masks add in_situ");
	roiManager("Show None");
	close("SegNucleus");
}

function detectNucleolos(image,i)
{	
	// ADD
	if (!auto){
	
		print("Nucleolos Manual Detection..."); 
		selectWindow("maxProjection");
		wait(1000);
		run("Duplicate...", "title=detect");
		setTool("freehand");
		//check if we have a selection
		q=true;
			run("Colors...", "foreground=black background=white selection=red");
		while(q) {
			waitForUser("Select nucleolo from the analysis and then press OK");
			type = selectionType();
			if (type==-1)	{
				waitForUser("Edition", "You should draw a nucleolo to add.Otherwise nothing will be added.");
			 }else{
			selectWindow("NucleolosMask");
			run("Restore Selection");
			setForegroundColor(0, 0, 0);
			run("Fill", "slice");
			run("Select None");
			run("Create Selection");
			selectWindow("detect");
			run("Restore Selection");
			q=getBoolean("Would you like to add another nucleolo?");
			}
		}
		close("detect");
		selectWindow("NucleolosMask");
		run("Create Selection");
		selectWindow("maxProjection");
		run("Restore Selection");
		print("Done");
	}
	
	if (auto){
		
		/* LEVEL SETS NOT OPTIMAL*/

		print("Nucleolos Automatic Detection..."); 
		selectWindow("maxProjection");
		run("Duplicate...", "title=nucleusID");
		run("Colors...", "foreground=white background=black selection=green");
		//check if we have a selection
		roiManager("Select",i);
		run("Clear Outside");
		run("Set Measurements...", "area mean standard modal min median display redirect=None decimal=2");
		roiManager("Select",i);
		run("Enhance Contrast", "saturated=0.35");
		run("Apply LUT");
		//run("Find Edges");
		//run("Median...", "radius=2");
		roiManager("Measure");
		maxInt=getResult("Max", i);
		meanInt=getResult("Mean", i);
		stdDev=getResult("StdDev",i);
		//print(maxInt);
		roiManager("Select",i); 
		run("Scale... ", "x=0.97 y=0.97 centered");
		roiManager("Update");
		roiManager("Select",i);
	
		levelSetParam=floor((maxInt-stdDev)-meanInt);
	
		if (maxInt>200 && meanInt<140){
			if (levelSetParam>100){
				levelSetParam=100;}
		}
		//print(levelSetParam);
		run("Select None");
		roiManager("Select",i);
		run("Level Sets", "method=[Active Contours] use_level_sets grey_value_threshold=100 distance_threshold=0.50 advection=1 propagation=1 curvature=1 grayscale="+levelSetParam+" convergence=0.0020 region=inside");           
		close("Segmentation progress of nucleusID");
		imageCalculator("OR create", "NucleolosMask","Segmentation of nucleusID");
		close("NucleolosMask");
		selectWindow("Result of NucleolosMask");
		rename("NucleolosMask");
		close("Segmentation of nucleusID");
		close("nucleusID");
	}
	
	// FINISH AND SAVE RESULTS
	
}

function saveResults(membrane){
			
	// RESULTS
	run("Set Measurements...", "area mean standard modal min median display redirect=None decimal=2");
	n=roiManager("count");
	m=0;
	//print(n);
	
	if (nucleusAnalysis){
		sampleID=newArray(1);	
		nucleoID=newArray(1);
		nNucleolos=newArray(1);
		meanIntensityNucleolo=newArray(1);
		meanIntensityNucleoloMem=newArray(1);
		meanIntensityNucleoplasma=newArray(1);
		meanSize=newArray(1);
			
		for (i=0; i<n; i++)
		{
		
			//Measure 1 - Intensity Nucleoplasma
			run("Clear Results");	
			selectWindow("NucleolosMask");
			run("Select None");
			run("Duplicate...", "title=nucleoloID");
			setBackgroundColor(0, 0, 0);
			roiManager("Select",i);
			run("Clear Outside");
			run("Select None");
			run("Invert");
			run("Create Selection");
			selectWindow("maxProjection");
			run("Restore Selection");
			run("Measure");
			
			//print(meanIntensityNucleoplasma);
			
			//CHECK IF THE USER HAS SEGMENTED NUCLEOLO
			selectWindow("nucleoloID");
			run("Select None");
			run("Invert");
			run("Analyze Particles...", "size=10-80000 pixel show=Masks summarize");
			check=getResult("Count", 0,"Summary");
			Table.deleteRows(0, 1, "Summary");
			close("nucleoloID");
			selectWindow("Mask of nucleoloID");
			rename("nucleoloID");
			
			if (check>0){
	
				sampleIDtemp=newArray(1);	
				nucleoIDtemp=newArray(1);
				nNucleolostemp=newArray(1);
				meanIntensityNucleolotemp=newArray(1);
				meanIntensityNucleoloMemtemp=newArray(1);
				meanIntensityNucleoplasmatemp=newArray(1);
				meanSizetemp=newArray(1);
				
				sampleIDtemp=MyTitle_short;
				nucleoIDtemp=i+1;
				run("Analyze Particles...", "size=10-80000 pixel show=Masks include summarize in_situ");
				nNucleolostemp=getResult("Count", 0,"Summary");
				meanSizetemp=getResult("Average Size", 0,"Summary");
				
				//Measure 2 - Intensity Nucleolo
				run("Create Selection");
				selectWindow("maxProjection");
				roiManager("Show None");
				run("Restore Selection");
				run("Measure");
				
				//print(nNucleolos[i]);
				//print(meanSize[i]);
				
				selectWindow("nucleoloID");
				Table.deleteRows(0, 1, "Summary");
				run("Create Selection");
				type = selectionType();
				if (type !=-1)	{
					
					//GET RESULTS
					
					//Nucleoplasma 
					meanIntensityNucleoplasmatemp=getResult("Mean", 0);
					
					
					//Nucleolo and Membrane
					meanIntensityNucleolotemp=getResult("Mean", 1);
					run("Enlarge...", "enlarge=-"+membrane+" pixel");
					setForegroundColor(255, 255, 255);
					run("Fill", "slice");
					run("Create Selection");
					selectWindow("maxProjection");
					run("Restore Selection");
					//Measure 3 - Nucleolo Membrane
					run("Measure");
					meanIntensityNucleoloMemtemp=getResult("Mean", 2);
					//print(meanNucleoloMembrane);
								
					//UPDATE NucleolosMask
					selectWindow("nucleoloID");
					run("Select None");
					run("Invert");
					run("Analyze Particles...", "size=10-8000 pixel show=Masks");
					imageCalculator("XOR create", "NucleolosMask","Mask of nucleoloID");
					close("Mask of nucleoloID");
					close("NucleolosMask");
					selectWindow("Result of NucleolosMask");
					rename("NucleolosMask");
					close("Result of NucleolosMask");

					sampleID=Array.concat(sampleID,sampleIDtemp);
					nucleoID=Array.concat(nucleoID,nucleoIDtemp);
					nNucleolos=Array.concat(nNucleolos,nNucleolostemp);
					meanSize=Array.concat(meanSize,meanSizetemp);
					meanIntensityNucleoplasma=Array.concat(meanIntensityNucleoplasma,meanIntensityNucleoplasmatemp);
					meanIntensityNucleolo=Array.concat(meanIntensityNucleolo,meanIntensityNucleolotemp);
					meanIntensityNucleoloMem=Array.concat(meanIntensityNucleoloMem,meanIntensityNucleoloMemtemp);
										
				}	

				m=m+1;
			}
			close("nucleoloID");
		
		}
		
		Table.create("averageResults");
		Table.setColumn("SampleID",sampleID ,"averageResults");
		Table.setColumn("NucleoID",nucleoID ,"averageResults");
		Table.setColumn("Number of Nucleolos", nNucleolos,"averageResults"); 
		Table.setColumn("Average Size (um2) Nucleolo", meanSize,"averageResults");
		Table.setColumn("Mean Intenisty Nucleoplasma", meanIntensityNucleoplasma,"averageResults");
		Table.setColumn("Mean Intenisty Nucleolo ", meanIntensityNucleolo,"averageResults");
		Table.setColumn("Mean Intenisty Nucleolo Membrane", meanIntensityNucleoloMem,"averageResults");
		Table.deleteRows(0, 0,"averageResults");
		Table.update;
		selectWindow("averageResults");
		print("Saving Results in "+ OutDir+ File.separator);
		
		if(File.exists(OutDir+ File.separator+"AverageResults.csv"))
		{	
			//if exists add and modify
			open(OutDir+ File.separator+"AverageResults.csv");
			
			tableSampleID=Table.getColumn("SampleID","AverageResults.csv");
			tableNucleoID=Table.getColumn("NucleoID", "AverageResults.csv");
			tableNNucleolos=Table.getColumn("Number of Nucleolos", "AverageResults.csv");
			tableAvSize=Table.getColumn("Average Size (um2) Nucleolo","AverageResults.csv");
			tablemeanNucleoplasma=Table.getColumn("Mean Intenisty Nucleoplasma", "AverageResults.csv");
			tablemeanNucleolo=Table.getColumn("Mean Intenisty Nucleolo", "AverageResults.csv");
			tablemeanNucleoloMem=Table.getColumn("Mean Intenisty Nucleolo Membrane", "AverageResults.csv");
			
			
			close("AverageResults.csv");
			
			//CONCATENATE
			sampleID=Array.concat(tableSampleID,sampleID);
			nucleoID=Array.concat(tableNucleoID,nucleoID);
			nNucleolos=Array.concat(tableNNucleolos,nNucleolos);
			meanSize=Array.concat(tableAvSize,meanSize);
			meanIntensityNucleoplasma=Array.concat(tablemeanNucleoplasma,meanIntensityNucleoplasma);
			meanIntensityNucleolo=Array.concat(tablemeanNucleolo,meanIntensityNucleolo);
			meanIntensityNucleoloMem=Array.concat(tablemeanNucleoloMem,meanIntensityNucleoloMem);
							
			//Rewrite Table 
			Table.setColumn("SampleID",sampleID ,"averageResults");
			Table.setColumn("NucleoID",nucleoID ,"averageResults");
			Table.setColumn("Number of Nucleolos", nNucleolos,"averageResults"); 
			Table.setColumn("Average Size (um2) Nucleolo", meanSize,"averageResults");
			Table.setColumn("Mean Intenisty Nucleoplasma", meanIntensityNucleoplasma,"averageResults");
			Table.setColumn("Mean Intenisty Nucleolo ", meanIntensityNucleolo,"averageResults");
			Table.setColumn("Mean Intenisty Nucleolo Membrane", meanIntensityNucleoloMem,"averageResults");
			Table.deleteRows(tableSampleID.length,tableSampleID.length,"averageResults");
			Table.update;
				
			saveAs("averageResults", OutDir+ File.separator+"AverageResults.csv");
			}
		else
		{
			selectWindow("averageResults");
			saveAs("averageResults", OutDir+ File.separator+"AverageResults.csv");
		}
		
		close("Summary");
		close("Results");
	}
	
	
	//save segmented tissue

	selectWindow("maxProjection");
	roiManager("Set Color", "green");
	roiManager("Set Line Width", 1);
	roiManager("Show All");
	run("Flatten");
	run("Colors...", "foreground=black background=white selection=red");
	selectWindow("NucleolosMask");
	run("Create Selection");
	selectWindow("maxProjection-1");
	run("Restore Selection");
	roiManager("Set Line Width", 1);
	run("Flatten");
	close("maxProjection-1");
	selectWindow("maxProjection-2");
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_Nucleolos.tif");	
	
	close("NucleolosMask");
	close("MaxProjection");
	close(MyTitle);
	
	selectWindow(MyTitle_short+"_Nucleolos.tif");
	close("\\Others");
	
	
	
}
	
	
	





