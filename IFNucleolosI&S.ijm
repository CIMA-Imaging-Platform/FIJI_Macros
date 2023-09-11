/* Nucleolos 
 *  Modificacion Macro Nucleolos
 *  
 *  A nivel de Usuario
 *  + Selecionar orden de los canales
 *  + Selecionar canal para segmentacion nuclear (por si el DAPI no ha sido marcado correctamente)
 *  + Añadir o eliminar nucleos a segmentar. 
 *   
 *  Nivel desarrollo
 *  + Muestra resultados de todos los nucleos (aunque no haya nucleolos)
 *  + shape descriptors.
 *  + Area total de nucleolos.
 *  + metricas morfologícas por cada nucleolo 
 */


var info=fileInfo(File.name);
var OutDir=info[0];
var MyTitle=info[1];
var MyTitle_short=info[2];
var ID=getImageID();

var auto=false;
var cAF480=1;
var cDAPI=2;
var cAF594=3;
var prominence=5;
var membrane=3;
var cSegmetnation=cDAPI;

setOption("ExpandableArrays", true);

// BUTTON FOR TISSUE DETECTION

macro "Nucleolos Action Tool 1 - C0f0T4d15Dio"
{
	if (!isOpen(ID))
	{
		fileInfo(File.name);
	}

	roiManager("Reset");
	run("Clear Results");
	run("Colors...", "foreground=black background=white selection=green");

	
	Dialog.create("Parameters for the analysis");

	Dialog.addMessage("Introduce Channel Order")
	Dialog.addNumber("AF480", cAF480);
	Dialog.addNumber("DAPI", cDAPI);
	Dialog.addNumber("AF594", cAF594);
	Dialog.addMessage("Select Channel number for Nuclear Segmentation")
	Dialog.addNumber("Channel #N", cSegmetnation);
	Dialog.addNumber("Prominence", prominence);
		
	Dialog.addMessage("Quantification Parameters")			
	Dialog.addNumber("Membrane thickness (pixels)", membrane);
	//Dialog.addCheckbox("Automatic Detection", false); --> automatic version not ready for use.
	Dialog.show();

	
	cAF480= Dialog.getNumber();
	cDAPI= Dialog.getNumber();
	cAF594= Dialog.getNumber();
	cSegmetnation= Dialog.getNumber();
	prominence= Dialog.getNumber();
	membrane= Dialog.getNumber();
	

	//prominence= Dialog.getNumber();
	//auto=Dialog.getCheckbox(); 	
	
	showStatus("Processing "+MyTitle);
	selectWindow(MyTitle);
	run("Duplicate...", "title=orig duplicate");
	selectWindow("orig");
	run("Split Channels");
	close(MyTitle);


	//  Nucleus
	selectWindow("C"+cSegmetnation+"-orig");
	run("Z Project...", "projection=[Max Intensity]");
	selectWindow("MAX_C"+cSegmetnation+"-orig");
	rename("maxProjectionNucleus");

	// Nucleolos
	selectWindow("C"+cAF480+"-orig");
	run("Z Project...", "projection=[Max Intensity]");
	rename("maxProjectionNucleolos");
	
	//  AF594
	selectWindow("C"+cAF594+"-orig");
	run("Z Project...", "projection=[Max Intensity]");
	selectWindow("MAX_C"+cAF594+"-orig");
	rename("maxProjectionAF594");

	close("C*");
	
	// Segment Nucleus
	segmentNucleus("maxProjectionNucleus");
	selectWindow("maxProjectionNucleus");
	roiManager("show all");
	waitForUser("Use + and - Buttons to Edit the Segmentation");
	

	/*	Identify Nucleolos Within Nucleus 
	 *  Manual approach--> Recomended 
	 *  Automatic approach--> Level sets, not ready (auto=false)
	*/
	run("Select All");
	selectWindow("maxProjectionNucleus");
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
		detectNucleolos("maxProjectionNucleolos",0);		  	 	
	}else if(auto){
		for (i=0; i<n; i++)
		{	detectNucleolos("maxProjectionNucleolos",i);		  	 	
		}
	}
			
	saveResults(membrane);
}


macro "Nucleolos Action Tool 2 - C0f0T6e15+"
{
	// ADD
	roiManager("Add");
	
}


macro "Nucleolos Action Tool 3 - C0f0T7e20-"
{

	// DELETE
	delete=roiManager("index");
	roiManager("Select",delete);
	roiManager("delete");
	showMessage("Selection deleted");

}


function fileInfo(name)
{		
		close("Summary");
		close("Results");
		close("*");
		run("Close All");
		roiManager("Reset");
		run("Clear Results");
		path=File.openDialog("Select File");
		run("Bio-Formats Importer", "open=["+path+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		MyTitle=getTitle();
		output=getInfo("image.directory");
		OutDir = output+File.separator+"AnalyzedImages";
		File.makeDirectory(OutDir);
		aa = split(MyTitle,".");
		if (lengthOf(aa)>2){
			MyTitle_short=aa[0]+aa[1];
		}else{
			MyTitle_short=aa[0];
			}
		fileDirs=newArray(OutDir, MyTitle, MyTitle_short);
		showStatus("FileSelected "+MyTitle_short);		
		return  fileDirs;
}



function segmentNucleus(image) 
{	

	showStatus("Segmenting Nucleus....");
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
	rename("SegNucleus");
	setBatchMode(true);
	close("Threshold");
	run("Fill Holes");
	run("Median...", "radius=2 stack");
	run("Duplicate...", "title=SegNucleus-1");
	run("Distance Map");
	rename("EDM");
	prominence=2;
	run("Find Maxima...", "prominence="+prominence+" light output=[Segmented Particles]");
	run("Invert");
	selectWindow("SegNucleus");
	run("Invert");
	imageCalculator("OR", "SegNucleus","EDM Segmented");
	selectWindow("SegNucleus");
	run("Invert");
	run("Analyze Particles...", "size=1000-Infinity pixel show=Masks exclude add in_situ");
	roiManager("Show None");
	close("SegNucleus");
	close("EDM*");
}

function detectNucleolos(image,i)
{	
	// ADD
	if (!auto){
		showStatus("Nucleolos Manual Detection..."); 
		selectWindow(image);
		wait(1000);
		run("Duplicate...", "title=detect");
		setTool("freehand");
		//check if we have a selection
		q=true;
			run("Colors...", "foreground=black background=white selection=red");
		while(q) {
			waitForUser("Select NUCLEOLO MANUALY and press OK");
			type = selectionType();
			if (type==-1)	{
				waitForUser("Edition", "You should draw a nucleolo to add. Otherwise nothing will be added.");
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
		selectWindow(image);
		run("Restore Selection");
	}
	
	if (auto){
		/* LEVEL SETS */

		showStatus("Nucleolos Automatic Detection..."); 
		selectWindow(image);
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
	
	run("Set Measurements...", "area mean standard min shape display redirect=None decimal=2");
	setOption("ExpandableArrays", true);
	roiManager("Measure");
	n=nResults;
	showStatus("nNucleos :"+n);

	//Columns for creating Nucleos Table Results 
	sampleID=newArray(n);	
	nucleoID=newArray(n);
	areaNucleo=Table.getColumn("Area","Results");
	nNucleolos=newArray(n);
	areaTotalNucleolos=newArray(n);
	//By channel
	nucleoplasmaAF480=newArray(n);
	nucleoloMemAF480=newArray(n);
	nucleoloAF480=newArray(n);
	nucleoplasmaAF594=newArray(n);
	nucleoloMemAF594=newArray(n);
	nucleoloAF594=newArray(n);

	//Columns for creating Nucleolos Table Results 
	sample=newArray();
	label=newArray();
	nucleoloSize=newArray();
	circularity=newArray();
	AR=newArray();
	
	
	for (i=0; i<n; i++)
	{

		sampleID[i]=MyTitle_short;
		nucleoID[i]=i+1;
		showStatus("NucleoID "+nucleoID[i]);
		
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
	
		//Measure Both Channels
		selectWindow("maxProjectionNucleolos");
		run("Restore Selection");
		run("Measure");
		wait(100);
		selectWindow("maxProjectionAF594");
		run("Restore Selection");
		run("Measure");
		wait(100);
		// Intensity Nucleoplasma 
		nucleoplasmaAF480[i]=getResult("Mean", 0);
		nucleoplasmaAF594[i]=getResult("Mean", 1);
		
		//CHECK -->  IF THE USER HAS SEGMENTED NUCLEOLO
		
		selectWindow("nucleoloID");
		run("Select None");
		run("Invert");
		run("Analyze Particles...", "size=10-80000 pixel show=Masks display summarize in_situ");
		nNucleolos[i]=getResult("Count", i,"Summary");
		areaTotalNucleolos[i]=getResult("Total Area", i,"Summary");
		//print("nNucleolos "+nNucleolos[i]);
		//print("area total Nucleolos "+areaTotalNucleolos[i]);


		if (nNucleolos[i]>0){
			for (j = 0; j <nNucleolos[i] ; j++) {
				//nResults-nNucleolos[i]+j: Measurements of current nucleolo.
				position=nResults-nNucleolos[i]+j;
				a=nucleoID[i];
				b=getResult("Area",position,"Results");
				c=getResult("Circ.",position,"Results");
				d=getResult("AR",position,"Results");
				sample=Array.concat(sample,sampleID[i]);
				label=Array.concat(label,a);
				nucleoloSize=Array.concat(nucleoloSize,b);
				circularity=Array.concat(circularity,c);
				AR=Array.concat(AR,d);
				//Array.print(label);
			}	
		
			//Measure 2 - Intensity Nucleolo
			
			selectWindow("nucleoloID");
			run("Create Selection");
			type = selectionType();
			if (type !=-1)	{
				
				//Intensity inside Nucleolo and Membrane Nucleolo
				run("Enlarge...", "enlarge=-"+membrane+" pixel");
				selectWindow("maxProjectionNucleolos");
				run("Restore Selection");
				run("Measure");
				wait(100);
				selectWindow("maxProjectionAF594");
				run("Restore Selection");
				run("Measure");
							
				//Measure 2 - Nucleolo
				nucleoloAF480[i]=getResult("Mean", 2+nNucleolos[i]);
				nucleoloAF594[i]=getResult("Mean", 3+nNucleolos[i]);
				
				selectWindow("nucleoloID");
				setForegroundColor(255, 255, 255);
				run("Fill", "slice");
				selectWindow("nucleoloID");
				run("Create Selection");
				
				selectWindow("maxProjectionNucleolos");
				run("Restore Selection");
				run("Measure");
				wait(100);
				selectWindow("maxProjectionAF594");
				run("Restore Selection");
				run("Measure");
								
				//Measure 3 - Nucleolo Membrane
				nucleoloMemAF480[i]=getResult("Mean", 4+nNucleolos[i]);
				nucleoloMemAF594[i]=getResult("Mean", 5+nNucleolos[i]);
				
				//print("INucleoplasma"+meanIntensityNucleoplasma[i]+" INucleolo "+meanIntensityNucleolo[i]+" IMembrana "+meanIntensityNucleoloMem[i]); 
									
				//UPDATE NucleolosMask
				selectWindow("nucleoloID");
				run("Select None");
				run("Invert");
				selectWindow("nucleoloID");
				run("Analyze Particles...", "size=10-8000 pixel show=Masks");
				imageCalculator("XOR create", "NucleolosMask","Mask of nucleoloID");
				close("Mask of nucleoloID");
				close("NucleolosMask");
				selectWindow("Result of NucleolosMask");
				rename("NucleolosMask");
				
				}
		}else{
			nNucleolos[i]=0;
			areaTotalNucleolos[i]=0;
			nucleoplasmaAF480[i]=getResult("Mean", 0);
			nucleoplasmaAF594[i]=getResult("Mean", 1);
			nucleoloAF594[i]=0;
			nucleoloAF480[i]=0;
			nucleoloMemAF480[i]=0;
			nucleoloMemAF480[i]=0;	
		}
	
	close("nucleoloID");

	}
	
	Table.create("Quantification_IntensityResults");
	Table.setColumn("SampleID",sampleID ,"Quantification_IntensityResults");
	Table.setColumn("NucleoID",nucleoID ,"Quantification_IntensityResults");
	Table.setColumn("Area Nucleo (um2)",areaNucleo ,"Quantification_IntensityResults");
	Table.setColumn("Number of Nucleolos", nNucleolos,"Quantification_IntensityResults"); 
	Table.setColumn("Area Total (um2) Nucleolos", areaTotalNucleolos,"Quantification_IntensityResults");
	Table.setColumn("AF480 Mean Intenisty Nucleoplasma", nucleoplasmaAF480,"Quantification_IntensityResults");
	Table.setColumn("AF480 Mean Intenisty Nucleolo", nucleoloAF480,"Quantification_IntensityResults");
	Table.setColumn("AF480 Mean Intenisty Nucleolo Membrane", nucleoloMemAF480,"Quantification_IntensityResults");
	Table.setColumn("AF594 Mean Intenisty Nucleoplasma", nucleoplasmaAF594,"Quantification_IntensityResults");
	Table.setColumn("AF594 Mean Intenisty Nucleolo", nucleoloAF594,"Quantification_IntensityResults");
	Table.setColumn("AF594 Mean Intenisty Nucleolo Membrane", nucleoloMemAF594,"Quantification_IntensityResults");
	Table.update;

	Table.create("ShapeDescriptors");
	Table.setColumn("SampleID",sample,"ShapeDescriptors");
	Table.setColumn("NucleoID",label ,"ShapeDescriptors");
	Table.setColumn("Area Nucleolo (um2)",nucleoloSize ,"ShapeDescriptors");
	Table.setColumn("Circularity",circularity ,"ShapeDescriptors");
	Table.setColumn("AspectRatio", AR,"ShapeDescriptors"); 
	Table.update;

		
	showStatus("Saving Results in "+ OutDir+ File.separator);
	
	if(File.exists(OutDir+ File.separator+"Quantification_IntensityResults.xls"))
	{	
		//if exists add and modify
		open(OutDir+ File.separator+"Quantification_IntensityResults.xls");
		
		tableSampleID=Table.getColumn("SampleID","Quantification_IntensityResults.xls");
		tableNucleoID=Table.getColumn("NucleoID", "Quantification_IntensityResults.xls");
		tableAreaNucleo=Table.getColumn("Area Nucleo (um2)","Quantification_IntensityResults.xls");
		tableNNucleolos=Table.getColumn("Number of Nucleolos", "Quantification_IntensityResults.xls");
		tableAvSize=Table.getColumn("Area Total (um2) Nucleolos","Quantification_IntensityResults.xls");
		
		tableNucleoplasmaAF480=Table.getColumn("AF480 Mean Intenisty Nucleoplasma", "Quantification_IntensityResults.xls");
		tableNucleoloAF480=Table.getColumn("AF480 Mean Intenisty Nucleolo", "Quantification_IntensityResults.xls");
		tableNucleoloMemAF480=Table.getColumn("AF480 Mean Intenisty Nucleolo Membrane", "Quantification_IntensityResults.xls");
		tableNucleoplasmaAF594=Table.getColumn("AF594 Mean Intenisty Nucleoplasma", "Quantification_IntensityResults.xls");
		tableNucleoloAF594=Table.getColumn("AF594 Mean Intenisty Nucleolo", "Quantification_IntensityResults.xls");
		tableNucleoloMemAF594=Table.getColumn("AF594 Mean Intenisty Nucleolo Membrane", "Quantification_IntensityResults.xls");
				
		close("Quantification_IntensityResults.xls");
		
		//CONCATENATE
		sampleID=Array.concat(tableSampleID,sampleID);
		nucleoID=Array.concat(tableNucleoID,nucleoID);
		areaNucleo=Array.concat(tableAreaNucleo,areaNucleo);
		nNucleolos=Array.concat(tableNNucleolos,nNucleolos);
		areaTotalNucleolos=Array.concat(tableAvSize,areaTotalNucleolos);
		
		nucleoplasmaAF480=Array.concat(tableNucleoplasmaAF480,nucleoplasmaAF480);
		nucleoloAF480=Array.concat(tableNucleoloAF480,nucleoloAF480);
		nucleoloMemAF480=Array.concat(tableNucleoloMemAF480,nucleoloMemAF480);
		nucleoplasmaAF594=Array.concat(tableNucleoplasmaAF480,nucleoplasmaAF594);
		nucleoloAF594=Array.concat(tableNucleoloAF480,nucleoloAF594);
		nucleoloMemAF594=Array.concat(tableNucleoloMemAF480,nucleoloMemAF594);
						
		//Rewrite Table 
		Table.setColumn("SampleID",sampleID ,"Quantification_IntensityResults");
		Table.setColumn("NucleoID",nucleoID ,"Quantification_IntensityResults");
		Table.setColumn("Area Nucleo (um2)",areaNucleo ,"Quantification_IntensityResults");
		Table.setColumn("Number of Nucleolos", nNucleolos,"Quantification_IntensityResults"); 
		Table.setColumn("Area Total (um2) Nucleolos", areaTotalNucleolos,"Quantification_IntensityResults");
		Table.setColumn("AF480 Mean Intenisty Nucleoplasma", nucleoplasmaAF480,"Quantification_IntensityResults");
		Table.setColumn("AF480 Mean Intenisty Nucleolo", nucleoloAF480,"Quantification_IntensityResults");
		Table.setColumn("AF480 Mean Intenisty Nucleolo Membrane", nucleoloMemAF480,"Quantification_IntensityResults");
		Table.setColumn("AF594 Mean Intenisty Nucleoplasma", nucleoplasmaAF594,"Quantification_IntensityResults");
		Table.setColumn("AF594 Mean Intenisty Nucleolo", nucleoloAF594,"Quantification_IntensityResults");
		Table.setColumn("AF594 Mean Intenisty Nucleolo Membrane", nucleoloMemAF594,"Quantification_IntensityResults");
		Table.update;

		saveAs("Results", OutDir+ File.separator+"Quantification_IntensityResults.xls");
		close("Quantification_IntensityResults.xls");
	}else{
		selectWindow("Quantification_IntensityResults");
		saveAs("Results", OutDir+ File.separator+"Quantification_IntensityResults.xls");
		close("Quantification_IntensityResults.xls");
	}
	

	if(File.exists(OutDir+ File.separator+"Quantification_ShapeDescriptors.xls"))
	{	
		//if exists add and modify
		open(OutDir+ File.separator+"Quantification_ShapeDescriptors.xls");

		tableSample=Table.getColumn("SampleID","Quantification_ShapeDescriptors.xls");
		tableLabel=Table.getColumn("NucleoID","Quantification_ShapeDescriptors.xls");
		tableNucleoloSize=Table.getColumn("Area Nucleolo (um2)","Quantification_ShapeDescriptors.xls");
		tableCircularity=Table.getColumn("Circularity","Quantification_ShapeDescriptors.xls");
		tableAR=Table.getColumn("AspectRatio", "Quantification_ShapeDescriptors.xls");
		close(MyTitle_short+"_"+"ShapeDescriptors.xls");

		//CONCATENATE
		sample=Array.concat(tableSample,sample);
		label=Array.concat(tableLabel,label);
		nucleoloSize=Array.concat(tableNucleoloSize,nucleoloSize);
		circularity=Array.concat(tableCircularity,circularity);
		AR=Array.concat(tableAR,AR);

		//Rewrite Table
		selectWindow("ShapeDescriptors");
		Table.setColumn("SampleID",sample,"ShapeDescriptors");
		Table.setColumn("NucleoID",label,"ShapeDescriptors");
		Table.setColumn("Area Nucleolo (um2)",nucleoloSize,"ShapeDescriptors");
		Table.setColumn("Circularity",circularity ,"ShapeDescriptors");
		Table.setColumn("AspectRatio", AR,"ShapeDescriptors"); 
		Table.update;

		selectWindow("ShapeDescriptors");
		saveAs("Results", OutDir+ File.separator+"Quantification_ShapeDescriptors.xls");
		close("Quantification_ShapeDescriptors.xls");
	}else{
		selectWindow("ShapeDescriptors");
		saveAs("Results", OutDir+ File.separator+"Quantification_ShapeDescriptors.xls");
		close("Quantification_ShapeDescriptors.xls");
	}
	
	
	close("Summary");
	close("Results");
		
	//save segmented tissue

	selectWindow("maxProjectionNucleolos");
	roiManager("Set Color", "green");
	roiManager("Set Line Width", 1);
	roiManager("Show All");
	run("Flatten");
	run("Colors...", "foreground=black background=white selection=red");
	selectWindow("NucleolosMask");
	run("Create Selection");
	selectWindow("maxProjectionNucleolos-1");
	run("Restore Selection");
	roiManager("Set Line Width", 1);
	run("Flatten");
	close("maxProjectionNucleolos-1");
	selectWindow("maxProjectionNucleolos-2");
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_Nucleolos.tif");	
	
	close("NucleolosMask");
	close("maxProjectionNucleolos");
	close(MyTitle);
	
	selectWindow(MyTitle_short+"_Nucleolos.tif");
	close("\\Others");
	
	
}
	
	
	





