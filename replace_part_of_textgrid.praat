# This script will replace part of a TextGrid object with segments and labels in 
# another, shorter TextGrid.
# Two TextGrids have to be selected in the Object list. 
# The longer of these two TextGrids will be taken as the "mother" TextGrid.
# If the two TextGrids are of equal duration, the first one in the object list
# will be considered as the "mother".
# The user is prompted to select the starting time point or a segment
# in the mothe TextGrid.
# Segments and labels from the time of the cursor or the beginning of segment
# will be replaced by the small grid.
# A new TextGrid will be created that contains the result.
#
# This script is distributed under the GNU General Public License.
# Copyright 11.7.2002 Mietta Lennes
#

form Replace TextGrid by another
	choice Replace 1
	button all tiers that have the same number
	button all tiers that have the same name
	button only one tier
	integer in_tier_number 1
	comment You will be prompted for the starting time of the part to be replaced...
endform

grid1$ = selected$ ("TextGrid", 1)
grid2$ = selected$ ("TextGrid", 2)

# Decide which of the two Grids will be replaced with which:
select TextGrid 'grid1$'
dur1 = Get duration
select TextGrid 'grid2$'
dur2 = Get duration

if dur1 > dur2
	biggrid$ = grid1$
	smallgrid$ = grid2$
	select = 1
elsif dur2 > dur1
	biggrid$ = grid2$
	smallgrid$ = grid1$
	select = 1
else
	biggrid$ = grid1$
	smallgrid$ = grid2$
	select = 0
endif

select TextGrid 'biggrid$'
Edit
editor TextGrid 'biggrid$'

pause Please select the interval from the start of which the TextGrid 'biggrid$' should be replaced, and press Continue when ready!

start = Get starting point of interval
endeditor

select TextGrid 'smallgrid$'
smallNumberOfTiers = Get number of tiers
smallstart = Get starting time
smallduration = Get duration

select TextGrid 'biggrid$'
bigNumberOfTiers = Get number of tiers
bigstart = Get starting time
bigduration = Get duration

if bigstart <> 0 or smallstart <> 0
	exit Both TextGrids must start from time 0. Cannot replace! Please make sure the time scale is okay and try again...
endif

# Make an empty copy of the big TextGrid, with just the correct tiers:
n$ = ""
for n from 1 to bigNumberOfTiers
	select TextGrid 'biggrid$'
	tiername$ = Get tier name... n
	n$ = n$ + "'tiername$' "
endfor
n$ = left$ (n$, (length (n$) - 1))
Create TextGrid... 0 bigduration 'n$'
Rename... 'biggrid$'_replaced

if replace = 1
	# all tiers with the same number should be replaced...
	if smallNumberOfTiers > bigNumberOfTiers
		newtier = 0
		moretiers = smallNumberOfTiers - bigNumberOfTiers
		printline 'moretiers' more tiers are needed
		# new tiers will be added to the grid with corresponding names
		for i to moretiers
			newtier = bigNumberOfTiers + i
			select TextGrid 'smallgrid$'
			newlabel$ = Get tier name... newtier
			select TextGrid 'biggrid$'_replaced
			Insert interval tier... newtier 'newlabel$'
			select TextGrid 'biggrid$'
			Insert interval tier... newtier 'newlabel$'
		endfor
	endif
	for y to smallNumberOfTiers
		call ReplaceTier y y	
	endfor
	if moretiers > 0
		for n to moretiers
			select TextGrid 'biggrid$'
			bigNumberOfTiers = Get number of tiers
			Remove tier... bigNumberOfTiers
		endfor
	endif
	if bigNumberOfTiers > smallNumberOfTiers
		beg = smallNumberOfTiers + 1
		select TextGrid 'biggrid$'_replaced
		for t from beg to bigNumberOfTiers
			newNumberOfTiers = Get number of tiers
			Remove tier... newNumberOfTiers			
		endfor
		for t from beg to bigNumberOfTiers
			call CopyIntervalTier 'biggrid$' t 'biggrid$'_replaced
		endfor
	endif
elsif replace = 2
	# all tiers with the same name should be replaced...
	for i to bigNumberOfTiers
		replaced = 0
		select TextGrid 'biggrid$'
		bigtiername$ = Get tier name... i
		for p to smallNumberOfTiers
			select TextGrid 'smallgrid$'
			smalltiername$ = Get tier name... p
			if bigtiername$ = smalltiername$
				call ReplaceTier p i
				replaced = 1
			endif
		endfor
		if replaced = 0
			call CopyIntervalTier 'biggrid$' i 'biggrid$'_replaced
		endif
	endfor
	if bigNumberOfTiers < smallNumberOfTiers
		select TextGrid 'biggrid$'_replaced
		newNumberOfTiers = Get number of tiers
		for p to smallNumberOfTiers
			exists = 0
			select TextGrid 'smallgrid$'
			smalltiername$ = Get tier name... p
			for i to newNumberOfTiers
				select TextGrid 'biggrid$'_replaced
				bigtiername$ = Get tier name... p
				if bigtiername$ = smalltiername$
					exists = 1
				endif
			endfor
			if exists = 0
				call ReplaceTier p i
			endif
		endfor		
	endif
else
	# only tier 'in_tier_number' should be replaced...
	if smallNumberOfTiers = 1
		call ReplaceTier in_tier_number 1
		if bigNumberOfTiers > 1
			for t from 2 to bigNumberOfTiers
				call CopyIntervalTier 'biggrid$' t 'biggrid$'_replaced
			endfor
		endif
	elsif smallNumberOfTiers >= in_tier_number
		if bigNumberOfTiers < in_tier_number
			exit There are only 'bigNumberOfTiers' in the TextGrid 'biggrid$'. Tier 'in_tier_number' in TextGrid 'biggrid$' was not replaced! Exit...
		endif
		if in_tier_number > 1
			stop = in_tier_number - 1
			for t to stop
				call CopyIntervalTier 'biggrid$' t 'biggrid$'_replaced
			endfor
		endif
		call ReplaceTier in_tier_number in_tier_number
		beg = in_tier_number + 1
		for t from beg to bigNumberOfTiers
			call CopyIntervalTier 'biggrid$' t 'biggrid$'_replaced
		endfor
	else
		exit There are only 'smallNumberOfTiers' in the TextGrid 'smallgrid$'. Tier 'in_tier_number' in TextGrid 'biggrid$' was not replaced! Exit...
	endif
endif

echo Finished!

if replace = 1
	printline All tiers from 1 to smallNumberOfTiers in 'biggrid$' were replaced by tiers in 'smallgrid$',
elsif replace = 2
	printline All tiers that had the same name in 'biggrid$' as in 'smallgrid$' were replaced by the tiers in 'smallgrid$',

else
	printline starting from time 'start:3' s, ending at time 'replace_end:3' s.
endif

printline
printline The original TextGrids were not modified.
printline The result is the new TextGrid 'biggrid$'_replaced.


#--------

procedure ReplaceTier replaceThisTier withThisTier
	# Check if the first interval has an identical label:
	select TextGrid 'biggrid$'
	duration = Get duration
	numberOfIntervals2 = Get number of intervals... replaceThisTier
	int2 = Get interval at time... replaceThisTier start
	start2 = Get starting point... replaceThisTier int2
	end2 = Get end point... replaceThisTier int2
	for interval from 1 to int2
		select TextGrid 'biggrid$'
		if interval = 1
			label2$ = Get label of interval... replaceThisTier 1
			select TextGrid 'biggrid$'_replaced
			Set interval text... replaceThisTier 1 'label2$'
		elsif interval < int2
			boundary = Get starting point... replaceThisTier interval
			label2$ = Get label of interval... replaceThisTier interval
			select TextGrid 'biggrid$'_replaced
			Insert boundary... replaceThisTier boundary
			Set interval text... replaceThisTier interval 'label2$'
		else
			select TextGrid 'biggrid$'_replaced
			Insert boundary... replaceThisTier start2
		endif
	endfor
	select TextGrid 'biggrid$'
	int2 = Get interval at time... replaceThisTier start
	start2 = Get starting point... replaceThisTier int2
	end2 = Get end point... replaceThisTier int2
	label2$ = Get label of interval... replaceThisTier int2
	select TextGrid 'biggrid$'_replaced
	Insert boundary... replaceThisTier end2
	newNumberOfIntervals = Get number of intervals... replaceThisTier
	newint = Get interval at time... replaceThisTier start
	select TextGrid 'smallgrid$'
	numberOfIntervals1 = Get number of intervals... withThisTier
	int1 = 1
	start1 = 0
	end1 = Get end point... withThisTier int1
	label1$ = Get label of interval... withThisTier int1
	select TextGrid 'biggrid$'_replaced
	if start2 < start
		if label1$ <> label2$ or (label1$ <> "" and label2$ <> "")
			Insert boundary... replaceThisTier start
			int2 = int2 + 1
		endif
	endif
	# go through the small grid and replace part of tier by it:
	for int1 from 1 to numberOfIntervals1
		select TextGrid 'smallgrid$'
		label1$ = Get label of interval... withThisTier int1
		end1 = Get end point... withThisTier int1
		if int1 > 1
			start1 = Get starting point... withThisTier int1
			boundary = start + start1
			select TextGrid 'biggrid$'_replaced
			Insert boundary... replaceThisTier boundary
			int2 = int2 + 1
		endif
		select TextGrid 'biggrid$'_replaced
		Set interval text... replaceThisTier int2 'label1$'
		replace_end = start + end1
		if replace_end >= duration
			int1 = numberOfIntervals1
		endif
	endfor
	newNumberOfIntervals = Get number of intervals... replaceThisTier
	label1$ = Get label of interval... replaceThisTier newNumberOfIntervals
	# copy the rest of the tier from the old big grid:
	select TextGrid 'biggrid$'
	int2 = Get interval at time... replaceThisTier replace_end
	start2 = Get starting point... replaceThisTier int2
	end2 = Get end point... replaceThisTier int2
	label2$ = Get label of interval... replaceThisTier int2
	if label1$ <> label2$ or (label1$ <> "" and label2$ <> "")
		select TextGrid 'biggrid$'_replaced
		Insert boundary... replaceThisTier replace_end
		newNumberOfIntervals = Get number of intervals... replaceThisTier
		Set interval text... replaceThisTier newNumberOfIntervals 'label2$'
	endif
	while end2 < duration or int2 < numberOfIntervals2
		int2 = int2 + 1
		select TextGrid 'biggrid$'
		start2 = Get starting point... replaceThisTier int2
		end2 = Get end point... replaceThisTier int2
		label2$ = Get label of interval... replaceThisTier int2
		select TextGrid 'biggrid$'_replaced
		Insert boundary... replaceThisTier start2
		newNumberOfIntervals = newNumberOfIntervals + 1
		Set interval text... replaceThisTier newNumberOfIntervals 'label2$'
	endwhile
	
endproc


# ------

procedure CopyIntervalTier gridname1$ tier1 gridname2$

select TextGrid 'gridname1$'
tiername$ = Get tier name... tier1
Extract tier... tier1
Rename... 'tiername$'

select TextGrid 'gridname2$'
plus IntervalTier 'tiername$'
Append
Rename... temp

select TextGrid 'gridname2$'
plus IntervalTier 'tiername$'
Remove

select TextGrid temp
Rename... 'gridname2$'

endproc
