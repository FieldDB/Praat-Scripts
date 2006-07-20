# This Praat script will globally change the sample rate of all the AIFF files in the given folder.
# See the Praat manual for details.
# 
# This script is distributed under the GNU General Public License.
# Copyright 10.3.2002 Mietta Lennes

form Change sample rate in sound files
   comment Changes will be made to ALL aiff sound files in the directory.
   comment Files must be in AIFF format and filenames must include the string .aif or .AIF!
   sentence Directory  /home/lennes/tmp/
   positive New_sample_rate_(Hz) 22050
   positive Precision_(samples) 50
endform

Create Strings as file list... list 'directory$'*
numberOfFiles = Get number of strings
for ifile to numberOfFiles
   select Strings list
   sound$ = Get string... ifile
	if index (sound$, ".aif") > 0 or index (sound$, ".AIF") > 0 
		Read from file... 'directory$''sound$'
		Rename... temp
		oldrate = Get sample rate
		if oldrate <> new_sample_rate
			Resample... new_sample_rate precision
			filedelete 'directory$''sound$'
			Write to AIFF file... 'directory$''sound$'
		endif
		select Sound temp
		Remove
	endif
endfor

select Strings list
Remove





