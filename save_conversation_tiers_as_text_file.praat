# This script exports the labeled utterances in a conversation to a plain text file (UTF-8,
# or whatever Praat supports as the default format for text files).
#
# Prerequisites:
# Exactly one TextGrid object containing 1-4 tiers with labeled intervals must be selected 
# in the Object window.
# Each speaker must be represented by one interval tier in the selected TextGrid object.
# Tier names are used in the output file as individual codes for the speakers, so you should change
# them if necessary.
#
# Output:
# The script writes the utterance labels to a plain text file (UTF-8 encoding), one utterance per line. 
# Each line starts with the name of the TextGrid tier where that particular 
# utterance occurred (could be the name of the speaker), followed by a double colon : and a tab.
# Lines are saved in the order of their starting times within the TextGrid object.
# Pause duration in seconds is indicated in brackets (), in case there is no overlap.
# Utterances that are completely overlapped by the preceding speaker are marked in square brackets [].
#
# Up to four speakers and TextGrid tiers are currently supported.
#
# This script is distributed under the GNU General Public License.
# 10.12.2009 Mietta Lennes


# Ask the user for some details:
form Export conversation to a plain text file
comment Names of the tiers that contain the utterances of the different participants:
sentence Tier_name_1 F1
sentence Tier_name_2 F2
sentence Tier_name_3 
sentence Tier_name_4 
boolean Insert_start_times yes
boolean Insert_pause_durations yes
boolean Include_start_times_for_overlaps yes
comment Path (optional) and filename:
text Filepath conversation.txt
endform

gridname$ = selected$ ("TextGrid", 1)
# Convert the special characters in the TextGrid into Unicode format
Nativize
total_duration = Get total duration
start_time = Get start time

# Check whether the user wishes to overwrite an existing file by the same name:
if fileReadable(filepath$)
	pause File 'filepath$' exists! Delete it and continue?
	filedelete 'filepath$'
endif
date$ = date$()
fileappend 'filepath$' 'gridname$'	('date$')'newline$''newline$'

# Check how many speaker/tier names the user has filled in to the form:
numberOfSpeakers = 0
for tier from 1 to 4
	if tier_name_'tier'$ <> ""
		numberOfSpeakers = numberOfSpeakers + 1
	else
		tier = 4
	endif
endfor

# Get the correct tier index number for each tier/speaker label in the TextGrid:
for tier to numberOfSpeakers
	tiername$ = tier_name_'tier'$
	call GetTier "'tiername$'" tier_'tier'
		if tier_'tier' = 0
			exit The tier "'tiername$'" was not found in the selected TextGrid! Please check the name.
		endif
	numberOfIntervals_'tier' = Get number of intervals... tier_'tier'
	int_'tier' = 1
	end_'tier' = start_time
endfor

# Initialize some variables
tier = tier_1
start = start_time
preceding_start = start_time - 1
preceding_end = start_time - 1
pause = 0
current_speaker = 0
start_0 = start_time
end_0 = start_time
overlapped = 0
overlapped_by = 0
line = 0
line$ = ""

# As long as new transcribed intervals are found, loop through the parallel tiers in the TextGrid:
repeat
	diff = total_duration - start
	next_speaker = 0

	# Find out which speaker starts the next utterance:
	for speaker to numberOfSpeakers
		label$ = ""
		int_'speaker' = Get interval at time... tier_'speaker' start
		start_'speaker' = Get starting point... tier_'speaker' int_'speaker'
		end_'speaker' = Get end point... tier_'speaker' int_'speaker'
		if line = 0
			label$ = Get label of interval... tier_'speaker' int_'speaker'		
		endif
		while label$ = "" and int_'speaker' < numberOfIntervals_'speaker'
			int_'speaker' = int_'speaker' + 1
			label$ = Get label of interval... tier_'speaker' int_'speaker'
			start_'speaker' = Get starting point... tier_'speaker' int_'speaker'
			end_'speaker' = Get end point... tier_'speaker' int_'speaker'
		endwhile
		# If this speaker begins an utterance earlier or at the same time than the 
		# previously checked speakers, make this speaker's utterance the next line to export:
		if label$ <> "" and (start_'speaker' - start) <= diff
			next_speaker = speaker
			diff = start_'speaker' - start
		endif
	endfor
		
	if next_speaker > 0
		
		# Check whether a change of speaker has occurred:
		if current_speaker <> next_speaker
			switch = 1
			preceding_speaker = current_speaker
			current_speaker = next_speaker
		else
			switch = 0
		endif
		start = start_'current_speaker'
		current_end = end_'current_speaker'
	
		# Get the name of the new speaker, if a turn switch occurred:	
		if switch = 1
			speaker$ = tier_name_'current_speaker'$
			speaker$ = speaker$ + ":"
		else
			speaker$ = ""
		endif
		
		# Get the utterance text:
		label$ = Get label of interval... tier_'current_speaker' int_'current_speaker'
	
		# If the current utterance is completely overlapped by a preceding speaker, keep this information:
		if preceding_end > current_end and preceding_start < start
			overlapped = 1
			overlapped_by = preceding_speaker
		else
			overlapped = 0
			overlapped_by = 0
		endif
	
		# If an utterance is completely overlapped by another, mark it in square brackets:
		if overlapped = 1 and include_start_times_for_overlaps = 0
			label$ = "['label$']"
		# Calculate the duration of a pause during which nobody speaks:
		elsif overlapped = 0 and preceding_end < start and insert_pause_durations = 1 and line > 0
			pause = start - preceding_end
			pause$ = "				('pause:2' s)" + newline$
			fileappend "'filepath$'" 'pause$'
		# The starting point of a following overlap is marked like a pause but as a negative number,
		# indicating the starting point of overlap relative to the end of the preceding utterance.
		# If an utterance overlaps with several previous utterances either partly or fully,
		# the overlap time is calculated from the overlapped utterance that started first.
		elsif preceding_end > start and include_start_times_for_overlaps = 1 and line > 0
			pause = start - preceding_end
			pause$ = "				('pause:2' s)" + newline$
			fileappend "'filepath$'" 'pause$'
			if overlapped = 1
				label$ = "['label$']"
			endif
		endif
		
		# Write the utterance line to the text file and increase counter:
		if insert_start_times = 1
			line$ = "['start:2' s]	"
		endif
		line$ = line$ + "'speaker$'	'label$'"
		#printline 'line$'
		line$ = line$ + newline$
		fileappend "'filepath$'" 'line$'
		line = line + 1
	
	endif

	# Change the start and end time of the preceding utterance only if there was no complete overlap:
	if overlapped = 0
		preceding_start = start
		preceding_end = current_end
	endif

	# Calculate and display progress in percent of total duration:
	percentage = start / total_duration * 100
	echo 'percentage:0' %

	# In case you want the script to stop after adding a specific number of lines,
	# uncomment the next three lines and edit the number as required:
	#if line = 30
	#	exit Only the first 'line' lines were inserted in the text file.
	#endif

	line$ = ""
	start = start + 0.00001

until next_speaker = 0

Genericize
echo 'line' lines of conversation were written in 'filepath$'.


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

endproc

