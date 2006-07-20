# This script will convert the label strings in a tier in a selected TextGrid object 
# from IPA symbols (Praat) to Worldbet (ASCII IPA) format, or from Worldbet to IPA.
# A TextGrid object must be selected in the Object list.
#
# This script is distributed under the GNU General Public License.
# Copyright 10.3.2002 Mietta Lennes and Olga Bolotova

form Conversion IPA - Worldbet
comment A new IntervalTier will be added with the converted interval labels.
comment Convert label strings in the intervals of:
integer Tier 1
choice Conversion 1
button from IPA to Worldbet
button from Worldbet to IPA
endform

numberOfTiers = Get number of tiers
if conversion = 1
	Duplicate tier... tier 1 Worldbet
else
	Duplicate tier... tier 1 IPA
endif
tier = tier + 1
numberOfTiers = numberOfTiers + 1

numberOfIntervals = Get number of intervals... tier
for interval from 1 to numberOfIntervals
	label$ = Get label of interval... tier interval
	output$ = ""
	echo Converting interval 'interval' / 'numberOfIntervals'
	if label$ <> ""
		if conversion = 1
			while index (label$, " ") > 0
				symbol$ = left$ (label$, (index (label$, " ") - 1))
				if index (label$, " ") < length (label$)
					label$ = right$ (label$, (length (label$) - (index (label$, " "))))
				else
					label$ = ""
				endif
				call IPAtoWorldbet 'symbol$'
				output$ = output$ + converted$ + " "
			endwhile
			call IPAtoWorldbet 'label$'
			output$ = output$ + converted$
			Set interval text... 1 interval 'output$'
		else
			while index (label$, " ") > 0
				symbol$ = left$ (label$, (index (label$, " ") - 1))
				if index (label$, " ") < length (label$)
					label$ = right$ (label$, (length (label$) - (index (label$, " "))))
				else
					label$ = ""
				endif
				call WorldbetToIPA 'symbol$'
				output$ = output$ + converted$ + " "
			endwhile
			call WorldbetToIPA 'label$'
			output$ = output$ + converted$
			Set interval text... 1 interval 'output$'
		endif
	endif
endfor


#-----------
procedure IPAtoWorldbet string$
converted$ = ""
# in case the string is not empty, start checking it for the different IPA strings:
if string$ <> ""

# in case the string is only one character, just leave it as it is
if length (string$) = 1
	converted$ = string$
# if there are several characters, check them from right to left:
else
	while length (string$) > 0
		# check individual substrings, the longest possible substring first:
		if right$ (string$, 5) = "(\sw)"
			converted$ = "schwa-upper-score" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\li"
			converted$ = "-" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\sw"
			converted$ = "&" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\as"
			converted$ = "A" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\at"
			converted$ = "ax" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\ab"
			converted$ = "5" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\ae"
			converted$ = "@" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\Oe"
			converted$ = "6" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\ep"
			converted$ = "E" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\er"
			converted$ = "3" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\oe"
			converted$ = "8" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\o/"
			converted$ = "7" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\ic"
			converted$ = "I" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\yc"
			converted$ = "Y" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\i-"
			converted$ = "ix" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\u-"
			converted$ = "ux" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\o-"
			converted$ = "ox" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\mt"
			converted$ = "4" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\hs"
			converted$ = "U" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\rh"
			converted$ = "2" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\vt"
			converted$ = "^" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\ct"
			converted$ = ">" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\li"
			converted$ = "-" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\f2"
			converted$ = "F" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\be"
			converted$ = "V" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\mj"
			converted$ = "M" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\vs"
			converted$ = "V_[" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\te"
			converted$ = "T" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\dh"
			converted$ = "D" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\rt"
			converted$ = "9" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\l-"
			converted$ = "hl" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\l~"
			converted$ = "L" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\lz"
			converted$ = "Zl" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\fh"
			converted$ = "d_(" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\sh"
			converted$ = "S" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\zh"
			converted$ = "Z" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\rl"
			converted$ = "l_(" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\b^"
			converted$ = "b_<" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\d^"
			converted$ = "d_<" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\j"
			converted$ = "J_<" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\g^"
			converted$ = "g_<" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\G^"
			converted$ = "Q_<" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\t."
			converted$ = "t_r" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\d."
			converted$ = "d_r" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\n."
			converted$ = "n_r" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\s."
			converted$ = "s_r" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\z."
			converted$ = "z_r" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\r."
			converted$ = "9r" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\f."
			converted$ = "rr" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\l."
			converted$ = "l_r" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\cc"
			converted$ = "c}" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\zc"
			converted$ = "z}" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\jc"
			converted$ = "C_v" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\j-"
			converted$ = "J" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\nj"
			converted$ = "nj" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\yt"
			converted$ = "L_j" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\ht"
			converted$ = "jw" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\wt"
			converted$ = "W" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\gs"
			converted$ = "g" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\ng"
			converted$ = "N" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\ga"
			converted$ = "G" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\ml"
			converted$ = "4)" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\lc"
			converted$ = "L" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\gc"
			converted$ = "Q" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\nc"
			converted$ = "Ng" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\ci"
			converted$ = "X" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\ri"
			converted$ = "K" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\rc"
			converted$ = "R" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\h-"
			converted$ = "H" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\9e"
			converted$ = "!" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\?g"
			converted$ = "?" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\hc"
			converted$ = "H_-" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\9-"
			converted$ = "!_-" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\h^"
			converted$ = "h_v" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\sr"
			converted$ = "&_r" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\0v"
			converted$ = "_0" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\0^"
			converted$ = "_0" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\~^"
			converted$ = "_n" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\cn"
			converted$ = "_c" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\|v"
			converted$ = "_=" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\Tv"
			converted$ = "_/" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\T^"
			converted$ = "_^" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\'^"
			converted$ = "_7" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\`^"
			converted$ = "_7" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\|1"
			converted$ = "|" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\|2"
			converted$ = "l|" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 3) = "\|-"
			converted$ = "c|" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 2) = "\c"
			converted$ = "C" + converted$
			string$ = left$ (string$, (length (string$) - 3))
		elsif right$ (string$, 2) = "^l"
			converted$ =  "_l" + converted$ 
			string$ = left$ (string$, (length (string$) - 2))
		elsif right$ (string$, 1) = ":"
			converted$ =  "_:" + converted$ 
			string$ = left$ (string$, (length (string$) - 2))
		elsif right$ (string$, 1) = "'"
			converted$ =  "_;" + converted$ 
			string$ = left$ (string$, (length (string$) - 2))
		# Special replacement IPA symbols used by the St. Petersburg group in Russia:
		elsif right$ (string$, 1) = "^"
			converted$ =  "_(" + converted$ 
			string$ = left$ (string$, (length (string$) - 1))
		elsif right$ (string$, 1) = "~"
			converted$ =  "_2" + converted$ 
			string$ = left$ (string$, (length (string$) - 1))
		elsif right$ (string$, 1) = "+"
			converted$ =  "_v" + converted$ 
			string$ = left$ (string$, (length (string$) - 1))
		elsif right$ (string$, 1) = "-"
			converted$ =  "_0" + converted$ 
			string$ = left$ (string$, (length (string$) - 1))
		elsif right$ (string$, 1) = "*"
			converted$ =  "_=" + converted$ 
			string$ = left$ (string$, (length (string$) - 1))
		else
			# if none of the above strings matched, then take what's left of the
			# string and just add it to the beginning of the converted string as such:
			converted$ =  string$ + converted$
			# and empty the string, so no more checks will be performed to it
			string$ = ""
		endif
	endwhile
endif

endproc

#-----------
procedure WorldbetToIPA string$
converted$ = ""
base$ = ""
diacritics$ = ""

# This is more difficult than IPA to Worldbet conversion, because the diacritics
# can be in a different order...

# in case the string is not empty, start checking for the different Worldbet strings:
if string$ <> ""
	# First divide the string into two substrings, the base symbol and diacritics:
	if index (string$, "_") > 0
		# everything before the first _ character should form the base symbol:
		base$ = left$ (string$, (index (string$, "_") - 1))
		# the rest of the string will be the diacritics:
		diacritics$ = right$ (	string$, (length (string$) - index (string$, "_") + 1))	
	else
		base$ = string$
		diacritics$ = ""
	endif

	# Then start looking for base-symbol + diacritic combinations.
	# First we have to check the most complex combinations.
	# I also think that the leftmost diacritics should be prioritized, because
	# the transcriber probably thought of them first, so they might be a good
	# guess to be included in an IPA base symbol...?

	while diacritics$ <> ""
		# Here we must list all the possible combinations of base+diacritics,
		# which have a separate IPA base symbol.
		# If a match is found, we add the IPA base symbol string in front of
		# the converted string:
		if base$ = "&" and left$ (diacritics$, 2) = "_r"
			converted$ = "\sr" + converted$
			base$ = ""
			diacritics$ = right$ (diacritics$, ((length (diacritics$)) - 2))
		# if none of the base+diacr. combinations match with an IPA symbol, 
		# then check the diacritic alone and add it to the end of the converted string.
		# The diacritics should be checked in the order they should be added to the converted string.
		# Some diacritics are put above the base symbol, some below. How do we check this?
		elsif left$ (diacritics$, 2) = "_0"
			converted$ = converted$ + "\0v"
			diacritics$ = right$ (diacritics$, ((length (diacritics$)) - 2))
		elsif left$ (diacritics$, 2) = "_?"
			converted$ = converted$ + "(\?g)"
			diacritics$ = right$ (diacritics$, ((length (diacritics$)) - 2))
		else 
			# it seems that the leftmost diacritic was not recognized, so we have to
			# add it to the IPA symbol as such and go on checking the rest:
			converted$ = converted$ + left$ (diacritics$, 2)
			diacritics$ = right$ (diacritics$, ((length (diacritics$)) - 2))
		endif
	endwhile

	# Now there are no more diacritics to convert.
	# If no match was found for the base symbol in the above combinations, then take 
	# the unconverted base symbol and check for matches for the base alone.
	# I there is no match, just add it in front of the converted string as such:
	if base$ = "@"
		converted$ = "\ae" + converted$
		base$ = ""
	elsif base$ = "A"
		converted$ = "\as" + converted$
		base$ = ""
	elsif base$ = "7"
		converted$ = "\o/" + converted$
		base$ = ""
	elsif base$ <> ""
		converted$ = base$ + converted$
		base$ = ""
	endif
endif
endproc
