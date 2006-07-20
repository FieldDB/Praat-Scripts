# This script saves a picture of the selected portion in the TextGrid editor
# as a labeling example. The picture will include waveform, spectrogram,
# intensity, and pitch curves plus one TextGrid tier.
#
# You can also save the selected portion of a LongSound file to a separate
# Sound file (WAV), and the corresponding part of the TextGrid file to an
# independent TextGrid file. The TextGrid will be "genericized" before saving.
#
# You have to open the script from within a TextGrid editor window. You can also 
# add a new menu command for this script, e.g., in the File menu of the TextGrid editor.
#
# EPS picture file is created by Praat.
# Smaller PS and PDF files will only be created in Unix-based systems 
# that include the tools convert and ps2pdf!!!
# 
# This script is distributed under the GNU General Public License.
# Copyright 23.3.2004 Mietta Lennes
#

form Where do you want to save the example picture?
sentence Filename Phone_
integer Tier_number 1
positive Picture_width 7
comment Save TextGrid file to:
text griddir /home/lennes/annotation_guide/annotation_examples/
comment Save sound file to:
text sounddir /home/lennes/annotation_guide/annotation_examples/
comment Directory for pictures:
text picdir /home/lennes/annotation_guide/
optionmenu Plot_intensity_or_pitch 1
option intensity
option pitch
option none
optionmenu Sound_object_type 1
option Sound
option LongSound
boolean Garnish 1
endform

soundpath$ = sounddir$ + filename$ + ".wav"
gridpath$ = griddir$ + filename$ + ".TextGrid"
epspath$ = picdir$ + "epsfigs/" + filename$ + ".eps"
pspath$ = picdir$ + "psfigs/"+ filename$ + ".ps"
pdfpath$ = picdir$ + "figs/"+ filename$ + ".pdf"
jpgpath$ = picdir$ + "jpgfigs/"+ filename$ + ".jpg"

filedelete 'soundpath$'
filedelete 'gridpath$'

pitchmin = 70
pitchmax = 500
intmin = 10
intmax = 90
spectrogrammax = 5500

start = Get begin of selection
end = Get end of selection
exampledur = Get selection length

endeditor

gridname$ = selected$ ("TextGrid", 1)
soundname$ = selected$ ("'sound_object_type$'", 1)

select TextGrid 'gridname$'
duration = Get duration

start2 = start - 0.03
end2 = end + 0.03
if start2 < 0
   start2 = 0
endif
if end2 > duration
   end2 = duration
endif

# Extract the selected tier, region and calculate spectrogram:
Extract tier... 'tier_number'
Rename... 'gridname$'
Into TextGrid
Rename... 'gridname$'
select IntervalTier 'gridname$'
Remove
select TextGrid 'gridname$'
Extract part... start2 end2 yes
Genericize
Rename... 'filename$'
select 'sound_object_type$' 'soundname$'

if sound_object_type$ = "LongSound"
	Extract part... start2 end2 yes
else
	Extract part... start2 end2 Rectangular 1.0 yes
endif

Rename... 'filename$'
To Spectrogram... 0.005 spectrogrammax 0.002 20 Gaussian
select Sound 'filename$'
if plot_intensity_or_pitch = 1
	To Intensity... pitchmin 0
elsif plot_intensity_or_pitch = 2
	To Pitch... 0 pitchmin pitchmax
endif

select TextGrid 'filename$'
plus Sound 'filename$'

# Draw box:
Erase all
Times
Black
Font size... 20
Viewport... 0 picture_width 0 5.5
Draw inner box

select Spectrogram 'filename$'
Viewport... 0 picture_width 1 4.7
Paint... start end 0 spectrogrammax 100 yes 50 6 0 no
Draw inner box
if garnish = 1
	One mark left... spectrogrammax no yes no 'spectrogrammax' Hz
	One mark left... 0 no yes no 0 Hz
	Text left... no Spektrogrammi
endif

if plot_intensity_or_pitch = 1
	select Intensity 'filename$'
	Blue
	Draw... start end intmin intmax no
	if garnish = 1
		One mark right... intmin no yes no 'intmin' dB
		One mark right... intmax no yes no 'intmax' dB
		Text right... no Intensiteetti
	endif
	Black
elsif plot_intensity_or_pitch = 2
	select Pitch 'filename$'
	Blue
	Draw... start end pitchmin pitchmax no
	if garnish = 1
		One mark right... pitchmax no yes no 'pitchmax' Hz
		One mark right... pitchmin no yes no 'pitchmin' Hz
		Text right... no Perustaajuus
	endif
	Black
endif

Viewport... 0 picture_width 0 5.5
select TextGrid 'filename$'
Draw... start end yes no no

Viewport... 0 picture_width 0 2.5
select Sound 'filename$'
min = Get minimum... start end None
max = Get maximum... start end None
if max > abs(min)
	min = -max
else
	max = -min
endif
min = min - 0.01
max = max + 0.01
Draw... start end min max no

exampledur = exampledur * 1000
Text top... no - 'exampledur:0' ms -

Viewport... 0 picture_width 0 5
Write to EPS file... 'epspath$'

# The following two commands will only work in Unix. Comment them out if using Windows or Mac!
system_nocheck convert 'epspath$' 'pspath$'
system_nocheck convert 'epspath$' 'jpgpath$'
system_nocheck ps2pdf 'pspath$' 'pdfpath$'

select TextGrid 'filename$'
if griddir$ <> ""
	Write to short text file... 'gridpath$'
endif

Remove

select Sound 'filename$'
if sounddir$ <> ""
	Write to WAV file... 'soundpath$'
endif
Remove

select Spectrogram 'filename$'
Remove
if plot_intensity_or_pitch = 1
	select Intensity 'filename$'
	Remove
elsif plot_intensity_or_pitch = 2
	select Pitch 'filename$'
	Remove
endif

select TextGrid 'gridname$'
Remove
select 'sound_object_type$' 'soundname$'
plus TextGrid 'gridname$'

editor TextGrid 'gridname$'

