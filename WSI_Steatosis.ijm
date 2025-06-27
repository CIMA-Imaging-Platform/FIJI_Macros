
function macroInfo(){
	
// * Quantification of Steatosis Identification on WSI Images  
// * Target User: General
// *  

	scripttitle= "Quantification of Steatosis on WSI Images";
	version= "1.02";
	date= "2024";
	

// *  Tests Images:

	imageAdquisition="Aperio: BrightField Whole Slide Imaging Images.";
	imageType="RGB";  
	voxelSize="Voxel size:  0.502 um xy";
	format="Format: Uncompressed .jpg";   
 
 //*  GUI User Requierments:
 //*    - None
 // Important Parameters: 
	// Parameters:
	
	parameter1="r= Micra per pixel ratio for image analysis. [0.502.um/px]";
	parameter2="thTissue= Threshold value for tissue detection. [0-255]";
	parameter3="thFat= Threshold value for fat-deposit detection. [0-255]";
	parameter4="minFatSize= Minimum size (pixels) of fat deposits for analysis.";
	parameter5="maxFatSize= Maximum size (pixels) of fat deposits for analysis.";
	parameter6="Fat-deposit texture= Texture Feature to differenciate Fat from colagen. Introduce values between 1-1.5. The lower the better to differenciate";
	parameter7="Fat-deposit Circularity= 0-1. 1 Means perfect Circle.";

 //  2 Action tools:
		
	 buttom1="Im: Single File processing. Use Single file processing for fine tunning parameters";
	 buttom2="Dir: Batch Mode. Please tune parameters before using Batchmode";

//  OUTPUT

// Analyzed Images with ROIs

	excel="QuantificationResults_Steatosis.xls";
	feature1="Label";
	feature2="Tissue area (um2)";
	feature3="Steatosis area (um2)";
	feature4="Ratio Asteatosis/Atissue (%)";			
	
	//globalPathToImages="///C:/Users/tmsantoro/Documents/0._TMSANTORO/2.MikelLearning/2.Image_Platform/2_QUANTIFICATION_SERVICE/1._SOFTWARE/1.1_FijiPlatafomraImagen_DEV/macros/toolsets/"
	
/*  	  
 *  version: 1.02 
 *  Author: Mikel Ariz  
 *  Commented by: Tomas Muñoz 2023 
 *  
 */

//	MIT License
//	Copyright (c) 2023 Tomas Muñoz tmsantoro@unav.es
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
    + "<li>" + parameter7 + "</li>"
    + "</ul>"
    + "<p><i>QUANTIFICATION RESULTS</i></p>"
    + "<p>Analyzed Images folder: Visualize Segmented Images</p>"
    + "<p>Excel " + excel + "</p>"
    + "<ul>"
    + "<li>" + feature1 + "</li>"
    + "<li>" + feature2 + "</li>"
    + "<li>" + feature3 + "</li>"
    + "<li>" + feature4 + "</li>"
    + "</ul>"
    + "</div>"
    + "</div>"
    + "</body>"
    + "</html>");
   // + "<div class='image-column'><img src='file:"+globalPathToImages+"resultsTemplates//WSI_Steatosis/WSI_Steatosis_imTemplate.jpg'></div>"


}



// changelog September 2022
var r = 0.502, thTissue = 210, thFat = 210,  minFatSize = 30, maxFatSize = 7000, fatRoundness = 0.7, textureFeature=1.3; // Scanner 20x 


// Macro for processing a single file
macro "Steatosis Action Tool 1 - Cf00T2d15IT6d10m" {
	
	macroInfo();
		
    // Prompt user to select a file
    name = File.openDialog("Select File");
    // Print selected file name
    print(name);
    
	// Create a dialog box for parameter input
	Dialog.create("Parameters");
	
	// Add message to instruct the user
	Dialog.addMessage("Choose parameters")
	
	// Add input fields for parameter values
	Dialog.addNumber("micra/px ratio", r); // micrometers per pixel ratio
	Dialog.addNumber("Threshold for tissue detection", thTissue); // threshold for tissue detection
	Dialog.addNumber("Threshold for fat-deposit detection", thFat); // threshold for fat-deposit detection
	Dialog.addNumber("Min fat-deposit size", minFatSize); // minimum size of fat deposits
	Dialog.addNumber("Max fat-deposit size", maxFatSize); // maximum size of fat deposits
	Dialog.addNumber("Fat-deposit texture", textureFeature);// minimum texture of fat deposits
	Dialog.addNumber("Fat-deposit Circularity", fatRoundness); // minimum Roundness of fat deposits
	 
	// Display the dialog box
	Dialog.show();
	
	// Retrieve parameter values from the dialog box
	r= Dialog.getNumber(); 
	thTissue= Dialog.getNumber(); 
	thFat= Dialog.getNumber(); 
	minSize= Dialog.getNumber(); 
	maxFatSize= Dialog.getNumber(); 
	textureFeature= Dialog.getNumber(); 
	fatRoundness= Dialog.getNumber(); 
	
    
    // Perform steatosis analysis
    steatosis("-", "-", name,r, thTissue, thFat,minFatSize, maxFatSize, fatRoundness,textureFeature);
    setBatchMode(false);
    showMessage("Done!");
}

// Macro for batch processing files in a directory
macro "Steatosis Action Tool 2 - C00fT0b11DT9b09iTcb09r" {
    
    macroInfo();
      
    // Prompt user to select a directory
    InDir = getDirectory("Choose a Directory");
    list = getFileList(InDir);
    L = lengthOf(list);
    
    
     // Create a dialog box for parameter input
	Dialog.create("Parameters");
	
	// Add message to instruct the user
	Dialog.addMessage("Choose parameters")
	
	// Add input fields for parameter values
	Dialog.addNumber("micra/px ratio", r); // micrometers per pixel ratio
	Dialog.addNumber("Threshold for tissue detection", thTissue); // threshold for tissue detection
	Dialog.addNumber("Threshold for fat-deposit detection", thFat); // threshold for fat-deposit detection
	Dialog.addNumber("Min fat-deposit size", minFatSize); // minimum size of fat deposits
	Dialog.addNumber("Max fat-deposit size", maxFatSize); // maximum size of fat deposits
	Dialog.addNumber("Fat-deposit Texture", textureFeature);// minimum texture of fat deposits
	Dialog.addNumber("Fat-deposit Circularity", fatRoundness); // minimum Roundness of fat deposits
	 
	// Display the dialog box
	Dialog.show();
	
	// Retrieve parameter values from the dialog box
	r= Dialog.getNumber(); 
	thTissue= Dialog.getNumber(); 
	thFat= Dialog.getNumber(); 
	minSize= Dialog.getNumber(); 
	maxFatSize= Dialog.getNumber(); 
	textureFeature= Dialog.getNumber(); 
	fatRoundness= Dialog.getNumber(); 
	
    
    // Iterate over files in the directory
    for (j = 0; j < L; j++) {
        if (endsWith(list[j], "jpg") || endsWith(list[j], "tif")) {
            // Perform steatosis analysis
            steatosis(InDir, InDir, list[j],r, thTissue, thFat,minFatSize, maxFatSize, fatRoundness,textureFeature);
            setBatchMode(false);
        }
    }
    showMessage("Done!");
}


function steatosis(output, InDir, name,r, thTissue, thFat, minFatSize, maxFatSize, fatRoundness,texturePerc) {
	// Function: steatosis
	// This function performs the steatosis analysis on a given image.
	// It detects tissue and fat deposits, calculates their areas, and saves the results.
	
	// Fat deposit based on Thresholding and Particle Analysis: 
	//After thresholding, the image is processed to identify connected regions (particles) that correspond to fat deposits. 
	//The Analyze Particles function is used to detect these regions based on specified criteria such as size (minFatSize and maxFatSize)
	//and circularity (fatRoundness).
		
	// Parameters:
	// - output: Output directory for saving analyzed images and results.
	// - InDir: Input directory where images are located (if processing multiple images).
	// - name: Name of the image file to be analyzed.
	
	
    run("Close All");
    if (InDir == "-") {
        open(name);
    } else {
        if (isOpen(InDir + name)) {} else {
            open(InDir + name);
        } 
    }
	
	
	function filterTableColum(tableName, columnName, filterType, threshold)
	{
		
		/**
		 * Filters a table column based on a given threshold.
		 * 
		 * @param {string} tableName - The name of the table window.
		 * @param {string} columnName - The name of the column to filter.
		 * @param {string} filterType - The type of filtering ("<" for values less than, ">" for values greater than).
		 * @param {number} threshold - The threshold value for filtering.
		 * @return {array} positiveRois - An array containing the indices of rows that meet the filtering criteria.
		 */
		 
	
		 //TEST PARAMETERS
		
		 /* tableName="Results";
		 columnName="Mean";
		 filterType=">";
		 threshold=25;
		 */
		 
		// Select the table window
		selectWindow(tableName);
		
		// Get the number of results in the table
		n = nResults;
		
		// Create an array of indices for the table rows
		id = Array.slice(Array.getSequence(n + 1), 0, n); 
		
		// Set the "Index" column in the table
		Table.setColumn("Index", id);
		
		// Sort the table based on the specified column
		Table.sort(columnName);
		
		// Get the specified column from the table
		column = Table.getColumn(columnName);
		
		// Loop through the values in the column
		for (i = 0; i < lengthOf(column); i++) {
			// Get the value at the current position
			value = column[i];
			
			// Check if the filter type is "<"
			if (filterType == "<") {
				// If the value is greater than the threshold, delete rows below the current position
				if (value > threshold) {
					selectWindow(tableName);
					Table.deleteRows(i, lengthOf(column) - 1);
					break;
				}
			} else if (filterType == ">") {
				// If the value is greater than the threshold, delete rows above the current position
				if (value > threshold) {
					selectWindow(tableName);
					Table.deleteRows(0, i - 1);
					break;
				}
			}
		}
		
		// Get the updated indices of rows that meet the filtering criteria
		positiveRois = Table.getColumn("Index");
		roiManager("select", positiveRois);
		
		// Return the array of positive indices
		return positiveRois;
	}

    // Reset ROI manager and clear previous results
    roiManager("Reset");
    run("Clear Results");

    // Get image title and output directory
    MyTitle = getTitle();
    output = getInfo("image.directory");
    OutDir = output + File.separator + "AnalyzedImages";
    File.makeDirectory(OutDir);

    // Processing MyTitle_short
    // Split image title to get short name
    aa = split(MyTitle, ".");
    MyTitle_short = aa[0];
    print("Processing "+MyTitle_short);
    selectWindow("Log");

    // Set batch mode and color preferences
    setBatchMode(true);
    run("Colors...", "foreground=white background=black selection=green");

    // DETECT TISSUE
    print("- Segmenting Tissue...");
    run("Select All");
    showStatus("Detecting tissue...");
    run("RGB to Luminance");
    rename("tissueMask");
    run("Threshold...");
    //thTissue=210;
    setThreshold(0, thTissue);
    setOption("BlackBackground", false);
    run("Convert to Mask");
    run("Invert");
    run("Open");
    //maxFatSize=6000;
    run("Analyze Particles...", "size="+maxFatSize+"-Infinity show=Masks in_situ");
    run("Invert");
    run("Analyze Particles...", "size=100000-Infinity pixel show=Masks in_situ");
    run("Create Selection");
    Roi.setName("Tissue");
    run("Add to Manager"); // ROI0 --> whole tissue

	//-- DETECT LIPID DEPOSITS
	selectWindow(MyTitle);
	run("Select None");
	run("Duplicate...", "title=orig");

	// LIPID MASK--> no signal regions (white) 
	print("- Segmenting Fat deposits ...");
	selectWindow("orig");
	run("Select None");
	run("Duplicate...", "title=fatMask");
	run("8-bit");
	//thFat=210;
	run("Threshold...");
	setThreshold(thFat, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Morphological Filters", "operation=Opening element=Disk radius=2");
	close("fatMask");
	selectWindow("fatMask-Opening");
	rename("fatMask");
	//minFatSize=20;
	//maxFatSize=6000;
	run("Analyze Particles...", "size="+minFatSize+"-"+maxFatSize+" pixel show=Masks exclude in_situ");
	roiManager("select", 0);
	setBackgroundColor(255,255,255);
	run("Clear Outside");
	run("Colors...", "foreground=white background=black selection=green");
	run("Create Selection");
	Roi.setName("FatMask");
	roiManager("add");	
	run("Select None");
	
	
	
	// FAT MASK BASED ON TEXTURE -->
	//Test images present glucogen, same phenotype as steatosis with different morphology and texture.
	
	print("- Separate Fat deposits from  glucogen ...");
	selectWindow("orig");
	run("Duplicate...", "title=fatMask-texture");
	run("Select None");
	run("8-bit");
	run("FeatureJ Derivatives", "x-order=1 y-order=1 z-order=0 smoothing=1.0");
	selectImage("fatMask-texture dx1 dy1 dz0");
	run("Square");
	//run("Threshold...");
	//textureFeature=1.5;
	setThreshold(-0.2,textureFeature);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Morphological Filters", "operation=Opening element=Disk radius=1");
	//minFatSize=20;
	//maxFatSize=6000;
	run("Analyze Particles...", "size="+minFatSize+"-"+maxFatSize+" pixel show=Masks exclude in_situ");
	run("Dilate");
	roiManager("select", 1);
	setBackgroundColor(255,255,255);
	run("Clear Outside");
	run("Select None");
	run("Colors...", "foreground=white background=black selection=green");
	run("Create Selection");
	Roi.setName("TextureFeature");
	roiManager("add");	
	close("*dx1*");
	close("fatMask-texture");
	selectWindow("fatMask-texture-Opening");
	rename("textureFeature");
	run("Select None");
	roiManager("Show None");
         	
	
	             	
	/* TEXTURE FEATURES SHAPE DESCRIPTORS  ...
	 *  Classify fatMask ROIs based on texture feature 
	 *  	--> Decided not to use due to fat glucogen clusters - shape descriptors wont be useful then. 
 	 *  Use directly texture Rois shape descriptors.
 	 *  Roundness
 	 *  Solidity
 	 * 
 	
 	// Classify fatMask ROIs based on texture feature
    selectWindow("fatMask");
    run("Select None");
    run("Analyze Particles...", "show=Masks add in_situ");
    roiManager("show none");
    selectWindow("textureFeature");
    run("Select None");
    run("Set Measurements...", "area_fraction mean redirect=None decimal=2");
    roiManager("measure");
    
    */
    
    //waitForUser;
	
	// ROUNDNESS --> 4 × [Area] / π × [Major axis]2  or the inverse of Aspect Ratio.
	
    roiManager("Reset");
    run("Clear Results");
    close("Results");
   	print("- Obtaining Texture Features ...");
   	selectWindow("textureFeature");
   	run("Set Measurements...", "area shape redirect=None decimal=2");
   	run("Analyze Particles...", "show=Masks add display in_situ");
	positiveRois=filterTableColum("Results","Round",">",fatRoundness);
	roiManager("select", positiveRois);
	roiManager("save selected", OutDir+File.separator+MyTitle_short+"_SteatosisROIs.zip");
	roiManager("Reset");
	roiManager("Open", OutDir+File.separator+MyTitle_short+"_SteatosisROIs.zip");
	
	run("From ROI Manager");
	run("Create Mask");    
	close("textureFeature");
	selectWindow("Mask");
	rename("TextureFeature_Roundness");
	run("Median", "radius=2");
	//run("Dilate");
	
	////waitForUser;
	
	// SOLIDITY -->  [Area]/ [Convex area] 
	
 	roiManager("Reset");
    run("Clear Results");
  	close("Results");
    //mFatSize=50;
	//maxFatSize=6000;
	selectWindow("TextureFeature_Roundness");
	run("Analyze Particles...", "size="+minFatSize+"-"+maxFatSize+" pixel show=Masks add display in_situ");
	positiveRois=filterTableColum("Results","Solidity",">",0.8); 
	roiManager("select", positiveRois);
	roiManager("save selected", OutDir+File.separator+MyTitle_short+"_SteatosisROIs.zip");
	roiManager("Reset");
	roiManager("Open", OutDir+File.separator+MyTitle_short+"_SteatosisROIs.zip");
	
	////waitForUser;
	
	run("From ROI Manager");
	run("Create Mask");    
	close("TextureFeature_Roundness");
	selectWindow("Mask");
	rename("TextureFeature_Roundness_Sol");
	roiManager("Show None");
		
	selectWindow("TextureFeature_Roundness_Sol");
	run("Analyze Particles...", "size="+minFatSize+"-"+maxFatSize+" show=Ellipses");
	run("Fill Holes");
	close("TextureFeature_Roundness_Sol");
	selectWindow("Drawing of TextureFeature_Roundness_Sol");
	rename("TextureFeature_Roundness_Sol");
	

	setBatchMode("exit and display");
	// ASPECT RATIO -->  The aspect ratio of the particle’s fitted ellipse, i.e., [Major Axis]/[Minor Axis]

	roiManager("Reset");
    run("Clear Results");
 	close("Results");
    selectWindow("TextureFeature_Roundness_Sol");
	run("Set Measurements...", "area shape redirect=None decimal=2");
   	run("Analyze Particles...", "show=Masks add display in_situ");
   	positiveRois=filterTableColum("Results","AR","<",1.35);
   	roiManager("select", positiveRois);
	roiManager("save selected", OutDir+File.separator+MyTitle_short+"_SteatosisROIs.zip");
	roiManager("Reset");
	roiManager("Open", OutDir+File.separator+MyTitle_short+"_SteatosisROIs.zip");
	run("From ROI Manager");
	run("Create Mask");
	rename("texturePositive");
	close("TextureFeature_Roundness_Sol");
	roiManager("Show None");
	
	nLipids=roiManager("count");
	area=Table.getColumn("Area");
	Array.getStatistics(area, areaMin, areaMax, areaAvg, areaStdDev);
  	
  	
  	
  	/* IN CASE MARKER CONTROLLED WATERSHED IS NEEDED
	 * 
  	/* Seeds 
	selectWindow("orig");
	run("8-bit");
	run("Gaussian Blur...", "sigma=1");
	run("From ROI Manager");
	run("Create Mask");
	
	run("Adjustable Watershed", "tolerance=1");
	//minFatSize=25;
	//maxFatSize=6000;
	//fatRoundness=0.7;
	run("Analyze Particles...", "size="+minFatSize+"-"+maxFatSize+" circularity="+fatRoundness+"-1 pixel show=Masks exclude in_situ");
	rename("texturePositive");
	
	
	selectWindow("textureFeature");
	run("Restore Selection");
	setBackgroundColor(255,255,255);
	run("Clear Outside");
	run("Colors...", "foreground=white background=black selection=green");
	run("Select None");
	run("Distance Map");
	run("Log");
	run("Fire");
	prominence=10;
	run("Find Maxima...", "prominence="+prominence+" output=[Single Points]");
	rename("seeds");
	
	// Fat deposit edges
	selectWindow(MyTitle);
	run("Duplicate...", "title=fatEdges");
	run("Select None");
	run("8-bit");
	run("Find Edges");
			
	// Reset ROI manager and clear previous results
    roiManager("Reset");
    run("Clear Results");
	
	// Marker-controlled watershed
	run("Marker-controlled Watershed", "input=fatEdges marker=seeds mask=texturePositive binary calculate use");
	selectWindow("fatEdges-watershed");
	rename("fatSegmented");
	run("8-bit");
	setThreshold(1, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	
	minFatSize=40;
	maxFatSize=6000;
	fatRoundness=0.6;
	//run("Analyze Particles...", "size=40-3000 circularity=0.70-1.00 pixel show=Masks in_situ");
	run("Analyze Particles...", "size="+minFatSize+"-"+maxFatSize+" circularity="+fatRoundness+"-1.00 pixel show=Masks in_situ");
	*/
	

	
	// Reset ROI manager and clear previous results
    roiManager("Reset");
    run("Clear Results");
    
    //Add masks to roimanager
    selectWindow("tissueMask");
    run("Select None");
    run("Create Selection");
    Roi.setName("Tissue");
    roiManager("add");
    close("tissueMask");
    
    /*
    selectWindow("fatMask");
 	run("Select None");
    run("Create Selection");
    Roi.setName("fatMask");
    roiManager("add");
    close("fatMask");
    */
    
    selectWindow("texturePositive");
    run("Select None");
    run("Create Selection");
    Roi.setName("texturePositive");
    roiManager("add");
    close("texturePositive");
    
    /*
    selectWindow("fatSegmented");
    run("Select None");
    run("Create Selection");
    Roi.setName("fatSegmented");
    roiManager("add");
    close("fatSegmented");
    */
    
    //waitForUser;
        
    print("- Calculate Quantification Features ...");
    
    // RESULTS --- Calculate Quantification Features 
    
    run("Clear Results");
    selectWindow(MyTitle);
    run("Set Measurements...", "area redirect=None decimal=2");

    // Tissue
    roiManager("select", 0);
    roiManager("Measure");
    At = getResult("Area", 0);
    Atm = At * r * r; // Convert area to micra

    // Fat deposits
    roiManager("select", 1);
    roiManager("Measure");
    Ap = getResult("Area", 1);
    Apm = Ap * r * r; // Convert area to micra

    // Ratio of fat deposits to tissue area
    r1 = Apm / Atm * 100;

    // Save results to a file
    run("Clear Results");
    if (File.exists(output + File.separator + "Quantification_Steatosis.xls")) {
        open(output + File.separator + "Quantification_Steatosis.xls");
        IJ.renameResults("Results");
    }
    i = nResults;
    setResult("[Label]", i, MyTitle);
    setResult("Tissue area (um2)", i, Atm);
    setResult("Steatosis area (um2)", i, Apm);
    setResult("Ratio Asteatosis/Atissue (%)", i, r1);
    setResult("# Lipids Detected", i, nLipids);
    setResult("Lipid Avg Size (um2)", i, areaAvg);
    setResult("Lipid stdDev Size (um2)", i, areaStdDev);
    saveAs("Results", output + File.separator + "Quantification_Steatosis.xls");
	
	print("- Saving Segmented Images ...");

	
	//waitForUser;
	
    // Display and save analyzed images
    selectWindow(MyTitle);
    roiManager("Show None");
    roiManager("Select", 0);
    roiManager("Set Color", "yellow");
    roiManager("Set Line Width", 1);
    run("Flatten");
    roiManager("Show None");
    roiManager("Select", 1);
    roiManager("Set Color", "green");
    roiManager("Set Line Width", 1);
    run("Flatten");
    saveAs("Jpeg", OutDir + File.separator + MyTitle_short + "_analyzed.jpg");
    rename(MyTitle_short + "_analyzed.jpg");
	
	//waitForUser;
	
    // Close windows and reset tool
    close("\\Others");
    setTool("zoom");

    if (InDir != "-") {
        close();
    }

    //showMessage("Done!");
}
