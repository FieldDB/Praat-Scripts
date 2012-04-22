# Tokenize utterance tiers in a Praat TextGrid file
# (Slightly adapted for ELFA)
#
# This script makes copies of all the tiers in each TextGrid in a given directory and tokenizes the annotations in each 
# original tier to the corresponding new word tier.
#
# 9.4.2012
# Mietta Lennes
#

# Ask the user for the input directory
form Tokenize the utterance tiers in TextGrid files
	text Directory 
endform
# Read the list of files in the given directory
Create Strings as file list... grids 'directory$'*.TextGrid
files = Get number of strings
echo 'files' TextGrid files found in directory 'directory$'.'newline$'

# Loop through all the files:
for file to files
	file$ = Get string... file
	Read from file... 'directory$''file$'
	printline Tokenizing: 'file$'
	
	gridname$ = selected$ ("TextGrid", 1)
	gridfile$ = directory$ + gridname$ + ".TextGrid"
	
	
	# Initialize some variables
	total_duration = Get total duration
	stringlength = 0
	oldlabel$ = ""
	newlabel$ = ""
	word_end = 0
	
	tier = 1
	starting_interval = 1 
	overwrite = 1
	
	# Copy the original transcript tiers into new word tiers, which will be named originalname-word
	select TextGrid 'gridname$'
	numberOfTiers = Get number of tiers
	speakerTiers = 0
	for t to numberOfTiers
		tier$ = Get tier name... t
			speakerTiers = speakerTiers + 1
			original_tier_'speakerTiers' = t
			t = t + 1
			new_tier$ = "'tier$'-word"
			Duplicate tier... original_tier_'speakerTiers' t 'new_tier$'
		endif
		numberOfTiers = Get number of tiers
	endfor
	numberOfSpeakers = speakerTiers
	
	# Loop through all the tiers in the TextGrid and process each pair of original tier + word tier:
	for t from 1 to numberOfTiers
	   original_tier = t
	   word_tier = t + 1
	   
	   numberOfUtteranceIntervals = Get number of intervals... original_tier
	   
	   # Loop through all utterance intervals for this speaker and tokenize them
	   for utt to numberOfUtteranceIntervals
			utterance$ = Get label of interval... original_tier utt
			if utterance$ <> ""
				words = 0
				# Remove any trailing spaces:
				while right$ (utterance$,1 ) = " "
					utterance$ = left$(utterance$, length(utterance$)-1)
				endwhile
				# Remove any leading spaces:
				while left$ (utterance$,1 ) = " "
					utterance$ = right$(utterance$, length(utterance$)-1)
				endwhile
				tmp_utterance$ = utterance$
				if index (utterance$, " ") = 0
					words = 1
					word_'words'$ = utterance$
					tmp_utterance$ = ""
				endif
				# Divide the utterance into words at (one or more) space characters
				while index(tmp_utterance$," ") > 0 or length(tmp_utterance$) > 0
					words = words + 1
					word_'words'$ = left$(tmp_utterance$, index(tmp_utterance$, " ")-1)
					if index(tmp_utterance$, " ") > 0
						tmp_utterance$ = right$(tmp_utterance$, length(tmp_utterance$)-index(tmp_utterance$, " "))
						while left$ (tmp_utterance$,1 ) = " "
							tmp_utterance$ = right$(tmp_utterance$, length(tmp_utterance$)-1)
						endwhile
					else
						word_'words'$ = tmp_utterance$
						tmp_utterance$ = ""
					endif
				endwhile
				# Count the total number of characters ("duration units") in each word and in the whole utterance,
				# excluding the special overlap markers {} in ELFA:
				utterance_length = 0
				for word to words
					word_'word'_length = 0
					for char to length(word_'word'$)
						if mid$(word_'word'$,char,1) <> "{" and mid$(word_'word'$,char,1) <> "}"
							utterance_length = utterance_length + 1
							word_'word'_length = word_'word'_length + 1
						endif
					endfor
				endfor
				
				utterance_start = Get starting point... original_tier utt
				utterance_end = Get end point... original_tier utt

				# ELFA modification:
				# Check for errors where the next utterance starts before the current utterance ends in the same utterance tier
				# (typical for ELFA where the original tiers have been created automatically from a non-time-aligned text file):
				if utt < numberOfUtteranceIntervals
					next_utt = utt + 1
					next_utterance_start = Get starting point... original_tier next_utt
					next_utterance$ = Get label of interval... original_tier next_utt
					# Remove the utterance end that occurs erroneously after the next utterance start:
					if next_utterance_start < utterance_end
						Remove right boundary... original_tier utt
						Insert boundary... original_tier next_utterance_start
						Set interval text... original_tier utt 'utterance$'
						Set interval text... original_tier next_utt 'next_utterance$'
						numberOfUtteranceIntervals = Get number of intervals... original_tier
						utterance_start = Get starting point... original_tier utt
						utterance_end = Get end point... original_tier utt
						# Do the same fix for the word tier where the errors have been copied:
						word_interval = Get interval at time... word_tier utterance_start
						word_start = Get starting point... word_tier word_interval
						word_end = Get end point... word_tier word_interval
						Remove right boundary... word_tier word_interval
						Insert boundary... word_tier next_utterance_start
						Set interval text... word_tier word_interval 'utterance$'
						next_word_interval = word_interval + 1
						Set interval text... word_tier next_word_interval 'next_utterance$'
						# This should fix it! - ML 9.4.2012
					endif
				endif
				
				# Divide the duration of the utterance by the number of characters, which was counted before:
				utterance_dur = utterance_end - utterance_start
				dur_unit = utterance_dur / utterance_length
				
				word_interval = Get interval at time... word_tier utterance_start
				word_start = Get starting point... word_tier word_interval
				# Insert the starting boundary for the first word, if required:
				if word_start < utterance_start
					Insert boundary... word_tier utterance_start
					word_interval = Get interval at time... word_tier utterance_start
					word_start = Get starting point... word_tier word_interval
				endif
				# Insert the end boundary for each word in the utterance, according to the number of characters:
				for word to words
					# In case the word is not empty, insert the text and the end boundary:
					if word_'word'_length > 0
						word$ = word_'word'$
						Set interval text... word_tier word_interval 'word$'
						word_end = word_start + (word_'word'_length * dur_unit)
						# The boundary will be added only in case there is no end boundary already:
						if word_end < total_duration and word_end < utterance_end
							Insert boundary... word_tier word_end
						endif
						word_start = word_end
						word_interval = Get interval at time... word_tier word_start
					endif
				endfor
			endif
	   endfor   
	
	   # Move on to the next speaker (= the next utterance tier or original transcript tier)   
	   t = t + 1
	endfor
	
	# Save this TextGrid file and remove the object from cluttering the Object window
	select TextGrid 'gridname$'
	Write to text file... 'gridfile$'
	Remove

	# and continue with the next TexctGrid file in the directory.
	select Strings grids
endfor

# Finally, remove the Strings object.
Remove

# Done!
printline ... Done.