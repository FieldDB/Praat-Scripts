# Save formant values for segments in the sound files of a specified directory
# Sound files must be .aif or .wav
# TextGrid files must be .textgrid
#
# This script is distributed under the GNU General Public License.
# Gina Cook April 24 2006

# directory format should be like:  targets\wav\

# Display config form 
form Save spectral peaks for all labels
comment Give the path of the directory containing the sound and TextGrid files:
text directory florin\targets\by.root\
comment Which tier of the TextGrid files should be used for segment analysis?
integer Tier 2
comment Which interval tier of the TextGrid files should be used for item names?
integer Item_tier 1
comment Where would you like to save the results?
text resultfile 060720results.v29.spectralpeaks.v1notuse.txt
comment Formant analysis options
integer Max_number_of_formants 5
positive Maximum_formant_(Hz) 4500 (= specialized for florins o and m)
positive Window_length_(s) 0.025
endform

echo Files in directory 'directory$' will now be checked...
token = 0
filepair = 0
# this is a "safety margin" (in seconds) for formant analysis, in case the vowel segment is very short:
#margin = 0.02
margin = 0.00
lineNumber = 0


#open some variables for the vowel volume holdre
for  i to 14
	vowel'i'Loudness =0
endfor


# Check if the result text file already exists. If it does, ask the user for permission to overwrite it.
if fileReadable (resultfile$) = 1
   pause The text file 'resultfile$' already exists. Do you want to continue and overwrite it?
endif
filedelete 'resultfile$'
# add the column titles to the text file:

titleLine$ = "placeOfArticulation	itemContext	labelType	root	itemLabel	lineNumber	`label`	duration	loudness	relativeLoudness	vowelLoudnessUsed	spectralPeak1Bark	spectralPeak1Hertz	spectralWindow1Used	spectralPeak2Bark	spectralPeak2Hertz	spectralWindow2Used	spectralPeak3Bark	spectralPeak3	spectralWindow3Used	spectralPeak4Bark	spectralPeak4	spectralWindow4Used	spectralPeak1amplitude	spectralPeak2amplitude	spectralPeak3amplitude	spectralPeak4amplitude	segstart	segend	spectral0Peak1Bark	spectral0Peak1	spectral0Peak2Bark	spectral0Peak2	spectral0Peak3Bark	spectral0Peak3	spectral0Peak4Bark	spectral0Peak4	spectral0Peak1amplitude	spectral0Peak2amplitude	spectral0Peak3amplitude	spectral0Peak4amplitude	spectral1Peak1Bark	spectral1Peak1	spectral1Peak2Bark	spectral1Peak2	spectral1Peak3Bark	spectral1Peak3	spectral1Peak4Bark	spectral1Peak4	spectral1Peak1amplitude	spectral1Peak2amplitude	spectral1Peak3amplitude	spectral1Peak4amplitude	spectral2Peak1Bark	spectral2Peak1	spectral2Peak2Bark	spectral2Peak2	spectral2Peak3Bark	spectral2Peak3	spectral2Peak4Bark	spectral2Peak4	spectral2Peak1amplitude	spectral2Peak2amplitude	spectral2Peak3amplitude	spectral2Peak4amplitude	spectral3Peak1Bark	spectral3Peak1	spectral3Peak2Bark	spectral3Peak2	spectral3Peak3Bark	spectral3Peak3	spectral3Peak4Bark	spectral3Peak4	spectral3Peak1amplitude	spectral3Peak2amplitude	spectral3Peak3amplitude	spectral3Peak4amplitude	fricativeInterval'newline$'"
fileappend 'resultfile$' 'titleLine$'


# Check the contents of the user-specified directory and open appropriate Sound and TextGrid pairs:
Create Strings as file list... list 'directory$'*
numberOfFiles = Get number of strings

printline The number of files found is 'numberOfFiles'.

#for loop to go through all files in the directory
for gridfile to numberOfFiles
   #printline gridfile 'gridfile'
   select Strings list
   gridfilename$ = Get string... gridfile
   #printline gridfilename is 'gridfilename$'

   #if statement to get texgrid files
   if right$ (gridfilename$, 9) = ".textgrid" or right$ (gridfilename$, 9) = ".TextGrid"  or right$ (gridfilename$, 9) = ".TEXTGRID"
      #printline This is a textgrid (ie, the if statement is yes)

      #check if there is a corresponding sound file if a textgrid file was found,
      filename$ = left$ (gridfilename$, (length (gridfilename$) - 9))
      #printline filename is 'filename$'
      #for to check for sound files
      for soundfile to numberOfFiles
         #printline soundfiles is 'soundfile' and number of files is 'numberOfFiles'
         soundfilename$ = Get string... soundfile
         #printline soundfilename is 'soundfilename$' and string is  'soundfile'
         #if statement to check ifthe left part of the filename is identical to left part of textgrid and if the extension is wav or aif
         if left$ (soundfilename$, (length (filename$))) = filename$ and (right$ (soundfilename$, (length (soundfilename$) - length (filename$))) = ".wav" or right$ (soundfilename$, (length (soundfilename$) - length (filename$))) = ".WAV" or right$ (soundfilename$, (length (soundfilename$) - length (filename$))) = ".aif" or right$ (soundfilename$, 5) = ".aiff" or right$ (soundfilename$, (length (soundfilename$) - length (filename$))) = ".AIF" or right$ (soundfilename$, (length (soundfilename$) - length (filename$))) = ".AIFF")
            printline This is a matching pair 'filename$'
            filepair = filepair + 1
            # open both files if they match
            #printline soundfile is 'directory$''soundfilename$' and texgrid file is 'directory$''soundfilename$'
            Read from file... 'directory$''soundfilename$'
            Read from file... 'directory$''gridfilename$'

            #get times for the segment

            #extract textgrid information
            call Measurements






            select Strings list

         #endif for finding matching sound file
         endif

      #endfor to get matching sound files
      endfor

   #endif for finding textgrid files
   endif

#endfor to go through all files in a directory
endfor

printline 'filepair' matching pairs of Sound and TextGrid files were found. 
printline The results were saved in 'resultfile$'.


select Strings list
Remove


#----------------------
procedure Measurements
vowelLoudness = 0
relativeLoudness = 0

# look at the TextGrid object
select TextGrid 'filename$'

filestart = Get starting time
fileend = Get finishing time

##get place of articulation
if (endsWith (filename$,"ots")) > 0
	placeOfArticulation = 1
elsif (endsWith (filename$,"os")) > 0
	placeOfArticulation = 2
elsif (endsWith (filename$,"op")) > 0
	placeOfArticulation =0
else 
	placeOfArticulation = 999
endif

## get all intervals you want to measure
numberOfIntervals = Get number of intervals... tier

## small number of loops for debugging
#numberOfIntervals = 4

## get time info for the segment intervals
for interval to numberOfIntervals
	select TextGrid 'filename$'
	label$ = Get label of interval... tier interval



	segstart = Get starting point... tier interval
	segend = Get end point... tier interval

	# get item label from tier 1
	itemIntervalNumber = Get interval at time... item_tier segstart
	itemLabel$ = Get label of interval... item_tier itemIntervalNumber

	
	##get context
	stem$ = left$ (itemLabel$, (length(itemLabel$) - 3))
	if (rindex (stem$,"ul")) > 0
		itemContext = 0
	elsif (endsWith (stem$,"s")) > 0 or (endsWith (stem$,"p")) > 0 or (endsWith (stem$,"t")) > 0 
		itemContext = 1
	elsif (rindex (stem$,"ii")) > 0
		itemContext = 2
	elsif (endsWith (stem$,"i")) > 0
		itemContext = 3
	else 
		itemContext = 999
	endif



	##get label type
	if (rindex (label$,"labial")) > 0 or (rindex (label$,"dental")) > 0 or (rindex (label$,"velar")) > 0
		labelType = 999
	elsif (startsWith (label$,"o")) > 0
		labelType = 0
	elsif (rindex (label$,".")) > 0
		labelType =1
	elsif (startsWith (label$,"p")) > 0 or (startsWith (label$,"t")) > 0
		labelType =2
	elsif (rindex (label$,"C")) > 0
		labelType =5
	elsif (endsWith (label$,"P")) > 0 or (endsWith (label$,"S")) > 0 or (endsWith (label$,"s")) > 0
		labelType =3
	elsif (rindex (label$,"P")) > 0 or (rindex  (label$,"S")) > 0 or (startsWith  (label$,"s")) > 0
		labelType =4
	elsif (rindex (label$,"u")) > 0 or (rindex (label$,"ii")) > 0 
		labelType =7
	elsif (rindex (label$,"U")) > 0 or (rindex (label$,"I")) > 0   or (rindex (label$,"E")) > 0 
		labelType =6
	elsif (itemContext = 1 or itemContext =3) and (rindex (label$,"M")) > 0
		labelType = 6
	elsif (itemContext = 1 or itemContext =3) and (rindex (label$,"m")) > 0 
		labelType = 7
	else 
		labelType = 999
	endif

#0 previous vowel
#1 closure
#2 burst transients
#3 frication
#4 frication vowel colored
#5 reclosing transients
#6 aspiration
#7 following segment
#8 all voiceless area
	duration = segend - segstart
	# Create a window for analyses (possibly adding the "safety margin"):
	if (segstart - margin) > filestart
		windowstart = segstart - margin
		if labelType = 4
			windowstart = segend - 0.0256
			#pause Im doing a 25.6ms windwo for 'label$'
		elsif labelType = 0
			windowstart = segend - 0.015
		endif
	else
		windowstart = filestart
	endif	
	if (segend + margin) < fileend
		windowend = segend + margin
	else
		windowend = fileend
	endif	
	
	
	select Sound 'filename$'
	Extract part... windowstart windowend Hanning 1 yes
	Rename... extractedSegment
	select Sound extractedSegment
	To Spectrum... yes

	#get loudness in sones
	To Excitation... 0.1
	segmentLoudness = Get loudness

	#get intensity instead:
	select Sound extractedSegment
	segmentIntensity = Get intensity (dB)
	if labelType = 0
		vowel'itemIntervalNumber'Loudness = segmentLoudness
		#pause the vowel loudness for 'itemLabel$' was stored in vowel'itemIntervalNumber'Loudness
	endif	
	#relativeLoudness = segmentLoudness - vowelLoudness
	if vowel'itemIntervalNumber'Loudness != 0
		vowelLoudness = vowel'itemIntervalNumber'Loudness
		relativeLoudness =  vowelLoudness/segmentLoudness
	else
		vowelLoudness = 0
		relativeLoudness =  0
	endif
	
	#get frequency of maximum in hertz (convert to bark later)
	select Spectrum extractedSegment
	To Ltas (1-to-1)
##	#call SpectralPeakByPlace
	

	resultLine$ = "'placeOfArticulation'	'itemContext'	'labelType'	'filename$'	'itemLabel$'	'lineNumber'	`'label$'`	'duration'	'segmentLoudness'	'relativeLoudness'	'vowelLoudness'	'spectralPeak1Bark'	'spectralPeak1'	'spectralWindow1'	'spectralPeak2Bark'	'spectralPeak2'	'spectralWindow2'	'spectralPeak3Bark'	'spectralPeak3'	'spectralWindow3'	'spectralPeak4Bark'	'spectralPeak4'	'spectralWindow4'	'spectralPeak1amplitude'	'spectralPeak2amplitude'	'spectralPeak3amplitude'	'spectralPeak4amplitude'	'segstart'	'segend''newline$'"
	#printline 'resultLine$'
	fileappend 'resultfile$' 'resultLine$'
	lineNumber = lineNumber + 1
	
	#make uniform Ltas for averaging and making pictures
	#if labelType = 4 & ( itemContext = 2 or itemContext = 0 or itemContext = 1) & (duration > 0.006)
	#if labelType = 4 & (duration > 0.006)
	#	select Sound extractedSegment
	#	To Ltas... 100
	#	Rename... 'itemLabel$''label$'
	#endif

	select Sound extractedSegment
	plus Spectrum extractedSegment
	plus Excitation extractedSegment
	plus Ltas extractedSegment
	Remove
	

	
endfor

vowelLoudness = 0
relativeLoudness = 0

select TextGrid 'filename$'
numberOfItemIntervals = Get number of intervals... item_tier

for interval to numberOfItemIntervals
	select TextGrid 'filename$'
	itemLabel$ = Get label of interval... item_tier interval

	segstart = Get starting point... item_tier interval
	segend = Get end point... item_tier interval

	# get item label from tier 2
	segIntervalEnd = Get interval at time... tier segend
	segIntervalStart = Get interval at time... tier segstart
voicelessStart = 0
voicelessEnd = 0
beginningFound =0
closureEnd =0

voicelessLabel$ = ""
endFound = 0
	totalSegments = segIntervalEnd - segIntervalStart 
	
	for segment to totalSegments
		intervalToCheck = segment + segIntervalStart
		select TextGrid 'filename$'
		seglabel$ = Get label of interval... tier intervalToCheck
		voicelessLabel$ = "'voicelessLabel$' 'seglabel$'"
		#pause Total number of segments in this item is 'totalSegments' intervalToCheck is 'intervalToCheck' its label is 'seglabel$'
		if (endsWith (seglabel$,"o")) > 0 or (startsWith (seglabel$,"o")) > 0
			select TextGrid 'filename$'
			voicelessStart = Get end point... tier intervalToCheck
			#pause found starting point for voicelessness 'itemLabel$' in 'seglabel$'
			beginningFound = 1
			voicelessLabel$ = "'voicelessLabel$'!"

		elsif (endsWith (seglabel$, ".")) >0 
			closureEnd = Get end point... tier intervalToCheck
			#pause this segment 'seglabel$' is a closure
		#changed the m into an M so that hte coda ones would cut off the M, and added C incase that didnt work
		#elsif (rindex (seglabel$,"ii")) > 0 or (rindex (seglabel$,"u")) > 0 or (rindex (seglabel$,"M")) > 0 or (rindex (seglabel$,"C")) > 0 

		#i changed it and put it to the aspiration cause im going to measure the spectra of the combined frication and i want to control for lengths better than if i were to include the voiceless vowels following..
		elsif (startsWith (seglabel$,"I")) > 0 or (startsWith (seglabel$,"E")) > 0 or (startsWith (seglabel$,"U")) > 0 or (rindex (seglabel$,"ii")) > 0 or (rindex (seglabel$,"u")) > 0 or (rindex (seglabel$,"M")) > 0 or (rindex (seglabel$,"C")) > 0 
			voicelessEnd = Get starting point... tier intervalToCheck
			voicelessLabel$ = "'voicelessLabel$'!"
			segment = totalSegments
		#elsif (rindex (seglabel$,"U")) > 0 or (rindex (seglabel$,"I")) > 0 or  (rindex (seglabel$,"M")) > 0 
			#select TextGrid 'filename$'
			#voicelessEnd = Get end point... tier intervalToCheck
			#pause found ending point for voicelessness in 'itemLabel$' in 'segLabel$'
			#voicelessLabel$ = "'voicelessLabel$']"
			#endFound = 1
		endif
		#segment = segment + 1 
		#pause For label 'seglabel$' beginningFound is 'beginningFound' and endFound is 'endFound'
	endfor

	# Create a window for analyses (possibly adding the "safety margin"):
	#if (voicelessStart - margin) > filestart
	#	windowstart = voicelessStart - margin
	#else
	#	windowstart = filestart
	#endif	
	#if (voicelessEnd + margin) < fileend
	#	windowend = voicelessStart + margin
	#else
	#	windowend = fileend
	#endif	
	duration = voicelessEnd - voicelessStart
	#pause voicelssness is 'voicelessLabel$' 'duration' long.
	


	call ConsonantProgression


	##get context
	stem$ = left$ (itemLabel$, (length(itemLabel$) - 3))
	if (rindex (stem$,"ul")) > 0
		itemContext = 0
	elsif (endsWith (stem$,"s")) > 0 or (endsWith (stem$,"p")) > 0 or (endsWith (stem$,"t")) > 0 
		itemContext = 1
	elsif (rindex (stem$,"ii")) > 0
		itemContext = 2
	elsif (endsWith (stem$,"i")) > 0
		itemContext = 3
	else 
		itemContext = 999
	endif

	resultLine$ = "'placeOfArticulation'	'itemContext'	8	'filename$'	'itemLabel$'	'lineNumber'	'voicelessLabel$'	'duration'	000	000	000	000	000	000	000	000	000	000	000	000	000	000	000	000	000	000	000	'voicelessStart'	'voicelessEnd'	'spectral0Peak1Bark'	'spectral0Peak1'	'spectral0Peak2Bark'	'spectral0Peak2'	'spectral0Peak3Bark'	'spectral0Peak3'	'spectral0Peak4Bark'	'spectral0Peak4'	'spectral0Peak1amplitude'	'spectral0Peak2amplitude'	'spectral0Peak3amplitude'	'spectral0Peak4amplitude'	'spectral1Peak1Bark'	'spectral1Peak1'	'spectral1Peak2Bark'	'spectral1Peak2'	'spectral1Peak3Bark'	'spectral1Peak3'	'spectral1Peak4Bark'	'spectral1Peak4'	'spectral1Peak1amplitude'	'spectral1Peak2amplitude'	'spectral1Peak3amplitude'	'spectral1Peak4amplitude'	'spectral2Peak1Bark'	'spectral2Peak1'	'spectral2Peak2Bark'	'spectral2Peak2'	'spectral2Peak3Bark'	'spectral2Peak3'	'spectral2Peak4Bark'	'spectral2Peak4'	'spectral2Peak1amplitude'	'spectral2Peak2amplitude'	'spectral2Peak3amplitude'	'spectral2Peak4amplitude'	'spectral3Peak1Bark'	'spectral3Peak1'	'spectral3Peak2Bark'	'spectral3Peak2'	'spectral3Peak3Bark'	'spectral3Peak3'	'spectral3Peak4Bark'	'spectral3Peak4'	'spectral3Peak1amplitude'	'spectral3Peak2amplitude'	'spectral3Peak3amplitude'	'spectral3Peak4amplitude'	'fricativeInterval''newline$'"
	#printline 'resultLine$'
	fileappend 'resultfile$' 'resultLine$'
	lineNumber = lineNumber + 1




endfor
		


#pause Finished the root 'filename$' Do you want to stop?

endproc


##____________



#_------------------
procedure SpectralPeakByPlace

spectralPeak1 = 0
spectralPeak2 =0
spectralPeak3 =0
spectralPeak1Bark = 0
spectralPeak2Bark =0
spectralPeak3Bark =0

spectralPeak1amplitude =0
spectralPeak2amplitude =0
spectralPeak3amplitude =0

#it will do same ranges for all labels
	spectralPeak1= Get frequency of maximum... 1100 2200 Parabolic
	spectralPeak1amplitude = Get maximum... 1100 2200 Parabolic
	spectralWindow1=12
	#in the post alveolars expect maybe a higher value here in the second peak for the palatals, the peaks for the palatalized are flatter than for the none palatalized.
	spectralPeak2 = Get frequency of maximum... 2200 3000 Parabolic
	spectralPeak2amplitude = Get maximum... 2200 3000 Parabolic
	spectralWindow2= 22
	#the postalveolars only need up to 4200 for their last peak
	spectralPeak3 = Get frequency of maximum... 3000 4000 Parabolic
	spectralPeak3amplitude = Get maximum... 3000 4000 Parabolic
	spectralWindow3= 32
	#dental has two disperse peaks in the range of 3000-5200, which alterneate as which is loudest. i clumpted the ranges for the dentals and postalveolars together so i could compare them, the postalveolars only need up to 4200 for their last peak
	spectralPeak4 = Get frequency of maximum... 4000 5200 Parabolic
	spectralPeak4amplitude = Get maximum... 4000 5200 Parabolic
	spectralWindow4= 42


if labelType = 0 
	select Sound extractedSegment
	To Formant (burg)... 0 max_number_of_formants maximum_formant window_length 50
	spectralPeak1 = Get mean... 2 0 0 Hertz
	spectralPeak1amplitude = 0
	spectralWindow1 =222

	spectralPeak2 = Get mean... 3 0 0 Hertz
	spectralPeak2amplitude = 0
	spectralWindow2 =333 

	spectralPeak3 = 0
	spectralPeak3amplitude = 0
	spectralWindow3= 0
	spectralPeak4 = 0
	spectralPeak4amplitude = 0
	spectralWindow4= 0
	
	select Formant extractedSegment
	Remove
endif


spectralPeak1Bark = (26.81/(1+(1960/spectralPeak1)))-0.53
spectralPeak2Bark = (26.81/(1+(1960/spectralPeak2)))-0.53
spectralPeak3Bark = (26.81/(1+(1960/spectralPeak3)))-0.53
spectralPeak4Bark = (26.81/(1+(1960/spectralPeak4)))-0.53

#printline Analyzed segment 'itemContext' in window number 'spectralWindow1' and 'spectralWindow2'

endproc


#_------------------
procedure ConsonantProgression



if closureEnd = 0 
	#for postalveolars
	starting = voicelessStart
	starting0 = voicelessStart
	ending0 = voicelessStart + 0.0256	

else
	#pause  closureEnd was found
	#for labials and dentals
	starting = closureEnd
	#keating 25.6ms window centered on burst onset.
	starting0 = closureEnd - 0.0128
	ending0 = closureEnd + 0.0128	
endif

#get the sounds to make audio files for presentation and to examine variation
#	select Sound 'filename$'
#	exStart = voicelessStart - 0.0256
#	exEnd = voicelessEnd + 0.0256
##	Extract part... exStart exEnd Hanning 1 yes	
#	Extract part... voicelessStart voicelessEnd Rectangular 1 yes
#	Rename... 'itemLabel$'

#pause end one root
#endproc

fricativeDuration= voicelessEnd - starting
fricativeInterval = fricativeDuration / 3 

ending1 = voicelessEnd - (fricativeInterval * 2)
starting1 = ending1 - 0.0256
ending2 = voicelessEnd - fricativeInterval
starting2 = ending2 - 0.0256
ending3 = voicelessEnd
starting3 = ending3 - 0.0256
#printline the duration for 'voicelessLabel$' is 'fricativeDuration' so the interval will be 'fricativeInterval' voicelessEnd:'voicelessEnd' 
#printline starting0: 'starting0' ending0: 'ending0'
#printline starting1: 'starting1' ending1: 'ending1'
#printline starting2: 'starting2' ending2: 'ending2'
#printline starting3: 'starting3' ending3: 'ending3'

#pause the duration is 'fricativeDuration' so the interval will be 'fricativeInterval'. voicelessEnd is 'voicelessEnd' and ending 1 will be 'ending1', starting 1 will be 'starting1'

	select Sound 'filename$'
	Extract part... starting0 ending0 Hanning 1 yes
	Rename... extractedSegment
	To Spectrum... yes
	#get frequency of maximum in hertz (convert to bark later)
	select Spectrum extractedSegment
	To Ltas (1-to-1)
	spectral0Peak1= Get frequency of maximum... 1100 2200 Parabolic
	spectral0Peak1amplitude = Get maximum... 1100 2200 Parabolic
	spectral0Peak2 = Get frequency of maximum... 2200 3000 Parabolic
	spectral0Peak2amplitude = Get maximum... 2200 3000 Parabolic
	spectral0Peak3 = Get frequency of maximum... 3000 4000 Parabolic
	spectral0Peak3amplitude = Get maximum... 3000 4000 Parabolic
	spectral0Peak4 = Get frequency of maximum... 4000 5200 Parabolic
	spectral0Peak4amplitude = Get maximum... 4000 5200 Parabolic
	spectral0Peak1Bark = (26.81/(1+(1960/spectral0Peak1)))-0.53
	spectral0Peak2Bark = (26.81/(1+(1960/spectral0Peak2)))-0.53
	spectral0Peak3Bark = (26.81/(1+(1960/spectral0Peak3)))-0.53
	spectral0Peak4Bark = (26.81/(1+(1960/spectral0Peak4)))-0.53
	
	if placeOfArticulation != 2
		select Sound extractedSegment
		Filter (pass Hann band)... 0 6000 100
		To Spectrum... yes
		LPC smoothing... 16 50
		Rename... 'itemLabel$'0
		select Sound extractedSegment_band
		plus Spectrum extractedSegment_band
		Remove
	#else 
	#	select Ltas extractedSegment
	#	Remove
	endif
	select Sound extractedSegment
	plus Spectrum extractedSegment
	#plus Ltas extractedSegment
	Remove
	select Ltas extractedSegment
	Rename... 'itemLabel$'-0


	select Sound 'filename$'
	Extract part... starting1 ending1 Hanning 1 yes
	Rename... extractedSegment
	To Spectrum... yes
	#get frequency of maximum in hertz (convert to bark later)
	select Spectrum extractedSegment
	To Ltas (1-to-1)
	spectral1Peak1= Get frequency of maximum... 1100 2200 Parabolic
	spectral1Peak1amplitude = Get maximum... 1100 2200 Parabolic
	spectral1Peak2 = Get frequency of maximum... 2200 3000 Parabolic
	spectral1Peak2amplitude = Get maximum... 2200 3000 Parabolic
	spectral1Peak3 = Get frequency of maximum... 3000 4000 Parabolic
	spectral1Peak3amplitude = Get maximum... 3000 4000 Parabolic
	spectral1Peak4 = Get frequency of maximum... 4000 5200 Parabolic
	spectral1Peak4amplitude = Get maximum... 4000 5200 Parabolic
	spectral1Peak1Bark = (26.81/(1+(1960/spectral1Peak1)))-0.53
	spectral1Peak2Bark = (26.81/(1+(1960/spectral1Peak2)))-0.53
	spectral1Peak3Bark = (26.81/(1+(1960/spectral1Peak3)))-0.53
	spectral1Peak4Bark = (26.81/(1+(1960/spectral1Peak4)))-0.53
	select Sound extractedSegment
	plus Spectrum extractedSegment
	Remove
	select Ltas extractedSegment
	Rename... 'itemLabel$'-1

	select Sound 'filename$'
	Extract part... starting2 ending2 Hanning 1 yes
	Rename... extractedSegment
	To Spectrum... yes
	#get frequency of maximum in hertz (convert to bark later)
	select Spectrum extractedSegment
	To Ltas (1-to-1)
	spectral2Peak1= Get frequency of maximum... 1100 2200 Parabolic
	spectral2Peak1amplitude = Get maximum... 1100 2200 Parabolic
	spectral2Peak2 = Get frequency of maximum... 2200 3000 Parabolic
	spectral2Peak2amplitude = Get maximum... 2200 3000 Parabolic
	spectral2Peak3 = Get frequency of maximum... 3000 4000 Parabolic
	spectral2Peak3amplitude = Get maximum... 3000 4000 Parabolic
	spectral2Peak4 = Get frequency of maximum... 4000 5200 Parabolic
	spectral2Peak4amplitude = Get maximum... 4000 5200 Parabolic
	spectral2Peak1Bark = (26.81/(1+(1960/spectral2Peak1)))-0.53
	spectral2Peak2Bark = (26.81/(1+(1960/spectral2Peak2)))-0.53
	spectral2Peak3Bark = (26.81/(1+(1960/spectral2Peak3)))-0.53
	spectral2Peak4Bark = (26.81/(1+(1960/spectral2Peak4)))-0.53
	select Sound extractedSegment
	plus Spectrum extractedSegment
	Remove
	select Ltas extractedSegment
	Rename... 'itemLabel$'-2

	select Sound 'filename$'
	Extract part... starting3 ending3 Hanning 1 yes
	Rename... extractedSegment
	To Spectrum... yes
	#get frequency of maximum in hertz (convert to bark later)
	select Spectrum extractedSegment
	To Ltas (1-to-1)
	spectral3Peak1= Get frequency of maximum... 1100 2200 Parabolic
	spectral3Peak1amplitude = Get maximum... 1100 2200 Parabolic
	spectral3Peak2 = Get frequency of maximum... 2200 3000 Parabolic
	spectral3Peak2amplitude = Get maximum... 2200 3000 Parabolic
	spectral3Peak3 = Get frequency of maximum... 3000 4000 Parabolic
	spectral3Peak3amplitude = Get maximum... 3000 4000 Parabolic
	spectral3Peak4 = Get frequency of maximum... 4000 5200 Parabolic
	spectral3Peak4amplitude = Get maximum... 4000 5200 Parabolic
	spectral3Peak1Bark = (26.81/(1+(1960/spectral3Peak1)))-0.53
	spectral3Peak2Bark = (26.81/(1+(1960/spectral3Peak2)))-0.53
	spectral3Peak3Bark = (26.81/(1+(1960/spectral3Peak3)))-0.53
	spectral3Peak4Bark = (26.81/(1+(1960/spectral3Peak4)))-0.53
	#select Sound extractedSegment
	#plus Spectrum extractedSegment
	#Remove
	select Ltas extractedSegment
	Rename... 'itemLabel$'-3


#relativize the amplitudes with respect to peak 3
spectral0Peak1amplitude = spectral0Peak1amplitude - spectral0Peak3amplitude
spectral0Peak2amplitude = spectral0Peak2amplitude - spectral0Peak3amplitude
spectral0Peak4amplitude = spectral0Peak4amplitude - spectral0Peak3amplitude
spectral0Peak3amplitude = spectral0Peak3amplitude - spectral0Peak3amplitude
spectral1Peak1amplitude = spectral1Peak1amplitude - spectral1Peak3amplitude
spectral1Peak2amplitude = spectral1Peak2amplitude - spectral1Peak3amplitude
spectral1Peak4amplitude = spectral1Peak4amplitude - spectral1Peak3amplitude
spectral1Peak3amplitude = spectral1Peak3amplitude - spectral1Peak3amplitude
spectral2Peak1amplitude = spectral2Peak1amplitude - spectral2Peak3amplitude
spectral2Peak2amplitude = spectral2Peak2amplitude - spectral2Peak3amplitude
spectral2Peak4amplitude = spectral2Peak4amplitude - spectral2Peak3amplitude
spectral2Peak3amplitude = spectral2Peak3amplitude - spectral2Peak3amplitude
spectral3Peak1amplitude = spectral3Peak1amplitude - spectral3Peak3amplitude
spectral3Peak2amplitude = spectral3Peak2amplitude - spectral3Peak3amplitude
spectral3Peak4amplitude = spectral3Peak4amplitude - spectral3Peak3amplitude
spectral3Peak3amplitude = spectral3Peak3amplitude - spectral3Peak3amplitude


pause finished one root

endproc

