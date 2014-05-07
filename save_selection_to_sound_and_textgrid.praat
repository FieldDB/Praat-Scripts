# This script saves the selected portion of a LongSound file to a separate
# Sound file (WAV), and the corresponding part of the TextGrid file to an
# independent TextGrid file. The TextGrid will be "genericized" before saving.
# You have to open the script from within a TextGrid editor window. You can also 
# add a new menu command for this script, e.g., in the File menu of the TextGrid editor.
#
# This script is distributed under the GNU General Public License.
# Copyright 9.10.2001 Mietta Lennes
#

form Where do you want to save the files?
comment Folder:
text Folder /home/lennes/tmp
sentence Save_sound_to_subfolder 
sentence Save_TextGrid_to_subfolder 
sentence Filename utterance1
endform

soundpath$ = folder$ + save_sound_to_subfolder$ + "/" + filename$ + ".wav"
gridpath$ = folder$ + save_TextGrid_to_subfolder$ + "/" + filename$ + ".TextGrid"

filedelete 'soundpath$'
filedelete 'gridpath$'

start = Get begin of selection
end = Get end of selection

endeditor

gridname$ = selected$ ("TextGrid", 1)
soundname$ = selected$ ("LongSound", 1)

select TextGrid 'gridname$'
Extract part... start end no
Genericize
Write to text file... 'gridpath$'
Remove

select LongSound 'soundname$'
Extract part... start end no
Write to WAV file... 'soundpath$'
Remove

select LongSound 'soundname$'
plus TextGrid 'gridname$'

editor

