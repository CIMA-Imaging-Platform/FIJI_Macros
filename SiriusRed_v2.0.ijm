//changelog October 2021
//batch processing of a directory
//sirius red detection from colour deconvolution

var r=0.502, th_tissue=233, redThreshold=200, globalMode=false, export=true;

macro "SiriusRed_batch Action Tool 1 - Cf00T2d15IT6d10m"{
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	
	Dialog.create("Parameters");
	Dialog.addMessage("Choose parameters")
	Dialog.addNumber("micra/px ratio", r);
	Dialog.addNumber("Tissue threshold", th_tissue);
	Dialog.addMessage("Sirius Red detection parameters");
	Dialog.addNumber("Red threshold", redThreshold);
	modeArray=newArray("Global correction","Tissue correction");
	Dialog.addRadioButtonGroup("Choose background compensation for sirius red", modeArray, 1, 2, "Tissue correction");
	Dialog.addCheckbox("Export analyzed image", export); 
	Dialog.show();
	r= Dialog.getNumber();
	th_tissue= Dialog.getNumber();
	redThreshold= Dialog.getNumber();
	corrType= Dialog.getRadioButton();
	export=Dialog.getCheckbox();
					
	//setBatchMode(true);
	print(name);
	sr("-","-",name,r,th_tissue,redThreshold,corrType,export);
	setBatchMode(false);
	showMessage("Done!");

		}
macro "SiriusRed_batch Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	InDir=getDirectory("Choose a Directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("Parameters");
	Dialog.addMessage("Choose parameters")
	Dialog.addNumber("micra/px ratio", r);
	Dialog.addNumber("Tissue threshold", th_tissue);
	Dialog.addMessage("Sirius Red detection parameters");
	Dialog.addNumber("Red threshold", redThreshold);
	modeArray=newArray("Global correction","Tissue correction");
	Dialog.addRadioButtonGroup("Choose background compensation for sirius red", modeArray, 1, 2, "Tissue correction");
	Dialog.addCheckbox("Export analyzed image", export); 
	Dialog.show();
	r= Dialog.getNumber();
	th_tissue= Dialog.getNumber();
	redThreshold= Dialog.getNumber();
	corrType= Dialog.getRadioButton();
	export=Dialog.getCheckbox();

	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"tif")||endsWith(list[j],"jpg")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print(name);
			//setBatchMode(true);
			sr(InDir,InDir,list[j],r,th_tissue,redThreshold,corrType,export);
			setBatchMode(false);
			}
	}
	showMessage("Done!");
}


function sr(output,InDir,name,r,th_tissue,redThreshold,corrType,export)
{
	
	if (InDir=="-") {open(name);}
	else {
		if (isOpen(InDir+name)) {}
		else { open(InDir+name); }
	}


	if(corrType=="Global correction") {
		globalMode=true;
	}
	else {
		globalMode=false;
	}
	
	getDimensions(width, height, channels, slices, frames);
	
	run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width="+r+" pixel_height=+"+r+" voxel_depth=1.0000 frame=[0 sec] origin=0,0");
			
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");

	run("Colors...", "foreground=black background=white selection=green");

	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);

	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	setBatchMode(true);
	run("Select All");
	
	run("Duplicate...", "title=orig");
	
	roiManager("Reset");
	
	//start
	
	//setBatchMode(true);
	
	run("Select All");
	showStatus("Detecting background...");

	run("Duplicate...", "title=[lum]");
	run("Split Channels");
	selectWindow("lum (blue)");
	close();
	selectWindow("lum (red)");
	close();
	selectWindow("lum (green)");
	rename("a");
	
	setAutoThreshold("Huang");
	setThreshold(0, th_tissue);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=12");
	run("Invert");
	//run("Fill Holes");
	run("Open");
	run("Analyze Particles...", "size=3000-Infinity pixel show=Masks in_situ");
	run("Invert");
	run("Analyze Particles...", "size=50000-Infinity pixel show=Masks in_situ");
	run("Create Selection");
	roiManager("Add");
	selectWindow("a");
	close();
/*
	roiManager("Add");

	selectWindow(MyTitle);
	setBatchMode(false);
	
	run("Select All");
	//run("Duplicate...", "title=orig");
	//selectWindow("orig");
	roiManager("select", 1);
	run("Make Inverse");
	wait(100);
	setForegroundColor(0, 0, 0);
	run("Fill", "slice");

	run("Select None");
	roiManager("select", 1);
	roiManager("Delete");
	*/

	showStatus("Separating colors...");
	
//--Colour Deconvolution
	//MyTitle=getTitle();
	selectWindow(MyTitle);
	run("Select All");
	run("Colour Deconvolution", "vectors=[User values] hide [r1]=0.09617791 [g1]=0.6905216 [b1]=0.7168889 [r2]=0.12630461 [g2]=0.2563811 [b2]=0.958288 [r3]=0.8249893 [g3]=0.5651483 [b3]=0.001");
	selectWindow(MyTitle+"-(Colour_2)");
	close();
	selectWindow(MyTitle+"-(Colour_3)");
	close();
	selectWindow(MyTitle+"-(Colour_1)");
	rename("positive");

	showStatus("Correcting background...");

//--Process red channel

	//mode subtraction: global for all image mode subtraction, not global for tissue mode subtraction
	if(globalMode) {
		run("Clear Results");
		run("Set Measurements...", "area mean modal redirect=None decimal=2");
		run("Select All");
		run("Measure");
		mod = getResult("Mode", 0);
		if(mod>200) {
			dif = 255-mod;
			run("Add...", "value="+dif);
		}
		run("Clear Results");
	}
	else {
		run("Clear Results");
		run("Set Measurements...", "area mean modal redirect=None decimal=2");
		roiManager("select", 0);
		run("Measure");
		mod = getResult("Mode", 0);
		if(mod>200) {
			dif = 255-mod;
			run("Select None");
			run("Add...", "value="+dif);
		}
		run("Clear Results");
	}

	showStatus("Detecting sirius red...");
	
	setThreshold(0, redThreshold);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=1");
		//Ratio and results
	selectWindow("positive");
	//run("Properties...", "channels=1 slices=1 frames=1 unit=pixel pixel_width=1.0000 pixel_height=1.0000 voxel_depth=1.0000 frame=[0 sec] origin=0,0");
	run("Analyze Particles...", "size=5-Infinity pixel circularity=0.00-1.00 show=Masks display clear in_situ");
		
	selectWindow("positive");
	//draw a pixel just in case is empty
	setPixel(1, 1, 255);
	run("Create Selection");
	roiManager("Add");

	// Save just red in tissue
	roiManager("Deselect");
	roiManager("Select", 0);
	roiManager("Select", newArray(0,1));
	roiManager("AND");
	type=selectionType();
	if(type==-1) {		
		makeRectangle(1, 1, 1, 1);
	}
	roiManager("Add");
	roiManager("Deselect");
	roiManager("Select", 1);
	roiManager("Delete");

	run("Clear Results");	
	selectWindow("positive");
	run("Set Measurements...", "area redirect=None decimal=2");
	
	//measure Tissue and positive
		
	roiManager("select", 0);
	selectWindow("positive");
	roiManager("Measure");
	roiManager("select", 1);
	selectWindow("positive");
	roiManager("Measure");
	
	Tm=getResult("Area",0);
	//in micra
	T=Tm/(r*r);
	Pm=getResult("Area",1);
	//in micra
	P=Pm/(r*r);

	
	selectWindow("positive");
	setBatchMode(false);
	run("Close");
	
	run("Clear Results");


	r1=Pm/Tm*100;
	

	
	//RESULTS print and save image
	if(File.exists(output+"Total.xls"))
	{
		//if exists add and modify
		open(output+"Total.xls");
		IJ.renameResults("Results");
	}
	i=nResults;
	setResult("Label", i, MyTitle); 
	setResult("Tissue Area (um2)",i,Tm);	
	setResult("Positive Area (um2)",i,Pm);
	setResult("Ratio Ared/Atissue (%)",i,r1);
	saveAs("Results", output+"Total.xls");	

		
	setBatchMode(false);
	selectWindow(MyTitle);
	rename("orig");
	
	roiManager("Show None");
	roiManager("Select", 0);
	roiManager("Set Color", "yellow");
	roiManager("Set Line Width", 3);
	run("Flatten");
	roiManager("Show None");
	roiManager("Select", 1);
	roiManager("Set Color", "green");
	roiManager("Set Line Width", 2);
	run("Flatten");
	if(export){
		saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	}
	rename(MyTitle_short+"_analyzed.jpg");
	
	selectWindow("orig");
	close();
	setTool("zoom");
	selectWindow("orig-1");
	close();
	
	if (InDir!="-") {
	close(); }

}

