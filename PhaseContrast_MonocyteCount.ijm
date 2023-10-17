// changelog October 2021

// Possibility of manual deletion of 
// Cell nuclei segmentation from blue (HE)
// Determination of cell by applying known diameter of leucocytes (20um)
// Brown signal (CD45) segmentation for positive cell determination


var r=0.502, cellDiameter=20, thTissue=230, thBlue=160, thBrown=105, minSize=10, maxSize=10000;		// Escáner 20x


macro "MonocyteCount Action Tool 1 - C2b4T1d14IT4d14nTcd14iTfd14t"
{

run("Close All");
name=File.openDialog("Select image file");
print("Processing "+name);

run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Grayscale rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
	
roiManager("Reset");
run("Clear Results");
MyTitle=getTitle();
output=getInfo("image.directory");


run("Colors...", "foreground=black background=white selection=green");
run("Set Measurements...", "area mean redirect=None decimal=2");
//run("Set Scale...", "distance=0 known=0 unit=pixel");

// DETECT TISSUE
run("Select All");
showStatus("Detecting tissue...");
run("Duplicate...", "title=tissue");
run("8-bit");
run("Variance...", "radius=20");
setAutoThreshold("Default dark");
//run("Threshold...");
setThreshold(30, 255);
run("Convert to Mask");
run("Analyze Particles...", "size=30-Infinity pixel show=Masks in_situ");
run("Invert");
run("Analyze Particles...", "size=1000-Infinity pixel show=Masks in_situ");
run("Invert");
run("Create Selection");
roiManager("Add");	// Roi0 -> Epitelium
selectWindow("tissue");
close();

selectWindow(MyTitle);
run("Select All");
roiManager("Select", 0);
q=getBoolean("Do you want to elliminate an area of tissue?");
while(q){
	setTool("freehand");
	roiManager("Show None");
	run("Select None");
	waitForUser("Please, select an area to elliminate and press ok when ready");
	roiManager("Add");
	roiManager("Deselect");
	roiManager("Select", newArray(0,1));
	roiManager("AND");
	roiManager("Add");
	roiManager("Select", newArray(0,2));
	roiManager("XOR");
	roiManager("Add");
	roiManager("Deselect");
	roiManager("Select", newArray(0,1,2));
	roiManager("Delete");
	roiManager("Deselect");
	roiManager("Select", 0);
	q=getBoolean("Do you want to elliminate another area?");	
}

q=getBoolean("Do you want to add an area of tissue?");
while(q){
	setTool("freehand");
	roiManager("Show None");
	run("Select None");
	waitForUser("Please, select an area to add and press ok when ready");
	roiManager("Add");
	roiManager("Deselect");
	roiManager("Select", newArray(0,1));
	roiManager("Combine");
	roiManager("Add");
	roiManager("Deselect");
	roiManager("Select", newArray(0,1));
	roiManager("Delete");
	roiManager("Deselect");
	roiManager("Select", 0);
	q=getBoolean("Do you want to add another area?");	
}

showMessage("Tissue detection finished!");

/*// DRAW TISSUE:
roiManager("Set Color", "yellow");
roiManager("Set Line Width", 2);
run("Flatten");
wait(100);
rename("orig");*/

}


macro "MonocyteCount Action Tool 2 - N44C333D6eD6fD6gD7cD7dD7eD7gD7hD7iD8iD8jD9bD9jDabDcaDcbDd9DdaDdbDdcDecDedDeeDeiDejDfeDffDfgDfhDfiDggDghDgiDkfDlcDldC777D00D03D04D09D0aD0eD0fD0gD0lD0nD1dD1fD1gD1lD2aD2dD2kD33D36D3fD3nD42D4dD4eD4fD4kD4nD50D52D5aD5kD60D62D64D6aD73D7nD81D83D84D8mD8nD95Da3Da4Db0Db1DbjDc0Dc1DcmDdmDdnDe2De3DefDenDf1Df2DfdDg1Dg2Dh0Dh1Di5Di6Di7DijDinDj4Dj5Dj6Dk1Dk5Dk6DkjDl0Dl6Dl7DljDlkDlmDm6Dm7DmiDmjDmkDmnDn1Dn6Dn8Dn9DnaC666D01D05D07D08D0bD0cD0dD0hD0iD0jD0kD12D13D19D1aD1bD1cD1hD1iD1jD1kD1nD20D21D22D23D29D2bD2cD2eD2fD2gD2lD32D35D39D3aD3bD3dD3eD3gD3iD3jD3kD3lD3mD49D4aD4bD4cD4gD4iD4jD4lD4mD51D57D59D5bD5cD5dD5fD5jD5lD5nD63D69D6bD6lD6mD6nD74D7aD7lD82D89D8hD8lD90D92D93D9cD9mD9nDa5Da9Db2Dc4Dc7DccDcjDd4DdlDemDf3DfmDgfDgmDh2Dh6DhjDhkDhmDi0Di2Di3Di4DiiDikDilDimDj2Dj3Dj7DjaDjjDjkDjlDk0Dk7Dk8DkcDkdDkhDkiDkkDklDl1Dl5Dl8DliDllDlnDm0Dm3Dm5DmgDmhDmlDmmDn0Dn2Dn5Dn7DnbDndDneDnfDngDniDnjDnkDnlDnmC888D40D65DagDb3DbgDc2Dc3DcnDd2DdeDe0Df0DfaDhcDjmDjnDkmDnnC666D02D06D14D16D17D18D2hD2iD2jD34D37D38D3cD3hD43D48D4hD5eD5mD61D6kD71D79D7kD7mD88D96D98D99D9lDa0Da2Da6Da7Da8DajDamDanDb5Db6Db7Db8Db9DbmDc5Dc6Dc8DclDd5Dd6Dd7DddDe4De5De6De7DelDflDg3Dg6DgkDglDh3Dh5Dh7DhlDi1Di8DihDj0Dj1DjhDjiDk2Dk3Dk4Dl2Dl3Dl4DlgDlhDm1Dm2Dm4Dm9DmfDn3Dn4DncDnhC777D0mD10D11D1eD1mD30D31D41D44D47D54D66D72D8dD91D94D9iDa1Db4DbnDd0Dd1Dd3De1DehDfnDgnDhnDknDm8CaaaD56D9hDahDbeDceDfcDgbDhaDjeC555D15D24D25D26D28D2mD2nD53D58D5gD5hD5iD67D68D6cD6iD6jD70D75D76D77D78D80D85D86D87D8aD8kD97DalDblDd8De8DekDf4Df5Df6Df7DfkDg5Dg7DgjDh4Dh8DhiDigDj8DjfDk9Dl9DmaDmeC999D45D8eD8fD8gDaeDbcDdiDgdDgeDhdDhfCcccD46DadDaiDbdDbiDcdDciDfbDibDidC555D27D6dD7bD9aD9kDaaDbkDc9DckDdkDe9DeaDebDf8Df9DfjDg4Dg9Dh9DhhDjgDkbDkeDkgDlaDleDlfDmbDmcDmdC888DacDafDegDg0DifCbbbD9dD9eD9fD9gDdfDicDjbCaaaD55DbfDbhDcfDcgDgaDgcDhbDiaCeeeDchDdgDdhDheDieDjcDjdC444D6hD7fD7jD8bD8cDakDbaDbbDdjDg8DhgDi9Dj9DkaDlb"
{

setBatchMode(true);

run("Clear Results");
MyTitle=getTitle();
output=getInfo("image.directory");

OutDir = output+File.separator+"AnalyzedImages";

run("Select None");
run("8-bit");
run("Duplicate...", "title=a");
run("Mean...", "radius=10");
imageCalculator("Subtract create", MyTitle,"a");
rename("processed");
run("Median...", "radius=2");
run("Morphological Filters", "operation=Opening element=Disk radius=1");
rename("processed1");
run("Find Maxima...", "prominence=20 output=[Single Points]");
rename("max");
selectWindow("a");
close();
selectWindow("processed");
close();
selectWindow("processed1");
close();

// transform selection to individual points
selectWindow("max");
roiManager("Deselect");
run("Find Maxima...", "prominence=10 light output=[Point Selection]");
setTool("multipoint");
run("Point Tool...", "type=Hybrid color=Green size=Medium counter=0");
selectWindow(MyTitle);
run("Restore Selection");
selectWindow("max");
close();
setBatchMode(false);
showMessage("Automatic detection of monocytes finished. Add (Click) or Delete (CTRL+ALT+Click) monocytes if needed");

}



macro "MonocyteCount Action Tool 3 - Cf00T2d14CTcd14L"
{

// clear all points
run("Select None");

}



macro "MonocyteCount Action Tool 4 - N44C273D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD0fD0gD0hD0iD13D14D15D16D17D18D19D1aD1bD1cD1dD1eD1fD1gD1hD1iD23D24D25D26D27D28D29D2aD2bD2cD2dD2eD2fD2gD2hD2iD2jD33D34D35D36D3aD3bD3cD3gD3hD3iD3jD42D43D44D45D46D4gD4hD4iD4jD52D53D54D55D56D5gD5hD5iD5jD62D63D64D65D66D67D6eD6fD6gD6hD6iD6jD72D73D74D75D76D77D7eD7fD7gD7hD7iD7jD7kD82D83D84D85D8fD8gD8hD8iD8jD8kD92D93D94D95D9gD9hD9iD9jD9kDa1Da2Da3Da4Da5Da9DaaDabDacDagDahDaiDajDakDb1Db2Db3Db4Db5Db6Db7Db8Db9DbaDbbDbcDbdDbeDbfDbgDbhDbiDbjDbkDc1Dc2Dc3Dc4Dc5Dc6Dc7Dc8Dc9DcaDcbDccDcdDceDcfDcgDchDciDcjDckDclCacaD1kD41D5aD69D90DcmDd0DdlDg6Dg9DgcDgfDi7DiaDidDigDk7DkaDkdDkgC373D1jD32D39D3fD4aD4bD5fD6kD81D86D91D9aD9bDafDblCeffDe3Df3Dg3Dh3Di3Dj3Dk3Dl3Dm3CeeeDg5Dg8DgbDgeDh7DhaDhdDhgDl7DlaDldDlgC6a7D02D2kD3kD47D4cD51D5bD5eD61D87D8aD8bD8lD99D9cDa0Da7DaeDb0Dd5Dd7Dd8DdaDdbDddDdeDdgDi6Di9DicDifDk6Dk9DkcDkfCfffD00D01D0lD0mD0nD10D1lD1mD1nD20D2lD2mD2nD30D3mD3nD40D4mD4nD50D5mD5nD6mD6nD7mD7nD8mD8nD9nDanDbnDcnDdnDe0De1De2DekDelDemDenDf0Df1Df2DfkDflDfmDfnDg0Dg1Dg2DgkDglDgmDgnDh0Dh1Dh2DhkDhlDhmDhnDi0Di1Di2DikDilDimDinDj0Dj1Dj2DjkDjlDjmDjnDk0Dk1Dk2DkkDklDkmDknDl0Dl1Dl2DlkDllDlmDlnDm0Dm1Dm2DmkDmlDmmDmnDn0Dn1Dn2DnjDnkDnlDnmDnnCdedD21D48D5cD5dD70D89D8cD97D9dDamDdmDe5De8DebDeeDf5Df8DfbDfeDh6Dh9DhcDhfDi5Di8DibDieDj5Dj8DjbDjeDk5Dk8DkbDkeDl6Dl9DlcDlfC495D12D38D3eD4kD6dD71D78D7dD8eD96D9lDa8DadDc0De6De9DecDefDf6Df9DfcDffDj6Dj9DjcDjfCfffD3lDejDfjDgjDhjDijDjjDkjDljDmjCeefDe4DehDeiDf4DfhDfiDg4DghDgiDh4Dh5Dh8DhbDheDhhDhiDi4DihDiiDj4DjhDjiDk4DkhDkiDl4Dl5Dl8DlbDleDlhDliDm4Dm5Dm6Dm7Dm8Dm9DmaDmbDmcDmdDmeDmfDmgDmhDmiDn4Dn5Dn6Dn7Dn8Dn9DnaDnbDncDndDneDnfDngDnhDniC8b9D49D7lDd1Dd2Dd3Dd4DdhDdiDdjDdkDe7DeaDedDegDf7DfaDfdDfgDj7DjaDjdDjgCcdcD0kD31D4dD4eD58D5lD6cD6lD79D7cD80D88D8dD98D9eDbmDg7DgaDgdDggC383D0jD22D37D3dD4fD57D5kD68D9fDa6DalDd6Dd9DdcDdfCfffD60D6aD6bD7aD7bDn3CefeD11D4lD59D9m"
{

run("Clear Results");
MyTitle=getTitle();
output=getInfo("image.directory");

OutDir = output+File.separator+"AnalyzedImages";
File.makeDirectory(OutDir);

aa = split(MyTitle,".");
MyTitle_short = aa[0];

run("Create Mask");
rename("max");

//--Delete outside epitelium
selectWindow("max");
roiManager("Deselect");
roiManager("Select", 0);
setBackgroundColor(255, 255, 255);
run("Clear Outside");
run("Select None");

run("Find Maxima...", "prominence=10 light output=Count");

// Get number of monocytes
i=nResults;
nMon=getResult("Count",i-1);

// MEASURE AREA OF ANALYSIS--
selectWindow(MyTitle);
run("Clear Results");
run("Select All");
run("Set Measurements...", "area redirect=None decimal=2");
roiManager("Select", 0);
roiManager("Measure");
Atm=getResult("Area",0);
run("Clear Results");

// Write results:
run("Clear Results");
if(File.exists(output+File.separator+"Quantification_Monocytes.xls"))
{	
	//if exists add and modify
	open(output+File.separator+"Quantification_Monocytes.xls");
	IJ.renameResults("Results");
}
i=nResults;
setResult("Label", i, MyTitle); 
setResult("# Monocytes", i, nMon); 
setResult("Tissue Area (um2)", i, Atm); 
saveAs("Results", output+File.separator+"Quantification_Monocytes.xls");


// DRAW

selectWindow("max");
roiManager("Deselect");
run("Find Maxima...", "prominence=10 light output=[Point Selection]");
setTool("multipoint");
run("Point Tool...", "type=Hybrid color=Green size=Medium counter=0");
selectWindow(MyTitle);
run("Restore Selection");
selectWindow("max");
close();

selectWindow(MyTitle);
rename("orig");
run("Point Tool...", "type=Hybrid color=Green size=Medium counter=0");
run("Add Selection...");
run("Flatten");
wait(200);

selectWindow("orig-1");
roiManager("Show None");
roiManager("Select", 0);
roiManager("Set Color", "yellow");
roiManager("Set Line Width", 1);
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



