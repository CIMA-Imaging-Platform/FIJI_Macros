/* UTILS LIST */


// ARRAY F U N C T I O N S .....................................................


function multiplyArrayByScalar(array,scalar){
	
	// * @return {array}  - An array.
	// * @param {scalar}  - float scalar.
			
		for (i = 0; i < lengthOf(array); i++) {
			array[i]=array[i]*scalar;
		}
		return array;
}

function devideArrayByScalar(array,scalar){
	
	// * @return {array}  - An array.
	// * @param {scalar}  - float scalar.
			
		for (i = 0; i < lengthOf(array); i++) {
			array[i]=array[i]/scalar;
		}
		return array;
}

function ArrayUnion(array1, array2) {
	unionA = newArray();
	for (i=0; i<array1.length; i++) {
		for (j=0; j<array2.length; j++) {
			if (array1[i] == array2[j]){
				unionA = Array.concat(unionA, array1[i]);
			}
		}
	}
	return unionA;
}

function ArrayDiff(array1, array2) {
	diffA	= newArray();
	unionA 	= newArray();	
	for (i=0; i<array1.length; i++) {
		for (j=0; j<array2.length; j++) {
			if (array1[i] == array2[j]){
				unionA = Array.concat(unionA, array1[i]);
			}
		}
	}
	c = 0;
	for (i=0; i<array1.length; i++) {
		for (j=0; j<unionA.length; j++) {
			if (array1[i] == unionA[j]){
				c++;
			}
		}
		if (c == 0) {
			diffA = Array.concat(diffA, array1[i]);
		}
		c = 0;
	}
	for (i=0; i<array2.length; i++) {
		for (j=0; j<unionA.length; j++) {
			if (array2[i] == unionA[j]){
				c++;
			}
		}
		if (c == 0) {
			diffA = Array.concat(diffA, array2[i]);
		}
		c = 0;
	}	
	return diffA;
}

function ArrayUnique(array) {
    // Sort the array first
    array = Array.sort(array);
    
    // Initialize an array to store unique values
    uniqueA = newArray();
    
    // Iterate through the sorted array to find unique values
    for (i = 0; i < array.length - 1; i++) {
        // If the current element is different from the next element, it's unique
        if (array[i] != array[i + 1]) {
            uniqueA = Array.concat(uniqueA, array[i]);
        }
    }
    
    // Always add the last element since it's not checked in the loop
    uniqueA = Array.concat(uniqueA, array[array.length - 1]);

    return uniqueA;
}
		
// Function to calculate the mode of an array
function calculateMode(array) {
    uniqueArray = ArrayUnique(array);  // Get unique values from the array
    maxCount = -1;                     // Variable to store the highest frequency
    mode = -1;                          // Variable to store the mode value
    
    // Iterate over the unique values to count occurrences in the original array
    for (i = 0; i < uniqueArray.length; i++) {
        count = 0;
        for (j = 0; j < array.length; j++) {
            if (array[j] == uniqueArray[i]) {
                count++;  // Increment the count for the current unique value
            }
        }
        
        // Update the mode if the current value has a higher count
        if (count > maxCount) {
            maxCount = count;
            mode = uniqueArray[i];
        }
    }

    return mode;
}

function ArrayOccur(array, n) {
	array1 	= Array.sort(array);
	array2 	= Array.concat(array1, 999999);
	uniqueA = newArray();
	i = 0;	
   	while (i<(array2.length)-1) {
		if (array2[i] == array2[(i)+1]) {
			//print("found: "+array[i]);			
		} else {
			uniqueA = Array.concat(uniqueA, array2[i]);
		}
   		i++;
   	}
   	c = 0;
   	occurA	= newArray();
   	//compare unique with input array
   	for (i=0; i<uniqueA.length; i++) {
   		for (j=0; j<array.length; j++) {
   			if (uniqueA[i] == array[j]) {
   				c++;
   			}
   		}
   		if (c == n) {
   			occurA = Array.concat(occurA, uniqueA[i]);
   		}
   		c = 0;
   	}
	return occurA;
}


function statisticsEachSlice(){
      if (nSlices>1) run("Clear Results");
      getVoxelSize(w, h, d, unit);
      n = getSliceNumber();
      for (i=1; i<=nSlices; i++) {
          setSlice(i);
          getStatistics(area, mean, min, max, std);
          row = nResults;
          if (nSlices==1)
              setResult("Area ("+unit+"^2)", row, area);
          setResult("Mean ", row, mean);
          setResult("Std ", row, std);
          setResult("Min ", row, min);
          setResult("Max ", row, max);
      }
      setSlice(n);
      updateResults();
	}	

macro "Plot Histogram" {
       getStatistics(area, mean, min, max, std, histogram);
       if (bitDepth==8 || bitDepth==24)
           Plot.create("Histogram", "Value", "Count", histogram);
       else {
           values = newArray(256);
           value = min;
           binWidth = (max-min)/256;
           for (i=0; i<256; i++) {
               values[i] = value;
               value += binWidth;
          }
          Plot.create("Histogram", "Value", "Count", values, histogram);
       }
  }

macro "List Histogram Counts" {
       run("Clear Results");
       getStatistics(area, mean, min, max, std, histogram);
       if (bitDepth==8 || bitDepth==24) {
           for (i=0; i<histogram.length; i++) {
               setResult("Value", i, i);
               setResult("Count", i, histogram[i]);
          }
       } else {
           value = min;
           binWidth = (max-min)/256;
           for (i=0; i<histogram.length; i++) {
               setResult("Value", i, value);
               setResult("Count", i, histogram[i]);
               value += binWidth;
          }
       }
       updateResults();
  }

macro "Plot Z-axis Profile" {
      if (nSlices==1) exit("This macro requires a stack");
      n = getSliceNumber();
      means = newArray(nSlices);
      for (i=1; i<=nSlices; i++) {
          setSlice(i);
          getStatistics(area, mean);
          means[i-1] = mean;
      }
      setSlice(n);
      Plot.create("Histogram", "Slice", "Mean", means);
  }



function CalcStackHist() 
{
	/**
	* Function: CalcStackHist
	* 
	* Purpose:
	* This function calculates a cumulative histogram for an image stack. It aggregates 
	* the pixel intensity counts from all slices of the stack into a single histogram, 
	* representing the distribution of pixel intensities across the entire stack.
	* 
	* Returns:
	* - `countsStack`: An array of size 256, where each index corresponds to a pixel intensity 
	*   (0–255) and contains the total count of pixels with that intensity across all slices.
	*/

    // Initialize the cumulative histogram with the first slice
    setSlice(1); // Set the active slice to the first slice of the stack
    getHistogram(valuesStack, countsStack, 256); // Compute histogram for the first slice

    // Clear any pre-existing results in the Results table
    run("Clear Results");

    // Iterate through all slices starting from the second
    for (sl = 2; sl <= nSlices; sl++) {
        setSlice(sl); // Set the active slice to the current slice

        // Get the histogram for the current slice
        getHistogram(values, counts, 256);

        // Add the current slice's pixel counts to the cumulative histogram
        for (i = 0; i < 256; i++) {
            countsStack[i] += counts[i];
        }
    }

    // Uncomment this line for debugging purposes to view the cumulative histogram
    // Array.show(countsStack);

    // Return the cumulative histogram
    return countsStack;
}


// TABLE F U N C T I O N S .....................................................


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
	 /*
	 tableName="Results";
	 columnName="Mean";
	 filterType=">";
	 threshold=0;*/
	 
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
	
	// Return the array of positive indices
	return positiveRois;
}

// DIRECTORIES FILES F U N C T I O N S .....................................................

function extractFilesSubfolder(){
	// Select the root directory
	rootDir = getDirectory("Choose the parent folder");

	// Get all subdirectories
	list = getFileList(rootDir);
	for (i = 0; i < list.length; i++) {
		currentPath = rootDir + list[i];
		if (File.isDirectory(currentPath)) {
			processSubfolder(currentPath, rootDir);
		}
	}

	// Function to process files in subfolders
	function processSubfolder(subfolderPath, destination) {
		files = getFileList(subfolderPath);
		for (j = 0; j < files.length; j++) {
			filePath = subfolderPath + files[j];
			if (!File.isDirectory(filePath)) {
				File.copy(filePath, destination + files[j]);
			}
		}
	}
}


function openFileFormat(file) {
	// Function openFileFormat:
	// This function opens files based on their format.
	
	// Parameters:
	// @param {string} : File path.
	
	
	if (endsWith(file, ".jpg") || endsWith(file, ".tif")) {
		open(file);
	} else if (endsWith(file, ".czi") || endsWith(file, ".svs")) {
		run("Bio-Formats Importer", "open=[" + file + "] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	}
}


// ROIs F U N C T I O N S .....................................................



function deleteTissueRegions(im,mask){

	// Delete unwanted ROIS	
	deleteROIs=getBoolean("Do you want to Delete unwanted Regions");
	
	do {
				
		nRois=roiManager("count");
		if (nRois>1){
			roiManager("select", 1);
			roiManager("delete");
			
		}
		
		// DELETE
		setTool("freehand");
		selectWindow(im);
		roiManager("select", 1);
		
		waitForUser("Please Draw ROI to delete and press ok when ready");
		
		//check if we have a selection
		type = selectionType();
		if (type==-1)	{
			showMessage("Edition", "You should select a fiber to delete. Nothing will be deleted.");
			exit();
		}	

		selectWindow(mask);
		setBatchMode("show");
		run("Restore Selection");
		setForegroundColor(255, 255, 255);
		run("Fill", "slice");
		run("Create Selection");
		selectWindow(im);
		run("Restore Selection");
		showMessage("Selection deleted");
		selectWindow(im);
		deleteROIs=getBoolean("Do you want to Delete another unwanted Regions");
		
		
	} while (deleteROIs)
}

function particlesConvexHull(mask) {
	/**
	 * Processes a binary mask to compute the convex hull for particles.
	 * 
	 * @param {string} mask - binary mask (Inverted LUT) with particles. 
	 */
	
		// Reset ROI Manager and prepare the mask for analysis
		roiManager("reset");
		selectWindow(mask);
		run("Select None");
		run("Analyze Particles...", " add");
		run("Colors...", "foreground=black background=white selection=red");
		setForegroundColor(0, 0, 0);
	
		// Compute convex hull for each particle in the mask
		n = roiManager("count");
		for (i = 0; i < n; i++) {
			roiManager("select", i);
			run("Convex Hull");
			run("Fill");
		}
		
		// Reset the ROI Manager and deselect the mask
		roiManager("reset");
		selectWindow(mask);
		run("Select None");
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


function addROIsFun(Mask, orig) {
    // Loop to add multiple ROIs if desired
    addROIs = true;
    while (addROIs) {
        // Prompt the user to draw a ROI to delete
        setTool("freehand");
        selectWindow(orig);
        waitForUser("Please Draw Vessels ROI and press OK when ready");
      
        // Check if a selection is made
        type = selectionType();
        if (type == -1) {
            showMessage("Edition", "You should DRAW a REGION. Otherwise nothing will be added.");
            exit();
        }
        
        // Apply the selection to the mask image
        selectWindow(Mask);
        setBatchMode("show");
        run("Restore Selection");
        setForegroundColor(0, 0, 0);
        run("Fill", "slice");
        run("Create Selection");
        
        // Apply the selection to the original image
        selectWindow(orig);
        run("Restore Selection");
        
        // Prompt the user to add another ROI
        selectWindow(orig);
        addROIs = getBoolean("Do you want to add other Detected Regions");
    }
}


function deleteROIsFun(Mask, orig) {
    // Loop to delete multiple ROIs if desired
    deleteROIs = getBoolean("Do you want to Delete other Detected Regions");
    while (deleteROIs) {
        // Prompt the user to draw a ROI to delete
        setTool("freehand");
        waitForUser("Please Draw ROI to delete and press OK when ready");
        
        // Check if a selection is made
        type = selectionType();
        if (type == -1) {
            showMessage("Edition", "You should DRAW a REGION. Otherwise nothing will be deleted.");
            
        }else{
        
	        // Apply the selection to the mask image
	        selectWindow(Mask);
	        setBatchMode("show");
	        run("Restore Selection");
	        setForegroundColor(255, 255, 255);
	        run("Fill", "slice");
	        run("Create Selection");
	        
	        // Apply the selection to the original image
	        selectWindow(orig);
	        run("Restore Selection");
	         
	        // Prompt the user to delete another ROI
	        selectWindow(orig);
	        deleteROIs = getBoolean("Do you want to Delete other Detected Regions");
        }
    }
}


function addOverlayLabels3D(target, mask, color) {

	/* Function to overlay labels on the image
 	* 
 	* @param {string} target - The name of the target image.
 	* @param {string} mask - The name of the mask.
 	* @param {string} color - color name ID.
 	*/ 

	selectWindow(mask);
	for (i = 1; i <= nSlices; i++) {
			selectWindow(mask);
			setSlice(i);
			run("Create Selection");
			if (selectionType() != -1){
				selectWindow(target);
				run("Restore Selection");		    
				run("Add Selection...", "stroke="+color+" width=1");
				Overlay.setPosition(i);
			}
	}
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


function addOverlay2dTime(rawImage,maskImage,channel,color,slice){
			
	selectWindow(rawImage);
	
	getDimensions(width, height, channels, slices, frames);
	Array.print(newArray(width, height, channels, slices, frames));
	RoiManager.associateROIsWithSlices(false);	

	// Ensure the image is a stack
	if (frames > 1) {
		// Loop through each slice
		for (f = 1; f <= frames; f++) {
			selectWindow(maskImage);
			// Create an ROI from the binary image
			Stack.setFrame(f);
			run("Select None");
			run("Create Selection");
			wait(5);
			type=selectionType();
			if(type!=-1){
				selectWindow(rawImage);
				Stack.setFrame(f);
				run("Restore Selection");
				//	Array.print(newArray(channel,s,frame));
				selectWindow(rawImage);
				Overlay.addSelection(color);
				Overlay.setPosition(channel, slice, f);				
			}

		}
	}else{
		print("The image is not a stack.");
	}
}	

// FILTERs F U N C T I O N S .....................................................


function correctBackground(image) {
	/**
	 * Adjusts the background intensity of an image based on pixel intensity mode.
	 * Supports global and tissue-specific correction modes.
	 * 
	 * @param {string} image - Name of the image window to correct.
	 * @returns {number} mode - The mode of pixel intensity used for adjustment.
	 * 
	 * Modes:
	 * - **Global Correction**: Calculates the mode for the entire image. If mode > 200, adjusts brightness by adding (255 - mode) to all pixels.
	 * - **Tissue-Specific Correction**: Calculates the mode within a selected ROI. Adjustment logic for this mode is incomplete.
	 * 
	 * Requirements:
	 * - For tissue-specific correction, an ROI must be present in the ROI Manager.
	 * 
	 * Note: Global correction is enabled by default.
	 */

	
	
    // Set to true for global background correction; false for tissue-specific correction.
    globalMode = true;

    if (globalMode) {
        // Global background correction
        run("Clear Results");
        run("Set Measurements...", "area mean modal redirect=None decimal=2");
        run("Select All");
        
        // Get the mode of pixel intensity
        mode = getValue("Mode");
        print(mode);

        // Adjust brightness if mode exceeds threshold
        if (mode > 200) {
            dif = 255 - mode;
            selectWindow(image);
            run("Add...", "value=" + dif);
        }

        // Clear measurement results
        run("Clear Results");
    } else {
        // Tissue-specific background correction
        run("Clear Results");
        run("Set Measurements...", "area mean modal redirect=None decimal=2");

        // Assume ROI is preloaded in the ROI Manager
        selectWindow(image);
        roiManager("select", 0);
        run("Measure");

        // Get the mode of pixel intensity within the ROI
        mode = getResult("Mode", 0);

        if (mode > 200) {
            selectWindow(image);
            dif = 255 - mode;
            run("Select None");
        }

        // Clear measurement results
        run("Clear Results");
    }

    return mode; // Return the measured mode
}



function backgroundSubstract2DGPU(name, sigma) {
	
	/**
	 * Subtracts background from an image using GPU acceleration.
	 * 
	 * @param {string} name - The name of the input image.
	 * @param {number} sigma - The standard deviation for Gaussian blur.
	 */
	// Load CLIJ GPU accelerator and CLIJ2 Macro Extensions
	run("CLIJx Version 0.32.1.1");
	run("CLIJ2 Macro Extensions", "cl_device=[]");
	
	// Clear CLIJ2
	Ext.CLIJ2_clear();
	
	// Push input image to GPU memory
	image1 = name;
	Ext.CLIJ2_push(image1);
	
	// Define output image name
	image2 = name + "_subtracted";
	
	// Set sigma values for Gaussian blur
	sigma_x = sigma;
	sigma_y = sigma;
	
	// Subtract background using CLIJx
	Ext.CLIJx_subtractBackground2D(image1, image2, sigma_x, sigma_y);
	
	// Pull result image from GPU memory
	Ext.CLIJ2_pull(image2);
	
	// Clear CLIJ2
	Ext.CLIJ2_clear();
	
	// Close input image
	close(image1);
	
	// Rename output image
	selectWindow(image2);
	rename(name);
}



function backgroundSubstract3DGPU(name, sigma) {
	
	/**
	 * Subtracts background from an image using GPU acceleration.
	 * 
	 * @param {string} name - The name of the input image.
	 * @param {number} sigma - The standard deviation for Gaussian blur.
	 */
	// Load CLIJ GPU accelerator and CLIJ2 Macro Extensions
	run("CLIJx Version 0.32.1.1");
	run("CLIJ2 Macro Extensions", "cl_device=[]");
	
	// Clear CLIJ2
	Ext.CLIJ2_clear();
	
	// Push input image to GPU memory
	image1 = name;
	Ext.CLIJ2_push(image1);
	
	// Define output image name
	image2 = name + "_subtracted";
	
	// Set sigma values for Gaussian blur
	sigma_x = sigma;
	sigma_y = sigma;
	sigma_z = sigma;
	
	
	// Subtract background using CLIJx
	Ext.CLIJx_subtractBackground3D(image1, image2, sigma_x, sigma_y,sigma_z);
	
	// Pull result image from GPU memory
	Ext.CLIJ2_pull(image2);
	
	// Clear CLIJ2
	Ext.CLIJ2_clear();
	
	// Close input image
	close(image1);
	
	// Rename output image
	selectWindow(image2);
	rename(name);
}


// SEGMENTATION F U N C T I O N S .....................................................


function huangThreshold(image){

	selectWindow(image);
	
	// Find Slice with Max Signal
	run("Select All");
	run("Measure Stack...");
	selectWindow("Results");
	meanSliceI=Table.getColumn("Mean");
	Array.getStatistics(meanSliceI, min, max, mean, stdDev);
	Array.print(newArray(min, max, mean, stdDev));
	maxMarker1=Array.findMaxima(meanSliceI,stdDev);
	Array.print(maxMarker1);
	selectWindow("live");
	if (maxMarker1[0]==0){
		setSlice(1);
	}else{
		setSlice(maxMarker1[0]);
	}
	run("Enhance Contrast", "saturated=0.1");
	run("Apply LUT", "stack");
	run("Gaussian Blur...", "sigma=2 stack");
	
	setAutoThreshold("Huang dark");
	//setThreshold(25, 255);
	run("Convert to Mask", "method=Huang background=Dark");
	
}


function percHistMode(image){

	//--Calculate threshold as PercHist % of the mode in the histogram
	
	selectWindow(image);
	//calculate stack histogram
	setSlice(1);
	getHistogram(valuesStack,countsStack,256);
	run("Clear Results");
	for (sl=2; sl<=nSlices; sl++) {
		setSlice(sl);
		getHistogram(values,counts,256);
		for (i = 0; i < 256; i++) {
			countsStack[i] += counts[i]; 
		}	
	}
	// max count value
	Array.getStatistics(countsStack, min, maxCount, mean, stdDev);
	// intensity at which the count is max
	iMaxCount = Array.findMaxima(countsStack, 500);
	// search for intensity at which the peak of the histogram descends below PercHist
	cCount = maxCount;
	cInt = iMaxCount[0];
	while(cCount >= maxCount*PercHist*0.01) {	//multiply by 0.01 because PercHist value is in %
		cInt = cInt+1;
		cCount = countsStack[cInt];
	}
	// current intensity, at which the counts are below desired % of the histogram peak, is our threshold for bacteria
	thBac = cInt;
	
	
	//--Thresholding
	setThreshold(thBac, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark");
	
}

function fixThreshold(image){
	
	selectWindow(image);
	setThreshold(thBac, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark");
}


function segmentNucleus3D(image, kernelSize3D) {

	/**
	 * Segments nuclei in a 3D image using CLIJx and CLIJ2 for processing.
	 *
	 * @param image        The name of the image window to be processed.
	 * @param kernelSize3D Array containing the kernel sizes for background subtraction (sigma_x, sigma_y, sigma_z).
	 */
	
	
    // Print message to console
    print("Segmenting Nucleus 3D....");
    
    // Select the specified image window
    selectWindow(image);
    setBatchMode(false);
    
    // Duplicate the selected image for processing
    run("Duplicate...", "title=SegNucleus3D duplicate");
    
    // Initialize CLIJx and CLIJ2 extensions
    run("CLIJx Version 0.32.1.1");
    run("CLIJ2 Macro Extensions", "cl_device=[]");
    Ext.CLIJ2_clear();
    
    // Subtract background using CLIJx
    image1 = "SegNucleus3D";
    Ext.CLIJ2_push(image1);
    image2 = "SegNucleus3D_subBckg";
    sigma_x = kernelSize3D[0];
    sigma_y = kernelSize3D[1];
    sigma_z = kernelSize3D[2];
    Ext.CLIJx_subtractBackground3D(image1, image2, sigma_x, sigma_y, sigma_z);
    Ext.CLIJ2_pull(image2);
    Ext.CLIJ2_clear();
    
    // Perform 3D nuclei segmentation on the background-subtracted image
    selectWindow("SegNucleus3D_subBckg");
    run("3D Nuclei Segmentation", "auto_threshold=Otsu manual=0 separate_nuclei");
    
    // Threshold the segmented image
    selectImage("merge");
    setAutoThreshold("Default dark no-reset");
    getThreshold(lower, upper);
    setThreshold(1, upper);
    setOption("BlackBackground", false);
    
    // Convert the image to a mask
    run("Convert to Mask", "background=Dark");
    
    // Analyze particles in the mask
    run("Analyze Particles...", "size=20-Infinity pixel show=Masks in_situ");
    
    // Fill holes in the 3D stack
    run("Fill Holes", "stack");
    
    // Apply 3D morphological filters to clean up the segmentation
    run("Morphological Filters (3D)", "operation=Opening element=Cube x-radius=2 y-radius=2 z-radius=2");
    
    // Invert the stack and re-analyze particles
    run("Invert", "stack");
    run("Analyze Particles...", "size=100-Infinity pixel show=Masks in_situ stack");
    
    // Label the connected components in the 3D image
    run("Connected Components Labeling", "connectivity=6 type=[16 bits]");
    
    // Rename the labeled image and close intermediate images
    rename("nucleus3D_labelled");
    close("merge*");
    close("SegNucleus3D*");
    
    // Exit batch mode and display results
    setBatchMode("exit and display");
}


function nucleiSegmentationMarkerWatershed{
	
	// SEGMENT NUCLEI FROM DAPI:

	/* Duplicate the image and apply mean filtering
	selectWindow(MyTitle);
	//cDAPI=1;
	run("Duplicate...", "title=nucleiMask duplicate channels="+cDAPI);
	run("Mean...", "radius=4");
	
	// Background subtraction using GPU acceleration
	backgroundSubstract2DGPU("nucleiMask",100)*/
	
	// Apply thresholding and morphological operations to segment nuclei
	setAutoThreshold("Otsu dark");
	setThreshold(8,255);
	run("Convert to Mask");
	run("Median...", "radius=2");
	run("Fill Holes");
	run("Select All");
	run("Analyze Particles...", "size=200-5000 pixel show=Masks in_situ");
	RoiManager.selectByName("Tissue");
	setBackgroundColor(255,255,255);
	run("Clear Outside");
	setBackgroundColor(0,0,0);
	run("Select None");
	
	// Perform marker-controlled watershed segmentation
	run("Duplicate...", "title=EDM duplicate ");
	run("Distance Map");
	run("Enhance Contrast", "saturated=0.05");
	run("Apply LUT");
	run("Find Maxima...", "prominence=20 light output=[Single Points]");
	rename("nucleiMaxima");
	
	selectWindow("nucleiMask");
	run("Select All");;
	run("Duplicate...", "title=nucleiEdges");
	run("Find Edges");
	
	// Apply marker-controlled watershed
	run("Marker-controlled Watershed", "input=nucleiEdges marker=nucleiMaxima mask=nucleiMask binary calculate use");
	selectWindow("nucleiEdges-watershed");
	run("8-bit");
	setThreshold(1, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Create Selection");
	Roi.setName("nuclei");
	Roi.setStrokeColor("green");
	run("Add to Manager");	// ROI2 --> Watershed NUCLEI
	run("Select None");
	
	// Cleanup and save segmented nuclei
	close("nucleiEdges");
	close("nucleiMask");
	close("nucleiMaxima");
	close("EDM");
	selectWindow("nucleiEdges-watershed");
	rename("nucleiMask");
	roiManager("Save", OutDir+File.separator+MyTitle_short+"_roisDAPI.zip");
}

























































































































































































































