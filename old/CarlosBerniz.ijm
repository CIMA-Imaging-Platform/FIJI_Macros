// Possibility of deleting regions in ROI

var r=0.502, recWum=1000, recHum=1000, thTissue=248, thBrownCollag=170, thRed=90, thBrownMSA=170, minAR=3, minObjSize=20, minMSASize=20, maxMSASize=800, 
thBrownCD68=80, thBlueCD68=160, cellDiameterCD68=10, positPercent=30;	

macro "CarlosBerniz Action Tool 1 - C742T0b11CT7b09oTcb09lTeb09l"{
	
	run("Close All");
	//just one file
	name=File.openDialog("Select Collagen File");
	open(name);
	
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	OutDir = output+File.separator+"AnalyzedImages_Collagen";
	File.makeDirectory(OutDir);
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	//setBatchMode(true);
	run("Colors...", "foreground=white background=black selection=green");
	run("Set Measurements...", "area modal redirect=None decimal=2");
	
	//--MANUALLY PLACE THE RECTANGLE OF ANALYSIS
	
	recW = round(recWum/r);
	recH = round(recHum/r);
	setTool("rectangle");
	print("\\Clear");
	selectWindow("Log");
	print("---- COLLAGEN ANALYSIS ----");
	print("---- Processing image "+MyTitle+" ----");
	print("---------------------------------------------------------------------------");
	print("Click on the image on the top-left corner of the region you want to analyze");
	print("---------------------------------------------------------------------------");
	flags=-1;
	while (flags!=16) {
	  getCursorLoc(x, y, z, flags);  
	  wait(10);
	}
	//print(x);
	//print(y);
	//print(flags);
	makeRectangle(x, y, recW, recH);
	waitForUser("Move the area of analysis if necessary by dragging the rectangle and press OK when ready");
	run("Crop");
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_ROI_of_analysis.jpg");
	wait(100);
	rename("orig");
	
	
	//--DETECT TISSUE
	
	print("---- Segmenting tissue ----");
	setBatchMode(true);
	run("Select All");
	showStatus("Detecting tissue...");
	run("RGB to Luminance");
	rename("a");
	run("Subtract Background...", "rolling=200 light");
	run("Gaussian Blur...", "sigma=4");
	run("Threshold...");
		//thTissue=240;
	setThreshold(0, thTissue);
	run("Convert to Mask");
	run("Median...", "radius=12");
	run("Analyze Particles...", "size=10000-Infinity pixel show=Masks in_situ");
	run("Invert");
	wait(100);
	run("Analyze Particles...", "size=10000-Infinity pixel show=Masks in_situ");
	run("Invert");
	wait(100);
	run("Create Selection");
	run("Add to Manager");	// ROI0 --> whole tissue
	selectWindow("a");
	close();
	
	
	//BROWN--
	
	print("---- Segmenting collagen ----");
	selectWindow("orig");
	run("Select All");
	run("Colour Deconvolution", "vectors=[H&E DAB] hide");
	//selectWindow(MyTitle+"-(Colour_3)");
	selectWindow("orig-(Colour_2)");
	close();
	selectWindow("orig-(Colour_1)");
	close();
	selectWindow("orig-(Colour_3)");
	
	run("Threshold...");
	setAutoThreshold("Default");
		//thBrownCollag=170;
	setThreshold(0, thBrownCollag);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=1");
	run("Analyze Particles...", "size="+minObjSize+"-Infinity show=Masks in_situ");
	roiManager("Show None");
	run("Create Selection");
	run("Add to Manager");	// ROI1 --> Whole brown
	close();
	
	// Save just brown in tissue
	roiManager("Deselect");
	roiManager("Select", 0);
	roiManager("Select", newArray(0,1));
	roiManager("AND");
	roiManager("Add");
	roiManager("Deselect");
	roiManager("Select", 1);
	roiManager("Delete");
	
	// RESULTS--
	
	run("Clear Results");
	selectWindow("orig");	
	run("Set Measurements...", "area redirect=None decimal=2");
	
	// Tissue
	roiManager("select", 0);
	roiManager("Measure");
	At=getResult("Area",0);
	//in micra
	Atm=At*r*r;
	
	// Staining
	roiManager("select", 1);
	roiManager("Measure");
	Ap=getResult("Area",1);
	//in micra
	Apm=Ap*r*r;
	
	// Ratio
	r1=Apm/Atm*100;
	
	run("Clear Results");
	if(File.exists(output+File.separator+"Quantification_Collagen.xls"))
	{	
		//if exists add and modify
		open(output+File.separator+"Quantification_Collagen.xls");
		IJ.renameResults("Results");
	}
	i=nResults;
	setResult("Label", i, MyTitle); 
	setResult("Tissue area (um2)",i,Atm);
	setResult("Collagen area (um2)",i,Apm);
	setResult("Ratio Acollagen/Atissue (%)",i,r1);			
	saveAs("Results", output+File.separator+"Quantification_Collagen.xls");
		
	
	selectWindow("orig");
	setBatchMode(false);
	roiManager("Show None");
	roiManager("Select", 0);
	roiManager("Set Color", "red");
	roiManager("Set Line Width", 2);
	run("Flatten");
	roiManager("Show None");
	roiManager("Select", 1);
	roiManager("Set Color", "green");
	roiManager("Set Line Width", 2);
	run("Flatten");
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	rename(MyTitle_short+"_analyzed.jpg");
	
	selectWindow("orig");
	close();
	selectWindow("orig-1");
	close();
	
	setTool("zoom");
	
	showMessage("Done!");

}


macro "CarlosBerniz Action Tool 2 - Cf22T1b11RTab11S"{
	
	run("Close All");
	//just one file
	name=File.openDialog("Select Sirius Red File");
	open(name);
	
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	OutDir = output+File.separator+"AnalyzedImages_SiriusRed";
	File.makeDirectory(OutDir);
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	//setBatchMode(true);
	run("Colors...", "foreground=white background=black selection=green");
	run("Set Measurements...", "area modal redirect=None decimal=2");
	
	//--MANUALLY PLACE THE RECTANGLE OF ANALYSIS
	
	recW = round(recWum/r);
	recH = round(recHum/r);
	setTool("rectangle");
	print("\\Clear");
	selectWindow("Log");
	print("---- SIRIUS RED ANALYSIS ----");
	print("---- Processing image "+MyTitle+" ----");
	print("---------------------------------------------------------------------------");
	print("Click on the image on the top-left corner of the region you want to analyze");
	print("---------------------------------------------------------------------------");
	flags=-1;
	while (flags!=16) {
	  getCursorLoc(x, y, z, flags);  
	  wait(10);
	}
	//print(x);
	//print(y);
	//print(flags);
	makeRectangle(x, y, recW, recH);
	waitForUser("Move the area of analysis if necessary by dragging the rectangle and press OK when ready");
	run("Crop");
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_ROI_of_analysis.jpg");
	wait(100);
	rename("orig");
	
	
	//--DETECT TISSUE
	
	print("---- Segmenting tissue ----");
	setBatchMode(true);
	run("Select All");
	showStatus("Detecting tissue...");
	run("RGB to Luminance");
	rename("a");
	run("Subtract Background...", "rolling=200 light");
	run("Gaussian Blur...", "sigma=4");
	run("Threshold...");
		//thTissue=240;
	setThreshold(0, thTissue);
	run("Convert to Mask");
	run("Median...", "radius=12");
	run("Analyze Particles...", "size=10000-Infinity pixel show=Masks in_situ");
	run("Invert");
	wait(100);
	run("Analyze Particles...", "size=10000-Infinity pixel show=Masks in_situ");
	run("Invert");
	wait(100);
	run("Create Selection");
	run("Add to Manager");	// ROI0 --> whole tissue
	selectWindow("a");
	close();
	
	
	//--SIRIUS RED
	
	print("---- Segmenting sirius red ----");
	selectWindow("orig");
	run("Select All");
	run("Duplicate...", "title=positive");
	selectWindow("positive");
	
	// Color Thresholder 1.48v
	// Autogenerated macro, single images only!
	min=newArray(3);
	max=newArray(3);
	filter=newArray(3);
	a=getTitle();
	run("HSB Stack");
	run("Convert Stack to Images");
	selectWindow("Hue");
	rename("0");
	selectWindow("Saturation");
	rename("1");
	selectWindow("Brightness");
	rename("2");
	min[0]=12;
	max[0]=152;
	filter[0]="stop";
	min[1]=thRed;
	max[1]=255;
	filter[1]="pass";
	min[2]=0;
	max[2]=255;
	filter[2]="pass";
	for (i=0;i<3;i++){
	  selectWindow(""+i);
	  setThreshold(min[i], max[i]);
	  run("Convert to Mask");
	  if (filter[i]=="stop")  run("Invert");
	}
	imageCalculator("AND create", "0","1");
	imageCalculator("AND create", "Result of 0","2");
	for (i=0;i<3;i++){
	  selectWindow(""+i);
	  close();
	}
	selectWindow("Result of 0");
	close();
	selectWindow("Result of Result of 0");
	rename(a);
	// Colour Thresholding-------------
	
	run("Median...", "radius=1");
	run("Analyze Particles...", "size="+minObjSize+"-Infinity show=Masks in_situ");
	roiManager("Show None");
	run("Create Selection");
	run("Add to Manager");	// ROI1 --> Whole brown
	close();
	
	// Save just red in tissue
	roiManager("Deselect");
	roiManager("Select", 0);
	roiManager("Select", newArray(0,1));
	roiManager("AND");
	roiManager("Add");
	roiManager("Deselect");
	roiManager("Select", 1);
	roiManager("Delete");
	
	// RESULTS--
	
	run("Clear Results");
	selectWindow("orig");	
	run("Set Measurements...", "area redirect=None decimal=2");
	
	// Tissue
	roiManager("select", 0);
	roiManager("Measure");
	At=getResult("Area",0);
	//in micra
	Atm=At*r*r;
	
	// Staining
	roiManager("select", 1);
	roiManager("Measure");
	Ap=getResult("Area",1);
	//in micra
	Apm=Ap*r*r;
	
	// Ratio
	r1=Apm/Atm*100;
	
	run("Clear Results");
	if(File.exists(output+File.separator+"Quantification_SiriusRed.xls"))
	{	
		//if exists add and modify
		open(output+File.separator+"Quantification_SiriusRed.xls");
		IJ.renameResults("Results");
	}
	i=nResults;
	setResult("Label", i, MyTitle); 
	setResult("Tissue area (um2)",i,Atm);
	setResult("Sirius Red area (um2)",i,Apm);
	setResult("Ratio Ared/Atissue (%)",i,r1);			
	saveAs("Results", output+File.separator+"Quantification_SiriusRed.xls");
		
	
	selectWindow("orig");
	setBatchMode(false);
	roiManager("Show None");
	roiManager("Select", 0);
	roiManager("Set Color", "red");
	roiManager("Set Line Width", 2);
	run("Flatten");
	roiManager("Show None");
	roiManager("Select", 1);
	roiManager("Set Color", "green");
	roiManager("Set Line Width", 2);
	run("Flatten");
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	rename(MyTitle_short+"_analyzed.jpg");
	
	selectWindow("orig");
	close();
	selectWindow("orig-1");
	close();
	
	setTool("zoom");
	
	showMessage("Done!");

}


macro "CarlosBerniz Action Tool 3 - C742T0b11MT8b11STfb11A"{
	
	run("Close All");
	//just one file
	name=File.openDialog("Select MSA File");
	open(name);
	
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	OutDir = output+File.separator+"AnalyzedImages_MSA";
	File.makeDirectory(OutDir);
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	//setBatchMode(true);
	run("Colors...", "foreground=white background=black selection=green");
	run("Set Measurements...", "area modal redirect=None decimal=2");
	
	//--MANUALLY PLACE THE RECTANGLE OF ANALYSIS
	
	recW = round(recWum/r);
	recH = round(recHum/r);
	setTool("rectangle");
	print("\\Clear");
	selectWindow("Log");
	print("---- MSA ANALYSIS ----");
	print("---- Processing image "+MyTitle+" ----");
	print("---------------------------------------------------------------------------");
	print("Click on the image on the top-left corner of the region you want to analyze");
	print("---------------------------------------------------------------------------");
	flags=-1;
	while (flags!=16) {
	  getCursorLoc(x, y, z, flags);  
	  wait(10);
	}
	//print(x);
	//print(y);
	//print(flags);
	makeRectangle(x, y, recW, recH);
	waitForUser("Move the area of analysis if necessary by dragging the rectangle and press OK when ready");
	run("Crop");
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_ROI_of_analysis.jpg");
	wait(100);
	rename("orig");
	
	
	//--DETECT TISSUE
	
	print("---- Segmenting tissue ----");
	setBatchMode(true);
	run("Select All");
	showStatus("Detecting tissue...");
	run("RGB to Luminance");
	rename("a");
	run("Subtract Background...", "rolling=200 light");
	run("Gaussian Blur...", "sigma=4");
	run("Threshold...");
		//thTissue=248;
	setThreshold(0, thTissue);
	run("Convert to Mask");
	run("Median...", "radius=12");
	run("Analyze Particles...", "size=10000-Infinity pixel show=Masks in_situ");
	run("Invert");
	wait(100);
	run("Analyze Particles...", "size=10000-Infinity pixel show=Masks in_situ");
	run("Invert");
	wait(100);
	run("Create Selection");
	run("Add to Manager");	// ROI0 --> whole tissue
	selectWindow("a");
	//close();
	setBatchMode("show");
	
	run("Clear Results");
	selectWindow("orig");	
	run("Set Measurements...", "area redirect=None decimal=2");
	roiManager("select", 0);
	roiManager("Measure");
	At=getResult("Area",0);
	//in micra
	Atm=At*r*r;
	run("Clear Results");
	
	
	//BROWN--
	
	print("---- Detecting MSA ----");
	selectWindow("orig");
	run("Select All");
	run("Colour Deconvolution", "vectors=[H&E DAB] hide");
	//selectWindow(MyTitle+"-(Colour_3)");
	selectWindow("orig-(Colour_2)");
	close();
	selectWindow("orig-(Colour_1)");
	close();
	selectWindow("orig-(Colour_3)");
	rename("brown");
	
	
	run("Mean...", "radius=2");
	run("Find Maxima...", "prominence=10 light output=[Single Points]");
	rename("brownMaxima");
	
	selectWindow("brown");
	  //thBrownMSA=150;
	setThreshold(0, thBrownMSA);
	//waitForUser("Select threshold manually and press OK when ready");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	//run("Fill Holes");
	run("Median...", "radius=1");
	//run("Watershed");
	//run("Analyze Particles...", "size=20-1000 pixel show=Masks in_situ");
	run("Analyze Particles...", "size="+minMSASize+"-"+maxMSASize+" pixel show=Masks in_situ");
	roiManager("Select", 0);	
	run("Clear Outside");
	run("Select All");
	
	run("Duplicate...", "title=cellEdges");
	run("Find Edges");
	
	// MARKER-CONTROLLED WATERSHED
	run("Marker-controlled Watershed", "input=cellEdges marker=brownMaxima mask=brown binary calculate use");
	
	selectWindow("cellEdges-watershed");
	run("8-bit");
	setThreshold(1, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	
	selectWindow("cellEdges");
	close();
	selectWindow("brown");
	close();
	selectWindow("brownMaxima");
	close();
	selectWindow("cellEdges-watershed");
	rename("brown");
	
	//--Filter by aspect ratio to keep only elongated cells:
	run("Set Measurements...", "area shape redirect=None decimal=2");
	run("Analyze Particles...", "size="+minMSASize+"-"+maxMSASize+" show=Masks display clear add in_situ");
	roiManager("Show None");
	selectWindow("brown");
	run("Select All");
	setBackgroundColor(255, 255, 255);
	run("Clear", "slice");
	wait(100);
	selectWindow("brown");	// fill in cellMask only nuclei positive por RNA
	n=roiManager("Count");
	for (i=0; i<n; i++)
	{
		ARi=getResult("AR",i);	                         
		if (ARi>minAR) {	//if aspect ratio is big enough, keep that cell
		//if (ARi>3) {	//if aspect ratio is big enough, keep that cell
	  		roiManager("Select", i);
			setForegroundColor(0, 0, 0);
			run("Fill", "slice");
	  	}  	 	
	}
	run("Select None");
	roiManager("Reset");
	
	
	
	// transform selection to individual points
	run("Find Maxima...", "prominence=10 light output=[Point Selection]");
	setTool("multipoint");
	run("Point Tool...", "type=Hybrid color=Green size=Medium counter=0");
	selectWindow("orig");
	run("Restore Selection");
	setBatchMode(false);
	selectWindow("a");
	selectWindow("orig");
	waitForUser("Automatic detection of MSA+ cells finished. Add (Click) or Delete (CTRL+ALT+Click) MSA+ cells if needed and press OK when ready");
	run("Create Mask");
	rename("MaskMSA");
	run("Find Maxima...", "prominence=10 light output=Count");
	selectWindow("MaskMSA");
	close();
	
	
	// Get number of monocytes
	i=nResults;
	nMSA=getResult("Count",i-1);
	
	// Write results:
	run("Clear Results");
	if(File.exists(output+File.separator+"Quantification_MSA.xls"))
	{	
		//if exists add and modify
		open(output+File.separator+"Quantification_MSA.xls");
		IJ.renameResults("Results");
	}
	i=nResults;
	setResult("Label", i, MyTitle); 
	setResult("# MSA+ cells", i, nMSA); 
	setResult("Tissue Area (um2)", i, Atm); 
	saveAs("Results", output+File.separator+"Quantification_MSA.xls");
	
	
	// DRAW
	
	selectWindow("orig");
	run("Point Tool...", "type=Hybrid color=Green size=Medium counter=0");
	run("Add Selection...");
	run("Flatten");
	wait(200);
	
	selectWindow("a");
	run("Create Selection");
	run("Add to Manager");	// ROI0 --> whole tissue
	selectWindow("a");
	close();
	
	selectWindow("orig-1");
	roiManager("Show None");
	roiManager("Select", 0);
	roiManager("Set Color", "red");
	roiManager("Set Line Width", 2);
	run("Flatten");
	wait(200);
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	rename(MyTitle_short+"_analyzed.jpg");
	
	selectWindow("orig");
	close();
	selectWindow("orig-1");
	close();
	
	setTool("zoom");
	
	showMessage("Done!");

}


macro "CarlosBerniz Action Tool 4 - C742T0b08CT5b08DTbb086Tfb088"{
	
	run("Close All");
	//just one file
	name=File.openDialog("Select CD68 File");
	open(name);
	
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	OutDir = output+File.separator+"AnalyzedImages_CD68";
	File.makeDirectory(OutDir);
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	//setBatchMode(true);
	run("Colors...", "foreground=white background=black selection=green");
	run("Set Measurements...", "area mean modal redirect=None decimal=2");
	
	cellRadiusPxCD68 = round(cellDiameterCD68/(2*r));
	
	//--MANUALLY PLACE THE RECTANGLE OF ANALYSIS
	
	recW = round(recWum/r);
	recH = round(recHum/r);
	setTool("rectangle");
	print("\\Clear");
	selectWindow("Log");
	print("---- CD68 ANALYSIS ----");
	print("---- Processing image "+MyTitle+" ----");
	print("---------------------------------------------------------------------------");
	print("Click on the image on the top-left corner of the region you want to analyze");
	print("---------------------------------------------------------------------------");
	flags=-1;
	while (flags!=16) {
	  getCursorLoc(x, y, z, flags);  
	  wait(10);
	}
	//print(x);
	//print(y);
	//print(flags);
	makeRectangle(x, y, recW, recH);
	waitForUser("Move the area of analysis if necessary by dragging the rectangle and press OK when ready");
	run("Crop");
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_ROI_of_analysis.jpg");
	wait(100);
	rename("orig");
	
	
	//--DETECT TISSUE
	
	print("---- Segmenting tissue ----");
	setBatchMode(true);
	run("Select All");
	showStatus("Detecting tissue...");
	run("RGB to Luminance");
	rename("a");
	run("Subtract Background...", "rolling=200 light");
	run("Gaussian Blur...", "sigma=4");
	run("Threshold...");
		//thTissue=240;
	setThreshold(0, thTissue);
	run("Convert to Mask");
	run("Median...", "radius=12");
	run("Analyze Particles...", "size=10000-Infinity pixel show=Masks in_situ");
	run("Invert");
	wait(100);
	run("Analyze Particles...", "size=10000-Infinity pixel show=Masks in_situ");
	run("Invert");
	wait(100);
	run("Create Selection");
	run("Add to Manager");	// ROI0 --> whole tissue
	selectWindow("a");
	close();
	
	run("Clear Results");
	selectWindow("orig");	
	run("Set Measurements...", "area mean redirect=None decimal=2");
	roiManager("select", 0);
	roiManager("Measure");
	At=getResult("Area",0);
	//in micra
	Atm=At*r*r;
	run("Clear Results");
	
	selectWindow("orig");
	setBatchMode(false);
	roiManager("Show None");
	roiManager("Select", 0);
	roiManager("Set Color", "red");
	roiManager("Set Line Width", 2);
	run("Flatten");
	setBatchMode(true);
	
	//BROWN--
	
	print("---- Segmenting CD68 ----");
	selectWindow("orig");
	run("Select All");
	run("Colour Deconvolution", "vectors=[H&E DAB] hide");
	//selectWindow(MyTitle+"-(Colour_3)");
	selectWindow("orig-(Colour_2)");
	close();
	selectWindow("orig-(Colour_1)");
	rename("blue");
	selectWindow("orig-(Colour_3)");
	rename("brown");
	
	
	// DETECT BROWN STAINING
	selectWindow("brown");
	run("Threshold...");
	setAutoThreshold("Huang");
	  //thBrownCD68=120;
	setThreshold(0, thBrownCD68);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Close-");
	//run("Fill Holes");
	run("Median...", "radius=1");
	run("Analyze Particles...", "size=20-Infinity show=Masks in_situ");
	roiManager("Select", 0);
	setBackgroundColor(255, 255, 255);
	run("Clear Outside");
	run("Select All");
	
	
	// SEGMENT BLUE CELLS
	selectWindow("blue");
	run("Mean...", "radius=2");
	
	// transform selection to individual points
	run("Find Maxima...", "prominence=20 light output=[Single Points]");
	rename("blueMaxima");
	
	selectWindow("blue");
	run("Threshold...");
	setAutoThreshold("Default");
	setAutoThreshold("Huang");
	   //thBlueCD68 = 140;
	setThreshold(0, thBlueCD68);
	//waitForUser("Adjust threshold for cell segmentation and press OK when ready");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Fill Holes");
	run("Median...", "radius=2");
	//run("Watershed");
	roiManager("Select", 0);
	setBackgroundColor(255, 255, 255);
	run("Clear Outside");
	run("Select All");
	run("Analyze Particles...", "size=10-Infinity pixel show=Masks in_situ");
	//run("Analyze Particles...", "size="+minSize+"-"+maxSize+" pixel show=Masks in_situ");
	
	selectWindow("blue");
	run("Create Selection");
	
	selectWindow("blueMaxima");
	run("Select None");
	run("Restore Selection");
	setBackgroundColor(255, 255, 255);
	run("Clear Outside");
	run("Select None");
	
	// Generate cellMask by enlarging the mask of nuclei
	selectWindow("blueMaxima");
	run("Duplicate...", "title=cellMask");
	run("Create Selection");
		// cellRadiusPxCD68 = 10;
	run("Enlarge...", "enlarge="+cellRadiusPxCD68);
	setForegroundColor(0, 0, 0);
	run("Fill", "slice");
	
	selectWindow("cellMask");
	run("Select All");
	run("Duplicate...", "title=cellEdges");
	run("Find Edges");
	
	// MARKER-CONTROLLED WATERSHED
	run("Marker-controlled Watershed", "input=cellEdges marker=blueMaxima mask=cellMask binary calculate use");
	
	selectWindow("cellEdges-watershed");
	run("8-bit");
	setThreshold(1, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Analyze Particles...", "size=0-Infinity show=Masks add in_situ");
	roiManager("Show None");
	
	selectWindow("cellEdges");
	close();
	selectWindow("cellMask");
	close();
	selectWindow("blueMaxima");
	close();
	selectWindow("cellEdges-watershed");
	rename("cellMask");
	selectWindow("blue");
	close();
	
	n=roiManager("Count");
	nCells=n-1;
	
	
	// CHECK ONE BY ONE WHICH CELLS CONTAIN CD3
	
	//--Keep only cells with a certain % of area occupied by brown signal:
	cellAreapx = PI*pow(cellRadiusPxCD68, 2);
	minSize = round(positPercent*cellAreapx/100);
	selectWindow("cellMask");
	run("Create Selection");
	selectWindow("brown");
	run("Restore Selection");
	setBackgroundColor(255, 255, 255);
	run("Clear Outside");
	run("Select All");
	run("Analyze Particles...", "size="+minSize+"-Infinity show=Masks in_situ");
	
	selectWindow("cellMask");
	run("Duplicate...", "title=positCellMask");
	run("Select All");
	setBackgroundColor(255, 255, 255);
	run("Clear", "slice");
	wait(100);
	
	run("Clear Results");
	selectWindow("brown");
	run("Select None");
	roiManager("Deselect");
	roiManager("Measure");
	selectWindow("positCellMask");	// fill in cellMask only nuclei positive por RNA
	for (i=1; i<n; i++)
	{
		Ii=getResult("Mean",i);	
		if (Ii!=0) {	//if there is RNA spot, negative cell --> delete ROI
	  		roiManager("Select", i);
			run("Fill", "slice");
	  	}  	 	
	}
	run("Select None");
	roiManager("Reset");
	
	run("Clear Results");
	run("Analyze Particles...", "size=0-Infinity show=Masks display clear in_situ");
	nCD68 = nResults;
	run("Create Selection");
	roiManager("Add");
	close();
	
	//--Cell density:
	dCD68 = nCD68/Atm*1000000;	// in cells per mm2
	
	
	
	run("Clear Results");
	if(File.exists(output+File.separator+"Quantification_CD68.xls"))
	{	
		//if exists add and modify
		open(output+File.separator+"Quantification_CD68.xls");
		IJ.renameResults("Results");
	}
	i=nResults;
	setResult("Label", i, MyTitle); 
	setResult("Tissue area (um2)",i,Atm);
	setResult("# CD68+ cells",i,nCD68);
	setResult("Density of CD68+ cells (#cells/mm2)",i,dCD68);
	saveAs("Results", output+File.separator+"Quantification_CD68.xls");
		
	
	selectWindow("orig-1");
	setBatchMode(false);
	roiManager("Show None");
	roiManager("Select", 0);
	roiManager("Set Color", "green");
	roiManager("Set Line Width", 1);
	run("Flatten");
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	rename(MyTitle_short+"_analyzed.jpg");
	
	selectWindow("orig");
	close();
	selectWindow("orig-1");
	close();
	
	setTool("zoom");
	
	showMessage("Done!");

}



macro "CarlosBerniz Action Tool 1 Options" {
     Dialog.create("Parameters");

     Dialog.addMessage("Choose parameters")
     Dialog.addNumber("micra/px ratio", r);
     Dialog.addNumber("Rectangle width for analysis (um)", recWum);
     Dialog.addNumber("Rectangle height for analysis (um)", recHum);
     Dialog.addNumber("Threshold for tissue detection", thTissue); 
     Dialog.addNumber("Threshold for collagen detection", thBrownCollag);  
     Dialog.show();
     
     r= Dialog.getNumber();
     recWum= Dialog.getNumber();
     recHum= Dialog.getNumber();
     thTissue= Dialog.getNumber();
     thBrownCollag= Dialog.getNumber();    
     
        
}

macro "CarlosBerniz Action Tool 2 Options" {
     Dialog.create("Parameters");

     Dialog.addMessage("Choose parameters")
     Dialog.addNumber("micra/px ratio", r);
     Dialog.addNumber("Rectangle width for analysis (um)", recWum);
     Dialog.addNumber("Rectangle height for analysis (um)", recHum);
     Dialog.addNumber("Threshold for tissue detection", thTissue); 
     Dialog.addNumber("Threshold for sirius red detection", thRed);  
     Dialog.show();
     
     r= Dialog.getNumber();
     recWum= Dialog.getNumber();
     recHum= Dialog.getNumber();
     thTissue= Dialog.getNumber();
     thRed= Dialog.getNumber();         
        
}

macro "CarlosBerniz Action Tool 3 Options" {
     Dialog.create("Parameters");

     Dialog.addMessage("Choose parameters")
     Dialog.addNumber("micra/px ratio", r);
     Dialog.addNumber("Rectangle width for analysis (um)", recWum);
     Dialog.addNumber("Rectangle height for analysis (um)", recHum);
     Dialog.addNumber("Threshold for tissue detection", thTissue); 
     Dialog.addNumber("Threshold for MSA detection", thBrownMSA); 
     Dialog.addNumber("Minimum elongation for MSA+ cells", minAR); 
     Dialog.addNumber("Minimum size for MSA+ cells (px)", minMSASize); 
     Dialog.addNumber("Maximum size for MSA+ cells (px)", maxMSASize);  
     Dialog.show();
     
     r= Dialog.getNumber();
     recWum= Dialog.getNumber();
     recHum= Dialog.getNumber();
     thTissue= Dialog.getNumber();
     thBrownMSA= Dialog.getNumber();    
     minAR= Dialog.getNumber();    
     minMSASize= Dialog.getNumber();    
     maxMSASize= Dialog.getNumber();    
        
}

macro "CarlosBerniz Action Tool 4 Options" {
     Dialog.create("Parameters");

     Dialog.addMessage("Choose parameters")
     Dialog.addNumber("micra/px ratio", r);
     Dialog.addNumber("Rectangle width for analysis (um)", recWum);
     Dialog.addNumber("Rectangle height for analysis (um)", recHum);
     Dialog.addNumber("Threshold for tissue detection", thTissue); 
     Dialog.addNumber("Threshold for nuclei detection in HE", thBlueCD68);
     Dialog.addNumber("Cell diameter (microns)", cellDiameterCD68);	
     Dialog.addNumber("Threshold for CD68 detection", thBrownCD68); 
     Dialog.addNumber("Min CD68+ area per cell (%)", positPercent);      
     
     Dialog.show();
     
     r= Dialog.getNumber();
     recWum= Dialog.getNumber();
     recHum= Dialog.getNumber();
     thTissue= Dialog.getNumber();
     thBlueCD68= Dialog.getNumber(); 
     cellDiameterCD68= Dialog.getNumber();
     thBrownCD68= Dialog.getNumber();  
     positPercent= Dialog.getNumber();           
                
        
}