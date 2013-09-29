# This script will draw an LPC spectrum from a given window around the cursor in the editor window.
#
# 11.3.2002 Mietta Lennes

# Ask the user for some necessary information:
form Draw an LPC spectrum from a small window around the cursor
comment LPC options:
integer Prediction_order 20
positive Analysis_width_(seconds) 0.025
positive Time_step_(seconds) 0.005
positive Preemphasis_from_(Hz) 50.0
comment Options for drawing the spectrum from LPC:
integer Minimum_frequency_resolution_(Hz) 20
positive Bandwidth_reduction_(Hz) 0.1
positive Deemphasis_frequency_(Hz) 50.0
endform

# Make a temporary selection from the original sound:
cursor = Get cursor
start = cursor - analysis_width
end = cursor + analysis_width
Select... start end

# name the new Sound object according to the time point where the cursor was
milliseconds = round (cursor * 1000)
Extract windowed selection... LPC_'milliseconds'ms Kaiser2 2 no

# leave the Sound editor for a while to calculate and draw the spectrum
endeditor

# Make an LPC object from the new Sound
To LPC (burg)... prediction_order analysis_width time_step preemphasis_from
To Spectrum (slice)... analysis_width minimum_frequency_resolution bandwidth_reduction deemphasis_frequency
Edit
editor Spectrum LPC_'milliseconds'ms
# zoom the spectrum to a comfortable frequency view...
Zoom... 0 5000
endeditor

# select and remove the temporary Sound and LPC objects 
select Sound LPC_'milliseconds'ms
Remove
select LPC LPC_'milliseconds'ms
Remove

# return to the Sound editor window and recall the original cursor position
editor
Move cursor to... cursor
