macro "Scaffold Action Tool - Cf00T4d15Tio"
{	
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	run("Properties...", "channels=1 slices=1 frames=1 unit=pixel pixel_width=1 pixel_height=1 voxel_depth=1 frame=[0 sec] origin=0,0");
	run("Select All");
	//run("Duplicate...", "title=orig");
	//setBatchMode(true);
	roiManager("Reset");
	//rel micra/pixel 20x spot auto1
	//run("ReadXml ");
	//r=getResult("Ratio",0);//	r=0.72464;
	r=1;
	run("Clear Results");
	//start
	
	setTool("freehand");
	waitForUser("Please, select your area of interest and press Ok when ready");
	run("Crop");
	run("Add to Manager");
	setTool("zoom");
	
	// Colour Thresholding-------------
	run("Duplicate...", "title=positive");
	//Choose threshold and measure binary positive area
	if(isOpen("Threshold Color")) {
		
		//selectWindow("-R1-Threshold Color--");
		selectWindow("Threshold Color");
		
	}else{	
		//run("ColorT R1"); // old fiji versions 
		run("Color Threshold...");
	}
	waitForUser("Choose a threshold and press Ok when ready");
	
	//setBatchMode(true);
	//FINISH == mark trheshold button
	//then
	//run("Duplicate...", "title=positive");
	run("8-bit");
	//setAutoThreshold("Moments dark");
	setThreshold(83, 87);
	run("Convert to Mask");
	run("Median...", "radius=1");
	//filter small objects
	run("Analyze Particles...", "size=5-Infinity pixel circularity=0.00-1.00 show=Masks in_situ");
	//create selection
	run("Create Selection");
	roiManager("Add");
	selectWindow("positive");	
	close();
	selectWindow(MyTitle);
	setBatchMode(false);
	roiManager("Select All");
	roiManager("AND");
	roiManager("Add");
	
	//Ratio and results
	run("Set Measurements...", "area redirect=None decimal=5");
	run("Clear Results");	
	roiManager("Select", 0);
	roiManager("Measure");
	roiManager("Select", 2);
	roiManager("Measure");
	T=getResult("Area",0);
	Tm=parseInt(T)*r*r;
	P=getResult("Area",1);
	Pm=parseInt(P)*r*r;
					
	r1=(parseInt(P)/parseInt(T))*100;

	//clear rois and save image
	selectWindow(MyTitle);
	roiManager("Select", 0);
	roiManager("Delete");
	roiManager("Select", 0);
	roiManager("Delete");
	roiManager("Show All");
	run("From ROI Manager");
	run("Flatten");
	saveAs("Jpeg",output+"/Analyzed-"+MyTitle);
	close();
	close();
	
	run("Clear Results");	
	//RESULTS print and save image
	if(File.exists(output+"Total.xls"))
	{
		open(output+"Total.xls");
		i=nResults;
		setResult("Label", i, MyTitle); 
		setResult("Total Area (micra)",i,Tm);	
		setResult("Positive Area (micra)",i,Pm);
		setResult("Total Area",i,T);	
		setResult("Positive Area",i,P);
		setResult("% Ratio +/Atotal",i,r1);
		saveAs("Results", output+"Total.xls");
	}
	else{
		setResult("Label", 0, MyTitle); 
		setResult("Total Area (micra)",0,Tm);	
		setResult("Positive Area (micra)",0,Pm);
		setResult("Total Area",0,T);	
		setResult("Positive Area",0,P);
		setResult("% Ratio +/Atotal",0,r1);
		saveAs("Results", output+"Total.xls");
	}

	
	selectWindow("Results");
	//run("Close");

}