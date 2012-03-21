# Align a conversation transcript with a sound file
#
# This Praat script reads lines of text from a plain text file (UTF-8) and helps the user align each 
# speaker's turns or utterances with the corresponding sound file.
# One LongSound object must be selected in the Objects window (use the command Open:Open long sound file...).
#
# This script is distributed under the Gnu General Public License.
# Mietta Lennes 1.3.2012
#
# 2.3.2012 (ML): Comma chunking is now switched off! Full stop, tab and repeated spaces still work if use_text_chunking = 1.
# 
#

form Align a conversation transcript with LongSound
	comment Splice the original text lines into shorter chunks?
	comment (cut at full stops, tabs, or 3 or more repeated spaces)
	boolean Use_text_chunking 1
	comment Play suggested utterance automatically? (0=no, 1=play all, 0,8=play 0.8 sec)
	real Play_automatically 0.8
endform

#--- The default string that follows the speaker code and the semicolon : (will be removed before aligning each line)
# (here, a tab character)
default_start_string$ = "	"

#---- Do you wish to automatically chunk the text on the basis of commas, full stops, tab characters and repeated space dharacters?
# 	  (Set this to 0 in case you only want coarse alignment of the entire lines of text.)
#use_text_chunking = 1

# Do not play automatically:
#play_automatically = 0
# Play 0.7 seconds from the beginning of each suggested utterance:
#play_automatically = 0.8
# Play entire utterance automatically:
#play_automatically = 1

#------- NB: This script uses full stops, tabs and repeated spaces as pause markers.

# Default durations for long pauses (e.g., at line breaks, full stops and tab characters) and short pauses (e.g., at a comma) 
short_pause = 0.2
long_pause = 0.5
expected_duration_per_character = 0.06

soundname$ = selected$ ("LongSound", 1)
gridfile$ = soundname$ + ".TextGrid"
tmpfile$ = soundname$ + ".tmp"
total_duration = Get total duration
# Sound ID is the left part of the sound name, separated with an underscore _.
sound_id$ = left$(soundname$, (index(soundname$,"_")-1))

#---- First check whether there is a matching TextGrid file:
continue = 0
if fileReadable (gridfile$)
	pause The TextGrid file already exists. We will continue aligning it.
	Read from file... 'gridfile$'
	gridname$ = selected$ ("TextGrid", 1)
	continue = 1
else
	# If no existing TextGrid was found, create a new TextGrid object with only one tier "original":
	select LongSound 'soundname$'
	To TextGrid... original
	gridname$ = selected$ ("TextGrid", 1)
endif
original_tier = 1


#----- Open the transcript file that needs to be aligned:
transcript_file$ = soundname$ + ".txt"
if fileReadable (transcript_file$)
	printline The transcript file 'transcript_file$' was found.
	Read Strings from raw text file... 'transcript_file$'
	Rename... transcript
else
	printline The transcript file 'transcript_file$' was not found.
	transcript_file$ = sound_id$ + ".txt"
	if fileReadable (transcript_file$)
		printline The transcript file 'transcript_file$' was found.
		Read Strings from raw text file... 'transcript_file$'
		Rename... transcript
	else
		exit The transcript file 'transcript_file$' was not found. Please save the transcript to the same directory with this script!
	endif
endif


#--- Separate a possible header from the beginning of the transcript and save it to an .info file:
numberOfLines = Get number of strings
header_breakline = 0
for line to numberOfLines
	line$ = Get string... line
	if line$ = "" and line < numberOfLines
		header_breakline = line
		line = numberOfLines
	endif
endfor
if header_breakline > 0
	# Create a header file:
	header_file$ = gridname$ + ".info"
	if fileReadable (header_file$)
		pause The header file 'header_file$' already exists! Continue and overwrite?
		filedelete 'header_file$'
	endif
	for line from 1 to header_breakline
		line$ = Get string... line
		if line$ <> ""
			fileappend 'header_file$' 'line$''newline$'
		endif
	endfor
	begline = header_breakline + 1
	filedelete 'transcript_file$'
	for line from begline to numberOfLines
		line$ = Get string... line
		if line$ <> ""
			fileappend 'transcript_file$' 'line$''newline$'
		endif
	endfor
	Remove
	# Read in the new, shorter version of the transcript file:
	Read Strings from raw text file... 'transcript_file$'
	Rename... transcript
	numberOfLines = Get number of strings
endif

#------ The parameters for pause detection in this particular sound file are stored in a text file (you can modify them if required):
pause_parameter_file$ = soundname$ + "_pause_parms.txt"
if fileReadable (pause_parameter_file$)
	Read Strings from raw text file... 'pause_parameter_file$'
	Rename... pause_parameters
else
	# Save the default parameters in the text file:
	fileappend 'pause_parameter_file$' Minimum_duration_(seconds) 0.2'newline$'
	fileappend 'pause_parameter_file$' Maximum_intensity_(dB) 54'newline$'
	fileappend 'pause_parameter_file$' Minimum_pitch_(Hz) 70'newline$'
	fileappend 'pause_parameter_file$' Time_step_(0=auto) 0'newline$'
	Read Strings from raw text file... 'pause_parameter_file$'
	Rename... pause_parameters
endif
call UpdatePauseParameters


completed_lines = 0
utt_count = 0
first_utt = 0
unfinished_line = 0

#---- Now begin the actual alignment process.

previous_speaker$ = ""
previous_end = 0
speaker$ = ""
speaker = 0
numberOfSpeakers = 0

select TextGrid 'gridname$'
editorIsOpen = 0

at_line = 1

if continue = 1
	# If this is continuing earlier work, check first how many tiers and speakers there are
	numberOfSpeakers = Get number of tiers
	# The last tier is supposed to contain the original lines of text.
	numberOfSpeakers = numberOfSpeakers - 1
	for tier to numberOfSpeakers
		speaker_'tier'$ = Get tier name... tier
		speaker_'tier'_tier = tier
	endfor	
	original_tier = Get number of tiers
	original_tier$ = Get tier name... original_tier
	if original_tier$ <> "original"
		pause The last tier is not called "original". In case it contains a speaker's utterances, you can continue, otherwise please stop and rename the tier!
		pause Please locate the last line of text that has been aligned in the TextGrid.
		# AVATAAN STRINGS JA TEXTGRID (ZOOMATAAN LOPPUUN) KATSOTTAVAKSI 
		# LUODAAN LOMAKE JOSSA KYSYTÄÄN ARVO at_line
		# LUODAAN GRIDIIN ORIGINAL-KERROS, JOSSA ON NYKYISEN RIVIN MÄÄRÄ + 1 KERROSTA
	else
		numberOfIntervals = Get number of intervals... original_tier
		at_line = 0
		unfinished_line = 0
		for i to numberOfIntervals
			t$ = Get label of interval... original_tier i
			first_utt =  Get end point... original_tier i
			if t$ <> ""
				at_line = at_line + 1
				if i = numberOfIntervals
					unfinished_line = 1
					first_utt =  Get starting point... original_tier i
				endif
			endif
		endfor
		if at_line = 0
			exit The "original" tier does not contain the original text lines. Please remove the tier and try again!
		elsif unfinished_line = 0
			# Continue from the next line of text.
			at_line = at_line + 1
		endif
	endif
	if at_line < 1
		at_line = 1
	endif
endif

date1$ = date$()
last_utt = first_utt

if unfinished_line = 1
	echo It seems that the line number 'at_line' has been partially annotated but not finished.
	printline This is the line:
	select Strings transcript
	string$ = Get string... at_line
	printline 'string$'
	printline
	printline Please finish aligning it manually!
	printline Once you have marked the final boundary for that line by that speaker, press Continue in order to proceed.
	select TextGrid 'gridname$'
	# Check the last speaker and the last interval:
		last_end = 0
		last_start = 0
		last_speaker = 0
		for spk to numberOfSpeakers
			t = speaker_'spk'_tier
			i = Get number of intervals... t
			i_txt$ = Get label of interval... t i
			i_end = Get end point... t i
			if i_txt$ = "" and i > 1
				i = i - 1
				i_txt$ = Get label of interval... t i
				i_start = Get starting point... t i
				i_end = Get end point... t i
			endif
			if i_end > last_end and i_txt$ <> ""
				last_start = i_start
				last_end = i_end
				last_speaker = spk
				last_speaker$ = speaker_'spk'$
				at_interval = i
				first_utt = last_start
				last_utt = last_end
			endif
		endfor
	win_start = last_start
	if win_start < 0
		win_start = 0
	endif
	win_end = last_end
	if win_end > total_duration
		win_end = total_duration
	endif
	speaker_tier = last_speaker
	call DisplayWaitAndUpdate win_start win_end
	at_line = at_line + 1
	unfinished_line = 0
endif

if at_line = numberOfLines
	exit You are done! All the 'numberOfLines' lines in the transcript file have already been aligned.
endif

for line from at_line to numberOfLines

	echo 
	select Strings transcript
	string$ = Get string... line
	speakercode = 0
	select TextGrid 'gridname$'
	# Extract the speaker code from the beginning of the line:
	if index(string$,":") > 0
		speaker$ = left$(string$, (index(string$,":")-1))
		while startsWith(speaker$,"	") or startsWith(speaker$," ")
			speaker$ = right$ (speaker$, (length(speaker$)-1))
		endwhile
		speakercode = 1
	endif
	# Check whether this speaker already has a tier:
	if numberOfSpeakers > 0
		speaker = 0
		for spk to numberOfSpeakers
			if speaker_'spk'$ = speaker$
				speaker = spk
				speaker_tier = speaker_'speaker'_tier
				spk = numberOfSpeakers
			endif
		endfor
	endif
	# If this speaker was not seen before, insert a tier for her:
	if speaker = 0
		numberOfSpeakers = numberOfSpeakers + 1
		speaker = numberOfSpeakers
		speaker_'speaker'$ = speaker$
		speaker_'speaker'_tier = numberOfSpeakers
		speaker_tier = numberOfSpeakers
		Insert interval tier... numberOfSpeakers 'speaker$'
		original_tier = original_tier + 1
	endif
	

	# Extract the actual text of the utterance (to be aligned next):
	if speakercode = 1
		speakercode$ = speaker$ + ":"
		text$ = extractLine$ (string$,speakercode$)	
	else
		text$ = string$
	endif	
	
		#----- Check who speaks the last interval that has been aligned thus far:
		last_end = 0
		last_start = 0
		last_speaker = 0
		at_interval = 0
		for spk to numberOfSpeakers
			t = speaker_'spk'_tier
			i = Get number of intervals... t
			i_txt$ = Get label of interval... t i
			i_end = Get end point... t i
			# Find the latest non-empty interval in this tier:
			while i_txt$ = "" and i > 1 and i_end > last_end
				i = i - 1
				i_txt$ = Get label of interval... t i
				i_start = Get starting point... t i
				i_end = Get end point... t i
				# In case there are consecutive empty intervals at the end of the tier for some reason, 
				# remove the boundary between them:
				if i_txt$ = ""
					Remove right boundary... t i
					i_end = Get end point... t i
				endif
			endwhile
			# If this interval ends later than those of the other speakers, record the information about it as the last interval:
			if i_end > last_end and i_txt$ <> ""
				last_start = i_start
				last_end = i_end
				last_speaker = spk
				last_speaker$ = speaker_'spk'$
				at_interval = i
			endif
		endfor
		if first_utt = 0 and line = at_line
			first_utt = last_start
			last_utt = last_end
		endif

		# Clean up this line of text before processing it further:
		# Remove the default start string (e.g., a tab) from the text line:
		text$ = right$(text$,(length(text$)-length(default_start_string$)))
		# Remove any final spaces or tabs
		while right$(text$,1) = " "
			text$ = left$ (text$, length(text$)-1)
		endwhile
		while right$(text$,1) = "	"
			text$ = left$ (text$, length(text$)-1)
		endwhile

		# We need to check whether overlapping speech is expected (= Are there leading spaces or tabs?).
		overlap = 0
		while left$ (text$,1) = "	" or left$ (text$,1) = " "
			if left$(text$,1) = "	"
				overlap = overlap + 5
			else
				overlap = overlap + 1
			endif
			text$ = right$(text$,(length(text$)-1))
		endwhile

		#----- Suggest new boundaries:
		text_length = length(text$)
		text_dur = text_length * expected_duration_per_character
		# If the text contains full stops, commas, tabs or repeated spaces, add the expected duration of the corresponding pauses:
		c = 0
		while c < length(text$)
			c = c + 1
			char$ = mid$(text$,c,1)
			if char$ = "." and c < length(text$)
				text_dur = text_dur + expected_duration_per_character
			elsif char$ = ","
				text_dur = text_dur + expected_duration_per_character
			elsif char$ = "	"
				text_dur = text_dur + short_pause
			else char$ = mid$(text$,c,3)
				if char$ = "   "
					text_dur = text_dur + short_pause
				endif
			endif
		endwhile
		# Check that the new utterance is after the last one of the utterances by all the other speakers
		# and within the time domain of the sound file:
		if overlap > 0
			if last_speaker <> speaker_tier
				interval_start = last_start + (overlap * expected_duration_per_character)
			else
				interval_start = last_end + (overlap * expected_duration_per_character)
			endif
		else
			interval_start = last_end + 0.01
		endif
		interval_end = interval_start + text_dur
		# Suggest a new starting boundary if possible:
		if overlap = 0
			# If this utterance does not overlap with the earlier speaker, look for a rise in intensity:
			tmp_window_end = interval_end + ((interval_end - interval_start)*5)
				if tmp_window_end - interval_end < 1
					tmp_window_end = tmp_window_end + 1
				endif
				if tmp_window_end - interval_end > 10
					tmp_window_end = tmp_window_end - 5
				endif
			call DetectNextPause interval_start tmp_window_end 0
			select TextGrid 'gridname$'
			if pauseend > 0 and pauseend > last_end and pausestart < (interval_start + short_pause)
				interval_start = pauseend
			endif
		endif		
		interval_end = interval_start + text_dur
		if interval_end > total_duration
			interval_end = total_duration
		endif
		if interval_start >= total_duration
			exit The new interval would begin after the end of the sound file. Please fix this manually! 
		endif
		Insert boundary... speaker_tier interval_start
		speaker_interval = Get interval at time... speaker_tier interval_start
		Insert boundary... original_tier interval_start
		original_interval = Get interval at time... original_tier interval_start
		Set interval text... original_tier original_interval 'string$'

		chunk = 1
		#--- Text chunking is only done in case the variable use_text_chunking was set to 1 (see the beginning of this script).
		# If the utterance text contains markers for pauses, slice the line into smaller pieces:
		if use_text_chunking = 1
			tmp$ = text$
			# Remove any final spaces or tabs
			while right$(tmp$,1) = " "
				tmp$ = left$ (tmp$, length(tmp$)-1)
			endwhile
			while right$(tmp$,1) = "	"
				tmp$ = left$ (tmp$, length(tmp$)-1)
			endwhile
			text_1$ = text$
			text_1_pause = long_pause
			space_index = index(tmp$, "   ")
			tab_index = index(tmp$, "	")
			#comma_index = index(tmp$, ",")
			full_stop_index = index(tmp$, ".")
			# Slice the text line into smaller pieces in the order of which type of pause marker occurs first:
			#while tab_index > 0 or space_index > 0 or comma_index > 0 or full_stop_index > 0
			while tab_index > 0 or space_index > 0 or full_stop_index > 0
				#if tab_index > 0 and ((tab_index < comma_index or comma_index = 0) and (tab_index < full_stop_index or full_stop_index = 0) and (tab_index < space_index or space_index = 0))
				if tab_index > 0 and ((tab_index < full_stop_index or full_stop_index = 0) and (tab_index < space_index or space_index = 0))
					text_'chunk'$ = left$ (tmp$, (index(tmp$, "	")-1))
					text_'chunk'_pause = short_pause
					tmp$ = right$ (tmp$, length(tmp$)-index(tmp$, "	"))
				# Comma chunking was switched off on 2.3.2012 - ML.
				#elsif comma_index > 0 and ((comma_index < tab_index or tab_index = 0) and (comma_index < full_stop_index or full_stop_index = 0) and (comma_index < space_index or space_index = 0))
					#text_'chunk'$ = left$ (tmp$, (index(tmp$, ",")))
					#text_'chunk'_pause = short_pause
					#tmp$ = right$ (tmp$, length(tmp$)-index(tmp$, ","))
				#elsif full_stop_index > 0 and ((full_stop_index < tab_index or tab_index = 0) and (full_stop_index < comma_index or comma_index = 0) and (full_stop_index < space_index or space_index = 0))
				elsif full_stop_index > 0 and ((full_stop_index < tab_index or tab_index = 0) and (full_stop_index < space_index or space_index = 0))
					text_'chunk'$ = left$ (tmp$, (index(tmp$, ".")))
					text_'chunk'_pause = long_pause
					tmp$ = right$ (tmp$, length(tmp$)-index(tmp$, "."))
				#elsif space_index > 0 and ((space_index < tab_index or tab_index = 0) and (space_index < comma_index or comma_index = 0) and (space_index < full_stop_index or full_stop_index = 0))
				elsif space_index > 0 and ((space_index < tab_index or tab_index = 0) and (space_index < full_stop_index or full_stop_index = 0))
					text_'chunk'$ = left$ (tmp$, (index(tmp$, "   ")-1))
					text_'chunk'_pause = long_pause
					tmp$ = right$ (tmp$, length(tmp$)-index(tmp$, "   ")-2)
				endif
				# Remove any leading spaces from the leftover text (i.e., from the rest of the line):
				while left$(tmp$,1) = " " or left$(tmp$,1) = "	"
					tmp$ = right$ (tmp$, length(tmp$)-1)
				endwhile
				# Check again whether some of the pause markers still occur in the leftover text:
				space_index = index(tmp$, "   ")
				tab_index = index(tmp$, "	")
				#comma_index = index(tmp$, ",")
				full_stop_index = index(tmp$, ".")
				# Increase counter for the number of chunks
				chunk = chunk + 1
				# In case there would be no more pause markers, store the final piece of the text into the new chunk:
				text_'chunk'$ = tmp$
				text_'chunk'_pause = 0
				if tmp$ = ""
					chunk = chunk - 1
				endif
			endwhile
		endif

		sub_start = interval_start
		if chunk = 1 or use_text_chunking = 0
			text_length = length(text$)
			text_dur = text_length * expected_duration_per_character
			# If the text contains full stops, repeated spaces or tabs, add the expected duration of the corresponding pauses:
			c = 0
			while c < length(text$)
				c = c + 1
				char$ = mid$(text$,c,1)
				if char$ = "." and c < length(text$)
					text_dur = text_dur + expected_duration_per_character
				elsif char$ = ","
					text_dur = text_dur + expected_duration_per_character
				elsif char$ = "	"
					text_dur = text_dur + short_pause
				else char$ = mid$(text$,c,3)
					if char$ = "   "
						text_dur = text_dur + short_pause
					endif
				endif
			endwhile
			max_dur = 4 * text_dur
			min_dur = 0.5 * text_dur
			# If there is only one utterance in the line of text, insert this as is:
			speaker_interval = Get interval at time... speaker_tier interval_start
			Set interval text... speaker_tier speaker_interval 'text$'
			# Try to determine a nice end for the utterance (after the midpoint of the character-based duration):
			tmp_window_end = interval_end + ((interval_end - interval_start)*3)
				if tmp_window_end - interval_start < 1
					tmp_window_end = tmp_window_end + 1
				endif
				if tmp_window_end - interval_start> 10
					tmp_window_end = tmp_window_end - 5
				endif
			call DetectNextPause interval_start tmp_window_end 0
			select TextGrid 'gridname$'
			# If the detected pause does not result in an overlong utterance, use it:
			if max_dur > pausestart - interval_start and min_dur < pausestart - interval_start
				interval_end = pausestart
			endif
			# Insert the final boundary, if possible:
			if interval_end < total_duration and interval_end > interval_start
				Insert boundary... speaker_tier interval_end
			elsif interval_end < total_duration
				interval_end = interval_start + short_pause
				Insert boundary... speaker_tier interval_end
			else
				interval_end = total_duration
			endif
		else
			# Loop through the text chunks and insert the boundaries for each of them:
			for ch to chunk
				speaker_interval = Get interval at time... speaker_tier sub_start
				text_length = length(text_'ch'$)
				text_dur = text_length * expected_duration_per_character
				max_dur = 6 * text_dur
				min_dur = 0.5 * text_dur
				interval_end = sub_start + text_dur
				# Try to determine a nice end for the utterance 
				# (somewhere after the midpoint of the character-based duration):
				tmp_window_start = sub_start + short_pause
				tmp_window_end = interval_end + ((interval_end - sub_start)*8)
				if tmp_window_end - tmp_window_start < 1
					tmp_window_end = tmp_window_end + 1
				endif
				if tmp_window_end - tmp_window_start > 10
					tmp_window_end = tmp_window_end - 5
				endif
				call DetectNextPause tmp_window_start tmp_window_end 0
				select TextGrid 'gridname$'
				# If the detected pause does not result in an overlong utterance, use it:
				if max_dur > pausestart - sub_start and min_dur < pausestart - sub_start
					interval_end = pausestart
				endif
				chunk$ = text_'ch'$
				printline 'sub_start' 'interval_end' ('text_dur') 'chunk$'
				if interval_end <= sub_start
					interval_end = sub_start + 0.1
				endif
				# Insert the end boundary of each chunk
				if interval_end < total_duration
					Insert boundary... speaker_tier interval_end
				else
					interval_end = total_duration
				endif
				Set interval text... speaker_tier speaker_interval 'chunk$'

				# Determine the start boundary of the next chunk, if required:
				if pauseduration = 0
					pauseduration = text_'ch'_pause
				endif
				if ch < chunk
					call DisplayWaitAndUpdate sub_start interval_end
					last_utt = interval_end
					select TextGrid 'gridname$'

					sub_start = interval_end + text_'ch'_pause
					tmp_window_start = interval_end
					tmp_window_end = interval_end + ((interval_end - sub_start)*5)
					call DetectNextPause tmp_window_start tmp_window_end 1
					if pauseend > sub_start and (pauseend - sub_start) < (text_'ch'_pause * 20)
						sub_start = pauseend
					endif
					if sub_start > total_duration
						exit The next utterance would begin after the end of the sound file. Please fix this manually! 
					endif
					Insert boundary... speaker_tier sub_start
					interval_start = sub_start
				endif
			endfor
		endif
	endif
		
	call DisplayWaitAndUpdate interval_start interval_end
	last_utt = interval_end
																																										
	select TextGrid 'gridname$'
	Write to short text file... 'gridfile$'
	completed_lines = completed_lines + 1

	call UpdatePauseParameters
	
	continue = 0

endfor


#-------------
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
	
endproc

#-----------
procedure UpdatePauseParameters
# Get the pause parameters from the Strings object (can be edited during the alignment work!) when required.

	select Strings pause_parameters
	minimum_duration$ = Get string... 1
	minimum_duration = extractNumber(minimum_duration$, "Minimum_duration_(seconds)")
	maximum_intensity$ = Get string... 2
	maximum_intensity = extractNumber(maximum_intensity$, "Maximum_intensity_(dB)")
	minimum_pitch$ = Get string... 3
	minimum_pitch = extractNumber(minimum_pitch$, "Minimum_pitch_(Hz)")
	time_step$ = Get string... 4
	time_step = extractNumber(time_step$, "Time_step_(0=auto)")

endproc

#--------------
procedure DetectNextPause windowstart windowend get_pause_end_only
# Get pause end only: 0 or 1. If 1, a pause has already been confirmed at the start of the analysis window, and the
# beginning of the next utterance needs to be determined.
#
# Output:
# if pauseend = 0 and pausedetected = 1, the expected or detected pause did not yet end within the time window
# pauseduration = the duration of the pause
# pausestart, pauseend correspondingly


	pauseend = 0
	pausenumber = 0
	frame = 0
	time = 0
	intensity = 0
	pausedetected = get_pause_end_only
	pausestart = 0
	if get_pause_end_only = 1
		pausestart = windowstart
	endif
	pauseduration = 0
	pauseend = 0


# Only do this for sound windows of over 0.1 seconds.
if windowend - windowstart > 0.1

	select LongSound 'soundname$'
	Extract part... windowstart windowend yes
	Rename... Window
	To Intensity... minimum_pitch time_step
	frames = Get number of frames
	if get_pause_end_only = 1
		pausestart = windowstart
	endif
	frame = 1
		#--------------------------------------------------------------------------------------------------
		# Loop through all frames in the Intensity object:
		select Intensity Window

		while frame <= frames
			intensity = Get value in frame... frame
			time = Get time from frame... frame

			if intensity > maximum_intensity
				if pausedetected = 1
					# If the end of an earlier detected possible pause has been reached:
					if frame - 1 < 1
						pauseend = windowstart
					else
						pauseend = Get time from frame... (frame - 1)
					endif
				endif
			elsif pausedetected = 0
			# If this frame is under the intensity threshold, a new pause is started 
				pausestart = Get time from frame... frame
				pauseend = 0
				pausedetected = 1	
			endif
			# If a detected pause just continues, do nothing special.

			# If the end of a pause was just detected, check whether the silence was sufficiently long:
			if pauseend > 0
				pauseduration = pauseend - pausestart
			endif
			if pauseduration >= minimum_duration
				# Apparently, a real pause was found. Stop the loop.
				frame = frames
			elsif pauseduration > 0
				# If there was a silenvce but it was not long enough, reset and continue to look for another longer pause.
				pausedetected = 0
				pauseduration = 0
				pausestart = 0
				pauseend = 0
			endif	
			frame = frame + 1
			# When all frames in the intensity analysis have been looked at, end the frame loop.
		endwhile
		#--------------------------------------------------------------------------------------------------
	select Sound Window
	plus Intensity Window
	Remove

endif

endproc

#----
procedure DisplayWaitAndUpdate win_start win_end

	if unfinished_line = 0
		# Print the current part of the original transcript file to the Info window:
		start_line = line - 5
		end_line = line + 5
		target_line = start_line + 5
		if start_line < 1
			target_line = target_line + start_line - 1
			start_line = 1	
		endif
		if end_line > numberOfLines
			end_line = numberOfLines
		endif
		select Strings transcript
		transcript_line$ = Get string... start_line
		echo Lines 'start_line' to 'end_line':
		printline 'transcript_line$'
		start_line = start_line + 1
		for l from start_line to end_line
			transcript_line$ = Get string... l
			if l = target_line
				printline >> 'transcript_line$'
			else
				printline    'transcript_line$'					
			endif
		endfor
	endif

	# Zoom to a minimally 5-second area around the utterance:
	if (win_end - win_start) < 3
		win = 2.5 - (win_end - win_start) / 2
	else
		win = 1
	endif
	sel_start = win_start - win
	if sel_start < 0
		sel_start = 0
	endif
	sel_end = win_end + win
	if sel_end > total_duration
		sel_end = total_duration
	endif
	select LongSound 'soundname$'
	plus TextGrid 'gridname$'
	if editorIsOpen = 0
		Edit
		editorIsOpen = 1
	endif
	editor TextGrid 'gridname$'
	for f from 2 to speaker_tier
		Select next tier
	endfor
	Select... sel_start sel_end
	Zoom to selection
	Select... win_start win_end
	Move cursor to... win_start
	
	if play_automatically = 1
		Play... win_start win_end
	elsif play_automatically > 0 and play_automatically <> 1
		play_end = win_start + play_automatically
		Play... win_start play_end
	endif

# Wait for the revisions made by the user:
	beginPause ("Continue?")
	comment ("Please check the boundaries thus far and select:")
	clicked = endPause ("Continue","Save and quit",1)

	Close
 editorIsOpen = 0
	#endeditor
	
	# Save file
	select TextGrid 'gridname$'
	Write to short text file... 'gridfile$'
	utt_count = utt_count + 1


# Check where the last aligned interval is now (in order to keep the information for the future):
	select TextGrid 'gridname$'
	numberOfIntervals = Get number of intervals... speaker_tier
	speaker_interval = numberOfIntervals
	last_interval_text$ = Get label of interval... speaker_tier speaker_interval
	interval_end = Get end point... speaker_tier speaker_interval
	if last_interval_text$ = ""
		if numberOfIntervals > 1
			speaker_interval = speaker_interval - 1
			interval_end = Get end point... speaker_tier speaker_interval
			last_interval_text$ = Get label of interval... speaker_tier speaker_interval
		endif
	endif

	completed_duration = last_utt - first_utt
	percent = (completed_duration / total_duration) * 100
	# Jos käyttäjä halusi lopettaa työt:
	if clicked = 2
		date2$ = date$()
		echo Today's report:
		printline
		printline Congratulations! 
		printline You completed the alignment for 'completed_lines' lines of text and 'utt_count' utterances in the transcript file.
		printline The alignments covered the duration of 'completed_duration:1' s ('first_utt:2'-'last_utt:2's, 'percent:0'%) in the sound file.
		printline
		printline You started work: 'date1$'
		printline  and finished at: 'date2$'
		printline
		printline The TextGrid file was saved to 'gridfile$'.
		exit The TextGrid file was saved to 'gridfile$'.
	endif

endproc