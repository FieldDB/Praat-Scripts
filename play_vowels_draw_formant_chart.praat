# Draw formant chart from selected segments according to a TextGrid object
#
# This script is distributed under the GNU General Public License.
# Copyright Mietta Lennes 8.3.2002

form Draw a vowel chart from the centre points of selected segments in a Sound object
integer Tier 1
sentence Segment_label a
comment You can also give a small "safety margin" around each vowel segment for formant calculation.
positive Margin 0.05
endform

gridname$ = selected$ ("TextGrid", 1)
soundname$ = selected$ ("Sound", 1)

Create Sound... silence 0 0.5 22050 0

Viewport... 0 6 6.5 9
Font size... 18
Line width... 1

Viewport... 0 6 0 6
Axes... 100 900 600 2900

Text top... yes Formant chart of ''segment_label$'' segments
Text bottom... yes F_1 (Hz)
Text left... yes F_2 (Hz)
Font size... 14
Marks bottom every... 1 100 yes yes yes
Marks left every... 1 500 yes yes yes
endif

Plain line
#---------

select TextGrid 'gridname$'
numberOfIntervals = Get number of intervals... tier
start = Get starting time
end = Get finishing time

token = 0

for interval to numberOfIntervals

echo Analyzing segment number 'interval' / 'numberOfIntervals' 

select TextGrid 'gridname$'
label$ = Get label of interval... tier interval

if label$ = segment_label$

	token = token + 1

	select TextGrid 'gridname$'
	segStart = Get starting point... tier interval
	segEnd = Get end point... tier interval

	# Create a window for analyses
	if (segStart - margin) > start
		winStart = segStart - margin
	else
		winStart = start
	endif	
		
	if (segEnd + margin) < end
		winEnd = segEnd + margin
	else
		winEnd = end
	endif	
		
	vowDur = segEnd - segStart
	
	select Sound 'soundname$'
	Extract part... winStart winEnd Rectangular 1 yes
	Rename... window
			
	# measure F1 and F2
	select Sound window
	To Formant (burg)... 0.01 5 5500 0.025 50
	Rename... formants
	Track... 3 550 1650 2750 3850 4950 1 1 1
	measurepoint = (segStart + segEnd) / 2
	vowF1 = Get value at time... 1 measurepoint Hertz Linear
	vowF2 = Get value at time... 2 measurepoint Hertz Linear
	Viewport... 0 6 0 6
	Draw circle... vowF1 vowF2 27
	# play the sound and the environment a couple of times...
		select Sound 'soundname$'
		Extract part... segStart segEnd Rectangular 1 yes
		Rename... seg_window
		Play
		select Sound silence
		Play
		if winStart - 0.2 < start
			bigstart = start
		else
			bigstart = winStart - 0.2
		endif
		if winStart + 0.2 > end
			bigend = end
		else
			bigend = winEnd + 0.2
		endif
		select Sound 'soundname$'
		Extract part... bigstart bigend Rectangular 1 yes
		Rename... big_window
		Play
		Remove
		select Sound silence
		Play
		select Sound seg_window
		Play
		select Sound silence
		Play
		select Sound seg_window
		Play
	Remove
	# finished playing
	pause Do you want to see and hear the next segment 'segment_label$'?
	select Sound window
	Remove
	select Formant formants
	Remove
	select Formant formants
	Remove
	
endif

endfor

printline The (F1,F2) formant points of 'token' vowel tokens were plotted on the chart. 
printline Finished drawing!

