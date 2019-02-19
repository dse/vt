/*********************************************************************/
/*                                                                   */
/*  Title:       dpview.c                                            */
/*                                                                   */
/*  URL:      http://www.cs.latrobe.edu.au/~yuand/ansi_c/dpview.html */
/*                                                                   */
/*  Comments:    This program takes the input of a Postcript file,   */
/*               converts the codes in it to plain text which is     */
/*               displayed and re-directable.                        */
/*                                                                   */
/*  Author:      David Yuan <yuand@latcs1.lat.oz.au>                 */
/*                                                                   */
/*  Date Created:   19/04/1996                                       */
/*                                                                   */
/*  Date Last Modified:    16/06/1996                                */
/*                                                                   */
/*  Copyright 1997 David Yuan                                        */
/*  Permission of distribution is granted, provided no alternation,  */
/*       commenting or modification is made towards any parts of     */
/*       the source code and the binary code.                        */
/*                                                                   */
/*********************************************************************/

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include "file_handle.c"
#include "fggets.c"

#define INDICATOR_STR1         "%%EndSetup"             /* First string to be s
earched */
#define INDICATOR_STR2         "%%Page"                 /* Second string to be
searched */

#define SPACE_CHAR             0x20                     /* space character */
#define NULL_CHAR              0x0                      /* null character */
#define BACK_SLASH             '\\'                     /* back slash character
 */
#define L_BRACKET              '('                      /* left bracket charact
er */
#define R_BRACKET              ')'                      /* right bracket charac
ter */
#define S_QUOTE                '\''                     /* single quotation mar
k */
#define D_QUOTE                '"'                      /* double quotation mar
k */

#define TRUE                   1                        /* Logical constant */
#define FALSE                  0                        /* Logical constant */

#define KILO_BYTE              1024                     /* machine related cons
tant */
#define MAX_STR_LEN            512                      /* Longest length of st
ring allowed */
#define MAX_BUFR_SIZE          (KILO_BYTE * 16)         /* Define 16KB buffer s
ize for */
                                                        /* both input and outpu
t file  */

#define output_line(x)                                  fprintf(outf, "%s\n", (
x))
#define output_line_break                               fprintf(outf, "\n")
#define output_line_without_line_break(x)               fprintf(outf, "%s", (x)
)

#ifndef __BORLANDC__
  char inbufr[MAX_BUFR_SIZE];                           /* reserve space for in
put file buffers */
  char outbufr[MAX_BUFR_SIZE];                          /* reserve space for ou
tput file buffers */
#endif

typedef int BOOL;                                       /* Define boolean type
*/

FILE *inf;                                              /* handle of input file
 */
FILE *outf;                                             /* handle of output fil
e */
FILE *errf;                                             /* handle of error log
file */

char Linebuff[MAX_STR_LEN];                             /* pre-allocated input
line buffer */
char Outbuff[MAX_STR_LEN];                              /* pre-allocated output
 line buffer */
char Indcbuff[MAX_STR_LEN];                             /* pre-allocated string
 buffer */
char Sub_string[MAX_STR_LEN];                           /* pre-allocated string
 buffer */
char * pLinebuff;                                       /* pointer to input lin
e buffer */
char * pOutbuff;                                        /* pointer to output li
ne buffer */
char * pIndcbuff;                                       /* pointer to string bu
ffer */
char * pSubstr;                                         /* pointer to another s
tring buffer */

int  pageno = 0;                                        /* page number to be in
serted into the page break */
int  done = 0;                                          /* indicator for end of
 line */

BOOL dp_error = FALSE;                                  /* boolean variable */
                                                        /* when error happens i
t is set to be TRUE */
BOOL supress_page_break = FALSE;                        /* variable to decide w
hether */
                                                        /* output page break or
 not */

/* close all opened files */
/* write message to error log if necessary */
void closefiles(void)
{
  fclose(inf);
  fclose(outf);
  if (!dp_error) fprintf(errf, "\nNo error.\n");
  fclose(errf);
}

/* display and write to error log file a message about non-Postscript format */
void msgNonPS(void)
{
  printf("\nError-->Non-Postcript input file.\n\n");
  fprintf(errf, "\nError-->Non-Postcript input file.\n\n");
  closefiles();
  exit(-9);
}

/* writes a page break into output file */
void output_page_break()
{
  pageno++;
  if (!supress_page_break)
    fprintf(outf, "\n\n============================  Page %i  =================
==========\n\n\n", pageno);
  return;
}

/* copy characters between two pointers: p1 and p2 */
/* to the location starting: p0 */
/* if p2 is pointed to an address smaller than p1 */
/* this loop will terminate and NULL string returned */
char * getSubstring(char * p0, char * p1, char * p2)
{
  char * temp1;
  char * temp2;

  /* copy characters */
  temp1 = p0;
  temp2 = p1;

  /* terminate if p1 is pointed address after p2 */
  if (p1 <= p2)
  {
     if (p1[0] == L_BRACKET)
     {
       /* search until right bracket is found */
       while ((temp2[0] != R_BRACKET) && (temp2[0] != NULL_CHAR)) {
         temp1[0] = temp2[0];
         temp1++;
         temp2++;
       }
       /* do not forget to copy the character pointed by: p2 */
       temp1[0] = temp2[0];
     }
     else
     {
       /* just find the next space or EOL character */
       while (temp2 != p2) {
         temp1[0] = temp2[0];
         temp1++;
         temp2++;
       }
       /* do not forget to copy the character pointed by: p2 */
       temp1[0] = temp2[0];
     }
  }

  (++temp1)[0] = NULL_CHAR;
  (++temp1)[0] = NULL_CHAR;
  return temp2;
}

/* analyze the line read-in from input file */
/* source line pointer passed in by char * s1 */
/* pointer analyzed line stored and passed out by char * s2 */
int analyze_line(char * s1, char * s2)
{
  int RC = 0;
  char * c1;
  char * c2;
  char * c3;
  char * c4;
  char * c5;
  int  n_ptr;
  char numero[MAX_STR_LEN];

  c1 = s1;
  c2 = s2;
  /* set the analyze result string to be blank */
  c2[0] = NULL_CHAR;
  c2[1] = NULL_CHAR;
  /* handle comment lines */
  /* in Postscript, comment lines start with two percentage signs: "%%" */
  if (strstr(c1, "%%") == c1) return RC;

  while (c1[0])
  {
    /* skip spaces and TAB keys */
    c3 = c1;
    while ((c3[0] <= SPACE_CHAR) && (c3[0])) c3++;
    /* at the end of input string */
    if (!c3[0])
    {
      if (strlen(s2) > 0)
      {
        output_line_without_line_break(s2);
        c2 = s2;
        s2 = NULL_CHAR;
      }
      break;
    }
    /* starting of a word */
    c1 = c3;
    if (c1[0] != L_BRACKET)
    {
      if (c1[0] == R_BRACKET)
      {
        while ((c1[0] == SPACE_CHAR) || (c1[0] == R_BRACKET)) c1++;
        c3 = c1;
      }

      while ((c3[0] > SPACE_CHAR) && (!c3[0])
          && (c3[0] != L_BRACKET) && (c3[0] != R_BRACKET)) c3++;
      c3--;

      /* getting of a sub-string */
      c3 = getSubstring(pSubstr, c1, c3);
    }
    else
    {
      while ((c3[0] > SPACE_CHAR) && (!c3[0]) && (c3[0] != R_BRACKET))
      {
        if (c3[0] != BACK_SLASH)
          c3++;
        else
        {
          c3++;
          c3++;
        }
      }
      /* getting of a sub-string */
      c3 = getSubstring(pSubstr, c1, c3);
    }
    /* update current char pointer */
    c1 = c3;
    c1++;

    /* discriminate the token read-in */
    switch (strlen(pSubstr))
    {
      case 0: break;
      case 1: {
                switch (pSubstr[0])
                {
                  case 'y':
                  case 'T':
                  case 'P':
                  case 'Q':
                  {
                    c2[0] = NULL_CHAR;
                    if (strlen(s2) > 0)
                      output_line(s2);
                    else
                      output_line_break;

                    if (pSubstr[0] == 'Q')
                      output_line_break;

                    c2 = s2;
                    s2[0] = NULL_CHAR;
                    s2[1] = 0;
                    break;
                  }

                  case 'b':
                  case 'c':
                  case 'd':
                  case 'e':
                  case 'f':
                  case 'g':
                  case 'h':
                  case 'i':
                  case 'j':
                  case 'k':
                  {
                    /* between 'b' and 'k' */
                    c2[0] = SPACE_CHAR;
                    c2++;
                    c2[0] = NULL_CHAR;
                    break;
                  }
                }
              }
      default: {
                if (strcmp(pSubstr, "eop") == 0)
                {
                  if (strlen(s2) > 0)
                    output_line(s2);
                  c2 = s2;
                  s2[0] = NULL_CHAR;
                  s2[1] = NULL_CHAR;
                  output_page_break();
                  break;
                }

                /* a displayable word entered */
                if ((pSubstr[0] == L_BRACKET) && (pSubstr[strlen(pSubstr)-1] ==
 R_BRACKET))
                {
                  if (strchr(pSubstr, SPACE_CHAR) != NULL)
                  {
                    if (strstr(pSubstr, "(Error: )") != NULL) break;

                    if (strstr(pSubstr, "(converted error name will end") != NU
LL) break;

                    if (strstr(pSubstr, "(converted stack will end") != NULL) b
reak;

                    if (strstr(pSubstr, "(Stack: )") != NULL) break;

                    if (strstr(pSubstr, "(Incompatable color bitimage") != NULL
) break;

                    if (strstr(pSubstr, "(Offending Command:") != NULL) break;

                  }
                  c4 = pSubstr + 1;
                  while (!c4[0])
                  {
                    switch (c4[0])
                    {
                      case R_BRACKET:
                             c2[0] = 0;
                             c2--;
                             break;
                      case BACK_SLASH:
                             c4++;
                             if (!isdigit(c4[0]))
                               c2[0] = c4[0];
                             else
                             /* handle number */
                             {
                               c5 = c4;
                               n_ptr = 0;
                               while ((isdigit(c5[0])) && (n_ptr < 3)) {
                                 numero[n_ptr++] = c5[0];
                                 c5++;
                               }
                               numero[n_ptr] = 0;
                               switch (atoi(numero))
                               {
                                 case 13:
                                   (c2++)[0] = 'f';
                                   c2[0] = 'f';
                                   break;
                                 case 14:
                                 case 336:
                                   (c2++)[0] = 'f';
                                   c2[0] = 'i';
                                   break;
                                 case 322:
                                 case 323:
                                   c2[0] = D_QUOTE;
                                   break;
                                 case 324:
                                 case 325:
                                   c2[0] = S_QUOTE;
                                   break;
                                 case 134:
                                   c2[0] = BACK_SLASH;
                                   break;
                                 case 50:
                                   c2[0] = L_BRACKET;
                                   break;
                                 case 51:
                                   c2[0] = R_BRACKET;
                                   break;
                                 case 245:
                                   (c2++)[0] = '+';
                                   c2[0] = SPACE_CHAR;
                                   break;
                                 default:c2[0] = (char) atoi(numero);
                               }
                               c4 = c5 - 1;
                             }
                             break;
                      default:
                             c2[0] = c4[0];
                             break;
                      }
                    }

                    c2++;
                    c4++;
                    c2[0] = NULL_CHAR;
                  break;
                }

                break;
              }
    }     /* the biggest switch statement in this program */
  }

  /* flush line buffer if it is not empty */
  if (strlen(s2) > 0)
    output_line_without_line_break(s2);
  s2[0] = NULL_CHAR;
  s2[1] = NULL_CHAR;
  return RC;
}

/* to check the first line of the file to tell  */
/* if it is a Postscript formatted file */
void verifyPostscript(void)
{
  /* read one non-blank line */
  do {
    fggets(pLinebuff, 1024, &done, inf);
  } while (!strlen(pLinebuff));
  /* check the Postscript indicator */
  if (strstr(pLinebuff, "%!PS") != pLinebuff)
    msgNonPS();
  else
    return;
}

/* to display usage on the stdio */
/* argument name is the program name */
void displayUsage(char * name)
{
  char * ptr;
  char * nameptr;
  char nname[100];

  strcpy(nname, name);
  /* find the last back slash character */
  ptr = strrchr(nname, BACK_SLASH);
  if (ptr)
    nameptr = ++ptr;
  else
    nameptr = name;

#ifdef __BORLANDC__
  /* find the dot, then put a NULL-CHARACTER at that place */
  ptr = strrchr(nname, '.');
  if (ptr) ptr[0] = NULL;
#endif

#ifdef MSDOS
  /* find the dot, then put a NULL-CHARACTER at that place */
  if (ptr = strrchr(nname, '.')) ptr[0] = NULL_CHAR;
#endif

  printf("\nUsage: %s PS-file-name [ -b ]", nameptr);
  printf("\n       (dump content of PS file onto the screen.)");
  printf("\n\noptional -b: suppress page-break within output");
  printf("\n\nother usage: %s PS-file-name [ -b ] > Text-file-name", nameptr);
  printf("\n\n             %s PS-file-name [ -b ] | more", nameptr);
  printf("\n\nCopyright: David Yuan (C), Deakin University, May, 1996.\n\n");
  fprintf(errf, "\nError-->No argument is supplied.\n\n");
  fclose(errf);
}

/* Main body of the program */

void main(int argCount, char **argument)
{
  /* to reserve space for both input and output file buffers */
#ifdef __BORLANDC__
  char inbufr[MAX_BUFR_SIZE];
  char outbufr[MAX_BUFR_SIZE];
#endif

  /* To set up pointers to the text buffers,  */
  /* such arrangement make sure the program to be simple and fast */
  /* no malloc() or free() function call is necessary */
  /* set every bytes in these strings to be NULL char as precaution */
  pLinebuff = (char *) (&Linebuff);
  memset(pLinebuff, NULL_CHAR, MAX_STR_LEN - 1);
  pOutbuff = (char *) (&Outbuff);
  memset(pOutbuff, NULL_CHAR, MAX_STR_LEN - 1);
  pIndcbuff = (char *) (&Indcbuff);
  memset(pIndcbuff, NULL_CHAR, MAX_STR_LEN - 1);
  pSubstr = (char *) (&Sub_string);
  memset(pSubstr, NULL_CHAR, MAX_STR_LEN - 1);

  /* pre-open the error log file */
  errf = fopen("DPVIEW.ERROR", TEXT_WRITE);

  /* handles arguments of the program */
  /* display usage information if wrong number of arguments given */
  if ((argCount < 2) || (argCount > 4))
  {
    displayUsage(argument[0]);
    exit(0);
  }

  /* supress string */
  if ((strcmp(argument[2], "-b") == 0)) supress_page_break = TRUE;

  /* check the existance of the input file */
  if (argCount >= 2)
  {
    if ((inf = fopen(argument[1], TEXT_READ)) == NULL)
    {
      printf("\nError-->File:  %s  can not be opened.\n\n", argument[1]);
      fprintf(errf, "\nError-->File:  %s  can not be opened.\n\n", argument[1])
;
      fclose(inf);
      fclose(errf);
      exit(-1);
    }
    else
    {
    /* attempt to set up input file buffer */
      if ((setvbuf(inf, (char *)(&inbufr), _IOLBF, MAX_BUFR_SIZE)) != 0)
      {
        printf("\nError-->System memory too low to execute program.\n\n");
        fprintf(errf, "\nError-->System memory too low to execute program.\n\n"
);
        fclose(inf);
        fclose(errf);
        exit(-5);
      }
      else
        verifyPostscript();
    }
  }

  /* dump output to screen */
  outf = (FILE *) (stdout);

  /* read in input file line by line */
  /* until the first indicator string is found */
  strcpy(pIndcbuff, INDICATOR_STR1);
  while (!done)
  {
    fggets(pLinebuff, 1024, &done, inf);
    if (strstr(pLinebuff, pIndcbuff) != NULL)
    {
      if ((feof(inf))) done = 1;
      break;
    }
  }

  /* read in input file line by line */
  /* until the second indicator string is found */
  /* The real PS text content begins from the next line */
  strcpy(pIndcbuff, INDICATOR_STR2);
  while (!done)
  {
    fggets(pLinebuff, 1024, &done, inf);
    if (strstr(pLinebuff, pIndcbuff) != NULL)
    {
      if ((feof(inf))) done = 1;
      break;
    }
  }

  /* read in input file line by line */
  /* analyze it and output plain text into output file */
  do {
    fggets(pLinebuff, 1024, &done, inf);
    analyze_line(pLinebuff, pOutbuff);
    if ((feof(inf))) done = 1;
  } while (!done);

  /* close input, output and error log files */
  closefiles();

  return;

}

/* End of main body of the program */
