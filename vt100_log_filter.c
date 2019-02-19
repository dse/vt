Article 3482 of comp.terminals:
Path: cs.utk.edu!emory!swrinde!hookup!news.mathworks.com!transfer.stratus.com!xylogics.com!Xylogics.COM!carlson
From: carlson@Xylogics.COM (James Carlson)
Newsgroups: comp.terminals
Subject: Re: Logging vt100 output to a file without escape sequences
Date: 25 Jan 1995 12:53:04 GMT
Organization: Xylogics Incorporated
Lines: 158
Distribution: world
Message-ID: <3g5hjg$re2@newhub.xylogics.com>
References: <2250002@hpcc01.corp.hp.com>
Reply-To: carlson@xylogics.com
NNTP-Posting-Host: newhub.xylogics.com

In article <2250002@hpcc01.corp.hp.com>, cfoster@hpcc01.corp.hp.com (Craig E Foster) writes:
|> 
|> 
|> I am trying to log the output from a vt100 type device without the
|> special escape sequences being included.
|> 
|> When using:
|>  xterm -tn vt100 -l -lf log_file
|> The log file contains all of the escape sequences and isn't readable 
|> except on another vt100 display. I have tried to use nroff and several
|> other unix commands to strip the escape codes, but I have had no
|> success.
|> 
|> Does anyone know of
|>   a)  A terminal emulator that will log output without the special sequences.
|> or
|>   b)  A program or application that will strip special sequences from a
|>       log file containing them.

Such a filter would be fairly trivial to write:

#include <stdio.h>

#define BEL	0x07
#define BS	0x08
#define TAB	0x09
#define LF	0x0A
#define VT	0x0B
#define FF	0x0C
#define CR	0x0D
#define SO	0x0E
#define SI	0x0F
#define CAN	0x18
#define SUB	0x1A
#define ESC	0x1B
#define SS2	0x8E
#define SS3	0x8F
#define DCS	0x90
#define CSI	0x9B
#define ST	0x9C
#define OSC	0x9D
#define PM	0x9E
#define APC	0x9F

enum {
	Normal, Esc, Csi, Dcs, DcsString, DropOne
} vtstate = Normal;

void
filter_out_vt(fp)
FILE *fp;
{
	int chr;

	while ((chr = getc(fp)) != EOF) {
		chr &= 0xFF;
		if (vtstate == DropOne) {
			vtstate = Normal;
			continue;
		}
		/* Handle normal ANSI escape mechanism */
		/* (Note that this terminates DCS strings!) */
		if (vtstate == Esc && chr >= 0x40 && chr <= 0x5F) {
			vtstate = Normal;
			chr += 0x40;
		}
		switch (chr) {
		case CAN:
		case SUB:
			vtstate = Normal;
			break;
		case ESC:
			vtstate = Esc;
			break;
		case CSI:
			vtstate = Csi;
			break;
		case DCS:
		case OSC:		/* VT320 commands */
		case PM:
		case APC:
			vtstate = Dcs;
			break;
		default:
			if ((chr & 0x6F) < 0x20) { /* Check controls */
				switch (chr) {
	/* VT oddity -- controls go through regardless of state. */
				case BEL:	/* Pass these through */
				case BS:
				case TAB:
				case LF:
				case VT:
				case FF:
				case CR:
					putchar(chr);
					break;
				}
				break;
			}
			switch (vtstate) {
			case Normal:
				putchar(chr);
				break;
			case Esc:
				vtstate = Normal;
				switch (chr) {
				case 'c': case '7': case '8':
				case '=': case '>': case '~':
				case 'n': case '\123': case 'o':
				case '|':
					break;
				case '#': case ' ': case '(':
				case ')': case '*': case '+':
					vtstate = DropOne;
					break;
				}
				break;
			case Csi:
			case Dcs:
				if (chr >= 0x40 && chr <= 0x7E)
					if (vtstate == Csi)
						vtstate = Normal;
					else
						vtstate = DcsString;
				break;
			case DcsString:
				/* Just drop everything here */
				break;
			}
		}
	}
}

int
main(argc,argv)
int argc;
char **argv;
{
	char *arg;
	FILE *fp;

	if (argc <= 1)
		filter_out_vt(stdin);
	else
		while ((arg = *++argv) != NULL)
			if ((fp = fopen(arg,"r")) == NULL)
				perror(arg);
			else {
				filter_out_vt(fp);
				fclose(fp);
			}
	return 0;
}

---
James Carlson <carlson@xylogics.com>            Tel:  +1 617 272 8140
Annex Software Support / Xylogics, Inc.               +1 800 225 3317
53 Third Avenue / Burlington MA  01803-4491     Fax:  +1 617 272 2618


