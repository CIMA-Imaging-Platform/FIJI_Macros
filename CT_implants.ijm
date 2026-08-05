

function macroInfo(){

//  Analyze CT images, Quantify Implants Volumes;
// * Target User:   
// *  

	scripttitle= "Quantify Implant Deformation: Reference vs Treatment Deformation";
	version= "1.01";
	date= "19.05.2025";
	

// *  Tests Images:

	imageAdquisition="microCT";
	imageType="8bit/16bit/32bit";  
	voxelSize="Voxel size:  unkown um xy";
	format="Format: .tif";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button 
  		
	//parameter1="Introduce Dimension to be reduced"; 
		 
//  2 Action tools:
	buttom1="Im: Single File processing";
	buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs

	//excel="Image folder with all sequences";
	
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
	    +"<ol><font size=2  i><li>"+buttom1+"</li><li>"+buttom2+"</li></ol>"
	    +"<p><font size=3  i> Results: </i></p>"
	    +"<p><font size=3 i>tif images: Visualize  Images</i></p>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}

macro "preProcessing Action Tool 1 - Cf00T2d15PT6d10R" {
    /**
     * Performs batch preprocessing of sample images by aligning them to a reference image.
     * 
     * Steps include:
     *  - Opening the reference image and defining ROI
     *  - Iterating through a selected input directory
     *  - Preprocessing each image using the `preProcessing` function
     * 
     * User interaction is required to select the input directory.
     */

    // Close all open images, reset ROI Manager, and clear the results table
    close("*");
    roiManager("Reset");
    run("Clear Results");

    // Set standard display colors for consistency
    run("Colors...", "foreground=black background=white selection=green");

    // Define and print the path to the fixed (reference) image
    reference = "F:/TMSANTORO/0_USUARIOS_PLATAFORMA/1_USUARIOS_TOMAS/EXTERNOS/MariaFernanda/2025_05_19_Implantes/referenceSample/MARIA_FERNANDA_IMPLANTES_16_control_original_134444.tif";
    print("Fixed Image : " + reference);

    // Load reference image and move to its center slice
    open(reference);
    setSlice(floor(nSlices / 2));

    // Retrieve title and coordinates of ROI on reference image
    referenceTitle = getTitle();
    selectWindow(referenceTitle);
    getLocationAndSize(x, y, width, height);
    locationRefence = newArray(x, y, width, height);  // Store ROI position

    // Prompt the user to select the directory containing moving images (samples)
    InDir = getDirectory("Choose Directory of samples to Register (Moving Images)");
    list = getFileList(InDir);  // Get filenames in the selected directory
    L = lengthOf(list);         // Number of files to process

    // Loop through each file and apply preprocessing
    for (j = 0; j < L; j++) {
        // Filter only TIFF or JPG files
        if (endsWith(list[j], "jpg") || endsWith(list[j], "tif")) {
            name = list[j];

            // Run preprocessing on the current image
            setBatchMode(false);  // Optional: disable batch mode if real-time feedback is needed
            preProcessing(referenceTitle, locationRefence, InDir, InDir, list[j]);
            setBatchMode(false);  // Restore or maintain state
        }
    }

    // Notify user when all files have been processed
    showMessage("Done!");
}


macro "Quantification Action Tool 2 - C00fT0b11QT9b09NTcb09T" {

    // Close any open images, reset the ROI manager, and clear results
    close("*");
    roiManager("Reset");
    run("Clear Results");

    // Set default colors and measurements (area) for subsequent processing
    run("Colors...", "foreground=black background=white selection=green");
    run("Set Measurements...", "area redirect=None decimal=2");
    
    // Define radius for deformation analysis
    r = 50;

    // Prompt user to select the directory containing reference samples
    InDirRef = getDirectory("Choose Directory of Sample Reference");
    referenceList = getFileList(InDirRef);
    L = lengthOf(referenceList);
    
    // Initialize arrays for storing volumes, volume differences, and volume ratios
    labels = newArray();
	implantVolumes = newArray();
	implantFilledVolumes = newArray();
	implantRoscaVolumes = newArray();
	
    // Calculate deformation value for the first reference sample
    referenceVolumes = quantifyDeformation(InDirRef, referenceList[0], r);
    labels[0] =referenceList[0];
    implantVolumes[0]= d2s(referenceVolumes[0], 4); 
    implantFilledVolumes[0] = d2s(referenceVolumes[1], 4); 
    implantRoscaVolumes[0] = d2s(referenceVolumes[2], 4); 
    Array.print(referenceVolumes);
    
  	//  print("vImplantReference: " + vImplantReference);
        
     // Define the title for the reference sample image
    referenceTitle = "Implantes_01032023_4_muestraReferencia_141519.tif";

    // Prompt user to select directory containing implant samples (moving images)
    InDir = getDirectory("Choose Directory of samples to Register (Moving Images)");
    listImplants = getFileList(InDir);
    L = lengthOf(listImplants);

  
    // Loop through each implant sample for deformation analysis
    for (j = 0; j < L; j++) {
        // Process only files with "tif" extension
        if (endsWith(listImplants[j], "tif")) {
            run("Clear Results");
            pos = lengthOf(labels);
            // Quantify deformation for the current implant sample and calculate volume difference and ratio
            volumes = quantifyDeformation(InDir, listImplants[j], r);
            labels[pos] = listImplants[j];
            implantVolumes[pos] = d2s(volumes[0],4);
            implantFilledVolumes[pos] = d2s(volumes[1],4);
            implantRoscaVolumes[pos] = d2s(volumes[2],4);
   	
            /*
            // Ensure minimum volume difference and ratio values are met
            if (volumeDiff[j] < 0) {
                volumeDiff[j] = 0;
            }
            if (volumeRatio[j] < 1) {
                volumeRatio[j] = 1;
            }
			*/
			

        }
    }
    
    /*
    // Create arrays for implant IDs and combine reference data with the analyzed sample data
    ref = newArray(1);
    ref[0] = referenceTitle;
    ImplantID = Array.concat(ref, listImplants);
    
    vRef = newArray(1);
    vRef[0] = vImplantReference;
    volumes = Array.concat(vRef, listVolumesImplants);

    vDiff = newArray(1);
    vDiff[0] = 0;
    volumesDiff = Array.concat(vDiff, volumeDiff);

    rRef = newArray(1);
    rRef[0] = 1;
    Ratios = Array.concat(rRef, volumeRatio);
	*/
	
    // Create a results table with columns for implant ID, volume, deformation, and ratios
	Table.create("DeformationResults");
	Table.setColumn("[Labels]", labels, "DeformationResults");
	Table.setColumn("Implant Volumes (um3)", implantVolumes, "DeformationResults");
	Table.setColumn("Implant Filled Volume (um3)", implantFilledVolumes, "DeformationResults");
	Table.setColumn("Implant Inner Rosca Volume (um3)", implantRoscaVolumes, "DeformationResults");
	Table.update;
	saveAs("DeformationResults", InDir + File.separator + "DeformacionImplantes_QuantificationResults.xls");
    
    // Save the results table to an Excel file in the specified directory
    

}



function filterSlices(name, column) {
    /**
     * Identifies image slices that contain detected particles and determines
     * their orientation based on perimeter measurements from a given column.
     *
     * @param {string} name      - The name of the image stack window.
     * @param {string} column    - The name of the column in the Results table used for orientation analysis (e.g., "Perim.").
     * @return {array} [topSlice, bottomSlice, flipZ]
     *         topSlice (int)    - Index of the top-most slice with detected particles.
     *         bottomSlice (int) - Index of the bottom-most slice with detected particles.
     *         flipZ (boolean)   - Whether the stack was flipped in Z based on perimeter comparison.
     */

    // Activate the target image window
    selectWindow(name);

    // Initialize array to hold indices of slices with particle selections
    slices = newArray();

  // Optional: pause for manual review or user input

    // Loop through all slices in the stack
    for (i = 1; i < nSlices; i++) {
        setSlice(i);
        run("Create Selection");

        // If there is a selection, store the slice index and measure
        if (selectionType() != -1) {
            slices = Array.concat(slices, i);
            run("Measure");
        }
    }

    // Remove placeholder 0th element from the array
    slices = Array.slice(slices, 1, lengthOf(slices));

    // Debug: print first and last perimeter values used for comparison
    print(parseInt(Table.get(column, 0, "Results")));
    print(parseInt(Table.get(column, lengthOf(slices) - 1, "Results")));

    // Determine orientation of stack by comparing perimeter values
    if (parseInt(Table.get(column, 0, "Results")) < parseInt(Table.get(column, lengthOf(slices) - 1, "Results"))) {
        flipZ = true;
        run("Flip Z");
        topSlice = nSlices - slices[lengthOf(slices) - 1];
        bottomSlice = nSlices - slices[0];
    } else {
        flipZ = false;
        topSlice = slices[0];
        bottomSlice = slices[lengthOf(slices) - 1];
    }

    // Clean up and return result
    run("Clear Results");
    run("Select None");

    return newArray(topSlice, bottomSlice, flipZ);
}

function preProcessing(referenceTitle, locationRefence, output, InDir, name) {
    /**
     * Preprocesses a 3D implant image to extract and align the region of interest.
     * 
     * Steps include ROI selection, thresholding, 3D centroid computation, 
     * cropping, reslicing, rotation, and saving the processed result.
     *
     * @param {string} referenceTitle     - Title of the reference window (unused in current function).
     * @param {array} locationRefence     - Array with ROI [x, y, width, height] used for cropping.
     * @param {string} output             - Directory path for saving output.
     * @param {string} InDir              - Directory of the input image (use "-" if already opened).
     * @param {string} name               - Filename of the image to be processed.
     * 
     * @return {void}
     */

    // Open the image only if it's not already loaded
    if (InDir == "-") {
        open(name);
    } else {
        if (!isOpen(InDir + name)) {
            open(InDir + name);
        }
    }

    print("preProcessing: " + name);

    // Set Region of Interest (ROI) around the implant using reference location
    setLocation(locationRefence[0] + 20 + locationRefence[2], locationRefence[1], locationRefence[2], locationRefence[3]);
    setSlice(floor(nSlices / 2));

    // Configure measurements and create binary mask of the implant
    run("Set Measurements...", "area mean standard min perimeter shape redirect=None decimal=2");
    run("Duplicate...", "title=implantMask duplicate");
    setAutoThreshold("Otsu dark stack");
    setOption("BlackBackground", false);
    run("Convert to Mask", "method=Otsu background=Dark");
    run("Analyze Particles...", "size=100-Infinity pixel show=Masks display in_situ stack");
    run("Clear Results");

    // Keep only the largest region in the mask and rename window
    run("Keep Largest Region");
    close("implantMask");
    rename("implantMask");

    // Identify relevant Z-slices based on object detection
    zSlices = filterSlices("implantMask", "Perim.");
    Array.print(zSlices);

    // Compute 3D centroid of the implant
    selectWindow("implantMask");
    run("3D Centroid");
    x = Table.get("CX(pix)", 0, "Results");
    y = Table.get("CY(unit)", 0, "Results");
    z = Table.get("CZ(pix)", 0, "Results");
    close("implantMask");

    // Crop and isolate the implant based on centroid and slice range
    selectWindow(name);
    run("Duplicate...", "title=croppedImplant duplicate");
    setLocation(locationRefence[0] + 20 + locationRefence[2], locationRefence[1], locationRefence[2], locationRefence[3]);
    setSlice(floor(z));
    makePoint(x, y, "small green hybrid");
    makeRectangle(x - 75, y - 75, 150, 150);
    run("Crop");

    // Crop in Z dimension: reslice and isolate implant volume
    run("Reslice [/]...", "output=1.000 start=Top avoid");
    makeRectangle(0, zSlices[0] - 5, 150, zSlices[1] + 5 - zSlices[0]);
    run("Crop");
    run("Reslice [/]...", "output=1.000 start=Top avoid");

    // Perform rotation corrections (XZ/YZ plane adjustments)
    run("Reslice [/]...", "output=1.000 start=Top avoid");
    setSlice(floor(nSlices / 2));
    run("Rotate...");

    run("Reslice [/]...", "output=1.000 start=Top avoid");
    run("Rotate 90 Degrees Left");

    run("Reslice [/]...", "output=1.000 start=Top avoid");
    setSlice(floor(nSlices / 2));
    run("Rotate...");

    run("Reslice [/]...", "output=1.000 start=Top avoid");
    run("Rotate 90 Degrees Right");

    // Save the rotated version (temporary or debug use)
    saveAs("TIFF", DIR + File.separator + "rotated" + FILE);

    // Save the final preprocessed image to output directory
    OutDir = output + File.separator + "preProcessedImages";
    File.makeDirectory(OutDir);
    selectWindow("croppedImplant");
    rename(name);
    saveAs("Tiff", OutDir + File.separator + name);
    close("*");
}


function quantifyDeformation(DIR, FILE, r) {
    /**
     * Quantifies the volume of an implant by thresholding and analyzing particle area across image slices.
     * 
     * The process includes converting the image to a binary mask, filling holes, calculating area per slice,
     * and finally estimating the volume based on a scaled voxel size.
     * 
     * @param {string} DIR  - Directory where the input image is located.
     * @param {string} FILE - Filename of the image to be analyzed.
     * @param {number} r    - Reference scaling factor (radius in mm, will be scaled to microns).
     * 
     * @return {number} vImplant - Estimated implant volume in cubic microns.
     */

    // Open the image file from the specified directory
    open(DIR + File.separator + FILE);
    print(FILE);

	// r = 50 / 1000; // Convert radius from microns to millimeters (scaling factor)
	//run("Set Scale...", "distance=1 known=50 unit=um");
	setVoxelSize(0.05, 0.05, 0.05, "mm");

    // Segment the implant in the middle slice and across the stack using Otsu threshold
    setSlice(floor(nSlices / 2));
    setAutoThreshold("Otsu dark");           // Middle slice threshold (for visualization/debug)
    setAutoThreshold("Otsu dark stack");     // Apply threshold to entire stack
    setOption("BlackBackground", false);
    run("Convert to Mask", "method=Otsu background=Dark");  // Create binary mask
    
    rename("implant");
	run("Analyze Regions 3D", "volume surface_area surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
	selectWindow("implant-morpho");
	vImplant = getResult("Volume", 0);
	close("implant-morpho");
	
    // Create a filled version of the implant mask for edge detection

    run("Duplicate...", "title=fillImplant duplicate");
    run("Fill Holes", "stack");
	run("Analyze Regions 3D", "volume surface_area surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
	selectWindow("fillImplant-morpho");
	vImplantFilled = getResult("Volume", 0);
	close("fillImplant-morpho");
	
	// Calculate Inner Rosca 
    imageCalculator("XOR create stack", "implant", "fillImplant");  // Highlight the edges of the implant
	rename("Rosca");
	
	selectWindow("Rosca");
	run("Analyze Regions 3D", "volume surface_area surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
	selectWindow("Rosca-morpho");
	vRosca = getResult("Volume", 0);
	close("Rosca-morpho");
  
  	volumes = newArray(vImplant,vImplantFilled,vRosca);
    
	/*
    // Accumulate area values from each slice to compute total volume
    for (i = 0; i < nResults; i++) {
        areaSlice = getResult("Area", i);
        vImplant = vImplant + areaSlice;
    }

    /*
    // Optional: Save inverted mask image for visual inspection
    run("Invert", "stack");
    saveAs("TIFF", DIR + File.separator + "Rosca" + FILE);
    
    // Convert accumulated 2D area to 3D volume using cubic voxel scaling
    vImplant = vImplant * r * r * r;
	*/
	
    // Clean up result tables and image windows
    run("Clear Results");
    close("Results");

    /*
    // Optional: Export 3D visualization as STL using 3D Viewer plugin
    run("3D Viewer");
    call("ij3d.ImageJ3DViewer.setCoordinateSystem", "false");
    call("ij3d.ImageJ3DViewer.add", FILE, "None", FILE, "0", "true", "true", "true", "2", "0");
    call("ij3d.ImageJ3DViewer.exportContent", "STL Binary", "Z:/path/to/export/untitled.stl");
    */

    // Close all open images
    close("*");

    // Return the volume for external use
    return volumes;
}



