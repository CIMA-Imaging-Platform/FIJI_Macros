//changelog December 2022
//manual selection of cardiomyocites, measure area and equivalent diameter
//detect nucleus with DAPI and measure area
//they are RGB!

var r=0.502, thDAPI=25;	// Scanner 20X

macro "manualCardio Action Tool - Cf00T4d14M" 
{

Dialog.create("Parameters");
Dialog.addMessage("Choose parameters")	
Dialog.addNumber("Ratio micra/pixel", r);
Dialog.addNumber("Nuclei threshold", thDAPI);
Dialog.show();	
r= Dialog.getNumber();		
thDAPI= Dialog.getNumber();	

run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width="+r+" pixel_height=+"+r+" voxel_depth=1.0000 frame=[0 sec] origin=0,0");
roiManager("Reset");
run("Clear Results");
MyTitle=getTitle();
output=getInfo("image.directory");

aa = split(MyTitle,".");
MyTitle_short = aa[0];

selectWindow(MyTitle);
setTool("zoom");
// Manage cardiomyocite selection
q=getBoolean("Do you want to select a cardiomyocyte?");
while(q){
	run("Clear Results");
	setTool("polygon");	
	roiManager("Show All");	// show to avoid drawing one already measured	
	//roiManager("Show None");
	waitForUser("Please, draw the cardiomyocyte and press ok when ready");
	type = selectionType();
	  if (type==-1)	//if there is no selection, select the whole image
	      waitForUser("Tienes que seleccionar un cardiomiocito antes de pulsar OK");
	run("Add to Manager");	
	run("Measure");
	a=getResult("Area",0);
	
	//calculate equivalent diameter
	d=2*sqrt(a/PI);

	//--Create a DAPI image by splitting RGB:	
	run("Duplicate...", "title=cm");
	run("Duplicate...", "title=cmMask");
	run("Select None");
	run("Split Channels");
	selectWindow("cmMask (green)");
	close();
	selectWindow("cmMask (red)");
	close();
	selectWindow("cmMask (blue)");
	rename("dapi");
	  //thDAPI = 25;
	setThreshold(thDAPI, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=1");
	run("Keep Largest Region");
	selectWindow("dapi");
	close();
	selectWindow("dapi-largest");
	rename("dapi");
	run("Create Selection");
	run("Measure");
	An=getResult("Area",1);
	selectWindow("dapi");	
	close();
	selectWindow("cm");	
	run("Restore Selection");
	waitForUser("Check the nucleus detection and press OK");
	if(isOpen("cm")) {
		selectWindow("cm");
		close();
	}	

	// WRITE RESULTS--
	run("Clear Results");
	if(File.exists(output+File.separator+MyTitle_short+".xls"))
	{		
		//if exists add and modify
		open(output+File.separator+MyTitle_short+".xls");
		IJ.renameResults("Results");
	}
	i=nResults;
	setResult("Label", i, "C"+(i+1));		
	setResult("Area CM (micra²)",i,a);
	setResult("Equivalent diameter (micra)",i,d);
	setResult("Area nucleus (micra²)",i,An);
	saveAs("Results", output+File.separator+MyTitle_short+".xls");
		
	
	q=getBoolean("Do you want to add another cardiomyocyte?");
	setTool("zoom");
}

selectWindow(MyTitle);
roiManager("Show All with labels");
roiManager("Set Color", "red");
roiManager("Set Line Width", 1);
run("Flatten");
saveAs("Jpeg", output+MyTitle_short+"_analyzed.jpg");

selectWindow(MyTitle);
close();

showMessage("Done!");

}




