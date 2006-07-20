# This script creates TextGrid objects for several LongSound objects and sets boundaries at pauses 
# on the basis of an intensity analysis.
# The boundaries will be set either in the centre time of a pause or at the beginning 
# and end of pauses. In the latter case you can also give a time margin that will be left 
# around the sound segments. Use a bigger margin if the pause detection 
# does not seem to work accurately. Different amounts of background noise can change the
# ideal pause detection parameters, and different speakers have different pause duration,
# so you should also try to modify the pause detection parameters to improve the accuracy.
 
# This script is distributed under the GNU General Public License.
# Copyright Mietta Lennes 25.1.2002

#******************************************************************************************************
# DEFAULT VALUES (initialization of variables)
# The name of the selected LongSound object is put to string soundname$:

#NOTE!!!!! There is still something wrong with the script... boundaries get sometimes
# very close to each other, and once in a while the script halts complaining that
# it was trying to add a boundary on a previous boundary...

form Pause analysis from LongSound(s)
   comment Give the time period you wish to include:
   real Starting_time_(seconds) 0
   real Finishing_time_(0=all) 0
   comment These criteria define a pause:
   positive Minimum_duration_(seconds) 0.6
   positive Maximum_intensity_(dB) 59
   comment Intensity analysis parameters:
	 positive Minimum_pitch_(Hz) 100
	 integer Time_step_(0=auto) 0
	 positive Window_size_(seconds) 20
	 choice Boundary_placement 2
	button One boundary at the center of each pause
	button Two boundaries with a time margin of:
	positive Margin_(seconds) 0.1
	boolean Mark_pause_intervals_with_xxx 0
	boolean Mark_utterance_intervals_with_s 1
   comment Save TextGrid file to folder:
	text folder /home/lennes/tmp/
endform


numberOfSelectedSounds = numberOfSelected ("LongSound")
warning = 1

for sound to numberOfSelectedSounds
	soundname'sound'$ = selected$ ("LongSound", sound)
endfor

for sound to numberOfSelectedSounds

	selection$ = soundname'sound'$
	select LongSound 'selection$'
	To TextGrid... utterance 
	printline Marking pauses in LongSound'selection$'...
	
	if fileReadable ("'folder$''soundname$'.TextGrid")
		pause The file 'folder$''selection$'.TextGrid already exists. Do you want to overwrite it?
	endif
	
	select TextGrid 'selection$'
		endofsound = Get finishing time
	select LongSound 'selection$'
		pausenumber = 0
		duration = 0
		count = 0
		loops = 0
		pauses_found = 0
		windowstart = 0
		windowend = 0
		frame = 0
		frames = 0
		time = 0
		intensity = 0
		pausedetected = 0
		pausestart = 0
		pauseend = 0
		pausenumber = 0
		halfpause = 0
		if finishing_time < 0
		exit Finishing time must be greater than or equal to zero! (If you give a zero, the whole LongSound will be analysed.)
		endif
		if finishing_time = 0
		finishing_time = endofsound
		endif
		#******************************************************************************************************
		# BEGIN
		#******************************************************************************************************
		# DIVIDE LONGSOUND INTO SHORTER PERIODS AND LOOP THROUGH EACH
		duration = finishing_time - starting_time
		#--------------------------------------------------------------------------------------------------
	# Default number of loops is 1
	loops = 1
	# but if the period to be analysed is longer than 60 seconds, it will be divided into 60-second
	# periods for which the analysis is made:
	if duration > window_size
	loops = ceiling ((duration/window_size))
	endif
	#--------------------------------------------------------------------------------------------------
	# START LOOPING THROUGH SHORT WINDOWS HERE
	count = 1	
	while count <= loops
		if count = 5 and warning = 1
			pause Continue?
			warning = 0
		endif
		# Create a window of the LongSound and extract it for analysis
		windowstart = starting_time + ((count - 1) * window_size)
		windowend = starting_time + (count * window_size)
		if windowend > endofsound
		windowend = endofsound
		endif
		if windowend > finishing_time
		windowend = finishing_time
		endif
		select LongSound 'selection$'
		Extract part... windowstart windowend yes
		windowname$ = "Window_" + "'count'" + "_of_" + "'loops'"
		if count < 5 and warning = 1
			echo Analysing Intensity window 'count' of 'loops' (in the first LongSound 'selection$')
			printline The script will pause after calculating 4 windows, so you can check the result...
		endif
		Rename... 'windowname$'
		#--------------------------------------------------------------------------------------------------
		# CALCULATE INTENSITY
		To Intensity... minimum_pitch time_step
		frames = Get number of frames
		#--------------------------------------------------------------------------------------------------
		# Check the pause criteria
		pauseend = 0
		frame = 1
			#--------------------------------------------------------------------------------------------------
			# Loop through all frames in the Intensity object:
			while frame <= frames
				select Intensity 'windowname$'
				intensity = Get value in frame... frame
				time = Get time from frame... frame
					if intensity > maximum_intensity
						# If the end of an earlier detected possible pause has been reached:
						if pausedetected = 1
							if frame - 1 < 1
							pauseend = windowstart
							else
							pauseend = Get time from frame... (frame - 1)
							endif
							pausedetected = 0
						endif
					    # If below intensity limit, a possible new pause is started if one hasn't been detected yet:
					    elsif pausedetected = 0
							pausestart = Get time from frame... frame
							pauseend = 0
							pausedetected = 1
							pausenumber = pausenumber + 1
					# If a detected pause just continues, do nothing special.
					endif
				#--------------------------------------------------------------------------------------------------
				# IF PAUSE CRITERIA ARE FULFILLED, ADD A BOUNDARY OR TWO TO TEXTGRID
				if pauseend > 0
					pauseduration = pauseend - pausestart
					if pauseduration >= minimum_duration
						select TextGrid 'selection$'
						halfpause = pauseduration / 2
							if boundary_placement = 1
								boundary = pausestart + halfpause
								Insert boundary... 1 boundary
							else
								boundary = 0
								if pauseduration >= (2 * margin)
									if pausestart > margin
										boundary = pausestart + margin
										Insert boundary... 1 boundary
									endif
									if mark_pause_intervals_with_xxx = 1
										pauseinterval = Get interval at time... 1 boundary
										Set interval text... 1 pauseinterval xxx
									endif
									boundary = pauseend - margin
									Insert boundary... 1 boundary
										if mark_utterance_intervals_with_s = 1
											utteranceinterval = Get interval at time... 1 boundary
											Set interval text... 1 utteranceinterval s
										endif

								else
									if pauseend < (endofsound - margin)
										boundary = pausestart + halfpause
										Insert boundary... 1 boundary
									endif
								endif
							endif
						pauseend = 0
						pauses_found = pauses_found + 1
						Write to text file... 'folder$''selection$'.TextGrid
					endif
				endif
				frame = frame + 1
				# When all frames in the intensity analysis have been looked at, end the frame loop.
			endwhile
			#--------------------------------------------------------------------------------------------------
		select Sound 'windowname$'
		Remove
		select Intensity 'windowname$'
		Remove
		# END LOOPING THROUGH WINDOWS HERE
		count = count + 1
	endwhile
	select TextGrid 'selection$'
	Write to text file... 'folder$''selection$'.TextGrid
	
	printline ...done. The TextGrid file was saved as 'folder$''selection$'.TextGrid.
	printline

	#******************************************************************************************************

endfor

printline Finished marking pauses in 'numberOfSelectedSounds' LongSound objects.
