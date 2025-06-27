// Changelog September 2021
// Macro con tres botones
// Botón 1: inicializar calibrando la imagen, haciendo un reslice y recortando el volumen a un prisma rectangular de análisis
// Botón 2: anotación semiautomática de la pieza insertada en el fémur. Se anotan manualmente algunos slices y se interpolan el resto
// Botón 3: cuantificación de volumen e intensidad de hueso dentro y fuera de la pieza anotada.

macro "Bone Action Tool 1 - C2b4T1d14IT4d14nTcd14iTfd14t"
{

run("Close All");

name=File.openDialog("Select volume to analyze");
open(name);
wait(500);

roiManager("Reset");
run("Clear Results");
MyTitle=getTitle();
fname=getInfo("image.directory");

print("Processing bone "+MyTitle);

//output=getDirectory("Choose output directory for results file");// getInfo("image.directory");
output = fname+File.separator+"Results/";
File.makeDirectory(output);

aa = split(MyTitle,".");
MyTitle_short = aa[0];

Dialog.create("Parameters for the analysis");
Dialog.addNumber("Enter voxel size (mm/pixel)", 0.020);	
Dialog.addMessage("Enter dimensions of the prism for the analysis");
Dialog.addNumber("Height (mm)", 7);
Dialog.addNumber("Width (mm)", 8);
Dialog.show();	
r= Dialog.getNumber();
prismH= Dialog.getNumber();
prismW= Dialog.getNumber();

// Reslice from axial to coronal view
run("Reslice [/]...", "output=1.000 start=Top");
rename("orig");
selectWindow(MyTitle);
close();

/*
waitForUser("Go to the first slice for the analysis and press OK");
selectWindow(MyTitle);
z1 = getSliceNumber();
waitForUser("Go to the last slice for the analysis and press OK");
selectWindow(MyTitle);
z2 = getSliceNumber();
run("Slice Keeper", "first="+z1+" last="+z2+" increment=1");
rename("all");
selectWindow(MyTitle);
close();
selectWindow("all");
rename(MyTitle);
*/

run("Set Measurements...", "area mean display redirect=None decimal=2");

Stack.getDimensions(width, height, channels, slices, frames);
run("Properties...", "channels=1 slices="+slices+" frames=1 unit=mm pixel_width="+r+" pixel_height="+r+" voxel_depth="+r+" frame=[0 sec] origin=0,0");
setSlice(floor(slices/2));
run("Enhance Contrast", "saturated=0.35");


//--PRISM SELECTION

prismHpx = round(prismH/r);
prismWpx = round(prismW/r);
makeRectangle(round(width/2-prismWpx/2), round(height/2-prismHpx/2), prismWpx, prismHpx);
waitForUser(prismH+" mm height prism added. Check height and move it if necessary. Press OK when ready");
q=getBoolean("Would you like to change prism dimensions?", "Change prism dimensions", "Continue with the analysis");
while (q) {
	Dialog.create("Prism dimensions");
	Dialog.addMessage("Enter dimensions of the prism for the analysis");
	Dialog.addNumber("Height (mm)", prismH);
	Dialog.addNumber("Width (mm)", prismW);
	Dialog.show();		
	prismH= Dialog.getNumber();
	prismW= Dialog.getNumber();
	prismHpx = round(prismH/r);
	prismWpx = round(prismW/r);
	makeRectangle(round(width/2-prismWpx/2), round(height/2-prismHpx/2), prismWpx, prismHpx);
	waitForUser(prismH+" mm height prism added. Check height and move it if necessary. Press OK when ready");
	q=getBoolean("Would you like to change prism dimensions?", "Change prism dimensions", "Continue with the analysis");		
}

run("Crop");
wait(100);

saveAs("Tiff", output+MyTitle_short+"_analysisROI.tif");


showMessage("Image ready for monetite scaffold annotations!");

}


macro "Bone Action Tool 2 - N44C73aD1eD1jD2dD2kD3dD4lD6cD6mD7cD7mD8mD9bDaaDb8Db9Dc3Dd2DdnDe1DenDfnDjlDkkDl4Dl5DljDm7Dm8DmhCfffD00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0lD0mD0nD10D11D12D13D14D15D16D17D18D19D1aD1bD1mD1nD20D21D22D23D24D25D26D27D28D29D2aD2bD2nD30D31D32D33D34D35D36D37D38D39D3aD3bD3fD3gD3hD3iD3nD40D41D42D43D44D45D46D47D48D49D4aD4bD4fD4gD4hD4iD4jD50D51D52D53D54D55D56D57D58D59D5aD5fD5gD5hD5iD5jD60D61D62D63D64D65D66D67D68D69D6aD6eD6fD6gD6hD6iD6jD70D71D72D73D74D75D76D77D78D79D7aD7eD7fD7gD7hD7iD7jD7kD80D81D82D83D84D85D86D87D88D89D8eD8fD8gD8hD8iD8jD8kD90D91D92D93D94D95D96D97D98D9dD9eD9fD9gD9hD9iD9jD9kDa0Da1Da2Da3Da4Da5DadDaeDafDagDahDaiDajDakDb0Db1DbcDbdDbeDbfDbgDbhDbiDbjDbkDc0DcbDccDcdDceDcfDcgDchDciDcjDckDd6Dd7Dd8Dd9DdaDdbDdcDddDdeDdfDdgDdhDdiDdjDdkDe4De5De6De7De8De9DeaDebDecDedDeeDefDegDehDeiDejDekDelDf3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDffDfgDfhDfiDfjDfkDflDg3Dg4Dg5Dg6Dg7Dg8Dg9DgaDgbDgcDgdDgeDgfDggDghDgiDgjDgkDh3Dh4Dh5Dh6Dh7Dh8Dh9DhaDhbDhcDhdDheDhfDhgDhhDhiDhjDhkDi3Di4Di5Di6Di7Di8Di9DiaDibDicDidDieDifDigDihDiiDijDj5Dj6Dj7Dj8Dj9DjaDjbDjcDjdDjeDjfDjgDjhDjiDk8Dk9DkaDkbDkcDkdDkeDkfDkgDknDl0DlmDlnDm0Dm1Dm2DmlDmmDmnDn0Dn1Dn2Dn3Dn4DnjDnkDnlDnmDnnCa8cD1dD3cD4mD8lD9nDd3DjkDjmDk1Dl8DlkDm5Dn9DngC85aD0gD2eD5dD5lD5mD8bDb5DbnDc2Dc6DcmDdmDemDfmDl6Dm6DmcDmdCedeD0kD1lD2cD2gD3jD4eD6nD8dDa6DacDbbDblDc9Dg2DglDikDjjDkmDlbDleDllDm3Dn7C74aD5cD8cD9mDabDb6Dc5DcnDf1Di1DimDm9DncDndCcbdD9lDa7Dd4De0Df2Di2DinDj0Dj3DkiDl2DmjDn8DnhC96bD1kD3kDanDbaDf0Dk4DkjDklDl3Dl7DlhDnaCfefD0dD1cD4nD5eD5nD6kD8aD99DcaDdlDe3DjnDk0Dk7DkhDn5Dn6C74aD1fD3lDb7Dc4DhmDj1Dk2DmgCb9dD0jD2fD3eD4kD7bD7dD8nD9aDa8Db3Dc8DhlDk5Dl9DlgC95bD0iD4cD6lDa9Dd1Di0DilDj2DmiDnfCeefD2hD2mD5bDb2DclDd0Dd5Dh2Dj4Dl1DlcDldDmkDniC84aD0hD1gD1hD1iD4dDamDbmDg0Dg1DgmDgnDh0Dh1Dk3DliDmaDmbDmeDmfDnbDneCdceD0eD2iD3mD5kD6bD7nDalDc1Dk6DlaDlfDm4Ca7cD0fD2jD2lD6dD7lD9cDb4Dc7De2Dhn"
{

q=getBoolean("Are you sure you want to create a new annotation?");
if(!q) 
{
	exit();
}
roiManager("Reset");

// Get filename
outDir=getInfo("image.directory");	
MyTitle2=getTitle();
k = indexOf(MyTitle2, "_analysisROI");
MyTitle_short = substring(MyTitle2, 0, k);
MyTitle = MyTitle_short+".tif";

run("ROI Manager...");
roiManager("Show None");
roiManager("Show All");
roiManager("Show All without labels");

//--MANUAL SEGMENTATION OF THE PIECE
waitForUser("Please annotate the contour of the monetite (by pressing 'T' to save it) in as many slices as you want. Intermediate slices will be interpolated. Press OK when you finish the annotation");

// Save current reference ROIs:
roiManager("Deselect");
roiManager("Sort");
roiManager("Save", outDir+MyTitle_short+"_RefROIs.zip");

// Interpolate intermediate ROIs
roiManager("Interpolate ROIs");

// Check and finish or reannotate references
waitForUser("Please check the interpolated ROIs");
q=getBoolean("Would you like to finish the annotation process?","Finish annotation","Revise reference annotations");
if(!q) {
	roiManager("Reset");
	roiManager("Open", outDir+MyTitle_short+"_RefROIs.zip");
	waitForUser("Please draw additional annotations of the contour of the monetite (by pressing 'T' to save them) in as many slices as you want. Press OK when you finish to interpolate intermediate slices again");
	
	// Save current reference ROIs:
	roiManager("Deselect");
	roiManager("Sort");
	roiManager("Save", outDir+MyTitle_short+"_RefROIs.zip");

	// Interpolate intermediate ROIs
	roiManager("Interpolate ROIs");

	waitForUser("Please check the interpolated ROIs");
	q=getBoolean("Would you like to finish the annotation process?","Finish annotation","Revise reference annotations");
}

roiManager("Save", outDir+MyTitle_short+"_AllROIs.zip");

}


macro "Bone Action Tool 3 - N44C222D0hD1fD1jD4mD5fD5nD6nD8iD8mDbfDc8De6Df1Df5Dh0Di8Dm4Dm8Dn6CfffD00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD0kD0lD0mD0nD10D11D12D13D14D15D16D17D18D19D1aD1bD1cD1dD1lD1mD1nD20D21D22D23D24D25D26D27D28D29D2aD2bD2cD2dD2gD2hD2iD2lD2mD2nD30D31D32D33D34D35D36D37D38D39D3aD3bD3cD3dD3gD3hD3iD3nD40D41D42D43D44D45D46D47D48D49D4aD4bD4cD4dD4gD4hD4iD4jD50D51D52D53D54D55D56D57D58D59D5aD5bD5cD5dD5hD5iD5jD5kD5lD60D61D62D63D64D65D66D67D68D69D6aD6bD6cD6gD6hD6iD6jD6kD6lD70D71D72D73D74D75D76D77D78D79D7aD7bD7fD7gD7hD7jD7kD7lD80D81D82D83D84D85D86D87D88D89D8aD8eD8fD8gD90D91D92D93D94D95D96D97D98D99D9dD9eD9fD9nDa0Da1Da2Da3Da4Da5Da6Da7Da8DacDadDaeDaiDajDakDalDamDanDb0Db1Db2Db3Db4Db5Db6Db7DbbDbcDbdDbhDbiDbjDbkDblDbmDbnDc0Dc1Dc2Dc3Dc4Dc5Dc6DcaDcbDccDcgDchDciDcjDckDclDcmDcnDd0Dd1Dd2Dd3Dd4Dd5Dd9DdaDdbDdfDdgDdhDdiDdjDdkDdlDdmDdnDe0De8De9DeaDeeDefDegDehDeiDejDekDelDemDenDf7Df8Df9DfdDfeDffDfgDfhDfiDfjDfkDflDfmDfnDg2Dg3Dg4Dg6Dg7Dg8DgcDgdDgeDgfDggDghDgiDgjDgkDglDgmDgnDh2Dh3Dh4Dh5Dh6Dh7DhbDhcDhdDheDhfDhgDhhDhiDhjDhkDhlDhmDhnDi2Di3Di4Di5Di6DiaDibDicDidDieDifDigDihDiiDijDikDilDimDinDj4Dj5Dj6DjaDjbDjcDjdDjeDjfDjgDjhDjiDjjDjkDjlDjmDjnDk0Dk5Dk6Dk7DkaDkbDkcDkdDkeDkfDkgDkhDkiDkjDkkDklDkmDknDl0Dl1Dl2Dl5Dl6Dl7DlaDlbDlcDldDleDlfDlgDlhDliDljDlkDllDlmDlnDm0Dm1Dm2DmaDmbDmcDmdDmeDmfDmgDmhDmiDmjDmkDmlDmmDmnDn0Dn1Dn2Dn3Dn9DnaDnbDncDndDneDnfDngDnhDniDnjDnkDnlDnmDnnC888D2fD8hD9gDafDc9Dd8De4De7Df6Dj9Dl8C444D2kD3eD3lD8jDf4Dg0Dj8Dk2Dk9Dl3CcccD3jD5eD9mDahDbgDc7Dd6De1De5Di9Dm9C333D0gD0iD3kD6eD7dD7nD8cD9bD9hDaaDagDb9DceDd7DddDecDfbDgaDh9Di0Dj1Dk3Dn5Dn7CaaaD0fD0jD1iD3fD3mD4nD5mDi1Dk1Dk8Dm5Dn8C777D4eD6fD7eD8dD8lD9cDabDbaDbeDcdDdcDebDf2DfaDg9Dh8CfffDj7C999D1gD2jD4lD7mD8kD9jDf3Dg1Dj0Dj2Dl4Dm7Dn4C555D2eD4fD9kDe3Dl9CdddD1hD4kD5gD6dD6mD7cD7iD8bD9aDa9Db8DcfDdeDedDfcDg5DgbDh1DhaDi7Dj3Dk4Dm6CbbbD1eD1kD8nD9iDf0Dm3C666D9lDe2"
{

if(isOpen("boneMaskOut")) {
	selectWindow("boneMaskOut");
	close();
}

if(isOpen("boneMaskIn")) {
	selectWindow("boneMaskIn");
	close();
}

showStatus("Processing bone...");
setBatchMode(true);

// Get filename
outDir=getInfo("image.directory");	
MyTitle2=getTitle();
k = indexOf(MyTitle2, "_analysisROI");
MyTitle_short = substring(MyTitle2, 0, k);
MyTitle = MyTitle_short+".tif";

//--Load ROIs of all slices
roiManager("Reset");
roiManager("Show None");
roiManager("Open", outDir+MyTitle_short+"_AllROIs.zip");

//--Get first annotated slice and number of annotated slices:
nSl = roiManager("count");
if (nSl==0) {
	exit("ERROR: no monetite scaffold has been annotated");
}
roiManager("select", 0);
z1 = getSliceNumber();


selectWindow(MyTitle2);
run("Select None");

//--Parameters
Dialog.create("Parameters for bone quantification");
Dialog.addNumber("Bone threshold", 2800);
Dialog.addCheckbox("Save bone segmentation masks", true);
Dialog.show();	
thBone= Dialog.getNumber();
saveMasks= Dialog.getCheckbox();

run("Set Measurements...", "area mean display redirect=None decimal=2");
Stack.getDimensions(width, height, channels, slices, frames);
getVoxelSize(vx, vy, vz, unit);

//--Segment bone
run("Duplicate...", "title=boneMaskOut duplicate range=1-"+slices);
wait(200);
setSlice(floor(slices/2));
run("Threshold...");
	//thBone=2800;
setThreshold(thBone, 65535);
//setThreshold(120, 255);
run("Convert to Mask", "  white");
run("Median...", "radius=1 stack");
run("Analyze Particles...", "size=0.01-Infinity show=Masks in_situ stack");

//--Duplicate mask for bone inside the cylinder and make it blank to fill it in later
run("Duplicate...", "title=boneMaskIn duplicate range=1-"+slices);
run("Select All");
setBackgroundColor(255, 255, 255);
run("Clear", "stack");

//--Initialize results
run("Clear Results");
Ain=newArray(slices);
Iin=newArray(slices);
Aout=newArray(slices);
Iout=newArray(slices);
AinTot=0;
IinTot=0;
AoutTot=0;
IoutTot=0;

//--From 1st slice to 1st annotated slice:
if (z1!=1) {
for (i=0;i<(z1-1);i++){
	selectWindow("boneMaskOut");
	Stack.setSlice(i+1);	
	run("Create Selection");
	type = selectionType();
	if (type==-1) {	//if there is no selection, signal and area are 0 for that slice
		Aout=0;
		Iout=0;		
	}
	else {
		selectWindow(MyTitle2);
		run("Restore Selection");
		Stack.setSlice(i+1);
		run("Measure");
		k=nResults;
		Aout=getResult("Area",k-1);
		Iout=getResult("Mean",k-1);		
	}	
	// Accumulated values:
	AoutTot = AoutTot+Aout;
	IoutTot = IoutTot+Iout*Aout;		
}
}

//--From 1st annotated slice to last annotated slice:
for (i=0;i<nSl;i++){

	//--Copy content of maskOut to maskIn:
	selectWindow("boneMaskOut");
	Stack.setSlice(i+z1);
	run("Select None");
	run("Create Selection");
	type = selectionType();
	if (type!=-1) {
		selectWindow("boneMaskIn");
		Stack.setSlice(i+z1);
		run("Restore Selection");
		setForegroundColor(0, 0, 0);
		run("Fill", "slice");	
	}	

	//--Interior of the piece:
	selectWindow("boneMaskIn");
	roiManager("select", i);
	setBackgroundColor(255, 255, 255);
	run("Clear Outside", "slice");
	run("Create Selection");
	type = selectionType();
	if (type==-1) {	//if there is no selection, signal and area are 0 for that slice
		Ain=0;
		Iin=0;				
	}
	else {
		selectWindow(MyTitle2);
		run("Restore Selection");
		Stack.setSlice(i+z1);
		run("Measure");
		k=nResults;
		Ain=getResult("Area",k-1);
		Iin=getResult("Mean",k-1);		
	}		
	// Accumulated values:
	AinTot = AinTot+Ain;
	IinTot = IinTot+Iin*Ain;
	
	//--Exterior of the piece:
	selectWindow("boneMaskOut");
	roiManager("select", i);
	setBackgroundColor(255, 255, 255);
	run("Clear", "slice");
	run("Create Selection");
	type = selectionType();
	if (type==-1) {	//if there is no selection, signal and area are 0 for that slice
		Aout=0;
		Iout=0;				
	}
	else {
		selectWindow(MyTitle2);
		run("Restore Selection");
		Stack.setSlice(i+z1);
		run("Measure");
		k=nResults;
		Aout=getResult("Area",k-1);
		Iout=getResult("Mean",k-1);		
	}		
	// Accumulated values:
	AoutTot = AoutTot+Aout;
	IoutTot = IoutTot+Iout*Aout;	
}

//--From 1st slice after annotations to last slice:
if((z1+nSl-1)!=slices) {
for (i=z1+nSl;i<=slices;i++){
	selectWindow("boneMaskOut");
	Stack.setSlice(i);	
	run("Create Selection");
	type = selectionType();
	if (type==-1) {	//if there is no selection, signal and area are 0 for that slice
		Aout=0;
		Iout=0;		
	}
	else {
		selectWindow(MyTitle2);
		run("Restore Selection");
		Stack.setSlice(i);
		run("Measure");
		k=nResults;
		Aout=getResult("Area",k-1);
		Iout=getResult("Mean",k-1);		
	}	
	// Accumulated values:
	AoutTot = AoutTot+Aout;
	IoutTot = IoutTot+Iout*Aout;		
}
}

//--FINAL AVERAGE INTENSITY VALUES:
IinBone = IinTot/AinTot;
IoutBone = IoutTot/AoutTot;
//--TOTAL VOLUMES:
VinBone = AinTot*vz;
VoutBone = AoutTot*vz;

if (saveMasks)
{
	selectWindow("boneMaskOut");
	run("Select None");
	saveAs("Tiff", outDir+MyTitle_short+"_boneMaskOut.tif");
	rename("boneMaskOut");
	selectWindow("boneMaskIn");
	run("Select None");
	saveAs("Tiff", outDir+MyTitle_short+"_boneMaskIn.tif");
	rename("boneMaskIn");
}


//--WRITE RESULTS

run("Clear Results");	
if(File.exists(outDir+"BoneQuantificationResults.xls"))
{
	open(outDir+"BoneQuantificationResults.xls");
	IJ.renameResults("Results");
}
i=nResults;
setResult("Label", i, MyTitle_short); 
setResult("Bone Volume outside scaffold ("+unit+"3)",i,VoutBone);
setResult("Bone Avg Intensity outside scaffold",i,IoutBone);	
setResult("Bone Volume inside scaffold ("+unit+"3)",i,VinBone);
setResult("Bone Avg Intensity inside scaffold",i,IinBone);		
saveAs("Results", outDir+"BoneQuantificationResults.xls");

selectWindow("Threshold");
run("Close");

setBatchMode("exit and display");

selectWindow(MyTitle2);
run("Select None");
selectWindow("boneMaskOut");
run("Select None");
selectWindow("boneMaskIn");
run("Select None");

run("Synchronize Windows");

showMessage("Bone quantification inside and outside monetite scaffold finished!");

}
