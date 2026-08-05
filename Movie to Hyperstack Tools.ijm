// "Hyperstack Tools"
//This version August 31, 2025
//Jeff Hardin, Univ. of Wisconsin
//jdhardin@wisc.edu
//Requires ImageJ 1.53e or later, which added features for converting
//virtual stacks into hyperstacks in xyczt or xyctz ordering
var dCmds = newMenu("Movie to Hyperstack Menu Tool",
      newArray("Classic 4d Movie to Hyperstack...","Classic 4d AVI to Hyperstack...","Classic 4d Viewer to HyperStack...","PE AVIs to Hyperstack...","PE TIFFs to Hyperstack...","MM Images to HyperStack...","Imaris to HyperStack..."));

macro "Movie to Hyperstack Menu Tool - C369D05D06D07D14D15D16D17D22D23D24D26D27D31D32D33D36D37D40D41D42D43D44D45D46D47D48D49D50D51D52D53D54D55D56D57D58D59D66D67D97D98D99D9aD9bD9cD9dD9eDa8Da9DaaDabDacDadDb8Db9DbaDbbDbcDbdDc9DcaDcbDccDdaDdbDeaDeb"{
	cmd = getArgument(); 
    //print("Command:" + cmd);
    if (cmd=="Classic 4d Movie to Hyperstack...")
    {
    	run("Classic 4d Movie to Hyperstack");
	}
	else if (cmd=="Classic 4d AVI to Hyperstack...")
	{ 
		run("Classic 4d AVI to Hyperstack");
	}
		else if (cmd=="PE AVIs to Hyperstack...")
    {
    	run("PE AVIs to Hyperstack");
    }
	else if (cmd=="PE TIFFs to Hyperstack...")
    {
    	run("PE TIFFs to Hyperstack");
    }

	else if (cmd=="MM Images to Hyperstack...")
    {
    	run("MM Images to Hyperstack");
    }
    else if (cmd=="Imaris to Hyperstack...")
	{
		run("Imaris to Hyperstack");
	}
	    else if (cmd=="Classic 4d Viewer to Hyperstack...")
	{
		run("Classic 4d Viewer to Hyperstack");
	}

	//end of menu tool code
  }
  
 macro "Toggle Animation (alt click for dialog) Action Tool - C037B43L1131L1252L1373L1494L1595L1676L1757L1838" {
	if (nImages==0) {
            showMessage("Requires Stack", "This tool requires a stack");
            return;
        }
        if (isKeyDown("alt")) {
            run("Animation Options...");
            setKeyDown("alt");
        } else {
            //run("Start Animation");
		doCommand("Start Animation [\\]");
       }
}

    macro "First Time Point Action Tool  - C037T0d14<T7d14<" {
		if (nImages==0) {
            showMessage("Requires Stack", "This tool requires a stack");
            return;
        }
          Stack.getPosition(channel, slice, frame);
         // print("channel=" + channel + " slices=" + slice + " frame=" + frame);
          Stack.setPosition(channel, slice, 1);
          
    }

    macro "Previous Time Point Action Tool - C037T4d14<" {
       if (nImages==0) {
            showMessage("Requires Stack", "This tool requires a stack");
            return;
        }
         Stack.getPosition(channel, slice, frame);
         //print("channel=" + channel + " slices=" + slice + " frame=" + frame);
          Stack.setPosition(channel, slice, frame-1);
    }

    macro "Next Time Point Action Tool - C037T4d14>" {
       if (nImages==0) {
            showMessage("Requires Stack", "This tool requires a stack");
            return;
        }
          Stack.getPosition(channel, slice, frame);
          //print("channel=" + channel + " slices=" + slice + " frame=" + frame);
          Stack.setPosition(channel, slice, frame+1);
    }

    macro "Last Time Point Action Tool - C037T0d14>T7d14>" {
       if (nImages==0) {
            showMessage("Requires Stack", "This tool requires a stack");
            return;
        }
          getDimensions(w, h, channels, slices, frames);
          Stack.getPosition(channel, slice, frame);
          //print("channel=" + channel + " slices=" + slice + " frame=" + frame);
          Stack.setPosition(channel, slice, frames);
    }

    macro "Up Action Tool - C037T4d14^" {
       if (nImages==0) {
            showMessage("Requires Stack", "This tool requires a stack");
            return;
        }
          Stack.getPosition(channel, slice, frame);
          //print("channel=" + channel + " slices=" + slice + " frame=" + frame);
          Stack.setPosition(channel, slice-1, frame);
    }

    macro "Down Action Tool - C037T4c14v" {
       if (nImages==0) {
            showMessage("Requires Stack", "This tool requires a stack");
            return;
        }
          Stack.getPosition(channel, slice, frame);
          //print("channel=" + channel + " slices=" + slice + " frame=" + frame);
          Stack.setPosition(channel, slice+1, frame);
    }


