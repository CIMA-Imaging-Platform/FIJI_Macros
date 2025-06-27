// WSI MeasureDistances Measurement Macro

function macroInfo(){
    
// * Quantification of Distances on WSI Images  
// * Target User: General
// *  

    scripttitle= "WSI Quantification of Distances on WSI Images";
    version= "1.00";
    date= "2024";
    

// *  Test Images:

    imageAdquisition="Aperio: BrightField Whole Slide Imaging Images.";
    imageType="RGB";  
    voxelSize="Voxel size:  0.502 um xy";
    format="Format: Uncompressed .jpg or .tif";   
 
 //*  GUI User Requirements:
 //*    - Choose image file.
 //*    - Enter acquisition resolution.
 //*    - Draw multiple straight lines representing MeasureDistances.
 //*    - Save results as Excel file.
 //*    - Angle of each line is also quantified.
 
     parameter1="Resolution (micron/pixel ratio) = 0.502 microns/pixel xy"; 
     parameter2="Draw straight lines to measure ";
     
      
 //  Action tools:
        
     buttom1="Open: Select and open a WSI image file";
     buttom2="Draw: Use the straight line tool to draw thickness measurements";

//  OUTPUT

// Analyzed Images with ROIs

    excel="WSI_MeasureDistances.xls";
    feature1="Image Label";
    feature2="Line #";
    feature3="Length (pixels)";
    feature4="Length (microns)";
    feature5="Angle (degrees)";
    
/*  	  
 *  version: 1.00 
 *  Author Tomas Muñoz
 *  date 2025 
 *  
 */

//	MIT License
//	Copyright (c) 2024 Tomas Muñoz tmsantoro@unav.es
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
        +"<ul id=list-style-3><font size=2  i><li>"+imageAdquisition +"</li><li>"+imageType+"</li><li>"+voxelSize+"</li><li>"+format+"</li></ul>"
        +"<p><font size=3 i>Action tools (Buttons)</i></p>"
        +"<ol><font size=2  i><li>"+buttom1+"</li>"
        +"<li>"+buttom2+"</li></ol>"
        +"<p><font size=3  i>PARAMETERS: </i></p>"
        +"<ul id=list-style-3><font size=2  i>"
        +"<li>"+parameter1+"</li>"
        +"<li>"+parameter2+"</li></ul>"
        +"<p><font size=3  i>Quantification Results: </i></p>"
        +"<p><font size=3 i>Excel file: "+excel+"</i></p>"
        +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li><li>"+feature5+"</li></ul>"
        +"<h0><font size=5></h0>"
        +"");
}




var r = 0.502; // Default resolution (um/pixel)

macro "WSI MeasureDistances Measurement Action Tool 1  - Cf00T2d15IT6d10m" {
	
	run("Fresh Start");
	close("*");
	
	macroInfo();
	
	run("Roi Defaults...", "color=green stroke=0 group=0");
	
    // 1. Open image (jpg or tif)
    path = File.openDialog("Select WSI image (jpg or tif)");
    if (endsWith(path, ".jpg") || endsWith(path, ".tif")) {
        open(path);
    } else {
        showMessage("Error", "Please select a .jpg or .tif file.");
        exit();
    }
    
    // Get the directory of the opened image and use it as output path
    MyTitle = getTitle();
    imgDir = File.directory;

    // 2. Ask user for resolution
    Dialog.create("Acquisition Resolution");
    Dialog.addNumber("Resolution (um/pixel):", r);
    Dialog.show();
    r = Dialog.getNumber();
	
	
    // 3. User draws multiple lines
    run("ROI Manager...");
    setTool("line");
    waitForUser("Draw lines and add to ROI Manager (press letter T). When finished, press OK.");
			
    // 4. Measure all lines
    roiManager("Show All with labels");
    roiManager("Measure");
    n = roiManager("count");
    if (n == 0) {
        showMessage("No lines found", "No lines were added to the ROI Manager.");
        exit();
    }

    // Add overlay with line lengths (in microns)
    for (i = 0; i < n; i++) {
    	roiManager("Show All with labels");
        roiManager("select", i);
        lengthPx = getResult("Length", i);
        lengthUm = lengthPx * r;
        Roi.setName("ROI_"+i);
        Roi.setStrokeColor("green"); // Changed from "red" or "blue" to "green"
        Roi.setStrokeWidth(2);
        // Get the coordinates of the line
        getSelectionCoordinates(x, y);
        // Place the label at the midpoint of the line
        midX = (x[0] + x[1]) / 2;
        midY = (y[0] + y[1]) / 2;
        makeText(d2s(lengthUm, 2) + "µm", midX, midY);
        setFont("SansSerif", 25, "bold");
        setForegroundColor(0, 255, 0); // Green text
        Overlay.addSelection();
    }
   
   Overlay.show();

    // 5. Save results to XLS

    savePath = imgDir + "WSI_DermisThickness.xls";
    // Convert pixel lengths to um and save, also save angle
    for (i = 0; i < nResults; i++) {
        lengthPx = getResult("Length", i);
        setResult("Length_um", i, lengthPx * r);
        angle = getResult("Angle", i);
        setResult("Angle_deg", i, angle);
    }
    saveAs("Results", savePath);

    // 6. Flatten overlay and save image as JPG
    run("Flatten"); // This merges overlay into the image
    saveImagePath = imgDir + MyTitle+"_Analyzed.jpg";
    saveAs("Jpeg", saveImagePath);

    showMessage("Done!!", "Lengths saved to:\n" + savePath + "\n\nImage with overlay saved to:\n" + saveImagePath);
    close(MyTitle);
}
