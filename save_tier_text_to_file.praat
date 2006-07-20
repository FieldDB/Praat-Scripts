form Write tier text to text file
comment Which tier do you want to write out?
integer Tier 1
comment Where do you want to save the file?
sentence Folder /home/lennes/read_text/
comment Criterion to be fulfilled:
sentence Criterion_text ok
integer In_tier 3
endform

filename$ = selected$ ("TextGrid", 1)
folder$ = "'folder$'" + "'filename$'" + ".txt"

numberOfIntervals = Get number of intervals... tier

for interval from 1 to numberOfIntervals

line$ = ""

line$ = Get label of interval... tier interval

call FulfilsCriterion tier interval in_tier 'criterion_text$'

if line$ <> "" and left$ (line$, 1) <> "." and line$ <> "xxx" and fulfils = 1
# add this to the end of the previous line to exclude .-beginning labels:
# and left$ (line$, 1) <> "."

	line$ = "'line$'" + "'newline$'"
		fileappend "'folder$'" 'line$'

endif

line$ = ""

endfor

#------------------------

procedure FulfilsCriterion sel_tier sel_interval crittier crittext$

in_interval = 0

if crittier <> 0

	tempstart1 = Get starting point... sel_tier sel_interval
	tempend1 = Get end point... sel_tier sel_interval
	midtime1 = (tempstart1 + tempend1) / 2

	tempcriterion = Get interval at time... crittier midtime1
	tempstart2 = Get starting point... crittier tempcriterion
	tempend2 = Get end point... crittier tempcriterion

	temp_label2$ = Get label of interval... crittier tempcriterion

	# if criterion text is empty, any interval label other than "" will be accepted
	if crittext$ = "" and temp_label2$ <> ""
		crittext$ = temp_label2$
	endif

	if tempstart2 <= tempstart1 and tempend2 >= tempend1
		in_interval = tempcriterion
	endif

	if temp_label2$ = crittext$ and tempstart2 <= tempstart1 and tempend2 >= tempend1
		fulfils = 1
	else
		fulfils = 0
	endif

else 

	fulfils = 1

endif

endproc
