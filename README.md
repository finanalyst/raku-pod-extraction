# Extractor GUI
>Mainly used to generate a README.md from <Modulename>.pm6, which contain POD6


----
## Table of Contents

----
Run `Extractor` in the directory where the transformed files are needed. Select POD6 files by clicking on the FileChooser button at the top of the panel. The Output file name by default is the same as the basename of the input file, but can be changed. Select the output formats.

Will also generate HTML files from POD6 with css to be used as a static file. For HTML generation, the CSS and Images/favicons can be replaced with non-functional divs.

If a file was selected by mistake, uncheck the 'convert' box on the far left and it will not be processed.

When the list is complete, click on **Convert**. The converted files will be shown, or the failure message.

This tool is fairly primitive and it may not handle all error conditions. The tool is intended for generating md and html files in an adhoc manner.

head1 Dependencies

`Extractor` requires GTK::Simple. It is known that this is difficult to install on Windows. However, if the GTK library has already been installed on Windows, then GTK::Simple will load with no problem. Look at the GTK website for information about Windows installations of GTK.








----
Rendered from README at 2021-01-18T15:00:43Z