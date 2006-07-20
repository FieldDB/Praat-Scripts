# This script adds syllable and word tier units for utterance intervals 
# in a TextGrid object.
# The script only works for the Finnish language.
# Utterance transcriptions must be quasi-orthographic.
#
# This script is distributed under the GNU General Public License.
# Copyright 31.5.2004 Mietta Lennes

form Add syllables and words
	sentence Utterance_tier_name utterance
	sentence Written_sentence_tier_name_(optional) "written sentence"
	sentence Word_tier_name word
	sentence Syllable_tier_name syllable
	sentence Phone_tier_name phone
	comment A TextGrid plus a LongSound must be selected!
endform

echo Adding syllables and words to TextGrid...

sound$ = selected$ ("LongSound", 1)
grid$ = selected$ ("TextGrid", 1)
select TextGrid 'grid$'
total_duration = Get duration
numberOfHandledUtterances = 0

# Make a temporary copy of the TextGrid for safe editing:
Copy... temp
select TextGrid temp

# If necessary, add tiers for phones, syllables, 
call GetTier 'phone_tier_name$' phone_tier
newtier = phone_tier + 1

call GetTier 'syllable_tier_name$' syllable_tier
if syllable_tier = 0
	Insert interval tier... newtier 'syllable_tier_name$'
	newtier = newtier + 1
endif
call GetTier 'word_tier_name$' word_tier
if word_tier = 0
	Insert interval tier... newtier 'word_tier_name$'
endif

# Update all tier numbers:
call GetTier 'phone_tier_name$' phone_tier
call GetTier 'syllable_tier_name$' syllable_tier
call GetTier 'word_tier_name$' word_tier
call GetTier 'utterance_tier_name$' utterance_tier

printline Written sentence tier = 'written_sentence_tier'

select LongSound 'sound$'
plus TextGrid temp
Edit
editor TextGrid temp
for seltier from 2 to utterance_tier
	Select next tier
endfor

if utterance_tier > 0
	endeditor
	select TextGrid temp
	numberOfUtterances = Get number of intervals... utterance_tier
	
	for utterance to numberOfUtterances
		select TextGrid temp
		numberOfUtterances = Get number of intervals... utterance_tier
		utterance_text$ = Get label of interval... utterance_tier utterance
		call IsLegalLabel 'utterance_text$'
		if legal = 1

			numberOfHandledUtterances = numberOfHandledUtterances + 1

			uttstart = Get starting point... utterance_tier utterance
			uttend = Get end point... utterance_tier utterance
			
			# Check if syllables or words exist for this utterance:
			endcheck = uttend - 0.01
			firstsyll = Get interval at time... syllable_tier uttstart
			lastsyll = Get interval at time... syllable_tier endcheck
			sylltext$ = Get label of interval... syllable_tier firstsyll

			if firstsyll = lastsyll and sylltext$ = ""

				# Move utterance boundaries a little to match phone boundaries:
				if phone_tier > 0
					call CheckUtteranceBoundaries utterance_tier utterance
				endif

				uttdur = uttend - uttstart
				uttchar = length (utterance_text$)
				call GetWords 'utterance_text$'
				uttnetchar = uttchar - (words - 1)
				uttunit = uttdur / uttnetchar

				# Add word and syllable boundaries and labels
				thisword = Get interval at time... word_tier uttstart
				wstart = Get starting point... word_tier thisword
				if wstart < uttstart
					Insert boundary... word_tier uttstart
				endif
				thisword = Get interval at time... word_tier uttstart
				wend = uttstart
				thissyll = Get interval at time... syllable_tier uttstart
				sstart = Get starting point... syllable_tier thissyll
				if sstart < uttstart
					Insert boundary... syllable_tier uttstart
				endif
				thissyll = Get interval at time... syllable_tier uttstart
				for w to words
					w$ = word'w'$
					wlength = length (w$)
					wstart = wend
					wend = wend + (wlength * uttunit)
					if w = words
						wend = uttend
					endif
					thisword = Get interval at time... word_tier wend
					Set interval text... word_tier thisword 'w$'
					call CheckIfBoundaryExists word_tier wend
					if boundary_exists = 0
						Insert boundary... word_tier wend
					endif
					call GetSyllables 'w$'
					send = wstart
					for s to syllables
						s$ = syllable's'$
						slength = length (s$)
						sstart = send
						send = send + (slength * uttunit)
						if s = syllables
							send = wend
							if w = words
								send = uttend
							endif
						endif
						thissyll = Get interval at time... syllable_tier send
						Set interval text... syllable_tier thissyll 's$'
						call CheckIfBoundaryExists syllable_tier send
						if boundary_exists = 0
							Insert boundary... syllable_tier send
						endif
					endfor
				endfor

				# Go to the editor window and select a region around the utterance:
				selstart = uttstart - 0.3
				if selstart < 0
					selstart = 0
				endif
				selend = uttend + 0.3
				if selend > total_duration
					selend = total_duration
				endif
				editor TextGrid temp
				Select... selstart selend
				Zoom to selection
				Select... uttstart uttend
			
				# Done. Now return to original selections.
				endeditor
				select LongSound 'sound$'
				plus TextGrid 'grid$'
				editor TextGrid temp

				# Here we copy the edited temporary TextGrid to the
				# original TextGrid.
				endeditor
				select TextGrid 'grid$'
				Remove
				select TextGrid temp
				Copy... 'grid$'
				select LongSound 'sound$'
				plus TextGrid 'grid$'

			endif
		endif
	endfor

else
	# This script cannot proceed without an utterance tier.
	exit Utterance tier "'utterance_tier_name$'" does not exist!
	Remove
	select LongSound 'sound$'
	plus TextGrid 'grid$'	
endif

printline 'numberOfHandledUtterances' non-empty utterance intervals were checked.
printline Please remember to save the TextGrid!


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

#-----------------
procedure IsLegalLabel string$
# This will exclude syllable labels starting with a dot (.), and empty labels.

if string$ <> "" and
... string$ <> "xxx" and
... left$ (string$, 1) <> "."
	legal = 1
else
	legal = 0
endif

endproc

#-----------------
procedure GetWords string$

words = 0

while index (string$, " ")
	words = words + 1
	word'words'$ = left$ (string$, (index (string$, " ") - 1))
	string$ = right$ (string$, (length (string$) - index (string$, " ")))
endwhile

words = words + 1
word'words'$ = string$

if word'words'$ = ""
	words = words - 1
endif

endproc

#-----------------
procedure GetSyllables wstring$
# The input must be a legal word string.

numberOfChars = length (wstring$)
syllables = 0

while wstring$ <> ""
	syllables = syllables + 1
	syllable'syllables'$ = ""
	vowel = 0
	char$ = left$ (wstring$, 1)
	call IsVowel 'char$'
	# onset of syllable, until we meet a vowel character:
	while vowel = 0 and wstring$ <> ""
		syllable'syllables'$ = syllable'syllables'$ + left$ (wstring$, 1)
		wstring$ = right$ (wstring$, (length (wstring$) - 1))
		if left$ (wstring$, 1) = "-"
			syllable'syllables'$ = syllable'syllables'$ + left$ (wstring$, 1)
			wstring$ = right$ (wstring$, (length (wstring$) - 1))
		endif
		char$ = left$ (wstring$, 1)
		call IsVowel 'char$'
	endwhile
	# nucleus of syllable:
	vowels = 0
	lastvowel$ = ""
	boundary = 0
	while vowel = 1 and vowels < 2 and boundary = 0 and wstring$ <> ""
		vowels = vowels + 1
		vowel$ = left$ (wstring$, 1)
		if ((lastvowel$ <> "o" or lastvowel$ <> "a") or vowel$ <> "e")
			syllable'syllables'$ = syllable'syllables'$ + left$ (wstring$, 1)
			wstring$ = right$ (wstring$, (length (wstring$) - 1))
			if left$ (wstring$, 1) = "-"
				syllable'syllables'$ = syllable'syllables'$ + left$ (wstring$, 1)
				wstring$ = right$ (wstring$, (length (wstring$) - 1))
			endif
			char$ = left$ (wstring$, 1)
			call IsVowel 'char$'
			lastvowel$ = vowel$
		else
			boundary = 1
		endif
	endwhile

	# consonants before next vowel or end of word:
	consonants = 0
	consonants$ = ""
	boundary = 0
	while vowel = 0 and wstring$ <> ""
		consonants = consonants + 1
		consonants$ = consonants$ + left$ (wstring$, 1)
		wstring$ = right$ (wstring$, (length (wstring$) - 1))
		if left$ (wstring$, 1) = "-"
			consonants$ = consonants$ + left$ (wstring$, 1)
			wstring$ = right$ (wstring$, (length (wstring$) - 1))
		endif
		char$ = left$ (wstring$, 1)
		call IsVowel 'char$'
	endwhile
	# if these are word final consonants, add all to this syllable:
	if wstring$ = ""
		syllable'syllables'$ = syllable'syllables'$ + consonants$
	# otherwise, put last consonant to next syllable:
	else
		if consonants > 1
			syllable'syllables'$ = syllable'syllables'$ + left$ (consonants$, length (consonants$) - 1)
			wstring$ = right$ (consonants$, 1) +  wstring$
		else
			wstring$ = consonants$ +  wstring$
		endif
	endif
endwhile

endproc


#-----------------
procedure IsVowel string$
# If the leftmost character of the string is a vowel symbol, returns vowel = 1.

if left$ (string$, 1) = "a" or
... left$ (string$, 1) = "A" or
... left$ (string$, 1) = "e" or
... left$ (string$, 1) = "E" or
... left$ (string$, 1) = "i" or
... left$ (string$, 1) = "I" or
... left$ (string$, 1) = "o" or
... left$ (string$, 1) = "O" or
... left$ (string$, 1) = "u" or
... left$ (string$, 1) = "U" or
... left$ (string$, 1) = "y" or
... left$ (string$, 1) = "Y" or
... left$ (string$, 1) = "ä" or
... left$ (string$, 1) = "Ä" or
... left$ (string$, 1) = "@" or
... left$ (string$, 1) = "ö" or
... left$ (string$, 1) = "Ö" or
... left$ (string$, 1) = "7" or
... left$ (string$, 1) = "&" or
... left$ (string$, 1) = ">" or
... left$ (string$, 1) = "2" or
... left$ (string$, 1) = "3" or
... left$ (string$, 1) = "4" or
... left$ (string$, 1) = "5" or
... left$ (string$, 1) = "6" or
... left$ (string$, 1) = "8"
	vowel = 1
else
	vowel = 0
endif

endproc

#----------------
procedure CheckUtteranceBoundaries utterance_tier utterance

# Given that phone_tier exists:

if phone_tier > 0

	uttlabel$ = Get label of interval... utterance_tier utterance

	uttstart = Get starting point... utterance_tier utterance
	firstphone = Get interval at time... phone_tier uttstart
	firstphonestart = Get starting point... phone_tier firstphone
	firstphoneend = Get end point... phone_tier firstphone
	startdiff = uttstart - firstphonestart
	enddiff = firstphoneend - uttstart
	prevutterance = utterance - 1
	if prevutterance >= 1
		prevuttstart = Get starting point... utterance_tier prevutterance
	else
		prevuttstart = 0
	endif
	if startdiff < 0.5 or enddiff < 0.5
		if startdiff < enddiff
			newuttstart = firstphonestart		
		else
			newuttstart = firstphoneend
		endif
		firstphone = Get interval at time... phone_tier newuttstart
		firstphonelabel$ = Get label of interval... phone_tier firstphone
		newuttstart = Get starting point... phone_tier firstphone
		if firstphonelabel$ = ""
			firstphone = Get interval at time... phone_tier newuttstart
			firstphonelabel$ = Get label of interval... phone_tier firstphone
			newuttstart = Get starting point... phone_tier firstphone
		endif
		if firstphonelabel$ <> "" and newuttstart > prevuttstart and newuttstart <> uttstart
			# Now we can change the starting point of this utterance:
			Set interval text... utterance_tier utterance 
			call CheckIfBoundaryExists utterance_tier newuttstart
			if boundary_exists = 0
				Insert boundary... utterance_tier newuttstart
			endif
			editor TextGrid temp
			Move cursor to... uttstart
			if newuttstart < uttstart
				Select previous interval
				Select next interval
			else
				Select next interval
				Select previous interval
			endif
			Remove
			Move cursor to... 0
			endeditor
			utterance = Get interval at time... utterance_tier newuttstart
			Set interval text... utterance_tier utterance 'uttlabel$'
			uttstart = newuttstart
		endif
	endif

	uttend = Get end point... utterance_tier utterance
	lastphone = Get interval at time... phone_tier uttend
	lastphonestart = Get starting point... phone_tier lastphone
	lastphoneend = Get end point... phone_tier lastphone
	startdiff = uttend - lastphonestart
	enddiff = lastphoneend - uttend
	nextutterance = utterance + 1
	if nextutterance >= numberOfUtterances
		nextuttend = total_duration
	else
		nextuttend = Get end point... utterance_tier nextutterance
	endif
	if startdiff < 0.5 or enddiff < 0.5
		if startdiff < enddiff
			newuttend = lastphonestart		
		else
			newuttend = lastphoneend
		endif
		lastphone = Get interval at time... phone_tier newuttend
		lastphonelabel$ = Get label of interval... phone_tier lastphone
		newuttend = Get end point... phone_tier lastphone
		if lastphonelabel$ = ""
			lastphone = lastphone - 1
			lastphonelabel$ = Get label of interval... phone_tier lastphone
			newuttend = Get end point... phone_tier lastphone
		endif
		if lastphonelabel$ <> "" and newuttend < nextuttend and newuttend <> uttend
			# Now we can change the starting point of this utterance:
			Insert boundary... utterance_tier newuttend
			editor TextGrid temp
			Move cursor to... uttend
			if newuttend > uttend
				Select next interval
			else
				Select previous interval
				Select next interval
			endif
			Remove
			endeditor
			uttend = newuttend
		endif
	endif

endif

endproc

#-------------
procedure CheckIfBoundaryExists temptier temptime

boundary_exists = 0
tempinterval = Get interval at time... temptier temptime
tempstart = Get starting point... temptier tempinterval
if tempstart = temptime
	boundary_exists = 1
endif

endproc
