
function macroInfo(){
	
// "Reduce dimensionality of Time lapse Capture Images.";
// * Target User: General
// *  

	scripttitle= "Reduce dimensionality Images.";
	version= "1.01";
	date= "Jan 2024";
	

// *  Tests Images:

	imageAdquisition="2D/3D/4D Images";
	imageType="8bit/16bit/32bit";  
	voxelSize="Voxel size:  unkown um xy";
	format="Format: Zeiss .czi";   
 
 //*  GUI User Requierments:
 //*    - Choose parameters.
 //*    - Single File and Batch Mode
 //*    
 // Important Parameters: click Im or Dir + right button 
  		
	parameter1="Introduce Dimension to be reduced"; 
		 
//  2 Action tools:
	buttom1="Im: Single File processing";
	buttom2="DIR: Batch Mode. Select Folder: All images within the folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs

	excel="Image folder with all sequences";

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
	    +"<p><font size=3  i>PARAMETERS:  </i></p>"
	    +"<ul id=list-style-3><font size=2  i>"
	    +"<li>"+parameter1+"</li></ul>"
	    +"<p><font size=3  i> Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>"+excel+"</i></p>"
	    +"<h0><font size=5></h0>"
	    +"");

	   //+"<P4><font size=2> For more detailed instructions see "+"<p4><a href=https://www.protocols.io/edit/movie-timepoint-copytoclipboard-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}

// BUTTON FOR TISSUE DETECTION

macro "Gen_ReduceDimensionality Action Tool 1 - Cf00T2d15IT6d10m"
{	
	
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	print("Processing "+name);

	
	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Dimension to be reduced");
	default=false;
	Dialog.addCheckbox("Channels (c)", default);
	Dialog.addCheckbox("Slices (z)", default);
	Dialog.addCheckbox("Frames (t)", default);
	Dialog.show();	
	
	channel=Dialog.getCheckbox();
	slices=Dialog.getCheckbox();
	frames=Dialog.getCheckbox();
	
	reduceDim("-","-",name,channel,slices,frames);

}
	
	
macro "Gen_ReduceDimensionality Action Tool 2 - C00fT0b11DT9b09iTcb09r"{

	run("Close All");
	
	run("ROI Manager...");
	
	InDir=getDirectory("Choose Tiles' directory");
	list=getFileList(InDir);
	L=lengthOf(list);
	
	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Dimension to be reduced");
	default=false;
	Dialog.addCheckbox("Channels (c)", default);
	Dialog.addCheckbox("Slices (z)", default);
	Dialog.addCheckbox("Frames (t)", default);
	Dialog.show();	
	
	channel=Dialog.getCheckbox();
	slices=Dialog.getCheckbox();
	frames=Dialog.getCheckbox();

	
	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"czi")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			print("Processing "+name);
			reduceDim(InDir,InDir,list[j],channel,slices,frames);
			}
	}
	
	showMessage("Done!");

}

	function reduceDim(output,InDir,name,channel,slices,frames){
		setBatchMode(true)
		if(channel){channel=" split_channels";}else{channel="";}
		if(slices){slices=channel+" split_focal";}else{slices=channel+"";}
		if(frames){frames=slices+" split_timepoints";}else{frames=slices+"";}
				
		if (InDir=="-") {
			run("Bio-Formats", "open=["+name+"] autoscale color_mode=Colorized rois_import=[ROI manager]"+frames+" view=Hyperstack stack_order=XYCZT series_1");
			}
		else {
			run("Bio-Formats Importer", "open=["+InDir+name+"] autoscale color_mode=Colorized rois_import=[ROI manager]"+frames+" view=Hyperstack stack_order=XYCZT series_1");
			}
		
		//Make Results directory
		MyTitle=getTitle();
		output=getInfo("image.directory");
		aa = split(MyTitle,".");
		MyTitle_short = aa[0];
		OutDir = output+File.separator+MyTitle_short;
		File.makeDirectory(OutDir);
		
		// get image IDs of all open images
		ids=newArray(nImages);
		Array.print(ids);
		for (i=0;i<nImages;i++) {
			selectImage(i+1);
			MyTitle=getTitle();
			saveAs("Tiff", OutDir+File.separator+MyTitle+".tif");

		}
		setBatchMode(false);
		
	}



