
function macroInfo(){
	
// * Title  
	scripttitle =  "3D QUALITATIVE COLOCALIZATION OF MICROGLIA BIOMARKERS   ";
	version =  "1.02";
	date =  "2023";
	

// *  Tests Images:

	imageAdquisition = "IF Confocal 2 Channels ";
	imageType = "3D 8 bit";  
	voxelSize = "Voxel size:  unknown";
	format = "Format: czi";   
	
 /*
 *  GUI Requierments:
 *		// automatic Protein and Microglia signal detection in 3D
 *		// Microglia-Protein 3D colocalization quantification
 */
 
 // Important Parameters: 
 
   // Dialog for setting parameters
    parameter1="Microglia and Protein channels order";	
    parameter2="Microglia and Protien thresholds [0-255]";	
    parameter3="Min Microglia and Protein particle size (px)";
    parameter4="Check if Contains Vessels";

 //  2 Action tools:
		
	 buttom1 = "Im: Single File processing. Use Single file processing for fine tunning parameters";
	 buttom2 = "Dir: Batch Mode. Please tune parameters before using Batchmode";

//  OUTPUT

// Analyzed Images with ROIs

	excel = "QuantificationResults_IF3D_BiofilmQuantification_Colultivos.xls";
	
    feature1="Label";
    feature2="Protein-marker volume um^3)";
    feature3="Microglia-marker volume um^3";
    feature4="Protein-Microglia coloc volume um^3";
    feature5="Ratio of coloc wrt total volume (%)";
 
 /*  	  
 *  version: 1.02 
 *  Author: Mikel Ariz  
 *  Commented by: Tomas Muñoz  
 *  Date : 2023
 *  
 */
 
// SOFTWARE LICENCE
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
		+"<style>h{margin-top: 5px; margin-bottom: 5px;} p{margin: 0px;padding: 0px;} ol{margin-left: 20px;padding: 5px;} #list-style-3 {list-style-type: circle;.container {max-width: 1200px; margin: 0 auto; padding: 0px; }</style>"
	    +"<h1><font size = 6 color = Teal href = https://cima.cun.es/en/research/technology-platforms/image-platforms>CIMA: Imaging Platform</h1>"
	    +"<h1><font size = 5 color = Purple><i>Software Development Service</i></h1>"
	    +"<p><font size = 2 color = Purple><i>ImageJ Macros</i></p>"
	    +"<h2><font size = 3 color = black>"+scripttitle+"</h2>"
	    +"<p><font size = 2>Modified by Tomas Mu&ntilde;oz Santoro</p>"
	    +"<p><font size = 2>Version: "+version+" ("+date+")</p>"
	    +"<p><font size = 2> contact tmsantoro@unav.es</p>" 
	    +"<p><font size = 2> Available for use/modification/sharing under the "+"<p4><a href = https://opensource.org/licenses/MIT/>MIT License</a></p>"
	    +"<h2><font size = 3 color = black>Developed for</h2>"
	    +"<p><font size = 3  i>Input Images</i></p>"
	    +"<ul id = list-style-3><font size = 2  i><li>"+imageAdquisition +"</li><li>"+imageType+"</li><li>"+voxelSize+"</li><li>"+format+"</li></ul>"
	    +"<p><font size = 3 i>Action tools (Buttons)</i></p>"
	    +"<ol><font size = 2  i><li>"+buttom1+"</li><li>"+buttom2+"</li></ol>"
	    +"<p><font size = 3  i>PARAMETERS:</i></p>"
	    +"<ul id = list-style-3><font size = 2  i>"
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li>"
	    +"<li>"+parameter3+"</li>"
    	+"<li>"+parameter4+"</li></ul>"
    	+"<p><font size = 3  i> Quantification Results: </i></p>"
	    +"<p><font size = 3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size = 3  i>Excel "+excel+"</i></p>"
	    +"<ul id = list-style-3><font size = 2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li>"
	    +"<li>"+feature5+"</li></ul>"
	    +"<h0><font size = 5></h0>"
	    +"");
	   //+"<P4><font size = 2> For more detailed instructions see "+"<p4><a href = https://www.protocols.io/edit/movie-timepoint-copytoclipboaMarker2-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}

// Initial parameters for channels, thresholds, and minimum particle sizes
var cProtein=2, cMicroglia=1, thProtein=30, thMicroglia=30, minSizeProtein=20, minSizeMicroglia=20;
var vessels=true, thVessels=150, minSizeVessels=200;


macro "microgliaMarkerColoc Action Tool 1 - Cf00T2d15IT6d10m" {
    macroInfo();                      // Display macro info or metadata
    run("Close All");                 // Close all open images

    // File selection dialog
    name = File.openDialog("Select File");
    print("Processing " + name);      // Print selected file name

    // Dialog for setting parameters
    Dialog.create("Parameters for the analysis");
    Dialog.addMessage("Choose channel numbers");	
    Dialog.addNumber("Protein marker", cProtein);	
    Dialog.addNumber("Microglia marker", cMicroglia);
    Dialog.addMessage("Choose analysis parameters");	
    Dialog.addNumber("Protein threshold", thProtein);	
    Dialog.addNumber("Microglia threshold", thMicroglia);
    Dialog.addNumber("Min Protein particle size (px)", minSizeProtein);	
    Dialog.addNumber("Min Microglia particle size (px)", minSizeMicroglia);
    Dialog.addCheckbox("Contains Vessels", true);
    Dialog.addNumber("Vessels threshold", thVessels);
    Dialog.addNumber("Min Vessel size (px)", minSizeVessels);
    Dialog.show();

    // Retrieve values from dialog inputs
    cProtein = Dialog.getNumber();
    cMicroglia = Dialog.getNumber();
    thProtein = Dialog.getNumber();
    thMicroglia = Dialog.getNumber();
    minSizeProtein = Dialog.getNumber();
    minSizeMicroglia = Dialog.getNumber();
    vesselsFlag=Dialog.getCheckbox();
    thVessels = Dialog.getNumber();
    minSizeVessels = Dialog.getNumber();

    // Run quantification with parameters
    microgliaMarkerColoc("-", "-", name, cProtein, cMicroglia, thProtein, thMicroglia, minSizeProtein, minSizeMicroglia,vesselsFlag,thVessels,minSizeVessels);
    setBatchMode(false);              // Turn off batch mode
    showMessage("Quantification finished!");  // Completion message
}

macro "microgliaMarkerColoc Action Tool 2 - C00fT0b11DT9b09iTcb09r" {
    macroInfo();                      // Display macro info or metadata
    run("Close All");                 // Close all open images

    // Directory selection dialog
    InDir = getDirectory("Choose Tiles' directory");
    list = getFileList(InDir);        // List all files in directory
    L = lengthOf(list);               // Count files in the list

  
    // Dialog for setting parameters
    Dialog.create("Parameters for the analysis");
    Dialog.addMessage("Choose channel numbers");	
    Dialog.addNumber("Protein marker", cProtein);	
    Dialog.addNumber("Microglia marker", cMicroglia);
    Dialog.addMessage("Choose analysis parameters");	
    Dialog.addNumber("Protein threshold", thProtein);	
    Dialog.addNumber("Microglia threshold", thMicroglia);
    Dialog.addNumber("Min Protein particle size (px)", minSizeProtein);	
    Dialog.addNumber("Min Microglia particle size (px)", minSizeMicroglia);
    Dialog.addCheckbox("Contains Vessels", true);
    Dialog.addNumber("Vessels threshold", thVessels);
    Dialog.addNumber("Min Vessel size (px)", minSizeVessels);
    Dialog.show();

    // Retrieve values from dialog inputs
    cProtein = Dialog.getNumber();
    cMicroglia = Dialog.getNumber();
    thProtein = Dialog.getNumber();
    thMicroglia = Dialog.getNumber();
    minSizeProtein = Dialog.getNumber();
    minSizeMicroglia = Dialog.getNumber();
    vesselsFlag=Dialog.getCheckbox();
    thVessels = Dialog.getNumber();
    minSizeVessels = Dialog.getNumber();
    

    // Loop through each file in the directory
    for (j = 0; j < L; j++) {
        if (endsWith(list[j], "czi")) {   // Check if file has a ".czi" extension
            name = list[j];
            print("Processing " + name);  // Print name of current file
            
            // Run quantification with parameters
            microgliaMarkerColoc(InDir, InDir, list[j], cProtein, cMicroglia, thProtein, thMicroglia, minSizeProtein, minSizeMicroglia,vesselsFlag,thVessels,minSizeVessels);
            setBatchMode(false);          // Turn off batch mode
            close("*");
            
        }
    }

    showMessage("Quantification finished!");  // Completion message
}



function microgliaMarkerColoc(output, InDir, name, cProtein, cMicroglia, thProtein, thMicroglia, minSizeProtein, minSizeMicroglia,vesselsFlag,thVessels,minSizeVessels) {
    
	/**
	 * Function: microgliaMarkerColoc
	 * --------------
	 * This function processes and analyzes bioimage data, specifically to identify two markers (Protein and Microglia)
	 * within an image stack. It performs image import, channel selection, background subtraction, segmentation, 
	 * particle analysis, ROI (Region of Interest) management, and mask projection. The function outputs segmented 
	 * images, ROIs for each marker, and 2D projection masks.
	 *
	 * Parameters:
	 *  @param output              String representing the output directory path for saving results.
	 *  @param InDir               String representing the input directory path; use "-" to indicate no directory.
	 *  @param name                String representing the name of the file to be processed.
	 *  @param cProtein            Integer for the channel number of the Protein marker.
	 *  @param cMicroglia          Integer for the channel number of the Microglia marker.
	 *  @param thProtein           Integer specifying the threshold value for Protein segmentation.
	 *  @param thMicroglia         Integer specifying the threshold value for Microglia segmentation.
	 *  @param minSizeProtein      Integer defining the minimum particle size (pixels) for Protein marker detection.
	 *  @param minSizeMicroglia    Integer defining the minimum particle size (pixels) for Microglia marker detection.
	 *  @param vesselsFlag		   Boolean define if the image contains vessels
	 *  @param thVessels     	   Integer specifying the threshold value for Vessels segmentation.
	 *  @param minSizeVessels      Integer defining the minimum Vessels size (pixels) for detection.	
	 */
	 
    // Close any open images to ensure a clean workspace
    run("Close All");

    // Conditional image import using Bio-Formats based on input directory presence
    if (InDir == "-") {
        // Import the image file directly when no directory is specified
        run("Bio-Formats Importer", "open=[" + name + "] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
    } else {
        // Import the image from specified input directory
        run("Bio-Formats Importer", "open=[" + InDir + name + "] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
    }
    
    // Set display mode to composite for viewing multiple channels
    Stack.setDisplayMode("composite");

    // Set colors for foreground, background, and ROI selection
    run("Colors...", "foreground=black background=white selection=yellow");

    // Get image dimensions for reference in further analysis
    Stack.getDimensions(width, height, channels, slices, frames);

    // Reset ROI manager and clear results table for a fresh start
    roiManager("Reset");
    run("Clear Results");

    // Capture current image title and output directory path
    MyTitle = getTitle();
    output = getInfo("image.directory");

    // Create directory to save processed images and ROIs
    OutDir = output + File.separator + "AnalyzedImages_Coloc/";
    File.makeDirectory(OutDir);

    // Extract main title without extension for use in file naming
    aa = split(MyTitle, ".");
    MyTitle_short = aa[0];

    // Retrieve voxel size information for analysis context
    getDimensions(width, height, channels, slices, frames);
    getVoxelSize(rx, ry, rz, unit);
	FOV=(width*height*slices)*(rx*ry*rz);

    // Set the main image as "orig" for easier reference
    selectWindow(MyTitle);
    rename("orig");

    // Begin batch mode to optimize processing speed
    setBatchMode(true);
        
    // ----------- DETECT VESSELS (FALSE POSITIVES PROTEINs) -----------
	
	if (vesselsFlag){
	
		// Duplicate the image channel corresponding to the Protein marker
	    selectWindow("orig");
	    run("Duplicate...", "title=VesselsMask duplicate channels=" + cProtein);
	    
	    // Set threshold for segmentation and convert to binary mask
		//run("Threshold...");
		vesselsTh=150;
		setThreshold(vesselsTh, 255);
		setOption("BlackBackground", false);
		run("Convert to Mask", "method=Otsu background=Dark");
		    
	    // Apply median filter to smooth mask and analyze particles based on minimum size
	    run("Median...", "radius=1 stack");
	    //minVesselSize=250;
	    run("Analyze Particles...", "size=" + minSizeVessels + "-5000 pixel show=Masks in_situ stack");
	    selectImage("VesselsMask");
		setOption("BlackBackground", false);
		
		for (i = 0; i < 5; i++) {
			run("Dilate 3D", "iso=255");
		}
				
	}
	
    // ----------- DETECT PROTEIN MARKER -----------
    
    // Duplicate the image channel corresponding to the Protein marker
    selectWindow("orig");
    run("Duplicate...", "title=Protein duplicate channels=" + cProtein);
    
    selectWindow("Log");
    print("PROCESSING PROTEIN......");
    
    // Subtract background from the Protein channel
    run("Subtract Background...", "rolling=20 stack");

    // Duplicate the channel for mask generation and set 8-bit format
    run("Duplicate...", "title=ProteinMask duplicate range=1-" + slices);
    run("8-bit");

    // Set threshold for segmentation and convert to binary mask
    setAutoThreshold("Huang dark");
    setThreshold(thProtein, 255);
    setOption("BlackBackground", false);
    run("Convert to Mask", "method=Default background=Dark");
    
    // Apply median filter to smooth mask and analyze particles based on minimum size
    run("Median...", "radius=1 stack");
    run("Analyze Particles...", "size=" + minSizeProtein + "-Infinity pixel show=Masks in_situ stack");
    
    if (vesselsFlag){
	    //DELETE VESSELS
	    imageCalculator("Subtract stack", "ProteinMask","VesselsMask");
    }
    
    saveAs("Tiff", OutDir + File.separator + MyTitle_short + "_ProteinMask.tif");
    rename("ProteinMask");
    
    print("3D Volume Quantification......");
    
    //--Calculate volume fraction 
	selectWindow("ProteinMask");
	run("Analyze Regions 3D", "volume surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
	
	selectWindow("ProteinMask-morpho");
	IJ.renameResults("Results");
	Vol_Prot= getResult("Volume", 0);	// microglia  volume
	
	print("Protein Volume: "+Vol_Prot);
     
    // ----------- DETECT MICROGLIA MARKER -----------
    
    // Duplicate the image channel corresponding to the Microglia marker
    selectWindow("orig");
    getDimensions(width, height, channels, slices, frames);
    run("Duplicate...", "title=Microglia duplicate channels=" + cMicroglia);
    
    print("PROCESSING MICROGLIA......");

    // Subtract background from the Microglia channel
    run("Subtract Background...", "rolling=30 stack");
    setSlice(floor(slices/2));
    run("Enhance Contrast", "saturated=0.35");
	run("Apply LUT", "stack");
    run("Median...", "radius=1 stack");
    
    // Duplicate the channel for mask generation and set 8-bit format
    run("Duplicate...", "title=MicrogliaMask duplicate range=1-" + slices);
    run("8-bit");

    // Set threshold for segmentation and convert to binary mask
    setAutoThreshold("Huang dark");
    setThreshold(thMicroglia, 255);
    run("Convert to Mask", "method=Default background=Dark");

    // Apply median filter to smooth mask and analyze particles based on minimum size
    run("Median...", "radius=1 stack");
    run("Analyze Particles...", "size=" + minSizeMicroglia + "-Infinity pixel show=Masks in_situ stack");
    
    if(vesselsFlag){
	    //DELETE VESSELS
		imageCalculator("Subtract stack", "MicrogliaMask","VesselsMask");
		close("VesselsMask");
    }
	saveAs("Tiff", OutDir + File.separator + MyTitle_short + "_MicrogliaMask.tif");
    rename("MicrogliaMask");	
    
    print("3D Volume Quantification......");
    
	//--Calculate volume fraction 
	selectWindow("MicrogliaMask");
	run("Analyze Regions 3D", "volume surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
	
	selectWindow("MicrogliaMask-morpho");
	IJ.renameResults("Results");
	Vol_Microglia = getResult("Volume", 0);	// microglia  volume
 
 	print("Microglia Volume: "+Vol_Microglia);
 
	/**
	 * COLOCALIZATION SECTION
	 * -------------------
	 * Measures area and volume of each marker (Protein and Microglia) and their colocalized regions, and  colocalization ratio.
	 */
	
    print("Calculating Colocalization......");
	
	selectWindow("MicrogliaMask");
	run("Duplicate...", "title=ColocMask duplicate ");

	imageCalculator("AND stack", "ColocMask", "ProteinMask");
	
	saveAs("Tiff", OutDir + File.separator + MyTitle_short + "_ColocMask.tif");
    rename("ColocMask");	
    
    print("3D Volume Quantification......");
    
	//--Calculate volume fraction 
	selectWindow("ColocMask");
	run("Analyze Regions 3D", "volume surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
        
	selectWindow("ColocMask-morpho");
	IJ.renameResults("Results");
	Vol_Coloc = getResult("Volume", 0);	// coloc  volume
	
    // Calculate colocalization ratio as a percentage
    rCol = Vol_Coloc / (Vol_Microglia + Vol_Prot) * 100;
    
     
	/**
	 * RESULTS WRITING
	 * ---------------
	 * Writes the calculated results to an Excel file. If the file already exists, results are appended.
	 */

    run("Clear Results");

    // Check if results file exists and open if so
    if (File.exists(output + File.separator + "Colocalization_Results.xls")) {
        open(output + File.separator + "Colocalization_Results.xls");
        IJ.renameResults("Results");
    }

    // Write calculated volumes and colocalization ratio
    i = nResults;
    setResult("Label", i, MyTitle);
    setResult("Field of View (um3)", i, FOV);
    setResult("Protein-marker volume (" + unit + "^3)", i, Vol_Prot);
    setResult("Microglia-marker volume (" + unit + "^3)", i, Vol_Microglia);
    setResult("Protein-Microglia coloc volume (" + unit + "^3)", i, Vol_Coloc);
    setResult("Ratio of coloc wrt total volume (%)", i, rCol);
    saveAs("Results", output + File.separator + "Colocalization_Results.xls");
    
     // SAVE 3D SEGMENTED IMAGE FOR VALIDATION
	selectWindow("orig");
	run("Select None");
	run("Remove Overlay");
	run("Duplicate...", "title=3DimageToSave duplicate");
	          
	// add overlay rois
	selectWindow("3DimageToSave");
	print("SAVING RESULTS...");
	print("3D image segmentation...");
	addOverlay3D("3DimageToSave","MicrogliaMask",1,"green");
	addOverlay3D("3DimageToSave","ProteinMask",1,"red");
	addOverlay3D("3DimageToSave","ColocMask",1,"yellow");
		
    wait(500);
    selectWindow("3DimageToSave");
	saveAs("Tiff", OutDir + File.separator + MyTitle_short + "_3Danalyzed.tif");
    rename(MyTitle_short + "_3Danalyzed.tif");
    
    //2D PROJECTION.
	selectWindow("orig");
	run("Select None");
	run("Remove Overlay");
	run("Make Composite");
	run("Duplicate...", "title=2DimageToSave duplicate");
	run("RGB Color", "slices");
    run("Z Project...", "projection=[Max Intensity]");
    setBatchMode("show");
    close("2DimageToSave");
    selectWindow("MAX_2DimageToSave");
    rename("2DimageToSave");
    
    selectWindow("MicrogliaMask");
    run("Invert LUT");
    run("Z Project...", "projection=[Max Intensity]");
	run("Invert LUT");
	run("Create Selection");
	selectWindow("2DimageToSave");
	run("Colors...", "foreground=black background=white selection=green");
	run("Restore Selection");
	Overlay.addSelection;
	Overlay.flatten;
	close("2DimageToSave");
	rename("2DimageToSave");
	
	close("*Microglia*");
	
	selectWindow("ProteinMask");
    run("Invert LUT");
    run("Z Project...", "projection=[Max Intensity]");
	run("Invert LUT");
	run("Create Selection");
	selectWindow("2DimageToSave");
	run("Colors...", "foreground=black background=white selection=red");
	run("Restore Selection");
	Overlay.addSelection;
	Overlay.flatten;
    close("2DimageToSave");
    rename("2DimageToSave");
    
    close("*Protein*");
    
    selectWindow("ColocMask");
    run("Invert LUT");
    run("Z Project...", "projection=[Max Intensity]");
	run("Invert LUT");
	run("Create Selection");
	selectWindow("2DimageToSave");
	run("Colors...", "foreground=black background=white selection=yellow");
	run("Restore Selection");
	Overlay.addSelection;
	Overlay.flatten;
    close("2DimageToSave");
    rename("2DimageToSave");
    
    setBatchMode("exit and display");
    wait(500);
   
    if (InDir != "-") {
        close();
    }
	
	close("orig");
	close("*Mask*");

    // Clear memory
    wait(500);
    run("Collect Garbage");

}


function addOverlay3D(rawImage,maskImage,channel,color){
		
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
}

