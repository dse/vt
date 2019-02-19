$!  PROMPT.COM for VMS.
$!  Obtained at Queen City DECUS LUG 26 October A.D. 1988.
$!
$!  This routine works only on VT220 or later terminals that have "soft
$!  characters".  On a VT300, the characters do not look as pretty.
$!  Invoke it with an integer argument to choose the prompt, e.g.,
$!
$!    $ @prompt 1
$!
$ IF (F$GETDVI("TT","TT_DRCS") .EQ. "FALSE") THEN EXIT   ! Can't do it.
$! 
$   cr[0,8] = 13
$  esc[0,8] = 27
$   lf[0,8] = 10
$  dcs      = "''esc'P"
$  off      = "''esc'[0m"
$ bold      = "''esc'[1m"
$  say      = "write sys$output"
$!
$!  The following device-control codes work only in an 8-bit environment.
$!  Comment them out if you use 7-bit communication links.
$! 
$  csi[0,8] = 155
$  off      = "''csi'm"
$ bold      = "''csi'1m"
$!
$ proceed:
$!
$ howmany   = 4
$!
$! If the first parameter is a valid number, go change the prompt.
$!
$ if p1 .ge. 1 .and. p1 .le. howmany then gosub 'p1'
$!
$ type/page nl:                                 ! clear screen
$ EXIT                                                  ! all done
$!
$!#############################################################################
$!
$! Gator
$! The slogan was requested by Bill Edwards, a Florida graduate.
$  1:
$ say "''dcs'1;65;1{#1w{}q__o_/???@@@@@;o___o__o/@@@@@@@@;"
$ say                "WWoo_GWo/B??FNGGB;wwooowwo/BBBBBBBB;WWoo_GWw/B??FNGGB;"
$ say                "{kKSSSSW/@@@BAABA;WGGWGGWK/BAABAABA;WG??????/BA??????;"
$ say "''esc'\"
$ set prompt = "''bold'''esc'(#1abcddefgh''esc'(B ''off'"
$!set prompt = "''bold'''esc'(#1abcddefgh''esc'(BGo Gators! ''off'"
$ RETURN
$! 
$!  Snoopy
$ 2:
$ say "''dcs'1;65;1{#1??__OOGG/??@@IIKK;CCCCGGOO/NN????II;"
$ say                "________/????????;????????/HHEEAA??;bbVVVVJJ/@@AACCCC;"
$ say                "EEwwEEGG/DDCCCCEE;pp@@@@@@/FFEEDDDD;????????/DDEE????;"
$ say "''esc'\"
$ set prompt = "''bold'''esc'(#1abcd''cr'''lf'efgh''esc'(B''off'"
$ RETURN
$! 
$!  Enterprise
$ 3:
$ say "''dcs'1;65;1{#1OOooOOoo/??@@@@@@;OOooOOoo/@@@@@@@@;"
$ say                "OOooo???/BFLG@???;????????/????????;?????___/???@@JMM;"
$ say                "________/FBAABAAB;oogoo___/AABAABAA;_______?/BAABA@@@;"
$ say                "????????/????????;????????/????????;?{]]~}cc/????????;"
$ say                "{cc{cc{c/????????;c{ce{rr{/????????;{{{{g???/????????;"
$ say                "????????/????????;????????/????????;"
$ say "''esc'\"
$ set prompt = "''bold'''esc'(#1abcdefgh''cr'''lf'ijklmno''esc'(B''off'"
$ RETURN
$! 
$!  Woodstock
$ 4:
$ say "''dcs'1;65;1{#1OO__GGOO/GGCCDDEE;aa{{__OO/LL????@@;"
$ say                "gggggg??/AACCCCDD;????????/CCGG????;CCAAHHDD/????KKBB;"
$ say                "QQKKOO'`/????????;OOOOOOOO/@@MM????;OOGGFF??/????????;"
$ say "''esc'\"
$ set prompt = "''bold'''esc'(#1abcd''cr'''lf'efgh''esc'(B''off'"
$ RETURN
$!############################################################################
