# This script will draw a spectrum from a 40 ms window around the cursor in the editor window.
#
# The original version of the script can be found in the scripting tutorial of the built-in Praat manual.
# However, the original script does not work with the new Praat versions; this one does. :-)
#
# 11.3.2002 Mietta Lennes

# Make a temporary selection from the original sound:
cursor = Get cursor
start = cursor - 0.02
end = cursor + 0.02
Select... start end

# name the new Sound object according to the time point where the cursor was
milliseconds = round (cursor * 1000)
Extract windowed selection... FFT_'milliseconds'ms Kaiser2 2 no

# leave the Sound editor for a while to calculate and draw the spectrum
endeditor

# Make the Spectrum object from the new Sound
To Spectrum
Edit
editor Spectrum FFT_'milliseconds'ms
# zoom the spectrum to a comfortable frequency view...
Zoom... 0 5000
endeditor

# select and remove the temporary Sound object 
select Sound FFT_'milliseconds'ms
Remove

# return to the Sound editor window and recall the original cursor position
editor
Move cursor to... cursor
