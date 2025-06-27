// Changelog February 2022
// Usamos la imagen PRE para segmentar hueso cortical
// La imagen POST es el mismo animal con el hueso descalcificado y lo que se ve hiper-intenso es el osmio, que marca grasa
// Las dos imágenes están ya previamente registradas manualmente en Mevislab
// Hay que cuantificar volumen de grasa dentro de la cortical, normalizado por el volumen total del hueco

macro "Bone Action Tool - Cf00T4d15Bio"
{

waitForUser("Select PRE image and press OK");

roiManager("Reset");
run("Clear Results");
MyTitle=getTitle();
fname=getInfo("image.directory");

rename("pre");

waitForUser("Select POST image and press OK");
rename("post");

print("Processing bone "+MyTitle);

output = File.getParent(fname);

outDir = output+File.separator+"Results/";
File.makeDirectory(outDir);

aa = split(MyTitle,".");
MyTitle_short_temp = aa[0];
MyTitle_short = substring(MyTitle_short_temp, 0, lengthOf(MyTitle_short_temp)-4);
print(MyTitle_short);

Dialog.create("Parameters for the analysis");
Dialog.addNumber("Enter voxel size (mm/pixel)", 0.020);	
Dialog.addNumber("Enter bone threshold", 700);	
Dialog.addNumber("Enter fat threshold", 7000);	
Dialog.show();	
r= Dialog.getNumber();
thBone= Dialog.getNumber();
thFat= Dialog.getNumber();

waitForUser("Go to the first slice for the analysis and press OK");
z1 = getSliceNumber();
waitForUser("Go to the last slice for the analysis and press OK");
z2 = getSliceNumber();

selectWindow("pre");
run("Slice Keeper", "first="+z1+" last="+z2+" increment=1");
rename("all");
selectWindow("pre");
close();
selectWindow("all");
rename("pre");

selectWindow("post");
run("Slice Keeper", "first="+z1+" last="+z2+" increment=1");
rename("all");
selectWindow("post");
close();
selectWindow("all");
rename("post");

run("Set Measurements...", "area mean display redirect=None decimal=4");

selectWindow("pre");
Stack.getDimensions(width, height, channels, slices, frames);
run("Properties...", "channels=1 slices="+slices+" frames=1 unit=mm pixel_width="+r+" pixel_height="+r+" voxel_depth="+r+" frame=[0 sec] origin=0,0");
setSlice(floor(slices/2));
//run("Enhance Contrast", "saturated=0.35");

selectWindow("post");
Stack.getDimensions(width, height, channels, slices, frames);
run("Properties...", "channels=1 slices="+slices+" frames=1 unit=mm pixel_width="+r+" pixel_height="+r+" voxel_depth="+r+" frame=[0 sec] origin=0,0");
setSlice(floor(slices/2));
//run("Enhance Contrast", "saturated=0.35");


showStatus("Processing bone...");

//--SEGMENT BONE

selectWindow("pre");
run("Duplicate...", "title=outer duplicate");
wait(200);
setAutoThreshold("Default dark");
getThreshold(lower, upper);
  //thBone=700;
setThreshold(thBone, upper);
setOption("BlackBackground", false);
run("Convert to Mask", "method=Default background=Dark");
run("Duplicate...", "title=inner duplicate");
selectWindow("outer");
run("Options...", "iterations=1 count=1 do=Close stack");
run("Fill Holes", "stack");
run("Median...", "radius=1 stack");
run("Analyze Particles...", "size=30-Infinity pixel circularity=0.00-1.00 show=Masks in_situ stack");
run("Select None");
run("Keep Largest Region");
wait(200);
selectWindow("outer");
close();
selectWindow("outer-largest");
rename("outer");

//--Get a mask of bone marrow
imageCalculator("AND stack", "inner","outer");
imageCalculator("XOR create stack", "outer","inner");
imageCalculator("AND stack", "Result of outer","outer");

run("Options...", "iterations=1 count=1 do=Open stack");
/*it=1;
for(j=1;j<it;j++){
	run("Dilate", "stack");
	//run("Dilate");
}
//run("Fill Holes", "stack");
for(j=1;j<it;j++){
	run("Erode", "stack");
}*/
run("Median...", "radius=1 stack");

selectWindow("Result of outer");
rename("marrow");

selectWindow("outer");
close();
selectWindow("inner");
close();


//--SEGMENT FAT

selectWindow("post");
run("Duplicate...", "title=fat duplicate");
wait(200);
setAutoThreshold("Default dark");
getThreshold(lower, upper);
  //thFat=7000;
setThreshold(thFat, upper);
setOption("BlackBackground", false);
run("Convert to Mask", "method=Default background=Dark");

//--Keep only fat in the bone marrow space
imageCalculator("AND stack", "fat","marrow");


//--MEASURE VOLUMES

run("Clear Results");
selectWindow("fat");
run("Create Selection");
run("Select None");
run("Statistics");
Vfat=getResult("Volume(mm^3)",0);
print("Fat volume: "+Vfat+" mm^3");

run("Clear Results");
selectWindow("marrow");
run("Create Selection");
run("Select None");
run("Statistics");
Vmarrow=getResult("Volume(mm^3)",0);
print("Bone marrow volume: "+Vmarrow+" mm^3");

rFat = Vfat/Vmarrow*100;
print("Fat ratio: "+rFat+"%");


//--SAVE MASKS

selectWindow("pre");
run("Select None");
saveAs("Tiff", outDir+File.separator+MyTitle_short+"_PRE.tif");
selectWindow("post");
run("Select None");
saveAs("Tiff", outDir+File.separator+MyTitle_short+"_POST.tif");
selectWindow("fat");
run("Select None");
saveAs("Tiff", outDir+File.separator+MyTitle_short+"_fatMask.tif");
selectWindow("marrow");
run("Select None");
saveAs("Tiff", outDir+File.separator+MyTitle_short+"_marrowMask.tif");


// WRITE RESULTS--

run("Clear Results");
if(File.exists(output+File.separator+"FatQuantification.xls"))
{
	//if exists add and modify
	open(output+File.separator+"FatQuantification.xls");
	IJ.renameResults("Results");
}
i=nResults;
setResult("Label", i, MyTitle_short); 
setResult("Fat volume (mm3)",i,Vfat);
setResult("Bone marrow volume (mm3)",i,Vmarrow);
setResult("Fat ratio (%)",i,rFat);
saveAs("Results", output+File.separator+"FatQuantification.xls");


run("Synchronize Windows");

showMessage("Done!");

}
