# This script goes through sound and TextGrid files in a directory,
# opens each pair of Sound and TextGrid, calculates the duration
# of each labeled interval in the phone tier, 
# the pitch maximum at the center of the phone, and
# the duration of the corresponding interval in the syllable tier, 
# and then saves the results to a text file.
#
# To make some other or additional analyses, you can modify the script
# yourself... it should be reasonably well commented! ;)
#
# This script is distributed under the GNU General Public License.
# Copyright 25.11.2004 Mietta Lennes

form Analyze durations of phones and the corresponding syllables
	comment Directory of sound files
	text sound_directory /home/lennes/kysymykset/
	sentence Sound_file_extension .aif
	comment Directory of TextGrid files
	text textGrid_directory /home/lennes/kysymykset/
	sentence TextGrid_file_extension .TextGrid
	comment Full path of the resulting text file:
	text resultfile /home/lennes/kysymykset/pitchresults.txt
	comment Which tier contains the speech sound segments?
	sentence Phone_tier phone
	comment Which tier contains the syllable segments?
	sentence Syllable_tier syllable
	comment Pitch analysis parameters
	real Time_step 0.0 (=auto)
	positive Minimum_pitch 75
	positive Maximum_pitch 500
endform

# Here, you make a listing of all the sound files in a directory.
# The example gets file names ending with ".aif" from C:\kysymykset\

Create Strings as file list... list 'sound_directory$'*'sound_file_extension$'
numberOfFiles = Get number of strings

# Check if the result file exists:
if fileReadable (resultfile$)
	pause The result file 'resultfile$' already exists! Do you want to overwrite it?
	filedelete "'resultfile$'"
endif

# Write a row with column titles to the result file:
# (remember to edit this if you add or change the analyses!)

titleline$ = "Filename	Preceding phone	Phone label		Starting point	Phone duration	Pitch max in phone	Syllable label	Syllable duration'newline$'"
fileappend "'resultfile$'" 'titleline$'

# Go through all the sound files, one by one:

for ifile to numberOfFiles
	filename$ = Get string... ifile
	# A sound file is opened from the listing:
	Read from file... 'sound_directory$''filename$'
	# Starting from here, you can add everything that should be 
	# repeated for every sound file that was opened:
	soundname$ = selected$ ("Sound", 1)
	# Open a TextGrid by the same name:
	gridfile$ = "'textGrid_directory$''soundname$''textGrid_file_extension$'"
	if fileReadable (gridfile$)
		Read from file... 'gridfile$'
		# Find the tier number that has the label given in the form:
		call GetTier 'phone_tier$' phone_tier
		call GetTier 'syllable_tier$' syllable_tier
		if phone_tier > 0 and syllable_tier > 0
			numberOfIntervals = Get number of intervals... phone_tier
			preceding_label$ = ""
			select Sound 'soundname$'
			To Pitch... time_step minimum_pitch maximum_pitch
			select TextGrid 'soundname$'
			# Pass through all intervals in the selected phone tier:
			for interval to numberOfIntervals
				label$ = Get label of interval... phone_tier interval
				if label$ <> ""
					# if the interval has an unempty label, get its start and end:
					start = Get starting point... phone_tier interval
					end = Get end point... phone_tier interval
					# get the duration of the phone segment
					phonedur = end - start
					# get the time at the middle of the phone:
					phonecenter = (start + end) / 2
					select Pitch 'soundname$'
					pitchmax = Get maximum... start end Hertz Parabolic
					select TextGrid 'soundname$'
					# get the syllable interval number at the phone center:
					syllable = Get interval at time... syllable_tier phonecenter
					# get the label of that syllable:
					syllable_label$ = Get label of interval... syllable_tier syllable
					syllstart = Get starting point... syllable_tier syllable
					syllend = Get end point... syllable_tier syllable
					# get the duration of the syllable segment:
					syllabledur = syllend - syllstart
					# Save result to text file:
					resultline$ = "'soundname$'	'preceding_label$'	'label$'	'start'	'phonedur'	'pitchmax'	'syllable_label$' 'syllabledur''newline$'"
					fileappend "'resultfile$'" 'resultline$'
					select TextGrid 'soundname$'
				endif
				preceding_label$ = label$
			endfor
			# Remove the Pitch object
			select Pitch 'soundname$'
			Remove
		endif
		# Remove the TextGrid object from the object list
		select TextGrid 'soundname$'
		Remove
	endif
	# Remove the sound object from the object list
	select Sound 'soundname$'
	Remove
	select Strings list
	# and go on with the next sound file!
endfor

Remove


#-------------
# This procedure finds the number of a tier that has a given label.

procedure GetTier name$ variable$
        numberOfTiers = Get number of tiers
        itier = 1
        repeat
                tier$ = Get tier name... itier
                itier = itier + 1
        until tier$ = name$ or itier > numberOfTiers
        if tier$ <> name$
                'variable$' = 0
        else
                'variable$' = itier - 1
        endif

	if 'variable$' = 0
		printline The tier called 'name$' is missing from the file 'soundname$'!
	endif

endproc
