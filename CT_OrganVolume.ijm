function macroInfo(){

// * Semiautomatic segmentation of 3D organs in microCT images
// * Target User: General
// *

	scripttitle= "Semiautomatic segmentation of 3D organs in microCT images";
	version= "1.02";
	date= "2025";


// *  Tests Images:

	imageAdquisition="microCT images";
	imageType="3D tiff (Grayscale)";
	voxelSize="Voxel size: user-defined at runtime";
	format="Format: .tif";

 //*  GUI User Requirements:
 //*    - Single File Mode
 //*    - Right-click buttons to tune parameters
 // Important Parameters: right-click Im or Dir button

	// Parameters:
	parameter1="r= Voxel size (micron/pixel). Default: 20 um/px. Set at runtime.";
	parameter2="grayscaleTol= Grayscale tolerance for Level Sets segmentation [0-255]. Default: 10.";
	parameter3="enlargement= ROI expansion between slices (px). Default: 8.";
	parameter4="minorganSection= Minimum organ section area (px) to consider convergence valid. Default: 10.";
	parameter5="sizeFacPerc= Organ-growth tolerance between consecutive slices (%). Default: 5.";
	parameter6="maxSlicesConverg= Maximum number of slices allowed without convergence. Default: 5.";

 //  2 Action tools:
	buttom1="Init: Single File processing. Open image and set voxel size.";
	buttom2="Organ: Start Reference Annotation and Volume Quantification";

//  OUTPUT

// Analyzed Images with ROIs

	excel="CT_OrganVolumeResults.xls";
	feature1="Label";
	feature2="Organ #";
	feature3="Organ Volume (micron^3)";
	feature4="Organ Equivalent Diameter (microns)";
	feature5="Organ ROI Volume (micron^3)";
	feature6="Ratio VolROI/VolOrgan";

/*
 *  version: 1.02
 *  Author: Tomas Muñoz 2025
 *
 */

//	MIT License
//	Copyright (c) 2025 Tomas Muñoz tmsantoro@unav.es
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.

	showMessage("ImageJ Script", "<html>"
    + "<head>"
    + "<style>"
    + "h1, h2, h3, h4, h5, h6 {margin-top: 5px; margin-bottom: 5px;}"
    + "p {margin: 0px; padding: 0px;}"
    + "ol, ul {margin-left: 20px; padding: 5px;}"
    + "#list-style-3 {list-style-type: circle;}"
    + ".container {max-width: 1200px; max-width: 2000px; margin: 0 auto; padding: 0px;}"
    + ".text-column {float: left; width: 1200px; padding-right: 20px;}"
    + ".image-column img {width: 100%; height: 100%;}"
    + "</style>"
    + "</head>"
    + "<body>"
    + "<div class='container'>"
    + "<div class='text-column'>"
    + "<h1 style='color: teal;'>CIMA: Imaging Platform</h1>"
    + "<h2 style='color: purple;'><i>Software Development Service</i></h2>"
    + "<p><i>ImageJ Macros</i></p>"
    + "<h3>" + scripttitle + "</h3>"
    + "<p>Modified by Tomas Muñoz Santoro</p>"
    + "<p>Version: " + version + " (" + date + ")</p>"
    + "<p>Contact: tmsantoro@unav.es</p>"
    + "<p>Available under the <a href='https://opensource.org/licenses/MIT/'>MIT License</a></p>"
    + "<p><i>Video Tutorial:</i> <a href='https://drive.google.com/file/d/1c23FpjLXepu7-hoEqiVSL4eB18cXXGFF/view?usp=sharing' target='_blank'>Watch the video tutorial</a></p>"
    + "<h3>Developed for</h3>"
    + "<p><i>INPUT IMAGES</i></p>"
    + "<ul>"
    + "<li>" + imageAdquisition + "</li>"
    + "<li>" + imageType + "</li>"
    + "<li>" + voxelSize + "</li>"
    + "<li>" + format + "</li>"
    + "</ul>"
    + "<p><i>ACTION TOOLS (Buttons)</i></p>"
    + "<ol>"
    + "<li>" + buttom1 + "</li>"
    + "<li>" + buttom2 + "</li>"
    + "</ol>"
    + "<p><i>PARAMETERS:</i></p>"
    + "<ul>"
    + "<li>" + parameter1 + "</li>"
    + "<li>" + parameter2 + "</li>"
    + "<li>" + parameter3 + "</li>"
    + "<li>" + parameter4 + "</li>"
    + "<li>" + parameter5 + "</li>"
    + "<li>" + parameter6 + "</li>"
    + "</ul>"
    + "<p><i>QUANTIFICATION RESULTS</i></p>"
    + "<p>Analyzed Images folder: Visualize Segmented Images</p>"
    + "<p>Excel " + excel + "</p>"
    + "<ul>"
    + "<li>" + feature1 + "</li>"
    + "<li>" + feature2 + "</li>"
    + "<li>" + feature3 + "</li>"
    + "<li>" + feature4 + "</li>"
    + "<li>" + feature5 + "</li>"
    + "<li>" + feature6 + "</li>"
    + "</ul>"
    + "</div>"
    + "</div>"
    + "</body>"
    + "</html>");

}


var r=20, grayscaleTol=10, enlargement=8, minorganSection=10, sizeFacPerc=5, maxSlicesConverg=5;

macro "organ Action Tool 1 - C2b4T1b10IT4b10nTab10iTdb10t"
{
	run("Fresh Start");
	roiManager("Reset");
	close("ROI Manager");
	run("Clear Results");
	run("Remove Overlay");
	close("*");	
	run("Close All");

	macroInfo();

	name=File.openDialog("Select File");
	open(name);
	
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	fname=getInfo("image.directory");
	
	print("Processing image "+MyTitle);
	
		
	//output=getDirectory("Choose output directory for results file");// getInfo("image.directory");
	outDir = fname+File.separator+"AnalyzedImages/";
	File.makeDirectory(outDir);
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	rename("orig");
	
	//save info
	print("\\Clear");
	print(outDir);
	print(MyTitle);
	selectWindow("Log");
	saveAs("Text",fname+File.separator+"imInfo.txt");
	run("Close");	
	
	r = getNumber("Enter voxel size (micron/pixel)", r);
	
	Stack.getDimensions(width, height, channels, slices, frames);
	run("Properties...", "channels=1 slices="+slices+" frames=1 unit=um pixel_width="+r+" pixel_height="+r+" voxel_depth="+r+" frame=[0 sec] origin=0,0");
	setSlice(floor(slices/2));
	//run("Enhance Contrast", "saturated=0.35");
		
	run("Set Measurements...", "area mean centroid redirect=None decimal=2");
	
	showMessage("Image ready for organ annotations!");

}
/*
macro "organ Action Tool 2 - Ca3fT0b10AT6b10uTcb10tTfb10o" 
{

	macroInfo();

	Dialog.create("Parameters for the analysis");
	Dialog.addNumber("Grayscale tolerance for Level Sets", grayscaleTol);	
	Dialog.addNumber("ROI expansion between slices (px)", enlargement);	
	Dialog.addNumber("Minimum organ section (px)", minorganSection);	
	Dialog.addNumber("organ-growth tolerance between slices (%)", sizeFacPerc);	
	Dialog.addNumber("Max number of slices without convergence", maxSlicesConverg);		
	Dialog.show();	
	grayscaleTol= Dialog.getNumber();
	enlargement= Dialog.getNumber();
	min= Dialog.getNumber();	
	sizeFacPerc= Dialog.getNumber();
	maxSlicesConverg= Dialog.getNumber();

	// Calculate organ-growth between slices as factor:
	sizeFac = 1+sizeFacPerc/100;
		
	roiManager("Reset");
	run("Clear Results");
	run("Remove Overlay");
	
	//get info of original image
	selectWindow("orig");
	wait(200);
	Stack.getDimensions(width, height, channels, slices, frames);
	getVoxelSize(rx, ry, rz, unit);
	r=rx;	//the three are equal
	
	fname=getInfo("image.directory");	
	outDir = fname+File.separator+"Results/";
	
	Fstring=File.openAsString(outDir+"imInfo.txt");
	strA=split(Fstring,"\n");
	temp=strA[0];
	MyTitle=strA[1];
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	// Open already annotated organs:
	if(File.exists(outDir+MyTitle_short+"_organs.zip"))
	{
		roiManager("Open", outDir+MyTitle_short+"_organs.zip");	
	}
	
	// Show them as overlays:
	nn=roiManager("count");
	if(nn>0) {
		roiManager("Show All with labels");
		run("From ROI Manager");
	}
	
	
	// ANNOTATE organ IN ITS CENTRAL SLICE (WHERE THE organ LOOKS BIGGER)
	
	selectWindow("orig");
	//setSlice(floor(slices/2));
	setTool("oval");
	waitForUser("Please go to the central slice of the organ and draw an area surrounding it, close to the contour. Press OK when ready");
	type=selectionType();
	if (type==-1) {
		waitForUser("No selection has been drawn. Please go to the central slice of the organ and draw an area surrounding it, close to the contour. Press OK when ready");
		type2=selectionType();
		if (type2==-1) {
			exit("No selection detected. No further action will be performed");
		}
	}
	roiManager("Add");		// ROI0 --> Initialization contour outside the organ
	s = getSliceNumber();	// Slice number of central slice of the organ
	
	// Save annotated organs including current one:
	roiManager("deselect");
	roiManager("Save", outDir+MyTitle_short+"_organs.zip");	
	
	// Delete previous ones and keep only current one:
	nn=roiManager("count");
	norgan=nn;
	while(nn>1) {
		roiManager("select", 0);
		roiManager("delete");
		nn=roiManager("count");
	}
	run("Remove Overlay");
	
	setBatchMode(true);
	run("Select All");
	run("Duplicate...", "title=slice");
	run("8-bit");
	roiManager("Select", 0);
	run("Set Scale...", "distance=0 known=0 unit=pixel");
	run("Mean...", "radius=1");
	
	//--Set a darker pixel inside to avoid level sets errors:
	run("Clear Results");
	run("Measure");
	cx=getResult("X", 0);
	cy=getResult("Y", 0);
	ca=getResult("Area", 0);	//area of organ from previous slice
	cm=getResult("Mean", 0);	//mean gray value of the inside
	setPixel(round(cx), round(cy), round(cm/2));	// set the pixel in the centroid to half the average intensity of the region (make it darker)
	run("Clear Results");
		
	//--Level Sets:
	//--Inside-out:
	//run("Level Sets", "method=[Active Contours] use_level_sets grey_value_threshold=50 distance_threshold=0.50 advection=1.50 propagation=1 curvature=1 grayscale=5 convergence=0.0050 region=outside");
	//--Outside-in:
	run("Level Sets", "method=[Active Contours] use_level_sets grey_value_threshold=50 distance_threshold=0.50 advection=0.8 propagation=1 curvature=2.5 grayscale="+grayscaleTol+" convergence=0.0100 region=inside");
	//run("Level Sets", "method=[Active Contours] use_level_sets grey_value_threshold=50 distance_threshold=0.50 advection=0.8 propagation=1 curvature=2.5 grayscale=10 convergence=0.0100 region=inside");
	
	run("Invert LUT");
	run("Create Selection");
	type=selectionType();
	if (type==-1) {
		roiManager("Reset");
		roiManager("Open", outDir+MyTitle_short+"_organs.zip");	
		n=roiManager("count");
		roiManager("select", n-1);
		roiManager("delete");
		roiManager("deselect");
		n=roiManager("count");
		if(n>0) {
			roiManager("Save", outDir+MyTitle_short+"_organs.zip");	
		}
		else {
			File.delete(outDir+MyTitle_short+"_organs.zip");
		}
		selectWindow("orig");
		run("Select None");
		exit("The contour does not converge to a organ. Please change initial contour or Level Sets parameters and run the program again, or quantify organ manually");
	}
	roiManager("Add");
	close();
	selectWindow("Segmentation progress of slice");
	close();
	selectWindow("slice");
	close();
	selectWindow("orig");
	roiManager("Select", 0);
	roiManager("Delete");
	roiManager("Select", 0);
	roiManager("Add");
	roiManager("Delete");		// ROI0 --> Contour of organ in central slice, in original stack and with the associated slice number
	
	
	//--GO DOWN IN THE SLICES
	
	//s=166;
	sDown=s;	
	cc=0;
	ccConverg=0;
	while(sDown>1)
	{	
		sDown--;
		selectWindow("orig");
		setSlice(sDown);
		run("Duplicate...", "title=slice");
		run("8-bit");
		run("Set Scale...", "distance=0 known=0 unit=pixel");
		run("Mean...", "radius=1");
		run("Clear Results");
		
		//--Paint a darker pixel in the centroid in case the contour completely collapses to 0, to avoid Level Sets errors:
		roiManager("Select", cc);
		run("Measure");
		cx=getResult("X", 0);
		cy=getResult("Y", 0);
		ca=getResult("Area", 0);	//area of organ from previous slice
		cm=getResult("Mean", 0);	//mean gray value of the inside
		setPixel(round(cx), round(cy), round(cm/2));	// set the pixel in the centroid to half the average intensity of the region (make it darker)
		
			//enlargement=8;
		run("Enlarge...", "enlarge="+enlargement+" pixel");
	
		//--Level Sets:
		//--Inside-out:
		//run("Level Sets", "method=[Active Contours] use_level_sets grey_value_threshold=50 distance_threshold=0.50 advection=1.50 propagation=1 curvature=1 grayscale=5 convergence=0.0050 region=outside");
		//--Outside-in:
		run("Level Sets", "method=[Active Contours] use_level_sets grey_value_threshold=50 distance_threshold=0.50 advection=0.8 propagation=1 curvature=2.5 grayscale="+grayscaleTol+" convergence=0.0100 region=inside");
		
		run("Invert LUT");
		run("Create Selection");
		run("Measure");
		Ac=getResult("Area", 1);
		type=selectionType();
		if (Ac<minorganSection || type==-1 || ccConverg>maxSlicesConverg) {
			// If the contour converges to a very small region, organ ends at this slice and we exit the loop
			selectWindow("Segmentation of slice");
			close();
			selectWindow("Segmentation progress of slice");
			close();
			selectWindow("slice");
			close();		
			break
		}
	
		//--Check size of converged contour. If it is bigger that the one in the previous slice, don't take it into account and repeat the previous one
		if(Ac>ca*sizeFac) {
			roiManager("Select", cc);
			ccConverg++;	// update counter of slices for which the contour is increasing
		}
	
		selectWindow("orig");
		run("Restore Selection");
		roiManager("Add");
		run("Select None");
		
		selectWindow("Segmentation of slice");
		close();
		selectWindow("Segmentation progress of slice");
		close();
		selectWindow("slice");
		close();
	
		cc++;	
	}
	
	//--Sort ROIs according to slices. That way, the last ROI will be the central slice of the organ
	roiManager("Sort");
	
	//--GO UP IN THE SLICES
	
	//s=166;
	sUp=s;
	ccConverg=0;
	while(sUp<slices)
	{	
		sUp++;
		selectWindow("orig");
		setSlice(sUp);
		run("Duplicate...", "title=slice");
		run("8-bit");
		run("Set Scale...", "distance=0 known=0 unit=pixel");
		run("Mean...", "radius=1");
		run("Clear Results");
		
		//--Paint a darker pixel in the centroid in case the contour completely collapses to 0, to avoid Level Sets errors:
		roiManager("Select", cc);
		run("Measure");
		cx=getResult("X", 0);
		cy=getResult("Y", 0);
		ca=getResult("Area", 0);	//area of organ from previous slice
		cm=getResult("Mean", 0);	//mean gray value of the inside
		setPixel(round(cx), round(cy), round(cm/2));	// set the pixel in the centroid to half the average intensity of the region (make it darker)
		
			//enlargement=8;
		run("Enlarge...", "enlarge="+enlargement+" pixel");
	
		//--Level Sets:
		//--Inside-out:
		//run("Level Sets", "method=[Active Contours] use_level_sets grey_value_threshold=50 distance_threshold=0.50 advection=1.50 propagation=1 curvature=1 grayscale=5 convergence=0.0050 region=outside");
		//--Outside-in:
		run("Level Sets", "method=[Active Contours] use_level_sets grey_value_threshold=50 distance_threshold=0.50 advection=0.8 propagation=1 curvature=2.5 grayscale="+grayscaleTol+" convergence=0.0100 region=inside");
		
		run("Invert LUT");
		run("Create Selection");
		run("Measure");
		Ac=getResult("Area", 1);
		type=selectionType();
		if (Ac<minorganSection || type==-1 || ccConverg>maxSlicesConverg) {
			// If the contour converges to a very small region, organ ends at this slice and we exit the loop
			cc++;
			selectWindow("Segmentation of slice");
			close();
			selectWindow("Segmentation progress of slice");
			close();
			selectWindow("slice");
			close();		
			break
		}
	
		//--Check size of converged contour. If it is bigger that the one in the previous slice, don't take it into account and repeat the previous one
		if(Ac>ca*sizeFac) {
			roiManager("Select", cc);
			ccConverg++;	// update counter of slices for which the contour is increasing
		}
	
		selectWindow("orig");
		run("Restore Selection");
		roiManager("Add");
		run("Select None");
		
		selectWindow("Segmentation of slice");
		close();
		selectWindow("Segmentation progress of slice");
		close();
		selectWindow("slice");
		close();
	
		cc++;	
	}
	
	
	//--Show segmentation
	selectWindow("orig");
	roiManager("Show All with labels");
	roiManager("Show All without labels");
	roiManager("Show None");
	run("From ROI Manager");
	
	
	//--SAVE organ MEASUREMENT
	
	waitForUser("Check current organ segmentation and press OK");
	q=getBoolean("Would you like to save current organ annotation measurements?", "Save", "Discard");
	if(q) {
	
		//--Save organ annotations
		roiManager("deselect");
		roiManager("Save", outDir+MyTitle_short+"_Annotatedorgan_"+norgan+".zip");	
		
		//--Measure organ volume
		
		selectWindow("orig");
		run("Clear Results");
		n=roiManager("count");
		Aacc=0;
		for (i = 0; i < n; i++) {
			roiManager("Select", i);
			run("Measure");
			area=getResult("Area", i);
			Aacc = Aacc+area;
		}
		organVol = Aacc*r;	//multiply the accumulated area in mm2 by the Z of the voxel
	
		//--Calculate diameter for an equivalente sphere:
		base = 6*organVol/PI;
		exponent = 1/3;
		Deq = pow(base, exponent);
		
		roiManager("Deselect");
		run("Select None");
		setSlice(s);
		
		//--Write results
		run("Clear Results");	
		if(File.exists(outDir+"CT_OrganVolumeResults.xls"))
		{
			open(outDir+"CT_OrganVolumeResults.xls");
			IJ.renameResults("Results");
		}
		i=nResults;
		setResult("Label", i, MyTitle); 
		setResult("organ #", i, norgan); 
		setResult("organ Volume (micron^3)",i,organVol);
		setResult("organ Equivalent Diameter (microns)",i,Deq);
		saveAs("Results", outDir+"CT_OrganVolumeResults.xls");
		
		showMessage("organ quantified and saved!");
	
	}
	
	else {	// delete organ central annotation
		roiManager("Reset");
		roiManager("Open", outDir+MyTitle_short+"_organs.zip");	
		n=roiManager("count");
		roiManager("select", n-1);
		roiManager("delete");
		roiManager("deselect");
		n=roiManager("count");
		if(n>0) {
			roiManager("Save", outDir+MyTitle_short+"_organs.zip");	
		}
		else {
			File.delete(outDir+MyTitle_short+"_organs.zip");
		}
		selectWindow("orig");
		run("Select None");
		run("Remove Overlay");
		showMessage("Nothing has been saved!");
}
*/



macro "organ Action Tool 3 - N44C73aD1eD1jD2dD2kD3dD4lD6cD6mD7cD7mD8mD9bDaaDb8Db9Dc3Dd2DdnDe1DenDfnDjlDkkDl4Dl5DljDm7Dm8DmhCfffD00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0lD0mD0nD10D11D12D13D14D15D16D17D18D19D1aD1bD1mD1nD20D21D22D23D24D25D26D27D28D29D2aD2bD2nD30D31D32D33D34D35D36D37D38D39D3aD3bD3fD3gD3hD3iD3nD40D41D42D43D44D45D46D47D48D49D4aD4bD4fD4gD4hD4iD4jD50D51D52D53D54D55D56D57D58D59D5aD5fD5gD5hD5iD5jD60D61D62D63D64D65D66D67D68D69D6aD6eD6fD6gD6hD6iD6jD70D71D72D73D74D75D76D77D78D79D7aD7eD7fD7gD7hD7iD7jD7kD80D81D82D83D84D85D86D87D88D89D8eD8fD8gD8hD8iD8jD8kD90D91D92D93D94D95D96D97D98D9dD9eD9fD9gD9hD9iD9jD9kDa0Da1Da2Da3Da4Da5DadDaeDafDagDahDaiDajDakDb0Db1DbcDbdDbeDbfDbgDbhDbiDbjDbkDc0DcbDccDcdDceDcfDcgDchDciDcjDckDd6Dd7Dd8Dd9DdaDdbDdcDddDdeDdfDdgDdhDdiDdjDdkDe4De5De6De7De8De9DeaDebDecDedDeeDefDegDehDeiDejDekDelDf3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDffDfgDfhDfiDfjDfkDflDg3Dg4Dg5Dg6Dg7Dg8Dg9DgaDgbDgcDgdDgeDgfDggDghDgiDgjDgkDh3Dh4Dh5Dh6Dh7Dh8Dh9DhaDhbDhcDhdDheDhfDhgDhhDhiDhjDhkDi3Di4Di5Di6Di7Di8Di9DiaDibDicDidDieDifDigDihDiiDijDj5Dj6Dj7Dj8Dj9DjaDjbDjcDjdDjeDjfDjgDjhDjiDk8Dk9DkaDkbDkcDkdDkeDkfDkgDknDl0DlmDlnDm0Dm1Dm2DmlDmmDmnDn0Dn1Dn2Dn3Dn4DnjDnkDnlDnmDnnCa8cD1dD3cD4mD8lD9nDd3DjkDjmDk1Dl8DlkDm5Dn9DngC85aD0gD2eD5dD5lD5mD8bDb5DbnDc2Dc6DcmDdmDemDfmDl6Dm6DmcDmdCedeD0kD1lD2cD2gD3jD4eD6nD8dDa6DacDbbDblDc9Dg2DglDikDjjDkmDlbDleDllDm3Dn7C74aD5cD8cD9mDabDb6Dc5DcnDf1Di1DimDm9DncDndCcbdD9lDa7Dd4De0Df2Di2DinDj0Dj3DkiDl2DmjDn8DnhC96bD1kD3kDanDbaDf0Dk4DkjDklDl3Dl7DlhDnaCfefD0dD1cD4nD5eD5nD6kD8aD99DcaDdlDe3DjnDk0Dk7DkhDn5Dn6C74aD1fD3lDb7Dc4DhmDj1Dk2DmgCb9dD0jD2fD3eD4kD7bD7dD8nD9aDa8Db3Dc8DhlDk5Dl9DlgC95bD0iD4cD6lDa9Dd1Di0DilDj2DmiDnfCeefD2hD2mD5bDb2DclDd0Dd5Dh2Dj4Dl1DlcDldDmkDniC84aD0hD1gD1hD1iD4dDamDbmDg0Dg1DgmDgnDh0Dh1Dk3DliDmaDmbDmeDmfDnbDneCdceD0eD2iD3mD5kD6bD7nDalDc1Dk6DlaDlfDm4Ca7cD0fD2jD2lD6dD7lD9cDb4Dc7De2Dhn"
{
	
	roiManager("Reset");
	run("Clear Results");
	run("Remove Overlay");
	
	run("Options...", "iterations=1 count=1 do=Nothing");

	
	//get info of original image
	selectWindow("orig");
	wait(200);
	Stack.getDimensions(width, height, channels, slices, frames);
	getVoxelSize(rx, ry, rz, unit);
	r=rx;	//the three are equal
	
	fname=getInfo("image.directory");	
	outDir = fname+File.separator+"AnalyzedImages/";
	
	Fstring=File.openAsString(fname+File.separator+"imInfo.txt");
	strA=split(Fstring,"\n");
	temp=strA[0];
	MyTitle=strA[1];
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	// Open already annotated organs:
	if(File.exists(outDir+MyTitle_short+"_organs.zip"))
	{
		close("orig");
		open(outDir+MyTitle_short+"_Annotations.tif");
		rename("orig");
		roiManager("Open", outDir+MyTitle_short+"_organs.zip");	
				
	}
	
	// Show them as overlays:
	nn=roiManager("count");
	norgan = nn+1;
	if(nn>0) {
		roiManager("Show All with labels");
		run("From ROI Manager");
	}
	
	roiManager("Reset");
	run("ROI Manager...");
	roiManager("Show None");
	roiManager("Show All");
	roiManager("Show All without labels");
	
	
	//--MANUAL SEGMENTATION OF THE organ
	setTool("freehand");
	waitForUser("Please annotate the organ contour in a few reference slices (by pressing 'T'). Intermediate slices will be interpolated. Press OK when you finish the annotation");
	
	run("Remove Overlay");
	// Save current reference ROIs:
	roiManager("Deselect");
	roiManager("Sort");
	roiManager("Save", outDir+MyTitle_short+"_RefROIs.zip");
	
	// Interpolate intermediate ROIs
	roiManager("Interpolate ROIs");
	selectWindow("orig");
	roiManager("Show All with labels");
	roiManager("Show All without labels");
	roiManager("Show None");
	run("From ROI Manager");
	
	// Check and finish or reannotate references
	waitForUser("Please check the interpolated ROIs");
	q=getBoolean("Would you like to finish the annotation process?","Finish annotation","Revise reference annotations");
	if(!q) {
		run("Remove Overlay");
		roiManager("Reset");
		roiManager("Open", outDir+MyTitle_short+"_RefROIs.zip");
		roiManager("Show All with labels");
		roiManager("Show All without labels");
		waitForUser("Please draw additional annotations of the contour of the organ (by pressing 'T'). Press OK when you finish to interpolate intermediate slices again");
		
		// Save current reference ROIs:
		roiManager("Deselect");
		roiManager("Sort");
		roiManager("Save", outDir+MyTitle_short+"_RefROIs.zip");
	
		// Interpolate intermediate ROIs
		roiManager("Interpolate ROIs");
	
		run("Remove Overlay");
		selectWindow("orig");
		roiManager("Show All with labels");
		roiManager("Show All without labels");
		roiManager("Show None");
		run("From ROI Manager");
	
		waitForUser("Please check the interpolated ROIs");
		q=getBoolean("Would you like to finish the annotation process?","Finish annotation","Revise reference annotations");
	}
	
	//--Show segmentation
	selectWindow("orig");
	roiManager("Show All with labels");
	roiManager("Show All without labels");
	roiManager("Show None");
	run("From ROI Manager");
	
	run("Options...", "iterations=1 count=1");
	
	//--Measure organ volume
	setForegroundColor(0, 0, 0);
	setBackgroundColor(255, 255, 255);
	run("Select None");
	run("Duplicate...", "title=organMask duplicate");
	run("Remove Overlay");
	setAutoThreshold("Default dark");
	run("8-bit");
	//run("Threshold...");
	setThreshold(0, 255);
	run("Convert to Mask", "background=Dark");
	run("Make Binary", "background=Dark");
			
	selectWindow("orig");
	run("Clear Results");
	n=roiManager("count");
	Aacc=0;
	for (i = 0; i < n; i++) {
		selectWindow("organMask");
		roiManager("Select", i);
		run("Fill","slice");
	}
	run("Make Binary", " ");
	
	run("Erode", "stack");
	
	selectWindow("organMask");
	run("Analyze Regions 3D", "voxel_count volume surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
	organVolpix = getResult("VoxelCount", 0);
	organVol = organVolpix*pow(r,3);
	close("organMask-morpho");
	
	run("Clear Results");
	
	selectWindow("organMask");
	run("Select None");
	run("Divide...", "value=255 stack");

	selectWindow("orig");
	run("Duplicate...", "title=organROI duplicate");
	run("Remove Overlay");
	imageCalculator("Multiply stack", "organROI","organMask");
	run("Select None");
	run("Remove Overlay");
	
	selectWindow("organMask");
	run("Multiply...", "value=255 stack");
		
	selectWindow("organROI");
	run("Threshold...");
	setAutoThreshold("Default dark 16-bit stack no-reset");
	waitForUser("SET Intensity threshold and press OK");
	setOption("BlackBackground", true);
	run("Convert to Mask", "background=Dark");
	run("Make Binary", " ");
	
	selectWindow("organROI");
	run("Analyze Regions 3D", "voxel_count volume surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
	organROIvolpix = getResult("VoxelCount", 0);
	organROIvol = organROIvolpix *pow(r,3);
	close("organROI-morpho");
	
	//--SAVE organ MEASUREMENT
	q=getBoolean("Would you like to save current organ annotation measurements?", "Save", "Discard");
	if(q) {
	
		//--Save organ annotations
		roiManager("deselect");
		roiManager("Save", outDir+MyTitle_short+"_AnnotatedOrgan_"+norgan+".zip");	
				
		//--Calculate diameter for an equivalente sphere:
		base = 6*organVol/PI;
		exponent = 1/3;
		Deq = pow(base, exponent);
		
		roiManager("Deselect");
		run("Select None");
	
		//--Save annotated central slice
		centralSl = round(n/2);
		roiManager("Select", centralSl);
		roiManager("Save", outDir+MyTitle_short+"_organManualAnnot.roi");
		roiManager("reset");
		// Open already annotated organs:
		if(File.exists(outDir+MyTitle_short+"_organs.zip"))
		{
			roiManager("Open", outDir+MyTitle_short+"_organs.zip");	
		}
		roiManager("Open", outDir+MyTitle_short+"_organManualAnnot.roi");
		roiManager("deselect");
		roiManager("Save", outDir+MyTitle_short+"_organs.zip");	
		norgan=roiManager("count");
		run("Select None");
		
		//--Write results
		close("Results");
		run("Clear Results");	
		if(File.exists(fname+File.separator+"CT_OrganVolumeResults.xls"))
		{
			open(fname+File.separator+"CT_OrganVolumeResults.xls");
			IJ.renameResults("Results");
		}
		i=nResults;
		setResult("Label", i, MyTitle); 
		setResult("organ #", i, norgan); 
		setResult("organ Volume (micron^3)",i,organVol);
		setResult("organ Equivalent Diameter (microns)",i,Deq);
		setResult("organ ROI volume (microns^3)",i,organROIvol);
		setResult("Ratio VolROI/VolOrgan",i,organROIvol/organVol);
		saveAs("Results", fname+File.separator+"CT_OrganVolumeResults.xls");
		
		selectWindow("organMask");
		saveAs("Tiff", outDir+MyTitle_short+"_organ"+i+"Mask.tif");
		rename("organMask");
		
		selectWindow("organROI");
		saveAs("Tiff", outDir+MyTitle_short+"_organROI"+i+"Mask.tif");
		rename("organROI");
		
		// Open already annotated organs:
		if(File.exists(outDir+MyTitle_short+"_Annotations.tif"))
		{
			close("orig");
			open(outDir+MyTitle_short+"_Annotations.tif");
			rename("orig");
		}
		
		addOverlay3D("orig","organMask",1,"blue");
		addOverlay3D("orig","organROI",1,"magenta");
	
		selectWindow("orig");
		saveAs("Tiff", outDir+MyTitle_short+"_Annotations");
		close("\\Others");		
		showMessage("organ quantified and saved!");
	
	}else {	// delete organ central annotation
		roiManager("Reset");
		selectWindow("orig");
		run("Select None");
		run("Remove Overlay");
		showMessage("Nothing has been saved!");
	}


}


function addOverlay3D(rawImage,maskImage,channel,color){
		
		selectWindow(rawImage);
		getDimensions(width, height, channels, slices, frames);
		
		setBatchMode(true);
		RoiManager.associateROIsWithSlices(true);	
		// Ensure the image is a stack
		if (slices > 1) {
		    // Loop through each slice
		    for (i = 1; i <= slices; i++) {
		    	selectWindow(maskImage);
		        setSlice(i);
		        
		        // Create an ROI from the binary image
		        run("Create Selection");
		        type=selectionType();
		        if(type!=-1){
		        	selectWindow(rawImage);
		        	setSlice(i);
		           	run("Restore Selection");
		           	Roi.setPosition(i);
		        	Overlay.addSelection(color);
					Overlay.setPosition(i);
	
		        }
		    }
		}else{
		    print("The image is not a stack.");
		}

		setBatchMode("exit and display");
		run("Select None");
}
































