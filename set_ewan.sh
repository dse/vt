# !/usr/bin/csh
#
# vt100|vt100-am|dec vt100 (w/advanced video),
#
setenv TERMCAP 'am, cols#98, lines#28, msgr, xenl, xon, it#8, vt#3, acsc=``aaffggjjkkllmmnnooppqqrrssttuuvvwwxxyyzz{{||}}~~, bel=^G, blink=\E[5m$<2>, bold=\E[1m$<2>, clear=\E[H\E[J$<50>, cr=^M, csr=\E[%i%p1%d;%p2%dr, cub=\E[%p1%dD, cub1=^H, cud=\E[%p1%dB, cud1=^J, cuf=\E[%p1%dC, cuf1=\E[C$<2>, cup=\E[%i%p1%d;%p2%dH$<5>, cuu=\E[%p1%dA, cuu1=\E[A$<2>, ed=\E[J$<50>, el=\E[K$<3>, el1=\E[1K$<3>, enacs=\E(B\E)0, home=\E[H, ht=^I, hts=\EH, ind=^J, ka1=\EOq, ka3=\EOs, kb2=\EOr, kbs=^H, kc1=\EOp, kc3=\EOn, kcub1=\EOD, kcud1=\EOB, kcuf1=\EOC, kcuu1=\EOA, kent=\EOM, kf0=\EOy, kf1=\EOP, kf10=\EOx, kf2=\EOQ, kf3=\EOR, kf4=\EOS, kf5=\EOt, kf6=\EOu, kf7=\EOv, kf8=\EOl, kf9=\EOw, rc=\E8, rev=\E[7m$<2>, ri=\EM$<5>, rmacs=^O, rmam=\E[?7l, rmkx=\E[?1l\E>, rmso=\E[m$<2>, rmul=\E[m$<2>, rs2=\E>\E[?3l\E[?4l\E[?5l\E[?7h\E[?8h, sc=\E7, sgr=\E[0%?%p1%p6%|%t;1%;%?%p2%t;4%;%?%p1%p3%|%t;7%;%?%p4%t;5%;m%?%p9%t\016%e\017%;, sgr0=\E[m\017$<2>, smacs=^N, smam=\E[?7h, smkx=\E[?1h\E=, smso=\E[7m$<2>, smul=\E[4m$<2>, tbc=\E[3g, mir, dch1=\E[P, dl1=\E[M, il1=\E[L, rmir=\E[4l, smir=\E[4h'


# Ordinary vt100 in 132 column ("wide") mode.
#vt100-w|vt100-w-am|dec vt100 132 cols (w/advanced video),
#	cols#132, lines#24,
#	rs2=\E>\E[?3h\E[?4l\E[?5l\E[?8h, use=vt100-am,
#vt100-w-nam|vt100-nam-w|dec vt100 132 cols (w/advanced video no automargin),
#	cols#132, lines#14, vt@,
#	rs2=\E>\E[?3h\E[?4l\E[?5l\E[?8h, use=vt100-nam,
#
# vt100 with no advanced video.
#vt100-nav|vt100 without advanced video option,
#	xmc#1,
#	blink@, bold@, rev@, rmso=\E[m, rmul@, sgr@, sgr0@,
#	smso=\E[7m, smul@, use=vt100,
#vt100-nav-w|vt100-w-nav|dec vt100 132 cols 14 lines (no advanced video option),
#	cols#132, lines#14, use=vt100-nav,
#
#
# Most of the `vt100' emulators out there actually emulate a vt102
# This entry (or vt102-nsgr) is probably the right thing to use for
# these.
#vt102|dec vt102,
#	mir,
#	dch1=\E[P, dl1=\E[M, il1=\E[L, rmir=\E[4l,
#	smir=\E[4h, use=vt100,
#vt102-w|dec vt102 in wide mode,
#	lines#132,
#	rs3=\E[?3h, use=vt102,
#
# Many brain-dead PC comm programs that pretend to be `vt100-compatible'
# fail to interpret the ^O and ^N escapes properly.  Symptom: the <sgr0>
# string in the canonical vt100 entry above leaves the screen littered
# with little  snowflake or star characters (IBM PC ROM character \017 = ^O)
# after highlight turnoffs.  This entry should fix that, and even leave
# ACS support working, at the cost of making multiple-highlight changes
# slightly more expensive.
# From: Eric S. Raymond <esr@snark.thyrsus.com> July 22 1995
#
#vt102-nsgr|vt102 no sgr (use if you see snowflakes after highlight changes),
#	sgr@, sgr0=\E[m, use=vt102,
#
#### VT100 emulations
#
# John Hawkinson <jhawk@MIT.EDU> tells us that the EWAN telnet for Windows
# (the best Windows telnet as of September 1995) presents the name `dec-vt100'
# to telnetd.  We'll guess that it's vt102-like but doesn't grok ^N/^O.
#dec-vt100-80|ewan|EWAN telnet's vt100 emulation,
#	use=vt102-nsgr,
#
#dec-vt100|ewanbig|EWAN telnet's vt100 with expanded display,
#	cols#98, lines#29,
#	use=vt102-nsgr,
#
# _____________________________________________________________________________

