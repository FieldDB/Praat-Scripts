# This script will take data from a simple text file, convert them into
# a Praat TextGrid object, and draw a horizontal bar in the Picture window 
# with divisions correponding to the values of the data file.
#
# This script is distributed under the GNU General Public License.
# Copyright 24.4.2002 Mietta Lennes
#

form Draw distribution bar from data file
comment Full path of the data:
text path /home/lennes/tmp/phoneme_frequencies2.txt
boolean The_text_file_contains_a_title_row 0
positive Group_together_if_smaller_than_(%) 3
positive Picture_width_(inches) 12
positive Picture_height_(inches) 4
integer Font_size 24
text title Distribution of categories
endform

if fileReadable (path$) = 0
	exit The file 'path$' does not exist! Give the correct path to the file and try again.
endif

Read Strings from raw text file... 'path$'
Rename... temp

numberOfStrings = Get number of strings
end = 0
sum = 0
long = 0

Line width... 3

# first, check the strings, calculate total sum, etc.
for string from 1 to numberOfStrings
	string$ = Get string... string
	if index (string$, "	") > 0
		number$ = left$ (string$, (index (string$, "	") - 1))
		if length (right$ (string$, (length (string$) - (index (string$, "	"))))) > 2
			long = 1
		endif
	elsif index (string$, " ") > 0
		number$ = left$ (string$, (index (string$, " ") - 1))
		if length (right$ (string$, (length (string$) - (index (string$, " "))))) > 2
			long = 1
		endif
	elsif string$ <> ""
		number$ = string$
	endif
	if number$ <> ""
		number = 'number$'
		sum = sum + number
	elsif end = 0
		printline Data ended in line 'string'.
		end = 'string'
	endif
endfor

if end > 0
	numberOfStrings = end
endif

# now, create the TextGrid:
Create TextGrid... 0 sum textline
Rename... temp
boundary = 0
interval = 0
minor = 0
minorpoint = sum
minor$ = ""
count = 0

for i from 1 to numberOfStrings
	select Strings temp
	string$ = Get string... i
	if index (string$, "	") > 0
		number$ = left$ (string$, (index (string$, "	") - 1))
		label$ = right$ (string$, (length (string$) - index (string$, "	")))
	elsif index (string$, " ") > 0
		number$ = left$ (string$, (index (string$, " ") - 1))
		label$ = right$ (string$, (length (string$) - index (string$, " ")))
	elsif string$ <> ""
		number$ = string$
		label$ = ""
	endif
	number = 'number$'
	percent = (number / sum) * 100
	if percent > group_together_if_smaller_than
		boundary = boundary + number
	else
		if minor$ = ""
			minor$ = minor$ + "'label$'"
		else
			minor$ = minor$ + ", 'label$'"
		endif
		minorpoint = minorpoint - (number / 2)
	endif
	select TextGrid temp	
	if number > 0 and boundary < sum and percent > group_together_if_smaller_than
		interval = interval + 1
		Insert boundary... 1 boundary
		call CheckLabel
		if long = 0
			Set interval text... 1 interval 'label$'
		else
			text'interval'$ = label$
			point'interval' = boundary - (number / 2)
			count = count + 1
		endif
	elsif number > 0 and boundary = sum
		interval = interval + 1
		if percent > group_together_if_smaller_than
			call CheckLabel
			if long = 0
				Set interval text... 1 interval 'label$'
			else
				text'interval'$ = label$
				point'interval' = boundary - (number / 2)
				count = count + 1
			endif
		endif
	endif
endfor

if minor$ <> ""
	interval = interval + 1
	if length (minor$) > 14
		label$ = "Others"
	else
		label$ = minor$
	endif
	call CheckLabel
	if long = 0
		Set interval text... 1 interval 'label$'
	endif
endif

# and finally, draw the grid to the Picture window:

select TextGrid temp
Erase all
Viewport... 0 picture_width 0 picture_height
Draw... 0.0 0.0 no no no

Line width... 2
Marks bottom... 11 no yes no
tenpercent = sum / 20
One mark bottom... tenpercent no no no 10 \% 
Times
Font size... font_size
Text... sum Centre -2.3 Bottom Total: 'sum'

if long = 1
	for label from 1 to count
		text$ = text'label'$
		Text special... point'label' Left -0.9 Half Times font_size 45 'text$'
	endfor
endif

if title$ <> ""
	middle = sum / 2
	if long = 0
		Text... middle Centre 0 Top 'title$'
	else
		Text special... middle Centre 0.3 Half Helvetica 22 0 'title$'
		Text special... minorpoint Left -0.9 Half Times font_size 45 'label$'	
	endif
endif

select Strings temp
plus TextGrid temp
Remove


procedure CheckLabel

while index (label$, "ä") > 0
	label$ = left$ (label$, (index (label$, "ä") - 1)) + "\a""" + right$ (label$, (length (label$) -  index (label$, "ä")))
endwhile

while index (label$, "ö") > 0
	label$ = left$ (label$, (index (label$, "ö") - 1)) + "\o""" + right$ (label$, (length (label$) -  index (label$, "ö")))
endwhile

endproc
