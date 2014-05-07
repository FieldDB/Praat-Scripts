#!/usr/local/bin/node

var praatCommand = " praat ";
var praatMacCommand = " Applications/Praat.app/Contents/MacOS/Praat ";

var scriptToRun = "script_you_want_to_run.praat";
var workingDir = "/tmp/dir_where_audio_files_are";
var wavFile = "your_wav_file.wav";
var scriptParameters = "-20 4 0.4 0.1 no \"" + workingDir + "\"   \"" + wavFile + "\"";

var textGridCommand = praatCommand + __dirname + "/node_modules/praat-scripts/" + scriptToRun + "  " + scriptParameters; //+ " 2>&1 ";

console.log("\n\nRun these scripts from your project using a command like this on the commandline using\n\n Praat itself:\n   " + textGridCommand);

console.log("\n\nOr using Node:\n  childProcess.exec( textGridCommand , function(error, stdout, stderr) {});\n\n");
