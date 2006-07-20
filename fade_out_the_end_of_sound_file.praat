# This script will fade out the end of a sound file 
# by filtering it with the latter half of a Hanning window.
#
# This script is distributed under the GNU General Public License.
# Copyright Mietta Lennes 25.9.2003
#

form Fade out the end of a sound file
comment Give the directory path of the original sound:
text file /home/lennes/projektit/cbru/syllables/1ka2_takka.wav
comment Give the directory path of the resulting sound:
text file2 /home/lennes/tmp/filtered.wav
positive Fade_from_time_(s) 0.05
positive zero_at_time 0.09
endform

if fileReadable (file$)
	Read from file... 'file$'

	# Test that the sound has the minimum duration required:
	duration = Get duration
	if duration >= zero_at_time
		#you can uncomment the next line if you want a copy of the original sound somewhere...
		#Write to WAV file... /home/lennes/tmp/original.wav
		call CutSoundToDuration zero_at_time
		call Fadeout fade_from_time
		Write to WAV file... 'file2$'
	else
		printline File 'file$' is not long enough for fading!
		printline   (it's only about 'duration:5' seconds)
	endif
	Remove
else
	printline File 'file$' is not readable.
endif


#-----
#
procedure CutSoundToDuration tempdur

	sound$ = selected$ ("Sound")
	Extract part... 0 tempdur Rectangular 1.0 no
	Rename... temp
	select Sound 'sound$'
	Remove
	select Sound temp
	Rename... 'sound$'

endproc


#-----
# This procedure filters the end of the sound object with a Hanning window.
procedure Fadeout fadetime

	numberOfSamples = Get number of samples
	index_at_fadetime = Get index from time... fadetime
	index_at_fadetime = index_at_fadetime - 1
	effective_samples = numberOfSamples - index_at_fadetime
	doubled_effective_samples = effective_samples * 2
	printline Filtering sound...

	for index from index_at_fadetime to numberOfSamples
		oldvalue = Get value at index... index
		effective_index = index - index_at_fadetime
		if effective_index > 0
			
			# The following is supposed to implement the latter half of the Hanning window:
			newvalue = oldvalue * (0.5 * (1 - (cos ((2 * pi * (effective_index + effective_samples)) / (doubled_effective_samples - 1)))))
			
			if index < numberOfSamples
				Set value at index... index newvalue
			else
				# The very last sample should have zero value.
				Set value at index... index 0
			endif
		endif
	endfor	

endproc
