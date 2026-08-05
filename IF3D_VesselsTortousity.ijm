function macroInfo(){

    // * Title  
    scripttitle =  "Tortuosity Analysis of 3D Vessels";
    version =  "1.01";
    date =  "07/2025";

    // *  Tests Images:
    imageAdquisition = "IF Confocal 1 Channel";
    imageType = "3D - 8 bit";
    voxelSize = "Voxel size: unknown";
    format = "Format: tiff or czi";

    // *  GUI User Requirements:
    buttom1 = "Im: Single File processing. Use Single file processing for fine tuning parameters";
    buttom2 = "Dir: Batch Mode. Please tune parameters before using Batchmode";

    //  OUTPUT
    excel = "QuantificationResults-IF3D_VesselsStructure.xls";
    feature1  = "Label";
    feature2  = "BranchLength(um)";
    feature3  = "EuclidianDistance(um)";

    // Parameters used in the macro
    parameter1 = "Morphological Dilation (3D): Ball, radius=1";
    parameter2 = "Gaussian Blur 3D: x=4, y=4, z=2";
    parameter3 = "CLAHE: blocksize=100, histogram=256, maximum=2";
    parameter4 = "Background Subtraction: rolling=125";
    parameter5 = "Ridge Detection Algorithm for branch detectio ";
    parameter6 = "small branches deleted 150pix * resolution";

    showMessage("ImageJ Script", "<html>"
        +"<h1><font size=6 color=Teal>CIMA: Imaging Platform</font></h1>"
        +"<h2><font size=5 color=Purple><i>Software Development Service</i></font></h2>"
        +"<p><font size=2 color=Purple><i>ImageJ Macros</i></font></p>"
        +"<h2><font size=3 color=black>"+scripttitle+"</font></h2>"
        +"<p><font size=2>Modified by Tomas Mu&ntilde;oz Santoro</font></p>"
        +"<p><font size=2>Version: "+version+" ("+date+")</font></p>"
        +"<p><font size=2>Contact: tmsantoro@unav.es</font></p>"
        +"<p><font size=2>Available for use/modification/sharing under the <a href='https://opensource.org/licenses/MIT/'>MIT License</a></font></p>"
        +"<h3><font size=3 color=black>Developed for</font></h3>"
        +"<p><font size=3><i>Input Images</i></font></p>"
        +"<ul><font size=2><li>"+imageAdquisition+"</li><li>"+imageType+"</li><li>"+voxelSize+"</li><li>"+format+"</li></font></ul>"
        +"<p><font size=3><i>Action tools (Buttons)</i></font></p>"
        +"<ol><font size=2><li>"+buttom1+"</li><li>"+buttom2+"</li></font></ol>"
        +"<p><font size=3><i>Parameters:</i></font></p>"
        +"<ul><font size=2>"
        +"<li>"+parameter1+"</li>"
        +"<li>"+parameter2+"</li>"
        +"<li>"+parameter3+"</li>"
        +"<li>"+parameter4+"</li>"
        +"<li>"+parameter5+"</li>"
        +"<li>"+parameter6+"</li>"
        +"</font></ul>"
        +"<p><font size=3><i>Quantification Results:</i></font></p>"
        +"<p><font size=3><i>Results file: "+excel+"</i></font></p>"
        +"<ul><font size=2>"
        +"<li>"+feature1+"</li>"
        +"<li>"+feature2+"</li>"
        +"<li>"+feature3+"</li>"
        +"</font></ul>"
        +"</html>"
    );
}



/*SINGLE FILE*/
macro "IF3D Vessels Action Tool 1  - Cf00T2d15IT6d10m"{

	close("*");
	roiManager("reset");
	run("Clear Results");
	
	macroInfo();
	
	wait(500);
	run("Collect Garbage");
	
	//just one file
	name=File.openDialog("Select File");
	openFileFormat(name);
 	InDir=getInfo("image.directory");
 	
	vessel3dTortuosity("-",InDir,name);
	
	close("\\Others");
	showMessage("QIF done!");

}

/*BATCH MODE*/
macro "IF3D Vessels Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	close("*");
	roiManager("reset");
	run("Clear Results");
		

	run("Collect Garbage");
	run("ROI Manager...");
	
	macroInfo();
	
	run("Close All");    
    InDir = getDirectory("Choose Tiles' directory");
    list = getFileList(InDir);
    L = lengthOf(list);
    
    run("Options...", "iterations=1 count=1 do=Nothing");
    RoiManager.useNamesAsLabels(false);
		
	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"tif")||endsWith(list[j],"czi")){
			
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			//setBatchMode(true);
			vessel3dTortuosity(InDir,InDir,name);
			
			}
		
		close("*");
	}
	
	showMessage("QIF done!");
}

function vessel3dTortuosity(InDir,InDir,file)
{
    /**
     * Computes tortuosity metrics of 3D vessel structures from input image stacks.
     *
     * The function performs preprocessing (morphological filtering, Gaussian smoothing, CLAHE, background subtraction),
     * ridge detection to extract vessel segments, and quantification of tortuosity by comparing branch length to
     * Euclidean distance.
     *
     * @global {string} InDir - Input directory containing the image files.
     * @global {string} file -  image file name.
     */
     
	run("Collect Garbage");
    
	roiManager("reset");
	run("Clear Results");
    
    if (InDir != "-") {
		file=InDir+name;
		openFileFormat(file);
	}else{
		openFileFormat(file);
	}
	
	MyTitle=File.nameWithoutExtension;
	
	output=getInfo("image.directory");
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	print("Processing " + MyTitle);

    // Preprocessing
    rename("orig");
    run("8-bit");
    
	setBatchMode("exit and display");
    
    run("Morphological Filters (3D)", "operation=Dilation element=Ball x-radius=1 y-radius=1 z-radius=1");
    run("Gaussian Blur 3D...", "x=4 y=4 z=2");
    getDimensions(width, height, channels, slices, frames);

    // Apply CLAHE (contrast enhancement) to each slice
    for (i = 1; i <= nSlices; i++) {
        setSlice(i);
        run("Enhance Local Contrast (CLAHE)", "blocksize=100 histogram=256 maximum=2 mask=*None* fast_(less_accurate)");
    }

    // Background subtraction
    run("Subtract Background...", "rolling=150 stack");
    //run("Morphological Filters (3D)", "operation=Erosion element=Ball x-radius=2 y-radius=2 z-radius=1");
    close("orig");
   	rename("orig");
   	close("*Dilation*");

    // Ridge detection to extract vessels
     
    waitForUser("Select reference slice");
    run("Ridge Detection");
    //run("Ridge Detection", "line_width=3 high_contrast=255 low_contrast=0 add_to_manager make_binary method_for_overlap_resolution=NONE sigma=7 lower_threshold=0 upper_threshold=0.1 minimum_line_length=50 maximum=0 stack");
	
	setBatchMode(true);

    // Rename detection window for clarity
    selectWindow("orig Detected segments");
    run("Dilate", "stack");
    run("Dilate", "stack");
    run("Dilate", "stack");
    run("Dilate", "stack");
    run("Skeletonize", "stack");

    
    rename("branches");
    run("Remove Overlay");
    saveAs("Tiff", OutDir + File.separator+MyTitle+"_BranchesMask.tif");
  	rename("branches");
  
    // Extract voxel size for physical units
    getVoxelSize(rx, ry, rz, unit);

	selectWindow("branches");
	run("Set Scale...", "distance=1 known=1 unit=µm");
	run("Select None");
	
	selectWindow("orig");
	run("Remove Overlay");
	
	selectWindow("branches");
	roiManager("reset");
	run("Analyze Particles...", "size=50-Infinity show=Masks stack in_situ");
	run("Select None");
	roiManager("Show None");


    // Initialize results arrays
    label = newArray();
    branchLabel = newArray();
    branchLength = newArray();
    euclidDist = newArray();
    tortuosityDistances = newArray();
    SOAM = newArray();
    segmentsLength = newArray();
    SOAMperLength = newArray();
    
    run("Dilate", "stack");    
    run("Analyze Particles...", "size=50-Infinity show=Masks stack add in_situ");
    n = roiManager("count"); 
	roiManager("show none");
	roiManager("Save",  OutDir + File.separator+MyTitle+"_RoiSet.zip");
	
    // Loop through detected branches
    for (i = 0; i < n; i++) {
        
        run("Select None");
        
        label[i] = MyTitle;
		
        
        selectWindow("branches");
        // Branch length (measured along the curve)
     	roiManager("select", i);
        branchLabel[i] = "branch_"+i;
        roiManager("rename", "branch_"+i);
     	run("Duplicate...", "title=singleBranch");
		setBackgroundColor(255, 255, 255);
		run("Clear Outside");
		run("Select None");
		run("Connected Components Labeling", "connectivity=8 type=[8 bits]");
		run("Keep Largest Label");
		selectWindow("singleBranch-lbl-largest");
		rename("branch");
		close("single*");
		run("Skeleton Geodesic Diameter", "input=branch chamfer=[Chessknight (5,7,11)] show image=branch");
		IJ.renameResults("Results");
		
		// Extract coordinates of ROI
 	    Overlay.activateSelection(0);
 	    getSelectionCoordinates(x, y);

 	    npts = lengthOf(x);
 	    //print(npts);
 	    
 	    // First and last points of the ROI
        x_first = getResult("Extremity1.X", 0); 
        y_first = getResult("Extremity1.Y", 0);
        x_last  = getResult("Extremity2.X", 0);
        y_last = getResult("Extremity2.Y", 0);
	 	geodesicDistance = getResult("GeodesicDiameter", 0);
	 	run("Clear Results");
				
		/* First and last points of the ROI
        x_first = x[0] 
        y_first = y[0];
        x_last  = x[npts-1];
        y_last = y[npts-1];
	 	*/   		
		
		// Euclidean distance between endpoints
        dx = x_last - x_first;
        dy = y_last - y_first;
        euclidDist[i] = sqrt(dx*dx + dy*dy) * rx;
       	
       	branchLength[i]=geodesicDistance*rx;
       	
       	//print(euclidDist[i]);
       	//print(geodesicDistance);
       	//makeLine(x_first, y_first, x_last, y_last);
		//waitForUser;
		
		
		run("Clear Results");
		
		// TORTUOSITY METRICS: DISTANCE AND SUM OF ANGLES
       	//roiManager("select", i);
		//run("Fit Spline");
		//getSelectionCoordinates(x, y);
		tortuosityDistances[i] = d2s(branchLength[i]/euclidDist[i],3);
		//print(branchLength[i]);
		//print(euclidDist[i]);
		//print(tortuosityDistances[i]);
		
		vals = computeSOAM_fromXY("branch",x, y, rx, ry);
		SOAM[i] = vals[0];
		segmentsLength[i] = vals[1];
		SOAMperLength[i] = d2s(vals[0]/vals[1],4);
		/*
		print(SOAM[i]);
		print(segmentsLength[i]);
		print(branchLength[i]);
		*/
		
		close("branch");
		
    }
    
	run("Clear Results");
	close("Results");
			
    setBatchMode("exit and display");
	
    // Append to or create results file
    resultsFile = output +File.separator+MyTitle+"_IF3D_VesselsStructure.xls";

    if (File.exists(resultsFile)) {
        open(resultsFile);
     	IJ.renameResults("Results");
        pos = nResults;
        for (v = 0; v < lengthOf(SOAMperLength); v++) {
            setResult("[Label]", pos+v, label[v]);
            setResult("[Branch Label]", pos+v, branchLabel[v]);
            setResult("BranchLength(um)", pos+v, branchLength[v]);
            setResult("EuclidianDistance(um)", pos+v, euclidDist[v]);
            setResult("Length/Euclidean Distance", pos+v, tortuosityDistances[v]);
            setResult("SumOfAngles", pos+v, SOAM[v]);
       		setResult("SumOfAnglesPerLength", pos+v, SOAMperLength[v]);
       
        }
     
    }else{
    	
		// Create results table for current image    
		Table.create("vectorAnalysis");
		Table.setColumn("[Label]", label);
		Table.setColumn("[Branch Label]",branchLabel);
		Table.setColumn("BranchLength(um)", branchLength);
		Table.setColumn("EuclidianDistance(um)", euclidDist);
		Table.setColumn("Length/Euclidean Distance", tortuosityDistances);
		Table.setColumn("SumOfAngles", SOAM);
		Table.setColumn("SumOfAnglesPerLength",SOAMperLength);
		Table.update;
    	
    	selectWindow("vectorAnalysis");
        IJ.renameResults("Results");
    }

    // Save results
    saveAs("Results", resultsFile);
    close(MyTitle+"_IF3D_VesselsStructure.xls");
    close("Results");
    
    selectWindow("orig");
    saveAs("Tiff", OutDir + File.separator+MyTitle+"_Analyzed.tif");
    
    run("Z Project...", "projection=[Max Intensity]");
    run("Remove Overlay");
    saveAs("Tiff", OutDir + File.separator+MyTitle+"_ZProjection.tif");
    
    setBatchMode("exit and display");
    
    
}

function computeSOAM_fromXY(image,xpoints, ypoints, rx, ry) {
	
	//run("Fit Spline");
	//
    //getSelectionCoordinates(xpoints, ypoints);
    //Roi.getSplineAnchors(xpoints, ypoints);
    //getVoxelSize(rx, ry, rz, unit);

	selectWindow(image);
	Overlay.activateSelection(0);
	getSelectionCoordinates(xpoints, ypoints);
	getVoxelSize(rx, ry, rz, unit);
	
	// compute SOAM from selection coordinates (2D). Assumes rx, ry are set (µm/pixel)
    // compute segment vectors in physical units
    nCoor = lengthOf(xpoints);
	//print(nCoor);
	
	dxy = 15;
	//dxy = round(3/rx);
	//print(dxy);
	
	//dxy = 5;
	nPoints = floor(nCoor/dxy);
	//print(nPoints);
	
 	soam = 0.0;
    pathLen = 0.0;
    validSegments = 0;
	
	//segmentsLength = newArray();
	/*
	for (j = 0; j < nPoints-1; j++) {
		
		t1x = (xpoints[(j+1)*dxy] - xpoints[j*dxy]) * rx;
        //print(t1x);
        t1y = (ypoints[(j+1)*dxy] - ypoints[j*dxy]) * ry;
        //print(t1y);
        t1Len = sqrt(t1x*t1x + t1y*t1y);
        //print(t1Len);
        
        if (t1Len > 0){
        	validSegments++;
        }
	}
	*/
	
	// sum absolute turning angles
	
	for (j = 0; j < nPoints-2; j++) {

		t1x = (xpoints[(j+1)*dxy] - xpoints[j*dxy]) * rx;
		//print(t1x);
		t1y = (ypoints[(j+1)*dxy] - ypoints[j*dxy]) * ry;
		//print(t1y);
		t1Len = sqrt(t1x*t1x + t1y*t1y);
		//print(t1Len);
		makeLine(xpoints[(j+1)*dxy], ypoints[(j+1)*dxy], xpoints[j*dxy], ypoints[j*dxy]);

				
		t2x = (xpoints[(j+2)*dxy] - xpoints[(j+1)*dxy]) * rx;
		//print(t2x);
		t2y = (ypoints[(j+2)*dxy] - ypoints[(j+1)*dxy]) * ry;
		//print(t2y);
		t2Len = sqrt(t2x*t2x + t2y*t2y);
		//print(t2Len);
		//makeLine(xpoints[(j+2)*dxy], ypoints[(j+2)*dxy], xpoints[(j+1)*dxy], ypoints[(j+1)*dxy]);

 		// normalized dot product
    	// theta = arcos (dotProduct(a,b)/(|a||b|))
    	dot = t1x*t2x + t1y*t2y;
    	cosv = dot / (t1Len * t2Len);
    	if (cosv > 1) {
    		cosv = 1;
    	}else if (cosv < -1){
    		cosv = 1;
    	}
    	
    	theta = acos(cosv); // radians
    	//print(theta);
    	soam = soam + abs(theta);
    	
	    //segmentsLength[j] = t1Len;
        pathLen = pathLen + t1Len;
    	
    	/*	
    	print(cosv);
    	print(theta);
    	print(soam);
    	print(pathLen);
		*/

    	
	}
	

	return newArray(soam,pathLen);
}




function openFileFormat(file){
			
	if(endsWith(file,".jpg")||endsWith(file,".tif")){
		if (!endsWith(file,"ome.tif")){
			open(file);
		}else{
			run("Bio-Formats", "open=["+file+"] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
		}
	}else if(endsWith(file,".czi") || endsWith(file,".svs") || endsWith(file,"ome.tif")){
		//run("Bio-Formats Importer", "open=["+file+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
		run("Bio-Formats", "open=["+file+"] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
	}
}	







