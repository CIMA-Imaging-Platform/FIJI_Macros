// changelog October 2022

var thProl=25;

macro "Soma_and_axon_size_2D Action Tool 1 - N44C000D00D03D04D05D06D09D0aD0bD0kD0nD10D11D14D15D16D17D1bD1cD1dD1iD1mD1nD20D21D24D25D26D27D28D29D2mD2nD30D31D32D35D36D37D38D39D3aD3bD3mD3nD42D45D46D47D48D49D4aD4bD4cD4iD4lD4mD4nD55D56D57D58D59D5aD5bD5cD5dD5iD5lD5mD5nD60D66D67D69D6aD6bD6cD6dD6eD6kD6lD6mD6nD70D71D77D79D7aD7bD7cD7dD7eD7kD7lD7mD7nD80D81D8aD8bD8cD8dD8eD8kD8lD8mD8nD90D91D93D94D95D9aD9bD9cD9dD9eDa0Da1Da2Da3Da4Da5Da6DaaDabDacDadDaeDb0Db3Db4Db5Db6Db7DbbDbcDbdDbeDccDcdDckDclDcmDcnDd0Dd1Dd2Dd3Dd4DdjDdkDdlDdmDdnDe0De1De2De3De4De5De6De7De8DejDekDelDemDenDf0Df2Df3Df4Df5Df6Df7Df8DfkDflDfmDfnDg0Dg2Dg3Dg4Dg6DgiDglDgmDgnDh0Dh9DhaDhbDhcDhdDhmDhnDi7Di8Di9DiaDibDicDidDikDinDj2Dj3Dj4Dj5Dj6Dj7Dj8Dj9DjaDjbDjcDjdDjjDjkDjlDjnDk0Dk1Dk2Dk3Dk4Dk5Dk6Dk7Dk8Dk9DkaDkbDkcDkdDl0Dl1Dl2Dl3Dl4Dl5Dl6Dl7Dl8Dl9DlaDlbDlcDldDleDlhDliDm0Dm1Dm2Dm3Dm4Dm5Dm6Dm7Dm8Dm9DmbDmcDmdDmiDmjDmnDn0Dn1Dn2Dn3Dn4Dn5Dn6Dn7Dn8Dn9DnaDnbDncDnfDniDnjDnkC000D08D0cD0iD13D18D2bD2lD3lD41D4eD5eD5kD72D89D92Da7DaiDbiDbnDc1Df1DgkDh1DheDi6DkeDkhDkkDmaC000D2jD34D3eD4dD7hD84DajDb8DbmDc8Dc9Dh2C000D07D1aD1jD2cD2iD3dD53D78D99Dd5Dd6DdiDf9DhhDieDijDimDj1DkfDklDknDmfC000D2dD3cD6iD87D9nDc2De9DfiDjfC000D19D22D43D61D8jDceDhjDhlDkiDljDllDlmC000DblDc0DeaDghDilDlnDmmDngC000D02D2aD4jD6hD76D82Db2Dg7DgdDh3DkmC000C100D88D96DeiDfjDhiDmhDndC100D68D8hDakDd7Dg5DmeDmkC100D0jD1kD3iD3jD4gD52D83Db1Dc7DdcDebDgcDhkDneC100D0dDiiDjmDlfC100D0mD65D7jDgjC100D2gD4hDg1C100D0hD23D2eD5hDj0DnlC100D0lD1hD5gD9mDc6DcjDfhDi5C200Dc5DddDh4DnnC200D0fD3gD3hD9lDc3DcbDmlC200DjhDlkC200D01D12D44D4kD54Dc4Dd8Dd9C200D2hD50D9jDbhDh8DnmC200D1eD51DbaDnhC200D9kDfaDgbDjeDkjC200C300D63DjiC300D0gD33C300D1lD64D73D85D98C300DehDi0C300Da9DbjDifC300D40C300D1gDdhC300DmgC400D74Di4C400D62D75DihC400D5jD9iC400D3kD7iC400D6jD9fDalDdaC400Di1C400D8iDjgC400C500DbkC500D8fDafC500D2kD7fC500DanDh6Dh7C500D97Di3DlgC500DamDciC500DgaDh5Di2C500D6gDg8C600Da8C600Db9C600DkgC600DhfC600C700DchC700DahC700D6fD86D9hDfbC700DcaC700C800D0eDg9C800DbfC800D7gC800D1fC800DgeC800DigC800C900DagC900D8gC900D3fDdbC900Ca00D5fCa00D4fCa00Cb00DecCb00DedCb00D2fCb00DhgCb00Cc00D9gDbgCc00DcfCc00Cd00DdeCd00DfdDggCd00Ce00DcgCe00DfcCe00Cf00DfgCf00DdfDdgDegDgfCf00DeeDefDfeDff"{

run("Close All");

//just one file
name=File.openDialog("Select File");
//print(name);
print("Processing "+name);

run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");

Dialog.create("Parameters for the analysis");
Dialog.addNumber("Segmentation threshold", thProl);	
Dialog.show();	
thProl = Dialog.getNumber();

roiManager("Reset");
run("Clear Results");
MyTitle=getTitle();
output=getInfo("image.directory");

OutDir = output+File.separator+"AnalyzedImages";
File.makeDirectory(OutDir);

aa = split(MyTitle,".");
MyTitle_short = aa[0];

run("Colors...", "foreground=black background=white selection=yellow");

Stack.getDimensions(width, height, channels, slices, frames);


///// IMAGE PREPROCESSING//////

//--Get just red channel

run("Duplicate...", "title=orig duplicate channels=1");

//--Background subtraction
run("Subtract Background...", "rolling=20 stack");

//--2D projection
run("Z Project...", "projection=[Sum Slices]");
selectWindow("orig");
close();
selectWindow("SUM_orig");
rename("orig");
run("8-bit");
run("Red");
run("Enhance Contrast", "saturated=0.35");


//--MANUAL SELECTION OF AREA OF ANALYSIS AND SOMAS

setTool("freehand");
waitForUser("Please select an area of analysis and press OK");
type=selectionType();
if(type==-1) {
	run("Select All");
}
run("Add to Manager");	// ROI 0 --> Area of analysis

roiManager("Show All");
roiManager("Show All without labels");

waitForUser("Please add somas by drawing and pressing 'T'. Press OK when all the somas are annotated");

//--Check if somas are in the analysis region and delete them if not:

n = roiManager("count");
for (i = 1; i < n; i++) {
	roiManager("deselect");
	roiManager("Select", newArray(0,1));
	roiManager("AND");
	type=selectionType();
	if(type!=-1) {
		roiManager("add");
	}
	roiManager("deselect");
	roiManager("Select", 1);
	roiManager("delete");
}

//--Count neurons 
n = roiManager("count");
nNeurons = n-1;

//--Measure area of analysis
run("Set Measurements...", "area redirect=None decimal=2");
run("Clear Results");
selectWindow("orig");
roiManager("Show None");
roiManager("Select", 0);
roiManager("Measure");
Atotal = getResult("Area", 0);

//--Measure areas of somas
run("Clear Results");
Asomas = newArray(nNeurons);
for (i = 0; i < nNeurons; i++) {
	roiManager("Select", i+1);
	roiManager("Measure");
	Asomas[i] = getResult("Area", i);
}
Array.getStatistics(Asomas, min, max, mean, stdDev);
Asoma_avg = mean;
//print(Asoma_avg);

selectWindow("orig");
roiManager("Show None");
roiManager("Select", 0);
roiManager("Set Color", "yellow");
roiManager("Set Line Width", 1);
run("Flatten");
rename("imageToSave");


//--CALCULATE AREA OF PROLONGATIONS

//--Steerable filter
selectWindow("orig");
run("Select None");
getVoxelSize(vx, vy, vz, unit);
print("Voxel size: "+vx+"x"+vy+"x"+vz+" "+unit);
run("Tubeness", "sigma="+vx+" use");
//run("Tubeness", "sigma=2 use");

selectWindow("tubeness of orig");
rename("prolong");
run("8-bit");
run("Enhance Contrast...", "saturated=0.3");
  // thProl = 25;
setThreshold(thProl, 255);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Analyze Particles...", "size=5-Infinity pixel show=Masks in_situ");

//--Keep only area of analysis
roiManager("Deselect");
roiManager("Select", 0);
setBackgroundColor(255, 255, 255);
run("Clear Outside");
roiManager("Deselect");
roiManager("Select", 0);
roiManager("Delete");

//--Clear somas
roiManager("Deselect");
roiManager("Combine");
setBackgroundColor(255, 255, 255);
run("Clear", "slice");
run("Select None");
run("Analyze Particles...", "size=10-Infinity pixel show=Masks in_situ");
run("Create Selection");
run("Add to Manager");
close();

selectWindow("imageToSave");
roiManager("Deselect");
roiManager("Combine");
roiManager("Set Color", "cyan");
roiManager("Set Line Width", 1);
run("Flatten");
selectWindow("imageToSave");
close();
selectWindow("imageToSave-1");
rename("imageToSave");

//--Measure prolongations

selectWindow("orig");
roiManager("Show None");
roiManager("Select", nNeurons);
roiManager("Measure");
Aprol = getResult("Area", 0);
close();


//--Save results
run("Clear Results");
if(File.exists(output+File.separator+"Quantification_Somas_and_Prolongations.xls"))
{	
	//if exists add and modify
	open(output+File.separator+"Quantification_Somas_and_Prolongations.xls");
	IJ.renameResults("Results");
}
i=nResults;
setResult("Label", i, MyTitle); 
setResult("# neurons",i,nNeurons);
setResult("Area of analysis (um2)",i,Atotal);
setResult("Avg area of soma (um2)",i,Asoma_avg);
setResult("Total area of prolongations (um2)",i,Aprol);
saveAs("Results", output+File.separator+"Quantification_Somas_and_Prolongations.xls");


//--Draw

selectWindow("imageToSave");
roiManager("Deselect");
roiManager("Select", nNeurons);
roiManager("Set Color", "magenta");
roiManager("Set Line Width", 1);
run("Flatten");
saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
rename(MyTitle_short+"_analyzed.jpg");

selectWindow(MyTitle);
close();
selectWindow("imageToSave");
close();

	 
//Clear unused memory
wait(500);
run("Collect Garbage");

showMessage("Quantification finished!");
	
}



