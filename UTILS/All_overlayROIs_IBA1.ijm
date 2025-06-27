

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
	
	// Save just brown in tissue
	roiManager("Deselect");
	roiManager("Select", 0);
	roiManager("Select", newArray(0,1));
	roiManager("AND");
	type=selectionType();
	if(type==-1) {
		makeRectangle(1, 1, 1, 1);
		flagBrown=true;
	}
	roiManager("Add");
	roiManager("Deselect");
	roiManager("Select", 1);
	roiManager("Delete");
	
	// DRAW:
	
	selectWindow(MyTitle);
	rename("orig");
	roiManager("Show None");
	roiManager("Select", 0);
	roiManager("Set Color", "yellow");
	roiManager("Set Line Width", 2);
	run("Flatten");
	roiManager("Show None");
	roiManager("Select", 1);
	roiManager("Set Color", "green");
	roiManager("Set Line Width", 2);
	run("Flatten");
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	rename(MyTitle_short+"_analyzed.jpg");
	
	close("*");
	
	setBatchMode(false);
	
	//showMessage("Done!");

}



