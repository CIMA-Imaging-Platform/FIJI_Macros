
function macroInfo(){
	
// "Reduce dimensionality of Time lapse Capture Images.";
// * Target User: General
// *  

	scripttitle= "Save Aperio SVs to other Format ";
	version= "1.01";
	date= "Jan 2024";
	

// *  Tests Images:

	imageAdquisition="Aperio Images";
	imageType="8bit/16bit/32bit";  
	voxelSize="Voxel size:  unkown um xy";
	format="Format: .svs";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button 
  		
	//parameter1="Introduce Dimension to be reduced"; 
		 
//  2 Action tools:
	buttom1="Im: Single File processing";
	buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs

	//excel="Image folder with all sequences";

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
	    +"<ol><font size=2  i><li>"+buttom1+"</li><li>"+buttom2+"</li></ol>"
	    +"<p><font size=3  i> Results: </i></p>"
	    +"<p><font size=3 i>tif images: Visualize  Images</i></p>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}



macro "All_SVSchangeFormat Action Tool 1 - Cf00T2d15IT6d10m"
{	
	
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	
	print("Processing "+name);

	setBatchMode(true);
	
	if (InDir=="-") {
		//open(name);
		run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
		}
	else {
		run("Bio-Formats Importer", "open=["+InDir+name+"] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
		//open(InDir+name);
		}
		
	//run("Input/Output...", "jpeg=100 gif=-1 file=.csv use_file save copy_column save_column save_row");
	
	//Make Results directory
	MyTitle=getTitle();
	output=getInfo("image.directory");
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	OutDir = output+File.separator+MyTitle_short;

	run("RGB Color");
	
	/*
	run("8-bit");
	setAutoThreshold("Default");
	//run("Threshold...");
	//setThreshold(0, 184);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Analyze Particles...", "size=50000-Infinity show=Masks in_situ add");
	
	nTissues=roiManager("count");
	
	for (i = 0; i < nTissues(); i++) {
	    selectWindow(MyTitle);
	    roiManager("select", i);
	}
	*/
	
	//save as JPG
	//saveAs("Tiff", OutDir+".tif");
	//saveAs("Jpeg",  OutDir+".jpg");
	
	run("Scriptable save HDF5 (new or replace)...", "save=["+OutDir+".hd5] dsetnametemplate=/channel{c} formattime=%d formatchannel=%d compressionlevel=0");
	//run("Scriptable load HDF5...", "load=[F:/TMSANTORO/0_USUARIOS_PLATAFORMA/INTERNOS/NAVARRABIOMED/2024_06_18_Paula_Aldaz/CD3/Combi 1 CD3.hd5] datasetnames=channel0 nframes=1 nchannels=1");
		
	close("*");
	
	setBatchMode(false);
		
	
}
	
	
macro "All_SVSchangeFormat Action Tool 2 - C00fT0b11DT9b09iTcb09r"{

	run("Close All");
	
	InDir=getDirectory("Choose Tiles' directory");
	list=getFileList(InDir);
	L=lengthOf(list);
	setBatchMode(true);
	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],".tif") || endsWith(list[j],".svs")){

			name=list[j];
			print("Processing "+name);
			
			if (InDir=="-") {
				//open(name);
				run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
				}
			else {
				run("Bio-Formats Importer", "open=["+InDir+name+"] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
				//open(InDir+name);
				}
				
			//run("Input/Output...", "jpeg=100 gif=-1 file=.csv use_file save copy_column save_column save_row");
			
			//Make Results directory
			MyTitle=getTitle();
			output=getInfo("image.directory");
			aa = split(MyTitle,".");
			MyTitle_short = aa[0];
			OutDir = output+File.separator+MyTitle_short;
		
			run("RGB Color");		
			
			//save as JPG
			//saveAs("Tiff", OutDir+".tif");
			//saveAs("Jpeg",  OutDir+".jpg");
			//saveAs("Raw Data", OutDir+".raw");
			
			//save HD5 format
			run("Scriptable save HDF5 (new or replace)...", "save=["+OutDir+".hd5] dsetnametemplate=/channel{c} formattime=%d formatchannel=%d compressionlevel=0");
			//run("Scriptable load HDF5...", "load=[F:/TMSANTORO/0_USUARIOS_PLATAFORMA/INTERNOS/NAVARRABIOMED/2024_06_18_Paula_Aldaz/CD3/Combi 1 CD3.hd5] datasetnames=channel0 nframes=1 nchannels=1");
	
			
			close("*");
					
					}
			}
			
	setBatchMode(false);
	showMessage("Done!");

}


function autoCrop(


function changeformat(output,InDir,name){
		
		
	
	




	}



