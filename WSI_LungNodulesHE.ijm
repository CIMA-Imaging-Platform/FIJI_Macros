// changelog December 2019
// Automatic detection of tissue and lung nodules in HE
// Possibility of deleting tissue regions

var r=2.008, thTissue=230, thNodule=150, minNoduleSize=600;	

macro "LungNodulesHE Action Tool 1 - Ca2fT0b11NT8b09oTdb09d"
{


roiManager("Reset");
run("Clear Results");
MyTitle=getTitle();
output=getInfo("image.directory");

OutDir = output+File.separator+"AnalyzedImages";
File.makeDirectory(OutDir);


run("Colors...", "foreground=white background=black selection=green");


// DETECT TISSUE--

//POSSIBILITY OF DELETING
run("Select All");
setBatchMode(false);
run("Duplicate...", "title=orig");
setTool("zoom");
q=getBoolean("Do you want to elliminate an area of tissue?");
	while(q){
		setTool("freehand");		
		waitForUser("Please, select an area to elliminate and press ok when ready");
		setBackgroundColor(255, 255, 255);		
		run("Clear", "slice");
		run("Select All");				
		q=getBoolean("Do you want to elliminate another area?");
		setTool("zoom");
}

// DETECT
setBatchMode(true);
run("Select All");
showStatus("Detecting tissue...");
run("RGB to Luminance");
rename("a");
run("Threshold...");
//setAutoThreshold("Huang");
//getThreshold(lower, upper);
	//thTissue=233;
setThreshold(0, thTissue);
run("Convert to Mask");
run("Median...", "radius=12");
run("Analyze Particles...", "size=10000-Infinity pixel show=Masks in_situ");
run("Fill Holes");
run("Create Selection");
run("Add to Manager");	// ROI0 --> whole tissue
selectWindow("a");
close();


// LUNG NODULES--

selectWindow("orig");
showStatus("Deconvolving channels...");
run("Colour Deconvolution", "vectors=[H&E 2] hide");
selectWindow("orig-(Colour_2)");
close();
selectWindow("orig-(Colour_3)");
close();
selectWindow("orig");
close();
selectWindow("orig-(Colour_1)");
rename("Hematox");

run("Threshold...");
setAutoThreshold("Default");
	//thNodule=150;
setThreshold(0, thNodule);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Open");
run("Median...", "radius=1");
//run("Analyze Particles...", "size=600-Infinity show=Masks in_situ");
run("Analyze Particles...", "size="+minNoduleSize+"-Infinity show=Masks in_situ");
run("Median...", "radius=3");
roiManager("Show None");
run("Create Selection");
type = selectionType();
  if (type==-1) {	//if there is no selection, select one pixel
      makeRectangle(1,1,1,1);
  }
run("Add to Manager");	// ROI1 --> Whole hematoxylin detection
close();

// Save just nodules in tissue
roiManager("Deselect");
roiManager("Select", 0);
roiManager("Select", newArray(0,1));
roiManager("AND");
type = selectionType();
  if (type==-1) {	//if there is no selection, select one pixel
      makeRectangle(1,1,1,1);
  }
roiManager("Add");
roiManager("Deselect");
roiManager("Select", 1);
roiManager("Delete");


// POSSIBILITY OF DELETING NODULES

selectWindow(MyTitle);
setBatchMode(false);
roiManager("Select", 1);
setTool("zoom");
q=getBoolean("Do you want to set negative a region detected as nodule?");
	while(q){
		setTool("freehand");		
		waitForUser("Please, select the area and press ok when ready");
		run("Add to Manager");
		roiManager("Deselect");
		roiManager("Select", 1);
		roiManager("Select", newArray(1,2));
		roiManager("AND");
		type = selectionType();
		  if (type==-1) {	//if there is no selection, select one pixel
		      makeRectangle(2,2,1,1);
		  }
		roiManager("Add");
		roiManager("Deselect");
		roiManager("Select", 1);
		roiManager("Select", newArray(1,3));
		roiManager("XOR");
		roiManager("Add");
		roiManager("Deselect");
		roiManager("Select", newArray(1,2,3));
		roiManager("Delete");
		roiManager("Deselect");
		roiManager("Select", 1);
		setTool("zoom");								
		q=getBoolean("Do you want to set negative another region detected as positive?");		
	}



// RESULTS--

run("Clear Results");
selectWindow(MyTitle);	
run("Select None");
run("Set Measurements...", "area redirect=None decimal=2");

// Tissue
roiManager("select", 0);
roiManager("Measure");
At=getResult("Area",0);
//in micra
Atm=At*r*r;

// Nodules
roiManager("select", 1);
roiManager("Measure");
Ap=getResult("Area",1);
//in micra
Apm=Ap*r*r;

// Ratio
r1=Apm/Atm*100;

run("Clear Results");
if(File.exists(output+File.separator+"Total.xls"))
{
	
	//if exists add and modify
	open(output+File.separator+"Total.xls");
	i=nResults;
	setResult("Label", i, MyTitle); 
	setResult("Tissue area (micra^2)",i,Atm);
	setResult("Nodule area (micra^2)",i,Apm);
	setResult("Ratio Anodule/Atissue (%)",i,r1);			
	saveAs("Results", output+File.separator+"Total.xls");
	
}
else
{
	
	setResult("Label", 0, MyTitle); 
	setResult("Tissue area (micra^2)",0,Atm);
	setResult("Nodule area (micra^2)",0,Apm);
	setResult("Ratio Anodule/Atissue (%)",0,r1);		
	saveAs("Results", output+File.separator+"Total.xls");
	
}

aa = split(MyTitle,".");
MyTitle_short = aa[0];

selectWindow(MyTitle);
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

selectWindow("Threshold");
run("Close");
selectWindow(MyTitle);
close();
setTool("zoom");
selectWindow(MyTitle_short+"-1.jpg");
close();

showMessage("Done!");

}

macro "LungNodulesHE Action Tool 1 Options" {
     Dialog.create("Parameters");

     Dialog.addMessage("Choose parameters")
     Dialog.addNumber("micra/px ratio", r);
     Dialog.addNumber("Threshold for tissue detection", thTissue); 
     Dialog.addNumber("Threshold for nodule detection", thNodule);  
     //Dialog.addCheckbox("Export analyzed image", export);   
     Dialog.show();
     
     r= Dialog.getNumber();
     thTissue= Dialog.getNumber();
     thNodule= Dialog.getNumber();     
     //export=Dialog.getCheckbox();
        
}
