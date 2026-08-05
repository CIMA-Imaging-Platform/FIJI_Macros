function macroInfo(){
	
// * Quantification of Brown WSI Images Area  adapted for Liver tissue
// * Target User: General
// *  

	scripttitle= "Quantification of Toulina Stained Area on Condyles Cartilage";
	version= "1.01";
	date= "2026";
	

// *  Tests Images:

	imageAdquisition="Aperio: BrightField Whole Slide Imaging Images.";
	imageType="RGB";  
	voxelSize="Voxel size:  0.502 um xy";
	format="Format: Uncompressed .jpg";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button 
	 parameter1="Resolution (micra pixel ratio)= 0.502 micras/pixel xy"; 
	 parameter2="Use SAMJ for condyles annotation";
	 parameter3="Toulina Marker Threshold = Separate Lession(+) tissue form Non Lession(-) tissue";
	 
 //  2 Action tools:
	 buttom1="Im: Single File processing";
	 buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs

	excel="Results_WSI_CartilageToulinaBlue.xls";
	feature1="Image Label";
	feature2="Tissue Area (micra²)";
	feature3="Stained area (micra²)";
	feature4="Ratio Area stained/Area tissue (%)"

/*  	  
 *  version: 1.01 
 *  Date: Changelog 2026
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
	    +"<ol><font size=2  i><li>"+buttom1+"</li>"
	    +"<li>"+buttom2+"</li></ol>"
	    +"<p><font size=3  i>PARAMETERS: Right Click on Action tools  </i></p>"
	    +"<ul id=list-style-3><font size=2  i>"
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li>"
	    +"<li>"+parameter3+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}



// Possibility of deleting regions in ROI

var r=0.502;
/*
macro "BrownDetection Action Tool 1 - Cf00T2d15IT6d10m"{
	
	run("Collect Garbage");
	close("*");
	
	macroInfo();
	
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	//setBatchMode(true);
	print(name);
	
    roiManager("reset");
	run("SAMJ Annotator");
	roiManager("show all without labels");	
	
	SAMJpipeline("-",name);
	close("*");
	showMessage("Done!");

}
*/

macro "BrownDetection Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	run("Collect Garbage");
	close("*");
	
	
	macroInfo();
	
	InDir=getDirectory("Choose a Directory");
	list=getFileList(InDir);
	L=lengthOf(list);
	
    roiManager("reset");
	run("SAMJ Annotator");
	roiManager("show all without labels");	

	for (j=0; j<L; j++)
	{
		close("*");
		if(endsWith(list[j],"jpg")||endsWith(list[j],"tif")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print(name);
			//setBatchMode(true);
			SAMJpipeline(InDir,list[j]);
			setBatchMode(false);
			}
	}
	showMessage("Done!");
}


	
	// DETECT CARTILAGE REGION
	
function SAMJpipeline(InDir,filePath) {
    
    /**
     * Summary:
     * The `SAMJpipeline` function processes a set of 2D image stacks for cell counting and quantification.
     * It can operate in two modes: processing a single image or multiple images from a directory.
     * The function handles preprocessing (such as removing outliers, subtracting background, and setting image scale)
     * and uses a specialized tool (EfficientVitSAM10) for annotating liposomes within the images.
     *
     * @param output        The output directory path where results will be saved.
     * @param InDir         The input directory path. If "-", the user will manually select a file.
     * @param rxy           The resolution in nanometers (XY-plane resolution).
     */

    // Import a single image if no directory is specified


    
    if (InDir == "-") {

		open(filePath);
	 	MyTitle = File.nameWithoutExtension;
	 	rename(MyTitle);
        output = getInfo("image.directory");
        OutDir = output + File.separator + "AnalyzedImages";
        File.makeDirectory(OutDir);
        showStatus("Analyzing " + MyTitle);
        
    }else{
    	
    	open(InDir+File.separator+filePath);
	 	MyTitle = File.nameWithoutExtension;
	 	rename(MyTitle);
        output = getInfo("image.directory");
        OutDir = output + File.separator + "AnalyzedImages";
        File.makeDirectory(OutDir);
        showStatus("Analyzing " + MyTitle);
    	
    }
   
	processActiveImage(MyTitle,output);

    
}
    
        
function processActiveImage(MyTitle,output){
                        
        
 		// Initialize SAMJ Annotator for image annotation
        
        waitForUser("Install and Load EfficientVitSAM10");
        waitForUser("Select Image on LIST to Click GO");
        waitForUser("Select rectangle ROIs for condyle semi-automatic segmentation and Click OK");
		
        setBatchMode(true);
		
        segmentsROIs(MyTitle);
                
    	run("Set Measurements...", "area redirect=None decimal=2");
    	run("Set Scale...", "distance=1 known="+r+" unit=um");   	

		selectWindow("condyles");
		run("Set Scale...", "distance=1 known="+r+" unit=um");   	
		run("Create Selection");
		condlyesArea = getValue("Area");
		
		
		selectWindow("toulinaMask");
		run("Fill Holes");
		run("Create Selection");
		run("Set Scale...", "distance=1 known="+r+" unit=um");   	
		toulinaArea = getValue("Area");
		//getStatistics(toulinaArea, toulinaMean, min, max, toulinaStd, histogram);
		
		ratio = (toulinaArea/condlyesArea);
	
		run("Clear Results");
		if(File.exists(output+File.separator+"Results_WSI_CartilageToulinaBlue.xls"))
		{
			//if exists add and modify
			open(output+File.separator+"Results_WSI_CartilageToulinaBlue.xls");
			IJ.renameResults("Results");
		}
		i=nResults;
		setResult("[Label]", i, MyTitle); 
		setResult("Condlyes Ara (micra2)",i,condlyesArea);
		setResult("Toulina Stained area (micra2)",i,toulinaArea);
		setResult("Lession area (micra2)",i,(condlyesArea-toulinaArea));
		setResult("Ratio AreaLession/AreaCondyles",i,ratio);	
		setResult("Ratio AreaStained/AreaCondyles",i,(1-ratio));			
		//setResult("Toulina Mean Intensity",i,toulinaMean);			
		//setResult("Toulina Std Intensity",i,toulinaStd);			
		saveAs("Results", output+File.separator+"Results_WSI_CartilageToulinaBlue.xls");
		
		selectWindow(MyTitle);
		
		selectWindow("tissue");
		run("Create Selection");
		selectWindow(MyTitle);
		run("Restore Selection");
		Roi.setStrokeColor("yellow");
		Overlay.addSelection;
		
		selectWindow("condyles");
		run("Create Selection");
		selectWindow(MyTitle);
		run("Restore Selection");
		Roi.setStrokeColor("red");
		Overlay.addSelection;
				
		selectWindow("toulinaMask");
		run("Create Selection");
		selectWindow(MyTitle);
		run("Restore Selection");
		Roi.setStrokeColor("blue");
		Overlay.addSelection;
		Overlay.flatten;
		saveAs("Jpeg", OutDir+File.separator+MyTitle+"_analyzed.jpg");
		rename(MyTitle+"_analyzed.jpg");
		close("\\Others");
		
		setBatchMode("exit and display");
		
}



function segmentsROIs(MyTitle){
	
	selectWindow(MyTitle);
	run("Duplicate...", "ignore title=condylesMask");
	run("Select All");
	run("Clear");
	run("From ROI Manager");
	run("Create Mask");
	rename("condyles");
	
	roiManager("reset");
	
	selectWindow(MyTitle);
	roiManager("show none");
	run("Colour Deconvolution2", "vectors=[User values] output=[8bit_Transmittance] simulated [r1]=0.5984215275516185 [g1]=0.7351294678022318 [b1]=0.31855351345040145 [r2]=0.657050923611756 [g2]=0.6104933706980744 [b2]=0.44224645630535236 [r3]=0.5885836782517665 [g3]=0.6037426139796298 [b3]=0.5376468262350895");
	close("Log");
	close("Colour Deconvolution");
	selectWindow(MyTitle+"-(Colour_1)");
	rename("toulina");
	selectWindow(MyTitle+"-(Colour_2)");
	rename("tissue");
	selectWindow(MyTitle+"-(Colour_3)");
	close();

	selectWindow("tissue");
	run("Median...", "radius=2");
	setAutoThreshold("Huang no-reset");
	//setThreshold(0, 232);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Analyze Particles...", "size=500-Infinity show=Masks in_situ");
	run("Invert");
	run("Analyze Particles...", "size=1000-Infinity show=Masks in_situ");
	run("Invert");
	
	selectWindow("toulina");
	run("Duplicate...", "ignore title=toulinaMask");
	run("Median...", "radius=2");
	run("Threshold...");
	setBatchMode("show");
	waitForUser("Introduce Toulina(+) threshold for lession separation");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Analyze Particles...", "size=200-Infinity show=Masks in_situ");

	selectWindow("tissue");
	imageCalculator("OR", "tissue","toulinaMask");
	run("Analyze Particles...", "size=500-Infinity show=Masks in_situ");
	selectWindow("toulinaMask");
	imageCalculator("AND ", "toulinaMask","condyles");
	
}



