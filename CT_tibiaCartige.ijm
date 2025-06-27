function macroInfo(){

	/* AUTOMATIC TIBIA CARTILAGE QUANTIFICATION;
		
		Target User: Fermin Milagro
	
		scripttitle= "AUTOMATIC TIBIA CARTILAGE QUANTIFICATION";
		version= "1.03";
		date= "27/06/2023";
			
		  Tests Images:
	
		imageAdquisition="microCT : 1 channel images.";
		imageType="16bit";  
		voxelSize="Voxel size:  20um";
		format="Format: .tiff";   
	 
	   GUI User Requierments:
	     - Choose parameters.
	     - Single File and Batch Mode
	     
	   Important Parameters: click Im or Dir + right button 
	 			 
	   Action tools:
		
		button1="Automatic Cartilage Segmentation and Quantification of Cartilage";
		button2="Manual Selection of Lateral an Medial Condyles ROIs 0.6x1.2 mm. whithin previously calculated ThicknessMap. From ROIs quantify - mean, std, max and min Thickness."
		button3="Plot mean Thickness Profile across 1,1 mm"
			
		
	   OUTPUT
	
		setResult("Label", i, MyTitle); 
		setResult("Tibia axial size (mm2)", i, tibiaHeadSize);
		setResult("Cartilage Volume (mm3)", i, cartilageVol); 
		setResult("Cartilage MeanIntensity (Hounsfield)", i, meanIntensity);
	
		setResult("Label", i, MyTitle); 
		setResult("LateralCondyle_meanThickness", i, meanLCondyle); 
		setResult("LateralCondyle_stdThickness", i, stdLCondyle);
		setResult("LateralCondyle_maxThickness", i, maxLCondyle); 
		setResult("LateralCondyle_minThickness", i, minLCondyle);
		
		setResult("MedialCondyle_meanThickness", i, meanMCondyle); 
		setResult("MedialCondyle_stdThickness", i, stdMCondyle);  
		setResult("MedialCondyle_maxThickness", i, maxMCondyle); 
		setResult("MedialCondyle_minThickness", i, minMCondyle);
		
		saveAs("Results", output+File.separator+"TIBIAS_cartilageThickness.xls");
	
	   Analyzed Images with ROIs
	
		 	  
	 *  version: 1.02 
	 *  Author: Tomas  
	 *  Commented by: Tomas Muñoz 2023 
	 *  Date : 2023
	 *  
	
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
	    +"<p><font size=3  i>PARAMETERS: Right Click on Action tool  </i></p>"
	    +"<ul id=list-style-3><font size=2  i>"
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li>"
	    +"<li>"+feature5+"</li><li>"+feature6+"</li><li>"+feature7+"</li><li>"+feature8+"</li>"
	    +"<li>"+feature9+"</li><li>"+feature10+"</li><li>"+feature11+"</li><li>"+feature12+"</li><li>"+feature13+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");
*/

var maxCartilageThickness=4; //in pixels
var voxelSize=0.02; 		// mm
var ID=getImageID();

/* MAIN BUTTON FOR DETECTION AND QUANTIFICATION 
Automatic Cartilage Segmentation and Quantification of Cartilage: 
 * 	  		Volume mm^3 and Mean Intensity 16 bits.
 * 	  		Creation of Local ThicknessMaps. in mm.
 * 	  		(InterSample Calibration with max 2mm thickness tube).
 */

macro "tibiaCartilage Action Tool 1 - C0f0T4d15Tio"{

	//InDir="F://TMSANTORO/0_USUARIOS_PLATAFORMA/INTERNOS/0_UNAV/Fermin_Milagro/2024_Cuantificacion_Cartílago/TIBIAS_18112024/";
	
 	// Initialize batch processing by asking the user to select a directory
    InDir = getDirectory("Choose a Directory"); 
    list = getFileList(InDir);  // Get the list of files in the directory
    L = lengthOf(list);         // Count the number of files
    
	
	 // Loop through each file in the directory (currently configured for testing with only one file)
    for (j = 0; j < L; j++) {  
      
      	close("*");               // Close all open windows
        roiManager("Reset");      // Reset ROI Manager
        run("Clear Results");     // Clear any previous results
        run("Select None");       // Ensure no ROI is selected
        run("Colors...", "foreground=black background=white selection=green"); // Set visual display properties

		print(list[j]);
		
        // Open the next image file if it has a .tif extension
        if (endsWith(list[j], ".tif")) { 
         	
			 // File and output directory initialization
	        filePath = InDir + list[j]; 
	        
	        openFileFormat(filePath); 
	        MyTitle = getTitle();     // Extract the image title
	        aa = split(MyTitle, "."); 
	        temp = aa[0];             // Remove the file extension
	        aaa = split(temp, "_");
	        MyTitle_short = aaa[0];   // Shortened title for labeling
	
	        // Create an output directory specific to the current image
	        output = getInfo("image.directory");
	        OutDir = output + temp + "_Results";
	        File.makeDirectory(OutDir); 
	        print(OutDir);
	
	        // Prepare array for file-related metadata
	        fileDirs = newArray(OutDir, MyTitle, MyTitle_short, output);
	        showStatus("FileSelected"); 
	        print(MyTitle_short);
	
			selectWindow(MyTitle); 
			
			// Preprocessing: Remove ringing artifacts using background subtraction
	        setSlice(floor(nSlices / 2)); 
	        //run("Subtract Background...", "rolling=25 stack");
	        
	        backgroundSubstract3DGPU(MyTitle,50);
			
			//waitForUser("1");
			
	        // **Cartilage Segmentation**
	        // Generate masks for the inner and outer cartilage boundaries
	        innerBoneMask(MyTitle+"_subBckg"); // Generate inner cartilage edge mask (inner bone boundary)
	
			selectWindow("innerTibiaMask"); 
	        run("Duplicate...", "title=outerTibiaMask duplicate"); 
	        outerCartilageMask("iMap", "outerTibiaMask"); 
	        
	    	//waitForUser("2");
	    
	        // Mask cartilage by subtracting inner cartilage from outer cartilage
	        imageCalculator("Subtract create stack", "outerTibiaMask", "innerTibiaMask"); 
	        rename("cartilageMask"); 
	        selectWindow(MyTitle+"_subBckg"); 
	        run("Duplicate...", "title=cartilageFat duplicate"); 
	        selectWindow("cartilageMask"); 
	        run("Divide...", "value=255 stack");
	        imageCalculator("Multiply create stack", "cartilageFat", "cartilageMask");
	        selectImage("Result of cartilageFat"); 
	        setSlice(floor(nSlices / 2)); 
	        resetMinAndMax();
	        rename("cartilage");
			
			waitForUser("3");
					
			 // Threshold cartilage image to isolate relevant regions
	        selectWindow("cartilage"); 
	        setAutoThreshold("Default dark no-reset stack"); 
	        getThreshold(lower, upper); 
	        setThreshold(1000, upper); 
	        waitForUser;
	        setOption("BlackBackground", false); 
	        run("Convert to Mask", "method=Default background=Dark"); 
	        close("Result*"); 
	        close("*Fat");
			
			//waitForUser("9");
			
			// Save intermediate results for cartilage segmentation
	        run("Duplicate...", "title=cartilageEdges duplicate");
	        run("Find Edges", "stack"); 
	        run("Binary Overlay", "reference=[" + MyTitle+"_subBckg" + "] binary=cartilageEdges overlay=Red"); 
	        saveAs("Tiff", OutDir + File.separator + MyTitle + "_cartilage.tif"); 
	        close(MyTitle + "_cartilage.tif");
			
			 // **Cartilage Quantification**
	        run("Clear Results"); 
	        close("Results"); 
	        run("Set Measurements...", "area mean display redirect=None decimal=2");

	        // Measure cartilage properties for each slice
	        selectWindow("cartilage"); 
	        run("Select None");
	        for (i = 1; i <= nSlices; i++) {
	            selectWindow("cartilage"); 
	            setSlice(i); 
	            run("Create Selection"); 
	            type = selectionType(); 
	            if (type != -1) {
	                selectWindow(MyTitle+"_subBckg"); 
	                setSlice(i); 
	                run("Restore Selection"); 
	                run("Measure");
	            }
	        }
				
			// Summarize mean intensity of the cartilage
	        pos = nResults; 
	        run("Summarize");
	        meanIntensity = getResult("Mean", pos); 
	        print(meanIntensity);
				
			//waitForUser("10");
			
	        // Measure the size of the tibia's head for normalization
	        run("Clear Results"); 
	        close("Results");
	        run("Set Scale...", "distance=1 known=1 unit=pixel"); 
	        selectWindow("innerTibiaMask");
	        run("Z Project...", "projection=[Max Intensity]");
	        run("Create Selection");
	
			voxelSize = 0.02; // Voxel size in mm
	        tibiaHeadSize = getValue("Area");
	        tibiaHeadSize = tibiaHeadSize * Math.pow(voxelSize, 2); // Convert to mm²
	        print(tibiaHeadSize);
	
	        // Calculate cartilage volume
	        run("Clear Results"); 
	        close("Results"); 
	        selectWindow("cartilage");
	        run("Select None");
	        run("Analyze Particles...", "size=0-Infinity pixel show=Masks display in_situ stack");
	        slices = nResults; 
	        run("Summarize");
	        meanArea = getResult("Area", slices);
	        cartilageVol = meanArea * slices * Math.pow(voxelSize, 3); // Convert to mm³
	        	        
			
			 // Generate and save a 2D thickness map
			resliceTop("cartilage");
			getDimensions(width, height, channels, slices, frames);
			makePoint(0+20, 20);
			run("Enlarge...", "enlarge="+5);
			setForegroundColor(0,0,0);
			run("Fill","stack");
			setForegroundColor(255,255,255);
			run("Select None");
			
			//Compute Local Thickness
			selectWindow("cartilage");
			run("Local Thickness (complete process)", "threshold=1");
			run("Multiply...", "value=0.02 stack"); //Local thickness result is in pixel by default
			rename("thicknessMap");
			run("Reslice [/]...", "output=1.000 start=Top avoid");
			run("Z Project...", "projection=[Max Intensity]");
			run("Fire");
			saveAs("Tiff", OutDir+File.separator+MyTitle+"_2DthicknessMap.tif");
			run("Calibration Bar...", "location=[Upper Left] fill=Black label=White number=5 decimal=3 font=12 zoom=1");
			saveAs("Tiff", OutDir+File.separator+MyTitle+"_2DthicknessMapCalibrated.tif");
							
			 // Save all quantification results to an Excel file
	        print("Saving values in :" + output); 
	        run("Clear Results"); 
	        if (File.exists(output + File.separator + "TIBIAS_cartilageThickness.xls")) {
	            open(output + File.separator + "TIBIAS_cartilageThickness.xls");
	            IJ.renameResults("Results");
	        }
	        i = nResults;
	        setResult("[Label]", i, MyTitle); 
	        setResult("Tibia axial size (mm2)", i, tibiaHeadSize); 
	        setResult("Cartilage Volume (mm3)", i, cartilageVol); 
	        setResult("Cartilage MeanIntensity (Hounsfield)", i, meanIntensity); 
	        saveAs("Results", output + File.separator + "TIBIAS_cartilageThickness.xls");
	
			/*
		    // Generate 3D projection of the thickness map
	        print("Saving images in :" + OutDir); 
	        selectWindow("thicknessMap");
	        run("3D Project...", "projection=[Brightest Point] axis=X-Axis slice=1 initial=0 total=360 rotation=10 lower=1 upper=255 opacity=0 surface=100 interior=50");
	        saveAs("Tiff", OutDir + File.separator + MyTitle + "_3DthicknessMap.tif");
			*/
			/*
			//thicknessMap
			selectWindow("Reslice of thicknessMap");
			resliceTop("thicknessMap");
			saveAs("Tiff", OutDir+File.separator+MyTitle+"_StackThicknessMap.tif");	
			*/
			
			// Reset for the next iteration
	        close("*"); 
	        roiManager("Reset"); 
	        run("Clear Results"); 
	        run("Select None"); 
	        run("Colors...", "foreground=black background=white selection=green");
		}
		
		//waitForUser;
    }
    
}

/*
 * 	  - Manual Selection of Lateral an Medial Condyles ROIs 0.6x1.2 mm. whithin
 * 	    Previously calculated ThicknessMap. 
 * 	  		From ROIs quantify - mean, std, max and min Thickness.
*/

macro "tibiaCartilage Action Tool 2 - C0f0T4d15Cio"{

	InDir=getDirectory("Choose a Directory");
	list=getFileList(InDir);
	L=lengthOf(list);
	Array.print(list);

	for (j = 0; j < L; j++) {

		close("*");
		roiManager("Reset");
		run("Clear Results");
		run("Select None");
		run("Colors...", "foreground=black background=white selection=green");
		run("Set Measurements...", "area mean standard min display redirect=None decimal=5");

		//OpenFile single File 
		filePath=InDir+list[j];
		print(filePath);
	

		
		if(endsWith(list[j],".jpg")||endsWith(list[j],".tif")){
		
			openFileFormat(filePath);

			MyTitle=getTitle();
			aa = split(MyTitle,".");
			temp = aa[0];
			aaa = split(temp,"_");
			MyTitle_short = aaa[0];
		
			output=getInfo("image.directory");
			OutDir = output+temp+"_Results";
			thicknesMapDir=OutDir+File.separator+list[j]+"_2DthicknessMap.tif";
			print(thicknesMapDir);
			openFileFormat(thicknesMapDir);
			thicknessMapTitle=getTitle();
			
			selectWindow(thicknessMapTitle);
			run("Set Scale...", "distance=1 known=0.02 unit=mm");
			run("Options...", "iterations=1 count=1 do=Nothing");
			run("Colors...", "foreground=black background=white selection=green");
			
			getDimensions(width, height, channels, slices, frames);
				
			//measure Lateral Condyle	
			selectWindow(thicknessMapTitle);
			getDimensions(width, height, channels, slices, frames);
			makeRectangle(width/2, height/2, 60, 40);
			waitForUser("Move the ROI to the LATERAL Condyle and press OK");
			run("Rotate...");
			waitForUser("Move the ROI to the LATERAL Condyle and press OK");
			Roi.setName("LateralCondyle");
			Overlay.addSelection;
			roiManager("add");
	
	
			//Measure Medial Condyle
			selectWindow(thicknessMapTitle);
			makeRectangle(width/2, height/2, 60, 40);
			waitForUser("Move the ROI to the MEDIAL Condyle and press OK");
			run("Rotate...");
			waitForUser("Move the ROI to the MEDIAL Condyle and press OK");
			Roi.setName("MedialCondyle");
			Overlay.addSelection;
			roiManager("add");
		
			RoiManager.select(0);
			meanLCondyle=getValue("Mean");
			stdLCondyle=getValue("StdDev");
			maxLCondyle=getValue("Max");
			minLCondyle=getValue("Min");
			print("Lateral Condyle :");
			print("MeanThickness :"+meanLCondyle);
			print("stdThickness :"+stdLCondyle);
	
			RoiManager.select(1);
			meanMCondyle=getValue("Mean");
			stdMCondyle=getValue("StdDev");
			maxMCondyle=getValue("Max");
			minMCondyle=getValue("Min");
			print("Lateral Condyle :");
			print("MeanThickness :"+meanMCondyle);
			print("stdThickness :"+stdMCondyle);
			
			//Save Images
			RoiManager.useNamesAsLabels(true);
			print("Saving images in :"+OutDir);
			selectWindow(thicknessMapTitle);
			roiManager("Show All with labels");
			run("Flatten");
			saveAs("Tiff", OutDir+File.separator+MyTitle+"_CondylesROIS.tif");	
			close("*");
	
			//Save Results
		
			print("Saving values in :"+output);
			run("Clear Results");
			if(File.exists(output+File.separator+"TIBIAS_CondylesThickness.xls"))
			{	
				//if exists add and modify
				open(output+File.separator+"TIBIAS_CondylesThickness.xls");
				IJ.renameResults("Results");
			}
			i=nResults;
			setResult("[Label]", i, MyTitle); 
			setResult("LateralCondyle_meanThickness", i, meanLCondyle); 
			setResult("LateralCondyle_stdThickness", i, stdLCondyle);
			setResult("LateralCondyle_maxThickness", i, maxLCondyle); 
			setResult("LateralCondyle_minThickness", i, minLCondyle);
			
			setResult("MedialCondyle_meanThickness", i, meanMCondyle); 
			setResult("MedialCondyle_stdThickness", i, stdMCondyle);  
			setResult("MedialCondyle_maxThickness", i, maxMCondyle); 
			setResult("MedialCondyle_minThickness", i, minMCondyle);
			
			selectWindow("Results");	
			saveAs("Results", output+File.separator+"TIBIAS_CondylesThickness.xls");

			close("*");			
		}
	}
}

/*   - Plot mean Thickness Profile across 0.6 mm.*/

macro "tibiaCartilage Action Tool 3 - C0f0T4d15Pio"{

	close("*");
	roiManager("Reset");
	run("Clear Results");
	run("Select None");
	run("Colors...", "foreground=black background=white selection=green");
	run("Set Measurements...", "area mean standard min display redirect=None decimal=5");
		
	name=File.openDialog("Select File");
	
	if(endsWith(name,".jpg") || endsWith(name,".tif")){
		
		openFileFormat(name);

		thicknessMapTitle=getTitle();
		aa = split(thicknessMapTitle,".");
		Array.print(aa);
		rename("thicknessMap");
		
		condylesFile=aa[0]+"."+aa[1]+".tif_CondylesROIS.tif";
		openFileFormat(condylesFile);
		
		temp = aa[0];
		aaa = split(temp,"_");
		thicknessMapTitle_short = aaa[0];
	
		output=getInfo("image.directory");
	
		selectWindow("thicknessMap");

		waitForUser("Container Box");
		run("Rotate... ");
		run("Select None");

		run("Abs");
		run("Multiply...", "value=1000");
		//run("Brightness/Contrast...");
		run("Enhance Contrast", "saturated=0.35");
		run("Calibration Bar...", "location=[Upper Left] fill=Black label=White number=5 decimal=1 font=12 zoom=1 overlay");
		
		//ROI
		getDimensions(width, height, channels, slices, frames);
		makeRectangle(width/3, height/2, 180, 50);
		waitForUser("Move the ROI");
			
		Roi.getCoordinates(xpoints, ypoints);
		run("Select None");
		width=xpoints[1]-xpoints[0];
		height=ypoints[3]-ypoints[0];
		roiMeanProfile=newArray(width);
		roiStdProfile=newArray(width);
		xAxis=newArray(width);
		x=xpoints[0];
		for (i = 0; i < width-1; i++) {
			xAxis[i]=x-xpoints[0];
			x+=20;
	    	makeLine(xpoints[0]+i, ypoints[0], xpoints[3]+i, ypoints[3]);
	    	currentProfile=getProfile();
			Array.getStatistics(currentProfile, min, max, mean, stdDev);
			roiMeanProfile[i]=mean;
			if (i/2-floor(i/2)!=0){
				roiStdProfile[i]=stdDev;	
			}else{
				roiStdProfile[i]=0;
			}
			
		}
		
		Plot.create("ROI Thickness", "Medial -----------> Lateral (microns)", "mean Thickness (microns)");
		Plot.add("line", xAxis, roiMeanProfile);
		Plot.setLegend("meanThickness", "top-right");
		Plot.add("error bars",roiStdProfile);
		Plot.setLegend("+/- std", "top-right");
	    Plot.show();
	    saveAs("Tiff", output+File.separator+thicknessMapTitle+"_ProfilePlot.tif");	

	    selectWindow("thicknessMap");
	    //run("Crop");
	    makeRectangle(xpoints[0],ypoints[0], width, height);
	    Overlay.addSelection;
	    run("Flatten");
	    saveAs("Tiff", output+File.separator+thicknessMapTitle+"Calibrated");	


	}
}

/* Functions Level 1
 *  file info
 *  innerBoneMask
 *  outerCartilageMask
 */


function fileInfo(name){ 
	
	// Function to handle file selection, metadata extraction, and output directory preparation.
	
    // Reset environment: close all windows, clear ROIs, and clear results.
    run("Close All");
    roiManager("Reset");
    run("Clear Results");

    // Prompt user to select a file and extract metadata from its name.
    filePath = File.openDialog("Select File");
    openFileFormat(filePath);
    MyTitle = getTitle();
    aa = split(MyTitle, ".");
    temp = aa[0];
    aaa = split(temp, "_");
    MyTitle_short = aaa[0];

    // Create a specific output directory for storing results related to the selected file.
    output = getInfo("image.directory");
    OutDir = output + temp + "_Results";
    File.makeDirectory(OutDir);
    print(OutDir);
    
    // Return an array containing the output directory and file metadata for further processing.
    fileDirs = newArray(OutDir, MyTitle, MyTitle_short, output);
    showStatus("FileSelected");
    print(MyTitle_short);  

    return fileDirs;
}



function getTibiaHead(innerTibiaMask) {
	
	// Function to define and extract the tibia head region based on the inner tibia mask	
	

    selectWindow(innerTibiaMask);
    Stack.getDimensions(width, height, channels, slices, frames); // Get image dimensions

    // Find the top slice of the tibia by checking for a valid selection
    for (i = 1; i < slices+1; i++) {
        selectWindow(innerTibiaMask);
        setSlice(i);
        run("Create Selection");
        type = selectionType();  
        if (type != -1) { // Valid selection found, set as top slice
            top = i;
            break;
        }
    }

    run("Select None");
    top3 = top-20; // Set the slice range for the tibia head
 	if (top3 <= 0){
 		top3=top-10;
	}
	if (top3 <= 0){
 		top3=top-10;
 	}
 	if (top3 <= 0){
 		top3=top-5;
 	}
 	if (top3 <= 0){
 		top3=top-2;
 	}
 	if (top3 <= 0){
 		top3=top;
 	}
 	 	
 	print(top);
 	
	getDimensions(width, height, channels, slices, frames);
	
    bottom = top + 40; // IMPORTANT: Bottom slice index
 	if (bottom >= slices){
 		bottom = top + 35;
	}
	if (bottom >= slices){
 		bottom = top + 30;
	}
    
    run("Make Substack...", "delete slices=" + top3 + "-" + bottom); 
    
	
    close(innerTibiaMask); 
    selectWindow("Substack (" + top3 + "-" + bottom + ")");
    rename(innerTibiaMask); 

    resliceTop(innerTibiaMask); // Reslice the tibia head stack from coronal to axial

    // Find the lateral edge slice of the tibia mask
    Stack.getDimensions(width, height, channels, slices, frames);
    for (i = 1; i < slices+1; i++) {
        selectWindow(innerTibiaMask);
        setSlice(i);
        run("Create Selection");
        type = selectionType();  
        if (type != -1) { // Valid selection found, set as lateral edge slice
            lateralEdge = i;
            break;
        }
    }
	
	
 	print(lateralEdge);
	
	
    run("Select None"); 
    lateralEdge3 = lateralEdge - 40; // Set the slice range for the lateral tibia edge
    medialEdge = lateralEdge + 200; // Set the slice range for the medial tibia edge
    run("Make Substack...", "delete slices=" + lateralEdge3 + "-" + medialEdge); 
    
	
    close(innerTibiaMask); 
    selectWindow("Substack (" + lateralEdge3 + "-" + medialEdge + ")");
    rename(innerTibiaMask); 
    
    resliceTop(innerTibiaMask); // Reslice the lateral tibia region from coronal to axial

    // Store the indices for the substack slices and return them
    subStackIndex = newArray(top3, bottom, lateralEdge3, medialEdge);

    return subStackIndex; // Return the substack slice indices
}



function innerBoneMask(image){

	selectWindow(image);
	
	//Thresholding Tissue
	run("Duplicate...", "title=TibiaMask duplicate");
	setAutoThreshold("Default dark stack");
	//run("Threshold...");
	getThreshold(lower, upper);
	setThreshold(1500, upper);
	waitForUser;
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark");
	run("Median...", "radius=1 stack");
	run("Analyze Particles...", "size=1000-Infinity pixel show=Masks in_situ stack");
	
	/*Obtain InnerMask
	 * Mask Operations Close open edges. XY
	*/
	
	selectWindow("TibiaMask");
	run("Duplicate...", "title=fullTibiaMask duplicate");
	run("Fill Holes","stack");
	run("Duplicate...", "title=joinedTibiaMask duplicate");
	run("Invert","stack");
	run("Watershed", "stack");
	imageCalculator("XOR create stack","joinedTibiaMask","fullTibiaMask");
	run("Invert","stack");
	run("Analyze Particles...", "size=0-Infinity pixel show=Masks in_situ exclude stack");
	rename("linesXY");
	close("full*");
	close("joined*");
	imageCalculator("OR create stack", "TibiaMask","linesXY");
	selectWindow("Result of TibiaMask");
	rename("Tibia");
	close("*Mask");
	selectWindow("Tibia");
	run("Invert","stack");
	setOption("BlackBackground", false);
	//run("Erode", "stack");
	run("Analyze Particles...", "size=500-25000 pixel show=Masks in_situ exclude stack");

	
	
	/* Label 3D partigles -> larger correspond to inner bone  
	*/
		
	waitForUser;
	selectWindow("Tibia");
	run("Dilate", "stack");
	run("3D Distance Map", "map=EDT image=Tibia mask=Same threshold=0");
	setOption("ScaleConversions", true);
	run("8-bit");
	//setAutoThreshold("Otsu dark stack");
	setThreshold(175, 255);
	run("Convert to Mask", "method=Otsu background=Dark");
	run("3D Watershed Split", "binary=Tibia seeds=EDT radius=2");
	close("MAILLY");
	close("EDT");
	close("Tibia");
	selectWindow("Split");
	
	waitForUser;
	
	run("Keep Largest Label");
	close("Split");
	selectWindow("Split-largest");
	rename("innerTibiaMask");
	setAutoThreshold("Default dark");
	//run("Threshold...");
	setThreshold(1, 255);
	run("Convert to Mask", "background=Dark");
		
	// Determine the Tibia's head x slices max
	subStackIndex=getTibiaHead("innerTibiaMask");
	top=subStackIndex[0];
	bottom=subStackIndex[1];
	lateralEdge=subStackIndex[2];
	medialEdge=subStackIndex[3];

	//crop in Z
	selectWindow(image);
	run("Make Substack...", "delete slices="+top+"-"+bottom);
	close(image);
	selectWindow("Substack ("+top+"-"+bottom+")");
	rename(image);

	//crop in X
	resliceTop(image);
	run("Make Substack...", "delete slices="+lateralEdge+"-"+medialEdge);
	close(image);
	selectWindow("Substack ("+lateralEdge+"-"+medialEdge+")");
	rename(image);
	resliceTop(image);
		

	selectWindow("linesXY");
	selectWindow("linesXY");
	run("Make Substack...", "delete slices="+top+"-"+bottom);
	close("linesXY");
	selectWindow("Substack ("+top+"-"+bottom+")");
	rename("linesXY");

	//crop in X
	resliceTop("linesXY");
	run("Make Substack...", "delete slices="+lateralEdge+"-"+medialEdge);
	close("linesXY");
	selectWindow("Substack ("+lateralEdge+"-"+medialEdge+")");
	rename("linesXY");
	resliceTop("linesXY");
	
	/* Complete the mask with level sets xy and z 
	 */

	//AXIAL
	selectWindow(image);
	run("Duplicate...", "title=iMap duplicate");
	run("8-bit");
	setSlice(floor(nSlices/2));
	run("Enhance Contrast", "saturated=0.7");
	//setMinAndMax(25, 255);
	run("Apply LUT","stack");
	imageCalculator("Add create stack", "iMap","linesXY");
	close("iMap");
	selectWindow("Result of iMap");
	rename("iMap");
	//enhance edges while smoothing intensities 
	run("Kuwahara Filter", "sampling=2 stack");
	
	close("linesXY"); 
	activeContoursOutside("iMap","innerTibiaMask",7);
	
	//CORONAL
	resliceTop("iMap");
	resliceTop("innerTibiaMask");
	activeContoursOutside("iMap","innerTibiaMask",7);
	addBorder("innerTibiaMask");
	
	//Back to axial
	resliceTop("iMap");
	resliceTop("innerTibiaMask");
	activeContoursOutside("iMap","innerTibiaMask",4);
	
	run("3D Draw Rois", "raw=iMap seg=innerTibiaMask display");
	close("DUP*");
	selectWindow("LabelRoi");
	run("8-bit");
	run("Make Binary","Method=Black");
	run("Invert","stack");
	run("Analyze Particles...", "size=0-Inf show=Masks exclude in_situ stack");
	run("Fill Holes","stack");
	close("innerTibiaMask");
	selectWindow("LabelRoi");
	rename("innerTibiaMask");
		
				
}



/* Functions Level 2
 *  getTibiaHead
 *  activeContoursOutside
 *  activeContoursInside
 *  resliceTop
 *  openFileFormat
 */


// Function to generate an outer cartilage mask based on an input iMap.

function outerCartilageMask(iMap, outerTibiaMask) {

    maxCartilageThickness = 4; // Set the maximum cartilage thickness to 4 pixel units)

    // AXIAL: Apply active contours to define the cartilage region inside the tibia mask
    activeContoursInside(iMap, outerTibiaMask, maxCartilageThickness);
    //mask3DConvexHull(outerTibiaMask);

    // CORONAL: Reslice images to coronal view and apply active contours to the tibia mask
    resliceTop(iMap); 
    resliceTop(outerTibiaMask);
  	maxCartilageThickness = 6;
    activeContoursInside(iMap, outerTibiaMask, maxCartilageThickness); // Apply active contours on coronal view
    //mask3DConvexHull(outerTibiaMask);
	
    // Add a border to the outer tibia mask
    addBorder(outerTibiaMask); 

    // BACK TO AXIAL: Reslice back to axial view for further processing
    resliceTop(iMap);
    resliceTop(outerTibiaMask);

}



function activeContoursOutside(iMap, innerTibiaMask, grayscale) {
	
		// Function to apply active contour segmentation outside the tibia mask using the iMap.
		
		setBatchMode(true); // Enable batch mode for faster processing
		
		//waitForUser("active1");
		
		//iMap="iMap";
		//innerTibiaMask="innerTibiaMask";
		//grayscale=7;
		
		 // Select the inner tibia mask for processing
	    selectWindow(innerTibiaMask);
	    Stack.getDimensions(width, height, channels, slices, frames); // Get image dimensions
	    run("Duplicate...", "title="+"innerTibiaMask"+"temp duplicate"); // Duplicate the tibia mask

		 // Set foreground and background colors for contouring
	    setBackgroundColor(0,0,0);
	    setForegroundColor(255,255,255);
		
		// Loop through each slice of the image and apply active contours
	    for (i = 1; i < slices+1; i++) {
	        selectWindow("innerTibiaMask");
	        setSlice(i);
	        run("Create Selection"); // Create a selection of the slice
	        type = selectionType();
	        print("processing slice" + i); // Print slice being processed
	        
	        if (type != -1) { // Check if selection is valid
	            selectWindow("iMap");
	            setSlice(i);
	            run("Duplicate...", "title=" + iMap + "_slice"); // Duplicate the iMap for the slice
	            run("Restore Selection");
	    	    run("Level Sets", "method=[Active Contours] use_level_sets grey_value_threshold=35 distance_threshold=0.50 advection=2 propagation=1 curvature=2 grayscale="+grayscale+" convergence=0.0050 region=outside");
	            close("*progress*");
	            selectWindow("Segmentation of iMap_slice");
	            run("Convert to Mask", "Method=Default background=Light"); // Convert the result to a binary mask
	            run("Concatenate...", "title=" + "innerTibiaMask" + "temp image1=" + innerTibiaMask + "temp image2=[Segmentation of " + iMap + "_slice]");
	            close("Segmentation*");
	            close("iMap_slice");
	        } else { // If no valid selection, fill the slice with the mask color
	            selectWindow(innerTibiaMask);
	            setSlice(i);
	            run("Duplicate...", "title=slice");
	            run("Select All");
	            setForegroundColor(255, 255, 255);
	            run("Fill", "Slice");
	            run("Concatenate...", "title=" + innerTibiaMask + "temp image1=" + innerTibiaMask + "temp image2=slice");
	        }
	    }
		
		//waitForUser("active2");
		
		//iMap="iMap";
		//innerTibiaMask="innerTibiaMask";
		//grayscale=7;
			
		// Finalize the batch processing by setting the foreground color and closing the mask
	    setForegroundColor(0, 0, 0);
	    close(innerTibiaMask);
	    selectWindow(iMap);
	    Stack.getDimensions(width, height, channels, slices, frames); // Get the dimensions of the iMap
	    selectWindow(innerTibiaMask + "temp");
	    run("Make Substack...", "delete slices=" + slices + 1 + "-" + 2 * slices); // Create a substack from the temporary mask
	    rename(innerTibiaMask); // Rename the result mask
	    close(innerTibiaMask + "temp");
	    setBatchMode(false); // Disable batch mode after processing is complete
		
		//waitForUser("active3");
}	




function activeContoursInside(iMap,innerTibiaMask,maxCartilageThickness){

		setBatchMode(false);
		innerTibiaMask="outerTibiaMask";
		//maxCartilageThickness=4;
		selectWindow(innerTibiaMask);
		Stack.getDimensions(width, height, channels, slices, frames);
		//	run("Duplicate...", "title="+innerTibiaMask+"temp duplicate");

		setForegroundColor(0,0,0);
		setBackgroundColor(255,255,255);
		
		for (i = 1; i < slices+1; i++) {
			selectWindow(innerTibiaMask);
			setSlice(i);
			run("Create Selection");
			type=selectionType();	
			if (type != -1 ) {
				//maxCartilageThickness
				
				run("Enlarge...", "enlarge="+maxCartilageThickness);
				run("Fill","slice");
				
				// ACTIVE COUNTUORS FAILS!! --> open cartilage  ... 
				/*
				setForegroundColor(255,255,255);
				setBackgroundColor(0,0,0);
				selectWindow(iMap);
				setSlice(i);
				run("Duplicate...", "title="+iMap+"_slice");
				run("Restore Selection");
				//maxCartilageThickness
				run("Enlarge...", "enlarge="+maxCartilageThickness);
				run("Clear Outside");
				/*waitForUser;
				run("Level Sets", "method=[Active Contours] use_level_sets grey_value_threshold=100 distance_threshold=1 advection=1 propagation=1 curvature=0.5 grayscale=30 convergence=0.0050 region=inside");
				waitForUser;
				close("*progress*");
				run("Concatenate...", "  title="+innerTibiaMask+"temp image1="+innerTibiaMask+"temp image2=[Segmentation of "+iMap+"_slice]");
				close("Segmentation*");
				close("iMap_slice");
				*/
				
			}else{
				
				/*
				selectWindow(innerTibiaMask);
				setSlice(i);
				run("Duplicate...", "title=slice");
				run("Select All");
				run("Fill","Slice");
				run("Concatenate...", "  title="+innerTibiaMask+"temp image1="+innerTibiaMask+"temp image2=slice");*/
			}
		}

		
		setBackgroundColor(0,0,0);
		setForegroundColor(255,255,255);
		
		/*close(innerTibiaMask);
		selectWindow(iMap);
		Stack.getDimensions(width, height, channels, slices, frames);
		selectWindow(innerTibiaMask+"temp");
		//slices=512;
		//run("Make Substack...", "delete slices="+slices+1+"-"+2*slices);
		rename(innerTibiaMask);
		close(innerTibiaMask+"temp");
		*/
		setBatchMode(false);

}



function mask3DConvexHull(mask) {
	/**
	 * Processes a 3D binary mask to compute the convex hull for each slice.
	 * 
	 * @param {string} mask - binary mask (Inverted LUT) with particles. 
	 */
	
		// Reset ROI Manager and prepare the mask for analysis
		roiManager("reset");
		selectWindow(mask);
		run("Select None");
		RoiManager.associateROIsWithSlices(true);	
		getDimensions(width, height, channels, slices, frames);
		run("Colors...", "foreground=black background=white selection=red");
		setForegroundColor(0, 0, 0);
	
		for (i = 1; i <= nSlices; i++) {
		    setSlice(i);
		    // do something here;
			run("Create Selection");
			type = selectionType();
			if (type != -1){
				run("Convex Hull","Slice");
				run("Fill", "slice");
			}
		}
		
		// Reset the ROI Manager and deselect the mask
		roiManager("reset");
		selectWindow(mask);
		run("Select None");
	}



// Function to reslice an image from coronal to axial orientation.
function resliceTop(image) {
    // Select and reslice the image from the top to axial orientation.
    selectWindow(image);
    run("Select All");
    run("Reslice [/]...", "output=1.000 start=Top");
    close(image);
    rename(image);
}

// Function to add a border around the image and subtract it from the original.
function addBorder(image) {
    // Duplicate the image, add a white border, and subtract it from the original image.
    selectWindow(image);
    run("Duplicate...", "title=border duplicate");
    setForegroundColor(255,255,255);
    setBackgroundColor(0,0,0);
    run("Select All");
    run("Fill" , "stack");
    run("Enlarge...", "enlarge=-2");
    run("Clear Outside","stack");
    run("Select None");
    imageCalculator("Substract stack", image,"border");
    close("Border");
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
	run("CLIJ2 Macro Extensions", "cl_device=[NVIDIA GeForce RTX 4060 Laptop GPU]");
	
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
	Ext.CLIJx_subtractBackground3D(image1, image2, sigma_x, sigma_y, sigma_z);
	
	// Pull result image from GPU memory
	Ext.CLIJ2_pull(image2);
	
	// Clear CLIJ2
	Ext.CLIJ2_clear();
	
	// Close input image
	//close(image1);
	
	// Rename output image
	selectWindow(image2);
	rename(name+"_subBckg");
}


// Function to open different file formats including .jpg, .tif, .czi, and .svs.
function openFileFormat(file) {

    if(endsWith(file,".jpg") || endsWith(file,".tif")){
        open(file); 
    } else if(endsWith(file,".czi") || endsWith(file,".svs")){
        run("Bio-Formats Importer", "open=["+file+"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
    }
}


