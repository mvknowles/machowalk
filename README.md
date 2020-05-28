# Mach-O-Walk

This is a project to build a database of internal and external headers, segments, sections and other data structures present in Mach-O files (typically found on MacOS).

The main tool is called "machowalk". It analyses the Mach-O header of a program, library or framework and dumps all the information into JSON.

Why JSON? It allows for easier analysis in higher-level languages and it can be imported into databases easily.

The eventual aim is to analyse a large amount of Mach-O files and build up a database with the information. This allows inferences to be made about internal data structures that are opaque when analysed in isolation. Put another way, it's great for reverse engineering the guts of Darwin/MacOS based programs. This is particularly useful for reverse engineering or malware analysis.

## Example
The following output shows the partial output of the program, invoked on a very simple binary. You can see the full output in [example_output.json](example_output.json). For a far more complex example, take a look in [example_complex.json](example_complex.json). It will illustrate just how much information can be packed into a Mach-O binary.

Short example output:

```
machowalk /System/Library/PrivateFrameworks/SharingXPCServices.framework/SharingXPCServices
```
```
{
"header" : {
   "magic" : "MH_MAGIC_64",
   "origStruct" : {
     "mach_header_64.filetype" : 6,
     "mach_header_64.cputype" : 16777223,
     "mach_header_64.cpusubtype" : 3,
     "mach_header_64.reserved" : 0,
     "mach_header_64.magic" : 4277009103,
     "mach_header_64.sizeofcmds" : 768,
     "mach_header_64.ncmds" : 14,
     "mach_header_64.flags" : 34603141
   },
   "fileType" : "MH_DYLIB"
 },
"stringTable" : [
  "_SharingXPCServicesVersionNumber",
  "_SharingXPCServicesVersionString",
  "dyld_stub_binder"
],
"path" : "\/System\/Library\/PrivateFrameworks\/SharingXPCServices.framework\/SharingXPCServices",
"stringTableByOffset" : {
  "4" : "_SharingXPCServicesVersionNumber",
  "37" : "_SharingXPCServicesVersionString",
  "70" : "dyld_stub_binder"
}
```

## Frequently Asked Questions

TODO.
