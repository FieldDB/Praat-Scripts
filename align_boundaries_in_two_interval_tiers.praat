# This script aligns boundaries in two tiers when they are 
# sufficiently close to each other.
#
# A TextGrid object must be selected in the Object list.
#
# This script is distributed under the GNU General Public License.
# Copyright 15.9.2005 Mietta Lennes

form Align boundaries in two interval tiers
	comment Give the name of the first interval tier:
	sentence Tier_1 syllable
	comment Give the name of the second interval tier:
	sentence Tier_2_(fixed) word
	comment Give the maximum difference between two boundaries to be aligned:
	real maximum_difference_(seconds) 0.003
	boolean Use_criterion_tier_below 1
	sentence Criterion_tier "Checked by Mietta"
	sentence Criterion_text 
endform

echo Aligning boundaries in tiers 'tier_1$' and 'tier_2$'...

gridname$ = selected$("TextGrid",1)
call GetTier 'tier_1$' tier1
call GetTier 'tier_2$' tier2

Edit
editor TextGrid 'gridname$'
for t from 2 to tier2
	Select next tier
endfor
endeditor


if tier1 > 0 and tier2 > 0
	if use_criterion_tier_below = 1
		call GetTier 'criterion_tier$' criterion_tier
		printline Boundaries will be automatically aligned where the label of tier 'criterion_tier' ('criterion_tier$') is "'criterion_text$'".
	endif
	
	numberOfIntervals1 = Get number of intervals... tier1
	numberOfIntervals2 = Get number of intervals... tier2

	prev_interval$ = ""

	for interval from 2 to numberOfIntervals1

		start1 = Get starting point... tier1 interval
		end1 = Get end point... tier1 interval
		interval$ = Get label of interval... tier1 interval
		previnterval = interval - 1

		if use_criterion_tier_below = 1
			call FulfilsCriterion tier1 interval criterion_tier 'criterion_text$'
		else
			fulfils = 1
		endif

		zoomstart = start1-2
		zoomend = start1+2

		interval2 = Get interval at time... tier2 start1
		start2 = Get starting point... tier2 interval2
		end2 = Get end point... tier2 interval2

		if (start2 <> start1) and (end2 <> start1)
			if abs(start2-start1) <= maximum_difference
				# The boundary should be moved to time point start2.
				editor TextGrid 'gridname$'
				Zoom... zoomstart zoomend
				Move cursor to... 'start2'
				if (fulfils = 1 or use_criterion_tier_below = 0) and start2 <> prevstart1
					printline Correcting alignment at time 'start1'...
					#pause Continue?
					endeditor
					Remove boundary at time... tier1 start1
					Set interval text... tier1 previnterval 'prev_interval$'
					Insert boundary... tier1 start2
					Set interval text... tier1 interval 'interval$'
					#pause Continue?
				elsif (fulfils = 0 and use_criterion_tier_below = 1)
					pause Possible boundary mismatch at time 'start2' - please correct this manually!
					printline Possible boundary mismatch at time 'start2' - please correct this manually! (criterion = "'temp_label2$'")
					endeditor
				else
					endeditor
				endif
			endif
			if abs(end2-start1) <= maximum_difference
				# The boundary should be moved to time point end2.
				editor TextGrid 'gridname$'
				Zoom... zoomstart zoomend
				Move cursor to... 'end2'
				if (fulfils = 1 or use_criterion_tier_below = 0) and end2 <> end1
					printline Correcting alignment at time 'start1'...
					#pause Continue?
					endeditor
					Remove boundary at time... tier1 start1
					Set interval text... tier1 previnterval 'prev_interval$'
					Insert boundary... tier1 end2
					Set interval text... tier1 interval 'interval$'
					#pause Continue?
				elsif (fulfils = 0 and use_criterion_tier_below = 1)
					pause Possible boundary mismatch at time 'end2' - please correct this manually!
					printline Possible boundary mismatch at time 'end2' - please correct this manually! (criterion = "'temp_label2$'")
					endeditor
				else
					endeditor
				endif
			endif
		endif

		prevstart1 = Get starting point... tier1 interval
		prev_interval$ = interval$

	endfor

	printline Finished alignment!

endif


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

#------------------

procedure FulfilsCriterion sel_tier sel_interval crittier crittext$

select TextGrid 'gridname$'

if crittier > 0
	tempstart1 = Get starting point... sel_tier sel_interval

	tempcriterion = Get interval at time... crittier tempstart1
	tempstart2 = Get starting point... crittier tempcriterion
	tempend2 = Get end point... crittier tempcriterion

	temp_label2$ = Get label of interval... crittier tempcriterion

	if temp_label2$ = crittext$ and tempstart2 < tempstart1
		fulfils = 1
	else
		fulfils = 0
	endif
else 
	fulfils = 0
endif

endproc
