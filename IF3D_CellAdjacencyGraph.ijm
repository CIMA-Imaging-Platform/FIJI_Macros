function macroInfo() {
	scripttitle = "Automatic Nuclei and Cell Adjacency Graphs in IF 3D Images";
	version = "1.03";
	date = "2024";

	imageAdquisition = "Confocal";
	imageType = "IF 3D 2 Channel: DAPI";
	voxelSize = "Voxel size: known metadata µm xy";
	format = "czi, tif";

	parameter1 = "Threshold Junction Marker: threshold to separate cell junction signal from background.";
	parameter2 = "Minimum nucleus size: filter small objects in segmentation.";
	parameter3 = "Adjacency graph: computes neighboring cells and distances.";

	button1 = "Im: Single File processing";
	button2 = "DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

	excelName1 = "IF3D_CellAdjacencyGraph_Neightbors.xls";
	excelName2 = "IF3D_CellAdjacencyGraph_Distances.xls";
	feature1 = "Filename";
	feature2 = "FOV (Field of View)";
	feature3 = "# Cells";
	feature4 = "# Neighboring Cells";
	feature5 = "Cell Adjacency Graph";
	feature6 = "Euclidian Distance(um)";

	showMessage("ImageJ Script", "<html>"
		+"<style>h{margin-top: 5px; margin-bottom: 5px;} p{margin: 0px;padding: 0px;} ol{margin-left: 20px;padding: 5px;} #list-style-3 {list-style-type: circle;.container {max-width: 1200px; margin: 0 auto; padding: 0px; }</style>"
		+"<h1><font size=6 color=Teal href=https://cima.cun.es/en/research/technology-platforms/image-platforms>CIMA: Imaging Platform</h1>"
		+"<h1><font size=5 color=Purple><i>Software Development Service</i></h1>"
		+"<p><font size=2 color=Purple><i>ImageJ Macros</i></p>"
		+"<h2><font size=3 color=black>"+scripttitle+"</h2>"
		+"<p><font size=2>Modified by Tomas Mu&ntilde;oz Santoro</p>"
		+"<p><font size=2>Version: "+version+" ("+date+")</p>"
		+"<p><font size=2>Contact: tmsantoro@unav.es</p>" 
		+"<p><font size=2>Available for use/modification/sharing under the <a href=https://opensource.org/licenses/MIT/>MIT License</a></p>"
		+"<h2><font size=3 color=black>Developed for</h2>"
		+"<p><font size=3><i>Input Images</i></p>"
		+"<ul id=list-style-3><font size=2><li>"+imageAdquisition+"</li><li>"+imageType+"</li><li>"+voxelSize+"</li><li>"+format+"</li></font></ul>"
		+"<p><font size=3><i>Action tools (Buttons)</i></p>"
		+"<ol><font size=2><li>"+button1+"</li><li>"+button2+"</li></font></ol>"
		+"<p><font size=3><i>PARAMETERS:</i></p>"
		+"<ul id=list-style-3><font size=2>"
		+"<li>"+parameter1+"</li>"
		+"<li>"+parameter2+"</li>"
		+"<li>"+parameter3+"</li></font></ul>"
		+"<p><font size=3><i>Quantification Results:</i></p>"
		+"<p><font size=3><i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
		+"<p><font size=3><i>Excel: "+excelName1+" and "+excelName2+"</i></p>"
		+"<ul id=list-style-3><font size=2>"
		+"<li>"+feature1+"</li>"
		+"<li>"+feature2+"</li>"
		+"<li>"+feature3+"</li>"
		+"<li>"+feature4+"</li>"
		+"<li>"+feature5+"</li>"
		+"<li>"+feature6+"</li>"
		+"</font></ul>"
		+"<h0><font size=5></h0>"
		+"</html>"
	);
}
var thJunctions=20;		

macro "IFnuclCyto3D Action Tool 1 - Cf00T2d15IT6d10m"{

	close("*");
	macroInfo();
		
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	//setBatchMode(true);
	print(name);
	processSingleIm("-","-",name);
	setBatchMode(false);
	showMessage("Done!");

}
		
macro "IFnuclCyto3D Action Tool 2 - C00fT0b11DT9b09iTcb09r"{

	close("*");
	macroInfo();
	
	InDir=getDirectory("Choose a Directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"czi") || endsWith(list[j],"tif")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print(name);
			//setBatchMode(true);
			processSingleIm(InDir,InDir,list[j]);
			setBatchMode(false);
			}
	}
	showMessage("Done!");
}



function processSingleIm(output,InDir,name)
{
	/**
	 * Calculates the 3D volume of segmented objects in a specified frame using the Analyze Regions 3D tool.
	 *
	 * @param {im}    String. Name of the intensity image to be analyzed.
	 * @param {mask}  String. Name of the mask image defining segmented regions.
	 * @returns       Quantitative results of 3D object volumes within the mask for the given frame.
	 */
	
	setBatchMode(false);
	
	run("Clear Results");
	roiManager("reset");
	
	cDapi = 1;

	// Open image file using Bio-Formats, either from a directory or as a single file
	selectWindow("Log");
	print("Step1 --> loading image...");
	if (InDir=="-") {
		run("Bio-Formats", "open=["+name+"] autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT");
	}
	else {
		if (!isOpen(InDir+name)) { 
			run("Bio-Formats", "open=["+InDir+name+"] autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT");
		}
	}
	
	// Set display and color options for stack visualization
	Stack.setDisplayMode("composite");
	run("Colors...", "foreground=black background=white selection=yellow");
	run("Options...", "iterations=1 count=1 pad do=Nothing");  // binary settings
	
	// Reset ROI Manager and Results table
	roiManager("Reset");
	run("Clear Results");
	
	// Get image title and output directory
	MyTitle=getTitle();
	output=getInfo("image.directory");
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	// Extract base filename for saving outputs
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	rename("orig");
	
	// Get image dimensions and calculate Field of View (FOV)
	Stack.getDimensions(width, height, channels, slices, frames);
	getVoxelSize(vxW, vxH, depth, unit);
	FOV = width * height * slices * vxH * vxH * depth ;
	
	
	// Segment nuclei from channel 1
	selectWindow("Log");
	print("Step2 --> Nucleus Segmentation --> STARDIST processing ...");
	selectWindow("orig");
	run("Duplicate...", "duplicate title=nuclei3D channels="+cDapi+"");
	
	setBatchMode(false);
	
	segmentNuclei("nuclei3D");
	
	computeNucleusRAG("nucleusLabels");
	
	// Measure junction features 
	selectWindow("Log");
	print("Step4 --> Calculating Metrics ...");

	node1 = Table.getColumn("Label 1");
	node2 = Table.getColumn("Label 2");
	nodes = Array.concat(node1,node2);
	
	// Sort to group duplicates
	nodesSort= Array.sort(nodes);
	imageLabel = newArray();
	unique = newArray();
	counts = newArray();
	count = 1;
	
	for (i = 1; i < nodesSort.length; i++) {
		if (nodesSort[i] == nodesSort[i-1])
	        count++;
	    else {
	    	imageLabel = Array.concat(imageLabel, newArray(MyTitle_short));
	        unique = Array.concat(unique, nodesSort[i-1]);
	        counts = Array.concat(counts, count);
	        count = 1;
	    }
	}
	// Add last
	unique = Array.concat(unique, nodesSort[nodesSort.length-1]);
	counts = Array.concat(counts, count);
	imageLabel = Array.concat(imageLabel, newArray(MyTitle_short));

	//Save Area Results
	if (File.exists(output+ File.separator+"IF3D_CellAdjacencyGraph_Neightbors.xls"))
	{	//if exists add and modify
		open(output+ File.separator+"IF3D_CellAdjacencyGraph_Neightbors.xls");
		IJ.renameResults("Results");
		pos = nResults;	
		for (i = 0; i < lengthOf(imageLabel); i++) {
			setResult("[Label]", pos+i , imageLabel[i]);
			setResult("CellLabelNodes", pos+i , unique[i]);
			setResult("#NeighboringCells", pos+i , counts[i]);
		}
		saveAs("Results",output+ File.separator+"IF3D_CellAdjacencyGraph_Neightbors.xls");
		
	}else {
		Table.create("RAG");
		Table.setColumn("[Label]", imageLabel);
		Table.setColumn("CellLabelNodes", unique);
		Table.setColumn("#NeighboringCells", counts);
		Table.update;
			
		selectWindow("RAG");
		IJ.renameResults("Results");
		saveAs("Results",output+ File.separator+"IF3D_CellAdjacencyGraph_Neightbors.xls");
	}
	
	close("Results");
	setBatchMode("exit and display");

	roiManager("Deselect");
	setVoxelSize(vxW, vxH, depth, unit);
	roiManager("Measure");
	v = Table.getColumn("Length");

	//Save Area Results
	if (File.exists(output+ File.separator+"IF3D_CellAdjacencyGraph_Distances.xls"))
	{	//if exists add and modify
		open(output+ File.separator+"IF3D_CellAdjacencyGraph_Distances.xls");
		
	}else {
		Table.create("RAG");
		Table.update;
	}
	IJ.renameResults("Results");
	pos = nResults;	
	for (i = 0; i < lengthOf(node1); i++) {
		setResult("[Label]", pos + i, MyTitle_short);
		setResult("Cell 1", pos + i, node1[i]);
		setResult("Cell 2", pos + i, node2[i]);
		setResult("Euclidian Distance(um)", pos + i, v[i]);
	}
	saveAs("Results",output+ File.separator+"IF3D_CellAdjacencyGraph_Distances.xls");
		
	print("Step5 --> Saving Overlay Images ...");
	
	selectWindow("orig");
	run("Duplicate...", "duplicate title=nuclei3D channels="+cDapi+"");
	selectWindow("nuclei3D");
	run("Z Project...", "projection=[Sum Slices]");
	rename("grayNucleus");
	
    run("From ROI Manager");
	run("Create Mask");
	run("16-bit");
	run("Select All");
	run("Clear");
	
	nRois = roiManager("count");
	print(nRois);
	for (i = 0; i <nRois; i++) {
		selectWindow("Mask");
		roiManager("select", i);
		run("Line to Area");
		setColor(i+1);
		fill();
	}
	
	run("Set Measurements...", "  redirect=None decimal=2");
	roiManager("Deselect");
	roiManager("Measure");
	call("inra.ijpb.plugins.LabelToValuePlugin.process", "Table=Results", "Column=Length", "Min=0", "Max=50");
	run("Assign Measure to Label");
	run("Fire");
	Stack.setUnits("pixel", "pixel", "pixel", "min", "um");
	run("Calibration Bar...", "location=[Upper Right] fill=Black label=White number=4 decimal=0 font=10 zoom=1.3 bold overlay show");
	saveAs("Tif",OutDir+ File.separator+MyTitle_short+"_RAGcalibrated");
	rename("Mask-Length");
	
	selectWindow("nucleusLabels");
	run("Remove Overlay");
	roiManager("reset");
	run("Label Map to ROIs", "connectivity=C4 vertex_location=Corners name_pattern=cell%03d");
	run("Merge Channels...", "c1=grayNucleus c2=Mask-Length create keep");
	run("RGB Color");
	roiManager("Show All with labels");
	run("Flatten");
	saveAs("Tif",OutDir+ File.separator+MyTitle_short+"_RAG");
	close("\\Others");
	
	
	/*
    Roi.setName("ROI_"+i);
    Roi.setStrokeColor("green"); // Changed from "red" or "blue" to "green"
    Roi.setStrokeWidth(1);
    run("Add to Manager");
 
    // Get the coordinates of the line
    getSelectionCoordinates(x, y);
    // Place the label at the midpoint of the line
    midX = (x[0] + x[1]) / 2;
    midY = (y[0] + y[1]) / 2;
    makeText(d2s(lengthUm, 2) + "um", midX, midY);
    setFont("SansSerif", 5, "bold");
    setForegroundColor(0, 255, 0); // Green text
    Overlay.addSelection();
  */


}


function segmentNuclei(nucleiIm){

	/**
	* Segments nuclei from a 3D image by projecting to 2D and applying StarDist2D.
	* @param nucleiIm Name of the 3D nuclei image window to process
	*/

	// segment CELLs IN THE 2D PROJECTION
	//nucleiIm = "nuclei3D";
	selectWindow(nucleiIm);
	run("Z Project...", "projection=[Sum Slices]");
	selectWindow("SUM_"+nucleiIm);
	run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input':'SUM_"+nucleiIm+"', 'modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'1.0', 'percentileTop':'99.8', 'probThresh':'0.479071', 'nmsThresh':'0.3', 'outputType':'Both', 'nTiles':'1', 'excludeBoundary':'5', 'roiPosition':'Stack', 'verbose':'false', 'showCsbdeepProgress':'true', 'showProbAndDist':'false'], process=[false]");
	selectImage("Label Image");
	rename("nucleusLabels");
	selectWindow("nucleusLabels");
	run("Label Size Filtering", "operation=Greater_Than size=1000");
	close("nucleusLabels");
	rename("nucleusLabels");
	run("Remap Labels");
	close("*3D");
	
	roiManager("reset");
	
	// Overlay nucleus segmentation on original image
	selectWindow("nucleusLabels");
	setAutoThreshold("Default dark");
	setThreshold(1, 65535, "raw");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Adjustable Watershed", "tolerance=1.5");
	run("Connected Components Labeling", "connectivity=8 type=float");
	close("nucleusLabels");
	rename("nucleusLabels");
	run("Remap Labels");
}

// Function to create cell mask in the 2D projection
		
function computeNucleusRAG(nucleiIm) {
	/**
	* Segments cell boundaries from a 3D nuclei image by projecting to 2D and applying StarDist2D.
	* @param nucleiIm Name of the 3D nuclei image window
	*/
	
	selectWindow(nucleiIm);
	run("Analyze Regions", "centroid");
	selectWindow("nucleusLabels-Morphometry");
	IJ.renameResults("Results");
	
	// CREATE CELL MASK IN THE 2D PROJECTION
	selectWindow(nucleiIm);
	run("Select None");
	run("Duplicate...", "title=centroids");
	setOption("ScaleConversions", true);
	run("8-bit");
	run("Convert to Mask");
	run("Select All");
	run("Clear");
	
	selectWindow("Results");
	nCentrois = nResults;
	centroidXcor = Table.getColumn("Centroid.X");
	centroidYcor = Table.getColumn("Centroid.Y");
	
	for (i = 0; i < lengthOf(centroidXcor); i++) {
	    xCor = centroidXcor[i];
	    yCor = centroidYcor[i];
	    selectWindow("centroids");
	    makePoint(xCor, yCor);
	    Overlay.addSelection("blue");
	
    }
	run("Flatten");
	selectWindow("centroids-1");
	run("8-bit");
	run("Morphological Filters", "operation=Opening element=Disk radius=3");
	run("Find Maxima...", "prominence=1 light output=[Segmented Particles]");
	run("Connected Components Labeling", "connectivity=8 type=float");
	rename("boundaries");
	run("Region Adjacency Graph", "show image=boundaries");
	close("centroids*");
	run("Remove Overlay");
	run("Remap Labels");
	
	setBatchMode("exit and display");
	
	selectWindow("boundaries");
	setBatchMode("show");
	
	matchLabels("nucleusLabels","boundaries");
    close("boundaries");
	
	setBatchMode(true);
	
	selectWindow(nucleiIm);
	run("Select None");
	run("Analyze Regions", "centroid");
	selectWindow("nucleusLabels-Morphometry");
	IJ.renameResults("Results");

	selectWindow("Results");
	nCentrois = nResults;
	labelIndex = Table.getColumn("Label");
	centroidXcor = Table.getColumn("Centroid.X");
	centroidYcor = Table.getColumn("Centroid.Y");
		
	selectWindow("boundaries-RAG");
	IJ.renameResults("Results");
	selectWindow("Results");
	connections = Table.getColumn("Label 1");
	//print(lengthOf(connections));
	roiManager("reset");
	
    for (i = 0; i < lengthOf(connections); i++) {
    	    	
    	u1 = getResult("Label 1", i);
    	u2 = getResult("Label 2", i);
    	
    	posU1 = findIndex(labelIndex,u1);
    	posU2 = findIndex(labelIndex,u2);
    	
       	x1 = centroidXcor[posU1]; 
    	y1 = centroidYcor[posU1];
    	x2 = centroidXcor[posU2];
    	y2 = centroidYcor[posU2];
    	
    	selectWindow("nucleusLabels");
    	makeLine(x1, y1, x2, y2);
    	run("Add to Manager");
    }
    
}


function findIndex(arr, value) {
    for (i=0; i<arr.length; i++) {
        if (arr[i] == value) {
            return i;  // return index (0-based)
        }
    }
    return -1; // not found
}


	
function matchLabels(ImInput,imTarget){
		
		
		run("Clear Results");
		roiManager("reset");
		
		selectWindow(ImInput);
		run("Label Map to ROIs", "connectivity=C4 vertex_location=Corners name_pattern=cell%03d");
		
		selectWindow(ImInput);
		run("Analyze Regions", "centroid");
		selectWindow("nucleusLabels-Morphometry");
		IJ.renameResults("Results");
		
		selectWindow("Results");
		xCor = Table.getColumn("Centroid.X");
		yCor = Table.getColumn("Centroid.Y");

		setBatchMode(false);
		for (i = 0; i < lengthOf(xCor); i++) {
			selectWindow(ImInput);
			makeRectangle(xCor[i], yCor[i],5,5);
			label = getValue("Mode");
			selectWindow(imTarget);
			makeRectangle(xCor[i], yCor[i], 5,5);
			wait(20);
			labelTarget = getValue("Mode");
			//print(label+"-->"+labelTarget);
			selectWindow(ImInput);
			roiManager("Select",i);
			changeValues(label, label, labelTarget);
		}
		run("Clear Results");
		close("Results");
		setBatchMode(false);
}
	


	
function addOverlay3D(rawImage,maskImage,channel,color){

	/**
	* @doc Adds 3D overlay ROIs from a mask image to a raw image, slice by slice, in a specified channel and color.
	* @param rawImage Name of the raw image window.
	* @param maskImage Name of the mask image window.
	* @param channel Channel number to assign the overlay.
	* @param color Color for the overlay.
	*/

			
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
		run("Select None");
}
	
function saveImages(image, outputDir, file) {
    // This function overlays two binary masks and saves the resulting image to the output directory.
    // * @param {image}     - String, image with the overlay
    // * @param {outputDir}- String, output directory path.
    // * @param {file}     - String, base filename for saving.
  	
  	selectWindow(image);
    saveAs("tif", outputDir + File.separator + file+"_Analyzed");
    close("*");	
}





















































