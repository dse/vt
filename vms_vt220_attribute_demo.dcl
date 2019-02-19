Article 125761 of comp.os.vms:
Path: cs.utk.edu!news.msfc.nasa.gov!newsfeed.internetmci.com!chi-news.cic.net!uwm.edu!homer.alpha.net!mvb.saic.com!info-vax
From: Gaylon Stockman <stockman@axpc.rdbewss.redstone.army.mil>
Newsgroups: comp.os.vms
Subject: Re: Bolding in DCL
Message-ID: <01HWW37B9G5EA8C8OI@axpc.rdbewss.redstone.army.mil>
Date: Thu, 26 Oct 1995 09:21:23 -0600 (CST)
Organization: Info-Vax<==>Comp.Os.Vms Gateway
X-Gateway-Source-Info: Mailing List
Lines: 256

	Christopher,
	I have included some code that I picked up somewhere - can't
remember where, although I think it was from Kevin Barkes. This should
help get you started in what you want to do. If you have any questions, 
send me a message.

------CUT HERE DEMO.COM--------
$! DEMO.COM
$! Command procedure to demonstrate the use of
$! some of the symbol assignments in USETERM.COM
$ WSO := WRITE SYS$OUTPUT
$ PAUSE1 := WAIT 00:00:01
$ PAUSE2 := WAIT 00:00:02
$ PAUSE3 := WAIT 00:00:03
$ PAUSE4 := WAIT 00:00:04
$ USETERM := @USETERM
$ USETERM
$ WSO CLEAR_SCREEN
$ USETERM POSITION 12 15
$ USETERM FORWARD 14
$ WSO POSITION+D_HEIGHT_TOP+"DEMO.COM"
$ WSO FORWARD+D_HEIGHT_BOT+"DEMO.COM"
$ WSO R_VIDEO
$ PAUSE1
$ WSO N_VIDEO
$ PAUSE1
$ WSO R_VIDEO
$ PAUSE1
$ WSO N_VIDEO
$ PAUSE1
$ WSO CLEAR_SCREEN
$ COPY/NOLOG SYS$INPUT SYS$OUTPUT
        By using the symbols defined in USETERM.COM, you can display a
                number of terminal characteristics, including:

$ PAUSE1
$ WSO BOLD_ON,"Bold type",BOLD_OFF
$ PAUSE1
$ WSO "         ",ULINE_ON,"Underlined type",ULINE_OFF
$ PAUSE1
$ WSO "                        ",BLINK_ON,"Blinking type,",BLINK_OFF
$ WSO ""
$ PAUSE1
$ WSO "                                       ",REV_ON,-
  "Reversed type",REV_OFF
$ WSO BOLD_ON,"And ",ULINE_ON,"combinations ",BLINK_ON,"of 
",REV_ON,"each."
$ WSO NORMAL,""
$ PAUSE3
$ WSO D_WIDTH,"Display double width lines,"
$ PAUSE2
$ WSO D_HEIGHT_TOP,"or double height lines"
$ WSO D_HEIGHT_BOT,"or double height lines"
$ USETERM SCROLL 20 24
$ WSO SCROLL
$ WSO ""
$ COPY/NOLOG SYS$INPUT SYS$OUTPUT












        You can set up a scrolling window for your command procedures,
                    leaving your original display intact.

$ PAUSE2
$ COPY/NOLOG SYS$INPUT SYS$OUTPUT




You can change your terminal characteristics....

$ PAUSE1
$ WSO JUMP
$ COPY/NOLOG SYS$INPUT SYS$OUTPUT

                        From
                            Jump
                                Scrolling....
$ PAUSE2
$ WSO SMOOTH
$ COPY/NOLOG SYS$INPUT SYS$OUTPUT


                        To
                          Smooth
                                Scrolling...
$ WSO JUMP
$ PAUSE2
$ WSO CLEAR_SCREEN
$ USETERM UP 5
$ USETERM DOWN 15
$ USETERM FORWARD 20
$ WSO DOWN,BOLD_ON,BLINK_ON,"Move"
$ PAUSE2
$ WSO UP,FORWARD,"around",FORWARD,UP,"the",UP,FORWARD,"screen",NORMAL
$ PAUSE2
$ WSO DOWN,"Change the terminal to 132 character display..."
$ PAUSE2
$ WSO C132
$ WSO "and back to 80 columns..."
$ PAUSE2
$ WSO C80
$ PAUSE2
$ WSO "Save a cursor position:  X",S_CURSOR
$ PAUSE2
$ USETERM DOWN 15
$ WSO 
DOWN,"Move",R_IND,"around",R_IND,"the",R_IND,"screen...",IND,"Then",-
   R_CURSOR,"return to the marked position...."
$ PAUSE2
$ WSO "Erase to the beginning to the screen..."
$ PAUSE2
$ WSO C_TO_START
$ WSO "And to the end..."
$ PAUSE2
$ WSO C_TO_END
$ PAUSE2
$ WSO "Clear the screen & maintain the current cursor position."
$ PAUSE2
$ WSO C_ALL,"All from DCL!"
$ PAUSE2
$ WSO "END OF DEMO.COM"
$ PAUSE2
$ WSO CLEAR_SCREEN
$ EXIT

------CUT HERE USETERM.COM-------
$! USETERM.COM
$! Sets up symbols which can be used to change terminal
$! display characteristics and attributes.
$! Define symbols so escape sequences in this command file
$! are all  "printable."
$  ESC[0,7]   = %X1B     ! Escape character
$  CSI        = ESC+"["  ! Control sequence introducer
$  BELL[0,7]  = %X7      ! Bell
$!
$! Trap errors:
$ ON WARNING THEN GOTO CATCH_ERROR
$!
$! If specified, execute one of the sequences
$! requiring passed variables:
$!
$ IF P1 .NES. "" THEN GOTO 'P1'
$!
$! Turn on/off bold or increased intensity:
$  BOLD_ON   == CSI+"1"+"m"
$  BOLD_OFF  == CSI+"2"+"2"+"m"
$! Turn on/off underlining:
$  ULINE_ON  == CSI+"4"+"m"
$  ULINE_OFF == CSI+"2"+"4"+"m"
$! Turn on/off blinking:
$  BLINK_ON  == CSI+"5"+"m"
$  BLINK_OFF == CSI+"2"+"5"+"m"
$! Turn on/off reverse image:
$  REV_ON  == CSI+"7"+"m"
$  REV_OFF == CSI+"2"+"7"+"m"
$! Turn off all attributes:
$  NORMAL == CSI+"0"+"m"
$! Turn on single-width:
$  S_WIDTH == ESC+"#"+"5"
$! Turn on double-width:
$  D_WIDTH == ESC+"#"+"6"
$! Double-height sequences:
$  D_HEIGHT_TOP == ESC+"#"+"3"
$  D_HEIGHT_BOT == ESC+"#"+"4"
$! Save current cursor position:
$  S_CURSOR  == ESC+"7"
$! Restore previously-saved position:
$  R_CURSOR  == ESC+"8"
$! Move cursor down one line in same column:
$  IND == ESC+"D"
$! Move cursor up one line in same column:
$  R_IND == ESC+"M"
$! Move cursor to first position on next line:
$  N_LINE == ESC+"E"
$! Erase the entire display, change to single-width,
$! cursor does not move:
$  C_ALL == CSI+"2"+"J"
$! Erase the display from the start of screen
$! to the current position:
$  C_TO_START == CSI+"1"+"J"
$! Erase the display from the current position
$! to the end of the screen:
$  C_TO_END  == CSI+"0"+"J"
$! Return the cursor to line 1, column 1:  
$  HOME_SCREEN  == CSI+"0"+"0"+"H"
$! Reposition the cursor to line 1,
$! column 1 and clear the screen:
$  CLEAR_SCREEN    == HOME_SCREEN+C_TO_END
$! Terminal test:
$  TERMTEST == ESC+"#"+"8"
$! Terminal modes:
$! Change to 132-column mode:
$  C132 == CSI+"?"+"3"+"h"
$! Change to 80-column mode:
$  C80 == CSI+"?"+"3"+"l" ! (lower case L)
$! Set smooth scrolling:
$  SMOOTH == CSI+"?"+"4"+"h"
$! Set jump scrolling:
$  JUMP == CSI+"?"+"4"+"l" ! (lower case L)
$! Set screen to reverse video:
$  R_VIDEO == CSI+"?"+"5"+"h"
$! Set screen to normal video:
$  N_VIDEO == CSI+"?"+"5"+"l" ! (lower case L)
$! Turn auto-wrap on:
$  WRAP_ON == CSI+"?"+"7"+"h"
$! Turn auto-wrap off:
$  WRAP_OFF == CSI+"?"+"7"+"l" ! (lower case L)
$! Turn auto-repeat on:
$  REPEAT_ON == CSI+"?"+"8"+"h"
$! Turn auto-repeat off:
$  REPEAT_OFF == CSI+"?"+"8"+"l" ! (lower case L)
$ EXIT
$! Set scrolling area according to passed 'p' parameters:
$ SCROLL:
$ SCROLL == CSI+P2+";"+P3+"r"
$ EXIT
$! Move cursor up:
$ UP:
$ UP == CSI+P2+"A"
$ EXIT
$! Move cursor down:
$ DOWN:
$ DOWN == CSI+P2+"B"
$ EXIT
$! Move cursor forward:
$ FORWARD:
$ FORWARD == CSI+P2+"C"
$ EXIT
$! Move cursor backward:
$ BACKWARD:
$ BACKWARD ==  CSI+P2+"D"
$ EXIT
$! Position cursor:
$ POSITION:
$ POSITION ==  CSI+P2+";"+P3+"f"
$ EXIT
$! Error handling:
$ CATCH_ERROR:
$! (Status code %X38148 is an unsatisfied goto)
$ IF $STATUS .EQ. %X38148 THEN GOTO BADPARM
$ WRITE SYS$OUTPUT "Unknown error."
$ EXIT
$ BADPARM:
$ WRITE SYS$OUTPUT P1," is an invalid parameter."
$ EXIT



Article 125797 of comp.os.vms:
Path: cs.utk.edu!news.msfc.nasa.gov!elroy.jpl.nasa.gov!swrinde!ihnp4.ucsd.edu!mvb.saic.com!info-vax
From: Gaylon Stockman <stockman@axpc.rdbewss.redstone.army.mil>
Newsgroups: comp.os.vms
Subject: Re: Bolding in DCL
Message-ID: <01HWW5HFI4ZSA8C8P1@axpc.rdbewss.redstone.army.mil>
Date: Thu, 26 Oct 1995 10:26:47 -0600 (CST)
Organization: CSC/U.S. Army MICOM; Home of BEWSS
X-Gateway-Source-Info: Mailing List
Lines: 19

Christopher,

	Forgot to mention it in case you did not know. Do
	@DEMO, which calls USETERM. The demo will show
	some nifty tricks with DCL and escape sequences.


 ##########################################################################
 #                           ___________________________________________  #
 #  Gaylon Stockman          | stockman@axpc.rdbewss.redstone.army.mil |  #
 #  Systems Manager          -------------------------------------------  #
 #  C S C / U.S. Army MICOM        Tel. (205)876-8154 Desk                #
 #  4815 Bradford Drive            Tel. (205)876-8154 Computer Rm.        #
 #  Huntsville, AL  35805          FAX  (205)876-6799                     #
 #                                                                        #
 #  Home of BEWSS - Battlefield Environment Weapon Systems Simulation     #
 #                                                                        #
 #  "The needs of the many out weigh the needs of the few" ...Spock       #
 ##########################################################################


Article 125991 of comp.os.vms:
Path: cs.utk.edu!news.msfc.nasa.gov!elroy.jpl.nasa.gov!usc!news.cerf.net!nntp-server.caltech.edu!SOL1.GPS.CALTECH.EDU!CARL
From: carl@SOL1.GPS.CALTECH.EDU (Carl J Lydick)
Newsgroups: comp.os.vms
Subject: Re: Bolding in DCL
Date: 29 Oct 1995 18:13:27 GMT
Organization: HST Wide Field/Planetary Camera
Lines: 28
Distribution: world
Message-ID: <470g87$68u@gap.cco.caltech.edu>
References: <46o0oh$a6u@sundog.tiac.net>,<Pine.A32.3.91.951027000948.127215F-100000@garnet.acns.fsu.edu>
Reply-To: carl@SOL1.GPS.CALTECH.EDU
NNTP-Posting-Host: sol1.gps.caltech.edu

In article <Pine.A32.3.91.951027000948.127215F-100000@garnet.acns.fsu.edu>, "Steven C. King" <sck4518@garnet.acns.fsu.edu> writes:
=Here's a simple DCL procedure to do WRITE SYS$OUTPUT with bold facing:
=
=$ ESC[0,7] = 27
=$ BOLD = "''ESC'[1m"
=$ UNBOLD = "''ESC'[m"
=$ WRITE SYS$OUTPUT "''BOLD'TESTING BOLD FACING''UNBOLD'"
=$ EXIT
=
=Make sure you don't get the ' and the " characters confused.

First, you really want to make sure that ESC starts out as a string symbol. 
Second, it's easy to avoid the ' character in this case:

$ ESC = ""
$ ESC[0,7] = 27
$ BOLD = ESC + "[1m"
$ UNBOLD = ESC + "[m"
$ WRITE SYS$OUTPUT BOLD, "TESTING BOLD FACING", UNBOLD
$ EXIT
--------------------------------------------------------------------------------
Carl J Lydick | INTERnet: CARL@SOL1.GPS.CALTECH.EDU | NSI/HEPnet: SOL1::CARL

Disclaimer:  Hey, I understand VAXen and VMS.  That's what I get paid for.  My
understanding of astronomy is purely at the amateur level (or below).  So
unless what I'm saying is directly related to VAX/VMS, don't hold me or my
organization responsible for it.  If it IS related to VAX/VMS, you can try to
hold me responsible for it, but my organization had nothing to do with it.


