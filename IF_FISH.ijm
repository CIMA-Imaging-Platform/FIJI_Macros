// changelog February 2022
// Automatic positive red and green fluorescence measurement
// Manual selection of regions of interest
// Background signal subtraction by manual measurement of basal signal

var nDAPI=1, nGreen=2, nRed=2, diskRad=12, minG=0, maxG=120, minR=0, maxR=120;

macro "FISH Action Tool 1 - Ca3fT0b10FT6b10IT8b10STfb10H"{	

	
	run("Close All");
	
	//--Ask for image for the analysis
	name=File.openDialog("Seleccione una imagen a preprocesar");
	run("Bio-Formats Importer", "open=["+name+"] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1"); 
	
	
	Dialog.create("Parametros para el analisis");
	// Channels:
	Dialog.addMessage("Indique numero de canales adquiridos de cada color")	
	Dialog.addNumber("DAPI", nDAPI);	
	Dialog.addNumber("Rojo", nRed);
	Dialog.addNumber("Verde", nGreen);	
	Dialog.show();	
	nDAPI= Dialog.getNumber();
	nRed= Dialog.getNumber();
	nGreen= Dialog.getNumber();
	
	
	roiManager("Reset");
	run("Clear Results");
	MyTitle=getTitle();
	output=getInfo("image.directory");
	
	OutDir = output+File.separator+"Procesadas";
	File.makeDirectory(OutDir);
	
	aa = split(MyTitle,".");
	MyTitle_short = aa[0];
	
	run("Colors...", "foreground=black background=white selection=yellow");
	run("Set Measurements...", "area redirect=None decimal=2");
	
	selectWindow(MyTitle);	
	rename("orig");
	
	//Stack.setDisplayMode("composite");
	
	
	//--DAPI: if there is more than one DAPI channel, create max projection
	
	run("Duplicate...", "title=DAPI duplicate channels=1-"+nDAPI);
	if(nDAPI>1) {
		run("Z Project...", "projection=[Max Intensity]");
		run("Blue");
		rename("proj");
		selectWindow("DAPI");
		close();
		selectWindow("proj");
		rename("DAPI");
	}
	
	
	//--RED: enhance each red channel and combine them by avg projection
	
	for (i = 1; i <= nRed; i++) {
		ch = nDAPI+i;
		selectWindow("orig");	
		run("Duplicate...", "title=r"+i+" duplicate channels="+ch);
		wait(50);
		//--Remove out-of-focus light and keep only defined FISH spots using a white top-hat filter
		  //diskRad=12;
		run("Morphological Filters", "operation=[White Top Hat] element=Disk radius="+diskRad);
		rename("temp");
		selectWindow("r"+i);
		close();
		selectWindow("temp");
		rename("r"+i);
	}
	
	if(nRed>1) {
		for (i = 1; i < nRed; i++) {
			i2 = i+1;
			run("Concatenate...", "  image1=r1 image2=r"+i2+" image3=[-- None --]");
			rename("r1");
		}
		run("Z Project...", "projection=[Average Intensity]");
		rename("red");
		selectWindow("r1");
		close();
		selectWindow("red");
		rename("r1");
	}
	
	selectWindow("r1");
	rename("red");
	run("Red");
	//setMinAndMax(40, 120);
	setMinAndMax(minR, maxR);
	run("Brightness/Contrast...");
	waitForUser("Revise el ajuste de contraste para el rojo y modifique el minimo o maximo si fuese necesario. Pulse OK al finalizar.");
	run("Apply LUT");
	
	
	//--GREEN: enhance each green channel and combine them by avg projection
	
	for (i = 1; i <= nGreen; i++) {
		ch = nDAPI+nRed+i;
		selectWindow("orig");	
		run("Duplicate...", "title=g"+i+" duplicate channels="+ch);
		wait(50);
		//--Remove out-of-focus light and keep only defined FISH spots using a white top-hat filter
		  //diskRad=12;
		run("Morphological Filters", "operation=[White Top Hat] element=Disk radius="+diskRad);
		rename("temp");
		selectWindow("g"+i);
		close();
		selectWindow("temp");
		rename("g"+i);
	}
	
	if(nGreen>1) {
		for (i = 1; i < nGreen; i++) {
			i2 = i+1;
			run("Concatenate...", "  image1=g1 image2=g"+i2+" image3=[-- None --]");
			rename("g1");
		}
		run("Z Project...", "projection=[Average Intensity]");
		rename("green");
		selectWindow("g1");
		close();
		selectWindow("green");
		rename("g1");
	}
	
	selectWindow("g1");
	rename("green");
	run("Green");
	//setMinAndMax(40, 120);
	setMinAndMax(minG, maxG);
	run("Brightness/Contrast...");
	waitForUser("Revise el ajuste de contraste para el verde y modifique el minimo o maximo si fuese necesario. Pulse OK al finalizar.");
	run("Apply LUT");
	
	
	//--MERGE THE THREE CHANNELS:
	
	run("Merge Channels...", "c1=red c2=green c3=DAPI");
	rename("final");
	selectWindow("orig");
	close();
	selectWindow("final");
	
	q=getBoolean("Desea guardar la imagen obtenida y continuar, o descartarla y volver a realizar el procesado?","Guardar","Descartar");
	if(!q) {
		exit("Imagen descartada");
	}
	
	saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_procesada.tif");
	wait(500);
	
	showMessage("Imagen guardada!");

}


macro "FISH Action Tool 2 - N44C223D1dD1gD21D2dD3dD3gD4dD4eD4gD9fDafDd4Dd5DddDdjDdmDe4DejDekDemDf3DfjDfmDgjDgmDj7Dj9DjkDk7Dk9DkmDl7Dl8DljDm7DmaDmlDmmC79bD2kD3kD3lD4kD4lD4mD55D67D6eD6gD79D7aD7dD7gD89D8aD8dD8gD99D9aD9eDa8Da9DaaDaeDc4DcmDd1Dd3De1De2Df2Dh1Dh2DhkDj1DklDnjC666D19D1aD1fD28D34D38D3fD45D49D4aD4fD5dD5gD7jD7lD7mD81D8mD9mDa4DakDalDamDd8Dd9DdaDe8Df8Dg8Dg9DgaDi7Di9DjbDjfDjgDkaDlbDlfDmbDmfCcbbD0hD40D5bD5cD65D6mD70D7iD7nD80D8iD8kD8lD9kDb5DbjDbkDblDbmDd6De6Df6Dg6Dh7Dh8Dh9DhaDhfDieDihDnbDneDnfDngDnnC257D12D1jD2eD2jD3jD4jD7eD7fD88D8eD8fD9dD9gDadDagDe3Df1Dg1Dg2Dg3DilDimDjjDjlDjmDjnDkjDkkDknDlkDllDlmDlnDmjDmkDmnCaaaD07D08D0aD0dD0eD0gD10D30D57D58D5hD6kD8nD9iDaiDb1Db3Db4DcbDchDdiDeiDfiDgiDhnDi1DigDj6DjcDk6DkcDlhDm6Dn7DnaDnmC888D1bD25D35D3bD4bD52D53D5eD5jD6fD73D74D82D85D87D92Da2DahDcdDceDcfDcgDcjDdbDdhDenDfnDgbDjeDkfDlgDm1DmeDmgCceeD1nD2nD4nD50D5iD6cD6iD76D7cD8cD96D9bD9cDa6DabDacDc6Df0Dg0Di2DiiDj0Dj2Dj4Dk0Dk2Dk3Dk5Dl0Dl2Dl3Dl5Dm0Dm3Dm4Dm5DnhC445D11D13D14D17D1eD22D23D2fD2gD32D33D42D43D71D8jD9jDa1DajDd7DdeDdfDdgDdkDe5De7DedDeeDf4Df7DfdDfkDg7DgdDgkDglDjdDl9DlaDm9C9abD02D03D04D1kD1lD1mD20D2lD2mD3mD4cD5mD68D6dD84D93D95Da3Da5DbdDbeDbfDbgDh3Dh4Dh5DifDjhDk1DkeDl1DmhDn9DnkC778D15D1hD29D2aD2hD39D3aD3hD44D4hD8hD94D97D9hDc2Dc5DdnDe9DeaDf5Df9DfaDg5DgnDhjDhmDi8DiaDkbDkgCdcdD00D0cD0jD16D1iD26D2iD36D3iD46D4iD6bD6nD86D90D9lDa0Db7DbnDc3DciDd0DdcDe0DecDfcDgcDhbDhhDhiDi3Di6DicDkiDliDn1C556D18D24D27D31D37D3eD41D47D48D77D78D7hD91D98Da7Dd2DdlDefDegDelDfeDffDfgDflDg4DgeDgfDggDijDikDj8DjaDk8DkdDldDm8DmdCbbcD05D09D0bD0fD59D5aD5kD5lD62D63D64D69D6aD6hD7bD8bDb2DbhDc1DcnDhdDheDhgDi4Dj3DjiDk4Dl4Dl6DlcDleDm2DmcDmiDn8DndDnlC999D01D1cD2bD2cD3cD51D54D5fD61D6jD6lD72D75D7kD83D9nDanDc7Dc8Dc9DcaDckDclDebDehDfbDfhDghDhlDibDidDinDkhCeeeD06D0iD0kD0lD0mD0nD3nD56D5nD60D66Db0Db6Db8Db9DbaDbbDbcDbiDc0DccDh0Dh6DhcDi0Di5Dj5Dn0Dn2Dn3Dn4Dn5Dn6DncDni"{	

	
	idsImages = newArray(100);
	namesImages = newArray(100);
	nRois = newArray(100);
	ccIm = 0;
	ccRoi = 0;
	q=getBoolean("Desea anotar celulas en una imagen?");
	while(q) {
		
		roiManager("Reset");
		
		// Annotate:
		roiManager("Show All without labels");
		setTool("freehand");
		waitForUser("Abra la imagen y anote las celulas que desee trazando el contorno y pulsando la tecla 'T' para guardarlas. Pulse OK cuando haya terminado con esa imagen");
		roiManager("deselect");
		
		// Get image and ROI data:
		idsImages[ccIm] = getImageID();
		nn = roiManager("count");
		ccRoi = ccRoi + nn;
		nRois[ccIm] = nn;
			
		if(ccIm==0) {   //first image
			output=getInfo("image.directory");
			OutDir = output+File.separator+"ROIs";
			File.makeDirectory(OutDir);
		}
		
		// Current image filename:
		MyTitle=getTitle();
		aa = split(MyTitle,".");
		MyTitle_short = aa[0];
		namesImages[ccIm] = MyTitle_short;
	
		// Save ROIs:
		roiManager("deselect");
		roiManager("save", OutDir+File.separator+MyTitle_short+"_ROI.zip");
	
		ccIm++;
		
		q=getBoolean("Desea anotar celulas en una nueva imagen?");	
		
	}
	
	
	//--Load annotated ROIs and create stack of cells:
	
	run("Colors...", "foreground=black background=white selection=yellow");
	for (i = 0; i < ccIm; i++) {
	
		// Get current image and ROIs:
		id = idsImages[i];
		selectImage(id);
		MyTitle_short = namesImages[i];	
		roiManager("Reset");	
		roiManager("Open", OutDir+File.separator+MyTitle_short+"_ROI.zip");
		nn = nRois[i];
	
		// Generate each ROIs image:
		for (j = 0; j < nn; j++) {
			selectImage(id);
			roiManager("select", j);
			run("Duplicate...", "title=cell");		
			setBackgroundColor(0,0,0);
			run("Clear Outside");
			run("Flatten");		//cell images will be automatically numbered as "cell-1", "cell-2"...
			selectWindow("cell");
			close();		
		}	
		
	}
	
	// Generate stack of individual annotated cells:
	run("Images to Stack", "method=[Copy (center)] name=StackOfCells title=cell use");
	
	
	//--Save original images with labeled annotations
	
	OutDir2 = output+File.separator+"Anotadas";
	File.makeDirectory(OutDir2);
	ccRoi = 0;
	for (i = 0; i < ccIm; i++) {
	
		// Get current image and ROIs:
		id = idsImages[i];
		selectImage(id);
		MyTitle_short = namesImages[i];	
		roiManager("Reset");	
		roiManager("Open", OutDir+File.separator+MyTitle_short+"_ROI.zip");
		nn = nRois[i];
			
		// Rename ROIs:
		for (j = 0; j < nn; j++) {
			iROI = ccRoi+j+1;
			roiManager("Select", j);
			roiManager("Rename", "cell-"+iROI);
			Roi.setFontSize(24);
		}
		ccRoi = ccRoi + nn;
	
		// Flatten ROIs and save image:
		selectImage(id);
		run("From ROI Manager");
		Overlay.useNamesAsLabels(true);
		Overlay.drawLabels(true);
		Overlay.setLabelFontSize(28, 'back');
		Overlay.setStrokeColor("yellow");
		Overlay.setStrokeWidth(2)
		Overlay.flatten;
		saveAs("Jpeg", OutDir2+File.separator+MyTitle_short+"_anotada.jpg");
		wait(50);
		close();
		selectImage(id);
		close();
	
	}
	
	
	//--Create mosaic of cells (20 cells per mosaic)
	
	OutDir3 = output+File.separator+"Mosaicos";
	File.makeDirectory(OutDir3);
	
	selectWindow("StackOfCells");
	nMosaics = Math.ceil(ccRoi/20);
	
	for (i = 0; i < nMosaics; i++) {
		
		selectWindow("StackOfCells");
		first = 20*i+1;
		last = first+20-1;
		run("Make Montage...", "columns=5 rows=4 scale=1 first="+first+" last="+last+" font=16 label");
		wait(50);
		iMosaic = i+1;
		rename("Mosaic"+iMosaic);
		saveAs("Tiff", OutDir3+File.separator+"Mosaic"+iMosaic+".tif");
		rename("Mosaic"+iMosaic);
		
	}
	
	selectWindow("StackOfCells");
	close();
	
	showMessage("Mosaicos creados!");

}

