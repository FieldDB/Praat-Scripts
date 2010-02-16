# This script will save the label information from a user-specified interval tier 
# of a selected TextGrid object to a  text file.
# The lines in the text file will have the format:
# starting point of seg1 - space - segment label - line break.
# The segments will be ordered according to time points.
# 
# This script is distributed under the GNU General Public License.
# Copyright 17.3.2002 Mietta Lennes

form Make text file from an IntervalTier in the selected TextGrid object
	comment Which tier do you want to convert to text?
	integer Tier 1
	comment Where do you want to save the text file?
	text path ../../ICSLP/lauseet2/uusi/C0.phn
endform

overwrite = 0

numberOfIntervals = Get number of intervals... tier

for interval from 1 to numberOfIntervals
	start = Get starting point... tier interval
	label$ = Get label of interval... tier interval
	if fileReadable (path$) and overwrite = 0 and interval = 1
		pause There already is a text file 'path$'. Do you want to continue and overwrite it?
		overwrite = 1
		filedelete 'path$'
	endif
	textline$ = "'start' 'label$''newline$'"
	fileappend 'path$' 'textline$'
endfor

echo Created a text file 'path$' for the segments and labels in tier 'tier'.
