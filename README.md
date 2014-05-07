[![Build Status](https://travis-ci.org/OpenSourceFieldlinguistics/Praat-Scripts.png)](https://travis-ci.org/OpenSourceFieldlinguistics/Praat-Scripts)

GitHub Mirror of http://www.helsinki.fi/~lennes/praat-scripts/ 


# SpeCT - The Speech Corpus Toolkit for Praat
### (formerly known as Mietta's Praat scripts)

The aim of the **Speech Corpus Toolkit (SpeCT)** is to provide an organized inventory of well-documented Praat scripts that can be easily downloaded, modified and used in order to perform small tasks during the various stages of building, organizing, annotating, analysing, searching and exporting data from a speech corpus.

The first full version of the SpeCT will appear during spring 2011 - apologies for any confusion and inconvenience this may cause. However, as a result of the reorganization, the scripts will hopefully be easier to find and to use. In addition to the scripts that are already available below, the new SpeCT site will contain several new scripts and instructions, e.g., for making simple searches in your annotated speech corpus. Stay tuned!


**Please note:**
These scripts may not have been fully tested! You may use them at your own risk.
*I cannot provide support for using the scripts,* but I will gladly receive bug reports ;-)

**Latest update:** 20.1.2011



* These Praat scripts were written by [Mietta Lennes](http://www.helsinki.fi/~lennes) . They should provide some functionalities and tools for the [Praat](http://www.praat.org/) program for phonetic analysis (see the Praat home page at [http://www.praat.org/](http://www.praat.org/) ). Praat is being developed by Paul Boersma and David Weenink in the University of Amsterdam.
These scripts are distributed under the [GNU General Public License](http://www.gnu.org/licenses/gpl.txt) . The scripts are distributed without any warranty: I do not guarantee that the scripts work in your system, and I will not be held responsible for any harm or damage caused by their use. Please make sure that you know what you are doing.
* Please refer any interested parties to this web page ( [http://www.helsinki.fi/~lennes/praat-scripts/](http://www.helsinki.fi/~lennes/praat-scripts/) ).
* If you can't find the script you need, take a look at some other Praat script resources on the web.

**How to run and modify the scripts:**

### Praat
See Scripting tutorial in the built-in Help pages within the [Praat](http://www.praat.org/) program (see the Help menu in the Objects list). 
 
### Node.js webservice

Add the scripts to your list of dependancies:

```bash
$ npm install praat-scripts --save
```

Reference the scripts where you want to execute them:

```js
var childProcess = require('child_process');

var praatCommand = " praat ";
var praatMacCommand = " Applications/Praat.app/Contents/MacOS/Praat ";

var scriptToRun = "script_you_want_to_run.praat";
var workingDir = "/tmp/dir_where_audio_files_are";
var wavFile = "your_wav_file.wav";
var scriptParameters = "-20 4 0.4 0.1 no \"" + workingDir + "\"   \"" + wavFile + "\"";

var textGridCommand = praatCommand + __dirname + "/node_modules/praat-scripts/" + scriptToRun + "  " + scriptParameters; //+ " 2>&1 ";

childProcess.exec(textGridCommand , function(error, stdout, stderr) {
  console.log("Script execution is complete, here are the results: " + stdout);
});

```

**Requirements:** In the Requirements column, you can find information on what type of objects have to be selected in the Object list or what sort of files are needed in order to run each script. This is important especially when you want to create new buttons or menu commands to use the script.

**Compatibility note:** Some of the scripts were originally written in a Windows machine, some in Macintosh, and some in Linux. All of them should work in any platform running Praat, but you may want to change, e.g., the default path for files according to your system. The version number tells you the Praat version on which the script has been tested. Sometimes the commands change in Praat, and consequently all of the scripts may not work in all Praat versions.



### Citing these scripts

Option 1: find the individual script's paper in Meitta's papers [Google Scholar](http://scholar.google.ca/scholar?q=mietta+lennes&btnG=&hl=en&as_sdt=0%2C5) or in [Meitta's BibTeX](http://www.helsinki.fi/~lennes/lennes.bib)

Option 2.: Cite the project

```tex
@misc{LennesSpeCT,
	Author = {Mietta Lennes},
	Howpublished = {Previously known as "{Mietta's scripts for the Praat program}"},
	Keywords = {script, Praat, corpus, analysis, annotation, acoustic},
	Note = {Retrieved 21.2.2011. [Website] <\url{http://www.helsinki.fi/\~lennes/praat-scripts/}>},
	Title = {{SpeCT --- The Speech Corpus Toolkit for Praat}},
	Year = {2011}
}
```
