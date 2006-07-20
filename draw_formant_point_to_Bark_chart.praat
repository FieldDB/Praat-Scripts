# Draw one formant point as a one-Bark circle on a Bark-scale F1/F2 chart
#
# This script is distributed under the GNU General Public License.
# Copyright Mietta Lennes 5.11.2004
#

form Draw one-Bark formant circle on a Bark-scale F1/F2 formant chart
	boolean Clear_Picture_window_first yes
	comment Formant values (Hz):
	real f1 500
	real f2 1500
	comment Formant chart minima and maxima (Hz):
	real f1_minimum 200
	real f1_maximum 1000
	real f2_minimum 600
	real f2_maximum 2500
	sentence Vowel_label a
	optionmenu Line_style 1
	option Plain line
	option Dashed line
	optionmenu Colour 1
	option Black
	option Grey
	option Silver
	option Red
	option Blue
	option Green
	option Cyan
	option Lime
	option Purple
endform

if clear_Picture_window_first = 1
	Erase all
endif


Black
Times
Line width... 1
Font size... 16

call AddBarkScale f1_minimum f1_maximum f2_minimum f2_maximum 1

Line width... 3

# switch to Bark scale:
f1bark = hertzToBark (f1)
f2bark = hertzToBark (f2)

f1low = f1bark - 0.5
f1high = f1bark + 0.5
f2low = f2bark - 0.5
f2high = f2bark + 0.5

'colour$'
'line_style$'
Draw ellipse... -f2high -f2low -f1high -f1low
Paint ellipse... White -f2high -f2low -f1high -f1low
Black
Plain line
Text... -f2bark Centre -f1bark Half 'vowel_label$'

#------

procedure AddBarkScale f1min f1max f2min f2max garnish

# This procedure adds Bark scale tick marks and lines to a
# reversed-and-inverted-axes F1/F2 formant chart (the traditional style).
# The input parameters for minima and maxima must be in Hertz.
#
# Remember that if you want to use Hertz scale for drawing after this
# procedure, you have to redefine the axes!!!

Draw inner box

if garnish = 1
	Text top... no Bark
	Text right... no Bark
endif

f1min_Bark = hertzToBark (f1min)
f1max_Bark = hertzToBark (f1max)
f2min_Bark = hertzToBark (f2min)
f2max_Bark = hertzToBark (f2max)

Axes... -f2max_Bark -f2min_Bark -f1max_Bark -f1min_Bark

Marks top every... 1 1 no yes yes
Marks right every... 1 1 no yes yes

if garnish = 1
	One mark left... -f1max_Bark no no no 'f1max:0'
	One mark left... -f1min_Bark no no no 'f1min:0'
	One mark bottom... -f2max_Bark no no no 'f2max:0'
	One mark bottom... -f2min_Bark no no no 'f2min:0'
endif

f1scale = floor ((f1max - f1min) / 100)
f2scale = floor ((f2max - f2min) / 100)

for x to f2scale
	f2value = hertzToBark (f2min + (x * 100))
	if (f2min + (x * 100) = 1000 or f2min + (x * 100) = 2000) and garnish = 1
		mark = f2min + (x * 100)
		mark$ = "'mark:0'"
	else
		mark$ = ""
	endif
	One mark bottom... -f2value no yes no 'mark$'	
endfor

for y to f1scale
	f1value = hertzToBark (f1min + (y * 100))
	if (f1min + (y * 100) = 500 or f1min + (y * 100) = 1000) and garnish = 1
		mark = f1min + (y * 100)
		mark$ = "'mark:0'"
	else
		mark$ = ""
	endif
	One mark left... -f1value no yes no 'mark$'	
endfor


endproc
