function macroInfo(){

    // * Title  
    scripttitle =  "Coloc Live Infection Quantification";
    version =  "2.0";
    date =  "2025";

    // *  Test Images:
    imageAdquisition = "IF Confocal, 2-3 Channels";
    imageType = "4D - 8 bit (Channels, Z, Time)";
    voxelSize = "Voxel size: user-defined";
    format = "Format: tif";

    // * GUI User Requirements:
    //   - Batch and single file mode (done)
    //   - Interactive thresholding for each channel (done)
    //   - Channel selection for Lysosome and NP-GFP (done)
    //   - Save results and segmented images (done)

    // Important Parameters:
    parameter1 = "Lysosome threshold value";
    parameter2 = "Lysosome min area (px²)";
    parameter3 = "NP-GFP threshold value";
    parameter4 = "NP-GFP min area (px²)";
    parameter5 = "Time interval between frames (min)";

    // 2 Action tools:
    buttom1 = "Single File processing: For parameter fine-tuning";
    buttom2 = "Batch Mode: Process all .tif files in selected directory";

    // OUTPUT

    excel = "IF4D_ColocLiveInfectionResults.xls";

    feature1  = "Filename";
    feature2  = "t (min)";
    feature3  = "Total_lysosome_area (or volume)";
    feature4  = "Total_NP_area (or volume)";
    feature5  = "Infected_NP_area (or volume)";

    // License and credits
    // MIT License
    // Copyright (c) 2025 Tomas Muñoz tmsantoro@unav.es

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
        +"<li>"+parameter4+"</li>"
        +"<li>"+parameter5+"</li></ul>"
        +"<p><font size = 3  i>Quantification Results: </i></p>"
        +"<p><font size = 3 i>Output folder: Visualize segmented images and overlays</i></p>"
        +"<p><font size = 3  i>Results file: "+excel+"</i></p>"
        +"<ul id = list-style-3><font size = 2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li><li>"+feature5+"</li></ul>"
        +"<h0><font size = 5></h0>"
        +"");
}


macro "Coloc Coloc Live infection quantification Action Tool 1 - Cf00T2d15IT6d10m" {

    run("Close All");

    // Show macro info
    macroInfo();

    // Select a single file
    name = File.openDialog("Select .tif File");
    print("Processing " + name);

    // Create dialog for parameters
    Dialog.create("Coloc Live infection analysis - Single File");
    Dialog.addNumber("Lysosome Channel", 1);
    Dialog.addNumber("NP-GFP Channel", 2);
    Dialog.addNumber("Time interval between frames (min)", 0.5);

    Dialog.addMessage("Lysosome Parameters");
    Dialog.addNumber("Lysosome threshold value:", 20);
    Dialog.addNumber("Min area (pixel2):", 5);

    Dialog.addMessage("NP-GFP Parameters");
    Dialog.addNumber("NP-GFP threshold value:", 10);
    Dialog.addNumber("Min area (pixel2):", 5);
    
	Dialog.addCheckbox("Batchmode?", true);
    Dialog.show();

    cLyso = Dialog.getNumber();
    cNP = Dialog.getNumber();
    t_int = Dialog.getNumber();
    LysoTh = Dialog.getNumber();
    aLyso_th = Dialog.getNumber();
    NPTh = Dialog.getNumber();
    aNP_th = Dialog.getNumber();
    var batchmode = Dialog.getCheckbox();
    // Prepare output directory
    conditions = "LysoT"+LysoTh+"A"+aLyso_th+"_NPT"+NPTh+"A"+aNP_th;
    outputDir = File.getParent(name) + File.separator + conditions + File.separator;
    File.makeDirectory(outputDir);

    close("*");
    roiManager("reset");

    setOption("ExpandableArrays", true);
    filename = newArray;
    t = newArray;
    aLyso = newArray;
    aNP = newArray;
    aNPLyso = newArray;

    // Use the new function for processing
    processSingleFile(name, cLyso, cNP, t_int, LysoTh, aLyso_th, NPTh, aNP_th, outputDir, filename, t, aLyso, aNP, aNPLyso);

    showMessage("Coloc Coloc Live infection quantification finished!");
}
macro "Coloc Coloc Live infection quantification Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	
	//Description
	macroInfo();

	setOption("ExpandableArrays", true);
	
	inputDir =getDirectory("Opendirectory");
	fileList =getFileList(inputDir);
	fileList = Array.deleteValue(fileList, "desktop.ini");

	
	//Create dialog box
	Dialog.create("Coloc Live infection analysis");
	//--Channels:
	Dialog.addNumber("Lysosome Channel", 1);
	Dialog.addNumber("NP-GFP Channel", 2);
	//Dialog.addNumber("P570-mCherry Channel", 2);
	Dialog.addNumber("Time interval between frames (min)", 0.5);
				

	//--Segmentation options: Lysosomes
	Dialog.addMessage("Lysosome Parameters");
	Dialog.addNumber("Lysosome threshold value:", 5);
	Dialog.addNumber("Min area (pixel2):", 200);
	
	//--Segmentation options: NP-GFP
	Dialog.addMessage("NP-GFP Parameters");
	Dialog.addNumber("NP-GFP threshold value:", 10);
	Dialog.addNumber("Min area (pixel2):", 20);
	
	//--Segmentation options: P570-mCherry
	//Dialog.addMessage("P570-mCherry Parameters");
	//Dialog.addNumber("P570-mCherry  threshold value:", 10);
	//Dialog.addNumber("Min area (pixel2):", 20);
	
	//--Segmentation options: P570-mCherry
	//Dialog.addMessage("Bacteria interaction Parameters");
	//Dialog.addNumber("Set interaction diameter:", 0.5);
	
	Dialog.addCheckbox("Batchmode?", true);
	Dialog.show();
	
	//--Get values
	cLyso = Dialog.getNumber();
	cNP = Dialog.getNumber();
	//cP570 = Dialog.getNumber();
	t_int = Dialog.getNumber();
	LysoTh = Dialog.getNumber();
	aLyso_th = Dialog.getNumber();
	NPTh= Dialog.getNumber();
	aNP_th = Dialog.getNumber();
	//P570Th= Dialog.getNumber();
	//aP570_th = Dialog.getNumber();
	//int_d = Dialog.getNumber();
	var batchmode = Dialog.getCheckbox();

	conditions = "LysoT"+LysoTh+"A"+aLyso_th+"_NPT"+NPTh+"A"+aNP_th; //+"_P570T"+P570Th+"A"+aP570_th
	outputDir = inputDir + File.separator + conditions + File.separator;		
	File.makeDirectory(outputDir);

	
	setOption("ExpandableArrays", true);
	filename =  newArray;
	t =  newArray;
	aLyso =  newArray;
	aNP =  newArray;
	// aP570=  newArray;
	aNPLyso =  newArray; 
	// aP570Lyso=  newArray;
	// NP_int_N = newArray;
	// NP_int_total = newArray;
	// P570_int_N = newArray;
	// P570_int_total = newArray;	

	for (j = 0; j < fileList.length; j++) {
		if (endsWith(fileList[j], ".tif") || endsWith(fileList[j], ".czi")) {
			file = inputDir + fileList[j];
			// Use the new function for processing
			processSingleFile(file, cLyso, cNP, t_int, LysoTh, aLyso_th, NPTh, aNP_th, outputDir, filename, t, aLyso, aNP, aNPLyso);
		}
	}
	 		

	close("*");	
	 		
		
}


function processSingleFile(name, cLyso, cNP, t_int, LysoTh, aLyso_th, NPTh, aNP_th, outputDir, filename, t, aLyso, aNP, aNPLyso) {
    // This function processes a single 4D infection quantification file:
    // - Opens and prepares the file
    // - Splits channels and generates masks
    // - Quantifies volumes per frame
    // - Adds overlays and saves results
    // * @param {name}      - String, full path to the file.
    // * @param {cLyso}     - Integer, lysosome channel number.
    // * @param {cNP}       - Integer, NP-GFP channel number.
    // * @param {t_int}     - Float, time interval between frames.
    // * @param {LysoTh}    - Integer, lysosome threshold value.
    // * @param {aLyso_th}  - Integer, lysosome min area.
    // * @param {NPTh}      - Integer, NP-GFP threshold value.
    // * @param {aNP_th}    - Integer, NP-GFP min area.
    // * @param {outputDir} - String, output directory.
    // * @param {filename}  - Array, to store file names per frame.
    // * @param {t}         - Array, to store time points.
    // * @param {aLyso}     - Array, to store lysosome volumes.
    // * @param {aNP}       - Array, to store NP-GFP volumes.
    // * @param {aNPLyso}   - Array, to store infected NP volumes.

    open(name);
    file = File.nameWithoutExtension;
    rename(file);
    print("Analysing " + file);
    getDimensions(width, height, channels, slices, frames);
	run("Options...", "iterations=1 count=1 do=Nothing");
		
    run("Duplicate...", "title=orig duplicate");
    selectWindow(file);
    run("Split Channels");
    lyso = "C"+cLyso+"-" + file;
    NP = "C"+cNP+"-" + file;
   	   	     
    // Generate masks
    lyso = getMask(lyso, LysoTh, aLyso_th);
    NP = getMask(NP, NPTh, aNP_th);
    NP_Lyso = getInfected(lyso, NP);
	
    m = 0;
    filename = newArray();
    volLyso = newArray();
    meanILyso = newArray();
    stdILyso = newArray();
    maxILyso = newArray();
    minILyso = newArray();
    medianILyso = newArray();
    modeILyso = newArray();
    
    volNP = newArray();
    meanINP = newArray();
    stdINP = newArray();
    maxINP = newArray();
    minINP = newArray();
    medianINP = newArray();
    modeINP = newArray();
    
    volColoc = newArray();
    meanIColoc = newArray();
    stdIColoc = newArray();
    maxIColoc = newArray();
    minIColoc = newArray();
    medianIColoc = newArray();
    modeIColoc = newArray();
    
    for (i = 0; i < frames; i++) {
    	
    	print("Processing Frame " + (i+1));
        filename[m] = file;
        t[m] = t_int * i;
        lysoFeatures = getImFeatures("orig",lyso,cLyso,i+1);
        volLyso[m] = lysoFeatures[0];
	    meanILyso[m] = lysoFeatures[1];
	    stdILyso[m] = lysoFeatures[2];
	    maxILyso[m] = lysoFeatures[3];
	    minILyso[m] = lysoFeatures[4];
	    medianILyso[m] = lysoFeatures[5];
	    modeILyso[m] = lysoFeatures[6];
	    
        NPfeatures = getImFeatures("orig",NP,cNP, i+1);
        volNP[m] = NPfeatures[0];
	    meanINP[m] = NPfeatures[1];
	    stdINP[m] = NPfeatures[2];
	    maxINP[m] = NPfeatures[3];
	    minINP[m] = NPfeatures[4];
	    medianINP[m] = NPfeatures[5];
	    modeINP[m] = NPfeatures[6];
	            
        NPLysofeatures = getImFeatures("orig",NP_Lyso,cLyso, i+1);
        volColoc[m] = NPLysofeatures[0];
	    meanIColoc[m] = NPLysofeatures[1];
	    stdIColoc[m] = NPLysofeatures[2];
	    maxIColoc[m] = NPLysofeatures[3];
	    minIColoc[m] = NPLysofeatures[4];
	    medianIColoc[m] = NPLysofeatures[5];
	    modeIColoc[m] = NPLysofeatures[6];
	    
        m++;
        selectWindow("orig");
        addOverlay4D("orig", lyso, cLyso, "red", i+1);
        selectWindow("orig");
        addOverlay4D("orig", NP, cNP, "green", i+1);
        selectWindow("orig");
        addOverlay4D("orig", NP_Lyso, cLyso, "yellow", i+1);
     }
    setBatchMode("exit and display");

    saveImages("orig", outputDir, file);
    close("*");
    run("Clear Results");
    close("Results");


	if (File.exists(outputDir + "IF4D_ColocLiveInfectionResults.xls")){
	
		open(outputDir + "IF4D_ColocLiveInfectionResults.xls");
		IJ.renameResults("Results");
	}
	
	pos = nResults;
		
    // Save results
    for (i = 0; i < t.length; i++) {
        setResult("Filename",pos+ i, filename[i]);
        setResult("t(min)",pos+i, t[i]);
        setResult("Total_lysosome_vol",pos+i, volLyso[i]);
        setResult("Lysosome_Avg_Intensity",pos+i, meanILyso[i]);
        setResult("Lysosome_Std_Intensity",pos+i, stdILyso[i]);
        setResult("Lysosome_Max_Intensity",pos+i, maxILyso[i]);
        setResult("Lysosome_Min_Intensity",pos+i, minILyso[i]);
        setResult("Lysosome_Median_Intensity",pos+i, medianILyso[i]);
        setResult("Lysosome_Mode_Intensity",pos+i, modeILyso[i]);
        
        setResult("Total_NP_vol",pos+i, volNP[i]);
        setResult("NP_Avg_Intensity",pos+i, meanINP[i]);
        setResult("NP_Std_Intensity",pos+i, stdINP[i]);
        setResult("NP_Max_Intensity",pos+i, maxINP[i]);
        setResult("NP_Min_Intensity",pos+i, minINP[i]);
        setResult("NP_Median_Intensity",pos+i, medianINP[i]);
        setResult("NP_Mode_Intensity",pos+i, modeINP[i]);
        
        
        setResult("ColocLysosomeNP_vol",pos+i, volColoc[i]);
        setResult("ColocLysosomeNP_Avg_Intensity",pos+i, meanIColoc[i]);
        setResult("ColocLysosomeNP_Std_Intensity",pos+i, stdIColoc[i]);
        setResult("ColocLysosomeNP_Max_Intensity",pos+i, maxIColoc[i]);
        setResult("ColocLysosomeNP_Min_Intensity",pos+i, minIColoc[i]);
        setResult("ColocLysosomeNP_Median_Intensity",pos+i, medianIColoc[i]);
        setResult("ColocLysosomeNP_Mode_Intensity",pos+i, modeIColoc[i]);
                
    }
    saveAs("Results", outputDir + "IF4D_ColocLiveInfectionResults.xls");
    close("Results");
    close("*");
}



function getMask(img, th, minArea) {
    // This function preprocesses an image (median filter, background subtraction, thresholding)
    // and generates a binary mask for segmentation, keeping only objects above minArea.
    // * @param {img}      - String, name of the image window to process.
    // * @param {th}       - Integer, threshold value for segmentation.
    // * @param {minArea}  - Integer, minimum area (in pixels) for objects to keep.
    // * @return {mask}    - String, name of the mask image window.
    selectWindow(img);

	run("Median...", "radius=1 stack");
    run("Subtract Background...", "rolling=20 stack");
    	
	getDimensions(width, height, channels, slices, frames);
	Stack.getStatistics(area, mean, min, max, std, histogram);
	setMinAndMax(min, max);	
	run("Apply LUT","stack");
	run("Gamma...", "value=0.75 stack");
	run("Subtract Background...", "rolling=20 stack");
    
	
    setThreshold(th, 255, "raw");
    //setAutoThreshold("Otsu dark stack no-reset");
    setOption("BlackBackground", false);
    run("Convert to Mask", "method=Otsu background=Dark");

    //minArea=50;
    run("Analyze Particles...", "size="+minArea+"-Infinity pixel show=Masks stack in_situ");
    mask = "Mask_"+img;
    rename(mask);
    return mask;	
}

function getInfected(lys, bact) { 
    // This function computes the intersection (AND) between two binary masks (e.g., lysosome and NP-GFP)
    // to identify infected regions.
    // * @param {lys}   - String, name of the lysosome mask image.
    // * @param {bact}  - String, name of the NP-GFP mask image.
    // * @return {title} - String, name of the resulting infection mask image.
    title = bact + "_infection";
    imageCalculator("AND create stack", bact, lys);
    rename(title);
    return title;
}

function getArea(img, n) { 
    // This function measures the area of objects in a given slice of a mask image.
    // * @param {img} - String, name of the mask image.
    // * @param {n}   - Integer, slice number to measure.
    // * @return {a}  - Float, measured area in pixels.
    run("Set Measurements...", "area limit redirect=None decimal=3");
    selectWindow(img);
    run("Clear Results");
    setSlice(n);
    run("Create Selection");
    run("Measure");
    run("Select None");
    if (nResults>0) {
        a = getResult("Area", 0);
    }
    else {		
        a = 0;
    }
    run("Clear Results");
    return a;
}

function getVolumeFeatures(lys, n){
    // This function calculates the 3D volume of segmented objects in a given frame using Analyze Regions 3D.
    // * @param {lys} - String, name of the mask image.
    // * @param {n}   - Integer, frame number to analyze.
    // * @return {Vol} - Float, measured volume.
    selectWindow(lys);
    run("Duplicate...", "title=temp duplicate frames="+n+"-"+n+"");
    run("Analyze Regions 3D", "volume surface_area surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
    wait(10);
    IJ.renameResults("Results");
    if (nResults > 0){
    	Vol = getResult("Volume", 0);
    }else {
    	Vol = 0;
    }
    run("Clear Results");
    close("temp");
    return Vol; 
}


function getImFeatures(im,lys,channel, n){
    // This function calculates the 3D volume of segmented objects in a given frame using Analyze Regions 3D.
    // * @param {lys} - String, name of the intensity image.
    // * @param {lys} - String, name of the mask image.
    // * @param {n}   - Integer, frame number to analyze.
    // * @return {Vol} - Float, measured volume.
    
    
    selectWindow(im);
    run("Select None");
    run("Duplicate...", "title=tempInt duplicate channels="+channel+" frames="+n+"-"+n+"");
   
    selectWindow(lys);
    run("Select None");
    run("Duplicate...", "title=temp duplicate frames="+n+"-"+n+"");
    
    run("Intensity Measurements 2D/3D", "input=tempInt labels=temp mean stddev max min median mode volume");
      
   	selectWindow("tempInt-intensity-measurements");
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
    close("temp*");
    return imFeatures; 
}


function getInteractions(infbac1, infbac2, int_d, n){
    // This function quantifies spatial interactions between two infected populations by enlarging ROIs and measuring overlaps.
    // * @param {infbac1} - String, mask image 1.
    // * @param {infbac2} - String, mask image 2.
    // * @param {int_d}   - Float, enlargement diameter for interaction.
    // * @param {n}       - Integer, slice/frame number.
    // * @return {res}    - Array, [number of interactions, total objects].
    run("Set Measurements...", "min redirect=None decimal=3");
    run("Clear Results");
    roiManager("reset");	
    res = newArray(2);
    selectWindow(infbac1);
    setSlice(n);
    run("Create Selection");	
    if (selectionType()>-1) {
        roiManager("add");
        roiManager("Select", 0);
        run("Enlarge...", "enlarge="+int_d);
        roiManager("update");
        run("Create Mask");
        temp_mask = getTitle();
        run("Select None");
        run("Analyze Particles...", "size=0-Infinity pixel display clear slice");
        close(temp_mask);	
    }
    if (nResults>1) {
        run("Clear Results");
        selectWindow(infbac2);
        setSlice(n);
        roiManager("Select", 0);
        roiManager("Split");	
        roiManager("Select", 0);
        roiManager("delete");	
        roiManager("Show All");
        roiManager("Measure");
        interactions = 0;
        for (idx = 0; idx < nResults; idx++) {
            if (getResult("Max", idx)==255) {		
                interactions++;
            }
        }
        res[0] = interactions;
        res[1] = nResults;
        run("Clear Results");
        roiManager("reset");			
    }
    else if (nResults==1){
        res[0] = 0;
        res[1] = 1;
        roiManager("reset");
        run("Clear Results");	
    }
    else {
        res[0] = 0;
        res[1] = 0;	
    }
    return res;
}

function saveImages(image, outputDir, file) {
    // This function overlays two binary masks and saves the resulting image to the output directory.
    // * @param {image}     - String, image with the overlay
    // * @param {outputDir}- String, output directory path.
    // * @param {file}     - String, base filename for saving.
  	
  	selectWindow(image);
    saveAs("tif", outputDir + file+"_Analyzed");
    close("*");	
}

function addOverlay4D(rawImage, maskImage, channel, color, frame){
    // This function overlays a binary mask onto a 4D raw image stack for visualization, for a given channel and frame.
    // * @param {rawImage}  - String, name of the raw image window.
    // * @param {maskImage} - String, name of the mask image window.
    // * @param {channel}   - Integer, channel number for overlay.
    // * @param {color}     - String, color for overlay.
    // * @param {frame}     - Integer, frame number for overlay.
    
    //Batchmode
    selectWindow(rawImage);
    Stack.setFrame(frame);

	setBatchMode(true);

    selectWindow(maskImage);
    Stack.setFrame(frame);
  
    run("Duplicate...", "title=temp duplicate frames="+frame+"-"+frame+"");
    selectWindow("temp");
    getDimensions(width, height, channels, slices, frames);
    RoiManager.associateROIsWithSlices(true);	
    if (slices > 1) {
        for (s = 1; s <= slices; s++) {
            selectWindow("temp");
            setSlice(s);
            selectWindow("temp");
            run("Create Selection");
            wait(5);
            type=selectionType();
            if(type!=-1){
                selectWindow(rawImage);
                Stack.setChannel(channel);
                Stack.setFrame(frame);
                Stack.setSlice(s);
                run("Restore Selection");
                selectWindow(rawImage);
                Overlay.addSelection(color);
                Overlay.setPosition(channel, s, frame);				
            }
        }
    } else {
        print("The image is not a stack.");
    }
    close("temp");
}
