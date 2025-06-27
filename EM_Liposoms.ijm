function macroInfo(){
	
// * Target User: General
// *  

	scripttitle= "Semiautomatic Segmentation of Liposoms using SAMJ";
	version= "1.01";
	date= "Sep 2024";
	
	
// *  Tests Images:

	imageAdquisition="2D Single Channel";
	imageType="Electron Microscopy";  
	voxelSize="Voxel size: unknown um xy";
	format="Format: Uncompressed .czi";   
 
 //*  GUI User Requierments:
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button 
 
 	parameter1="None ";

 //  2 Action tools:
	buttom1="Im: Single File processing";
    buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs

	excelName="Quantification_SAMJannotator.xls";
	feature1="QuantificationResultsLiposoms.xls";
	feature2="# Object";
	feature3="Object Mean Size  [microns^2]";
	feature4="Object std Size  [microns^3]";
	
	/*  - size distribution and average size considering external radius 
		- quantification of % of multi lamellarity (% of liposomes formed by more than one vesicle) */
	
	
/*  	  
 *  version: 1.01 
 *  Author: Tomás Muñoz 
 *  Date : Sep 2024
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
	    +"<li>"+parameter1+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excelName+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}

var rxy = 0.1, fit=true;  // Initialize a variable,  scaling or image resolution settings

setOption("WaitForCompletion", true);  // Ensure macro waits for each process to finish before continuing
setOption("ExpandableArrays", true);  // Enable dynamic array expansion for operations


// Tool 1: NETs Action Tool
macro "EM-lIPOSOMS Action Tool 1 - Cf00T2d15IT6d10m" {
    
    // Close all open images and reset the environment
    close("*");
    run("Fresh Start");
    
    // Display information about the current macro process
    macroInfo();
    
    // Annotate the image or data using the custom function SAMJ
    SAMJ("-", "-");
    
    //processSingleLiposomAnnotation("-");
    

}

// Tool 2: NETs Action Tool
macro "EM-lIPOSOMS Action Tool 2 - C00fT0b11DT9b09iTcb09r" {
    
    // Close all open images and reset the environment
    close("*");
    run("Fresh Start");
    
    // Display information about the current macro process
    macroInfo();
    
    // Annotate the image or data using the custom function SAMJ
    SAMJ("-", 0);
    
    // process all annotations
    //processAnnotations(0);
    
    
    
}

function SAMJ(output, InDir) {
    
    /**
     * Summary:
     * The `SAMJ` function processes a set of 2D image stacks for cell counting and quantification.
     * It can operate in two modes: processing a single image or multiple images from a directory.
     * The function handles preprocessing (such as removing outliers, subtracting background, and setting image scale)
     * and uses a specialized tool (EfficientVitSAM10) for annotating liposomes within the images.
     *
     * @param output        The output directory path where results will be saved.
     * @param InDir         The input directory path. If "-", the user will manually select a file.
     * @param rxy           The resolution in nanometers (XY-plane resolution).
     */

    // Reset ROI Manager and close all open images to start fresh
    roiManager("reset");
    run("Close All");
    run("Fresh Start");
    RoiManager.useNamesAsLabels(false);

    // Import a single image if no directory is specified
    if (InDir == "-") {
        
        // Open image file and set spatial resolution
        name = File.openDialog("Select File");
        run("Bio-Formats Importer", "open=[" + name + "] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
        
		// Create a dialog to gather user parameters for analysis
		Dialog.create("Parameters for the analysis");
		Dialog.addMessage(" PRE-PROCESSING PARAMETERS");
		Dialog.addCheckbox("FitElipse", true);
		Dialog.addNumber("Resolution (nm/px)", rxy);
		Dialog.show();
        
		fit= Dialog.getCheckbox();
		rxy=Dialog.getNumber();
		     		
        // Set image scale and retrieve image metadata
        run("Set Scale...", "distance=1 known=" + rxy + " unit=nm");
        
        MyTitle = getTitle();
        output = getInfo("image.directory");
        OutDir = output + File.separator + "AnalyzedImages";
        File.makeDirectory(OutDir);  // Create output directory
        aa = split(MyTitle, ".");
        MyTitle_short = aa[0];  // Extract short image title
        showStatus("Analyzing " + MyTitle);
        
        // Set measurement options and preprocess the image
        run("Set Measurements...", "area centroid fit shape redirect=None decimal=2");
        run("8-bit");
        run("Remove Outliers...", "radius=5 threshold=5 which=Bright");
        run("Remove Outliers...", "radius=5 threshold=5 which=Dark");
        run("Subtract Background...", "rolling=200 light");
      

        // Annotate liposomes
    	if(!File.exists(OutDir+File.separator+MyTitle_short+"_SingleLiposoms.zip")){  
    		// Initialize SAMJ Annotator for image annotation
	        roiManager("reset");
	        run("SAMJ Annotator");
	        waitForUser("Install and Load EfficientVitSAM10");
	        waitForUser("Select Image to click GO");
	    	annotateLiposoms(MyTitle, output,fit,rxy);
    	}
    	
        // Process annotations after applying them
		processSingleLiposomAnnotation(fit,rxy);
		
		//roisToEdges();

 	}else{
        
        // Process multiple images from a specified directory
        InDir = getDirectory("Choose a Directory");
        list = getFileList(InDir);
        L = lengthOf(list);
        
		// Create a dialog to gather user parameters for analysis
	    Dialog.create("Parameters for the analysis");
	    Dialog.addMessage(" PRE-PROCESSING PARAMETERS");
	    Dialog.addCheckbox("FitElipse", true);
	    Dialog.addNumber("Resolution (nm/px)", rxy);
	    Dialog.show();

		fit= Dialog.getCheckbox();
	    rxy=Dialog.getNumber();
		        
        setBatchMode(false);

        // Loop through image files in the directory
        for (j = 0; j < L; j++) {
            
            if (endsWith(list[j], "czi") || endsWith(list[j], "tif") || endsWith(list[j], "jpg")) {
                
                name = list[j];

                // Import image and set scale
                run("Bio-Formats Importer", "open=[" + InDir + name + "] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
        
                // Retrieve image metadata and set output directory
                MyTitle = getTitle();
                output = getInfo("image.directory");
                OutDir = output + File.separator + "AnalyzedImages";
                File.makeDirectory(OutDir);
                aa = split(MyTitle, ".");
                MyTitle_short = aa[0];
                showStatus("Analyzing " + MyTitle);
				
			  	run("Set Scale...", "distance=1 known=" + rxy + " unit=nm");
				
                // Preprocess the image
                run("Set Measurements...", "area centroid fit shape redirect=None decimal=2");
                run("8-bit");
                run("Remove Outliers...", "radius=5 threshold=5 which=Bright");
                run("Remove Outliers...", "radius=5 threshold=5 which=Dark");
                run("Subtract Background...", "rolling=200 light");


		 		// Annotate liposomes
		    	if(!File.exists(OutDir+File.separator+MyTitle_short+"_SingleLiposoms.zip")){  
	                // Initialize SAMJ Annotator for the first image
	                if (j == 0) {
	                    run("SAMJ Annotator");
	                    waitForUser("Install and Load EfficientVitSAM10");
	                    waitForUser("Select Image to click GO");
	                }
	
	                // Annotate liposomes for each image
	                annotateLiposoms(MyTitle, output,fit,rxy);
		    	}   
                // Process annotations after applying them
				processSingleLiposomAnnotation(fit,rxy);
				
				//roisToEdges();
				close("*");
                                
            }
        }
    }
}


   	
function annotateLiposoms(MyTitle, output,fit,rxy) {
    
    /**
     * Summary:
     * The `annotateLiposoms` function facilitates the annotation of different types of liposomes (single, multilamellar, and inner liposomes).
     * It prompts the user for manual annotation at each stage, fits ROIs using ellipses, extracts features, and saves the annotated liposomes and results.
     * The results, including counts and size statistics for each type of liposome, are saved in an Excel file.
     *
     * @param MyTitle       The title of the current image being processed.
     * @param output        The output directory where results will be saved.
     */

    // Reset ROI Manager and clear previous results
    roiManager("reset");
    run("Clear Results");
	RoiManager.useNamesAsLabels(false);
	
	run("Set Scale...", "distance=1 known=" + rxy + " unit=nm");
    getDimensions(width, height, channels, slices, frames);
    FOV = (width * height * rxy * rxy);  // Calculate field of view   
	
    // Prompt user to annotate single liposomes
    waitForUser("Annotate Single Liposoms");
	if (fit){
    	fitROIsEllipse();
    }
    featuresSingleLiposoms = extractSizeFeatures(rxy);

    // Save the annotated single liposomes if any features were extracted
    if (featuresSingleLiposoms[0] != 0) {
        roiManager("Save", OutDir + File.separator + MyTitle_short + "_SingleLiposoms.zip");
    }

    // Reset and prepare for multilamellar liposome annotation
    roiManager("reset");
    run("Clear Results");
    waitForUser("Annotate Multilamelar Liposoms");
    if (fit){
    	fitROIsEllipse();
    }
    featuresMultiLamelarLiposoms = extractSizeFeatures(rxy);

    // Save the annotated multilamellar liposomes if any features were extracted
    if (featuresMultiLamelarLiposoms[0] != 0) {
        roiManager("Save", OutDir + File.separator + MyTitle_short + "_MultiLamelarLiposoms.zip");
    }

    // Reset and prepare for inner liposome annotation
    roiManager("reset");
    run("Clear Results");
    waitForUser("Annotate Inner Liposoms");
 	if (fit){
    	fitROIsEllipse();
    }
    featuresInnerLiposoms = extractSizeFeatures(rxy);

    // Save the annotated inner liposomes if any features were extracted
    if (featuresInnerLiposoms[0] != 0) {
        roiManager("Save", OutDir + File.separator + MyTitle_short + "_InnerLiposoms.zip");
    }

    // Calculate and save the percentage of multilamellar liposomes if they exist
    if ((featuresMultiLamelarLiposoms[0] == 0) || (featuresSingleLiposoms[0] == 0)) {
        rMultilamelar=0;
    }else{
    	rMultilamelar = featuresMultiLamelarLiposoms[0] / (featuresMultiLamelarLiposoms[0] + featuresSingleLiposoms[0]);
	}
    

    // Clear results and prepare to save or update the results file
    run("Clear Results");
    if (File.exists(output + File.separator + "SAMJ_Results.xls")) {
        // If the results file exists, open it for modification
        open(output + File.separator + "SAMJ_Results.xls");
        IJ.renameResults("Results");
    }

    // Add results for the current image to the results table
    i = nResults;
    setResult("[Label]", i, MyTitle);
    setResult("FOV(nm2)", i, FOV);
    setResult("# Single Liposoms", i, featuresSingleLiposoms[0]);
    setResult("Single Liposoms meanSize", i, featuresSingleLiposoms[1]);
    setResult("Single Liposoms stdSize", i, featuresSingleLiposoms[2]);
    setResult("# Multilamelar Liposoms", i, featuresMultiLamelarLiposoms[0]);
    setResult("Multilamelar Liposoms meanSize", i, featuresMultiLamelarLiposoms[1]);
    setResult("Multilamelar Liposoms stdSize", i, featuresMultiLamelarLiposoms[2]);
    setResult("% Multilamelar Liposoms", i, rMultilamelar);
    setResult("# Inner Liposoms", i, featuresInnerLiposoms[0]);
    setResult("Inner Liposoms meanSize", i, featuresInnerLiposoms[1]);
    setResult("Inner Liposoms stdSize", i, featuresInnerLiposoms[2]);

    // Save the updated results to the Excel file
    saveAs("Results", output + File.separator + "SAMJ_Results.xls");
}





function processSingleLiposomAnnotation(fit,rxy){
		/**
	     * This function processes single, multilamellar, and inner liposomes in an image.
	     * It retrieves the current image, sets output directories, and processes different types of liposomes
	     * by annotating, fitting ellipses, excluding edge cases, measuring, and saving results.
	     */
    	
		// Converts the image to 8-bit
	    run("8-bit");
	
	    // Retrieves current image title and sets output directory
	    MyTitle = getTitle();
	    output = getInfo("image.directory");
	    OutDir = output + File.separator + "AnalyzedImages";
	    File.makeDirectory(OutDir);  // Creates output directory
	    aa = split(MyTitle, ".");
	    MyTitle_short = aa[0];  // Extracts base name from image title
	    rename(MyTitle_short);
	    showStatus("Analyzing " + MyTitle);
		
		//Scale
	    run("Set Scale...", "distance=1 known=" + rxy + " unit=nm");
	    getDimensions(width, height, channels, slices, frames);
	    FOV = (width * height * rxy * rxy);  // Calculate field of view   
	   	
	    // Duplicates the image for processing and 
		run("Select None");
	    run("Duplicate...", "title=imageToSave");

	    // PROCESS SINGLE LIPOSOMS
	    selectWindow(MyTitle_short);
	    roiManager("reset");
	    run("Clear Results");
	    run("Options...", "iterations=1 count=1");
		 
		// Check if the file containing annotations for single liposomes exists
		if(File.exists(OutDir+File.separator+MyTitle_short+"_SingleLiposoms.zip")){  
		   
		    // Open the ROI manager to load the liposome annotations
		    roiManager("Open", OutDir+File.separator+MyTitle_short+"_SingleLiposoms.zip");  
		   	    
		    // Set the scale and measurement parameters for the analysis
		    run("Set Scale...", "distance=1 known="+rxy+" unit=nm");
		    run("Set Measurements...", "area centroid fit shape redirect=None decimal=2");

		    if(fit){
		        // Fit ellipses to the ROIs if the user has opted to do so
		        fitROIsEllipse();
		    }
		    
		    // Enable batch processing for improved performance
		    setBatchMode(true);
		    
		    // Exclude ROIs that are touching the edges of the image
		    n=roiManager("count");  
		    roisToDelete=newArray(); 
		    cont=0; 
		    for (i = 0; i < (n); i++) {
		        // Process each ROI to determine if it should be excluded
		        roiManager("select", i); 
		        run("Create Mask"); 
		        run("Select All"); 
		        run("Enlarge...","enlarge=-1"); 
		        setForegroundColor(255, 255, 255); 
		        setBackgroundColor(0, 0, 0); 
		        run("Clear Outside"); 
		
		        // Reset colors for further processing
		        setForegroundColor(0, 0, 0); 
		        setBackgroundColor(255, 255, 255); 
		        run("Select None"); 
		        selectWindow("Mask"); 
		        run("Analyze Particles...", "size=2000-Infinity pixel show=Masks exclude in_situ"); 
		        selectWindow("Mask"); 
		        run("Create Selection"); 
		        type=selectionType(); 
		        if(type==-1){
		            // Mark edge-touching ROIs for deletion
		            roisToDelete[cont]=i;
		            cont+=1; 
		        }
		        close("Mask"); 
		    }
		    
		    // Check if there are any ROIs to delete and remove them
		    if(lengthOf(roisToDelete)>0){
		        roiManager("select", roisToDelete); 
		        roiManager("delete");	
		    }
		    
		    // Disable batch mode after processing
		    setBatchMode(false);
		    
		    // Clear previous measurement results and prepare for new measurements
		    run("Clear Results");
		    close("Results");
		    n = roiManager("count"); 
		    if (n>0){
		        rois=Array.getSequence(n); 
		        roiManager("select", rois); 
		        roiManager("measure"); 
		        
		        // Save features of the identified single liposomes
		        singleIDs=Array.getSequence(n+1); 
		        singleIDs=Array.slice(singleIDs,1,lengthOf(singleIDs));
		        liposomsArea=Table.getColumn("Area");
		        liposomsMinAxis=Table.getColumn("Minor");
		        liposomsMaxAxis=Table.getColumn("Major");
		        liposomsPosX=Table.getColumn("X");
		        liposomsPosY=Table.getColumn("Y");
		        class=newArray("SingleLiposoms");
		        string=newArray("SingleLiposoms");
		        for (i = 1; i < n; i++) {
		            class=Array.concat(class,string);		
		        }
		        
		        // Create an overlay to visualize identified single liposomes
		        selectWindow("imageToSave");
		        roiManager("Set Color", "green");
		        roiManager("Set Line Width", 5);
		        roiManager("Show None");
		        roiManager("Show All with labels");
		        run("From ROI Manager");
		        Overlay.add;
		        wait(100);
		        run("Flatten");
		        wait(100);
		        close("imageToSave");
		        selectWindow("imageToSave-1");
		        rename("imageToSave");
		    }
		}else{
		    // If no annotations exist for the image, print a message
		    print("NO ANNOTATIONS FOR IMAGE: "+MyTitle_short);
		    break;
		}
				
		// PROCESS MULTILAMELLAR LIPOSOMS
		selectWindow(MyTitle_short);  
		roiManager("reset");  
		run("Clear Results");  
		run("Select None");  
		run("Remove Overlay");  
		
		// Check if the annotations for multilamellar liposomes exist
		if(File.exists(OutDir + File.separator + MyTitle_short + "_MultiLamelarLiposoms.zip")) {
			
			// Open the existing annotations for multilamellar liposomes
			roiManager("Open", OutDir + File.separator + MyTitle_short + "_MultiLamelarLiposoms.zip");
			multi = true;	
				
			// Set the scale for measurements
			run("Set Scale...", "distance=1 known=" + rxy + " unit=nm");
			run("Set Measurements...", "area centroid fit shape redirect=None decimal=2");
			
			// Fit ellipses if the user has selected the option
			if(fit) {
				fitROIsEllipse();
			}
			
			setBatchMode(true);		
			// Exclude ROIs on the edges without using Analyze Particles
			n = roiManager("count");
			roisToDelete = newArray();
			cont = 0;
			
			// Loop through all ROIs to determine which ones to delete
			for (i = 0; i < n; i++) {
				roiManager("select", i);
				run("Create Mask");
				run("Select All");
				run("Enlarge...", "enlarge=-1");
				setForegroundColor(255, 255, 255);
				setBackgroundColor(0, 0, 0);
				run("Clear Outside");
				setForegroundColor(0, 0, 0);
				setBackgroundColor(255, 255, 255);
				run("Select None");
				selectWindow("Mask");
				run("Analyze Particles...", "size=2000-Infinity pixel show=Masks exclude in_situ");
				selectWindow("Mask");
				run("Create Selection");
				type = selectionType();
				
				// Mark ROIs for deletion if they were not selected
				if(type == -1) {
					roisToDelete[cont] = i;
					cont += 1;
				}
				close("Mask");
			}
			
			// Delete marked ROIs from the ROI Manager
			if(lengthOf(roisToDelete) > 0) {
				roiManager("select", roisToDelete);
				roiManager("delete");	
			}
			
			setBatchMode(false);		
			
			// Clear previous measurement results and re-measure the remaining ROIs
			run("Clear Results");
			close("Results");
			n = roiManager("count");
			
			if (n > 0) {
				multi = true;
				rois = Array.getSequence(n);
				roiManager("select", rois);
				roiManager("measure");
				
				// Extract measurements for multilamellar liposomes
				multiIDs = Array.getSequence(n + 1);
				multiIDs = Array.slice(multiIDs, 1, lengthOf(multiIDs));
				multiLiposomsArea = Table.getColumn("Area");
				multiLiposomsMinAxis = Table.getColumn("Minor");
				multiLiposomsMaxAxis = Table.getColumn("Major");
				multiLiposomsPosX = Table.getColumn("X");
				multiLiposomsPosY = Table.getColumn("Y");
				classMulti = newArray("Multilamelar");
				string = newArray("Multilamelar");
				
				// Prepare class array for multilamellar liposomes
				for (i = 1; i < n; i++) {
					classMulti = Array.concat(classMulti, string);		
				}
				
				// Create an overlay of the multilamellar liposomes
				selectWindow("imageToSave");
				roiManager("Set Color", "red");
				roiManager("Set Line Width", 5);
				roiManager("Show None");
				roiManager("Show All with labels");
				run("From ROI Manager");
				Overlay.add;
				wait(100);
				run("Flatten");
				wait(100);
				close("imageToSave");
				selectWindow("imageToSave-1");
				rename("imageToSave");
				
			} else {
				multi = false;  // Set multi to false if no ROIs were found
			}
		} else {
			multi = false;  // Set multi to false if no annotations exist
		}
		
		// PROCESS INNER LIPOSOMS
		selectWindow(MyTitle_short);  
		roiManager("reset");  
		run("Clear Results");  
		run("Select None");  
		run("Remove Overlay");  
		
		// Check if the annotations for inner liposomes exist
		if(File.exists(OutDir + File.separator + MyTitle_short + "_InnerLiposoms.zip")) {
			
			// Open the existing annotations for inner liposomes
			roiManager("Open", OutDir + File.separator + MyTitle_short + "_InnerLiposoms.zip");
			inner = true;
			
			// Set the scale for measurements
			run("Set Scale...", "distance=1 known=" + rxy + " unit=nm");
			run("Set Measurements...", "area centroid fit shape redirect=None decimal=2");


			// Fit ellipses if the user has selected the option
			if(fit) {
				fitROIsEllipse();
			}
		
			
			setBatchMode(true);
			// Exclude ROIs on the edges without using Analyze Particles
			n = roiManager("count");
			roisToDelete = newArray();
			cont = 0;
			
			// Loop through all ROIs to determine which ones to delete
			for (i = 0; i < n; i++) {
				roiManager("select", i);
				run("Create Mask");
				run("Select All");
				run("Enlarge...", "enlarge=-1");
				setForegroundColor(255, 255, 255);
				setBackgroundColor(0, 0, 0);
				run("Clear Outside");
				setForegroundColor(0, 0, 0);
				setBackgroundColor(255, 255, 255);
				run("Select None");
				selectWindow("Mask");
				run("Analyze Particles...", "size=2000-Infinity pixel show=Masks exclude in_situ");
				selectWindow("Mask");
				run("Create Selection");
				type = selectionType();
				
				// Mark ROIs for deletion if they were not selected
				if(type == -1) {
					roisToDelete[cont] = i;
					cont += 1;
				}
				close("Mask");
			}
			
			// Delete marked ROIs from the ROI Manager
			if(lengthOf(roisToDelete) > 0) {
				roiManager("select", roisToDelete);
				roiManager("delete");	
			}
		
			setBatchMode(false);		
			
			// Clear previous measurement results and re-measure the remaining ROIs
			run("Clear Results");
			close("Results");
			n = roiManager("count");
			
			if (n > 0) {
				inner = true;
				rois = Array.getSequence(n);
				roiManager("select", rois);
				roiManager("measure");
				
				// Extract measurements for inner liposomes
				innerIDs = Array.getSequence(n + 1);
				innerIDs = Array.slice(innerIDs, 1, lengthOf(innerIDs));
				innerLiposomsArea = Table.getColumn("Area");
				innerLiposomsMinAxis = Table.getColumn("Minor");
				innerLiposomsMaxAxis = Table.getColumn("Major");
				innerLiposomsPosX = Table.getColumn("X");
				innerLiposomsPosY = Table.getColumn("Y");
				classInner = newArray("Inner");
				string = newArray("Inner");
				
				// Prepare class array for inner liposomes
				for (i = 1; i < n; i++) {
					classInner = Array.concat(classInner, string);		
				}
				
				// Create an overlay of the inner liposomes
				selectWindow("imageToSave");
				roiManager("Set Color", "blue");
				roiManager("Set Line Width", 5);
				roiManager("Show None");
				roiManager("Show All with labels");
				run("From ROI Manager");
				Overlay.add;
				wait(100);
				run("Flatten");
				wait(100);
				close("imageToSave");
				selectWindow("imageToSave-1");
				rename("imageToSave");
				
			} else {
				inner = false;  // Set inner to false if no ROIs were found
			}
		} else {
			inner = false;  // Set inner to false if no annotations exist
		}
			
		// Gather statistics for single liposomes
		label = MyTitle_short;
		nSingleLiposoms = lengthOf(singleIDs);
		Array.getStatistics(liposomsArea, singleMin, singleMax, singleMean, singleStdDev);
		
		// Gather statistics for multi-lamellar liposomes if present
		if(multi) {
			nMulti = lengthOf(multiIDs);
			Array.getStatistics(multiLiposomsArea, multiMin, multiMax, multiMean, multiStdDev);
		} else {
			nMulti = 0;
			multiMin = 0;
			multiMax = 0; 
			multiMean = 0;
			multiStdDev = 0;
		}
		
		// Gather statistics for inner liposomes if present
		if(inner) {
			nInner = lengthOf(innerIDs);
			Array.getStatistics(innerLiposomsArea, innerMin, innerMax, innerMean, innerStdDev);
		} else {
			nInner = 0;
			innerMin = 0;
			innerMax = 0;
			innerMean = 0;
			innerStdDev = 0;
		}
		
		if ((nMulti ==0) || (nSingleLiposoms==0)){
			rLiposoms=0;
		}else {
			rLiposoms=(nMulti / (nMulti + nSingleLiposoms));
		}
		
		// CONCATENATE ALL RESULTS AND CREATE RESULTS TABLE
		
		// Clear previous results and close the results window
		run("Clear Results");
		close("Results");
		
		// Check if multi-lamellar liposomes are present
		if(multi) {
			
			// Concatenate results for single and multi-lamellar liposomes
			singleIDs = Array.concat(singleIDs, multiIDs);
			liposomsArea = Array.concat(liposomsArea, multiLiposomsArea);
			liposomsMinAxis = Array.concat(liposomsMinAxis, multiLiposomsMinAxis);
			liposomsMaxAxis = Array.concat(liposomsMaxAxis, multiLiposomsMaxAxis);
			liposomsPosX=Array.concat(liposomsPosX, multiLiposomsPosX);
			liposomsPosY=Array.concat(liposomsPosY, multiLiposomsPosY);
			class = Array.concat(class, classMulti);
		}
		
		// Check if inner liposomes are present
		if(inner) {
			
			// Concatenate results for single and inner liposomes
			singleIDs = Array.concat(singleIDs, innerIDs);
			liposomsArea = Array.concat(liposomsArea, innerLiposomsArea);
			liposomsMinAxis = Array.concat(liposomsMinAxis, innerLiposomsMinAxis);
			liposomsMaxAxis = Array.concat(liposomsMaxAxis, innerLiposomsMaxAxis);
			liposomsPosX=Array.concat(liposomsPosX, innerLiposomsPosX);
			liposomsPosY=Array.concat(liposomsPosY, innerLiposomsPosY);
			class = Array.concat(class, classInner);
		}
		
		// Prepare labels for the results table
		label = newArray(MyTitle_short);
		string = newArray(MyTitle_short);
		for (i = 1; i < lengthOf(class); i++) {
			label = Array.concat(label, string);		
		}
		
		// Create a results table for all liposome features
		Table.create("AllLiposomsFeatures");
		Table.setColumn("[Label]", label);
		Table.setColumn("Liposom Class", class);
		Table.setColumn("ID", singleIDs);
		Table.setColumn("Area (nm^2)", liposomsArea);
		Table.setColumn("Min Axis (nm)", liposomsMinAxis);
		Table.setColumn("Max Axis (nm)", liposomsMaxAxis);
		Table.setColumn("CentroidX", liposomsPosX);
		Table.setColumn("CentroidY", liposomsPosY);
		Table.update;
		IJ.renameResults("Results");
		
		
		// Save results to an Excel file
		if(File.exists(output + File.separator + "QuantificationSingleLiposoms.xlsx")) {	
			run("Read and Write Excel", "file=[" + output + File.separator + "QuantificationSingleLiposoms.xlsx] dataset_label=[Liposoms Individual Features] stack_results");
			run("Clear Results");
			close("Results");
		} else {
			run("Read and Write Excel", "file=[" + output + File.separator + "QuantificationSingleLiposoms.xlsx] dataset_label=[Liposoms Individual Features]");
			close("Results");
			run("Clear Results");
		}
		
		label = MyTitle_short;
		// Create a table for average liposome features
		Table.create("AverageLiposomsFeatures");
		Table.set("[Label]", 0, label);
		Table.set("Ratio # Multilamelar/TotalLiposoms", 0,rLiposoms);
		Table.set("#Liposoms", 0, nSingleLiposoms);
		Table.set("Liposoms Avg Size (nm2)", 0, singleMean);
		Table.set("Liposoms std Size (nm2)", 0, singleStdDev);
		Table.set("Liposoms Min Size (nm2)", 0, singleMin);
		Table.set("Liposoms Max Size (nm2)", 0, singleMax);
		Table.set("# MultiLamelar", 0, nMulti);
		Table.set("MultiLamelar Avg Size (nm2)", 0, multiMean);
		Table.set("MultiLamelar std Size (nm2)", 0, multiStdDev);
		Table.set("MultiLamelar Min Size (nm2)", 0, multiMin);
		Table.set("MultiLamelar Max Size (nm2)", 0, multiMax);
		Table.set("# InnerLiposoms", 0, nInner);
		Table.set("Inner Avg Size (nm2)", 0, innerMean);
		Table.set("Inner std Size (nm2)", 0, innerStdDev);
		Table.set("Inner Min Size (nm2)", 0, innerMin);
		Table.set("Inner Max Size (nm2)", 0, innerMax);
		Table.update;
		IJ.renameResults("Results");
				
		// Save average results to an Excel file
		if(File.exists(output + File.separator + "QuantificationAVGResultsLiposoms.xlsx")) {	
			run("Read and Write Excel", "file=[" + output + File.separator + "QuantificationAVGResultsLiposoms.xlsx] dataset_label=[Liposoms Average Features] stack_results");
			close("Results");
		} else {
			run("Read and Write Excel", "file=[" + output + File.separator + "QuantificationAVGResultsLiposoms.xlsx] dataset_label=[Liposoms Average Features]");
			close("Results");
		}
		
		// SAVE LABELLED IMAGE
		selectWindow("imageToSave");
		saveAs("Jpeg", OutDir + File.separator + MyTitle_short + "_analyzed.jpg");	
		close("*");
}

function roisToEdges(){
	
	 	
		// Converts the image to 8-bit
	    //run("8-bit");
	
	    // Retrieves current image title and sets output directory
	    MyTitle = getTitle();
	    output = getInfo("image.directory");
	    OutDir = output + File.separator + "AnalyzedImages";
	    newDir= output + File.separator + "EDGES";
	    File.makeDirectory(newDir);  // Creates output directory
	    aa = split(MyTitle, ".");
	    MyTitle_short = aa[0];  // Extracts base name from image title
	    rename(MyTitle_short);
	    showStatus("Analyzing " + MyTitle);
		
		//Scale
	    run("Set Scale...", "distance=1 known=" + rxy + " unit=nm");
	    getDimensions(width, height, channels, slices, frames);

		// Duplicates the image for processing and 
		run("Duplicate...", "title=singleLiposLabels");
		run("Select All");
	    setBackgroundColor(255, 255, 255);
		run("Clear", "slice");
		run("Select None");

	    // PROCESS SINGLE LIPOSOMS
	    roiManager("reset");
	    run("Clear Results");
	    run("Options...", "iterations=1 count=1");
		 
		// Check if the file containing annotations for single liposomes exists
		if(File.exists(OutDir+File.separator+MyTitle_short+"_SingleLiposoms.zip")){
			
			// Open the ROI manager to load the liposome annotations
		    roiManager("Open", OutDir+File.separator+MyTitle_short+"_SingleLiposoms.zip");
		    selectWindow("singleLiposLabels");
		    run("From ROI Manager");
			run("Create Mask");
			run("Create Selection");
			run("Enlarge...", "enlarge=-15 pixel");
			setForegroundColor(255, 255, 255);
			setBackgroundColor(0, 0, 0);
			run("Fill", "slice");
			//run("Connected Component Labeling");
			close("singleLiposLabels");
			selectWindow("Mask");
			rename("singleLiposLabels");
			run("Select None");
			//run("3-3-2 RGB");
			//close("Mask");
					
		}
		
		
	    // PROCESS Multilamellar LIPOSOMS
	    
	    // Duplicates the image for processing and 
		run("Duplicate...", "title=multiLiposLabels");
		run("Select All");
	    setBackgroundColor(255, 255, 255);
		run("Clear", "slice");
		run("Select None");
	    
	    
	    roiManager("reset");
	    run("Clear Results");
	    run("Options...", "iterations=1 count=1");
		 
		// Check if the file containing annotations for single liposomes exists
		if(File.exists(OutDir+File.separator+MyTitle_short+"_MultiLamelarLiposoms.zip")){
			
			// Open the ROI manager to load the liposome annotations
		    roiManager("Open", OutDir+File.separator+MyTitle_short+"_MultiLamelarLiposoms.zip");
		    selectWindow("multiLiposLabels");
		    run("From ROI Manager");
			run("Create Mask");
			run("Create Selection");
			run("Enlarge...", "enlarge=-15 pixel");
			setForegroundColor(255, 255, 255);
			setBackgroundColor(0, 0, 0);
			run("Fill", "slice");
			//run("Connected Component Labeling");
			close("multiLiposLabels");
			selectWindow("Mask");
			rename("multiLiposLabels");
			run("Select None");
			//run("3-3-2 RGB");
			//close("Mask");
			
		}
		
	     // Duplicates the image for processing and 
		run("Duplicate...", "title=innerLiposLabels");
		run("Select All");
	    setBackgroundColor(255, 255, 255);
		run("Clear", "slice");
		run("Select None");
	        
	    roiManager("reset");
	    run("Clear Results");
	    run("Options...", "iterations=1 count=1");
		 
		// Check if the file containing annotations for single liposomes exists
		if(File.exists(OutDir+File.separator+MyTitle_short+"_InnerLiposoms.zip")){
			
			// Open the ROI manager to load the liposome annotations
		    roiManager("Open", OutDir+File.separator+MyTitle_short+"_InnerLiposoms.zip");
		    selectWindow("innerLiposLabels");
		    run("From ROI Manager");
			run("Create Mask");
			run("Create Selection");
			run("Enlarge...", "enlarge=-15 pixel");
			setForegroundColor(255, 255, 255);
			setBackgroundColor(0, 0, 0);
			run("Fill", "slice");
			//run("Connected Component Labeling");
			close("innerLiposLabels");
			selectWindow("Mask");
			rename("innerLiposLabels");
			run("Select None");
			//run("3-3-2 RGB");
			//close("Mask");
			
		}
	
		imageCalculator("XOR create", "singleLiposLabels","multiLiposLabels");
		imageCalculator("XOR create", "Result of singleLiposLabels","innerLiposLabels");
		selectImage("Result of Result of singleLiposLabels");
		rename("liposEDGES");
		close("*Labels*");
		
		// SAVE LABELLED IMAGE
		selectWindow("liposEDGES");
		saveAs("Tiff", newDir + File.separator + MyTitle_short + "_liposEdges.tif");	
			
	
}


function processAnnotations(InDir) {

    /**
     * Summary:
     * The `processAnnotations` function processes image annotations either from a single file or all images in a specified directory.
     * It uses the Bio-Formats Importer to load images, resets the ROI Manager, and calls the `processSingleAnnotation` function 
     * for annotation processing.
     *
     * @param InDir        The input directory path or "-" if a single file will be processed.
     */

    // Resets ROI Manager and closes all images to start fresh
    roiManager("reset");
    run("Close All");
    run("Fresh Start");
	RoiManager.associateROIsWithSlices(true);
	RoiManager.restoreCentered(false);
	RoiManager.useNamesAsLabels(false);
	
    // If no directory is specified, prompt the user to select a single file
    if (InDir == "-") {
        
        name = File.openDialog("Select File");
        run("Bio-Formats Importer", "open=[" + name + "] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
		
		rxy=0;
        // Create a dialog to gather user parameters for analysis
	    Dialog.create("Parameters for the analysis");
	    Dialog.addMessage(" PRE-PROCESSING PARAMETERS");
	    Dialog.addCheckbox("Fit Ellipse", true);
	    Dialog.addNumber("Resolution (nm/px)", rxy);
	    Dialog.show();
	    
	    fit=Dialog.getCheckbox();
	    rxy=Dialog.getNumber();
	    			
        // Process annotations for the single selected file   
        processSingleLiposomAnnotation(fit,rxy);
        
    } else {
        // If a directory is specified, prompt user to select a directory
        InDir = getDirectory("Choose a Directory");
        list = getFileList(InDir);
        L = lengthOf(list);
        
         // Create a dialog to gather user parameters for analysis
	    Dialog.create("Parameters for the analysis");
	    Dialog.addMessage("PRE-PROCESSING PARAMETERS");
	    Dialog.addCheckbox("FitElipse", true);
	    Dialog.addNumber("Resolution (nm/px)", rxy);
	    Dialog.show();
	    
    	fit= Dialog.getCheckbox();
	    rxy=Dialog.getNumber();
              
        // Disable batch mode for user interaction
        setBatchMode(false);
        
        // Loop through files in the directory and process each applicable image file
        for (j = 0; j < L; j++) {
            if (endsWith(list[j], "czi") || endsWith(list[j], "tif") || endsWith(list[j], "jpg")) {
                name = list[j];
                run("Bio-Formats Importer", "open=[" + InDir + File.separator + name + "] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
			    
                // Process annotations for each image file
                processSingleLiposomAnnotation(fit,rxy);
            }
        }
    }
}




function fitROIsEllipse() {
    // Fits ellipses to all current ROIs and replaces original ROIs with their fitted ellipses
    
    n = roiManager("count");
    // print(n);
    if (n != 0) {
        for (i = 0; i <= n - 1; i++) {
            roiManager("select", i);
            run("Fit Ellipse");
            roiManager("add");
        }
        deleteRois = Array.getSequence(n);
        // Array.print(deleteRois);
        roiManager("select", deleteRois);
        roiManager("delete");
    }
}

function extractSizeFeatures(rxy) {
	
	// Count ROIs, measure them, extract the Area values,
	// compute statistics, and return an array with the count, mean, and stdDev.
	run("Set Scale...", "distance=1 known=" + rxy + " unit=nm");
    run("Set Measurements...", "area centroid fit shape redirect=None decimal=2");
 
    n = roiManager("count");
    
    if (n!=0){
    
	    roiManager("measure");
	    wait(10);
	    selectWindow("Results");
	    Area = Table.getColumn("Area");       
	    Array.getStatistics(Area, min, max, mean, stdDev);
	    features = newArray(n, mean, stdDev); 
	    //Array.print(features);
	    
    }else{
    	
    	features = newArray(0,0,0); 
	    	
    }
    close("Results");
    return features;                      
}



