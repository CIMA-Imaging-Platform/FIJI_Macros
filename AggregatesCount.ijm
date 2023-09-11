/*
 * SEMIAUTOMATIC DETECTION AND QUANTIFICATION OF PROT "Aggregates" per Cell
 * Target User: Didio , Tomas Aragon Research Group.
 *  
 *  Images: 
 *    - EPI Microscopy :  RGB images. DAPI and Green Channel are selected.
 *    - Format .tif   
 *  
 *  GUI Requierments:
 *    - User must draw cell countour. No presence of specific citoplasmatic membrane marker.
 *    - automatic detection "Aggregates", Find Maxima, and region growing fast marching. 
 *    - option to add/delete Aggregates. 
 *  
 *  Important Parameters
 *    - PROMINENCE -  
 *    - thFastMarching
 *    
 *  OUTPUT: 
 *   - Image Label
 *   - Cell ID
 *   - Cell Area
 *   - Cell MeanIntensity
 *   - #Aggreates/ Cell
 *   - Area Aggregates / Cell
 *   - Mean Intensity Aggregates/Cell
 *   - Ratio Aggregates Protein / Total Cell Protein.
 			
 *     
 *  Author: Tomás Muñoz 
 *  Date : 27/06/2023
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


function info(){
	scripttitle= "SEMIAUTOMATIC DETECTION AND QUANTIFICATION OF PROT AGGREGATES PER CELL";
	version= "1.03";
	date= "27/06/2023";
	
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
	    +"<ul id=list-style-3><font size=2  i><li>EPI Microscopy :  RGB images. DAPI(Blue) and GFP(Green) are selected.</li><li>8bit bit Images </li><li>Resolution: unknown</li<li>Format .tif</li></i></ul>"
	    +"<p><font size=3 i>Action tools (Buttons)</i></p>"
	    +"<ul><font size=2  i><li>F: Single File Processing</li></ul>"
	    +"<p><font size=3  i>user Steps</i></p><ol><li>Select File</li><li>Draw Manualy Cells Contour</li><li>Edit Automatic Agg detected</li></ol>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=2  i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=2  i>Excel AggregatesQuantificationResults.xls</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>Image Label</li><li>Cell ID<li>Cell Area (um2)</li><li>Cell ID<li>Cell Area (um2)</li><li>Cell MeanIntensity<li>#Aggreates/ Cell</li>"
	    +"<li>Area Aggregates each Cell</li><li>Mean Intensity Aggregates each Cell</li><li>Ratio Aggregates Protein / Total Cell Protein.</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
	}


 

setOption("DebugMode", true);
setOption("ExpandableArrays", true);
setOption("WaitForCompletion", true);
Table.showRowIndexes(false);

var fInfo=fileInfo(File.name);
var OutDir=fInfo[0];
var MyTitle=fInfo[1];
var MyTitle_short=fInfo[2];
var ID=getImageID();
var prominence=20;


// MAIN BUTTON FOR DETECTION AND QUANTIFICATION 

macro "AggregatesCount Action Tool 1 - B00C0f0T4d15Aio"
{
	if (!isOpen(ID))
	{
		fileInfo(File.name);
	}

	roiManager("Reset");
	run("Clear Results");
	run("Colors...", "foreground=black background=white selection=green");

	//User Draw Cell Contour
	selectWindow(MyTitle);

	run("Duplicate...", "title=orig duplicate");
	selectWindow("orig");
	run("Split Channels");

	//  Nucleus
	selectWindow("orig (blue)");
	rename("Nuclei");

	// Membrane
	selectWindow("orig (green)");
	rename("aggregates");

	close("orig (red)");
	
	//User Draw Cell Contour
	nCells=manualDetection(MyTitle);
	roiManager("show all");

	//Automatic Detection: FAST MARCHING REGION GROWING 
	nFocos=fastMarching("aggregates",prominence);

	//Compute ROI metrics: Area , ratio SumIntensityFocos / SumCitoplamas;
	computeMetrics("aggregates",nCells,nFocos);
	
}


/* Functions Level 1
 *  file info
 *  manualDetection
 *  fastMarching
 *  computeMetrics
*/

function fileInfo(name)
{		
		info();
		run("Close All");
		
		roiManager("Reset");
		run("Clear Results");
		path=File.openDialog("Select File");
		openFileFormat(path);
		MyTitle=getTitle();
		output=getInfo("image.directory");
		OutDir = output+File.separator+"Results";
		File.makeDirectory(OutDir);
		aa = split(MyTitle,".");
		temp = aa[0];
		aaa = split(temp,"_");
		MyTitle_short = aaa[0];
		fileDirs=newArray(OutDir, MyTitle, MyTitle_short);
		showStatus("FileSelected");
		print(MyTitle_short);
		
		return  fileDirs;
}



function manualDetection(image)
{	
	
	showStatus("Cell Manual Detection...");
	print("Cell Manual Detection...");
	wait(1000);
	selectWindow(image);
	run("Duplicate...", "title=detect");
	//Help the user visualize contours
	run("Enhance Contrast", "saturated=0.1");
	setTool("freehand");
	nCells=0;
	//check if we have a selection
	q=true;
		run("Colors...", "foreground=black background=white selection=red");
	while(q) {
		waitForUser("Select cell countour and then press OK");
		type = selectionType();
		if (type==-1)	{
			waitForUser("Edition", "You should draw a nucleolo to add.Otherwise nothing will be added.");
		 }else{
		nCells+=1;
		setSelectionName("Cell"+nCells);
		Roi.setGroup(1);
		Overlay.addSelection("green");
		run("Add to Manager");
		q=getBoolean("Would you like to add another cell?");
		}
	}
	selectWindow("detect");
	close("detect");
	selectWindow(image);
	return nCells;
}

function fastMarching(image,prominence){
	
	showStatus("Snakes Active Contours ...");
	run("Colors...", "foreground=black background=white selection=green");
	print("FastMarching...");
	setOption("ExpandableArrays", true);
	selectWindow(image);
	run("Duplicate...", "title=focusDetect");
	run("8-bit");
	nCells=RoiManager.size;
	Focos=newArray();
	setOption("WaitForCompletion", true);
	
	for (i = 0; i < nCells ; i++) {
	
		
		selectWindow("focusDetect");
		run("Duplicate...", "title=focusDetectEnhanced");
		RoiManager.select(i);
		cellBckg=getValue("Mean");
		setBackgroundColor(0,0,0);
		run("Clear Outside");
		setBackgroundColor(255,255,255);
		run("To Selection");
		//run("Enhance Contrast", "saturated=0.35");
		run("Find Maxima...", "prominence="+prominence+" output=[Point Selection]");
		setTool("multipoint");
		waitForUser("Edit Aggregates and press OK");
		
		nFocos=Roi.size;
		
		if (nFocos > 0){
		
			Roi.getCoordinates(xpoints, ypoints);
			
			//Array.print(xpoints);
			/* Use List instead o point selection
			run("Find Maxima...", "prominence="+prominence+" output=List");
			xCor=Table.getColumn("X","Results");
			yCor=Table.getColumn("Y","Results");*/


			print("nFocos detected :"+nFocos);
			Focos[i]=nFocos;
			selectWindow("focusDetectEnhanced");
			run("Select None");
			roiManager("show none");
			RoiManager.select(i);
			run("Enhance Contrast", "saturated=0.01");
			run("Apply LUT");
			run("Clear Results");
			close("Results");
			selectWindow("focusDetectEnhanced");
			run("Select None");
			roiManager("show none");
		
			pass=true;
			
			for (j = 0; j < nFocos; j++) {
				
				selectWindow("focusDetectEnhanced");
				
				maxPoint=getPixel(xpoints[j], ypoints[j]);
				thFastMarching=1;
				
				//Hyper intense aggregates + (hign medium or low cellbckg)
				if (maxPoint>200 && cellBckg>180){pass=true;}
				if (maxPoint>200 && cellBckg>100 && cellBckg<180){thFastMarching=2;}
				if (maxPoint>200 && cellBckg<100){thFastMarching=50;}
				if (maxPoint>200 && cellBckg<50){thFastMarching=130;}
		
				//High intense aggregates + (hign medium or low cellbckg)
				if (maxPoint<200 && maxPoint>150 && cellBckg>100){pass=false;}
				if (maxPoint<200 && maxPoint>150 && cellBckg>80 && cellBckg<100){thFastMarching=5;}
				if (maxPoint<200 && maxPoint>150 && cellBckg<80){thFastMarching=50;}
		
				//Midium low intense aggregates + (hign medium or low cellbckg)
				
				if (maxPoint<150 && maxPoint>100 && cellBckg>100){pass=false;}
				if (maxPoint<150 && maxPoint>100 && cellBckg>80 && cellBckg<100){pass=false;}
				if (maxPoint<150 && maxPoint>100 && cellBckg<80){thFastMarching=5;}
		
				//Low intense aggregates + (hign medium or low cellbckg)
				if (maxPoint<100 && cellBckg<100){pass=false;}
				if (maxPoint<70){pass=false;}
				
				selectWindow("focusDetectEnhanced");
				print("Cor:"+xpoints[j]+","+ypoints[j]+" maxI:"+maxPoint+" th: "+thFastMarching);
				makePoint(xpoints[j], ypoints[j], "medium red hybrid");
				if (pass){
					run("Level Sets", "method=[Active Contours] use_fast_marching grey_value_threshold="+thFastMarching+" distance_threshold=0.50 advection=1 propagation=1 curvature=1 grayscale=100 convergence=0.0050 region=inside");
					print("maxPoint: "+maxPoint);
					print("cellBkg: "+cellBckg);
					print("PARAMETER FASTMARCHING --> "+thFastMarching);
					wait(100);
					selectWindow("Segmentation of focusDetectEnhanced");
					run("Colors...", "foreground=black background=white selection=green");
					setThreshold(0, 0);
					run("Create Selection");
					run("Enlarge...", "enlarge=2");
					area=getValue("Area");
					print(area);
					if(area>250){
						run("Select None");					
						makePoint(xpoints[j], ypoints[j], "medium red hybrid");
						run("Enlarge...", "enlarge=2");
					}
				
				}else{
					run("Enlarge...", "enlarge=2");
					print("maxPoint: "+maxPoint);
					print("cellBkg: "+cellBckg);
				}
				setSelectionName("Cell"+i+1+"-Agg"+j+1);
				Roi.setGroup(i+2);
				Overlay.addSelection("red");
				run("Add to Manager");
				close("Seg*");
						
			}
			close("*Enhanced");
		}else{
			Focos[i]=0;	
		}
	}
	return Focos;
}


newImage("blackwhite", "8-bit white", 100, 100, 1);
setColor(0);
fillRect(20, 20, 20, 20);
fillRect(60, 50, 20, 20);

run("Create Selection");
getStatistics(area);
print("pixel count: "+area);

function computeMetrics(image,nCells,nFocos){
	
	showStatus("Compute Metrics ...");
	print("Compute Metrics...");
	selectWindow(image);
	run("Duplicate...", "title=Measurements");
	run("Set Scale...", "distance=1 known=1 unit=pixel");
	run("Set Measurements...", "area mean redirect=None decimal=2");

	RoiManager.selectGroup(1);
	roiManager("measure");
	
	cellTotalArea=newArray();
	focosTotalArea=newArray();

	cellMeanInt=newArray();
	cellTotalIntensity=newArray();
	focosTotalIntensity=newArray();
	ratio=newArray();

	for (i = 0; i < nCells; i++) {
		
		cellTotalArea[i]=getResult("Area",i);
		cellMeanInt[i]=getResult("Mean",i);
		cellTotalIntensity[i]=cellTotalArea[i]*cellMeanInt[i];
		
		print(cellTotalArea[i]);
		print(cellMeanInt[i]);
		print(cellTotalIntensity[i]);
	}
		

	meanIntensityFocos=newArray();
	pos=nCells;
	for (i = 0; i < nCells; i++) {

		run("Clear Results");
		
		if (nFocos[i]>0){
			RoiManager.selectGroup(i+2);
			if (nFocos[i]>1){
				roiManager("Combine");
			}
			roiManager("measure");
			roiManager("deselect");

			
			// In case there are ROIS > 200
			roisDeleted=filterTableColum("Results","Area","<",250);
			
			focosTotalIntensity[i]=0;
			focosTotalArea[i]=0;
			nFocos[i]=Table.size;
			Array.print(roisDeleted);
			
			//Delete rois from roiManager
			n=lengthOf(roisDeleted);
			print(n);

			
			if(n>0){
				for (k = 0; k < n; k++) {
					roisDeleted[k]=roisDeleted[k]+pos;
				}
				Array.print(roisDeleted);
		
				roiManager("select", roisDeleted);
				roiManager("delete");
			}
			pos=pos+nFocos[i];
			
			if (nFocos[i]>0){
				for (j = 0; j<nFocos[i]; j++) {
					
					meanIntensityFoco=getResult("Mean",j);
					areaFoco=getResult("Area",j);
					focosTotalArea[i]=focosTotalArea[i]+areaFoco;
					focosTotalIntensity[i]=focosTotalIntensity[i]+(meanIntensityFoco*areaFoco);
				}
				if(nFocos[i]==1){
					meanIntensityFocos[i]=getResult("Mean",0);
				}else{					
					run("Summarize");
					meanIntensityFocos[i]=getResult("Mean",nFocos[i]);
				
				}
				ratio[i]=(focosTotalIntensity[i]/cellTotalIntensity[i]);
			}else{
				nFocos[i]=0;
				focosTotalIntensity[i]=0;
				focosTotalArea[i]=0;
				meanIntensityFocos[i]=0;
				ratio[i]=0;
			}
				
			
		}else{
			focosTotalIntensity[i]=0;
			focosTotalArea[i]=0;
			meanIntensityFocos[i]=0;
			ratio[i]=0;
		}
		
	}


	run("Clear Results");
	close("Results");

	//SAVING RESULTS

	print("Saving Results in :"+OutDir);
		
	run("Input/Output...", "jpeg=85 gif=-1 file=.csv use_file copy_column save_column");
	
	if (File.exists(OutDir+ File.separator+"AggregatesQuantificationResults.xls"))
	{	//if exists add and modify
		open(OutDir+File.separator+"AggregatesQuantificationResults.xls");
		currentRow=Table.size("AggregatesQuantificationResults.xls");
		for (i = 0; i < nCells; i++) {
			setResult("[Label]",currentRow+i,MyTitle,"AggregatesQuantificationResults.xls");
			setResult("Cell_ID",currentRow+i,"Cell"+(i+1),"AggregatesQuantificationResults.xls");
			setResult("Cell_Area (pixels)",currentRow+i,cellTotalArea[i],"AggregatesQuantificationResults.xls");
			setResult("Cell_Mean_Intensity",currentRow+i,cellMeanInt[i],"AggregatesQuantificationResults.xls");
			setResult("#Focos", currentRow+i, nFocos[i],"AggregatesQuantificationResults.xls"); 
			setResult("Aggreagates_Area (pixels)",currentRow+i,focosTotalArea[i],"AggregatesQuantificationResults.xls");
			setResult("Aggreagates_Mean_Intensity",currentRow+i,meanIntensityFocos[i],"AggregatesQuantificationResults.xls");
			setResult("Protein Aggragates / Total Cell Protein",currentRow+i,ratio[i],"AggregatesQuantificationResults.xls");
			
		}
		
	}else {
		Table.create("AggregatesQuantificationResults");
		for (i = 0; i < nCells; i++) {
			setResult("[Label]",i,MyTitle,"AggregatesQuantificationResults");
			setResult("Cell_ID",i,"Cell"+(i+1),"AggregatesQuantificationResults");
			setResult("Cell_Area (pixels)",i,cellTotalArea[i],"AggregatesQuantificationResults");
			setResult("Cell_Mean_Intensity",i,cellMeanInt[i],"AggregatesQuantificationResults");
			setResult("#Focos", i, nFocos[i],"AggregatesQuantificationResults"); 
			setResult("Aggreagates_Area (pixels)",i,focosTotalArea[i],"AggregatesQuantificationResults");
			setResult("Aggreagates_Mean_Intensity",i,meanIntensityFocos[i],"AggregatesQuantificationResults");
			setResult("Protein Aggragates / Total Cell Protein",i,ratio[i],"AggregatesQuantificationResults");
			
		}
		
	}
	
	IJ.renameResults("Results");
	selectWindow("Results");
	saveAs("Results", OutDir+File.separator+"AggregatesQuantificationResults.xls");

	selectWindow(MyTitle);
	run("Duplicate...", "title=orig duplicate");
	roiManager("show all without labels");
	run("Flatten");

	for (i = 0; i < nCells; i++) {
		if(nFocos[i]>0){
			RoiManager.selectGroup(i+2);
			roiManager("delete");
		}
	}
	
	selectWindow("orig-1");
	RoiManager.selectGroup(1);
	roiManager("show all with labels");
	saveAs("TIFF", OutDir+File.separator+MyTitle+"_Aggragates");
	close("\\Others");
}


/* Functions level 2
	info 
	openFileFormat
	filterTableColumn
*/



function openFileFormat(file){
		
	if(endsWith(file,".jpg")||endsWith(file,".tif")){
			open(file);
	}else if(endsWith(file,".czi") || endsWith(file,".svs")){
		run("Bio-Formats Importer", "open=["+file+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	}
}


function filterTableColum(tableName,columnName,filterType,threshold)
{
	selectWindow(tableName);
	n=nResults;
	Table.setColumn("Index", Array.getSequence(n))
	Table.sort(columnName);
	column=Table.getColumn(columnName);
	for (i = 0; i < lengthOf(column); i++) {
		value=column[i];
		if (filterType=="<"){
			if (value>threshold){
				selectWindow(tableName);
				Table.deleteRows(i,lengthOf(column)-1);
				break;
			}
		}else if(filterType==">")
			if(value>threshold){
				print(value);
				print(threshold);
				selectWindow(tableName);
				Table.deleteRows(0,i-1);
				break;
			}
	}
	
	index=Table.getColumn("Index");
	indexDeleted=Array.getSequence(n);
	for (i = 0; i < lengthOf(index); i++) {
		indexDeleted=Array.deleteValue(indexDeleted, index[i]); 
	}
	selectWindow(tableName);
	return indexDeleted;
}


	
	
	
	
	
	
	
	
	
	
	


 