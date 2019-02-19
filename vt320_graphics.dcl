Article 332 of vmsnet.misc:
Path: utkcs2!gatech!swrinde!sdd.hp.com!ieee.org!ieeefs!f2001.n107.z1.ieee.org!Abe.Suleiman
From: Abe.Suleiman@f2001.n107.z1.ieee.org (Abe Suleiman)
Newsgroups: vmsnet.misc
Subject: Try this little progrDCL procedure Igoto create interesting prompts.
Message-ID: <10481.2943F678@ieee.org>
Date: 9 Dec 91 19:27:36 GMT
Sender: news@ieee.org
Organization: FidoNet node 1:107/2001 - HUB 200 GROUP, Coram NY
Lines: 210


$ SET
NOVERIFY
$!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!

$! GRAPHICS.COM
$!      This subroutine is used to create on screen graphics on a VT320
$!      terminal.  A text file is created that redefines the characters
$!      and displays  them.  This  is created from  an input text  file
$!      that  is defined by  the user.  The  basic layout of  the input
$!      file is  an enlarged version of  the graphic.  Any  displayable
$!      character  (except tab  as it would  be interpreted as a single
$!      space  instead of the eight  or so that it usually  stands for)
$!      can be used for off pixels, all on pixels are signified by "*".
$!      The only limit is that the vt320 terminal's downloadable
$!      character set has a limit of 94 characters.  This program will
$!      continue beyond that but those characters that are "out of
$!      bounds" will not display in the final graphic.
$!
$!      To calculate the number of characters required in a graphic
$!      use the following formula:
$!              (C / 15) round up to the nearest integer
$!              * (R / 12) round up to the neareat integer
$!                      where C is the number of columns (record length)
$!                      and R is the number of row (number of records)
$!
$!      Written by: Harry Delien Dec 5,
1990
$!
$!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!

$!      12/06/90 - Allow variable length records
$!      12/06/90 - Patch to maintain cursor position while character
$!                 redefinitions are being downloaded.
$!      12/06/90 - Query output modes normal, double width, or double height
$!      12/06/90 - If record length is evenly divisable by 15 program writes
$!                 a blank character (wasteful).  Bug
fix.
$!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!

$ SET = ""      ! Get rid of local system symbol
$ OPEN = ""
$       ALPHABET =
"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^
_`abcdefghijklmnopqrstuvwxyz{|}~"
$       PRINT_STRING = ""
$       PRINT_CHAR = 0
$!
$ GET_INFILE_NAME:
$       INQUIRE IN_FILE "What is the name of the input file "
$       IF( F$SEARCH("''IN_FILE'") .EQS. "")THEN GOTO NO_INFILE
$!
$ GET_OUTFILE_NAME:
$       INQUIRE OUT_FILE "What is the name of the output file "
$       IF( OUT_FILE .EQS. "" )THEN GOTO GET_OUTFILE_NAME
$       IF( F$SEARCH("''OUT_FILE'") .NES. "")THEN GOTO ALREADY
$!
$ GET_DISPLAY_MODE:
$       INQUIRE DIS_MODE "Display (N)ormal, Double-(W)idth, or
Double-(H)eight"
$       IF (DIS_MODE.NES."N".AND.DIS_MODE.NES."W".AND.DIS_MODE.NES."H")THEN
GOTO
 GET_DISPLAY_MODE
$!
$ OPEN:
$       OPEN INPUT_FILE 'IN_FILE
$       ON CONTROL_Y THEN GOTO EXIT_1
$       OPEN/WRITE OUTPUT_FILE 'OUT_FILE
$       ON CONTROL_Y THEN GOTO EXIT
$!
$ READ:
$       LOOP_VAR = 0
$       MAX_SIZE = 0
$       BIT_1 = ""
$       BIT_2 = ""
$       BIT_3 = ""
$       BIT_4 = ""
$       BIT_5 = ""
$       BIT_6 = ""
$       BIT_7 = ""
$       BIT_8 = ""
$       BIT_9 = ""
$       BIT_10 = ""
$       BIT_11 = ""
$       BIT_12 = ""
$       READ/ERROR=DONE INPUT_FILE BIT_1
$       MAX_SIZE = F$LENGTH(BIT_1)
$       READ/ERROR=PROCESS INPUT_FILE BIT_2
$       IF( F$LENGTH(BIT_2) .GT. MAX_SIZE )THEN MAX_SIZE = F$LENGTH(BIT_2)
$       READ/ERROR=PROCESS INPUT_FILE BIT_3
$       IF( F$LENGTH(BIT_3) .GT. MAX_SIZE )THEN MAX_SIZE = F$LENGTH(BIT_3)
$       READ/ERROR=PROCESS INPUT_FILE BIT_4
$       IF( F$LENGTH(BIT_4) .GT. MAX_SIZE )THEN MAX_SIZE = F$LENGTH(BIT_4)
$       READ/ERROR=PROCESS INPUT_FILE BIT_5
$       IF( F$LENGTH(BIT_5) .GT. MAX_SIZE )THEN MAX_SIZE = F$LENGTH(BIT_5)
$       READ/ERROR=PROCESS INPUT_FILE BIT_6
$       IF( F$LENGTH(BIT_6) .GT. MAX_SIZE )THEN MAX_SIZE = F$LENGTH(BIT_6)
$       READ/ERROR=PROCESS INPUT_FILE BIT_7
$       IF( F$LENGTH(BIT_7) .GT. MAX_SIZE )THEN MAX_SIZE = F$LENGTH(BIT_7)
$       READ/ERROR=PROCESS INPUT_FILE BIT_8
$       IF( F$LENGTH(BIT_8) .GT. MAX_SIZE )THEN MAX_SIZE = F$LENGTH(BIT_8)
$       READ/ERROR=PROCESS INPUT_FILE BIT_9
$       IF( F$LENGTH(BIT_9) .GT. MAX_SIZE )THEN MAX_SIZE = F$LENGTH(BIT_9)
$       READ/ERROR=PROCESS INPUT_FILE BIT_10
$       IF( F$LENGTH(BIT_10) .GT. MAX_SIZE )THEN MAX_SIZE = F$LENGTH(BIT_10)
$       READ/ERROR=PROCESS INPUT_FILE BIT_11
$       IF( F$LENGTH(BIT_11) .GT. MAX_SIZE )THEN MAX_SIZE = F$LENGTH(BIT_11)
$       READ/ERROR=PROCESS INPUT_FILE BIT_12
$       IF( F$LENGTH(BIT_12) .GT. MAX_SIZE )THEN MAX_SIZE = F$LENGTH(BIT_12)
$!
$ PROCESS:
$       PRINT_CHAR = PRINT_CHAR + 1
$       UP_STRING = ""
$       LO_STRING = ""
$       WRITE SYS$OUTPUT "Working on character ",PRINT_CHAR
$!
$ LOOP:
$       LOOP_VAR = LOOP_VAR + 1
$       UPCHAR_NUM = 0
$       IF (LOOP_VAR .GT. MAX_SIZE)THEN GOTO NEXT_LINE
$       IF (F$EXTRACT(LOOP_VAR-1,1,BIT_1) .EQS. "*") THEN UPCHAR_NUM =
UPCHAR_NU
M + 1
$       IF (F$EXTRACT(LOOP_VAR-1,1,BIT_2) .EQS. "*") THEN UPCHAR_NUM =
UPCHAR_NU
M + 2
$       IF (F$EXTRACT(LOOP_VAR-1,1,BIT_3) .EQS. "*") THEN UPCHAR_NUM =
UPCHAR_NU
M + 4
$       IF (F$EXTRACT(LOOP_VAR-1,1,BIT_4) .EQS. "*") THEN UPCHAR_NUM =
UPCHAR_NU
M + 8
$       IF (F$EXTRACT(LOOP_VAR-1,1,BIT_5) .EQS. "*") THEN UPCHAR_NUM =
UPCHAR_NU
M + 16
$       IF (F$EXTRACT(LOOP_VAR-1,1,BIT_6) .EQS. "*") THEN UPCHAR_NUM =
UPCHAR_NU
M + 32
$       UP_STRING = UP_STRING + F$EXTRACT(UPCHAR_NUM+28,1,ALPHABET)
$       LOCHAR_NUM = 0
$       IF (F$EXTRACT(LOOP_VAR-1,1,BIT_7) .EQS. "*") THEN LOCHAR_NUM =
LOCHAR_NU
M + 1
$       IF (F$EXTRACT(LOOP_VAR-1,1,BIT_8) .EQS. "*") THEN LOCHAR_NUM =
LOCHAR_NU
M + 2
$       IF (F$EXTRACT(LOOP_VAR-1,1,BIT_9) .EQS. "*") THEN LOCHAR_NUM =
LOCHAR_NU
M + 4
$       IF (F$EXTRACT(LOOP_VAR-1,1,BIT_10) .EQS. "*") THEN LOCHAR_NUM =
LOCHAR_N
UM + 8
$       IF (F$EXTRACT(LOOP_VAR-1,1,BIT_11) .EQS. "*") THEN LOCHAR_NUM =
LOCHAR_N
UM + 16
$       IF (F$EXTRACT(LOOP_VAR-1,1,BIT_12) .EQS. "*") THEN LOCHAR_NUM =
LOCHAR_N
UM + 32
$       LO_STRING = LO_STRING + F$EXTRACT(LOCHAR_NUM+28,1,ALPHABET)
$       IF (LOOP_VAR/15*15 .NE. LOOP_VAR) THEN GOTO LOOP
$!
$ NEXT_LINE:
$       PRINT_STRING = PRINT_STRING + F$EXTRACT(PRINT_CHAR-1,1,ALPHABET)
$       CHAR_NUM = PRINT_CHAR+2
$       WRITE OUTPUT_FILE
"P1;",CHAR_NUM,";1;0;0;2;12{1",UP_STRING,"/",LO_STRING,"\[A"
$       IF (LOOP_VAR .LT. MAX_SIZE)THEN GOTO PROCESS
$       PRINT_STRING = PRINT_STRING + "!"
$       GOTO READ
$!
$ DONE:
$       ELEMENT = 0
$!
$ FINAL_LOOP:
$       OUT_STRING = F$ELEMENT(ELEMENT,"!",PRINT_STRING)
$       IF (OUT_STRING .EQS. "" )THEN GOTO EXIT
$       IF(DIS_MODE.EQS."N")THEN $WRITE OUTPUT_FILE ")1",OUT_STRING,")1"
$       IF(DIS_MODE.EQS."W")THEN $WRITE OUTPUT_FILE "#6)1",OUT_STRING,")1"
$       IF(DIS_MODE.EQS."H")THEN $WRITE OUTPUT_FILE "#3)1",OUT_STRING,")1"
$       IF(DIS_MODE.EQS."H")THEN $WRITE OUTPUT_FILE "#4)1",OUT_STRING,")1"
$       ELEMENT = ELEMENT + 1
$       GOTO FINAL_LOOP
$!
$ NO_INFILE:
$       WRITE SYS$OUTPUT "Input file ''IN_FILE' does not exist"
$       GOTO GET_INFILE_NAME
$!
$ ALREADY:
$       INQUIRE CONTIN "Output file ''OUT_FILE' already exists, replace?
(Y/N)"
$       IF (CONTIN .EQS. "Y")THEN GOTO GET_DISPLAY_MODE
$       IF (CONTIN .EQS. "N")THEN GOTO GET_OUTFILE_NAME
$       GOTO ALREADY
$!
$ EXIT:
$       CLOSE INPUT_FILE
$ EXIT1:
$       CLOSE OUTPUT_FILE
$       TYPE=""
$       TYPE 'OUT_FILE
$       EXIT


---
 * Origin: King Diamond's Realm - 516-736-3403 (1:107/2001)
--  
 Abe Suleiman - Internet:  Abe.Suleiman@f2001.n107.z1.ieee.org


