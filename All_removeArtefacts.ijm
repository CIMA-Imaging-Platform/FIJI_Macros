


macro "removeArtefacts Action Tool 1 - Cf00T2d15IT6d10m"
{	
	
	//just one file
	name=File.openDialog("Select File");
	//print(name);
	
	print("Processing "+name);

	removeArtefacts("-","-",name);
	
	run("Collect Garbage");
}
	
	/*
macro "removeArtefacts Action Tool 2 - C00fT0b11DT9b09iTcb09r"{

	run("Close All");
	
	InDir=getDirectory("Choose Tiles' directory");
	list=getFileList(InDir);
	L=lengthOf(list);
	for (j=0; j<L; j++)
	{
		if(endsWith(list[j],"svs")){
			
			run(""
	
			name=list[j];
			print("Processing "+name);
			removeArtefacts(InDir,InDir,list[j]);
			
		}
			
			run("Collect Garbage");
	}
	
	showMessage("Done!");

}

*/
function removeArtefacts(output,InDir,name){
	
	
		if (InDir=="-") {
			
			open(name);
			
		}else {
			
			if (isOpen(InDir+name)) {
				
			}else { 
				
				open(InDir+name); 
				
				}
		}
		
		
		roiManager("Reset");
		run("Clear Results");
	
		//Make Results directory
		MyTitle=getTitle();
		output=getInfo("image.directory");
		aa = split(MyTitle,".");
		MyTitle_short = aa[0];
		OutDir = output+File.separator+MyTitle_short;
		
		run("Set Measurements...", "modal redirect=None decimal=2");
		
		
		//Select background
		
		("Select background reference ");
		run("Select All");
		waitForUser("Select Background Reference");
		run("Duplicate...", "title=background ");
		run("Make Composite");
		run("Select All");
		roiManager("Add");
		roiManager("multi-measure measure_all one append");
		r=getResult("Mode1", 0);
		g=getResult("Mode1", 1);
		b=getResult("Mode1", 2);
		
		close("blackground");
		
		
		//POSSIBILITY OF DELETING
		selectWindow(MyTitle);
		run("Select All");
		setTool("zoom");
		q=true;
		while(q){
			setTool("freehand");		
			waitForUser("Please, select an area to elliminate and press ok when ready");
			setForegroundColor(r,g,b);
			run("Fill");
			run("Select All");				
			q=getBoolean("Do you want to elliminate another area?");
			setTool("zoom");
		}
		
		run("Select None");
		roiManager("Reset");
		run("Clear Results");
		
		saveAs("Tiff", OutDir+"_Preprocessed.tif");
		close("*");
		run("Collect Garbage");

			
}


