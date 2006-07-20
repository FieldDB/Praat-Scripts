# This script extracts a tab-separated column from a text file.
# 
# This script is distributed under the GNU General Public License.
# Copyright 22.5.2003 Mietta Lennes

form Extract column from a tabular text file
   sentence Column_name Duration
   comment Give the path of the text file:
   text Input_file /home/lennes/selection.txt
   comment Give the path of the resulting file:
   text Output_file /home/lennes/durations.txt
endform

Read Strings from raw text file... 'input_file$'
Rename... temp

if fileReadable(output_file$)
   pause File 'output_file$' exists! Do you want to overwrite it?
   filedelete 'output_file$'
endif

call GetColumnNumber col 'column_name$'
if col > 0
   numberOfLines = Get number of strings
   for line from 2 to numberOfLines
      call GetColumnFromTextLine col line string$
      fileappend 'output_file$' 'string$''newline$'
   endfor
else
   exit Column 'column_name$' was not found!
endif

printline The column 'column_name$' was extracted to file 'output_file$'.

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

