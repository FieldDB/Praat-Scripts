# This script opens a stereo file as two sound objects and 
# saves the channels to separate sound files.
#
# This script is distributed under the GNU General Public License.
# Copyright 8.5.2004 Mietta Lennes

form Separate channels from stereo sound file
comment Give the path of the stereo file:
text file /home/lennes/restricted/snd/D6/D6.aif
comment Give the directory for the mono files:
text directory /home/lennes/restricted/snd/D6/
endform

printline Reading sounds from 'file$'...

if fileReadable (file$)
	Read two Sounds from stereo file... 'file$'
	printline Saving channels to directory 'directory$'...
	leftchannel$ = selected$ ("Sound", 1)
	rightchannel$ = selected$ ("Sound", 2)

	# Save the left channel:
	select Sound 'leftchannel$'
	leftfile$ = leftchannel$ + ".aif"
	leftfilepath$ = directory$ + leftfile$
	newfile = 0
	while fileReadable (leftfilepath$)
		newfile = newfile + 1
		leftfilepath$ = directory$ + leftchannel$ + "_'newfile'.aif"
	endwhile
	Write to AIFF file... 'leftfilepath$'
	Remove
	printline Saved left channel to 'leftfilepath$'

	# Save the right channel:
	select Sound 'rightchannel$'
	rightfile$ = rightchannel$ + ".aif"
	rightfilepath$ = directory$ + rightfile$
	newfile = 0
	while fileReadable (rightfilepath$)
		newfile = newfile + 1
		rightfilepath$ = directory$ + rightchannel$ + "_'newfile'.aif"
	endwhile
	Write to AIFF file... 'rightfilepath$'
	Remove
	printline Saved right channel to 'rightfilepath$'

	printline ... Done!
else
	exit File 'file$' was not readable. Please check the file path!
endif
