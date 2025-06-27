
function macroInfo() {

/*  
	 *  Target User: Maite Huarte -> Jovanna.
	 */

	scripttitle= "Quantification of Centriolos Distances to each Nuclei in IF images";
	version= "1.01";
	date= "2024";
	

	//  Tests Images:

	imageAdquisition="Confocal Microscopy 3D stack with 2 channel: Dapi + Centriolos";
	imageType="8 or 16 bits";  
	voxelSize="Voxel size: um xyz";
	format="Format: Zeiss .czi";   
 
	 /*  GUI User Requierments:
	     - Choose parameters.
	     - Single File and Batch Mode
	     
	   Important Parameters: click Im or Dir + right button.
	 
	*/
	 	
	parameter1="Introduce Channels Order";
	parameter3="Cyto threshold";
	parameter4="Min nucleus size";
	parameter5="Max nucleus size";
	parameter6="Min nucleus circularity";
	parameter7="Max allowed distance to nucleus";
		  
	 //  2 Action tools:
	 buttom1="Im: Single File processing. Use Single file processing for fine tunning parameters";
	 buttom2="Dir: Batch Mode. Please tune parameters before using Batchmode";

	//  OUTPUT
	
	// Analyzed Images with ROIs

	excel="QuantificationResults_IF_Centriolos.xls";
	feature1 = "Label";
	feature2 = "# Cell"; 
	feature3 = "Nucl Equiv Radius (um)";
	feature4 = "# Assoc Centr";
	feature5 = "Dist. to Nucl center (um)"; 						
	feature6 = "Area centr (um^2)";		
	feature7 = "Accum Fluor";

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
	    +"<li>"+parameter3+"</li>"
	    +"<li>"+parameter4+"</li>"
	    +"<li>"+parameter5+"</li>"
	    +"<li>"+parameter6+"</li>"
	    +"<li>"+parameter7+"</li></ul>"
	    +"<p><font size=3  i>Quantification Results: </i></p>"
	    +"<p><font size=3 i>AnalyzedImages folder: Visualize Segmented Images</i></p>"
	    +"<p><font size=3  i>Excel "+excel+"</i></p>"
	    +"<ul id=list-style-3><font size=2  i><li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li><li>"+feature4+"</li>"
	    +"<li>"+feature5+"</li><li>"+feature6+"</li><li>"+feature7+"</li></ul>"
	    +"<h0><font size=5></h0>"
	    +"");

}



var cNucl=1	, cCent=2, thBlue=17, thCyto=17, findMaxima=35 ,minSize=500, maxSize=50000, minCirc=0, ThDist=6;

macro "InmunoFluor Action Tool 1 - Cf00T2d15IT6d10m"{
	
	close("*");
	
	macroInfo();
	
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	//setBatchMode(true);
	//print(name);
	inmunofluor("-","-",name);
	setBatchMode(false);
	showMessage("Done!");

}
		
macro "InmunoFluor Action Tool 2 - C00fT0b11DT9b09iTcb09r"{
	
	close("*");
	
	macroInfo();
	
	InDir=getDirectory("Choose a Directory");
	list=getFileList(InDir);
	L=lengthOf(list);

	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],".czi")){
			//analyze
			//d=InDir+list[j]t;
			name=list[j];
			//print(name);
			//setBatchMode(true);
			inmunofluor(InDir,InDir,list[j]);
			setBatchMode(false);
			}
	}
	showMessage("Done!");
}



macro "InmunoFluor Action Tool 1 Options" {
    Dialog.create("Parameters");

	Dialog.addMessage("Choose parameters");
	Dialog.addNumber("DAPI channel", cNucl);
	Dialog.addNumber("Centriolos Channel", cCent);
	Dialog.addNumber("Nucl threshold", thCyto);
	Dialog.addNumber("Centriolos threshold", thCyto);
	Dialog.addNumber("Detect Centriolos", findMaxima);
	Dialog.addNumber("Min nucleus size", minSize);	
	Dialog.addNumber("Max nucleus size", maxSize);	
	Dialog.addNumber("Min nucleus circularity", minCirc);
	Dialog.addNumber("Max allowed distance to nucleus", ThDist);			
	Dialog.show();	
	cNucl = Dialog.getNumber();
	cCent = Dialog.getNumber();
	thBlue = Dialog.getNumber();
	thCyto= Dialog.getNumber();	
	findMaxima = Dialog.getNumber();	
	minSize= Dialog.getNumber();
	maxSize= Dialog.getNumber();	
	minCirc= Dialog.getNumber();	
	ThDist= Dialog.getNumber();	
}

macro "InmunoFluor Action Tool 2 Options" {
    Dialog.create("Parameters");

	Dialog.addMessage("Choose parameters");
	Dialog.addNumber("DAPI channel", cNucl);
	Dialog.addNumber("Centriolos Channel", cCent);
	Dialog.addNumber("Nucl threshold", thCyto);
	Dialog.addNumber("Centriolos threshold", thCyto);
	Dialog.addNumber("Detect Centriolos", findMaxima);
	Dialog.addNumber("Min nucleus size", minSize);	
	Dialog.addNumber("Max nucleus size", maxSize);	
	Dialog.addNumber("Min nucleus circularity", minCirc);
	Dialog.addNumber("Max allowed distance to nucleus", ThDist);			
	Dialog.show();	
	cNucl = Dialog.getNumber();
	cCent = Dialog.getNumber();
	thBlue = Dialog.getNumber();
	thCyto= Dialog.getNumber();
	findMaxima = Dialog.getNumber();	
	minSize= Dialog.getNumber();
	maxSize= Dialog.getNumber();	
	minCirc= Dialog.getNumber();	
	ThDist= Dialog.getNumber();	
}




function inmunofluor(output,InDir,name)
{
	
	if (InDir=="-") {
		run("Bio-Formats", "open=["+name+"] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT");	
	}
	else {
		run("Bio-Formats", "open=["+InDir+File.separator+name+"] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT");	
	}
	
	
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	OutDir = output+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	
	// INITIALIZATION
	selectWindow(MyTitle);
	getPixelSize(unit, pixelWidth, pixelHeight);
	//print(unit);
	//print(pixelWidth);
	//print(pixelHeight);
	run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");	//remove scale
	Stack.setDisplayMode("composite");
	Stack.setChannel(cCent);
	run("Green");
	Stack.setChannel(cNucl);
	run("Blue");
	run("Duplicate...", "title=blueStack duplicate channels="+cNucl+"");
	selectWindow(MyTitle);
	run("Duplicate...", "title=CytoStack duplicate channels="+cCent);
	selectWindow(MyTitle);
	close();
	
	
	// GET 2D PROJECTIONS
	// DAPI (median projection)
	selectWindow("blueStack");
	run("Z Project...", "projection=Median");
	rename("blue");
	run("8-bit");
	run("Enhance Contrast", "saturated=0.35");
	selectWindow("blueStack");
	close();
	
	// Cyto (max projection)
	selectWindow("CytoStack");
	run("Gamma...", "value=1.40 stack");
	run("Z Project...", "projection=[Max Intensity]");
	rename("Cyto");
	run("8-bit");
	run("Green");
	selectWindow("CytoStack");
	close();
	
	run("Merge Channels...", "c2=Cyto c3=blue create keep");
	rename("merge");
	run("RGB Color");
	selectWindow("merge");
	close();
	selectWindow("merge (RGB)");
	rename("merge");
		
	run("Colors...", "foreground=black background=white selection=red");
	run("Set Measurements...", "area mean modal min centroid display redirect=None decimal=2");
		
	// DETECT BLUE--
	
	//run("Duplicate...", "title=blue duplicate channels=1");
	selectWindow("blue");
	run("Duplicate...", "title=aa");
	//run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");	//remove scale
	run("Subtract Background...", "rolling=150");	
	run("8-bit");
	run("Mean...", "radius=2");
	setAutoThreshold("Default dark");
	//getThreshold(lower,upper);
	//setThreshold(lower*thBlueFactor, 255);
	//thBlue=17;
	setThreshold(thBlue, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Median...", "radius=2");
	run("Open");
	run("Fill Holes");
	run("Adjustable Watershed", "tolerance=1");
	run("Analyze Particles...", "size="+minSize+"-"+maxSize+" circularity="+minCirc+"-1.00 show=Masks display clear add in_situ");
	//run("Analyze Particles...", "size=500-50000 pixel circularity=0.2-1.00 show=Masks display clear add in_situ");
	selectWindow("aa");
	close();
	selectWindow("blue");
	run("8-bit");
	nCells=nResults;
	An=newArray(nCells);
	Rn=newArray(nCells);
	xn=newArray(nCells);
	yn=newArray(nCells);
	for(i=0;i<nCells;i++){
		atemp=getResult("Area",i);
		An[i]=atemp*pixelWidth*pixelWidth;	//in micras
		Rn[i]=sqrt(An[i]/PI);	//equivalent radius
		xn[i]=getResult("X",i);
		yn[i]=getResult("Y",i);
	}
	selectWindow("blue");
	//close();
	roiManager("Save", output+File.separator+"ROI_nuclei.zip");
	//roiManager("Save", OutDir+File.separator+MyTitle_short+"_ROI.zip");
	roiManager("Reset");
	
	// DETECT CENTRIOLES IN Cyto--
	
	run("Clear Results");
	selectWindow("Cyto");
	run("Subtract Background...", "rolling=2");
	// Calculate modal value and subtract it:
	run("Set Measurements...", "area mean modal min centroid display redirect=None decimal=2");
	run("Measure");
	mod=getResult("Mode",0);
	print("Mode Cyto: "+mod);
	selectWindow("Cyto");
	run("Subtract...", "value="+mod);
	
	// Find maxima in Cyto:
	selectWindow("Cyto");
	run("Find Maxima...", "noise="+findMaxima+" output=[Single Points]");
	rename("CytoMaxima");
	
	// Threshold Cyto image:
	selectWindow("Cyto");
	run("Duplicate...", "title=CytoMask");
	//run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");	//remove scale
	setThreshold(thCyto, 255);
	//setThreshold(32, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Analyze Particles...", "size=2-Inf show=Masks in_situ");
	run("Create Selection");
	//roiManager("Add");
	selectWindow("CytoMaxima");
	run("Select None");
	run("Restore Selection");
	setBackgroundColor(255, 255, 255);
	run("Clear Outside");
	run("Select None");
	
	/*
	selectWindow("CytoMaxima");
	run("Find Maxima...", "noise=10 output=[Point Selection] light");
	setTool("multipoint");
	run("Point Tool...", "selection=Cyto cross=White marker=Small");
	selectWindow("CytoMask");
	run("Restore Selection");
	*/
	
	// Marker-controlled Watershed in Cyto image, using CytoMaxima as seeds and CytoMask as mask:
	run("Marker-controlled Watershed", "input=Cyto marker=CytoMaxima mask=CytoMask binary calculate use");
	//run("Marker-controlled Watershed", "input=Cyto marker=CytoMaxima mask=CytoMask binary use");
	selectWindow("Cyto-watershed");
	//run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");	//remove scale
	run("8-bit");
	setThreshold(1, 255);
	run("Convert to Mask");
	run("Analyze Particles...", "size=0-Inf show=Masks display clear add in_situ");
	roiManager("Save", output+File.separator+"ROI_centrioles.zip");
	
	selectWindow("Cyto-watershed");
	close();
	selectWindow("CytoMaxima");
	close();
	selectWindow("CytoMask");
	close();
	
	// Measure intensities:
	run("Clear Results");
	run("Set Measurements...", "area centroid integrated display redirect=None decimal=2");
	selectWindow("Cyto");
	roiManager("Deselect");
	roiManager("Measure");
	nCentrs=nResults;
	Iacc=newArray(nCentrs);
	Ac=newArray(nCentrs);
	xc=newArray(nCentrs);
	yc=newArray(nCentrs);
	for(i=0;i<nCentrs;i++){
		Iacc[i]=getResult("RawIntDen",i);
		atemp=getResult("Area",i);
		Ac[i]=atemp*pixelWidth*pixelWidth;	//in micras
		xc[i]=getResult("X",i);
		yc[i]=getResult("Y",i);
	}
	
	selectWindow("Cyto");
	//close();
	
	
	// Associate each centriole to the closest nucleus:
	AssocNucl=newArray(nCentrs);
	Dist2nucl=newArray(nCentrs);
	for(i=0;i<nCentrs;i++){
		distVec=newArray(nCells);	
		for(j=0;j<nCells;j++){
			distVec[j]=EuclDist(xc[i],yc[i],xn[j],yn[j]);		
		}	
		rankPos = Array.rankPositions(distVec);	
		AssocNucl[i]=rankPos[0]+1;	// le sumo 1 para empezar en 1	
		Dist2nucl[i]=distVec[rankPos[0]]*pixelWidth;
	}
	
	
	// FILTER OUT CENTRIOLES TOO FAR FROM THE CLOSEST NUCLEUS:
	flagFirst=true;
	for(i=0;i<nCentrs;i++){
		if (Dist2nucl[i]-Rn[AssocNucl[i]-1]>ThDist)
		{
			if(flagFirst) {
				CentrsOut=newArray(1);
				CentrsOut[0]=i;
				flagFirst=false;
			}
			else {
				CentrsOut = Array.concat(CentrsOut, i);
			}			
		}
	}
	if(!flagFirst) {
		for(i=0;i<CentrsOut.length;i++){
			/*Ac=newArray(1,2,3,4,5);
			CentrsOut=4;
			Ac1 = Array.slice(Ac, 0, CentrsOut);
			Array.show(Ac1);
			Ac2 = Array.slice(Ac, CentrsOut+1);
			Array.show(Ac2);*/
			// Ac:
			Ac1 = Array.slice(Ac, 0, CentrsOut[i]-i);
			Ac2 = Array.slice(Ac, CentrsOut[i]-i+1);
			Ac = Array.concat(Ac1,Ac2);
			// Iacc:
			Iacc1 = Array.slice(Iacc, 0, CentrsOut[i]-i);
			Iacc2 = Array.slice(Iacc, CentrsOut[i]-i+1);
			Iacc = Array.concat(Iacc1,Iacc2);
			// xc:
			xc1 = Array.slice(xc, 0, CentrsOut[i]-i);
			xc2 = Array.slice(xc, CentrsOut[i]-i+1);
			xc = Array.concat(xc1,xc2);
			// yc:
			yc1 = Array.slice(yc, 0, CentrsOut[i]-i);
			yc2 = Array.slice(yc, CentrsOut[i]-i+1);
			yc = Array.concat(yc1,yc2);
			// AssocNucl:
			AssocNucl1 = Array.slice(AssocNucl, 0, CentrsOut[i]-i);
			AssocNucl2 = Array.slice(AssocNucl, CentrsOut[i]-i+1);
			AssocNucl = Array.concat(AssocNucl1,AssocNucl2);
			// Dist2nucl:
			Dist2nucl1 = Array.slice(Dist2nucl, 0, CentrsOut[i]-i);
			Dist2nucl2 = Array.slice(Dist2nucl, CentrsOut[i]-i+1);
			Dist2nucl = Array.concat(Dist2nucl1,Dist2nucl2);
			// ROIs:
			roiManager("Deselect");
			roiManager("Select",CentrsOut[i]-i);	
			roiManager("Delete");
		}
	}
	roiManager("Save", output+File.separator+"ROI_centrioles.zip");
	nCentrs = roiManager("count");
	
	
	// RESULTS--
	
	run("Clear Results");
	if(File.exists(output+File.separator+"QuantificationResults_IF_Centriolos.xls"))
	{
		
		//if exists add and modify
		open(output+File.separator+"QuantificationResults_IF_Centriolos.xls");
		centrCounter=newArray(nCells);	// counter of how many centrioles per cell
		for(k=0;k<nCells;k++){
			flagNoCentr=true;	
			centrCounter[k]=0;
			for(j=0;j<nCentrs;j++){
				if(AssocNucl[j]-1==k) {
					i=nResults;
					setResult("Label", i, MyTitle); 
					setResult("# Cell", i, k+1); 
					setResult("Nucl Equiv Radius ("+unit+")", i, Rn[k]);
					setResult("# Assoc Centr", i, j+1);
					setResult("Dist. to Nucl center ("+unit+")", i, Dist2nucl[j]); 						
					setResult("Area centr ("+unit+"^2)", i, Ac[j]);		
					setResult("Accum Fluor", i, Iacc[j]);
					flagNoCentr=false;	
					centrCounter[k]=centrCounter[k]+1;			
				}		
			}
			if(flagNoCentr) {
				i=nResults;
				setResult("Label", i, MyTitle); 
				setResult("# Cell", i, k+1); 
				setResult("Nucl Equiv Radius ("+unit+")", i, Rn[k]);
			}
					
		}		
		saveAs("Results", output+File.separator+"QuantificationResults_IF_Centriolos.xls");
	
		// GET NUMBER OF CELLS WITH EACH NUMBER OF CENTRIOLES:
		//centrCounter=newArray(2,4,1,2,3,1,0,2,1,0,3);
		Array.getStatistics(centrCounter, min, max, mean, stdDev);
		numCentrs=newArray(max+1);
		Array.fill(numCentrs,0);	//start all with 0's
		for(k=0;k<centrCounter.length;k++){
			tt=centrCounter[k];
			numCentrs[tt]=numCentrs[tt]+1;
		}
		
		// Save these results in another Excel:
		run("Clear Results");
		open(output+File.separator+"SummaryCentriolesPerCell.xls");
		i=nResults;
		setResult("Label", i, MyTitle); 
		for(j=0;j<numCentrs.length;j++){
			setResult("Cells with "+j+" centrioles", i, numCentrs[j]); 
		}
		saveAs("Results", output+File.separator+"SummaryCentriolesPerCell.xls");	
		
	}
	
	else
	{
		
		centrCounter=newArray(nCells);	// counter of how many centrioles per cell
		for(k=0;k<nCells;k++){
			flagNoCentr=true;	
			centrCounter[k]=0;
			for(j=0;j<nCentrs;j++){
				if(AssocNucl[j]-1==k) {
					i=nResults;
					setResult("Label", i, MyTitle); 
					setResult("# Cell", i, k+1); 
					setResult("Nucl Equiv Radius ("+unit+")", i, Rn[k]);
					setResult("# Assoc Centr", i, j+1);
					setResult("Dist. to Nucl center ("+unit+")", i, Dist2nucl[j]); 						
					setResult("Area centr ("+unit+"^2)", i, Ac[j]);		
					setResult("Accum Fluor", i, Iacc[j]);
					flagNoCentr=false;	
					centrCounter[k]=centrCounter[k]+1;			
				}		
			}
			if(flagNoCentr) {
				i=nResults;
				setResult("Label", i, MyTitle); 
				setResult("# Cell", i, k+1); 
				setResult("Nucl Equiv Radius ("+unit+")", i, Rn[k]);
			}
					
		}		
		saveAs("Results", output+File.separator+"QuantificationResults_IF_Centriolos.xls");
	
		// GET NUMBER OF CELLS WITH EACH NUMBER OF CENTRIOLES:
		//centrCounter=newArray(2,4,1,2,3,1,0,2,1,0,3);
		Array.getStatistics(centrCounter, min, max, mean, stdDev);
		numCentrs=newArray(max+1);
		Array.fill(numCentrs,0);	//start all with 0's
		for(k=0;k<centrCounter.length;k++){
			tt=centrCounter[k];
			numCentrs[tt]=numCentrs[tt]+1;
		}
		
		// Save these results in another Excel:
		run("Clear Results");		
		setResult("Label", 0, MyTitle); 
		for(j=0;j<numCentrs.length;j++){
			setResult("Cells with "+j+" centrioles", 0, numCentrs[j]); 
		}
		saveAs("Results", output+File.separator+"SummaryCentriolesPerCell.xls");	
		
	}
	
	
	// DRAW:
	
	selectWindow("merge");
	close();
	selectWindow("blue");
	run("Blue");
	selectWindow("Cyto");
	run("Green");
	run("Merge Channels...", "c2=Cyto c3=blue create");
	rename("merge");
	run("RGB Color");
	selectWindow("merge");
	run("Close");
	selectWindow("merge (RGB)");
	rename("merge");
	
	roiManager("Reset");
	roiManager("Open", output+File.separator+"ROI_nuclei.zip");
	selectWindow("merge");
	run("Select None");
	roiManager("Show All");
	roiManager("Show None");
	roiManager("Show All with Labels");
	roiManager("Set Color", "yellow");
	roiManager("Set Line Width", 1);
	wait(500);
	run("Flatten");
	
	roiManager("Reset");
	roiManager("Open", output+File.separator+"ROI_centrioles.zip");
	selectWindow("merge-1");
	run("Select None");
	roiManager("Show All");
	roiManager("Show None");
	roiManager("Show All without Labels");
	roiManager("Set Color", "red");
	roiManager("Set Line Width", 1);
	run("Flatten");
	/*
	run("Colors...", "foreground=red background=black selection=yellow"); 
	setFont("Serif", 8, "antiliased");
	//set the label font size.
	for (i=0; i<nCentrs; i++) {
		roiManager("Select", i);
		getSelectionBounds(x, y, width, height);	
		drawString(i, x, y);
		//roiManager("Select", i);
		//roiManager("Draw");
	}
	*/
	wait(500);
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_analyzed.tif");	
	wait(500);
	
	if (InDir!="-") {
	close(); }
	
	selectWindow("merge");
	close();
	selectWindow("merge-1");
	close();

}


function EuclDist (x1,y1,x2,y2) {
	return sqrt(pow( x1 - x2, 2 ) + pow( y1 - y2, 2 ) );	
}



