// changelog December 2019
// Automatic detection of tissue and lung nodules in HE
// Possibility of deleting tissue regions


function macroInfo(){
	
// * Quantification of Brown WSI Images Area  
// * Target User: General
// *  

	scripttitle= "Quantification of Lung Nodules in H&E";
	version= "1.03";
	date= "2019";
	

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
 	
	parameter1="Resolution (micra pixel ratio) = 0.502 micras/pixel xy"; 
	parameter2="Tissue Threshold (8bit) = Separate Tissue from Background";
	parameter3="Threshold for Nodules segmentation in HE (8bit): Separate Nodule expression from Basal.";
 	
 //  2 Action tools:
	buttom1="Nodules: Single File processing";
	
//  OUTPUT

// Analyzed Images with ROIs

	excel="Total.xls";
	feature1="Image Label"; 
	feature2="Tissue area (micra^2)";
	feature3="Nodule area (micra^2)";
	feature4="Ratio Anodule/Atissue (%)";			
		
/*  	  
 *  version: 1.02 
 *  Author: Mikel Ariz  
 *  Commented by: Tomas Muñoz 2023 
 *  Date : 2015
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
	    +"<p><font size=3  i>PARAMETERS:</i></p>"
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



var r=2.008, thTissue=230, thNodule=150, minNoduleSize=600;	

macro "LungNodulesHE Action Tool 1 - Ca2fT0b11NT8b09oTdb09d"
{

	macroInfo();
	
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	
	run("Colors...", "foreground=white background=black selection=green");
	
	
	// DETECT TISSUE--
	
	//POSSIBILITY OF DELETING
	run("Select All");
	setBatchMode(false);
	run("Duplicate...", "title=orig");
	setTool("zoom");
	q=getBoolean("Do you want to elliminate an area of tissue?");
		while(q){
			setTool("freehand");		
			waitForUser("Please, select an area to elliminate and press ok when ready");
			setBackgroundColor(255, 255, 255);		
			run("Clear", "slice");
			run("Select All");				
			q=getBoolean("Do you want to elliminate another area?");
			setTool("zoom");
	}
	
	// DETECT
	setBatchMode(true);
	run("Select All");
	showStatus("Detecting tissue...");
	run("RGB to Luminance");
	rename("a");
	run("Threshold...");
	//setAutoThreshold("Huang");
	//getThreshold(lower, upper);
		//thTissue=233;
	setThreshold(0, thTissue);
	run("Convert to Mask");
	run("Median...", "radius=12");
	run("Analyze Particles...", "size=10000-Infinity pixel show=Masks in_situ");
	run("Fill Holes");
	run("Create Selection");
	run("Add to Manager");	// ROI0 --> whole tissue
	selectWindow("a");
	close();
	
	
	// LUNG NODULES--
	
	selectWindow("orig");
	showStatus("Deconvolving channels...");
	run("Colour Deconvolution", "vectors=[H&E 2] hide");
	selectWindow("orig-(Colour_2)");
	close();
	selectWindow("orig-(Colour_3)");
	close();
	selectWindow("orig");
	close();
	selectWindow("orig-(Colour_1)");
	rename("Hematox");
	
	run("Threshold...");
	setAutoThreshold("Default");
		//thNodule=150;
	setThreshold(0, thNodule);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Open");
	run("Median...", "radius=1");
	//run("Analyze Particles...", "size=600-Infinity show=Masks in_situ");
	run("Analyze Particles...", "size="+minNoduleSize+"-Infinity show=Masks in_situ");
	run("Median...", "radius=3");
	roiManager("Show None");
	run("Create Selection");
	type = selectionType();
	  if (type==-1) {	//if there is no selection, select one pixel
	      makeRectangle(1,1,1,1);
	  }
	run("Add to Manager");	// ROI1 --> Whole hematoxylin detection
	close();
	
	// Save just nodules in tissue
	roiManager("Deselect");
	roiManager("Select", 0);
	roiManager("Select", newArray(0,1));
	roiManager("AND");
	type = selectionType();
	  if (type==-1) {	//if there is no selection, select one pixel
	      makeRectangle(1,1,1,1);
	  }
	roiManager("Add");
	roiManager("Deselect");
	roiManager("Select", 1);
	roiManager("Delete");
	
	
	// POSSIBILITY OF DELETING NODULES
	
	selectWindow(MyTitle);
	setBatchMode(false);
	roiManager("Select", 1);
	setTool("zoom");
	q=getBoolean("Do you want to set negative a region detected as nodule?");
		while(q){
			setTool("freehand");		
			waitForUser("Please, select the area and press ok when ready");
			run("Add to Manager");
			roiManager("Deselect");
			roiManager("Select", 1);
			roiManager("Select", newArray(1,2));
			roiManager("AND");
			type = selectionType();
			  if (type==-1) {	//if there is no selection, select one pixel
			      makeRectangle(2,2,1,1);
			  }
			roiManager("Add");
			roiManager("Deselect");
			roiManager("Select", 1);
			roiManager("Select", newArray(1,3));
			roiManager("XOR");
			roiManager("Add");
			roiManager("Deselect");
			roiManager("Select", newArray(1,2,3));
			roiManager("Delete");
			roiManager("Deselect");
			roiManager("Select", 1);
			setTool("zoom");								
			q=getBoolean("Do you want to set negative another region detected as positive?");		
		}
	
	
	
	// RESULTS--
	
	run("Clear Results");
	selectWindow(MyTitle);	
	run("Select None");
	run("Set Measurements...", "area redirect=None decimal=2");
	
	// Tissue
	roiManager("select", 0);
	roiManager("Measure");
	At=getResult("Area",0);
	//in micra
	Atm=At*r*r;
	
	// Nodules
	roiManager("select", 1);
	roiManager("Measure");
	Ap=getResult("Area",1);
	//in micra
	Apm=Ap*r*r;
	
	// Ratio
	r1=Apm/Atm*100;
	
	run("Clear Results");
	if(File.exists(output+File.separator+"Total.xls"))
	{
		
		//if exists add and modify
		open(output+File.separator+"Total.xls");
		i=nResults;
		setResult("Label", i, MyTitle); 
		setResult("Tissue area (micra^2)",i,Atm);
		setResult("Nodule area (micra^2)",i,Apm);
		setResult("Ratio Anodule/Atissue (%)",i,r1);			
		saveAs("Results", output+File.separator+"Total.xls");
		
	}
	else
	{
		
		setResult("Label", 0, MyTitle); 
		setResult("Tissue area (micra^2)",0,Atm);
		setResult("Nodule area (micra^2)",0,Apm);
		setResult("Ratio Anodule/Atissue (%)",0,r1);		
		saveAs("Results", output+File.separator+"Total.xls");
		
	}
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	selectWindow(MyTitle);
	roiManager("Show None");
	roiManager("Select", 0);
	roiManager("Set Color", "red");
	roiManager("Set Line Width", 2);
	run("Flatten");
	roiManager("Show None");
	roiManager("Select", 1);
	roiManager("Set Color", "green");
	roiManager("Set Line Width", 2);
	run("Flatten");
	saveAs("Jpeg", OutDir+File.separator+MyTitle_short+"_analyzed.jpg");
	
	selectWindow("Threshold");
	run("Close");
	selectWindow(MyTitle);
	close();
	setTool("zoom");
	selectWindow(MyTitle_short+"-1.jpg");
	close();
	
	showMessage("Done!");

}

macro "LungNodulesHE Action Tool 1 Options" {
     Dialog.create("Parameters");

     Dialog.addMessage("Choose parameters")
     Dialog.addNumber("micra/px ratio", r);
     Dialog.addNumber("Threshold for tissue detection", thTissue); 
     Dialog.addNumber("Threshold for nodule detection", thNodule);  
     //Dialog.addCheckbox("Export analyzed image", export);   
     Dialog.show();
     
     r= Dialog.getNumber();
     thTissue= Dialog.getNumber();
     thNodule= Dialog.getNumber();     
     //export=Dialog.getCheckbox();
        
}
