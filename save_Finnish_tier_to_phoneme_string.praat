# This script will convert the text in an orthographically labeled tier into Finnish
# phonemes and save the phonemes to a text file, one phoneme per line.
# Word boundaries will be marked as _ and utterance boundaries as __.
# Phoneme set is ABDEFGHIJKLMNOPRSTUVÄÖ or any of these doubled;
# NG is &
# (the above system correspond to the automatic segmentation tool in Helsinki University of Technology)
#
# Copyright 17.4.2002 Mietta Lennes


form Convert Finnish tier text to phonemes and save to text file
	comment Which tier do you want to convert?
	integer Tier 4
	comment Where do you want to save the file?
	sentence Folder ../../tmp/
endform

filename$ = selected$ ("TextGrid", 1)
folder$ = "'folder$'" + "'filename$'" + ".txt"

if fileReadable (folder$)
	pause Overwrite old file 'folder$'?
endif

filedelete 'folder$'

numberOfIntervals = Get number of intervals... tier

for interval from 1 to numberOfIntervals

	label$ = Get label of interval... tier interval

	if label$ <> "" and label$ <> "xxx" and left$ (label$, 1) <> "."

		for character from 1 to length (label$)

			phoneme$ = right$ (left$ (label$, character), 1)

			if character = length (label$)
				if phoneme$ <> "-"
					call ConvertToUppercase
					phoneme$ = "'phoneme$''newline$'"
					fileappend "'folder$'" 'phoneme$'
				endif
				phoneme$ = "__'newline$'"
				fileappend "'folder$'" 'phoneme$'
			elsif phoneme$ = " "
				phoneme$ = "_'newline$'"
				fileappend "'folder$'" 'phoneme$'
			else
				next = character + 1
				nextphoneme$ = right$ (left$ (label$, next), 1)
				if nextphoneme$ = " "
					next = next + 1
					if next <= length (label$)
						nextphoneme$ = right$ (left$ (label$, next), 1)
						if phoneme$ = "n"
							if nextphoneme$ = "p"
								phoneme$ = "M"
							elsif nextphoneme$ = "k" or nextphoneme$ = "g"
								phoneme$ = "&"
							else
								phoneme$ = "N"
							endif
						endif
						if phoneme$ <> "-"
							call ConvertToUppercase
							fileappend "'folder$'" 'phoneme$''newline$'
						endif
						phoneme$ = "_'newline$'"
						fileappend "'folder$'" 'phoneme$'
						character = character + 1
					else
						call ConvertToUppercase
						phoneme$ = "'phoneme$''newline$'"
						phoneme$ = "'phoneme$'__'newline$'"
						fileappend "'folder$'" 'phoneme$'
						character = length (label$)
					endif
				elsif phoneme$ = "n" 
					if nextphoneme$ = "p"
						phoneme$ = "M"
					elsif nextphoneme$ = "k"
						phoneme$ = "&"
					elsif nextphoneme$ = "g"
						phoneme$ = "&&"
						character = character + 1
					else
						phoneme$ = "N"
					endif
					phoneme$ = phoneme$ + newline$
					fileappend "'folder$'" 'phoneme$'
				elsif phoneme$ = nextphoneme$
					call ConvertToUppercase
					phoneme$ = phoneme$ + phoneme$ + newline$
					fileappend "'folder$'" 'phoneme$'
					if next = length (label$)
						phoneme$ = "__'newline$'"
						fileappend "'folder$'" 'phoneme$'
						character = length (label$)
					else
						character = character + 1
					endif
				elsif phoneme$ = " "
					phoneme$ = "_'newline$'"
					fileappend "'folder$'" 'phoneme$'
				elsif phoneme$ = "-"
				else
					call ConvertToUppercase
					phoneme$ = phoneme$ + newline$
					fileappend "'folder$'" 'phoneme$'
				endif
			endif

		endfor

	endif

endfor

procedure ConvertToUppercase

if phoneme$ = "a"
	phoneme$ = "A"
elsif phoneme$ = "b"
	phoneme$ = "B"
elsif phoneme$ = "c"
	phoneme$ = "C"
elsif phoneme$ = "d"
	phoneme$ = "D"
elsif phoneme$ = "e"
	phoneme$ = "E"
elsif phoneme$ = "f"
	phoneme$ = "F"
elsif phoneme$ = "g"
	phoneme$ = "G"
elsif phoneme$ = "h"
	phoneme$ = "H"
elsif phoneme$ = "i"
	phoneme$ = "I"
elsif phoneme$ = "j"
	phoneme$ = "J"
elsif phoneme$ = "k"
	phoneme$ = "K"
elsif phoneme$ = "l"
	phoneme$ = "L"
elsif phoneme$ = "m"
	phoneme$ = "M"
elsif phoneme$ = "n"
	phoneme$ = "N"
elsif phoneme$ = "o"
	phoneme$ = "O"
elsif phoneme$ = "p"
	phoneme$ = "P"
elsif phoneme$ = "r"
	phoneme$ = "R"
elsif phoneme$ = "s"
	phoneme$ = "S"
elsif phoneme$ = "t"
	phoneme$ = "T"
elsif phoneme$ = "u"
	phoneme$ = "U"
elsif phoneme$ = "v"
	phoneme$ = "V"
elsif phoneme$ = "y"
	phoneme$ = "Y"
elsif phoneme$ = "ä"
	phoneme$ = "Ä"
elsif phoneme$ = "ö"
	phoneme$ = "Ö"
endif

endproc
