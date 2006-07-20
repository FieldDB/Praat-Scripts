# This script picks out lines by the content of given columns 
# from a tab-separated text file.
# The script can be used to select a subset of analyzed data for
# e.g., drawing pictures or calculating statistics.
#
# This script is distributed under the GNU General Public License.
# Copyright 22.5.2003 Mietta Lennes
#

# First, ask the user for filenames and the criteria to use for
# selecting data lines in the input text file.

form Select lines from a tab-separated text file
   comment Give the full path of the tab-separated input text file: 
   text input_file /home/lennes/phonemes.txt
   comment Give the full path for the resulting text file: 
   text output_file /home/lennes/selection.txt
   comment Give the criteria for selecting lines. The first
   comment line in the text file must contain column titles.
   sentence Column_label_1 
   comment Give either a string value or a numeric value for column 1.
   sentence Value_1_(string) 
   real Value_1_(numeric) 0
   optionmenu Logical_operation_(optional) 1
   option AND
   option OR
   sentence Column_label_2 
   comment Give either a string value or a numeric value for column 2.
   sentence Value_2_(string) 
   real Value_2_(numeric) 0
endform

# Read the input file:
Read Strings from raw text file... 'input_file$'
Rename... input
numberOfLines = Get number of strings

if fileReadable(output_file$)
   pause The output file 'output_file$' exists! Do you want to overwrite?
   filedelete 'output_file$'
endif

# Copy the column titles to the result file:
titleline$ = Get string... 1
fileappend 'output_file$' 'titleline$''newline$'

matches = 0

if value_1$ <> ""
   type1$ = "string"
else
   type1$ = "number"
endif

if value_2$ <> ""
   type2$ = "string"
else
   type2$ = "number"
endif

call GetColumnNumber col1 'column_label_1$'
# if the first column really exists, check also the second column:
if col1 > 0
   printline Column 1 ('column_label_1$') was found.

   if column_label_2$ <> "" and column_label_2$ <> "0"
      printline 'column_label_2$'
      call GetColumnNumber col2 'column_label_2$'
      if col2 > 0
         # Now both columns exist, and we can look for matching lines.
         printline Column 2 ('column_label_2$') was found.
         if type1$ = "string"
            for line from 2 to numberOfLines
               call CheckMatch line col1 value_1$
               match1 = match
               if type2$ = "string"
	          call CheckMatch line col2 value_2$
                  match2 = match
	       else
	          call CheckMatch line col2 value_2
                  match2 = match
               endif
               # Check if the result was a logical match:
               if logical_operation = 1
		  if match1 = 1 and match2 = 1
                    # This was a match! Save the line.
                     matches = matches + 1
                     resultline$ = Get string... line
                     fileappend 'output_file$' 'resultline$''newline$'
                  endif
               else
		  if match1 = 1 or match2 = 1
                     # This was a match! Save the line.
                     matches = matches + 1
                     resultline$ = Get string... line
                     fileappend 'output_file$' 'resultline$''newline$'
                  endif
               endif
            endfor
         else
            for line from 2 to numberOfLines
               call CheckMatch line col1 value_1
               match1 = match
               if type2$ = "string"
	          call CheckMatch line col2 value_2$
                  match2 = match
               else
 	          call CheckMatch line col2 value_2
                  match2 = match
               endif
               # Check if the result was a logical match:
               if logical_operation = 1
		  if match1 = 1 and match2 = 1
                     # This was a match! Save the line.
                     matches = matches + 1
                     resultline$ = Get string... line
                     fileappend 'output_file$' 'resultline$''newline$'
                  endif
               else
		  if match1 = 1 or match2 = 1
                     # This was a match! Save the line.
                     matches = matches + 1
                     resultline$ = Get string... line
                     fileappend 'output_file$' 'resultline$''newline$'
                  endif
               endif
            endfor
         endif
      else
         printline Column 2 ('column_label_2$') was not found!
	 # If OR, matches may be found even without column 2:
         if logical_operation = 2
            printline Since you selected "1 OR 2", I will still try to find matches for column 1...
            for line from 2 to numberOfLines
               call CheckMatch line col1 value_1
 	       if match = 1
                  # This was a match! Save the line.
                  matches = matches + 1
                  resultline$ = Get string... line
                  fileappend 'output_file$' 'resultline$''newline$'
               endif
            endfor
         # otherwise we must exit without success.
         else
            exit No matches could be found. Exiting...
	 endif
      endif
   # if the second label was empty, only one column will be used as criterion.
   else
      printline You did not specify a second column. The logical operation will be ignored.
      for line from 2 to numberOfLines
         if type1$ = "string"
            call CheckMatch line col1 value_1$
         else
            call CheckMatch line col1 value_1
         endif
	 if match = 1
            # This was a match! Save the line.
            matches = matches + 1
            resultline$ = Get string... line
            fileappend 'output_file$' 'resultline$''newline$'
         endif
      endfor
   endif
endif


Remove

printline 'matches' matching lines were found.
printline The result was saved to the file 'output_file$'.


#-------

# This procedure finds a specified tab-separated string from the first line in
# a Strings object, and saves the column number to variable 'tovariable$'.

procedure GetColumnNumber tovariable$ text$

        col = 0
        column_title_not_found = 0

        repeat
                col = col + 1
                call GetColumnFromTextLine col 1 string$
        until string$ = text$ or lineend = 1

        if string$ = text$
                'tovariable$' = col
        else
                'tovariable$' = 0
                column_title_not_found = 1
        endif

        if column_title_not_found = 1
                printline For your attention, "'text$'" was not available.
        endif

endproc

#------

# This procedure checks whether a given tab-separated column 
# in a text line is equal to the content of 'valuevariable$'.

procedure CheckMatch line column valuevariable$

   match = 0

   if right$ (valuevariable$, 1) = "$"
      call GetColumnFromTextLine column line tempstring$
      if tempstring$ = 'valuevariable$'
         match = 1
      endif
   else
      call GetColumnFromTextLine column line tempnumber
      if tempnumber = 'valuevariable$'
         match = 1
      endif
   endif

endproc

#--------------

# This procedure reads a tab-separated string from a Strings object
# and returns the string within a given column in a variable.

procedure GetColumnFromTextLine col line output$

        data$ = Get string... line
        column = 1
        lineend = 0

        while column < col and lineend = 0
                column = column + 1
                if index (data$, "	") > 0
                        data$ = right$ (data$, (length (data$) - index (data$, "	")))
                else
                        data$ = ""
                        lineend = 1
                endif
        endwhile

        if index (data$, "	") > 0
                data$ = left$ (data$, (index (data$, "	") - 1))
        endif

        if right$ (output$, 1) = "$"
                'output$' = data$
        else
                'output$' = extractNumber (data$, "")
        endif

endproc

