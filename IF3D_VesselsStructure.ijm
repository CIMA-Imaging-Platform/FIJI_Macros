function macroInfo(){
	
// * Title  
	scripttitle =  "Volumetric Analysis of 3D Cocultive Bacteria Biofilms ";
	version =  "1.02";
	date =  "2023";
	

// *  Tests Images:

	imageAdquisition = "IF Confocal 2 Channel  ";
	imageType = "3D 8 bit";  
	voxelSize = "Voxel size:  unknown";
	format = "Format: czi";   
 
 //*  GUI User Requierments:
 //  	- save and load previous ROIS --> todo
 //*    - Interactive Threshold. --> done
 //*	- Delete Unwanted tissue and SR positive--> done
 //		- Single File and Batch Mode --> done
 //*    
 // Important Parameters: 
 
 	 parameter1 = "Threshold for all bacteria";
	 parameter2 = "Min bacteria size (px)";
	 
	  
 //  2 Action tools:
		
	 buttom1 = "Im: Single File processing. Use Single file processing for fine tunning parameters";
	 buttom2 = "Dir: Batch Mode. Please tune parameters before using Batchmode";

//  OUTPUT

// Analyzed Images with ROIs

	excel = "Results_IF3D_BiofilmQuantification_Colultivos.xls";
	
	feature1  = "Label";
	feature2  = "Total biofilm volume (um3)";
	feature3  = "Marker1 volume (um3)";
	feature4  = "Marker2 volume (um3)";
	feature5  = "VMarker1/Vbiofilm (%)";
	feature6  = "VMarker2/Vbiofilm (%)";
	feature7  = "Marker1 surface area (um2)";
	feature8  = "Marker1 roughness";
	feature9  = "Marker1 avg thickness (um)";
	feature10 = "Marker1 avg thickness in non-zero voxels (um)";
	feature11 = "Marker2 surface area (um2)";
	feature12 = "Marker2 roughness";
	feature13 = "Marker2 avg thickness (um)"
	feature14 = "Marker2 avg thickness in non-zero voxels (um)";
	feature15 = "Biofilm surface area (um2)";
	feature16 = "Biofilm roughness";
	feature17 = "Biofilm avg thickness (um)";
	feature18 = "Biofilm avg thickness in non-zero voxels (um)";
	
/*  	  
 *  version: 1.02 
 *  Author: Mikel Ariz  
 *  Commented by: Tomas Muñoz 2023 
 *  Date : 2023
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

	
	//image1 = "../templateImages/cartilage.jpg";
	//descriptionActionsTools = "
	
	showMessage("ImageJ Script", "<html>"
		+"<style>h{margin-top: 5px; margin-bottom: 5px;} p{margin: 0px;padding: 0px;} ol{margin-left: 20px;padding: 5px;} #list-style-3 {list-style-type: circle;.container {max-width: 1200px; margin: 0 auto; padding: 0px; }</style>"
	    +"<h1><font size = 6 color = Teal href = https://cima.cun.es/en/research/technology-platforms/image-platforms>CIMA: Imaging Platform</h1>"
	    +"<h1><font size = 5 color = Purple><i>Software Development Service</i></h1>"
	    +"<p><font size = 2 color = Purple><i>ImageJ Macros</i></p>"
	    +"<h2><font size = 3 color = black>"+scripttitle+"</h2>"
	    +"<p><font size = 2>Modified by Tomas Mu&ntilde;oz Santoro</p>"
	    +"<p><font size = 2>Version: "+version+" ("+date+")</p>"
	    +"<p><font size = 2> contact tmsantoro@unav.es</p>" 
	    +"<p><font size = 2> Available for use/modification/sharing under the "+"<p4><a href = https://opensource.org/licenses/MIT/>MIT License</a></p>"
	    +"<h2><font size = 3 color = black>Developed for</h2>"
	    +"<p><font size = 3  i>Input Images</i></p>"
	    +"<ul id = list-style-3><font size = 2  i><li>"+imageAdquisition +"</li><li>"+imageType+"</li><li>"+voxelSize+"</li><li>"+format+"</li></ul>"
	    +"<p><font size = 3 i>Action tools (Buttons)</i></p>"
	    +"<ol><font size = 2  i><li>"+buttom1+"</li><li>"+buttom2+"</li></ol>"
	    +"<p><font size = 3  i>PARAMETERS:</i></p>"
	    +"<ul id = list-style-3><font size = 2  i>"
	    +"<li>"+parameter1+"</li>"
	    +"<li>"+parameter2+"</li></ul>"
    	+"<p><font size = 3  i> Quantification Results: </i></p>"
	    +"<p><font size = 3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size = 3  i>Excel "+excel+"</i></p>"
	    +"<ul id = list-style-3><font size = 2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li>"
	    +"<li>"+feature5+"</li><li>"+feature6+"</li><li>"+feature7+"</li><li>"+feature8+"</li>"
	    +"<li>"+feature9+"</li><li>"+feature10+"</li><li>"+feature11+"</li><li>"+feature12+"</li>"
	    +"<li>"+feature13+"</li><li>"+feature14+"</li><li>"+feature15+"</li><li>"+feature16+"</li>"
	    +"<li>"+feature17+"</li><li>"+feature18+"</li></ul>"
	    +"<h0><font size = 5></h0>"
	    +"");
	   //+"<P4><font size = 2> For more detailed instructions see "+"<p4><a href = https://www.protocols.io/edit/movie-timepoint-copytoclipboaMarker2-tool-chutt6wn>Protocols.io</a><h4> </P4>"
}


macro "IF3D Vessels Action Tool 1 - Cf00T2d15IT6d10m"{
	

	 run("Close All");    
    InDir = getDirectory("Choose Tiles' directory");
    list = getFileList(InDir);
    L = lengthOf(list);

    for (j = 0; j < L; j++) {
        if (endsWith(list[j], ".czi") || endsWith(list[j], ".tif")) {
            name = list[j];
            print("Processing " + name);
            // Analyze each file using the 2D time workflow

			run("3D Fast Filters","filter=Median radius_x_pix=2.0 radius_y_pix=2.0 radius_z_pix=3.0 Nb_cpus=16");
			selectImage("3D_Median");
			
			run("Ridge Detection", "line_width=7 high_contrast=255 low_contrast=0 add_to_manager make_binary method_for_overlap_resolution=NONE sigma=8 lower_threshold=0 upper_threshold=0.10 minimum_line_length=20 maximum=0 stack");
		
	
			run("Invert LUT");
			run("Z Project...", "projection=[Max Intensity]");
			run("Gaussian Blur...", "sigma=4");
			setAutoThreshold("Default dark");
			//run("Threshold...");
			//setThreshold(15, 255);
			setOption("BlackBackground", false);
			run("Convert to Mask");
			run("Skeletonize")
			
					
           
            setBatchMode(false);
        }
    }
    
    
	
	
	

}
	
	
	
	
	
	
	
	
}
}

