
function macroInfo(){
	
// * Target User: CT images users
// *  

	scripttitle= "CT Ring Artefact Remuval ";
	version= "1.01";
	date= "Feb 2025";
	

// *  Tests Images:

	imageAdquisition="microCT images";
	imageType="8bit/16bit/32bit";  
	voxelSize="Voxel size:  unkown um xy";
	format="Format: microCT .dcm";   
 
 //*  GUI User Requierments:
 //*    - Single File and Batch Mode
 //*    
  		
	parameter1="Introduce dcm folder"; 
		 
//  2 Action tools:
	buttom1="Im: Single File processing";
	buttom2="DIR: Batch Mode. Select Folder: All dcm folder images within the parent folder will be quantified";

//  OUTPUT

// Analyzed Images with ROIs

	excel="Preprocessed Images are saved at the parent folders";

	/*  	  
 *  version: 1.01 
 *  Commented by: Tomas Muñoz 2024 
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



macro "removeRingArtefacts Action Tool 1 - Cf00T2d15IT6d10m"
{	
	
	macroInfo();
	
	//just one file
	InDir=getDirectory("Choose Tiles' directory");
	
	//print(name);
	
	print("Processing "+InDir);

	removeRingArtefacts("-","-",InDir);
	
	run("Collect Garbage");
}

macro "removeRingArtefacts Action Tool 2 - C00fT0b11DT9b09iTcb09r"{

	macroInfo();
	
	run("Close All");
	
	InDir=getDirectory("Choose Tiles' directory");
	list=getFileList(InDir);
	L=lengthOf(list);
	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"/")){
				
			name=list[j];
			print("Processing "+name);
			removeRingArtefacts(InDir,InDir,list[j]);
			
		}
			
			run("Collect Garbage");
	}
	
	showMessage("Done!");

}

function removeRingArtefacts(output,InDir,name){
		
		setBatchMode(true);
				
		if (InDir=="-") {
			
			File.openSequence(name);
	
		}else {
			
			File.openSequence(InDir+name);
			
		}
		
		
		roiManager("Reset");
		run("Clear Results");
	
		//Make Results directory
		MyTitle=getTitle();
		filePath=getInfo("image.directory");
		output=File.getParent(filePath);
		//OutDir = output+File.separator+MyTitle_short;
			
		
		// create fft band pass filter
		/*
		getDimensions(width, height, channels, slices, frames);
		setSlice(floor(slices/2));
		run("Duplicate...", "title=FFTmask");
		makePoint(floor(width/2),floor(height/2));
		run("Enlarge...", "enlarge=175 pixel");
		run("Clear Outside");
		setForegroundColor(255,255,255);
		run("Fill");
		run("Make Binary");
		run("Divide...", "value=255");
		*/
		
		MyTitle=getTitle();
		selectWindow(MyTitle);
		getDimensions(width, height, channels, slices, frames);
	    setSlice(1);
	    run("FFT");
	   	run("Inverse FFT");
	   	rename("postFFT");
	   	close("FFT*");
	   	
		for (i = 2; i <= slices; i++) {
			selectWindow(MyTitle);
		    setSlice(i);
		    // do something here;
		    run("FFT");
		   	run("Inverse FFT");	
		   	close("FFT*");
		   	run("Concatenate...", "  title=postFFT open image1=postFFT image2=[Inverse FFT of "+MyTitle+"] image3=[-- None --]");
	   	}
		
		print("Saving preprocessed image");
		
		selectWindow("postFFT");
		saveAs("Tiff", output+File.separator+MyTitle+"_Preprocessed.tif");
		close("*");
		run("Collect Garbage");

			
}




