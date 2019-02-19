#!/bin/sh
# --  vt_keyset.sh
# --
# --  Unix shell script skeleton to set up UDKs (user-defined keys) on
# --  DEC VT420 (or similar) terminal; uses DECUDK device-control sequence.
# --  The user-defined keys are the Shifted values of the top-row function keys
# --  on the LK201 or LK401 keyboards (i.e., press Shift plus the Fxx key).
# --
# --  The VT420 and VT330 have only 256 nonvolatile bytes to store the strings.
# --  The strings you are loading have to be defined according to the numeric,
# --  hexadecimal values of the ASCII characters.  This is fully general but
# --  rather inconvenient at times.  The "od -x" command can show hex values.
# --
# --  You can "lock" the UD keys (freeze their values) from software, but then
# --  the only way to unlock them is from the setup menu. (Not from software!)
# --
# --  On most DEC terminals, UDKs do not work in VT100 mode.  Be sure the
# --  terminal is set to a later-model emulation in the General Setup menu.
# --
# --  1997-05-01 
# --  Copyright 1997 Richard S. Shuford <shuford@cs.utk.edu>.  Anyone may
# --  use this script and modify the key settings in it; just don't claim
# --  you wrote it or try to sell it.
# --
# --  1999-03-31  RSS  printf fails under some circumstances; echo is safer
# -----------------------------------------------------------------------------

if [ -x "/usr/bin/printf-dontuse" ]
then {
    OUT="/usr/bin/printf"
}
else {
    OUT="echo"              # Some Unix versions give you a variety of echo's,
}                           # all different. If this doesn't work, try another.
fi

$OUT  "Setting up function keys on terminal.\n"

     DCS='\0033P'           # device-control string       ESC P in 7-bit coding
      ST='\0033\\'          # string terminator           ESC \ in 7-bit coding
     CSI='\0033['           # control-sequence introducer ESC [ in 7-bit coding

    CNOL='0;1|'             # Clear all keys; do not lock any
    LNOL='1;1|'             # Load, but No Lock
    LLOK='1;0|'             # Load, and Lock key until unlocked via Setup menu

   KEYF6='17'
   KEYF7='18'
   KEYF8='19'
   KEYF9='20'
  KEYF10='21'               # there is no key corresponding to 22
  KEYF11='23'
  KEYF12='24'
  KEYF13='25'
  KEYF14='26'               # there is no key corresponding to 27
 KEYHELP='28'
  KEYF15='28'               # "Help" is legend on what would otherwise be F15
   KEYDO='29'
  KEYF16='29'               # "Do"   is legend on what would otherwise be F16
  KEYF17='31'
  KEYF18='32'
  KEYF19='33'
  KEYF20='34'

$OUT   "$DCS$CNOL$ST"       # clear all keys before loading new values, no lock

# -- Shift F20 set as "PRINT":  ASCII hex encoding is P=50 R=52 I=49 N=4E T=54

$OUT   "$DCS$LNOL$KEYF20/" \
       "5052494E54" \
       "$ST"

# -- Shift F19 set as a Unix shell command to list directories and links

$OUT   "$DCS$LNOL$KEYF19/" \
       "6C73202D46207C20736564202D6E20272F5C2F2F703B2F402F7027" \
       "$ST"

# --
# -- here put other key-definition strings in suitable $OUT statements
# --

$OUT   "$DCS$LNOL$KEYF18/" \
       "0D" \
       "$ST"



# -- Uncomment one of these two lines to force numeric-keypad mode (DECNKM).

# $OUT "$CSI?66h"    #  application Escape sequences
# $OUT "$CSI?66l"    #  numeric digits + punctuation

$OUT   "Finished setting up function keys.\n"
exit
# -----------------------------------------------------------------------------
