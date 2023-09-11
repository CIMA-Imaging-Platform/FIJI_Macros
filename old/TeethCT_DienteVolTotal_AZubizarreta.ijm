// changelog May 2022
// Segmentación semi-manual de rosca interna y externa en implantes metálicos para medición de desgaste en dos técnicas distintas

var thDiente=2000;	

//macro "TeethCT Action Tool - Cf00T4d15Tio"
macro "TeethCT Action Tool - C000C111C222C333D21C333Dd1C333D25C333D22Dc0C333C444D40Dc6C444D24C444D6fDd4C444DafC444DccC444D89C444DbeC444D3aC444D50Db0C444C555D23C555D9aC555Dc7C555D30C555D4cC555DcbC555D6eC555D5eDa0C666D81C666D3bC666DcaDcdC666Dc8C666D37Dd3C666D4dC666D39Dc9C666DaeC777D79C777D91Dd5C777D7aC777DacC777D38C777D26C777D60C777D6cDd2C777DadC888D6bC888D90C888D6dC888C999DabC999D71C999D31Dc5C999D9bC999CaaaD13D88D99CaaaDe2CaaaDd0CaaaDbfCaaaCbbbD5dCbbbD12D7bCbbbD36DbdDe3CbbbD4bCbbbD28CbbbD61CbbbD27CbbbD14CcccD6aCcccD3cD70D7eCcccDdaCcccDd9CcccD29D80D9cCcccDceCdddD7cCdddDd8CdddDd6CdddD20D7dCdddD7fCdddDc1DdbCdddD9eDa1CdddD9dCdddDe1CdddD51D5fCdddDaaCeeeD41Dd7CeeeD35D78CeeeD9fCeeeD15D4eDc4CeeeD2aDe4CfffD11CfffDdcCfffD4aCfffDb6DbcCfffDb7CfffD00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD0fD10D16D17D18D19D1aD1bD1cD1dD1eD1fD2bD2cD2dD2eD2fD32D33D34D3dD3eD3fD42D43D44D45D46D47D48D49D4fD52D53D54D55D56D57D58D59D5aD5bD5cD62D63D64D65D66D67D68D69D72D73D74D75D76D77D82D83D84D85D86D87D8aD8bD8cD8dD8eD8fD92D93D94D95D96D97D98Da2Da3Da4Da5Da6Da7Da8Da9Db1Db2Db3Db4Db5Db8Db9DbaDbbDc2Dc3DcfDddDdeDdfDe0De5De6De7De8De9DeaDebDecDedDeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDff"
{

roiManager("Reset");
run("Clear Results");

getVoxelSize(vx, vy, vz, unit);

MyTitle=getTitle();
output=getInfo("image.directory");

OutDir = output+File.separator+"AnalyzedImages";
File.makeDirectory(OutDir);

aa = split(MyTitle,".");
MyTitle_short = aa[0];

rename("orig");
run("Select None");
run("Duplicate...", "title=origIm duplicate");

getDimensions(width, height, channels, slices, frames);

selectWindow("orig");
setSlice(round(slices/2));
run("Threshold...");
  //thDiente=3500;
setThreshold(thDiente, 32767);
setOption("BlackBackground", false);
run("Convert to Mask", "method=Default background=Dark");
run("Open", "stack");
run("Median...", "radius=2 stack");
run("Keep Largest Region");
selectWindow("orig");
close();
selectWindow("orig-largest");
rename("orig");
saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_toothMask.tif");
rename("orig");

/*
//--MEASURE IMAGE INTENSITY IN MASK

run("Set Measurements...", "area mean redirect=None decimal=2");
selectWindow("orig");
getDimensions(width, height, channels, slices, frames);
Aacc=0;
Iacc=0;
for (i = 1; i <= slices; i++) {
	selectWindow("orig");
	setSlice(i);
	run("Create Selection");
	type=selectionType();
	if (type!=-1) {	
  		selectWindow("origIm");
  		setSlice(i);
  		run("Restore Selection");
  		run("Measure");
  		Ai=getResult("Area",0);
  		Ii=getResult("Mean",0);
  		Aacc=Aacc+Ai;
  		Iacc=Iacc+Ii*Ai;	// weigh each slice intensity with the area of the ROI  	  	
	}
}
Vtooth = Aacc*vz;
Itooth = Iacc/Aacc;
selectWindow("origIm");
*/

// RESULTS--

run("Clear Results");

selectWindow("orig");
run("Create Selection");
run("Select None");
run("Statistics");
voxels=getResult("Voxels",0);
Vtooth=voxels*vx*vy*vz;


run("Clear Results");
if(File.exists(output+File.separator+"QuantificationResults.xls"))
{	
	//if exists add and modify
	open(output+File.separator+"QuantificationResults.xls");
	IJ.renameResults("Results");
}
i=nResults;
setResult("Label", i, MyTitle_short); 
setResult("Total tooth volume (mm3)",i,Vtooth);
//setResult("Avg tooth intensity",i,Itooth);
saveAs("Results", output+File.separator+"QuantificationResults.xls");
	

setTool("zoom");

selectWindow("Threshold");
run("Close");

run("Synchronize Windows");

showMessage("Done!");

}


macro "TeethCT Action Tool Options" {
        Dialog.create("Parameters");

	Dialog.addMessage("Choose parameters")	
	Dialog.addNumber("Threshold for implant", thDiente);
	Dialog.show();		
	thDiente= Dialog.getNumber();	
}
