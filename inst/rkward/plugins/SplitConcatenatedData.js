// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!

function preview(){
	
    // Load GUI values
    var data_frame = getValue("data_slot");
    var split_cols_full_string = getValue("split_cols_slot");
    var sep = getValue("sep_input");
    var direction = getValue("direction_dropdown");
    var is_fixed = getValue("fixed_cbox");
    var should_keep = getValue("drop_cbox");
    var strip_white = getValue("strip_white_cbox");
    var type_convert = getValue("type_convert_cbox");

    // Robust helper function to extract pure column names
    function getColumnName(fullName) {
        if (!fullName) return "";
        if (fullName.indexOf("[[") > -1) { return fullName.match(/\[\[\"(.*?)\"\]\]/)[1]; }
        else if (fullName.indexOf("$") > -1) { return fullName.substring(fullName.lastIndexOf("$") + 1); }
        else { return fullName; }
    }

    // Start building R command
    var options = new Array();
    options.push("indt = " + data_frame);

    var cols_array = split_cols_full_string.split(/\s+/).filter(function(n){ return n != "" });
    var col_names = cols_array.map(function(item) { return getColumnName(item); });
    options.push("splitCols = c(\"" + col_names.join("\", \"") + "\")");

    options.push("sep = \"" + sep + "\"");
    options.push("direction = \"" + direction + "\"");

    if(is_fixed != "1" && is_fixed != 1 && is_fixed != true){
        options.push("fixed = FALSE");
    }
    if(should_keep == "1" || should_keep == 1 || should_keep == true){
        options.push("drop = FALSE");
    }
    if(strip_white != "1" && strip_white != 1 && strip_white != true){
        options.push("stripWhite = FALSE");
    }
    if(type_convert != "1" && type_convert != 1 && type_convert != true){
        options.push("type.convert = FALSE");
    }

    // For the preview, save to the special object name "preview_data"
    echo("preview_data <- splitstackshape::cSplit(" + options.join(", ") + ")\n");

}

function preprocess(is_preview){
	// add requirements etc. here
	if(is_preview) {
		echo("if(!base::require(splitstackshape)){stop(" + i18n("Preview not available, because package splitstackshape is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(splitstackshape)\n");
	}
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    // Load GUI values
    var data_frame = getValue("data_slot");
    var split_cols_full_string = getValue("split_cols_slot");
    var sep = getValue("sep_input");
    var direction = getValue("direction_dropdown");
    var is_fixed = getValue("fixed_cbox");
    var should_keep = getValue("drop_cbox");
    var strip_white = getValue("strip_white_cbox");
    var type_convert = getValue("type_convert_cbox");

    // Robust helper function to extract pure column names
    function getColumnName(fullName) {
        if (!fullName) return "";
        // CORRECTED: The invalid "--1" has been replaced with the correct "> -1" check.
        if (fullName.indexOf("[[") > -1) { return fullName.match(/\[\[\"(.*?)\"\]\]/)[1]; }
        else if (fullName.indexOf("$") > -1) { return fullName.substring(fullName.lastIndexOf("$") + 1); }
        else { return fullName; }
    }

    // Start building R command
    var options = new Array();
    options.push("indt = " + data_frame);

    // Correctly parse the space-separated string from the multi-select varslot
    var cols_array = split_cols_full_string.split(/\s+/).filter(function(n){ return n != "" });
    var col_names = cols_array.map(function(item) { return getColumnName(item); });
    options.push("splitCols = c(\"" + col_names.join("\", \"") + "\")");

    options.push("sep = \"" + sep + "\"");
    options.push("direction = \"" + direction + "\"");

    // Use robust checkbox handling for all checkboxes
    if(is_fixed != "1" && is_fixed != 1 && is_fixed != true){
        options.push("fixed = FALSE");
    }
    if(should_keep == "1" || should_keep == 1 || should_keep != true){
        options.push("drop = FALSE");
    }
    if(strip_white != "1" && strip_white != 1 && strip_white != true){
        options.push("stripWhite = FALSE");
    }
    if(type_convert != "1" && type_convert != 1 && type_convert != true){
        options.push("type.convert = FALSE");
    }

    // For the main run, save to the object name defined in the saveobj component
    echo("data.split <- splitstackshape::cSplit(" + options.join(", ") + ")\n");

}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Split Concatenated Data results")).print();	
	}
    // The actual saving is done in the calculate block for the final run.
    // We only need to print a confirmation message if the save box was checked.
    var should_save = getValue("save_obj");
    if(should_save == "1" || should_save == 1 || should_save == true){
        echo("rk.header(\"cSplit results saved to object.\")\n");
    }

	if(!is_preview) {
		//// save result object
		// read in saveobject variables
		var saveObj = getValue("save_obj");
		var saveObjActive = getValue("save_obj.active");
		var saveObjParent = getValue("save_obj.parent");
		// assign object to chosen environment
		if(saveObjActive) {
			echo(".GlobalEnv$" + saveObj + " <- data.split\n");
		}	
	}

}

