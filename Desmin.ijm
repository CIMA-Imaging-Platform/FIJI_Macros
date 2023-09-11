// Changelog March 2023
// Automatic tissue detection adapted from BrownDetectionArea

var r=0.502, th_tissue=230, th_brown=160, vessels=15;

macro "Desmin Action Tool 1 - Cf00T2d15IT6d10m"{
	//just one file
	name=File.openDialog("Select File");
	

	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Choose parameters")	
    Dialog.addNumber("micra/px ratio", r);
    Dialog.addNumber("Threshold for tissue detection", th_tissue); 
    Dialog.addNumber("Threshold for brown detection", th_brown);  
    Dialog.addNumber("Size Vessels", vessels);  
    Dialog.show();
    r= Dialog.getNumber();
    th_tissue= Dialog.getNumber();
    th_brown= Dialog.getNumber();  
    vessels= Dialog.getNumber();  
    
	//setBatchMode(true);
	browndetection("-","-",name,r,th_tissue,th_brown,vessels);
	setBatchMode(false);
	showMessage("Done!");

}

macro "Desmin Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	InDir=getDirectory("Choose a Directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Choose parameters")	
    Dialog.addNumber("micra/px ratio", r);
    Dialog.addNumber("Threshold for tissue detection", th_tissue); 
    Dialog.addNumber("Threshold for brown detection", th_brown);  
    Dialog.addNumber("Size Vessels", vessels); 
    Dialog.show();
    r= Dialog.getNumber();
    th_tissue= Dialog.getNumber();
    th_brown= Dialog.getNumber();  
    vessels= Dialog.getNumber();  

	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"jpg")||endsWith(list[j],"tif")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print(name);
			//setBatchMode(true);
			browndetection(InDir,InDir,list[j],r,th_tissue,th_brown,vessels);
			setBatchMode(false);
			}
	}
	showMessage("Done!");
}


function browndetection(output,InDir,name,r,th_tissue,th_brown,vessels)
{
	
	if (InDir=="-") {open(name);}
	else {
		if (isOpen(InDir+name)) {}
		else { open(InDir+name); }
	}

	
	//getDimensions(width, height, channels, slices, frames);
	
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	print("Processing "+MyTitle);
	setBatchMode(true);
	run("Colors...", "foreground=white background=black selection=green");
	
	// DETECT TISSUE
	run("Select All");
	showStatus("Detecting tissue...");
	print("Detecting tissue...");
	run("RGB to Luminance");
	rename("a");
	run("Threshold...");
	//setAutoThreshold("Huang");
	//getThreshold(lower, upper);
	th_tissue=230;
	setThreshold(0, th_tissue);
	run("Convert to Mask");
	run("Median...", "radius=12");
	run("Invert");
	run("Fill Holes");
	run("Analyze Particles...", "size=3000-Infinity pixel show=Masks in_situ");
	run("Invert");
	
	// ROI1 --> whole tissue
	run("Create Selection"); 	
	run("Add to Manager");
	run("Select None");
	selectWindow("a");
	run("Duplicate...", " ");
	run("Fill Holes");
	imageCalculator("XOR create", "a","a-1");
	
	// ROI2 --> Vessels
	selectWindow("Result of a");
	run("Create Selection");
	print("Detecting vessels...");
	run("Add to Manager");	
	run("Select None");
	close("Result of a");
	close("a-1");
	close("a");
	close("Threshold");
	
	
	//BROWN--
	
	flagBrown=false;
		selectWindow(MyTitle);
	run("Colour Deconvolution", "vectors=[H&E DAB] hide");
	//selectWindow(MyTitle+"-(Colour_3)");
	close(MyTitle+"-(Colour_2)");
	close(MyTitle+"-(Colour_1)");
	print("Segmenting Desmin");
	selectWindow(MyTitle+"-(Colour_3)");
	run("Threshold...");
	setAutoThreshold("Default");
	th_brown=160;
	setThreshold(0, th_brown);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	close("Threshold");
	run("Median...", "radius=1");
	roiManager("Show None");
	
	//Enlarge 
	roiManager("Select", 1);
	run("Enlarge...", "enlarge="+vessels);
	setForegroundColor(255, 255, 255);
	run("Fill", "slice");
	
	run("Create Selection");
	type=selectionType();
	if(type==-1) {
		makeRectangle(1, 1, 1, 1);
		flagBrown=true;
	}
	run("Add to Manager");	// ROI1 --> Whole brown
	close();
	
	
	// RESULTS--
	
	run("Clear Results");
	selectWindow(MyTitle);	
	run("Set Measurements...", "area redirect=None decimal=2");
	print("Saving Results");
	
	// Tissue
	roiManager("select", 0);
	roiManager("Measure");
	At=getResult("Area",0);
	//in micra
	Atm=At*r*r;
	
	// Staining
	roiManager("select", 2);
	roiManager("Measure");
	Ap=getResult("Area",1);
	//in micra
	Apm=Ap*r*r;
	
	if (flagBrown) {
		Apm=0;
	}
	
	// Ratio
	r1=Apm/Atm*100;
	
	run("Clear Results");
	if(File.exists(output+File.separator+"ResultsCuantificacionDesmina.xls"))
	{
		//if exists add and modify
		open(output+File.separator+"ResultsCuantificacionDesmina.xls");
		IJ.renameResults("Results");
	}
	i=nResults;
	setResult("Label", i, MyTitle); 
	setResult("Tissue area (micra²)",i,Atm);
	setResult("Stained area (micra²)",i,Apm);
	setResult("Ratio Astained/Atissue (%)",i,r1);			
	saveAs("Results", output+File.separator+"ResultsCuantificacionDesmina.xls");
	
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	setBatchMode(false);
	selectWindow(MyTitle);
	rename("orig");
	
	roiManager("Show None");
	roiManager("Select", 0);
	roiManager("Set Color", "yellow");
	roiManager("Set Line Width", 2);
	run("Flatten");
	roiManager("Show None");
	roiManager("Select", 2);
	roiManager("Set Color", "green");
	roiManager("Set Line Width", 1);
	run("Flatten");
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	rename(MyTitle_short+"_analyzed.jpg");
	
	close("orig");
	setTool("zoom");
	close("orig-1");

	
	if (InDir!="-") {
	close(); }
	
	//showMessage("Done!");

}

