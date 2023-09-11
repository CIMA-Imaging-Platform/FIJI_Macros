
var imageMenu = newMenu("Figure Menu Tool", newArray("Meta-D-Rex", "-", "LUT Channels Tool", "-", "Save TIFF...", "-", "Export SVG", "Export all images as SVG", "Export time series as SVGs", "-", "Import images from SVG", "-", "Create framed inset Zoom", "-", "Properties...", "Set Scale...", "-", "Scale Bar...", "-", "Calibration Bar...", "-", "Time Stamp", "-", "RGB Color", "Simulate Color Blindness"));

macro "Figure Menu Tool - CeeeL00f0L01f1C999L02f2D03CfffL13e3C999Df3D04CfffD14C38fL24d4CfffDe4C999Df4D05CfffD15C59fD25C6afD35C8cfD45C7bfD55C59fL65d5CfffDe5C999Df5D06CfffD16CbdfD26CbefL3646CcefL5666CbefD76C8bfL8696C9cfDa6CeeeDb6CadfDc6C9cfDd6CfffDe6C999Df6D07CfffD17C365D27C476D37C588D47C7aaD57CcefD67CdffL77d7CfffDe7C999Df7D08CfffD18C032D28C041D38C152D48C264D58C587D68CaccD78CcefD88CacfD98CcefLa8b8CeffLc8d8CfffDe8C999Df8D09CfffD19C010L2939C020D49C021D59C031L6979C041D89C153D99C254Da9C376Db9C7abDc9CbccDd9CfffDe9C999Df9D0aCfffD1aC037D2aC047L3a4aC147D5aC479D6aC579D7aC68aD8aC8acD9aCacdDaaCbcdLbacaCacdDdaCfffDeaC999DfaD0bCfffD1bC049L2b3bC159D4bC259D5bC37aD6bC58aD7bC58bD8bC8acD9bC9bcDabC9bdDbbCabdDcbCacdDdbCfffDebC999DfbD0cCfffL1cecC999DfcL0dfdCeeeL0efeL0fff" {
	
	figure_cmd = getArgument();
	
	if (figure_cmd == "Save TIFF...") {
		saveAs("Tiff");
		
	} else if (figure_cmd == "Time Stamp") {
		run("Label...");
	} else if (figure_cmd == "Simulate Color Blindness") {
		currentImageID = getImageID();
		currentImageName = getTitle();
		if (bitDepth() == 24) {
			setBatchMode(true);
			selectImage(currentImageID);
			run("Duplicate...", "title=[CDV_Protanopia_"+currentImageName+"]");
			run("Simulate Color Blindness", "mode=[Protanopia (no red)]");
			selectImage(currentImageID);
			run("Duplicate...", "title=[CDV_Deuteranopia_"+currentImageName+"]");
			run("Simulate Color Blindness", "mode=[Deuteranopia (no green)]");
			selectImage(currentImageID);
			run("Duplicate...", "title=[CDV_Tritanopia_"+currentImageName+"]");
			run("Simulate Color Blindness", "mode=[Tritanopia (no blue)]");
			run("Images to Stack", "  title=CDV_ use");
			setBatchMode(false);
		} else {
			exit("Works only on RGB images");
		}
		
	} else if (figure_cmd != "-") {
		run(figure_cmd);
	}
}
