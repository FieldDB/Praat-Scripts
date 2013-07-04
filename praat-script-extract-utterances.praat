form I/O directory and file filter
	text outdir /Users/yourshortname/Desktop/Recordings/
	text filefilter *.mp3
endform

printline -------
printline Source/Target Directory is 'outdir$'
printline File filter is 'filefilter$'

# Get all the files
Create Strings as file list... list 'outdir$''filefilter$'
numsourcefiles = Get number of strings

# For all the files in the directory
for ifiles to numsourcefiles
	select Strings list
	sourcefile$ = Get string... ifiles
	Read from file... 'outdir$''sourcefile$'

	mainsound = selected("Sound", -1)
	mainsoundname$ = selected$("Sound", -1)
	# Create a TextGrid that contains sounds/silences based on a bunch of parameters
	To TextGrid (silences)...  100 0.01  -26 0.4 0.1 silence utterance
	textgridid = selected("TextGrid")
	plus mainsound
	Extract intervals where... 1 no "is not equal to" silence

	n=numberOfSelected("Sound")
	printline 'n' non-empty segments

  # preserve text grids for quality control to check what the script found later on
  select 'textgridid'
  Save as text file... 'outdir$''sourcefile$'.TextGrid

endfor
