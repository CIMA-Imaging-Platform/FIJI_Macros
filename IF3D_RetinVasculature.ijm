// changelog May 2021
// Segmentation of retin vasculature in 3D and mesh quantification

macro "IF3D_RetinVasculature Action Tool - N44C000D11D53D9kC000D41DalDckDelDj8DjaDkkC000D3jD7kDamDhnDk8Dk9DmbDnhC000D6nD74DfmDidDkjC000D20D82DblDdjDe0Df0Dg8DgbDh0DhcDi8DicDm3DnbC000D2dD4dD85DcgDdlDdnDfjDfkDi0Di5Dj0DkbDlaDmfDn3DnmC000D01D02D0hD61D62D7lD7nD8nDbkDdkDgcDgnDh1Di9Dj5DkcDkhDlbDliC000D10D1eD2fD31D4nD5lD5nD6lD93DagDajDcmDcnDejDgmDinDk0Dl5DmiC000D64D7mD84D9lDa3DakDd9DkdDlhDm0Dn9DncC000D1fD2eD36D37D4cD75D79D9mDa0DbjDclDdiDflDhlDhmDjbDjdDl0DmaDneC000D00D04D1gD3cD47D6gD73D8lD9jDb0Dg1Dh7DjjDkaDl4Dm8DnaC010D05D08D12D15D17D2cD69D72D94DbfDbgDbmDebDf8Dg9DjeDkiDmjDngDnkDnlC010D07D2nD51D54D6fD7fDa9Db8DdfDe3DeaDemDgkDhbDlcDm1C010D0iD52D5hD89D8eDekDenDgaDglDh9DhdDj1DjiDl3DmhC010D3dD3nD42D44D63Da8DbbDbnDcfDe9Df9Dj9Dk5Dm4DmgC010D13D16D4iD56D7eD8dD8mDaaDcaDd1Dd3DfaDfbDgjDibDljDn4C010D0gD49D4bDabDanDb9DcjDf3Dg0Di7Dk1Dk4DmmC010D2bD9aD9nDafDcbDf1DlfC010D0nD38D5fDfnDh8Di1DihDjgDjhDm5DmlDn0C010D06D1dD1jD22D57Da1DbeDc9Dd8DgdDiiDm9DmcC010D03D21D30D3eD99D9eDciDhaDhkDieDlnC010D0dD4mD60D67Db1DdaDdmDkfDlmC010D0jD14D43D48D5gD65D8kDe1De4Dg2Dg3DgfDiaDj2Dl1Dl8C010D1nDeiDf7DigDjkDk7DnnC010D23D2jD4gD58D9gDb6DbaDd4DfiDi6DkeC010D4hD6mD70D9fDimDjcDlgC010D0fD18D46D5mD71D90Db2DchDj4Dk6C020D09D6eDb3DdgDl9DndC020De8DnfC020D55D6kD7aD80C020D39D59D5bD68D91Dh5C020D3iD45D83D95D9bDc7DklDm7Dn8C020D0cD1hD1kD2gD3bD8fDdbDi3DijC020D29D9dDccDecDefDn7C020D6aDb7Dc8DkgDldC020D40Dc4DllC020D1cD2kD7dD7gC020D33Db5Dn1C020DbiDc5Dd5Di2C020D1iD8bDc2Dd2De7C020D24D3fDdhDf4Dh3DkmDlkC020D8jDc6C020D25De6Dl7DmeDmkC030D0eD1bD8aDc3C030D4lD9hDedDg7Dl6C030D19D26D32D3gDg5Dj3C030DaiDd7Dk3C030D81DfcC030D8hDjlDn5C030D0kD6hDb4DhhC030D98C030D27Dc1Dh2C030D3mC030D2iDdcDmdC030DknC030D1mDhfDjnC030D0aDa4Dd6C030D4jD66DikC030D28D34Dd0DnjC040DceDh6Dj6Dj7C040DheDifDm6C040D7cC040D92Dg6Dk2C040D50D5dDmnC040D0mD5cDehDffDniC040DilC040D77Dl2C040D1lD35Dg4C040D3hC040D0lD8gC040Df6DhjDi4C040Df2C040D0bC050DggC050D76DleC050DhgDn6C050Dm2C050D86D9iDddC050DegC050DaeC050D96C050DbcC050D5kD7hD7jDa7C050D5eDjfC050D1aC060DeeC060D97DfdC060D3kD6bC060Df5Dh4C060D8cDe5C060D6dDadC060D7iDgiDjmC060D2lD4fC060DfhDn2C060D2mC060D5aC070D2hC070D5iDa6C070DhiC070D8iC070De2DgeC070DahDdeC070Da2C080D3aC080D3lC080DbhC080D6iC080D78C080C090D4eC090DfeC090D4aC090D7bC0a0Dc0C0a0D88C0a0D2aC0a0C0b0DcdC0b0D9cC0b0Da5C0b0C0c0C0d0D6jC0d0DacC0d0C0e0C0f0D5jC0f0DghC0f0D4kD6cD87DbdDfg"
{
	
	
	function macroInfo() {
    /**
     * Muestra los metadatos, instrucciones de uso y parámetros de la herramienta
     * de análisis de vasculatura retinal 3D en una ventana HTML formateada.
     */
    
    // Información del script
    scripttitle = "Retinal Vasculature 3D Segmentation & Mesh Quantification";
    version = "2.0";
    date = "2026";
    author = "Tomas Muñoz Santoro";
    contact = "tmsantoro@unav.es";
    license = "MIT License";

    // Info de imagen de entrada
    imageAdquisition = "Confocal / Multiphoton Fluorescence";
    imageType = "3D Stack (Z-Series)";
    voxelSize = "Calibrated (um) - Crucial para BoneJ";
    format = "Bio-Formats compatible (czi, lsm, nd2, tif)";

    // Parámetros
    parameter1 = "Minimum Vessel Length (px): Filtro para eliminar ruido/artefactos.";
    parameter2 = "Calculate Thickness (BoneJ): Activa el cálculo de grosor de vasos y poros.";

    // Action tools (basado en el código analizado)
    buttom1 = "Manual ROI Z-Range: El usuario define los cortes inicial/final del análisis.";
    buttom2 = "Preprocessing: Aplicación de filtros Tubeness, CLAHE y Gaussian 3D.";

    // Características de salida (Excel)
    excel = "Quantification_RetinVasculature.xls";
    feature1 = "Vasculature Volume & Density (%)";
    feature2 = "Number of Vessels & Avg Length";
    feature3 = "Tortuosity (Arc-Chord Ratio)";
    feature4 = "Vessel Thickness (Avg/Std/Max)";
    feature5 = "Pore Diameter (Avg/Std/Max)";
    feature6 = "Segmented Tiff Stacks (AnalyzedImages folder)";
     
    showMessage("ImageJ Script Info", "<html>"
            +"<style>h1, h2 {margin-top: 5px; margin-bottom: 5px;} p{margin: 0px;padding: 0px;} ul, ol{margin-left: 20px;padding: 5px;} #list-style-3 {list-style-type: circle;}</style>"
            +"<h1><font size = 6 color = Teal>CIMA: Imaging Platform</h1>"
            +"<h1><font size = 5 color = Purple><i>Software Development Service</i></h1>"
            +"<p><font size = 2 color = Purple><i>ImageJ Macros - Retina Specialist Tool</i></p>"
            +"<h2><font size = 3 color = black>"+scripttitle+"</h2>"
            +"<p><font size = 2>Developed by "+author+"</p>"
            +"<p><font size = 2>Version: "+version+" ("+date+")</p>"
            +"<p><font size = 2>Contact: "+contact+"</p>" 
            +"<p><font size = 2>Distributed under the <a href = https://opensource.org/licenses/MIT/>MIT License</a></p>"
            
            +"<h2><font size = 3 color = black>Input Requirements</h2>"
            +"<ul id = list-style-3><font size = 2><li><b>Source:</b> "+imageAdquisition +"</li><li><b>Type:</b> "+imageType+"</li><li><b>Voxel:</b> "+voxelSize+"</li><li><b>Format:</b> "+format+"</li></ul>"
            
            +"<h2><font size = 3 color = black>Workflow Details</h2>"
            +"<ol><font size = 2><li>"+buttom1+"</li><li>"+buttom2+"</li></ol>"
            
            +"<h2><font size = 3 color = black>Parameters</h2>"
            +"<ul id = list-style-3><font size = 2>"
            +"<li>"+parameter1+"</li>"
            +"<li>"+parameter2+"</li></ul>"
            
            +"<h2><font size = 3 color = black>Output Metrics</h2>"
            +"<p><font size = 2><i>Results saved in: /AnalyzedImages/</i></p>"
            +"<p><font size = 2 color = Teal><b>Excel: "+excel+"</b></font></p>"
            +"<ul id = list-style-3><font size = 2>"
            +"<li>"+feature1+"</li><li>"+feature2+"</li><li>"+feature3+"</li>"
            +"<li>"+feature4+"</li><li>"+feature5+"</li><li>"+feature6+"</li></ul>"
            +"<br>");
	}
		
	run("Close All");
	
	macroInfo();
		
	// Open file:
	name=File.openDialog("Select image to analyze");
	run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	
	//--Parameters
	Dialog.create("Parameters for the analysis");
	Dialog.addMessage("Choose parameters")	
	Dialog.addNumber("Select minimum vessel length (in px) to discard short noisy artifacts", 5);
	Dialog.addCheckbox("Calculate vessel and pore thickness", false);
	Dialog.show();	
	minBranchLength= Dialog.getNumber();
	flagThickness= Dialog.getCheckbox();
		
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	OutDir = output+File.separator+"AnalyzedImages";
	File.makeDirectory(OutDir);
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	run("Colors...", "foreground=black background=white selection=yellow");
	run("Set Measurements...", "area mean integrated redirect=None decimal=2");
	
	Stack.getDimensions(width, height, channels, slices, frames);
	
	waitForUser("Go to the first slice for the analysis and press OK");
	selectWindow(MyTitle);
	z1 = getSliceNumber();
	
	waitForUser("Go to the last slice for the analysis and press OK");
	selectWindow(MyTitle);
	z2 = getSliceNumber();
		
	//--We need to take one extra slice from each side because tubeness makes them black and we will remove them:
	if(z1!=1) {
		z1 = z1-1;	
	}
	if(z2!=slices) {
		z2 = z2+1;
	}else if(z1==z2){
		z2=z1+1;
	}
	
	run("Make Composite","Display Mode=[Grayscale]");
	run("RGB Color", "slices keep");
	run("RGB to Luminance");
	close(MyTitle+"*");

	rename(MyTitle);
	run("Slice Keeper", "first="+z1+" last="+z2+" increment=1");
	rename("all");
	selectWindow(MyTitle);
	close();
	
	rename("orig");
		
	///// IMAGE PREPROCESSING//////
	
	//--Background subtraction
	run("Subtract Background...", "rolling=15 stack");
	run("Gaussian Blur...", "sigma=1 stack");
	
    getDimensions(width, height, channels, slices, frames);

    // Apply CLAHE (contrast enhancement) to each slice
    for (i = 1; i <= nSlices; i++) {
        setSlice(i);
        run("Enhance Local Contrast (CLAHE)", "blocksize=100 histogram=256 maximum=2 mask=*None* fast_(less_accurate)");
    }
	
    run("Gaussian Blur 3D...", "x=1 y=1 z=1");
	
	//--Steerable filtersa4
	getVoxelSize(vx, vy, vz, unit);
	//run("Tubeness", "sigma="+vx+" use");
	run("Tubeness", "sigma=5 use");
	
	selectWindow("orig");
	close();
	
	selectWindow("tubeness of orig");
	rename("orig");
	
	
	//run("Duplicate...", "title=orig duplicate range=1-"+slices);
	Stack.getDimensions(width, height, channels, slices, frames);
	if (slices>1){
		setSlice(floor(slices/2));
	}
	
	//--Enhance contrast
	run("Enhance Contrast...", "saturated=0.2 process_all");
	run("8-bit");
	
	/*
    // Apply CLAHE (contrast enhancement) to each slice
    Stack.getDimensions(width, height, channels, slices, frames);
    for (i = 1; i <= slices; i++) {
        setSlice(i);
        run("Morphological Filters", "operation=Closing element=Disk radius=1");
        run("Concatenate...", " title=orig open image1=orig image2=orig-Closing image3=[-- None --]");
    }
    */

    selectWindow("orig");
    
    //--Save preprocessed image
	selectWindow("orig");
	run("Green");
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_Enhanced.tif");
	wait(100);
	rename("orig");
										
	///// MASK GENERATION /////
	
	//--Ridge detection
	run("Green");
	run("Clear Results");
	//run("Ridge Detection", "line_width=2 high_contrast=100 low_contrast=10 estimate_width extend_line make_binary method_for_overlap_resolution=NONE sigma=1.08 lower_threshold=0.68 upper_threshold=6.97 minimum_line_length="+minBranchLength+" maximum=0 stack");

	selectWindow("orig");
	//minBranchLength =5;
	run("Ridge Detection", "line_width=3 high_contrast=255 low_contrast=10 estimate_width extend_line make_binary method_for_overlap_resolution=NONE sigma=1.37 lower_threshold=0.34 upper_threshold=11.05 minimum_line_length="+minBranchLength+" maximum=0 stack");
	wait(100);				
	rename("meshSegmented");
	
	run("Analyze Skeleton (2D/3D)", "prune=none show");
	selectWindow("Tagged skeleton");
	close();
	
	//--Filter branches applying a minimum length:
	run("Clear Results");
	IJ.renameResults("Branch information","Results");
	totBrNum = nResults;
	BrLength = newArray(totBrNum);
	BrEuclDist = newArray(totBrNum);
	for(i=0; i<totBrNum; i++) 
	{
		BrLength[i]=getResult("Branch length", i);
		BrEuclDist[i]=getResult("Euclidean distance", i);
	}
	run("Clear Results");
	for(i=0; i<totBrNum; i++) 
	{
		if(BrLength[i]>minBranchLength)
		{
			cc=nResults;
			setResult("Branch length", cc, BrLength[i]);
			setResult("Euclidean distance", cc, BrEuclDist[i]);
		}	
	}
	
	//--Get results
	selectWindow("Results");
	nFibers = nResults;
	print(nFibers);
	selectWindow("Results");
	run("Summarize");
	wait(100);
	selectWindow("Results");
	fiberLength_avg = getResult("Branch length", nFibers);				
	fiberLength_std = getResult("Branch length", nFibers+1);				
	fiberLength_min = getResult("Branch length", nFibers+2);				
	fiberLength_max = getResult("Branch length", nFibers+3);
	//print(fiberLength_avg);				
	//print(fiberLength_std);				
	//print(fiberLength_min);				
	//print(fiberLength_max);
	// Distance of shortest path for each branch:
	fiberShortest_avg = getResult("Euclidean distance", nFibers);				
	fiberShortest_std = getResult("Euclidean distance", nFibers+1);		
	
	//--Tortuosity
	tortuosity = fiberLength_avg/fiberShortest_avg;
	
	
	//--Save binary segmentation image
	selectWindow("meshSegmented");
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_Segmentation.tif");
	wait(100);
	rename("meshSegmented");
	
					
	// IMAGE ANALYSIS: BoneJ
	
	run("Clear Results");
	
	//--Calculate volume fraction 
	selectWindow("meshSegmented");
	run("Analyze Regions 3D", "volume surface_area surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
	selectWindow("meshSegmented-morpho");
	IJ.renameResults("Results");
	FV = getResult("Volume", 0);			// fiber volume
	TV = (width*height*slices)*(vx*vy*vz);	// total image volume
	PV = TV-FV;								// pore volume
	FDen = FV/TV*100;						// fiber percentage in total volume
	
	
	//--THICKNESS
	
	if (flagThickness)
	{
				
		run("Clear Results");
		
		// For Thickness measurements, we need isotropic voxels so we need to reslize Z to create cubic voxels:
		run("Reslice Z", "new="+vx);
		// We now need to binarize again:
		setThreshold(1, 255);
		run("Convert to Mask", "method=Otsu background=Light");
		
		//--Calculate Thickness (Legacy)
		run("Thickness", "thickness spacing");
		
		selectWindow("Resliced");
		close();
		
		//--Get Values
		selectWindow("Results");
		FbTh_avg=getResult("Tb.Th Mean (microns)",0);
		FbTh_std=getResult("Tb.Th Std Dev (microns)",0);
		FbTh_max=getResult("Tb.Th Max (microns)",0);
		TbSp_avg=getResult("Tb.Sp Mean (microns)",0);
		TbSp_std=getResult("Tb.Sp Std Dev (microns)",0);
		TbSp_max=getResult("Tb.Sp Max (microns)",0);
	
	}
	
	else {
	
		FbTh_avg=NaN;
		FbTh_std=NaN;
		FbTh_max=NaN;
		TbSp_avg=NaN;
		TbSp_std=NaN;
		TbSp_max=NaN;
	
	}
	
	
	//--Save results
	run("Clear Results");
	if(File.exists(output+File.separator+"Quantification_RetinVasculature.xls"))
	{	
		//if exists add and modify
		open(output+File.separator+"Quantification_RetinVasculature.xls");
		IJ.renameResults("Results");
	}
	i=nResults;
	setResult("[Label]", i, MyTitle); 
	setResult("Vasculature Volume (um3)",i,FV);
	setResult("Pore Volume (um3)",i,PV);
	setResult("Vasculature Density (%)",i,FDen);
	setResult("Number of Vessels",i,nFibers);
	setResult("Vessel Length Avg (um)",i,fiberLength_avg);
	setResult("Shortest Path Length Avg (um)",i,fiberShortest_avg);
	setResult("Tortuosity",i,tortuosity);
	//setResult("Vessel Length Std (um)",i,fiberLength_std);
	//setResult("Vessel Length Min (um)",i,fiberLength_min);
	//setResult("Vessel Length Max (um)",i,fiberLength_max);
	setResult("Vessel Thickness Avg (um)",i,FbTh_avg);
	setResult("Vessel Thickness Std (um)",i,FbTh_std);
	setResult("Vessel Thickness Max (um)",i,FbTh_max);
	setResult("Pore Diameter Avg (um)",i,TbSp_avg);
	setResult("Pore Diameter Std (um)",i,TbSp_std);
	setResult("Pore Diameter Max (um)",i,TbSp_max);
	
	saveAs("Results", output+File.separator+"Quantification_RetinVasculature.xls");
	
	run("Synchronize Windows");
	
	selectWindow("orig");
	rename("meshEnhanced");
	close("\\Others");
	//Clear unused memory
	wait(500);
	run("Collect Garbage");
	
	showMessage("Retin vasculature quantified!");
		
}




