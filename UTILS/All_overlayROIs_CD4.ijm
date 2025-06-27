

macro "overlay Action Tool 1 - Cf00T2d15IT6d10m"{
	
	//just one file
	name=File.openDialog("Select image file");
	//print(name);
	print("Processing "+name);
	
	//setBatchMode(true);
	overlay("-","-",name);
	setBatchMode(false);
	showMessage("DONE");

}

macro "overlay Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	InDir=getDirectory("Choose images directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	for (j=0; j<L; j++)
	{
		if (endsWith(list[j],".tif") || endsWith(list[j],".jpg")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print("Processing "+name);
			//setBatchMode(true);
			overlay(InDir,InDir,list[j]);
			setBatchMode(false);
			}
	}
	
	showMessage("DONE");

}


function overlay(output,InDir,name)
{

	run("Close All");
	roiManager("Reset");
	run("Clear Results");
	
	run("Colors...", "foreground=black background=white selection=green");
	run("Set Measurements...", "area mean area_fraction redirect=None decimal=2");
		
	setBatchMode(true);
	run("Collect Garbage");
	run("Memory & Threads...", "maximum=970967 parallel=16 run");
	
	
	if (InDir=="-") {open(name);}
	else {
		if (isOpen(InDir+name)) {}
		else { open(InDir+name); }
	}
	
	
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	roiManager("Open", output+File.separator+"ROIs"+File.separator+MyTitle_short+"_Preprocessed_ROIs.zip");
	roiManager("select", 1);
	run("Create Mask");
	wait(100);
		
	n=roiManager("count");
	cells=Array.slice(Array.getSequence(n),2,n);
	
	// CHECK ONE BY ONE WHICH CELLS CONTAIN CD8
	selectWindow("Mask");
	run("Select None");
	run("Duplicate...", "title=positCellMask");
	run("Select All");
	setForegroundColor(255,255,255);
	run("Fill");

	
	run("Clear Results");
	selectWindow("Mask");
	run("Select None");
	roiManager("Deselect");
	roiManager("Measure");
	selectWindow("positCellMask");	// fill in cellMask only cells positive for CD8
	minBrownPerc=5;
	setForegroundColor(0,0,0);
	for (i=2; i<n; i++)
	{
		Aperc=getResult("%Area",i);	
		if (Aperc>=minBrownPerc) {	
	  		roiManager("Select", i);
	   		run("Fill", "slice");
	  	}  	 	
	}
	

	// DRAW:
	
	selectWindow(MyTitle);
	rename("orig");
	roiManager("select", 0);
	roiManager("Set Color", "yellow");
	roiManager("Set Line Width", 1);
	run("Flatten");
	wait(200);
	
	selectWindow("positCellMask");
	run("Select None");
	run("Create Selection");
	selectWindow("orig-1");
	run("Restore Selection");
	roiManager("Set Color", "green");
	roiManager("Set Line Width", 1);
	run("Flatten");
	wait(200);
	
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	rename(MyTitle_short+"_analyzed.jpg");
	
	close("*");
	
	setBatchMode(false);
	
	//showMessage("Done!");

}



