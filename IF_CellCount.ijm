function macroInfo(){
	
// * Target User: General
// *  

	scripttitle= "Nuclei Count in 2D Confocal Images";
	version= "1.02";
	date= "2023";
	

// *  Tests Images:

	imageAdquisition="Confocal";
	imageType="IF";  
	voxelSize="Voxel size: unknown um xy";
	format="Format: Uncompressed .czi";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button 
	
	parameter1="Channel of Interest: DAPI";
	parameter2="Min particle size (px)";
	parameter3="Max Cell size (px)";
	 

 //  2 Action tools:
	buttom1="Im: Single File processing";
 //	buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs

	excelName="Quantification_IF2D_CellCount.xls";
	feature1="Image Label";
	feature2="# Cells";
	feature3="Average Cells Size  [microns^3]";
	feature4="std Cells Size [microns^3]"
	feature5="Average Intensity";
	
/*  	  
 *  version: 1.02 
 *  Author: Mikel Ariz  
 *  Commented by: Tomas Muñoz 2023 
 *  Date : 2015
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

	
	//image1="../templateImages/cartilage.jpg";
	//descriptionActionsTools="
	
	showMessage("ImageJ Script", "<html>"
		+"<style>h{margin-top: 5px; margin-bottom: 5px;} p{margin: 0px;padding: 0px;} ol{margin-left: 20px;padding: 5px;} #list-style-3 {list-style-type: circle;.container {max-width: 1200px; margin: 0 auto; padding: 0px; }</style>"
	    +"<h1><font size=6 color=Teal href=https://cima.cun.es/en/research/technology-platforms/image-platforms>CIMA: Imaging Platform</h1>"
	    +"<h1><font size=5 color=Purple><i>Software Development Service</i></h1>"
	    +"<p><font size=2 color=Purple><i>ImageJ Macros</i></p>"
	    +"<h2><font size=3 color=black>"+scripttitle+"</h2>"
	    +"<p><font size=2>Modified by Tomas Mu&ntilde;oz Santoro</p>"
	    +"<p><font size=2>Version: "+version+" ("+date+")</p>"
	    +"<p><font size=2> contact tmsantoro@unav.es</p>" 
	    +"<p><font size=2> Available for use/modification/sharing under the "+"<p4><a href=https://opensource.org/licenses/MIT/>MIT License</a></p>"
	    +"<h2><font size=3 color=black>Developed for</h2>"
	    +"<p><font size=3  i>Input Images</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+imageAdquisition +"</li><li>"+imageType+"</li><li>"+voxelSize+"</li><li>"+format+"</li></ul>"
	    +"<p><font size=3 i>Action tools (Buttons)</i></p>"
	    +"<ol><font size=2  i><li>"+buttom1+"</li></ol>"
	    +"<p><font size=3  i>PARAMETERS: </i></p>"
	    +"<ul id=list-style-3><font size=2  i>"
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li>"
	    +"<li>"+parameter3+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excelName+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li><li>"+feature5+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}

var ch = 1, maxNucleiSize = 6000, minNucleiSize = 100; 

macro "cellCount Action Tool 1 - Cf00T2d15IT6d10m" {
    // Close all open images
    close("*");
    
    // Display macro information
    macroInfo();
    
    // Open ROI Manager
    run("ROI Manager...");
    
    // Open dialog to select an image file
    name = File.openDialog("Select File");
    print("Processing " + name);
    
    // Create dialog to input analysis parameters
    Dialog.create("Parameters");
    Dialog.addMessage("Choose parameters");
    Dialog.addNumber("Channel of Interest: (DAPI)", ch);  // Input for channel of interest
    Dialog.addNumber("Max Particle size (px3)", maxNucleiSize);  // Input for maximum particle size
    Dialog.addNumber("Min particle size (px3)", minNucleiSize);  // Input for minimum particle size
    Dialog.show();
    
    // Retrieve parameters from the dialog
    ch = Dialog.getNumber();  // Channel of interest
    maxNucleiSize = Dialog.getNumber();  // Maximum particle size
    minNucleiSize = Dialog.getNumber();  // Minimum particle size
    
    // Perform cell counting
    IF2D_CellCount("-", "-", name, ch, maxNucleiSize, minNucleiSize);
}

macro "cellCount Action Tool 2 - C00fT0b11DT9b09iTcb09r" {
    // Close all open images
    close("*");
    
    // Display macro information
    macroInfo();
    
    // Open ROI Manager
    run("ROI Manager...");
    
    // Open dialog to select an image file
    name = File.openDialog("Select File");
    print("Processing " + name);
    
    // Create dialog to input analysis parameters
    Dialog.create("Parameters");
    Dialog.addMessage("Choose parameters");
    Dialog.addNumber("Channel of Interest", ch);  // Input for channel of interest
    Dialog.addNumber("Max Particle size (px3)", maxNucleiSize);  // Input for maximum particle size
    Dialog.addNumber("Min particle size (px3)", minNucleiSize);  // Input for minimum particle size
    Dialog.show();
    
    // Retrieve parameters from the dialog
    ch = Dialog.getNumber();  // Channel of interest
    maxNucleiSize = Dialog.getNumber();  // Maximum particle size
    minNucleiSize = Dialog.getNumber();  // Minimum particle size
    
    // Disable batch mode
    setBatchMode(false);

     // Loop through files in the directory and process each one
    for (j = 0; j < L; j++) {
        if (endsWith(list[j], "czi")) {
            name = list[j];
            print("Processing " + name);
            IF2D_CellCount("-", "-", name, ch, maxNucleiSize, minNucleiSize);
            setBatchMode(false);
        }
    }
    setBatchMode(false);
    showMessage("Cells quantified!");
}


function IF2D_CellCount(output, InDir, name, ch, maxNucleiSize, minNucleiSize) {
	
	/**
	 * Counts cells in a 2D image stack and performs quantification.
	 *
	 * @param output        The output directory path.
	 * @param InDir         The input directory path, or "-" if not applicable.
	 * @param name          The name of the image file to process.
	 * @param ch            The channel of interest for analysis.
	 * @param maxNucleiSize The maximum size of nuclei to consider (in pixels^3).
	 * @param minNucleiSize The minimum size of nuclei to consider (in pixels^3).
	 */
	
    run("Close All");

    // Import the image using Bio-Formats Importer
    if (InDir == "-") {
        run("Bio-Formats Importer", "open=[" + name + "] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
    } else {
        run("Bio-Formats Importer", "open=[" + InDir + name + "] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
    }

    // Initialize conditions
    roiManager("Reset");
    run("Clear Results");
    close("Results");
    run("Colors...", "foreground=white background=black selection=yellow");
    run("Set Measurements...", "area redirect=None decimal=2");
    getVoxelSize(rx, ry, rz, unit);
    run("Set Scale...", "distance=1 known=" + rx + " unit=micron");

    // Get current image title and directory
    MyTitle = getTitle();
    output = getInfo("image.directory");
    OutDir = output + File.separator + "AnalyzedImages";
    File.makeDirectory(OutDir);
    aa = split(MyTitle, ".");
    MyTitle_short = aa[0];
    showStatus("Analyzing " + MyTitle);
    print(MyTitle);
        
    // Image channels adjustment
    run("Make Composite");
    run("Duplicate...", "title=orig duplicate");
    selectWindow("orig");
    getDimensions(width, height, channels, slices, frames);
    
    // Process the specified channel
    if (channels > 1) {
        run("Make Composite");
        run("Split Channels");
        selectWindow("C" + ch + "-orig");
        rename("nucleus2D");
        close("*-orig");
    } else {
        rename("nucleus2D");
    }
    if(slices>1){
    	Dialog.addMessage("Image introduced is 3D, please use IF3D_CellCount instead");
    }
    
    // Segment nuclei in 2D
    kernelSize2D = newArray(150, 150);
    segmentnucleus2D("nucleus2D", kernelSize2D,minNucleiSize,maxNucleiSize);
    
   	selectWindow("nucleus2D-labelled");
    run("Clear Results");
    close("Results");
    run("3D Intensity Measure", "objects=nucleus2D-labelled signal=nucleus2D");
    nCells = nResults;
    print(nCells);
    cellsIntensity = Table.getColumn("IntensityAvg");
    run("Clear Results");
    close("Results");
    selectWindow("nucleus2D-labelled");
    run("3D Volume");
    cellsVolume = Table.getColumn("Volume(Pix)");
    close("Results");
    
    
    // Compute mean and standard deviation of cell volumes and intensities
    Array.getStatistics(cellsIntensity, Imin, Imax, Iavg, IstdDev);
    Array.getStatistics(cellsVolume, minVol, maxVol, meanVol, stdVol);
    meanVol = meanVol * (rx * ry);
    stdVol = stdVol * (rx * ry);
    print(meanVol);
    print(stdVol);

    // Write results to Excel file
    run("Clear Results");
    if (File.exists(output + File.separator + "Quantification_IF2D_CellCount.xls")) {
        // If the file exists, add and modify results
        open(output + File.separator + "Quantification_IF2D_CellCount.xls");
        IJ.renameResults("Results");
        i = nResults;
        print(i);
        setResult("[Label]", i, MyTitle);   
        setResult("# cells", i, nCells); 
        setResult("AverageSize [micras^3]", i, meanVol);
        setResult("stdSize [micras^3]", i, stdVol);
        setResult("meanIntensity]", i, Iavg);
        saveAs("Results", output + File.separator + "Quantification_IF2D_CellCount.xls");
    } else {
        // If the file does not exist, create it and add results
        i = nResults;
        setResult("[Label]", 0, MyTitle); 
        setResult("# cells", i, nCells); 
        setResult("AverageSize [micras^3]", i, meanVol);
        setResult("stdSize [micras^3]", i, stdVol);
        setResult("meanIntensity]", i, Iavg);
        saveAs("Results", output + File.separator + "Quantification_IF2D_CellCount.xls");
    }
	
    // Save labelled image
    selectWindow("nucleus2D");
    run("From ROI Manager");
    roiManager("Set Color", "yellow");
    roiManager("Set Line Width", 1);
    roiManager("Show All");
    run("Flatten");
    saveAs("Tiff", OutDir + File.separator + MyTitle_short + "_nCells.tif");
    close("\\Others");
}


function segmentnucleus2D(image, kernelSize2D,minNucleiSize,maxNucleiSize) {

	/**
	 * Segments nuclei in a 2D image using CLIJx and STARDIST IF MODEL.
	 *
	 * @param image        The name of the image window to be processed.
	 * @param kernelSize2D Array containing the kernel sizes for background subtraction (sigma_x, sigma_y, sigma_z).
	 */
	
	
    // Print message to console
    print("Segmenting Nucleus 2D....");
    
    // Select the specified image window
    selectWindow(image);
    setBatchMode(false);
    
    // Duplicate the selected image for processing
    run("Duplicate...", "title=SegNucleus2D_subBckg duplicate");
    run("Subtract Background...", "rolling=50");
	
	/*
    // Initialize CLIJx and CLIJ2 extensions
    run("CLIJ2 Macro Extensions", "cl_device=[]");
    Ext.CLIJ2_clear();
    
    // Subtract background using CLIJx
    image1 = "SegNucleus2D";
    //kernelSize2D=newArray(150,150);
    Ext.CLIJ2_push(image1);
    image2 = "SegNucleus2D_subBckg";
    sigma_x = kernelSize2D[0];
    sigma_y = kernelSize2D[1];
    Ext.CLIJx_subtractBackground2D(image1, image2, sigma_x, sigma_y);
    Ext.CLIJ2_pull(image2);
    Ext.CLIJ2_clear();
	*/
	
	// Perform 2D nuclei segmentation on the background-subtracted image
    selectWindow("SegNucleus2D_subBckg");
    starDist2D("SegNucleus2D_subBckg",minNucleiSize);
    
   	// From labels to ROIs 
	selectWindow("Label Image");
	run("Label Size Filtering", "operation=Greater_Than size="+minNucleiSize);
	close("Label Image");
	run("Label image to ROIs", "rm=[RoiManager[visible=true]]");
	run("ROIs to Label image");
	close("Label-sizeFilt");
	selectWindow("ROIs2Label_Label-sizeFilt");
	rename(image+"-labelled");
    
    // Exit batch mode and display results
    setBatchMode("exit and display");
}


function starDist2D(im,minNucleiSize){
	//im="SegNucleus2D_subBckg";
	getLocationAndSize(x, y, width, height);
	call("ij.gui.ImageWindow.setNextLocation", x, y);
  	run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input':"+im+", 'modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'0.0', 'percentileTop':'100.0', 'probThresh':'0.479071', 'nmsThresh':'0.2', 'outputType':'Label Image', 'nTiles':'1', 'excludeBoundary':'2', 'roiPosition':'Automatic', 'verbose':'false', 'showCsbdeepProgress':'false', 'showProbAndDist':'false'], process=[false]");
					
}
	
