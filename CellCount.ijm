// changelog Sept2018
// Automatic positive cell detection when they have blue+red and NO green

var ch=1, th=20, minParticleSize=20, r=0.502, prominence=5, circularity=0.8;

macro "CellCountAuto Action Tool - C0f0T4d14C"{	
	/*
	ch=1;
	th=20;
	minParticleSize=100;
	r=0.502;
	prominence=5;
	circularity=0.8;
	*/
	
	//Initialize conditions
	roiManager("Reset");
	run("Clear Results");
	run("Colors...", "foreground=black background=white selection=yellow");
	run("Set Measurements...", "area redirect=None decimal=2");
	run("Set Scale...", "distance=1 known="+r+" unit=micron");

	//Current Image Title 
	MyTitle=getTitle();
	output=getInfo("image.directory");
	OutDir = output+File.separator+"AnalyzedImages";
	//Make Results directory
	File.makeDirectory(OutDir);
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	showStatus("Analyzing"+MyTitle);

	
	// IMAGE CHANNELS ADJUSTMENT
	run("Duplicate...", "title=orig duplicate");
	selectWindow("orig");
	run("Split Channels");
	
	//  channel to Quantify
	selectWindow("C"+ch+"-orig");
	run("Z Project...", "projection=[Max Intensity]");
	selectWindow("MAX_C"+ch+"-orig");
	rename("MaxZProjection");
	close("C*");
	
	/// AUTOMATIC SEGMENTATION BASED ON SELECTED CHANNEL
	
	selectWindow("MaxZProjection");		
	run("Select All");
	run("Subtract Background...", "rolling=100");
	run("Threshold...");
	setAutoThreshold("Default dark no-reset");
	//Let the user choose the threshold
	waitForUser("Select Threshold for Nucleus Segmentation");
	getThreshold(lower, upper);
	setThreshold(lower, upper);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=2");
	run("Fill Holes");
	run("Median...", "radius=2");
	// EDM + Watershed
	run("Duplicate...", "title=SegmentCells");
	run("Distance Map");
	rename("EDM");
	//prominence=5;
	run("Find Maxima...", "prominence="+prominence+" light output=[Segmented Particles]");
	run("Invert");
	selectWindow("MaxZProjection");
	run("Invert");
	imageCalculator("OR", "MaxZProjection","EDM Segmented");
	selectWindow("MaxZProjection");
	run("Invert");
	//minParticleSize=20;
	//Size & Circularity Filter: Show Results 
	run("Analyze Particles...", "size="+minParticleSize+"-Infinity pixel circularity="+circularity+"-1.00 show=Masks display exclude clear add in_situ");		
	nCells=nResults;
	//Compute Mean Std of Area Column
	run("Summarize");
	
	averageSize=getResult("Area",nCells);
	stdSize=getResult("Area",nCells+1);
	//Array.print(averageSize,stdSize);

	close("M*");close("E*");
	

	// Write results:
	run("Clear Results");
	if(File.exists(output+File.separator+"Total.xls"))
	{
		//if exists add and modify
		open(output+File.separator+"Total.xls");
		i=nResults;
		setResult("Label", i, MyTitle); 	
		setResult("# cells", i, nCells); 
		setResult("AverageSize [micras^2]", i, averageSize);
		setResult("stdSize [micras^2]", i, stdSize);
		saveAs("Results", output+File.separator+"Total.xls");
		
	}
	else
	{
		setResult("Label", 0, MyTitle); 
		setResult("# cells", 0, nCells); 
		setResult("AverageSize [micras^2]", 0, averageSize);
		setResult("stdSize [micras^2]", 0, stdSize);
		saveAs("Results", output+File.separator+"QuantifiedImages.xls");
		
	}
	
	selectWindow(MyTitle);
	run("Z Project...", "projection=[Max Intensity]");
	run("Split Channels");
	run("Merge Channels...", "c1=C1-MAX_"+MyTitle+" c3=C2-MAX_"+MyTitle);
	roiManager("Set Color", "yellow");
	roiManager("Set Line Width", 1);
	roiManager("Show All");
	run("Flatten");
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_nCells.tif");
 	close("\\Others");
	
		
}
	
	
	macro "CellCountAuto Action Tool Options" {
		Dialog.create("Parameters");
		
		Dialog.addMessage("Choose parameters");
		Dialog.addNumber("Objective Scale", r);
		Dialog.addNumber("Channel to Quantify", ch);
	    Dialog.addNumber("Min particle size (px)", minParticleSize);
	    Dialog.addNumber("Circularity Filter)", circularity);	
		Dialog.show();
		r= Dialog.getNumber();
		ch= Dialog.getNumber();
		minParticleSize= Dialog.getNumber(); 
		circularity= Dialog.getNumber(); 			
	}
