

macro "Foci_integrated Action Tool 1- Cf00T4d15Fio" 
{

	roiManager("Reset");
	getDimensions(width, height, channels, slices, frames);
	run("Colors...", "foreground=black background=white selection=green");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	//wait for user to select area in green channel
	setTool("freehand");
	Stack.setSlice(floor(slices/2));	// N channels, slices are counted N times each by ImageJ
	Stack.setDisplayMode("composite");	
	Stack.setChannel(1);
	run("Green");
	Stack.setChannel(2);
	run("Blue");


	// Create stack with only the red channel and cropped to selection:
	run("Duplicate...", "title=red duplicate channels=1 slices=1-"+slices);
	run("Add to Manager");
	run("Select All");		
	run("8-bit");

	run("Subtract Background...", "rolling=20 stack");

	
	
	// MEASURE INTENSITIES--
	
	selectWindow("red");
	// Process slices
	getDimensions(width, height, channels, slices, frames);
	Iavg = newArray(slices);
	Iavg_tot = 0;
	Imax = newArray(slices);
	Imax_tot = 0;
	for (z=0; z<slices; z++)
	{
		run("Clear Results");
		run("Set Measurements...", "mean min display redirect=None decimal=2");
		setSlice(z+1);
		roiManager("select", 0);
		roiManager("Measure");
		// Average intensity:		
		Iz = getResult("Mean",0);
		Iavg[z] = Iz;
		Iavg_tot = Iavg_tot+Iavg[z];
		// Max intensity:
		Iz_max = getResult("Max",0);
		Imax[z] = Iz_max;
		if (Iz_max>Imax_tot) {
			Imax_tot = Iz_max;
		}			
	}
	Iavg_tot = Iavg_tot/slices;


	
	// CALCULATE FOCI--
	
	//MyTitle=getTitle();

	selectWindow("red");
	run("Subtract Background...", "rolling=10 stack");
	getDimensions(width, height, channels, slices, frames);
	run("Duplicate...", "title=a duplicate range=1-"+slices);
	setTool("zoom");
	//MyTitle2=getTitle();
	//run("8-bit");
	//run("Subtract Background...", "rolling=10 stack");
	setSlice(slices/2);
	//run("3D Objects Counter", "threshold=5 slice=12 min.=2 max.=897000 objects surfaces centroids");
	setAutoThreshold("Default dark");
	getThreshold(lower,upper);
	print(lower);
	print(upper);
	run("3D OC Options", "  centroid dots_size=3 font_size=10 redirect_to=none");
	//run("3D Objects Counter", "threshold=24 slice=16 min.=2 max.=324576000 objects centroids");
	//run("3D Objects Counter", "threshold="+lower*3.3+" slice=16 min.=2 max.=324576000 centroids");
	run("3D Objects Counter", "threshold=26 slice=16 min.=2 max.=324576000 centroids");

	
	//selectWindow("Objects map of "+MyTitle2);
	//selectWindow("Centroids map of "+MyTitle2);
	selectWindow("Centroids map of a");
	rename("Cent");
	setThreshold(1,255);
	//waitForUser("aa");
	run("Convert to Mask", "  white");
	roiManager("Select",0);
	run("Clear Outside", "stack");
	run("Select All");
	//slices=25;
	//waitForUser("aa");
	run("Set Measurements...", "area mean redirect=None decimal=2");
	roiManager("Reset");
	run("Clear Results");
	run("Analyze Particles...", "  show=Masks add in_situ stack");
	
	roiManager("Show All without labels");
	selectWindow("Cent");
	close();
	//selectWindow(MyTitle2);
	selectWindow("a");
	close();
	
	//selectWindow(MyTitle);
	selectWindow("red");
	run("Red");
	run("Enhance Contrast", "saturated=0.4");
	//roiManager("Select", 0);
	setTool("zoom");	
	roiManager("Show All without labels");
	roiManager("Show None");
	roiManager("Select All without labels");
	if(roiManager("Count")>0) {
		run("From ROI Manager");
		run("Flatten", "stack");
	}		
	run("3D Viewer");
	//call("ij3d.ImageJ3DViewer.add", MyTitle, "None", "3DS", "0", "true", "true", "true", "1", "0");
	call("ij3d.ImageJ3DViewer.add", "red", "None", "3DS", "0", "true", "true", "true", "1", "0");
	//selectWindow(MyTitle);
	selectWindow("red");
	roiManager("Show All without labels");
	run("Z Project...", "projection=[Max Intensity]");
	n=roiManager("Count");
	print(MyTitle);
	print(n);
	waitForUser(n+" points found. Please check the results and save images if desired. Press Ok when finished");
	//selectWindow(MyTitle);
	selectWindow("red");
	//close;
	//selectWindow("MAX_"+MyTitle);
	selectWindow("MAX_red");
	close;
	wait(200);
	call("ij3d.ImageJ3DViewer.close");

	selectWindow(MyTitle);
	setTool("zoom");
	run("Select None");
	//close();
	selectWindow("red");
	close();
	
	run("Clear Results");
	if(File.exists(output+File.separator+"Total.xls"))
	{
		
		//if exists add and modify
		open(output+File.separator+"Total.xls");
		i=nResults;
		setResult("Label", i, MyTitle); 
		setResult("#foci",i,n);
		setResult("Average Intensity",i,Iavg_tot);
		setResult("Maximum Intensity",i,Imax_tot);
		saveAs("Results", output+File.separator+"Total.xls");
		
	}
	else
	{
		
		setResult("Label", 0, MyTitle); 
		setResult("#foci",0,n);	
		setResult("Average Intensity",0,Iavg_tot);	
		setResult("Maximum Intensity",0,Imax_tot);	
		saveAs("Results", output+File.separator+"Total.xls");
		
	}

	showMessage("Done!");
	
}