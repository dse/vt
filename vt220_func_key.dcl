Article 65604 of comp.os.vms:
Newsgroups: comp.os.vms
Path: cs.utk.edu!darwin.sura.net!howland.reston.ans.net!xlink.net!sol.ctr.columbia.edu!news.cs.columbia.edu!cs.columbia.edu!reid
From: reid@dsm.fordham.edu (Darin Reid)
Subject: Re: QUESTION: reassigning keys on VT220 terminal.
In-Reply-To: Mighty Firebreather's message of Mon, 17 May 1993 13:31:28 EDT
Message-ID: <REID.93May17233037@dsm.dsm.fordham.edu>
Sender: news@cs.columbia.edu (The Daily News)
Organization: Fordham University/CLC, Division of Science and Math
References: <0096CA40.09830EA0.20332@nscvax.princeton.edu>
Date: Tue, 18 May 1993 04:30:37 GMT
Lines: 145


I picked this up some time ago.  it lets you define the vt220 function
keys to any command.  All you have to type is "SHIFT-<function key>".
These commands always work not only in your DCL environment (Well they
work under an Emacs session, and on the command line, during a telnet session
session to a Unix (AIX) machine).
------------------------------------------------------------------------------

$!	VT2XXDEF.COM - Procedure to define the function keys on VT2xx terminals
$!
$! Function key definitions are used by holding the shift key down while hitting
$! the function key.  A carriage return is appended to the end of each string.
$! You must edit this file between the lines of *'s to define multiple function
$! keys at one time.  Optionally, you can pass the key name and the definition
$! on the command line, and only that definition will be made.
$! Parameters:
$!	P1 = FunctionKeyName (F6-F14,HELP,DO,F17-F20)	P2 = Definition
$!
$	SAVERIFY = F$VERIFY(0)	! Save and turn off verification
$	SET TERMINAL/INQUIRE	! Make sure we're using a VT200 series terminal.
$	IF F$GETDVI("TT:","TT_DECCRT2") THEN GOTO START
$	WRITE SYS$OUTPUT -
		"Sorry, but this procedure works only on VT2xx terminals."
$	GOTO FINISHED
$ START:
$	ESC[0,8] = 27
$	SET SYMBOL/SCOPE=NOGLOBAL ! Don't want global symbol defs to interfere.
$	GOSUB DEFINE_KEYNUMBERS		! Define the key names and numbers.
$	ONLY_ONE = "FALSE"		! Initialize ONLY_ONE key def to false.
$	IF P1 .EQS. "" THEN GOTO INTERNAL_DEFS	! Key def on command line?
$	ONLY_ONE = "TRUE"			! Key def on command line.
$	I = F$LOCATE(P1,KEYDEF)			! Find key in definitions.
$	IF I .EQ. F$LENGTH(KEYDEF) THEN GOTO FINISHED ! Make sure valid key.
$	GOTO SINGLE_ENTRY			! Enter loop as single entry.
$!
$ INTERNAL_DEFS:
$!*****************************************************************************
$! Define key strings here. Use the function key names (F6-F14,HELP,DO,F17-F20)
$! Example:   $ F14 := SHOW SYSTEM
$ F7 := dr
$ F14 := p
$ HELP := help
$!*****************************************************************************
$!
$!		 Load the above keys into the VT2xx terminal
$	I = 0
$ LOOP:
$	P1 = F$EDIT(F$EXTRACT(I,4,KEYDEF),"TRIM")	! Get the key name.
$	IF F$TYPE('P1') .EQS. "" THEN GOTO TRY_NEXT	! Has it been defined?
$	P2 = 'P1'					! Get the string.
$ SINGLE_ENTRY:
$	KEYNUM = F$EXTRACT(I+4,2,KEYDEF)		! Get the key number.
$	GOSUB CONVERT_STR_TO_HEX			! Convert string to HEX.
$	WRITE SYS$OUTPUT "''ESC'P1;1|''KEYNUM'/''HEXSTR'0D''ESC'\" +- ! Do it.
	"Defining Shift ''P1' as " + P2		! (0D is the carriage return).
$	IF ONLY_ONE THEN GOTO FINISHED		! Exit if key def on cmd line.
$ TRY_NEXT:
$	I = I + 6				! Index to next key in KEYDEF.
$	IF I .GT. 84 THEN GOTO FINISHED		! Are we finished yet?
$	GOTO LOOP				! Go do another one.
$!
$!	Subroutine to convert string P2 to it's hex representation HEXSTR
$ CONVERT_STR_TO_HEX:
$	LEN = F$LENGTH(P2)			! Get the length of the string.
$	X = 0					! Initialize offset into string.
$	HEXSTR = ""				! Initialize hex representation.
$ CVT_LOOP:
$	CHR = F$EXTRACT(X,1,P2)			! Get the next character.
$	HEX = F$FAO("!XB",F$CVUI(0,8,CHR))	! Get the hex equivalent.
$	HEXSTR = HEXSTR + HEX		! Add it to the hex representation.
$	X = X + 1				! Increment offset.
$	IF X .GE. LEN THEN RETURN		! Finished string yet?
$	GOTO CVT_LOOP				! Go convert next character.
$!
$!			Define the key names and numbers
$ DEFINE_KEYNUMBERS:
$	KEYDEF[00,4] := F6	! 4 character maximum for key name
$	KEYDEF[04,2] := 17	! 2 character maximum for key number
$	KEYDEF[06,4] := F7
$	KEYDEF[10,2] := 18
$	KEYDEF[12,4] := F8
$	KEYDEF[16,2] := 19
$	KEYDEF[18,4] := F9
$	KEYDEF[22,2] := 20
$	KEYDEF[24,4] := F10
$	KEYDEF[28,2] := 21
$	KEYDEF[30,4] := F11
$	KEYDEF[34,2] := 23
$	KEYDEF[36,4] := F12
$	KEYDEF[40,2] := 24
$	KEYDEF[42,4] := F13
$	KEYDEF[46,2] := 25
$	KEYDEF[48,4] := F14
$	KEYDEF[52,2] := 26
$	KEYDEF[54,4] := HELP
$	KEYDEF[58,2] := 28
$	KEYDEF[60,4] := DO
$	KEYDEF[64,2] := 29
$	KEYDEF[66,4] := F17
$	KEYDEF[70,2] := 31
$	KEYDEF[72,4] := F18
$	KEYDEF[76,2] := 32
$	KEYDEF[78,4] := F19
$	KEYDEF[82,2] := 33
$	KEYDEF[84,4] := F20
$	KEYDEF[88,2] := 34
$	RETURN
$!
$ FINISHED:
$	SAVERIFY = F$VERIFY(SAVERIFY)	! Restore verification
$	EXIT
$!
$!	NOTE: This procedure's in-procedure command definitions may be more
$! useful if the "0D" (carriage return) is removed from the definition string
$! and ''CR' is used to denote carriage returns, with CR defined as follows:
$!	$ CR[0,8] = 13	! This would allow more flexibility like /TERMINATE
$! on the DEFINE/KEY command.
$!	For example, a DECserver is much easier to set up:
$!	$ NCP == "$NCP"
$!	$ F6 = "NCP CONNECT NODE "
$!	$ F7 = "serverpwd''CR'"
$!	$ F8 = "SET PRIVILEGED''CR'"
$!	$ F9 = "privpwd''CR'"
$!	$ F10 = "DEFINE SERVER NAME "
$!	$ F11 = "DEF POR "
$!	$ F12 = " PREF SER VAX AUTOCON ENA INACT LOG ENA''CR'"
$!	$ F13 = "LOGOUT PORT "
$!	$ F14 = "LOGOUT''CR'"
$! Of course, these lines must occur between the lines of *'s to be used.
$! (I use a "DECserver" version with the above changes, and the original
$! version above for more generic purposes.)
--

- Darin
--
Bitnet  : Areid@Fordmulc             __                      _ __
Unix/AIX: Reid@Dsm.Fordham.Edu      /  )                    ' )  )        /
Vax/VMS : Areid@Mary.Fordham.Edu   /  / __.  __  o ____      /--' _  o __/
DECnet  : MARY::AREID             /__/_(_/|_/ (_<_/ / <_    /  \_</_<_(_/_
Freenet : Bz809@Cleveland.Freenet.Edu







Article 65702 of comp.os.vms:
Path: cs.utk.edu!gatech!howland.reston.ans.net!usc!elroy.jpl.nasa.gov!nntp-server.caltech.edu!SOL1.GPS.CALTECH.EDU!CARL
From: carl@SOL1.GPS.CALTECH.EDU (Carl J Lydick)
Newsgroups: comp.os.vms
Subject: RE: QUESTION: reassigning keys on VT220 terminal.
Date: 19 May 1993 16:23:45 GMT
Organization: HST Wide Field/Planetary Camera
Lines: 26
Distribution: world
Message-ID: <1tdmuhINN6b0@gap.caltech.edu>
References: <01GYA18KWFIQCTZ8FY@PUMA.DIR.TEXAS.GOV>
Reply-To: carl@SOL1.GPS.CALTECH.EDU
NNTP-Posting-Host: sol1.gps.caltech.edu

In article <01GYA18KWFIQCTZ8FY@PUMA.DIR.TEXAS.GOV>, "Stewart Nichols (512) 463.7601" <NICHOLS_SA@PUMA.DIR.TEXAS.GOV> writes:
=>> How do I reassign the function keys, and the prev. screen, next screen
=>> keys on a DEC vt220 terminal?
=
=>    You can't.
= 
=>    [other stuff deleted...]
=
=You certainly CAN reassign the function and Prev/Next keys on 
=a VT220.  Here is how to do it at the DCL level, taken from
=my login.com file:
=
=  $ DEFINE/KEY/NOLOG  E1 "SET DEF "/noterminate/echo    !Find key

That's not reassigning the function keys, that's redefining the system's
response to them.  The person who asked the initial question almost certainly
wanted to know how to reprogram the keys, as you can with the user-defined
keys.
--------------------------------------------------------------------------------
Carl J Lydick | INTERnet: CARL@SOL1.GPS.CALTECH.EDU | NSI/HEPnet: SOL1::CARL

Disclaimer:  Hey, I understand VAXen and VMS.  That's what I get paid for.  My
understanding of astronomy is purely at the amateur level (or below).  So
unless what I'm saying is directly related to VAX/VMS, don't hold me or my
organization responsible for it.  If it IS related to VAX/VMS, you can try to
hold me responsible for it, but my organization had nothing to do with it.


