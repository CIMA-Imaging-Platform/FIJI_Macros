// changelog December 2020
// automatic detection of main aortic ring and attached branches
// possibility of manually joining unattached branches
// skeletonization and skeleton analysis for branch number and length measurement

var minBranchLength=25;

macro "AorticRings Action Tool 1 - C010D06D08D09D0bD15D16D19D24D26D28D32D3fD4eD4fD50D51D5eD5fD62D63D6bD6eD74D7aD7bD88D89D8aD8cD9aD9bD9cDa7DaaDabDacDc7Dc8DcaDcbDd6Dd7DdfDe6De7De8DefDf4Df5Df6Df7C011D5bD65D84D97D9dDb2Db6DeaDf9C020D10D11D20D21D41D5cD6fD7dD82D83D8dD92Da1Da2Dc0Dd0De5DeeC707D2aD3dD69Da5DcfDdeDf2C010D00D01D02D03D04D05D07D0aD0cD12D13D14D17D18D1aD22D23D25D27D30D31D33D34D35D36D40D42D43D44D52D53D54D60D61D64D70D71D72D73D79D7eD80D81D8bD90D91D93D98D99Da0Da8Da9Db0Db7Db8Db9DbaDbbDc6Dc9Dd5Dd8Dd9DdaDe0De9Df0DfeDffC020D4dD6aD6cD6dD7cDb1Df8C828D0eD59D75D85DbfDc2Dc3DfcC303D0dD29D37Da3Da6Dc5DfdCa0aD1cD2eD4bD5aD96Da4Db3Db5Dc1Dc4De1De3DedDfaC2a4D1eD2cD2dD3aD3bD48D49D57D58D67D76D9fDafDbeDcdC859D0fD1dD1fD2bD39D66D68D77DaeDbdDceDdcDddDfbC202D1bD3eD8eDbcDf3C808D38D55D78D87D9eDccDdbDe2C333D4aD4cD5dD86Db4Dd3De4DecCa2aD3cD47D56D8fD95DadDd2DebC505D2fD45D46D7fD94Dd1Dd4Df1"{


roiManager("Reset");
run("Clear Results");
MyTitle=getTitle();
output=getInfo("image.directory");

//OutDir = output+File.separator+"AnalyzedImages";
OutDir = output+"AnalyzedImages";
File.makeDirectory(OutDir);

aa = split(MyTitle,".");
MyTitle_short = aa[0];


// INITIALIZATION
selectWindow(MyTitle);
getVoxelSize(rx, ry, rz, unit);
getDimensions(width, height, channels, slices, frames);


Dialog.create("Parameters");
Dialog.addMessage("Choose parameters")	
Dialog.addNumber("Min branch length ("+unit+")", minBranchLength);
Dialog.show();	
minBranchLength= Dialog.getNumber();


run("Colors...", "foreground=black background=white selection=green");
run("Set Measurements...", "area mean redirect=None decimal=2");


// MAX PROJECTION

run("Z Project...", "projection=[Max Intensity]");
rename("projection");

//run("Subtract Background...", "rolling=50");


// PROCESSING

// Directional filtering:
run("Anisotropic Diffusion 2D", "number=20 smoothings=2 keep=20 a1=0.50 a2=0.90 dt=20 edge=3");
rename("orig");


// Manual delineation of main aortic ring:

setTool("freehand");
waitForUser("Please draw the aortic ring and press OK");
type=selectionType();
if(type==-1) {
	waitForUser("No ring drawn. Please draw the aortic ring and press OK");
}
run("Create Mask");
rename("body");
run("Create Selection");
roiManager("Add");	// ROI 0 --> Body of the aortic ring
//close();


// Segment branches:

selectWindow("orig");
run("Select None");
run("Unsharp Mask...", "radius=5 mask=0.3");
setAutoThreshold("Default dark");
run("Threshold...");
setThreshold(35, 255);
waitForUser("Adjust threshold for branch detection and press OK");
run("Convert to Mask");
run("Analyze Particles...", "size=60-Infinity show=Masks add in_situ");
roiManager("show none");


// Get branches connected to the main body:

selectWindow("orig");
run("Select None");
run("Duplicate...", "title=attachedBranches");

n=roiManager("Count");
run("Clear Results");
selectWindow("body");
run("Select None");
roiManager("Deselect");
roiManager("Measure");
selectWindow("attachedBranches");	
for (i=1; i<n; i++)
{
	Ii=getResult("Mean",i);	
	if (Ii==0) {	
  		roiManager("Select", i);
		run("Clear", "slice");
  	}  	 	
}
run("Select None");
roiManager("Select", 0);
setBackgroundColor(255, 255, 255);
run("Clear", "slice");
run("Select None");
roiManager("Reset");

selectWindow("body");
run("Create Selection");
roiManager("Add");	// ROI 0 --> Body of the aortic ring
selectWindow("attachedBranches");
run("Create Selection");
roiManager("Add");	// ROI 1 --> Branches attached to the main body
close();
selectWindow("orig");
run("Duplicate...", "title=unattachedBranches");
roiManager("Select", newArray(0,1));
roiManager("Combine");
run("Clear", "slice");
run("Select None");
run("Create Selection");
roiManager("Add");	// ROI 2 --> Branches unattached to the main body
close();


// POSSIBILITY OF EDITING BRANCH DETECTION

selectWindow("orig");
selectWindow("projection");
wait(100);
roiManager("Select", 2);
roiManager("Set Color", "cyan");
roiManager("Select", 1);
roiManager("Set Color", "magenta");
roiManager("Select", 0);
roiManager("Set Color", "yellow");
roiManager("Show All");
roiManager("Show All without labels");
waitForUser("Automatic branch detection finished! Check branches ATTACHED (MAGENTA) and UNATTACHED (CYAN) to the main aortic ring.");
q=getBoolean("Would you like to attach an unattached branch?");
while(q) 
{
	setTool("freehand");
	waitForUser("Draw the attaching section between branches and press OK");
	type=selectionType();
	if(type==-1) {
		showMessage("No selection has been drawn, nothing will be attached");
	}
	else {

		selectWindow("orig");
		run("Restore Selection");
		setForegroundColor(0, 0, 0);
		run("Fill", "slice");
		run("Select None");
		roiManager("Deselect");
		roiManager("Select", newArray(1,2));
		roiManager("Delete");
		roiManager("Deselect");
		run("Select None");
		run("Analyze Particles...", "size=60-Infinity show=Masks add in_situ");
		roiManager("show none");		
		
		// Get branches connected to the main body:
		
		selectWindow("orig");
		run("Select None");
		run("Duplicate...", "title=attachedBranches");
		
		n=roiManager("Count");
		run("Clear Results");
		selectWindow("body");
		run("Select None");
		roiManager("Deselect");
		roiManager("Measure");
		selectWindow("attachedBranches");	
		for (i=1; i<n; i++)
		{
			Ii=getResult("Mean",i);	
			if (Ii==0) {	
		  		roiManager("Select", i);
				run("Clear", "slice");
		  	}  	 	
		}
		run("Select None");
		roiManager("Select", 0);
		setBackgroundColor(255, 255, 255);
		run("Clear", "slice");
		run("Select None");
		roiManager("Reset");
		
		selectWindow("body");
		run("Create Selection");
		roiManager("Add");	// ROI 0 --> Body of the aortic ring
		selectWindow("attachedBranches");
		run("Create Selection");
		roiManager("Add");	// ROI 1 --> Branches attached to the main body
		close();
		selectWindow("orig");
		run("Duplicate...", "title=unattachedBranches");
		roiManager("Select", newArray(0,1));
		roiManager("Combine");
		run("Clear", "slice");
		run("Select None");
		run("Create Selection");
		roiManager("Add");	// ROI 2 --> Branches unattached to the main body
		close();
		
		// POSSIBILITY OF EDITING BRANCH DETECTION
		
		selectWindow("projection");
		wait(100);
		roiManager("Select", 2);
		roiManager("Set Color", "cyan");
		roiManager("Select", 1);
		roiManager("Set Color", "magenta");
		roiManager("Select", 0);
		roiManager("Set Color", "yellow");
		roiManager("Show All");
		roiManager("Show All without labels");
		waitForUser("Branch detection updated! Check branches ATTACHED (MAGENTA) and UNATTACHED (CYAN) to the main aortic ring.");
				
	}
	q=getBoolean("Would you like to attach another unattached branch?");
}

// Clear remaining unattached branches:
selectWindow("orig");
roiManager("Select", 2);
run("Clear", "slice");
run("Select None");

// Clear main aortic ring:
selectWindow("orig");
roiManager("Select", 0);
run("Clear", "slice");
run("Select None");


// SKELETONIZE AND ANALIZE SKELETON:

selectWindow("orig");
run("Set Scale...", "distance=1 known="+rx+" unit="+unit);
run("Skeletonize (2D/3D)");
//run("Analyze Particles...", "size=4-Infinity show=Masks in_situ");
run("Analyze Particles...", "size="+minBranchLength+"-Infinity show=Masks in_situ");
run("Analyze Skeleton (2D/3D)", "prune=none show display");

// Filter branches applying a minimum length:
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
		setResult("Branch length ("+unit+")", cc, BrLength[i]);
		setResult("Euclidean distance ("+unit+")", cc, BrEuclDist[i]);
	}	
}
saveAs("Results", output+File.separator+MyTitle_short+"_QuantifiedBranches.xls");


// SAVE OUTPUT IMAGES

selectWindow("Tagged skeleton");
saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_taggedSkeleton.tif");
rename(MyTitle_short+"_taggedSkeleton.tif");

selectWindow("orig-labeled-skeletons");
saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_labeledSkeleton.tif");
rename(MyTitle_short+"_labeledSkeleton.tif");

selectWindow("projection");
roiManager("Show None");
roiManager("Select", 2);
roiManager("Delete");
roiManager("Show All");
roiManager("Show All without labels");
run("Flatten");
wait(100);
saveAs("Tiff", OutDir+File.separator+MyTitle_short+"_analyzedBranches.tif");
rename(MyTitle_short+"_analyzedBranches.tif");

selectWindow("projection");
close();
selectWindow(MyTitle);
close();
selectWindow("body");
close();
selectWindow("orig");
close();
selectWindow("Threshold");
run("Close");


run("Synchronize Windows");

showMessage("Aortic branches quantified!");

}

