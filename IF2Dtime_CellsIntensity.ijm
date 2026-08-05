
function macroInfo() {
	/**
	 * Displays the script's metadata, version history, and usage instructions in a formatted HTML window.
	 * * @returns {void}
	 * @sideeffects Opens a dialog window titled "ImageJ Script" containing HTML text.
	 */
	
    // Title and version info
    scripttitle = "Cells 2D SumProjection Time Signal Analysis from 3D Multiphoton Images";
    version = "1.01";
    date = "2026";
    author = "Tomas Muñoz Santoro";
    contact = "tmsantoro@unav.es";
    license = "MIT License";

    // Input image info
    imageAdquisition = "IF MULTIPHOTON 1 Channel";
    imageType = "3D + TIME - 8 bit";
    voxelSize = "Voxel size: unknown";
    format = "Format: czi";

    // Parameter
    parameter1 = "Min cells size (px)";

    // Action tools
    buttom1 = "Im: Single File processing. Use Single file processing for fine tuning parameters";
    buttom2 = "Dir: Batch Mode. Please tune parameters before using Batchmode";

    // Output features
    excel = "QuantificationResults_IF2Dtime_CellsIntensity.xls";
    feature1 = "Image Label";
    feature2 = "Cell ID";
    feature3 = "Time Frame";
    feature4 = "Mean Intensity";
    feature5 = "Std Intensity";
    feature6 = "Integrated Intensity";
     
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
            +"<li>"+parameter1+"</li></ul>"
        +"<p><font size = 3  i> Quantification Results: </i></p>"
            +"<p><font size = 3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
            +"<p><font size = 3  i>Excel "+excel+"</i></p>"
            +"<ul id = list-style-3><font size = 2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li>"
            +"<li>"+feature5+"</li><li>"+feature6+"</li></ul>"
            +"<h0><font size = 5></h0>"
            +"");
}

var cCells=1, minCellSize=150;

macro "IF2Dtime_CellsIntensity Action Tool 1 - Cf00T2d15IT6d10m"{
    run("Close All");
    macroInfo();
    
    //just one file
    name=File.openDialog("Select File");
    
    print("=======================================");
    print("STARTING SINGLE FILE PROCESSING");
    print("Processing file: " + name);
    print("=======================================");
    
    Cells2dTime("-","-",name,minCellSize);
    setBatchMode(false);
    
    print("Single file processing complete.");
    showMessage("Cells quantified!");
}

macro "IF2Dtime_CellsIntensity Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
    run("Close All");
    macroInfo();
    
    InDir=getDirectory("Choose Tiles' directory");
    list=getFileList(InDir);
    L=lengthOf(list);
    
    print("=======================================");
    print("STARTING BATCH MODE PROCESSING");
    print("Found " + L + " files in directory.");
    print("=======================================");
        
    for (j=0; j<L; j++)
    {
        if(endsWith(list[j],"czi") || endsWith(list[j],"tif")){
            name=list[j];
            print("\n>>> Processing file " + (j+1) + " of " + L + ": " + name);
            Cells2dTime(InDir,InDir,list[j],minCellSize);
            setBatchMode(false);
        }
    }
    
    print("Batch processing complete.");
    showMessage("Cells quantified!");
}


function Cells2dTime(output,InDir,name,minCellSize){
/**
 * Main processing pipeline for 2D cell segmentation and time-series intensity quantification 
 * from 3D multiphoton images. Handles image loading, preprocessing, segmentation, user 
 * curation, measurement, and result export.
 * * @param {string} output - Target output directory path (often reassigned internally based on image location).
 * @param {string} InDir - Input directory path. Use "-" to denote a single file opened via dialog.
 * @param {string} name - The filename of the image being processed.
 * @param {number} minCellSize - Minimum pixel area for a detected particle to be considered a cell.
 * @returns {void}
 * @sideeffects Opens/closes images, modifies ROI manager, writes Excel files, and saves Tiff images.
 */

    
    print("--> Opening image...");
   if (InDir=="-") {
	run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	}
	else {
		run("Bio-Formats Importer", "open=["+InDir+name+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	}	
            
    roiManager("Reset");
    run("Clear Results");
    MyTitle=getTitle();
    aa = split(MyTitle,".");
    MyTitle_short = aa[0];
    
    selectWindow("Log");
    print("--> Setting up output directories...");
    output=getInfo("image.directory");
    OutDir = output+File.separator+"AnalyzedImages";
    File.makeDirectory(OutDir);
    rename("orig");
    
    setBatchMode(true);
    run("Set Measurements...", "area mean redirect=None decimal=2");
    run("Colors...", "foreground=white background=black selection=yellow");
    run("Options...", "iterations=1 count=1 do=Nothing");
    
    //--PROCESS Cells
    Stack.getDimensions(width, height, channels, slices, FRAMES);
    getVoxelSize(vx, vy, vz, unit);
    
    print("--> Applying 3D Fast Filters (Median) to the first frame...");
    run("Duplicate...", "title=firstFrame duplicate frames=1-1");
    run("3D Fast Filters","filter=Median radius_x_pix=2.0 radius_y_pix=2.0 radius_z_pix=2.0 Nb_cpus=16");
    
    selectImage("3D_Median");
    getDimensions(width, height, channels, slices, frames);
    Stack.setSlice(slices/2);
    
    selectWindow("Log");
    print("--> Enhancing contrast and applying morphological filters...");
    run("Enhance Contrast", "saturated=0.35");
    run("Apply LUT", "stack");
    run("Morphological Filters (3D)", "operation=Laplacian element=Ball x-radius=2 y-radius=2 z-radius=2");
    
    selectWindow("Log");
    print("--> Thresholding and creating binary mask...");
    run("8-bit");
    setThreshold(0, 110);
    setOption("BlackBackground", false);
    run("Convert to Mask", "stack");
    run("Median...", "radius=1 stack");
    
    selectWindow("Log");
    print("--> Analyzing particles (Initial detection)...");
    run("Fill Holes", "stack");
    minCellSize = 150;
    run("Analyze Particles...", "size=" + minCellSize + "-Infinity pixel show=Masks in_situ stack");
    setOption("BlackBackground", false);
    run("Convert to Mask", "stack");
	setBatchMode("show");
	
    selectWindow("Log");
    print("--> Computing 3D Convex Hull for detected cells...");
    particlesConvexHull("3D_Median-Laplacian");

    selectWindow("Log");
    print("--> Creating Z-Projection (Max Intensity)...");
    selectWindow("3D_Median-Laplacian");
    run("Z Project...", "projection=[Max Intensity]");
    rename("detections");
    close("first*");
    close("*3D*");
    
    selectWindow("detections");
    minCellSize = 150;
    run("Analyze Particles...", "size=" + minCellSize + "-Infinity pixel show=Masks add in_situ stack");

    selectWindow("orig");
    selectWindow("Log");
    print("--> Creating Z-Projection (Sum Slices) for intensity measurements...");
    //run("Median...", "radius=1 stack");
    run("Z Project...", "projection=[Sum Slices] all");
    run("16-bit");
    Stack.setSlice(1);
    
    selectWindow("Log");
    print("--> Registering image stack (StackReg Affine)...");
    run("StackReg", "transformation=Affine");
    
    setBatchMode("exit and display");
    
    selectWindow("Log");
    print("--> Prompting user for manual ROI editing (Delete/Add)...");
    deleteROIs("SUM_orig","detections");
    addROIs("SUM_orig","detections");
    
    setBatchMode(true);

    selectWindow("Log");
    print("--> Calculating measurements for all detected cells...");
    // Calculate total scanned volume (FOV)
    getVoxelSize(vx, vy, vz, unit);
    Stack.getDimensions(width, height, channels, slices, frames);
    FOV = 1024 * 1024 * vx * vy ; // Volume in cubic microns
    
    nCells = roiManager("count");
    print("--> Total cells to process: " + nCells);
    
    label = newArray();
    CellID = newArray();
    Frame = newArray();
    meanIntensity = newArray();
    stdIntensity = newArray();
    integratedIntensity = newArray();
    
    run("Set Measurements...", "area mean standard integrated redirect=None decimal=2");
    
    for (c = 1; c <= nCells; c++) {
        print("    -> Measuring Cell ID " + c + " of " + nCells + "...");
        run("Clear Results");
        close("Results");
        selectWindow("SUM_orig");
        roiManager("Select",c-1);
        run("Measure Stack...");
        for (i = 0; i < nResults(); i++) {label[i]=MyTitle;}
        cellsID = newArray(nResults);
        Array.fill(cellsID, c);
        frames = Array.getSequence(nResults+1);
        frames = Array.slice(frames,1);
        meanIntensity = Table.getColumn("Mean");
        stdIntensity = Table.getColumn("StdDev");
        integratedIntensity = Table.getColumn("RawIntDen");
                        
        Table.create("Metrics");
        Table.setColumn("[ImageLabel]", label);
        Table.setColumn("Cell_ID", cellsID);
        Table.setColumn("Time Frame", frames); 
        Table.setColumn("MeanIntensity", meanIntensity); 
        Table.setColumn("StdIntensity", stdIntensity); 
        Table.setColumn("IntegratedIntensity", integratedIntensity); 
        Table.update;
        IJ.renameResults("Results");
        
        //SAVE RESULTS
        run("Read and Write Excel", "stack_results no_count_column file=["+output+File.separator+"QuantificationResults_IF2dTime_CellsQuantification.xlsx] dataset_label=[IF2D_CellsIntensity]");
    }
    
    selectWindow("Log");
    print("--> Saved quantification results to Excel.");
    
    print("--> Generating overlay images for final output...");
    addOverlay2dTime("SUM_orig","detections",1,"green",0);
    selectWindow("SUM_orig");
    
    saveAs("Tiff", output+File.separator+"AnalyzedImages"+File.separator+MyTitle+"_2DtimeSumProjection.tif");
    wait(100);
    
    selectWindow("Log");
    print("--> Cleaning up memory and garbage collection...");
    //Clear unused memory
    wait(500);
    run("Collect Garbage"); 
    close("\\Others");
    print("--> Finished processing: " + MyTitle);
}


function particlesConvexHull(mask) {
	/**
	 * Processes a binary mask to compute and fill the convex hull for all isolated particles.
	 * Useful for smoothing rough cell boundaries and filling small edge irregularities.
	 * * @param {string} mask - The title of the binary mask image (requires Inverted LUT) containing particles.
	 * @returns {void}
	 * @sideeffects Modifies the input mask image and resets the ROI Manager.
	 */
    roiManager("reset");
    selectWindow(mask);
    run("Select None");
    run("Label image to ROIs", "rm=[]");
    run("Colors...", "foreground=black background=white selection=red");
    setForegroundColor(0, 0, 0);

    n = roiManager("count");
    for (i = 0; i < n; i++) {
        roiManager("select", i);
        run("Convex Hull");
        run("Fill","slice");
    }
    
    roiManager("reset");
    selectWindow(mask);
    run("Select None");
}
    

function addROIs(orig,mask){
	/**
	 * Interactively prompts the user to manually draw and add new cell ROIs to the detection mask.
	 * Loops until the user declines to add more cells.
	 * * @param {string} orig - The title of the original reference image used for drawing.
	 * @param {string} mask - The title of the binary mask image where the new ROIs will be added.
	 * @returns {void}
	 * @sideeffects Modifies the mask image, updates the ROI Manager, and pauses macro execution for user input.
	 */
    run("Select None");
    selectWindow(mask);
    wait(5);
    run("Create Selection");
    wait(5);
    selectWindow(orig);
    wait(5);
    run("Restore Selection");
        
    q = getBoolean("Do you want to add MANUALLY a new Cell?");
        
    while(q){
        print("      -> User is manually adding a cell...");
        setTool("freehand");
        waitForUser("Draw the Cell contour and press OK");
        type = selectionType();
        if (type==-1)   {
            showMessage("Edition", "You should draw a Region. Otherwise nothing will be added.");
        }else{
            selectWindow(mask);
            run("Restore Selection");
            setForegroundColor(0, 0, 0);
            run("Fill", "slice");
            run("Select None");
            
            roiManager("reset");
            selectWindow(mask);
            run("Analyze Particles...", "add composite");
            run("Select None");
                
            selectWindow(orig);
            roiManager("show all without labels");
        }
        q = getBoolean("Do you want to add another Cell?");
    }
}


function deleteROIs(orig,mask){
	/**
	 * Interactively prompts the user to manually draw regions to delete existing cell ROIs from the detection mask.
	 * Loops until the user declines to delete more regions.
	 * * @param {string} orig - The title of the original reference image used for context.
	 * @param {string} mask - The title of the binary mask image where regions will be erased.
	 * @returns {void}
	 * @sideeffects Modifies the mask image, updates the ROI Manager, and pauses macro execution for user input.
	 */
    run("Select None");
    selectWindow(mask);
    wait(5);
    run("Create Selection");
    wait(5);
    selectWindow(orig);
    wait(5);
    run("Restore Selection");
    
    q = getBoolean("Do you want to delete any detected region?");
        
    while(q){
        print("      -> User is manually deleting a cell...");
        setTool("freehand");
        waitForUser("Draw the Cell contour and press OK");
        type = selectionType();
        if (type==-1)   {
            showMessage("Edition", "You should draw a Region. Otherwise nothing will be deleted.");
        }else{
            selectWindow(mask);
            run("Restore Selection");
            setForegroundColor(255, 255, 255);
            run("Fill", "slice");
            run("Select None");
                    
            roiManager("reset");
            selectWindow(mask);
            run("Analyze Particles...", "add composite");
            run("Select None");
                
            selectWindow(orig);
            roiManager("show all without labels");
        }
        q = getBoolean("Do you want delete any detected region?");
    }
}


function addOverlay2dTime(rawImage,maskImage,channel,color,slice){
	/**
	 * Generates a visual overlay on the original raw image stack using the final segmented mask.
	 * * @param {string} rawImage - The title of the target image stack to receive the overlay.
	 * @param {string} maskImage - The title of the binary mask containing the final cell shapes.
	 * @param {number} channel - The target channel index for the overlay.
	 * @param {string} color - The color string (e.g., "green", "red") for the overlay outlines.
	 * @param {number} slice - The target Z-slice index for the overlay.
	 * @returns {void}
	 * @sideeffects Modifies the `rawImage` display by adding an Overlay.
	 */
    selectWindow(rawImage);
    
    getDimensions(width, height, channels, slices, frames);
    Array.print(newArray(width, height, channels, slices, frames));
    RoiManager.associateROIsWithSlices(false);  

    if (frames > 1) {
        for (f = 1; f <= frames; f++) {
            selectWindow(maskImage);
            run("Select None");
            run("Create Selection");
            wait(5);
            type=selectionType();
            if(type!=-1){
                selectWindow(rawImage);
                Stack.setFrame(f);
                run("Restore Selection");
                selectWindow(rawImage);
                Overlay.addSelection(color);
                Overlay.setPosition(channel, slice, f);             
            }
        }
    }else{
        print("-> Warning: The image is not a stack. Cannot process frames.");
    }
}


function devideArrayByScalar(array,scalar){
/**
 * Divides every element in a given array by a specified scalar value.
 * Note: Function name contains a typo ("devide") kept for backward compatibility.
 * * @param {Array} array - The input numerical array.
 * @param {number} scalar - The float/integer value to divide the array elements by.
 * @returns {Array} A new array containing the divided values.
 */
    new=newArray();
    for (i = 0; i < lengthOf(array); i++) {
        new[i]=array[i]/scalar;
    }
    return new;
} 
    

function multiplyArrayByScalar(array,scalar){
/**
 * Multiplies every element in a given array by a specified scalar value.
 * * @param {Array} array - The input numerical array.
 * @param {number} scalar - The float/integer value to multiply the array elements by.
 * @returns {Array} A new array containing the multiplied values.
 */
		
    new=newArray();
    for (i = 0; i < lengthOf(array); i++) {
        new[i]=array[i]*scalar;
    }
    return new;
}