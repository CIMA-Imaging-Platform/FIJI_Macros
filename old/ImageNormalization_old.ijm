// changelog October2020

var gridX=4, gridY=4;

macro "Normalization Action Tool - Ca3fT0b10NT7b10OTfb10R"{
	
InDir=getDirectory("Choose an input directory");
list=getFileList(InDir);
L=lengthOf(list);
//Array.show(list);
print(InDir);

setBatchMode(true);

parentFolder = File.getParent(InDir);
caseFolder = substring(InDir, lengthOf(parentFolder)+1, lengthOf(InDir)-1);
mainFolder = parentFolder+File.separator+caseFolder+"_Out";
File.makeDirectory(mainFolder);

//////////////////////////////////
// RENAMING FILES:
//////////////////////////////////

print("/////////////////////////////////");
print("Renaming files...");
print("/////////////////////////////////");
showStatus("Renaming files...");

// Determine if we need 'Renaming+Stitching' (WSI) or not (TMAs):
Dialog.create("Processing Mode");
modeArray=newArray("Whole-slide stamps (need of stitching)","TMA cores (no need of stitching)");
Dialog.addMessage("Please choose the type of images to process")
Dialog.addRadioButtonGroup("Modes", modeArray,2, 1, "Whole-slide stamps (need of stitching)");
Dialog.show();
obj=Dialog.getRadioButton();

// Process
OutDir = mainFolder+File.separator+caseFolder+"_Renamed";
File.makeDirectory(OutDir);
imcc=0;	// image counter
newNames = newArray(L);
for (i=0; i<L; i++)
{	
	imcc=i+1;
	name=list[i];
	print(name);
	if(obj=="Whole-slide stamps (need of stitching)") {
		aa = split(name,"[");
		MyTitle_short = aa[0];
		// Rename files
		if(imcc<10) { newNames[i] = MyTitle_short+"0"+imcc+".tif"; }			
		else { newNames[i] = MyTitle_short+imcc+".tif"; }
	}
	if(obj=="TMA cores (no need of stitching)") {
		newNames[i] = name;	// copy the file with the original name
	}
	File.copy(InDir+name, OutDir+File.separator+newNames[i]); 	
}


//////////////////////////////////
// NORMALIZING PER CHANNEL:
//////////////////////////////////

print("/////////////////////////////////");
print("Normalizing per channel...");
print("/////////////////////////////////");
showStatus("Normalizing per channel...");

newInDir = mainFolder+File.separator+caseFolder+"_Renamed";
OutDirCh = mainFolder+File.separator+caseFolder+"_Channels";
File.makeDirectory(OutDirCh);
//setBatchMode(true);

// Open all the images
for (i=0; i<L; i++)
{	
	run("Bio-Formats Importer", "open="+newInDir+File.separator+newNames[i]+" autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
	wait(100);
	rename(newNames[i]);
	if (i==0) { getDimensions(width, height, channels, slices, frames); }
	run("Make Composite", "display=Color");
	run("Split Channels");
	
}

// Creating and processing channels:
for (c=1; c<=channels; c++)
{
	run("Images to Stack", "name=Channel"+c+" title=C"+c+"- use");	
	saveAs("Tiff", OutDirCh+File.separator+"Channel"+c+".tif");	
}

setBatchMode("exit and display");
getPixelSize(unit, pixelWidth, pixelHeight);

//////////////////////////////////////////////
///// IMAGE ENHANCEMENT PER CHANNEL
//////////////////////////////////////////////

for (c=1; c<=channels; c++)
{

	//open(OutDirCh+File.separator+"Channel"+c+".tif");
	selectWindow("Channel"+c+".tif");
	waitForUser("Please inspect Channel "+c+" for background correction and press OK when ready");

	//////////////////////////////////////////////
	///// BACKGROUND CORRECTION
	//////////////////////////////////////////////
	
	Dialog.create("Processing Mode");
	modeArray=newArray("BaSiC","Rolling Ball","None");
	Dialog.addMessage("Please choose a background correction method for channel "+c);
	Dialog.addRadioButtonGroup("Methods", modeArray,3, 1, "BaSiC");
	Dialog.show();
	objBkg=Dialog.getRadioButton();

	if (objBkg=="BaSiC") {
	
		//////////////////////////////////////////////
		///// BaSiC shading and illumination correction
		//////////////////////////////////////////////
		
		print("/////////////////////////////////");
		print("Applying BaSiC...");
		print("/////////////////////////////////");
		showStatus("Applying BaSiC...");
	
		setBatchMode(true);
		
		// We first get the scale to set it at the end because BaSiC loses it:
		run("Set Scale...", "distance=1 known="+pixelWidth+" unit="+unit+" global");		
		
		showStatus("Applying BaSiC...");
		selectWindow("Channel"+c+".tif");
		//run("BaSiC ", "processing_stack="+"Channel"+c+".tif"+" flat-field=None dark-field=None shading_estimation=[Estimate shading profiles] shading_model=[Estimate both flat-field and dark-field] setting_regularisationparametes=Automatic temporal_drift=Ignore correction_options=[Compute shading and correct images] lambda_flat=0.50 lambda_dark=0.50");
		run("BaSiC ");
		wait(100);
		if (isOpen("Flat-field:Channel"+c+".tif")) {
			selectWindow("Flat-field:Channel"+c+".tif");
			close();
		}
		if (isOpen("Dark-field:Channel"+c+".tif")) {
			selectWindow("Dark-field:Channel"+c+".tif");
			close();
		}
		selectWindow("Channel"+c+".tif");	
		close();
		selectWindow("Corrected:Channel"+c+".tif");	
		rename("Channel"+c+".tif");			
	
		setBatchMode("exit and display");
	
		//////////////////////////////////////////////
		///// Rolling Ball background correction
		//////////////////////////////////////////////

		waitForUser("BaSiC applied to channel "+c+". Please inspect the result and press OK when ready");
		q=getBoolean("Do you want to also apply the Rolling Ball background correction to channel "+c+"?", "Apply rolling ball", "Do not apply rolling ball");
		if(q) {
			print("/////////////////////////////////");
			print("Applying Rolling Ball...");
			print("/////////////////////////////////");
			showStatus("Applying Rolling Ball...");
			
			rad = getNumber("Choose ball radius (in px)", 50);			
			selectWindow("Channel"+c+".tif");
			run("Subtract Background...", "rolling="+rad+" stack");
			
		}
	
	}
	
	if (objBkg=="Rolling Ball") {
	
		//////////////////////////////////////////////
		///// Rolling Ball background correction
		//////////////////////////////////////////////
	
		print("/////////////////////////////////");
		print("Applying Rolling Ball...");
		print("/////////////////////////////////");
		showStatus("Applying Rolling Ball...");
	
		rad = getNumber("Choose ball radius (in px)", 50);	
		selectWindow("Channel"+c+".tif");
		run("Subtract Background...", "rolling="+rad+" stack");
			
		//////////////////////////////////////////////
		///// BaSiC shading and illumination correction
		//////////////////////////////////////////////

		waitForUser("Rolling Ball background correction applied to channel "+c+". Please inspect the result and press OK when ready");
		q=getBoolean("Do you want to also apply BaSiC to channel "+c+"?", "Apply BaSiC", "Do not apply BaSiC");
		if(q) {
			
			print("/////////////////////////////////");
			print("Applying BaSiC...");
			print("/////////////////////////////////");
			showStatus("Applying BaSiC...");
	
			setBatchMode(true);
			
			// We first get the scale to set it at the end because BaSiC loses it:
			run("Set Scale...", "distance=1 known="+pixelWidth+" unit="+unit+" global");
						
			showStatus("Applying BaSiC...");
			selectWindow("Channel"+c+".tif");
			//run("BaSiC ", "processing_stack="+"Channel"+c+".tif"+" flat-field=None dark-field=None shading_estimation=[Estimate shading profiles] shading_model=[Estimate both flat-field and dark-field] setting_regularisationparametes=Automatic temporal_drift=Ignore correction_options=[Compute shading and correct images] lambda_flat=0.50 lambda_dark=0.50");
			run("BaSiC ");
			wait(100);
			if (isOpen("Flat-field:Channel"+c+".tif")) {
				selectWindow("Flat-field:Channel"+c+".tif");
				close();
			}
			if (isOpen("Dark-field:Channel"+c+".tif")) {
				selectWindow("Dark-field:Channel"+c+".tif");
				close();
			}			
			selectWindow("Channel"+c+".tif");	
			close();
			selectWindow("Corrected:Channel"+c+".tif");	
			rename("Channel"+c+".tif");			
						
			setBatchMode("exit and display");
			
		}	
	
	}

	//////////////////////////////////////////////
	///// Contrast Enhancement
	//////////////////////////////////////////////
	
	print("/////////////////////////////////");
	print("Enhancing contrast...");
	print("/////////////////////////////////");
	showStatus("Enhancing contrast...");
	
	OutDirEnhanced = mainFolder+File.separator+caseFolder+"_Enhanced";
	File.makeDirectory(OutDirEnhanced);

	if (objBkg!="None") {
		waitForUser("Background correction finished for channel "+c+". Please inspect the result and press OK when ready");
	}	
	q = getBoolean("Do you want to apply Contrast Enhancement to channel "+c+"?", "Apply Contrast Enhancement", "Do not apply Contrast Enhancement");
	if(q) {		
		selectWindow("Channel"+c+".tif");
		run("Enhance Contrast...", "saturated=0.3 normalize process_all use");			
	}

	selectWindow("Channel"+c+".tif");
	saveAs("Tiff", OutDirEnhanced+File.separator+"Channel"+c+".tif");
	wait(100);
	close();

}


//////////////////////////////////////////////
///// Merge Channels and Stitching (if necessary)
//////////////////////////////////////////////

setBatchMode(true);

if(obj=="Whole-slide stamps (need of stitching)") {

	for (c=1; c<=channels; c++)
	{
		open(OutDirEnhanced+File.separator+"Channel"+c+".tif");
		selectWindow("Channel"+c+".tif");	
		// Save as image sequence for stitching:	
		run("Image Sequence... ", "format=TIFF name=Channel"+c+" digits=0 use save="+OutDirEnhanced+File.separator+"Corrected_Channel"+c+".tif");
		selectWindow("Channel"+c+".tif");	
		close();
	}

	//////////////////////////////////////////////
	///// Stitching per channel
	//////////////////////////////////////////////
	
	print("/////////////////////////////////");
	print("Image stitching...");
	print("/////////////////////////////////");
	showStatus("Image stitching...");

	Dialog.create("Stiching parameters");	
	Dialog.addMessage("Choose grid size")	
	Dialog.addNumber("Number of rows", gridY);		
	Dialog.addNumber("Number of columns", gridX); 
	Dialog.show();	
	gridY= Dialog.getNumber();
	gridX= Dialog.getNumber();
		
	for (c=1; c<=channels; c++)
	{
		run("Grid/Collection stitching", "type=[Grid: column-by-column] order=[Down & Right                ] grid_size_x="+gridX+" grid_size_y="+gridY+" tile_overlap=0 first_file_index_i=1 directory="+OutDirEnhanced+" file_names=C"+c+"-"+MyTitle_short+"{ii}.tif output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 subpixel_accuracy computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");
		rename("Fused_Channel_"+c+".tif");
		
	}


	//////////////////////////////////////////////
	///// Merge channels to create composite
	//////////////////////////////////////////////
	
	OutDirFinal = mainFolder+File.separator+caseFolder+"_StitchedComposite";
	File.makeDirectory(OutDirFinal);
	// Need to do one case for each number of channels possible:
	if (channels==2) {
		run("Merge Channels...", "c1=Fused_Channel_1.tif c2=Fused_Channel_2.tif create"); }
	else if (channels==3) {
		run("Merge Channels...", "c1=Fused_Channel_1.tif c2=Fused_Channel_2.tif c3=Fused_Channel_3.tif create"); }
	else if (channels==4) {
		run("Merge Channels...", "c1=Fused_Channel_1.tif c2=Fused_Channel_2.tif c3=Fused_Channel_3.tif c4=Fused_Channel_4.tif create"); }
	else if (channels==5) {
		run("Merge Channels...", "c1=Fused_Channel_1.tif c2=Fused_Channel_2.tif c3=Fused_Channel_3.tif c4=Fused_Channel_4.tif c5=Fused_Channel_5.tif create"); }
	else if (channels==6) {
		run("Merge Channels...", "c1=Fused_Channel_1.tif c2=Fused_Channel_2.tif c3=Fused_Channel_3.tif c4=Fused_Channel_4.tif c5=Fused_Channel_5.tif c6=Fused_Channel_6.tif create"); }
	else if (channels==7) {
		run("Merge Channels...", "c1=Fused_Channel_1.tif c2=Fused_Channel_2.tif c3=Fused_Channel_3.tif c4=Fused_Channel_4.tif c5=Fused_Channel_5.tif c6=Fused_Channel_6.tif c7=Fused_Channel_7.tif create"); }

	else if (channels>=8) {		// if it's more than 7 channels we cannot merge them and create a composite
		run("Images to Stack", "name=Stack title="+MyTitle_short+" use");
		run("Re-order Hyperstack ...", "channels=[Slices (z)] slices=[Channels (c)] frames=[Frames (t)]");
	}
	
	// Save composite:
	run("Set Scale...", "distance=1 known="+pixelWidth+" unit="+unit);
	saveAs("Tiff", OutDirFinal+File.separator+MyTitle_short+".tif");
	setBatchMode(false);
	
}

if(obj=="TMA cores (no need of stitching)") {

	print("/////////////////////////////////");
	print("Merging final TMA cores...");
	print("/////////////////////////////////");
	showStatus("Merging final TMA cores...");

	OutDirFinal = mainFolder+File.separator+caseFolder+"_CompositeTMAs";
	File.makeDirectory(OutDirFinal);

	//////////////////////////////////////////////
	///// Separate channel stacks
	//////////////////////////////////////////////
	for (c=1; c<=channels; c++)
	{
		open(OutDirEnhanced+File.separator+"Channel"+c+".tif");
		selectWindow("Channel"+c+".tif");
		run("Stack to Images");
	}
	setBatchMode("exit and display");
	
	//////////////////////////////////////////////
	///// Merge channels of each TMA core
	//////////////////////////////////////////////
	for (i=0; i<L; i++)
	{	
		name=list[i];
		print(name);
		aa = split(name,".");
		MyTitle_short = aa[0];		
		// Need to do one case for each number of channels possible:
		if (channels==2) {
			run("Merge Channels...", "c1=C1-"+MyTitle_short+" c2=C2-"+MyTitle_short+" create"); }
		else if (channels==3) {
			run("Merge Channels...", "c1=C1-"+MyTitle_short+" c2=C2-"+MyTitle_short+" c3=C3-"+MyTitle_short+" create"); }
		else if (channels==4) {
			run("Merge Channels...", "c1=C1-"+MyTitle_short+" c2=C2-"+MyTitle_short+" c3=C3-"+MyTitle_short+" c4=C4-"+MyTitle_short+" create"); }
		else if (channels==5) {
			run("Merge Channels...", "c1=C1-"+MyTitle_short+" c2=C2-"+MyTitle_short+" c3=C3-"+MyTitle_short+" c4=C4-"+MyTitle_short+" c5=C5-"+MyTitle_short+" create"); }
		else if (channels==6) {
			run("Merge Channels...", "c1=C1-"+MyTitle_short+" c2=C2-"+MyTitle_short+" c3=C3-"+MyTitle_short+" c4=C4-"+MyTitle_short+" c5=C5-"+MyTitle_short+" c6=C6-"+MyTitle_short+" create"); }
		else if (channels==7) {
			run("Merge Channels...", "c1=C1-"+MyTitle_short+" c2=C2-"+MyTitle_short+" c3=C3-"+MyTitle_short+" c4=C4-"+MyTitle_short+" c5=C5-"+MyTitle_short+" c6=C6-"+MyTitle_short+" c7=C7-"+MyTitle_short+" create"); }

		else if (channels>=8) {		// if it's more than 7 channels we cannot merge them and create a composite
			run("Images to Stack", "name=Stack title="+MyTitle_short+" use");
			run("Re-order Hyperstack ...", "channels=[Slices (z)] slices=[Channels (c)] frames=[Frames (t)]");
		}
	
		// Save composite:
		saveAs("Tiff", OutDirFinal+File.separator+MyTitle_short+".tif");
		run("Set Scale...", "distance=1 known="+pixelWidth+" unit="+unit);
		setBatchMode(false);
		wait(100);
		close();
	}

}

showMessage("Done!");

}



