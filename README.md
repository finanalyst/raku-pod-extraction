![github-tests-passing-badge](https://github.com/finanalyst/raku-pod-extraction/actions/workflows/test.yaml/badge.svg)
# Extractor GUI
>Mainly used to generate a README.md from <Modulename>.pm6, which contain POD6


## Table of Contents
[Dependencies](#dependencies)  

----
Run `Extractor` in the directory where the transformed files are needed. Select POD6 files (`.pod6`, `.pm6`, `.rakudoc`) by clicking on the FileChooser button at the top of the panel. The Output file name by default is the same as the basename of the input file, but can be changed. Select the output formats.

Select `add github badge` to add a github badge at the beginning of the md file (typically README.md). The name of the module and the source url is taken from the META6.json file. An exception is generated if there is no META6.json file.

Will also generate HTML files from POD6 using HTML2 (see ProcessPod documentation for information). HTML2 leaves css and favicon files in the directory with the html file.

If a file was selected by mistake, uncheck the 'convert' box on the far left and it will not be processed.

When the list is complete, click on **Convert**. The converted files will be shown, or the failure message.

This tool is fairly primitive and it may not handle all error conditions. The tool is intended for generating md and html files in an adhoc manner.

# Dependencies
`Extractor` requires GTK::Simple. It is known that this is difficult to install on Windows. However, if the GTK library has already been installed on Windows, then GTK::Simple will load with no problem. Look at the GTK website for information about Windows installations of GTK.







----
Rendered from README at 2022-10-30T09:24:27Z