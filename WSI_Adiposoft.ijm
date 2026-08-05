/* Adiposoft v1.18 - 9th July 2026
 *
 * Automated analysis of white adipose tissue cellularity in histological sections.
 * Developed by Miguel Galarraga (mgalarraga@unav.es)
 * Modified by Mikel Ariz (mikelariz@unav.es)
 * Modified by Tomás Munoz (tmsantoro@unav.es)
 * Imaging Unit, CIMA, University of Navarra, Pamplona, Spain
 *
 * License: GNU GPL v3 or later — http://www.gnu.org/licenses/
 *
 * Please cite:
 *   Boqué N, et al. J Physiol Biochem. 2009 Dec;65(4):387-95. PMID: 20358352.
 */
 
 

// =============================================================================
// FUNCTION: macroInfo
// Displays an HTML information panel describing the macro, its parameters,
// and its expected inputs and outputs.
// =============================================================================

function macroInfo() {

    scripttitle = "Adiposoft: Automated White Adipose Tissue Cellularity Analysis";
    version     = "1.18";
    date        = "2026";

    imageAdquisition = "Brightfield histological section images (H&amp;E stained white adipose tissue).";
    imageType        = "RGB";
    voxelSize        = "Default voxel size: 0.502 um/px (configurable at runtime).";
    format           = "Format: .tif or .jpg";

    parameter1 = "r = Microns per pixel ratio. Default: 0.502 um/px (calibrate to your objective).";
    parameter2 = "thTissue = Tissue threshold [0-255]. Pixels with luminance &lt;= this value are considered tissue; brighter pixels (glass background) are excluded. Default: 230.";
    parameter3 = "d = Minimum adipocyte diameter to detect (um). Default: 20 um.";
    parameter4 = "D = Maximum adipocyte diameter to detect (um). Default: 300 um.";
    parameter5 = "thFac = Auto-threshold scaling factor [0-1]. Applied to the Huang threshold for adipocyte detection. Default: 0.98.";
    parameter6 = "Auto mode = Checked: fully automated analysis. Unchecked: manual ROI edition enabled after detection.";
    parameter7 = "Exclude on edges = Checked: adipocytes touching the image border are excluded from results.";

    buttom1 = "Adiposoft (A): Main analysis button. Opens a dialog to choose Single Image, Directory, or Batch (nested directories) mode.";
    buttom2 = "Info (i): Shows this information panel.";

    excel    = "&lt;ImageName&gt;.xls / .csv (per image) | &lt;FolderName&gt;.xls / .csv (merged, directory mode)";
    feature1 = "Label: image filename";
    feature2 = "Area: adipocyte area (um2 or px2 depending on output units)";
    feature3 = "D-eq: equivalent circular diameter — diameter of a circle with the same area (um or px)";

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
    + "<p>Original authors: Miguel Galarraga &amp; Mikel Ariz (CIMA, University of Navarra)</p>"
    + "<p>Adapted by Tomas Munoz Santoro</p>"
    + "<p>Version: " + version + " (" + date + ")</p>"
    + "<p>Contact: tmsantoro@unav.es</p>"
    + "<p>Available under the <a href='https://opensource.org/licenses/GPL-3.0/'>GNU GPL v3 License</a></p>"
    + "<p><i>Reference:</i> Boqué N et al. J Physiol Biochem. 2009;65(4):387-95. PMID: 20358352</p>"
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
    + "<p>Analyzed Images folder: annotated JPEG images with detected adipocyte ROIs overlaid</p>"
    + "<p>Results file: " + excel + "</p>"
    + "<ul>"
    + "<li>" + feature1 + "</li>"
    + "<li>" + feature2 + "</li>"
    + "<li>" + feature3 + "</li>"
    + "</ul>"
    + "</div>"
    + "</div>"
    + "</body>"
    + "</html>");
}



// =============================================================================
// GLOBAL PARAMETERS
// =============================================================================

var r       = 0.502;       // microns per pixel
var d       = 20;          // minimum adipocyte diameter (microns)
var D       = 300;         // maximum adipocyte diameter (microns)
var thFac    = 0.98;        // auto-threshold scaling factor
var thTissue = 245;         // luminance threshold to separate tissue from glass background [0-255]
var mic     = "Microns";   // output units: "Microns" or "Pixel"
var type    = "One Image"; // processing scope
var auto    = true;        // true = auto mode (manual edition disabled)
var dir     = "";
var filename = "";
var mode    = "End";
var exedges = true;       // true = exclude particles touching image edges


// =============================================================================
// MAIN ACTION BUTTON
// =============================================================================

macro "Adiposoft Action Tool - Cf00T4d15A" {

    macroInfo();
    run("Close All");
    run("Colors...", "foreground=black background=white selection=green");
    showStatus("Choose parameters");

    // --- Dialog 1: mode selection ---
    typesArray = newArray("One Image", "A Directory", "A list of nested Directories - Batch Mode");
    mpArray    = newArray("Microns", "Pixel");
    Dialog.create("-Adiposoft_1.17-");
    Dialog.addMessage("Choose parameters");
    Dialog.addCheckbox("Auto mode (Manual edition off)", auto);
    Dialog.addCheckbox("Exclude on edges", exedges);
    Dialog.addChoice("Output units", mpArray, mic);
    Dialog.addChoice("How many images do you want to analyze?", typesArray, type);
    Dialog.addHelp("http://fiji.sc/Adiposoft");
    Dialog.show();

    auto    = Dialog.getCheckbox();
    exedges = Dialog.getCheckbox();
    mic     = Dialog.getChoice();
    type    = Dialog.getChoice();

    // --- Dialog 2: calibration ---
    if (mic == "Pixel") {
        d = 60;
        D = 250;
        Dialog.create("-Calibration-");
        Dialog.addNumber("Minimum diameter:", d);
        Dialog.addNumber("Maximum diameter:", D);
        Dialog.addNumber("AutoThreshold factor:", thFac);
        Dialog.addNumber("Tissue threshold:", thTissue);
        Dialog.show();
        r        = 1;
        d        = Dialog.getNumber();
        D        = Dialog.getNumber();
        thFac    = Dialog.getNumber();
        thTissue = Dialog.getNumber();
    } else {
        Dialog.create("-Calibration-");
        Dialog.addNumber("Microns per pixel:", r);
        Dialog.addNumber("Minimum diameter:", d);
        Dialog.addNumber("Maximum diameter:", D);
        Dialog.addNumber("AutoThreshold factor:", thFac);
        Dialog.addNumber("Tissue threshold:", thTissue);
        Dialog.show();
        r        = Dialog.getNumber();
        d        = Dialog.getNumber();
        D        = Dialog.getNumber();
        thFac    = Dialog.getNumber();
        thTissue = Dialog.getNumber();
    }

    // --- Dispatch ---
    if (type == "One Image")                                    runSingleImage();
    if (type == "A Directory")                                  runDirectory();
    if (type == "A list of nested Directories - Batch Mode")    runBatch();
}


// --- Single image mode ---
function runSingleImage() {
    if (!isOpen(File.name)) {
        filename = File.openDialog("Choose an Image for the analysis");
        open(filename);
    }
    wait(200);
    run("ROI Manager...");
    OutDir = getDirectory("Choose output Directory");
    name   = getInfo("image.filename");
    dir    = getInfo("image.directory");
    run("Select All");
    run("Put Behind [tab]");
    setBatchMode(true);
    roiManager("Add");
    eval("js", "RoiManager.getInstance().hide()");
    Adiposoft(OutDir, dir, name, auto, r, d, D, thFac, type);
    setBatchMode(false);
}

// --- Single directory mode ---
function runDirectory() {
    if (!auto) {
        showMessage("Adiposoft", "Manual edition is not available in folder mode. Auto is on");
        auto = 1;
    }
    InDir  = getDirectory("Choose input Directory");
    OutDir = getDirectory("Choose output Directory");
    AdiposoftDir(OutDir, InDir, auto, r, d, D, thFac, type);
}

// --- Nested directories batch mode ---
function runBatch() {
    if (!auto) {
        showMessage("Adiposoft", "Manual edition is not available in folder mode. Auto is on");
        auto = 1;
    }
    InDir  = getDirectory("Choose a Directory");
    OutDir = getDirectory("Choose output Directory");
    list   = getFileList(InDir);
    L      = lengthOf(list);
    for (i = 0; i < L; i++) {
        if (File.isDirectory(InDir + list[i])) {
            dir = InDir + list[i];
            AdiposoftDir(OutDir, dir, auto, r, d, D, thFac, type);
        }
    }
    eval("js", "IJ.getInstance().show()");
    if (auto == 1) {
        showMessage("Succesfully processed. Results stored in '" + OutDir + "'");
        run("Adiposoft");
    }
}


// =============================================================================
// FUNCTION: AdiposoftDir
// Process all images in a folder, then merge individual results into one file.
// =============================================================================

function AdiposoftDir(OutDir, InDir, auto, r, d, D, thFac, type) {

    list = getFileList(InDir);
    L    = lengthOf(list);

    // Derive subfolder name to mirror inside OutDir
    strA   = split(InDir, File.separator);
    name1  = strA[lengthOf(strA) - 1];
    AuxDir = OutDir + name1 + File.separator;
    File.makeDirectory(AuxDir);

    // --- Process each image ---
    for (i = 0; i < L; i++) {
        if (endsWith(list[i], ".tif") || endsWith(list[i], ".jpg")) {
            open(InDir + list[i]);
            wait(200);
            run("ROI Manager...");
            run("Select All");
            run("Put Behind [tab]");
            setBatchMode(true);
            run("Add to Manager");
            eval("js", "RoiManager.getInstance().hide()");
            Adiposoft(AuxDir, InDir, list[i], auto, r, d, D, thFac, type);
            roiManager("reset");
            run("Clear Results");
            close();
            setBatchMode(false);
        }
    }

    // --- Merge all per-image .xls files into a single "Total" table ---
    list  = getFileList(AuxDir);
    L     = lengthOf(list);
    first = 1;
    setBatchMode(false);

    for (i = 0; i < L; i++) {
        if (endsWith(list[i], ".xls")) {
            open(AuxDir + list[i]);
            IJ.renameResults("Results");
            selectWindow("Results");

            if (first == 1) {
                IJ.renameResults("Total");
                first = 0;
            } else {
                // Copy current file's results
                nr    = nResults;
                Aarea = newArray(nr);
                Adeq  = newArray(nr);
                for (j = 0; j < nr; j++) {
                    Aarea[j] = getResult("Area",  j);
                    Adeq[j]  = getResult("D-eq",  j);
                }
                selectWindow("Results");
                run("Close");
                wait(100);

                // Append to Total
                selectWindow("Total");
                IJ.renameResults("Results");
                nt = nResults;
                for (j = 0; j < nr; j++) {
                    setResult("Label", nt + j, list[i]);
                    setResult("Area",  nt + j, Aarea[j]);
                    setResult("D-eq",  nt + j, Adeq[j]);
                }
                selectWindow("Results");
                IJ.renameResults("Total");
            }
        }
    }

    // --- Save merged results ---
    selectWindow("Total");
    IJ.renameResults("Results");
    saveAs("Results", OutDir + name1 + ".csv");
    saveAs("Results", OutDir + name1 + ".xls");
    setBatchMode(true);

    // --- Prompt to view results (single-directory mode only) ---
    if (type == "A Directory" && auto == 1) {
        q = getBoolean("Succesfully processed. Results stored in '" + OutDir + "'. Do you want to view the Results file?");
        if (q) {
            open(OutDir + name1 + ".xls");
            waitForUser("Press ok when finished");
            if (isOpen(name1 + ".xls")) run("Close");
        }
        run("Adiposoft");
    }
}


// =============================================================================
// FUNCTION: Adiposoft
// Core pipeline: segment and measure adipocytes in a single image.
// =============================================================================

function Adiposoft(output, dir, filename, auto, r, d, D, thFac, type) {

    run("Clear Results");
    roiManager("reset");
    eval("js", "IJ.getInstance().setAlwaysOnTop(true)");

    if (!isOpen(dir + filename)) open(dir + filename);
    MyTitle = getTitle();
    showStatus(MyTitle);

    // --- Step 1: Preprocessing ---
    showProgress(0.2);
    run("RGB to Luminance");
    rename("luminance");
    run("Subtract Background...", "rolling=20 light");
    run("Enhance Contrast", "saturated=1 normalize");

    // --- Step 1.2: Tissue segmentation ---
    // Separate tissue from glass background. Pixels with luminance <= thTissue
    // are considered tissue. The resulting mask is applied after watershed (Step 4)
    // to exclude any false adipocyte detections that fall in the background.
    selectWindow("luminance");
    run("Duplicate...", "title=tissueMask");
    selectWindow("tissueMask");
    thTissue = 245;
    setThreshold(0, thTissue);
    setOption("BlackBackground", false);
    run("Convert to Mask");
    run("Fill Holes");
    run("Analyze Particles...", "size=10000-Infinity pixel circularity=0-1 show=Masks in_situ");
    selectWindow("luminance");

    // --- Step 2: Auto-thresholding ---
    selectWindow("luminance");
    wait(100);
    setAutoThreshold("Huang dark");
    wait(100);
    getThreshold(lower, upper);
    run("Gaussian Blur...", "sigma=1");
    showProgress(0.3);
    thFac = 0.98;
    R = parseInt(lower) * (1+(1-thFac));
    setThreshold(R, 255);
    wait(100);
    setOption("BlackBackground", false);
    run("Convert to Mask");

    // --- Step 3: Morphological cleanup ---
    run("Median...", "radius=1");
    showProgress(0.4);
    run("Options...", "iterations=2 count=1 pad edm=Overwrite do=Nothing");
    run("Open");
    showProgress(0.5);

    // Hole filling via double particle-mask inversion
    run("Analyze Particles...", "size=500-Infinity pixel circularity=0-1 show=Masks in_situ");
    selectWindow("luminance");
 
 // Apply tissue mask: remove any detections that fall in glass background
    imageCalculator("AND","luminance", "tissueMask");
    close("tissueMask");
    run("Analyze Particles...", "size=500-Infinity pixel circularity=0-1 show=Masks in_situ");
 
    // --- Step 4: Watershed segmentation ---
    showProgress(0.6);
    MyTitle2 = getTitle();
    run("Duplicate...", "title=ws");
    run("Distance Map");
    run("Find Maxima...", "prominence=3 light output=[Segmented Particles]");
    showProgress(0.7);
    selectWindow("ws");
    close();
    imageCalculator("AND", MyTitle2, "ws Segmented");
    selectWindow("ws Segmented");
    close();

    // --- Step 5: Particle analysis ---
    showProgress(0.8);
    run("Set Measurements...", "area display redirect=None decimal=2");
    selectWindow("luminance");
    run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=" + r + " pixel_height=" + r + " voxel_depth=" + r + " frame=[0 sec] origin=0,0");
    m = PI * pow(d / 2, 2);
    M = PI * pow(D / 2, 2);

    if (exedges) {
        run("Analyze Particles...", "size=" + m + "-" + M + " circularity=0.45-1.00 display exclude clear add");
    } else {
        run("Analyze Particles...", "size=" + m + "-" + M + " circularity=0.45-1.00 display clear add");
    }
    showProgress(0.95);
    selectWindow("luminance");
    close();

    // --- Step 6: Handle empty result ---
    if (nResults == 0) {
        showMessage("Warning!", "No adypocites detected! Please, check parameters and input image.\nImage will not be analyzed");
        close;
        if (type == "One Image") run("Adiposoft");
        return;
    }

    // --- Step 7: Add equivalent-diameter column and save results ---
    selectWindow("Results");
    for (i = 0; i < nResults; i++) {
        a = getResult("Area", i);
        d = sqrt(4 * a / 3.1416);
        setResult("D-eq",   i, d);
        setResult("Label",  i, MyTitle);
    }
    saveAs("Results", output + MyTitle + ".csv");
    saveAs("Results", output + MyTitle + ".xls");
    IJ.renameResults("Results");

    // --- Step 8: Save ROIs and annotated image ---
    roiManager("Select All");
    roiManager("Save", output + "infoRoi.zip");

    selectWindow(MyTitle);
    roiManager("Show All with labels");
    roiManager("Show All");
    run("Duplicate...", "d");
    if (auto) run("From ROI Manager");
    run("Flatten");
    wait(200);
    saveAs("Jpeg", output + "Analyzed" + MyTitle);
    wait(200);
    close();

    setBatchMode("show");
    eval("js", "IJ.getInstance().setAlwaysOnTop(false)");
    selectWindow(MyTitle);
    close();

    // --- Step 9: Post-analysis flow ---
    if (auto == 1) {
        if (type == "One Image") {
            eval("js", "RoiManager.getInstance().show()");
            setBatchMode(false);
            wait(100);
            if (isOpen("Results")) {
                selectWindow("Results");
                run("Close");
            }
            dir     = getInfo("image.directory");
            MyTitle = filename;
            open(output + MyTitle + ".xls");
            IJ.renameResults("Results");
            showMessage("Adiposoft 1.17", "Succesfully processed. Results stored in '" + OutDir + "'");
            close;
            selectWindow("Results");
            run("Close");
            run("Collect Garbage");
            run("Adiposoft");
        }
    } else {
        selectWindow("Results");
        run("Close");
        setBatchMode(false);
        roiManager("Show All with labels");
        roiManager("Show All");
        getLocationAndSize(x, y, width, height);
        setLocation(x + 1, y);
        setBatchMode(true);
        showStatus("Edition Mode");
        setTool("freehand");
        Edition();
        while (mode != "End") Edition();
        open(output + MyTitle + ".xls");
        IJ.renameResults("Results");
        showMessage("Adiposoft 1.17", "Succesfully processed. Results stored in '" + OutDir + "'");
        close;
        selectWindow("Results");
        run("Close");
        run("Collect Garbage");
        run("Adiposoft");
    }
}


// =============================================================================
// MANUAL EDITION FUNCTIONS
// =============================================================================

// Dispatch dialog — called in a loop until the user picks "End"
function Edition() {
    typesArray = newArray("End", "Delete", "Add", "Merge", "Separate", "Undo");
    Dialog.create("-Adiposoft_1.17- Manual Edition");
    Dialog.addMessage("Choose Mode for manual edition");
    Dialog.addChoice("Edition mode", typesArray, typesArray[0]);
    Dialog.addHelp("http://fiji.sc/Adiposoft/manual");
    Dialog.show();
    mode = Dialog.getChoice();
    if (mode == "Delete")   delete();
    if (mode == "Add")      add();
    if (mode == "Merge")    merge();
    if (mode == "Separate") separate();
    if (mode == "Undo")     undo();
    if (mode == "End")      end();
}

// Shared helper: re-measure all ROIs, then save results and annotated image.
// Used by delete(), add(), and undo() after modifying the ROI set.
function remeasureAndSave(MyTitle) {
    run("Set Measurements...", "area display redirect=None decimal=2");
    run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=" + r + " pixel_height=" + r + " voxel_depth=" + r + " frame=[0 sec] origin=0,0");
    roiManager("Select All");
    roiManager("Measure");
    selectWindow("Results");
    for (i = 0; i < nResults; i++) {
        a   = getResult("Area", i);
        deq = sqrt(4 * a / 3.1416);
        setResult("D-eq",  i, deq);
        setResult("Label", i, MyTitle);
    }
    saveAs("Results", output + MyTitle + ".csv");
    saveAs("Results", output + MyTitle + ".xls");
    run("Close");
    roiManager("Show All with labels");
    roiManager("Show All");
    run("Flatten");
    wait(200);
    saveAs("Jpeg", output + "Analyzed" + MyTitle);
    close();
}

// Shared helper: save results already in the Results window (no re-measure),
// then save annotated image. Used by merge() and separate() after re-analysis.
function saveResultsAndImage(MyTitle) {
    selectWindow("Results");
    for (i = 0; i < nResults; i++) {
        a   = getResult("Area", i);
        deq = sqrt(4 * a / 3.1416);
        setResult("D-eq",  i, deq);
        setResult("Label", i, MyTitle);
    }
    saveAs("Results", output + MyTitle + ".csv");
    saveAs("Results", output + MyTitle + ".xls");
    run("Close");
    roiManager("Show All with labels");
    roiManager("Show All");
    run("Flatten");
    wait(200);
    saveAs("Jpeg", output + "Analyzed" + MyTitle);
    close();
}


// --- Delete: remove a user-selected cell from the ROI set ---
function delete() {
    dir = getInfo("image.directory");
    roiManager("Select All");
    roiManager("Save", dir + "infoRoi.zip");
    run("Select None");
    setTool("oval");
    waitForUser("Please select a cell to delete and press ok when ready");
    getDimensions(width, height, channels, slices, frames);
    getSelectionBounds(x, y, w, h);
    if (w == width) {
        showMessage("Edition", "You should mark a cell to delete. Nothing will be deleted.");
        return;
    }
    roiManager("Delete");
    MyTitle = filename;
    remeasureAndSave(MyTitle);
}


// --- Add: let the user draw a new cell and add it to the ROI set ---
function add() {
    dir = getInfo("image.directory");
    roiManager("Select All");
    roiManager("Save", dir + "infoRoi.zip");
    run("Select None");
    setTool("freehand");
    waitForUser("Please draw a cell to add and press ok when ready");
    getDimensions(width, height, channels, slices, frames);
    getSelectionBounds(x, y, w, h);
    if (w == width) {
        showMessage("Edition", "You should draw a region to add. Nothing will be added.");
        exit();
    }
    run("Add to Manager");
    MyTitle = filename;
    remeasureAndSave(MyTitle);
}


// --- Merge: combine all ROIs that overlap a user-drawn area into one ---
function merge() {
    dir     = getInfo("image.directory");
    MyTitle = filename;
    roiManager("Select All");
    roiManager("Save", dir + "infoRoi.zip");
    setTool("freehand");
    waitForUser("Please draw an empty area to merge cells and press ok when ready");
    getDimensions(width, height, channels, slices, frames);
    getSelectionBounds(x, y, w, h);
    if (w == width) {
        showMessage("Edition", "You should draw a region to merge two cells. Nothing will be merged.");
        exit();
    }
    run("Add to Manager");

    // Rebuild the binary mask from all ROIs (including the drawn area)
    run("Remove Overlay");
    run("RGB to Luminance");
    run("Select All");
    run("Clear", "slice");
    rename("luminance");
    n = roiManager("count");
    roiManager("Select All");
    if (n > 1) roiManager("Combine");
    run("Create Mask");
    selectWindow("luminance"); close();
    selectWindow("Mask");      rename("luminance");
    roiManager("reset");

    // Re-analyze the merged mask
    run("Select All");
    run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=" + r + " pixel_height=" + r + " voxel_depth=" + r + " frame=[0 sec] origin=0,0");
    run("Analyze Particles...", "size=0-Inf circularity=0.0-1.00 display clear add");
    selectWindow("luminance"); close();

    saveResultsAndImage(MyTitle);
}


// --- Separate: split a cell by drawing a line across it ---
function separate() {
    dir = getInfo("image.directory");
    roiManager("Select All");
    roiManager("Save", dir + "infoRoi.zip");
    setTool("freeline");
    waitForUser("Please draw a line to break a cell and press ok when ready");
    getDimensions(width, height, channels, slices, frames);
    getSelectionBounds(x, y, w, h);
    if (w == width) {
        showMessage("Edition", "You should draw a line to break a cell. Nothing will be done.");
        exit();
    }
    run("Add to Manager");

    // Rebuild mask from all ROIs
    run("Remove Overlay");
    run("RGB to Luminance");
    run("Select All");
    run("Clear", "slice");
    rename("luminance");
    n = roiManager("count");
    roiManager("Select All");
    if (n > 1) roiManager("Combine");
    run("Create Mask");
    selectWindow("luminance"); close();
    selectWindow("Mask");      rename("luminance");

    // Burn the separating line into the mask to split the cell
    roiManager("select", n - 1);
    run("Line Width...", "line=2");
    run("Clear", "slice");
    roiManager("reset");

    // Re-analyze the split mask
    run("Select All");
    run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=" + r + " pixel_height=" + r + " voxel_depth=" + r + " frame=[0 sec] origin=0,0");
    run("Analyze Particles...", "size=0-Inf circularity=0.0-1.00 display clear add");
    MyTitle = filename;
    selectWindow("luminance"); close();

    saveResultsAndImage(MyTitle);
}


// --- Undo: restore the last saved ROI snapshot ---
function undo() {
    dir = getInfo("image.directory");
    roiManager("reset");
    roiManager("Open", dir + "infoRoi.zip");
    roiManager("Show All with labels");
    roiManager("Show All");
    MyTitle = filename;
    remeasureAndSave(MyTitle);
}


// --- End: exit the edition loop (no action needed) ---
function end() {}


// =============================================================================
// INFO BUTTON
// =============================================================================

//macro "Adiposoft Info Action Tool - C059T4d15i" {
//    macroInfo();
//}
