// changelog September 2022

var r=0.502, thTissue=227, thFat=190, minFatSize=40, maxFatSize=3000, minFatCirc=0.5;	// Scanner 20x	

macro "Steatosis Action Tool 1 - Cf00T2d15IT6d10m"{
	//just one file
	name=File.openDialog("Select File");
	//print(name);
					//setBatchMode(true);
					print(name);
					steatosis("-","-",name);
					setBatchMode(false);
					showMessage("Done!");

		}
macro "Steatosis Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	InDir=getDirectory("Choose a Directory");
	list=getFileList(InDir);
	L=lengthOf(list);

			for (j=0; j<L; j++)
			{
				if(endsWith(list[j],"jpg")||endsWith(list[j],"tif")){
					//analyze
					//d=InDir+list[j]t;
					name=list[j];
					print(name);
					//setBatchMode(true);
					steatosis(InDir,InDir,list[j]);
					setBatchMode(false);
					}
			}
			showMessage("Done!");
		}


function steatosis(output,InDir,name)
{

	run("Close All");
	
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

aa = split(MyTitle,".");
MyTitle_short = aa[0];

setBatchMode(true);
run("Colors...", "foreground=white background=black selection=green");

// DETECT TISSUE
run("Select All");
showStatus("Detecting tissue...");
run("RGB to Luminance");
rename("a");
run("Threshold...");
//setAutoThreshold("Huang");
//getThreshold(lower, upper);
	//thTissue=227;
setThreshold(0, thTissue);
run("Convert to Mask");
run("Median...", "radius=12");
run("Invert");
//run("Fill Holes");
run("Open");
run("Analyze Particles...", "size=12000-Infinity pixel show=Masks in_situ");
run("Invert");
run("Analyze Particles...", "size=100000-Infinity pixel show=Masks in_situ");
//run("Fill Holes");
run("Create Selection");
run("Add to Manager");	// ROI0 --> whole tissue
selectWindow("a");
close();

// Detect deposits
run("Duplicate...", "title=orig");
run("8-bit");
run("Threshold...");
  //thFat=190;
setThreshold(thFat, 255);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Median...", "radius=1");
//run("Fill Holes");
//run("Analyze Particles...", "size=20-500 circularity=0.85-1.00 pixel show=Masks in_situ");
run("Analyze Particles...", "size="+minFatSize+"-"+maxFatSize+" circularity="+minFatCirc+"-1.00 pixel show=Masks in_situ");
run("Select None");
roiManager("Select", 0);
setBackgroundColor(255,255,255);
run("Clear Outside");
run("Create Selection");
run("Add to Manager");	// ROI1 --> Fat deposits in tissue
selectWindow("orig");
close();



// RESULTS--

run("Clear Results");
selectWindow(MyTitle);	
run("Set Measurements...", "area redirect=None decimal=2");

// Tissue
roiManager("select", 0);
roiManager("Measure");
At=getResult("Area",0);
//in micra
Atm=At*r*r;

// Fat deposits
roiManager("select", 1);
roiManager("Measure");
Ap=getResult("Area",1);
//in micra
Apm=Ap*r*r;

// Ratio
r1=Apm/Atm*100;

run("Clear Results");
if(File.exists(output+File.separator+"Quantification_Steatosis.xls"))
{	
	//if exists add and modify
	open(output+File.separator+"Quantification_Steatosis.xls");
	IJ.renameResults("Results");
}
i=nResults;
setResult("Label", i, MyTitle); 
setResult("Tissue area (um2)",i,Atm);
setResult("Steatosis area (um2)",i,Apm);
setResult("Ratio Asteatosis/Atissue (%)",i,r1);			
saveAs("Results", output+File.separator+"Quantification_Steatosis.xls");
	


setBatchMode(false);
selectWindow(MyTitle);
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

selectWindow(MyTitle);
close();
selectWindow(MyTitle_short+"-1.jpg");
close();
setTool("zoom");

if (InDir!="-") {
close(); }

//showMessage("Done!");

}

macro "Steatosis Action Tool 1 Options" {
     Dialog.create("Parameters");

     Dialog.addMessage("Choose parameters")
     Dialog.addNumber("micra/px ratio", r);
     Dialog.addNumber("Threshold for tissue detection", thTissue); 
     Dialog.addNumber("Threshold for fat-deposit detection", thFat); 
     Dialog.addNumber("Min fat-deposit size", minFatSize);  
     Dialog.addNumber("Max fat-deposit size", maxFatSize); 
     Dialog.addNumber("Min fat-deposit circularity", minFatCirc); 
     Dialog.show();
     
     r= Dialog.getNumber();
     thTissue= Dialog.getNumber();
     thFat= Dialog.getNumber();
     minSize= Dialog.getNumber();     
     maxFatSize= Dialog.getNumber();     
     minFatCirc= Dialog.getNumber();             
}

macro "Steatosis Action Tool 2 Options" {
     Dialog.create("Parameters");

     Dialog.addMessage("Choose parameters")
     Dialog.addNumber("micra/px ratio", r);
     Dialog.addNumber("Threshold for tissue detection", thTissue); 
     Dialog.addNumber("Threshold for fat-deposit detection", thFat); 
     Dialog.addNumber("Min fat-deposit size", minFatSize);  
     Dialog.addNumber("Max fat-deposit size", maxFatSize); 
     Dialog.addNumber("Min fat-deposit circularity", minFatCirc); 
     Dialog.show();
     
     r= Dialog.getNumber();
     thTissue= Dialog.getNumber();
     thFat= Dialog.getNumber();
     minSize= Dialog.getNumber();     
     maxFatSize= Dialog.getNumber();     
     minFatCirc= Dialog.getNumber();    
}
