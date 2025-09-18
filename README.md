# RKWard Plugin: Split Concatenated Data (`rk.cSplit`)

![Version](https://img.shields.io/badge/Version-0.01.8-blue.svg)
![License](https://img.shields.io/badge/License-GPL--3-green.svg)
![R Version](https://img.shields.io/badge/R-%3E%3D%203.0.0-lightgrey.svg)


> An RKWard plugin to split concatenated columns into a long or wide format using the `cSplit()` function from the `splitstackshape` package.

## Overview

This plugin provides a robust graphical user interface within RKWard for splitting columns that contain delimited or concatenated data. It serves as a user-friendly front-end for the powerful `cSplit()` function from the `splitstackshape` package.

This is a common data cleaning and reshaping task, required when a single column in a dataset contains multiple values (e.g., `"apple,banana,orange"`). The plugin allows you to easily transform this messy data into a tidy format, either by creating new columns (wide format) or new rows (long format) for each value.

## Features

-   Select any data frame from the current R workspace.
-   Select **one or more** columns to split simultaneously.
-   Specify any custom separator character (e.g., `,`, `;`, `|`).
-   Choose the output format:
    -   **Wide**: Creates new columns for the split values (`direction="wide"`).
    -   **Long**: Creates new rows for each split value, duplicating the other data (`direction="long"`).
-   Control key behaviors with simple checkboxes:
    -   Keep or drop the original column(s).
    -   Treat the separator as a fixed string or a regular expression.
    -   Automatically strip whitespace from around the separator.
    -   Attempt to convert the new columns to the most appropriate data type (e.g., numeric, integer).
-   A **live data preview** shows you exactly what the output will look like before you run the final command.
-   Save the final, reshaped data frame to a new R object, with the save option enabled by default.

## Installation

### With `devtools` (Recommended)
You can install this plugin directly from its repository using the `devtools` package in R.

```r
# If you don't have devtools installed:
# install.packages("devtools")

# Replace 'YourGitHubUsername' with the actual user/organization
local({
## Preparar
require(devtools)
## Computar
  install_github(
    repo="AlfCano/rk.cSplit"
  )
## Imprimir el resultado
rk.header ("Resultados de Instalar desde git")
})
```

### Manual Installation
1.  Download this repository as a `.zip` file.
2.  In RKWard, go to **Settings -> R Packages -> Install package(s) from local zip file(s)** and select the downloaded file.
3.  Restart RKWard. The plugin will be available in the `Data` menu.

## Usage

1.  Once installed, navigate to the **Data -> Split Data (cSplit)** menu in RKWard.
2.  In the dialog window, select the input `data.frame` you want to modify.
3.  In the "Columns to split" slot, select the column(s) containing the concatenated data. You can select multiple columns.
4.  Ensure the "Separator character" field matches the delimiter in your data.
5.  Choose the desired "Direction" for the output.
6.  Adjust the checkboxes under "Options" to control the function's behavior. The "Keep original column(s)" option is checked by default.
7.  Click the **Preview** button to see a sample of the transformed data without creating any objects.
8.  Specify a name for the output object and click **Submit**.

## Output

-   The primary output is a **new data frame object** saved to your R workspace with the name you specified.
-   A confirmation message will appear in the RKWard Output window upon successful completion.

## License

This plugin is licensed under the GPL (>= 3).
