
function macroInfo(){

// * Title

	scripttitle= "Explore Imaging Features ";
	version= "1.01";
	date= "2025";
	
// *  Tests Images:

	imageAdquisition="Any Type";
	imageType="";  
	voxelSize="";
	format="Format: tiff";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button 
		
 //  2 Action tools:
	buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

// Analyzed Images with ROIs

	feature1="BitLength,Dimensions, Intensity Distribution (Mean,std,Min,Max) and Otsu ROI statistics";
	
/*
 *  version: 1.01 
 *  Author: Tomas Muñoz  2025 
 *  Date : 2025
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
	    +"<ul id=list-style-3><font size=2  i><li>"+imageAdquisition +"</li><li>"+format+"</li></ul>"
	    +"<p><font size=3 i>Action tools (Buttons)</i></p>"
	    +"<ol><font size=2  i><li>"+buttom2+"</li></ol>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

}

macro "All_exploreFeatures Action Tool 1 - Sa3fT0b10CT8b10PTfb10LTfb10I"{
	
	close("*");
	macroInfo();
	
	// Prompt for input folder and output Excel file
	inputDir = getDirectory("Choose a folder with .tif images");
	outputFile = inputDir + "Samples_ImFeatures.xls";
	
	// Prepare the results table headers
	print("Generating report...");
	run("Clear Results");
	Table.create("features");
	row = 0;
	fileList = getFileList(inputDir);
	
	setBatchMode(false);

	
	for (i = 0; i < fileList.length; i++) {
	    if (endsWith(fileList[i], ".tif")) {
	        path = inputDir + fileList[i];
	        open(path);
	        
	        title = getTitle();
			getDimensions(width, height, channels, slices, frames);
	        bitDepthVal = bitDepth; // 8, 16, 24, 32
				
	       setSlice(floor(slices/2));      
	       	if (slices >1){
	       		run("Statistics");
	       		mode = getResult("Mode",0);
	       		median = getResult("Median",0);
		        mean = getResult("Mean",0);
		        std = getResult("StdDev",0);
		        min = getResult("Min",0);
		        max = getResult("Max",0);
		        run("Clear Results");
	       	}else{
		    	mode = getValue("Mode");
		        median = getValue("Median");
		        mean = getValue("Mean");
		        std = getValue("StdDev");
		        min = getValue("Min");
		        max = getValue("Max");
       		} 
	  
	        setAutoThreshold("Otsu dark stack");
	        getThreshold(otsuTh, upper);
	      	
    		setSlice(floor(slices/2));      
	       	if (slices >1){
	       		run("Statistics");
	       		modeTh = getResult("Mode",0);
	       		medianTh = getResult("Median",0);
		        meanTh = getResult("Mean",0);
		        stdTh = getResult("StdDev",0);
		        minTh = getResult("Min",0);
		        maxTh = getResult("Max",0);
		        run("Clear Results");
	       	}else{
		    	modeTh = getValue("Mode");
		        medianTh = getValue("Median");
		        meanTh = getValue("Mean");
		        stdTh = getValue("StdDev");
		        minTh = getValue("Min");
		        maxTh = getValue("Max");
		         run("Clear Results");
       		}
	        
			//run("Threshold...");
			selectWindow("features");
	        // Store to results table
	        setResult("Label", row, title,"features");
	        setResult("BitDepth", row, bitDepthVal,"features");
	        setResult("Width", row, width,"features");
	        setResult("Height", row, height,"features");
	        setResult("Slices", row, slices,"features");
	        setResult("Mode", row, mode,"features");
	        setResult("Mean", row, mean,"features");
	        setResult("Median", row, median,"features");
	        setResult("Min", row, min,"features");
	        setResult("Max", row, max,"features");
	        setResult("StdDev", row, std,"features");
	        
	        setResult("OtsuTh",row,otsuTh,"features");
	        setResult("roiMode", row, modeTh,"features");
	        setResult("roiMean", row, meanTh,"features");
	        setResult("roiMedian", row, medianTh,"features");
	        setResult("roiMin", row, minTh,"features");
	        setResult("roiMax", row, maxTh,"features");
	        setResult("roiStdDev", row, stdTh,"features");
	        Table.update;
	        
	        row++;
	        close(title);
        }
 			
	}
	
	run("Clear Results");
	
	// Save all collected data to XLS
	selectWindow("fetures");
	IJ.renameResults("Results");	
	saveAs("Results", outputFile);
	print("Saved to: " + outputFile);
	
}

