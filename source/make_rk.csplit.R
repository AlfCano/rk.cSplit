local({
# Golden Rule 1: This R script is the single source of truth.
# It programmatically defines and generates all plugin files.

# --- PRE-FLIGHT CHECK ---
# Stop if the user is accidentally running this inside an existing plugin folder
if(basename(getwd()) == "rk.cSplit") {
  stop("Your current working directory is already 'rk.cSplit'. Please navigate to the parent directory ('..') before running this script to avoid creating a nested folder structure.")
}

# Require "rkwarddev"
require(rkwarddev)
rkwarddev.required("0.08-1")

# --- GLOBAL SETTINGS ---
plugin_name <- "rk.cSplit"

# =========================================================================================
# PACKAGE DEFINITION (GLOBAL METADATA)
# =========================================================================================
package_about <- rk.XML.about(
    name = plugin_name,
    author = person(
      given = "Alfonso",
      family = "Cano Robles",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "An RKWard plugin to split concatenated columns into a long or wide format using the cSplit() function from the 'splitstackshape' package.",
      version = "0.01.9",
      date = format(Sys.Date(), "%Y-%m-%d"),
      url = "https://github.com/AlfCano/rk.cSplit",
      license = "GPL (>= 3)"
    )
)

# =========================================================================================
# COMPONENT DEFINITION: cSplit
# =========================================================================================

# --- UI Definition for cSplit ---
df_selector <- rk.XML.varselector(id.name = "df_source", label = "Data frames")
data_slot <- rk.XML.varslot(label = "Data to split (indt)", source = "df_source", id.name = "data_slot", required = TRUE, classes = "data.frame")
split_cols_slot <- rk.XML.varslot(label = "Columns to split (splitCols)", source = "df_source", id.name = "split_cols_slot", required = TRUE, multi = TRUE)

# Options
sep_input <- rk.XML.input(label = "Separator character (sep)", initial = ",", id.name = "sep_input")
direction_dropdown <- rk.XML.dropdown(label = "Direction of results", id.name = "direction_dropdown", options = list(
    "Wide (new columns)" = list(val = "wide", chk = TRUE),
    "Long (new rows)" = list(val = "long")
))
fixed_cbox <- rk.XML.cbox(label = "Treat separator as fixed pattern (fixed=TRUE)", chk=TRUE, value="1", id.name = "fixed_cbox")
drop_cbox <- rk.XML.cbox(label = "Keep original column(s) (drop=FALSE)", chk=TRUE, value="1", id.name = "drop_cbox")
strip_white_cbox <- rk.XML.cbox(label = "Strip whitespace around separator (stripWhite=TRUE)", chk=TRUE, value="1", id.name = "strip_white_cbox")
type_convert_cbox <- rk.XML.cbox(label = "Attempt to convert data type (type.convert=TRUE)", chk=TRUE, value="1", id.name = "type_convert_cbox")

# Saving and Preview options
save_object <- rk.XML.saveobj(label = "Save result to new object", chk=TRUE, initial = "data.split", id.name = "save_obj")
preview_button <- rk.XML.preview(mode = "data")

# Assemble the final UI dialog
dialog_col <- rk.XML.col(
    data_slot,
    split_cols_slot,
    sep_input,
    direction_dropdown,
    rk.XML.frame(fixed_cbox, drop_cbox, strip_white_cbox, type_convert_cbox, label="Options"),
    rk.XML.frame(save_object, label="Output"),
    preview_button
)

cSplit_dialog <- rk.XML.dialog(
    label = "Split Concatenated Columns (cSplit)",
    child = rk.XML.row(df_selector, dialog_col)
)

# --- Help File for cSplit ---
cSplit_help <- rk.rkh.doc(
    summary = rk.rkh.summary(text = "Splits one or more columns containing concatenated data into either a wide format (new columns) or a long format (new rows)."),
    usage = rk.rkh.usage(text = "Select a data frame and the column(s) to split. Specify the separator character and the desired output format. The result is saved to an R object in the workspace."),
    sections = list(
        rk.rkh.section(title="Options", text="<p><b>Columns to split:</b> Select one or more columns that contain the delimited data.</p><p><b>Separator character:</b> The character or string that separates the values within the cells (e.g., ',', ';', '|').</p><p><b>Direction:</b> Choose 'wide' to create new columns for the split values, or 'long' to create new rows for each value.</p>")
    ),
    title = rk.rkh.title(text = "cSplit")
)


# --- JavaScript Logic for cSplit ---
js_cSplit_calculate <- '
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
        if (fullName.indexOf("[[") > -1) { return fullName.match(/\\[\\[\\"(.*?)\\"\\]\\]/)[1]; }
        else if (fullName.indexOf("$") > -1) { return fullName.substring(fullName.lastIndexOf("$") + 1); }
        else { return fullName; }
    }

    // Start building R command
    var options = new Array();
    options.push("indt = " + data_frame);

    // Correctly parse the space-separated string from the multi-select varslot
    var cols_array = split_cols_full_string.split(/\\s+/).filter(function(n){ return n != "" });
    var col_names = cols_array.map(function(item) { return getColumnName(item); });
    options.push("splitCols = c(\\"" + col_names.join("\\", \\"") + "\\")");

    options.push("sep = \\"" + sep + "\\"");
    options.push("direction = \\"" + direction + "\\"");

    // Use robust checkbox handling for all checkboxes
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

    // For the main run, save to the object name defined in the saveobj component
    echo("data.split <- splitstackshape::cSplit(" + options.join(", ") + ")\\n");
'

js_cSplit_preview <- '
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
        if (fullName.indexOf("[[") > -1) { return fullName.match(/\\[\\[\\"(.*?)\\"\\]\\]/)[1]; }
        else if (fullName.indexOf("$") > -1) { return fullName.substring(fullName.lastIndexOf("$") + 1); }
        else { return fullName; }
    }

    // Start building R command
    var options = new Array();
    options.push("indt = " + data_frame);

    var cols_array = split_cols_full_string.split(/\\s+/).filter(function(n){ return n != "" });
    var col_names = cols_array.map(function(item) { return getColumnName(item); });
    options.push("splitCols = c(\\"" + col_names.join("\\", \\"") + "\\")");

    options.push("sep = \\"" + sep + "\\"");
    options.push("direction = \\"" + direction + "\\"");

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
    echo("preview_data <- splitstackshape::cSplit(" + options.join(", ") + ")\\n");
'

js_cSplit_printout <- '
    // The actual saving is done in the calculate block for the final run.
    // We only need to print a confirmation message if the save box was checked.
    var should_save = getValue("save_obj");
    if(should_save == "1" || should_save == 1 || should_save == true){
        echo("rk.header(\\"cSplit results saved to object.\\")\\n");
    }
'

# =========================================================================================
# PACKAGE CREATION (THE MAIN CALL)
# =========================================================================================
plugin.dir <- rk.plugin.skeleton(
    about = package_about,
    path = ".",
    xml = list(dialog = cSplit_dialog),
    js = list(
        require = "splitstackshape",
        calculate = js_cSplit_calculate,
        preview = js_cSplit_preview,
        printout = js_cSplit_printout
    ),
    rkh = list(help = cSplit_help),
    pluginmap = list(
        name = "Split Concatenated Data",
        hierarchy = list("data")
    ),
    create = c("pmap", "xml", "js", "desc", "rkh"),
    overwrite = TRUE,
    load = TRUE,
    show = TRUE
)

# Golden Rule 9: Separation of concerns.
message(
  paste0('Plugin package \'', plugin_name, '\' created successfully in \'', plugin.dir, '\'!\n\n'),
  'NEXT STEPS:\n',
  '1. Open RKWard.\n',
  '2. In the R console, run:\n',
  paste0('   rk.updatePluginMessages(pluginmap="inst/rkward/', plugin_name, '.rkmap")\n'),
  '3. Then, to install the plugin, run:\n',
  paste0('   # devtools::install()')
)
})
