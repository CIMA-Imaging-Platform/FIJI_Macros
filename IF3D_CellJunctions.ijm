function macroInfo() {
    scripttitle = "Automatic Nuclei and Cell Junctions in IF 3D Images";
    version = "1.03";
    date = "2015";

    imageAdquisition = "Confocal";
    imageType = "IF 3D 2 Channel: DAPI + Cell Marker";
    voxelSize = "Voxel size: known metadata µm xy";
    format = "czi, tif";

    parameter1 = "Threshold Junction Marker: threshold to separate cell junction signal from background.";

    button1 = "Im: Single File processing";
    button2 = "DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

    excelName = "IF3D_CellJunctionsQuantificationResults.xls";
    feature1 = "Filename";
    feature2 = "FOV (Field of View)";
    feature3 = "# Cells";
    feature4 = "Total_junction_vol";
    feature5 = "junction_Avg_Intensity";
    feature6 = "junction_Std_Intensity";
    feature7 = "junction_Max_Intensity";
    feature8 = "junction_Min_Intensity";
    feature9 = "junction_Median_Intensity";
    feature10 = "junction_Mode_Intensity";

    showMessage("ImageJ Script", "<html>"
        +"<style>h{margin-top: 5px; margin-bottom: 5px;} p{margin: 0px;padding: 0px;} ol{margin-left: 20px;padding: 5px;} #list-style-3 {list-style-type: circle;.container {max-width: 1200px; margin: 0 auto; padding: 0px; }</style>"
        +"<h1><font size=6 color=Teal href=https://cima.cun.es/en/research/technology-platforms/image-platforms>CIMA: Imaging Platform</h1>"
        +"<h1><font size=5 color=Purple><i>Software Development Service</i></h1>"
        +"<p><font size=2 color=Purple><i>ImageJ Macros</i></p>"
        +"<h2><font size=3 color=black>"+scripttitle+"</h2>"
        +"<p><font size=2>Modified by Tomas Mu&ntilde;oz Santoro</p>"
        +"<p><font size=2>Version: "+version+" ("+date+")</p>"
        +"<p><font size=2>Contact: tmsantoro@unav.es</p>" 
        +"<p><font size=2>Available for use/modification/sharing under the <a href=https://opensource.org/licenses/MIT/>MIT License</a></p>"
        +"<h2><font size=3 color=black>Developed for</h2>"
        +"<p><font size=3><i>Input Images</i></p>"
        +"<ul id=list-style-3><font size=2><li>"+imageAdquisition+"</li><li>"+imageType+"</li><li>"+voxelSize+"</li><li>"+format+"</li></font></ul>"
        +"<p><font size=3><i>Action tools (Buttons)</i></p>"
        +"<ol><font size=2><li>"+button1+"</li><li>"+button2+"</li></font></ol>"
        +"<p><font size=3><i>PARAMETERS:</i></p>"
        +"<ul id=list-style-3><font size=2>"
        +"<li>"+parameter1+"</li></font></ul>"
        +"<p><font size=3><i>Quantification Results:</i></p>"
        +"<p><font size=3><i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
        +"<p><font size=3><i>Excel: "+excelName+"</i></p>"
        +"<ul id=list-style-3><font size=2>"
        +"<li>"+feature1+"</li>"
        +"<li>"+feature2+"</li>"
        +"<li>"+feature3+"</li>"
        +"<li>"+feature4+"</li>"
        +"<li>"+feature5+"</li>"
        +"<li>"+feature6+"</li>"
        +"<li>"+feature7+"</li>"
        +"<li>"+feature8+"</li>"
        +"<li>"+feature9+"</li>"
        +"<li>"+feature10+"</li>"
        +"</font></ul>"
        +"<h0><font size=5></h0>"
        +"</html>"
    );
}
var cDapi=1;		

macro "IFnuclCyto3D Action Tool 1 - Cf00T2d15IT6d10m"{

	close("*");
	macroInfo();
		
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	//setBatchMode(true);
	
	Dialog.create("Parameters");
	Dialog.addNumber("DAPI CHANNEL",cDapi);
	Dialog.show();	
	cDapi= Dialog.getNumber();	

	print(name);
	processSingleIm("-","-",name,cDapi);
	setBatchMode(false);
	showMessage("Done!");

}
		
macro "IFnuclCyto3D Action Tool 2 - C00fT0b11DT9b09iTcb09r"{

	close("*");
	macroInfo();
	
	Dialog.create("Parameters");
	Dialog.addNumber("DAPI CHANNEL",cDapi);
	Dialog.show();	
	cDapi= Dialog.getNumber();	

	
	InDir=getDirectory("Choose a Directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"czi") || endsWith(list[j],"tif")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print(name);
			//setBatchMode(true);
			processSingleIm(InDir,InDir,list[j],cDapi);
			setBatchMode(false);
			}
	}
	showMessage("Done!");
}



function processSingleIm(output,InDir,name,cDapi)
{
	/**
	 * Calculates the 3D volume of segmented objects in a specified frame using the Analyze Regions 3D tool.
	 *
	 * @param {im}    String. Name of the intensity image to be analyzed.
	 * @param {mask}  String. Name of the mask image defining segmented regions.
	 * @returns       Quantitative results of 3D object volumes within the mask for the given frame.
	 */
	
	setBatchMode(false);


	// Open image file using Bio-Formats, either from a directory or as a single file
	selectWindow("Log");
	print("Step1 --> loading image...");
	if (InDir=="-") {
		run("Bio-Formats", "open=["+name+"] autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT");
	}
	else {
		if (!isOpen(InDir+name)) { 
			run("Bio-Formats", "open=["+InDir+name+"] autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT");
		}
	}
	
	// Set display and color options for stack visualization
	Stack.setDisplayMode("composite");
	run("Colors...", "foreground=black background=white selection=yellow");
	run("Options...", "iterations=1 count=1 pad do=Nothing");  // binary settings
	
	// Reset ROI Manager and Results table
	roiManager("Reset");
	run("Clear Results");
	
	// Get image title and output directory
	MyTitle=getTitle();
	output=getInfo("image.directory");
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	// Extract base filename for saving outputs
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	rename("orig");
	
	// Get image dimensions and calculate Field of View (FOV)
	Stack.getDimensions(width, height, channels, slices, frames);
	getVoxelSize(vxW, vxH, depth, unit);
	FOV = width * height * slices * vxH * vxH * depth ;
	
	
	// Segment nuclei from channel 1
	selectWindow("Log");
	print("Step2 --> Nucleus Segmentation --> STARDIST processing ...");
	selectWindow("orig");
	run("Duplicate...", "duplicate title=nuclei3D channels="+cDapi+"");
	segmentNuclei("nuclei3D");
	nCells = roiManager("count");
	//print(nCells);
	
	setBatchMode(true);

	// Segment cell junctions from channel 2
	selectWindow("orig");
	selectWindow("Log");
	print("Step3 --> Junctions segmentation ...");
	selectWindow("orig");
	run("Duplicate...", "title=junctionsInt duplicate channels=2");
	segmentCellJunctions("junctionsInt");
		
	// Measure junction features (volume, intensity statistics)
	selectWindow("Log");
	print("Step4 --> Calculating Metrics ...");
	
	junctionFeatures = getImFeatures("junctionsInt","junctionsIntMask");
	voljunction = junctionFeatures[0];
	meanIjunction = junctionFeatures[1];
	stdIjunction = junctionFeatures[2];
	maxIjunction = junctionFeatures[3];
	minIjunction = junctionFeatures[4];
	medianIjunction = junctionFeatures[5];
	modeIjunction = junctionFeatures[6];
	//Array.print(junctionFeatures);
   
	// Overlay nucleus segmentation on original image
	selectWindow("nucleusLabels");
	setAutoThreshold("Default dark");
	setThreshold(1, 65535, "raw");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Create Selection");
	
	selectWindow("orig");
	run("Restore Selection");
	Overlay.addSelection("blue");
	Overlay.setPosition(1, 0, 0);
	
	setBatchMode("exit and display");
	selectWindow("junctionsIntMask");
	
	// Overlay junction segmentation on original image
	addOverlay3D("orig", "junctionsIntMask", 2, "red");
	saveImages("orig", OutDir, MyTitle_short);

	// Close all images and clear results
	close("*");
	run("Clear Results");
	close("Results");
	selectWindow("Log");
	print("Step5 --> Saving results ...");
	
	// Check if results file exists; open and rename if necessary
	if(File.exists(output + File.separator + "IF3D_CellJunctionsQuantificationResults.xls")) {
		open(output + File.separator + "IF3D_CellJunctionsQuantificationResults.xls");
		wait(500);
		IJ.renameResults("Results");
		wait(500);
	}
	
	// Record quantification results in Results table
	i = nResults;
	setResult("Filename", i, MyTitle_short);
	setResult("FOV", i, FOV);
	setResult("# Cells", i, nCells);
	setResult("Total_junction_vol", i, voljunction);
	setResult("junction_Avg_Intensity", i, meanIjunction);
	setResult("junction_Std_Intensity", i, stdIjunction);
	setResult("junction_Max_Intensity", i, maxIjunction);
	setResult("junction_Min_Intensity", i, minIjunction);
	setResult("junction_Median_Intensity", i, medianIjunction);
	setResult("junction_Mode_Intensity", i, modeIjunction);
				  
	// Save results to Excel file
	saveAs("Results", output+ File.separator + "IF3D_CellJunctionsQuantificationResults.xls");
}


function segmentNuclei(nucleiIm){

	/**
	* Segments nuclei from a 3D image by projecting to 2D and applying StarDist2D.
	* @param nucleiIm Name of the 3D nuclei image window to process
	*/

	// segment CELLs IN THE 2D PROJECTION
	//nucleiIm = "nuclei3D";
	selectWindow(nucleiIm);
	run("Z Project...", "projection=[Sum Slices]");
	selectWindow("SUM_"+nucleiIm);
	run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input':'SUM_"+nucleiIm+"', 'modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'1.0', 'percentileTop':'99.8', 'probThresh':'0.479071', 'nmsThresh':'0.3', 'outputType':'Both', 'nTiles':'1', 'excludeBoundary':'5', 'roiPosition':'Stack', 'verbose':'false', 'showCsbdeepProgress':'true', 'showProbAndDist':'false'], process=[false]");
	selectImage("Label Image");
	rename("nucleusLabels");
	selectWindow("nucleusLabels");
	run("Label Size Filtering", "operation=Greater_Than size=1000");
	run("Label image to ROIs", "rm=[]");
	close("nucleusLabels");
	rename("nucleusLabels");
	close("*3D");
	//print(nCells);
	//close("nucleusLabels");
}


function discardSlices(im){
	
	selectWindow(im);
	run("Duplicate...", "title=bckg duplicate");
	run("Mean...", "radius=1 stack");
	run("Clear Results");
	run("Set Measurements...", "area mean standard modal min redirect=None decimal=2");
	run("Measure Stack...");
	mode = Table.getColumn("Mode");
	Array.getStatistics(mode, min, max, mean, stdDev);
	//Array.print(newArray(min,max,mean,stdDev));
	
	for (i = 0; i < lengthOf(mode); i++) {
		if (mode[i] > mean + 2) {
			print(max);
			break;			
		}
	}
	
	top = i + 1;
	
	run("Clear Results");
	close("Results");
	close("bckg")
	print(top);
	return top;			
}



function segmentCellJunctions(junctions){

	/**
	* Segments cell junctions in a 3D image using morphological filtering, thresholding, and particle analysis.
	* @param junctions Name of the 3D cell junction image window to process.
	*/
	selectWindow(junctions);
	run("3D Fast Filters","filter=Median radius_x_pix=2.0 radius_y_pix=2.0 radius_z_pix=2.0 Nb_cpus=16");
	run("Morphological Filters (3D)", "operation=Opening element=Ball x-radius=1 y-radius=1 z-radius=1");
	run("Morphological Filters (3D)", "operation=Closing element=[Line 45 degrees] x-radius=1 y-radius=1 z-radius=1");
	run("Morphological Filters (3D)", "operation=Closing element=[Line 135 degrees] x-radius=1 y-radius=1 z-radius=1");
	run("Subtract Background...", "rolling=20 stack");
	run("Median...", "radius=2 stack");
	run("Ridge Detection", "line_width=3 high_contrast=255 low_contrast=0 estimate_width make_binary method_for_overlap_resolution=NONE sigma=9 lower_threshold=0 upper_threshold=0.05 minimum_line_length=0 maximum=0 stack");
		
	run("Median...", "radius=5 stack");
	run("Erode", "stack");
	run("Erode", "stack");
	run("Erode", "stack");
	rename(junctions+"Mask");
	close("*Median*");
	
}

// Function to create cell mask in the 2D projection
		
function segmentCellBoundaries(nucleiIm) {
	/**
	* Segments cell boundaries from a 3D nuclei image by projecting to 2D and applying StarDist2D.
	* @param nucleiIm Name of the 3D nuclei image window
	*/

	// CREATE CELL MASK IN THE 2D PROJECTION
	selectWindow(nucleiIm);
	run("Z Project...", "projection=[Sum Slices]");
	selectWindow("SUM_"+nucleiIm);
	run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input':'SUM_"+nucleiIm+"', 'modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'1.0', 'percentileTop':'99.8', 'probThresh':'0.479071', 'nmsThresh':'0.3', 'outputType':'Both', 'nTiles':'1', 'excludeBoundary':'5', 'roiPosition':'Stack', 'verbose':'false', 'showCsbdeepProgress':'true', 'showProbAndDist':'false'], process=[false]");
	selectImage("Label Image");
	run("Label Size Filtering", "operation=Greater_Than size=600");
	
	//close("Label*");
	//close("*"+nucleiIm+"*");
	
	selectWindow("Label-sizeFilt-Morphometry");
	IJ.renameResults("Results");
	
	nCentrois = nResults;
	
	for (i = 0; i < nResults; i++) {
	    xCor = getResult("Centroid.X", i);
	    yCor = getResult("Centroid.Y", i);
	    selectWindow("centroids");
	    makePoint(xCor, yCor);
	    Overlay.addSelection("blue");
	
    }
	updateResults();

	
}

function getImFeatures(im,mask){
    // This function calculates the 3D volume of segmented objects in a given frame using Analyze Regions 3D.
    // * @param {im} - String, name of the intensity image.
    // * @param {mask} - String, name of the mask image.
    	    
    selectWindow(im);
    run("Select None");
    
    selectWindow(mask);
    run("Select None");
    
    run("Intensity Measurements 2D/3D", "input="+im+" labels="+mask+" mean stddev max min median mode volume");
      
   	selectWindow(im+"-intensity-measurements");
    IJ.renameResults("Results");
    if (nResults > 0){
	   Vol = getResult("Volume", 0);
	   meanI = getResult("Mean", 0);
	   stdI = getResult("StdDev", 0);
	   maxI = getResult("Max", 0);
	   minI = getResult("Min", 0);
	   medianI = getResult("Median", 0);
	   modeI = getResult("Mode", 0);
    }else {
       Vol = 0;
	   meanI = 0;
	   stdI = 0;
	   maxI = 0;
	   minI = 0;
	   medianI = 0;
	   modeI = 0;
    }
    
    imFeatures = newArray(Vol,meanI,stdI,maxI,minI,medianI,modeI);
    
    run("Clear Results");
    return imFeatures; 
}
	
	
function addOverlay3D(rawImage,maskImage,channel,color){

	/**
	* @doc Adds 3D overlay ROIs from a mask image to a raw image, slice by slice, in a specified channel and color.
	* @param rawImage Name of the raw image window.
	* @param maskImage Name of the mask image window.
	* @param channel Channel number to assign the overlay.
	* @param color Color for the overlay.
	*/

			
	selectWindow(rawImage);
	getDimensions(width, height, channels, slices, frames);
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
		    	Roi.setPosition(channel, i, 0);
		    	selectWindow(rawImage);
		    	Stack.setChannel(channel);
		    	run("Restore Selection");
				Overlay.addSelection(color);
				Overlay.setPosition(channel, i, 0);
		    }
		}
		}else{
			print("The image is not a stack.");
		}
		run("Select None");
}
	
function saveImages(image, outputDir, file) {
    // This function overlays two binary masks and saves the resulting image to the output directory.
    // * @param {image}     - String, image with the overlay
    // * @param {outputDir}- String, output directory path.
    // * @param {file}     - String, base filename for saving.
  	
  	selectWindow(image);
    saveAs("tif", outputDir + File.separator + file+"_Analyzed");
    close("*");	
}





















































