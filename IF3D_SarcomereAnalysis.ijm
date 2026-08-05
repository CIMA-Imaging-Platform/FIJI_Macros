
// Title / metadata
    scripttitle = "Sarcomere (Z-disk) Spacing Analysis";
    version = "1.2";
    date = "10.2025";
    imageAdquisition = "Confocal stacks (multi-channel)";
    imageType = "2D slice analysis from 3D stacks; 8-bit preferred";
    voxelSize = "Pixel size: microns (image must be calibrated)";
    format = "Supported: TIFF, CZI (via Bio-Formats)";

    // GUI / user requirements
    buttom1 = "Im: Single-file interactive processing";
    buttom2 = "Dir: (not implemented) Batch mode - tune parameters first";
    parameter1 = "Objective magnification (40x or 63x) — sets defaults";
    parameter2 = "Anisotropic diffusion iterations (AnisIter)";
    parameter3 = "Moving-average window for profile smoothing (winDefault)";
    parameter4 = "Peak detection tolerance (tolDefault)";

    // Output specification
    excel = "IF3D_SarcomereAnalysis.xls (summary table)";
    feature1 = "[Label] (image)";
    feature2 = "Slice (index)";
    feature3 = "# CM (cardiomyocytes in slice)";
    feature4 = "Area CM (um^2)";
    feature5 = "Orient CM (deg)";
    feature6 = "# Fil (filaments measured)";
    feature7 = "Orient Fil (deg)";
    feature8 = "Dist Z-disks (um)";
	
	// Output spec updated to include GLCM texture features computed by the macro:
	// Angular Second Moment, Contrast, Correlation, Inverse Difference Moment, Entropy
	// (packed into the feature9..feature11 slots so they appear in the showMessage list)

	feature9 = "Angular Second Moment";
	feature10 = "Contrast";
	feature11 = "Correlation"; 
	feature12 = "Inverse Difference Moment"
	feature13 = "Entropy";

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
    +"<p><font size=3  i>PARAMETERS: </i></p>"
    +"<ul id=list-style-3><font size=2  i>"
    +"<li>"+parameter1+"</li>"
    +"<li>"+parameter2+"</li>"
    +"<li>"+parameter3+"</li>"
    +"<li>"+parameter4+"</li></ul>"
    +"<p><font size=3  i>Quantification Results: </i></p>"
    +"<p><font size=3 i>AnalyzedImages folder: Visualize saved ROIs and plots</i></p>"
    +"<p><font size=3  i>Excel "+excel+"</i></p>"
    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li><li>"+feature5+"</li><li>"+feature6+"</li>"
    +"<li>"+feature7+"</li><li>"+feature8+"</li><li>"+feature9+"</li><li>"+feature10+"</li><li>"+feature11+"</li><li>"+feature12+"</li><li>"+feature13+"</li></ul>"
    +"<h0><font size=5></h0>"
    +"");
}

var tolDefault=20; lineBand = 50; sarChannel = 2; nuclChannel = 3; 

macro "SarcomereAnalysis Action Tool 1 - Ca3fT4d14S"{

	macroInfo();
	
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	// CHOOSE ANALYSIS AT 40X OR 63X (DEFAULT)
	Dialog.create("Choose option");
	items=newArray("40x","63x");
	Dialog.addRadioButtonGroup("Select the objective magnification", items,2, 1, "63x");
	Dialog.show();
	obj=Dialog.getRadioButton();
	mag63 = (obj=="63x");
	
	if(mag63) {
		AnisIter=80;
		winDefault=5;
	}
	else {
		AnisIter=10;
		winDefault=3;
	}
	
	// Initialization:
	getDimensions(width, height, channels, slices, frames);
	Stack.setSlice(floor(slices/2));
	Stack.setDisplayMode("composite");
	
	/*
	Stack.setChannel(1);
	run("Green");
	Stack.setChannel(2);
	run("Blue");
	*/

	run("Colors...", "foreground=black background=white selection=red");
	
	// Get pixel size:
	
	getPixelSize(unit, pw, ph, pd);
	if(unit=="microns") {
		r=pw;
	}
	else {
		waitForUser("Image not calibrated in microns. Go to Analyze>SetScale and set the appropriate scale in microns. Press OK when ready");
		r=pw;
	}
		
	// SLICE SELECTION FOR ANALYSIS
	
	q0=true;
	while(q0){
	
		waitForUser("Select the slice of interest and press OK");
		Stack.getPosition(cc, ss, ff);
		Stack.setChannel(1);
		//sarChannel = 2;
		//nuclChannel = 3;
		run("Select None");
	    run("Duplicate...", "title=temp duplicate slices="+ss+"");
		run("Duplicate...", "title=sarcomere duplicate channels="+sarChannel+"");
			
		// IMAGE ENHANCEMENT:
		selectWindow("sarcomere");
		// Anisotropic filter:
		run("Anisotropic Diffusion 2D", "number="+AnisIter+" smoothings=1 keep="+AnisIter+" a1=0.50 a2=0.90 dt=20 edge=3");
		// Unsharp mask with sigma 0.3:
		run("Unsharp Mask...", "radius=1 mask=0.30");
		run("Subtract Background...", "rolling=15");
		
		close("sarcomere");
		rename("sarcomere");
		
		selectWindow("temp");
		run("Original Scale");
		q=getBoolean("Do you want to select a cardiomyocite to analyze?");
		while(q){
		
			// CARDIOMYOCITE ORIENTATION:
		
			selectWindow("temp");
			setTool("freehand");
			run("Original Scale");
			roiManager("Reset");
			run("Clear Results");
			if (File.exists(OutDir+File.separator+MyTitle_short+"_"+ss+"_ROI_CMs.zip")){
				roiManager("Open", OutDir+File.separator+MyTitle_short+"_"+ss+"_ROI_CMs.zip");
			}
			roiManager("Show All with [Label]s");
			roiManager("Show All");
			cardiomyo=true;
			do{
				waitForUser("Draw the contour of a cardiomyocite to analyze and press OK when ready");
				type = selectionType();
				if (type==-1) {
					waitForUser("You should draw a cardiomyocite to analyze. Draw it and press OK when ready");
				}else{
					cardiomyo=false;
				}
			}while(cardiomyo)
			run("Measure");
			CMarea=getResult("Area",0);
			run("Clear Results");
			
			selectWindow("sarcomere");
			run("Restore Selection");
			run("Fit Ellipse");
			run("Add to Manager");	// We save the ellipse ROI
			run("Set Measurements...", "area fit redirect=None decimal=2");	// activo el "fit ellipse" para que me dé la orientación y medidas de los ejes
			run("Measure");
			CMang=getResult("Angle",0);
			roiManager("Save", OutDir+File.separator+MyTitle_short+"_"+ss+"_ROI_CMs.zip");
			roiManager("Reset");
			run("Clear Results");
			
			// SARCOMERE ANALYSIS:
		
			nFil=0;
			q2=getBoolean("Do you want to measure a filament?");
			if(q2){
				while(q2){
					nFil=nFil+1;	// counter for current filament number
					tol=tolDefault;
					setTool("line");
					selectWindow("sarcomere");
					run("Select None");
					roiManager("Reset");
					if (File.exists(OutDir+File.separator+MyTitle_short+"_"+ss+"_ROI_Fils.zip"))
						roiManager("Open", OutDir+File.separator+MyTitle_short+"_"+ss+"_ROI_Fils.zip");
					roiManager("Show All with [Label]s");
					roiManager("Show All");
					waitForUser("Draw a line along a filament to measure and press OK when ready");
					type = selectionType();
					if (type==-1) {
						waitForUser("You should draw a line along a filament. Draw it and press OK when ready");
					}		
			
					// Calculate position of Z-disks in the drawn profile. Let the user choose to keep it or repeat it:
					win=winDefault;
					q3=true;
					while(q3){				
						//tol=20;
						prof = getProfile();
						//Array.show(prof);
						profAvg = Array.copy(prof);		
						for (i=0;i<prof.length;i++) {
							if (i<floor(win/2)) {
								aslice = Array.slice(prof, 0, i-floor(win/2)+win);	// OJO, en realidad el que pones como 'end' no te lo coge
								Array.getStatistics(aslice, min, max, mean, stdDev);
								profAvg[i] = mean;
							}
							else if (i>prof.length-1-floor(win/2)) {
								aslice = Array.slice(prof, i-floor(win/2), prof.length); // OJO, en realidad el que pones como 'end' no te lo coge
								Array.getStatistics(aslice, min, max, mean, stdDev);
								profAvg[i] = mean;
							}
							else {				 
								aslice = Array.slice(prof, i-floor(win/2), i-floor(win/2)+win);
								Array.getStatistics(aslice, min, max, mean, stdDev);
								profAvg[i] = mean;
							}			
						}		
				
						maxLocs = Array.findMaxima(profAvg, tol);
						Array.sort(maxLocs);
						//Array.show(maxLocs);
						maxVals = Array.copy(maxLocs);		
						for (jj=0;jj<maxLocs.length;jj++) {
							xx = maxLocs[jj];
							maxVals[jj] = prof[xx];			
						}
						Plot.create("Filament Profile", "X", "Y", prof);		
						Plot.setColor("magenta");
						Plot.add("circle", maxLocs, maxVals);  		
						Plot.setColor("gray");
						Plot.show();
				
						//q3=getBoolean("Check the detected profile peaks corresponding to Z-disks. Do you want to measure this filament or draw it again?","Measure","Draw again");
						Dialog.create("Choose option");
						items=newArray("Measure","Draw again");
						Dialog.addRadioButtonGroup("Check the detected profile peaks corresponding to Z-disks. Do you want to measure this filament or draw it again?", items,2, 1, "Measure");
						Dialog.show();
						obj=Dialog.getRadioButton();
						q3 = (obj=="Draw again");
			
						if (q3) {
							selectWindow("Filament Profile");
							run("Close");				
							selectWindow("sarcomere");				
							waitForUser("Draw the filament again and press OK when ready");
							type = selectionType();
							if (type==-1) {
								waitForUser("You should draw a line along a filament. Draw it and press OK when ready");
							}	
							// Possibility to change tolerance for peak detection:			
							//tol = getNumber("You can change tolerance for peak detection",tol);	
							// Possibility to change window size for moving average:
							win = getNumber("You can change the averaging window size",win);							
						}
						
								
					}
					
					selectWindow("sarcomere");
					run("Add to Manager");
					run("Measure");	
					selectWindow("Results");	
					// Get filament angle and place it in 1st or 2nd quadrant:
					FilAng=getResult("Angle",0);
					if (FilAng<0) {
						FilAng = FilAng+180;
					}
					//print(FilAng);
			
					// Measure distance between consecutive peaks:
					peakDists = newArray(maxLocs.length-1);
					for (kk=0; kk<peakDists.length; kk++) {
						peakDists[kk] = maxLocs[kk+1]-maxLocs[kk];			
					}
					Array.getStatistics(peakDists, minD, maxD, meanD, stdD);
					//print(minD);
					//print(maxD);
					//print(meanD);
					//print(stdD);
			
					// ¿¿HACER DOUBLE-CHECK PARA VER SI HAY ALGUNA DISTANCIA QUE SE VA FUERA DE RANGO PORQUE FALTA O SOBRA UN PICO??
			
					selectWindow("Filament Profile");
					run("Close");
			
					ZdiskDist = meanD*r;	// mean distance in micras, because positions are voxels
					
					run("Clear Results");
										
					selectWindow("sarcomere");					
					run("Line to Area");
					run("Enlarge...", "enlarge=20");
					run("Duplicate...", "title=measureGLCMtexture");
					run("8-bit");
					run("Select None");
					run("GLCM Texture", "enter=2 select=[0 degrees] angular contrast correlation inverse entropy");
					close("measureGLCMtexture");
					
					aSM= getResult("Angular Second Moment", 0);
					contrast = getResult("Contrast", 0);
					corr = getResult("Correlation", 0);
					iDM = getResult("Inverse Difference Moment", 0);
					entropy = getResult("Entropy", 0);
															
					// SAVE RESULTS FOR CURRENT FILAMENT--
					roiManager("Save", OutDir+File.separator+MyTitle_short+"_"+ss+"_ROI_Fils.zip");
					roiManager("Reset");
					roiManager("Open", OutDir+File.separator+MyTitle_short+"_"+ss+"_ROI_CMs.zip");
					nCM=roiManager("count");
					run("Clear Results");
					selectWindow("Results");	
					close("Results");
					
					if(File.exists(output+File.separator+"IF3D_SarcomereAnalysis.xls"))
					{
						//if exists add and modify
						open(output+File.separator+"IF3D_SarcomereAnalysis.xls");
						IJ.renameResults("Results");
						i=nResults;
						setResult("[Label]", i, MyTitle);
						setResult("Slice", i, ss); 
						setResult("# CM", i, nCM); 
						setResult("Area CM (um2)", i, CMarea);
						setResult("Orient CM (deg)", i, CMang);	
						setResult("# Fil", i, nFil); 
						setResult("Orient Fil (deg)", i, FilAng); 						
						setResult("Dist Z-disks (um)", i, ZdiskDist);
						setResult("Angular Second Moment", i, aSM);
						setResult("Contrast", i, contrast);
						setResult("Correlation", i, corr);
						setResult("Inverse Difference Moment", i, iDM);
						setResult("Entropy", i, entropy);
						saveAs("Results", output+File.separator+"IF3D_SarcomereAnalysis.xls");
						
						
					}
					else
					{			
						setResult("[Label]", 0, MyTitle); 
						setResult("Slice", 0, ss);
						setResult("# CM", 0, nCM); 
						setResult("Area CM (um2)", 0, CMarea);
						setResult("Orient CM (deg)", 0, CMang);	
						setResult("# Fil", 0, nFil); 
						setResult("Orient Fil (deg)", 0, FilAng); 						
						setResult("Dist Z-disks (um)", 0, ZdiskDist); 		
						setResult("Angular Second Moment", 0, aSM);
						setResult("Contrast", 0, contrast);
						setResult("Correlation", 0, corr);
						setResult("Inverse Difference Moment", 0, iDM);
						setResult("Entropy", 0, entropy);
						saveAs("Results", output+File.separator+"IF3D_SarcomereAnalysis.xls");
						
					}
					
					selectWindow("sarcomere");
					run("Select None");
					run("Clear Results");
					roiManager("Reset");
					if (File.exists(OutDir+File.separator+MyTitle_short+"_"+ss+"_ROI_Fils.zip"))
						roiManager("Open", OutDir+File.separator+MyTitle_short+"_"+ss+"_ROI_Fils.zip");
					roiManager("Show All with [Label]s");
					roiManager("Show All");
					q2=getBoolean("Do you want to measure another filament?");	
					close("IF3D_SarcomereAnalysis.xls");				
				}
			}else {
				// SAVE RESULTS FOR CURRENT CARDIOMYOCITE WITHOUT FILAMENTS--
		
				selectWindow("Results");	
				roiManager("Reset");
				roiManager("Open", OutDir+File.separator+MyTitle_short+"_"+ss+"_ROI_CMs.zip");
				nCM=roiManager("count");
				run("Clear Results");
				close("Results");
				if(File.exists(output+File.separator+"IF3D_SarcomereAnalysis.xls"))
				{			
					//if exists add and modify
					open(output+File.separator+"IF3D_SarcomereAnalysis.xls");
					IJ.renameResults("Results");
					i=nResults;
					setResult("[Label]", i, MyTitle); 
					setResult("Slice", i, ss);
					setResult("# CM", i, nCM); 
					setResult("Area CM (um2)", i, CMarea);
					setResult("Orient CM (deg)", i, CMang);	
					setResult("# Fil", i, 0); 
					setResult("Orient Fil (deg)", i, 0); 						
					setResult("Dist Z-disks (um)", i, 0);
					setResult("Angular Second Moment", i, 0);
					setResult("Contrast", i, 0);
					setResult("Correlation", i, 0);
					setResult("Inverse Difference Moment", i, 0);
					setResult("Entropy", i, 0);				
					saveAs("Results", output+File.separator+"IF3D_SarcomereAnalysis.xls");
			
					
				}else{							
					setResult("[Label]", 0, MyTitle); 
					setResult("Slice", i, ss);
					setResult("# CM", 0, nCM); 
					setResult("Area CM (um2)", 0, CMarea);
					setResult("Orient CM (deg)", 0, CMang);	
					setResult("# Fil", 0, 0); 
					setResult("Orient Fil (deg)", 0, 0); 						
					setResult("Dist Z-disks (um)", 0, 0); 		
					setResult("Angular Second Moment", i, 0);
					setResult("Contrast", i, 0);
					setResult("Correlation", i, 0);
					setResult("Inverse Difference Moment", i, 0);
					setResult("Entropy", i, 0);
					saveAs("Results", output+File.separator+"IF3D_SarcomereAnalysis.xls");
				}
			}
		
			selectWindow("sarcomere");
			setTool("freehand");
			run("Original Scale");
			if (File.exists(OutDir+File.separator+MyTitle_short+"_"+ss+"_ROI_CMs.zip"))
				roiManager("Open", OutDir+File.separator+MyTitle_short+"_"+ss+"_ROI_CMs.zip");
			roiManager("Show All with [Label]s");
			roiManager("Show All");
			
			q=getBoolean("Do you want to select another cardiomyocite to analyze in the current slice?");
			close("IF3D_SarcomereAnalysis.xls");
		}
		
		close("sarcomere");
		close("temp");
		selectWindow(MyTitle);
		q0=getBoolean("Do you want to select another slice to analyze?");
	
	}
	
	showMessage("Done!");

}	



macro "SarcomereAnalysis Action Tool 1 Options" {
    
    Dialog.create("Parameters");

	Dialog.addMessage("Choose parameters")
	Dialog.addNumber("DapiChannel", nuclChannel);	
	Dialog.addNumber("SarcomerChannel", sarChannel);	
	Dialog.addNumber("Line Band", lineBand);	
	Dialog.addNumber("Default Tolerance", tolDefault);	
	Dialog.show();	
	nuclChannel = Dialog.getNumber();
	sarChannel= Dialog.getNumber();	
	lineBand = Dialog.getNumber();
	tolDefault= Dialog.getNumber();	
}




