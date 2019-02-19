
From scoth@wolfenet.com Tue Feb 25 09:58:12 1997
Path: stc06.ctd.ornl.gov!fnnews.fnal.gov!uwm.edu!cs.utexas.edu!math.ohio-state.edu!howland.erols.net!cam-news-hub1.bbnplanet.com!su-news-hub1.bbnplanet.com!news.bbnplanet.com!newsout1.alt.net!news1.alt.net!news.aa.net!ratty.wolfe.net!usenet
From: "Scot Harkins" <scoth@wolfenet.com>
Newsgroups: comp.unix.admin,comp.unix.aix,comp.unix.sco.misc,comp.unix.sco.programmer,comp.unix.shell
Subject: Re: Addressing dumb terminals
Date: 25 Feb 1997 02:30:50 GMT
Organization: Thurman Ind., Bothell, WA
Lines: 309
Message-ID: <01bc22c3$d25cde80$39629dcc@scoth>
References: <01bc1f48$9bb57c80$6d37989e@jqlr.demon.co.uk> <5ei2sr$216$3@research.Fresno.qnis.net>
NNTP-Posting-Host: sea-ts1-p03.wolfenet.com
X-Newsreader: Microsoft Internet News 4.70.1155
Xref: stc06.ctd.ornl.gov comp.unix.admin:59813 comp.unix.aix:101614 comp.unix.sco.misc:38340 comp.unix.sco.programmer:6094 comp.unix.shell:45651

Howdy,


As promised, albeit late.  I'm following this thread from
comp.unix.sco.misc, so I'm not sure what else has been said.  I'll look
around to see what else has been said in case respondents did not cross
post.

This is a small family of shell scripts and a configuration file that
stores capabilities for different terminal types.  This is a rather dated
script for me; my scripting abilities have come up somewhat from the time I
wrote this.  I plan to revamp it and clean it up.  This version works fine
for the most part.  I just want cleaner scripts.

The principle is this:  A base script. called "blip.sh", takes the tty as
the first parameter and the remaining parameters as the message.  This
means blip.sh specifically targets one tty.  blip.sh echoes the message to
the target tty, using commands that move the cursor to the bottom (line x)
and turns on reverse (if available).  It turns off reverse at the end of
the echo.  Five seconds later it sends a completely clear line to the same
position, overwriting the displayed text.  A bell is included to draw
attention.  The true character position in any application is not
compromised; subsequent typing restores the cursor to it's real position.

blip.sh loads the screen capabilities from a small database, organized by
terminal type.  blip.sh first looks to /etc/ttytype to determine what the
terminal type should be/is, then obtains the capabilities from the
database.  blip.sh uses awk to perform these functions.  It is assumed that
/etc/ttytype is accurate.  If users are using pseudo tty's, such as from
mscreen (multiscreens) then those terminals should be in /etc/ttytype as
well.  If users are using various multiscreen emulations or are telnetting
with unlike emulations (one with wy50 and another with ansi), then we may
need to switch to a publicly editable file that get's updated when a user
logs in.

You can add to the database (screen.cfg) by using a utility called
"screen.setup".  By setting your TERM to the desired (new) entry and
running screen.setup you can create an entry for a new terminal type. 
Future revisions to screen.setup would allow supplying a term type as a
parameter.  Alternately, term types missing from screen.cfg could be built
on the fly using standard tset commands (which is what screen.setup uses). 
The database is faster, especially on system-wide messages.

A system wide messaging utility, "blip", will get the tty's for all users
logged in and supply the message to a copy of blip.sh by tty.  That means
if there are 40 active logins, 40 copies of blip.sh will be called by blip.
 Each instance of blip.sh is called and placed in the background.  blip
takes all subsequent parameters as the message, so 'blip "Get off the
system NOW!!!"' will send "Get off the system NOW!!!" to the bottom of each
user's screen for five seconds.

Variants of blip can be created to blip specific users (all screens), users
of certain applications (example provided), etc.  Each one would use a
different rule to determine where to send the messages (what tty's) then
call blip.sh for each of those tty's.

For mail users wanting notification, a variant can be created that will hit
all of the user's screens, or a user selectable screen, via the
.maildelivery file (for MMDF).  I do not know what sendmail would use for
such a notification (as in calling an external shell program).  I also do
no know if the command would be executed with the mail-daemon's uid (thus
requiring the user's screens to be publicly writable) or the user's id
(suid).  Users could be allowed to selectively set their screens to be
writable (mesg y); the calling script could then determine if it could
write the screen ( [ -w /dev/tty... ] ) before attempting to call blip.sh
for that tty.

Future enhancements (that I can think of off the top of my head) would
include: blip.sh would determine capability on the fly if the database
entry is missing or unreadable (perms).  It would also accept the tty as
either "/dev/ttyxxx" or "ttyxxx"; right now it takes only "ttyxxx" since
blip uses "who" which supplies only "ttyxxx".  blip would be interactive if
no parameters we supplied.  Some implementations of multiple screens (like
Stallion's sessions) run "stopio" on sessions in the background, making the
blip.sh for that tty "hang"; a modification to blip.sh would cause it to
die automatically after a set time.  blip would check to see if pseudo
tty's are tied to a controlling terminal (multi-screen) and only blip the
controlling terminal.  As I said, there's more than a few things I would
re-do.  I, too, would like to give my users the option to be safely
notified of incoming mail (or mail from the president of the company, or
whoever).

Okay, here's the shell scripts.  It's late for me to be here, and I'm
writing an awk script that is going to fix a data file problem, so this is
borrowed time.  Feel free to email me.  I'll be glad to help where I can. 
I'll also be glad to share the modified scripts if desired.  These are cut
and paste from a telnet window, so the lines do not end at the end of the
text.

---  /usr/bin/blip.sh  ---

#! /bin/sh                                                                 
    
                                                                           
    
# blip.sh: Prints message at bottom of user screen for five seconds, then
clears
.                                                                          
    
# $1 must be the tty.  The balance of the params are the message.          
    
                                                                           
    
settings() {                                                               
    
        TTYPE=`grep $1 /etc/ttytype|awk '{print $1}'|head -1`              
    
        LINES=`grep $TTYPE /usr/lib/screen.cfg|awk -F: '{print $2}'`       
    
        CLEAR=`grep $TTYPE /usr/lib/screen.cfg|awk -F: '{print $3}'`       
    
        BOFF=`grep $TTYPE /usr/lib/screen.cfg|awk -F: '{print $4}'`        
    
        REV=`grep $TTYPE /usr/lib/screen.cfg|awk -F: '{print $5}'`         
    
        ROFF=`grep $TTYPE /usr/lib/screen.cfg|awk -F: '{print $6}'`        
    
        BOTTOM=`grep $TTYPE /usr/lib/screen.cfg|awk -F: '{print $7}'`      
    
        export LINES CLEAR BOFF REV ROFF BOTTOM ;                          
    
        }                                                                  
    
                                                                           
    
TTY="$1";export TTY                                                        
    
shift                                                                      
    
MESSAGE="$*";export MESSAGE                                                
    
                                                                           
    
settings $TTY                                                              
    
                                                                           
    
echo "${BOTTOM}${REV}\07${MESSAGE} ${ROFF}\c" > /dev/$TTY                  
    
sleep 5                    
echo "${BOTTOM}            
            \c" > /dev/$TTY

--- end /usr/bin/blip.sh  ---

--- /usr/lib/screen.cfg ---
sample:LINES:CLEAR:BOFF:REV:ROFF:BOTTOM:                     
                                                             
ansi|ansic|et|easyterm:25:^[[2J^[[H:^[[m:^[[7m:^[[m:^[[25;1H:
                                                             
wy60|wy50:25:^[*:^[G0:^[G4:^[G0:^[a25R1C:                    
                                                             
tvi925:25:^Z:^[G0::^[G0:                                     
                                                             
vt100:25:^[[H^[[J:^[[m:^[[7m:^[[m:                           
--- end /usr/lib/screen.cfg ---

--- begin /usr/local/bin/blip.sh ---
#! /bin/sh                                                              
                                                                        
terms2hit() {                                                           
        TERMS=`who|awk '{print $2}'`;export TERMS ;                     
        }                                                               
                                                                        
settings() {                                                            
        TTYPE=`grep $1 /etc/ttytype|awk '{print $1}'|head -1`           
        LINES=`grep $TTYPE /usr/lib/screen.cfg|awk -F: '{print $2}'`    
        CLEAR=`grep $TTYPE /usr/lib/screen.cfg|awk -F: '{print $3}'`    
        BOFF=`grep $TTYPE /usr/lib/screen.cfg|awk -F: '{print $4}'`     
        REV=`grep $TTYPE /usr/lib/screen.cfg|awk -F: '{print $5}'`      
        ROFF=`grep $TTYPE /usr/lib/screen.cfg|awk -F: '{print $6}'`     
        BOTTOM=`grep $TTYPE /usr/lib/screen.cfg|awk -F: '{print $7}'`   
        export LINES CLEAR BOFF REV ROFF BOTTOM ;                       
        } # settings moved to blip.sh to make it stand alone.  sh 8-6-96
                                                                        
cycleterms() {                                                          
        for t in $TERMS                                                 
        do                                                              
#               Moved to blip.sh
#               settings $t                                             
#               echo "${BOTTOM}${REV}\07${MESSAGE} ${ROFF}\c" > /dev/$t 
#               sleep 5                                                 
#               echo "${BOTTOM}                            
  \c" > /dev/$t                                            
                /usr/bin/blip.sh $t $MESSAGE &             
        done ;                                             
        }                                                  
                                                           
if [ "$*" ]                                                
then                                                       
        MESSAGE="$*"                                       
else                                                       
        echo "Error: You must supply a message to display."
        sleep 2                                            
        exit 15                                            
fi                                                         
                                                           
terms2hit                                                  
cycleterms                                                 
--- end /usr/local/bin/blip ---


--- /usr/local/bin/synblip (an application specific variant)
#! /bin/sh                                                                 
   
                                                                           
   
terms2hit() {                                                              
   
        TERMS=`ps -ef|grep synrun|grep -v grep|awk '{print $6}'`;export
TERMS ;
        }                                                                  
   
                                                                           
   
settings() {                                                               
   
        TTYPE=`grep $t /etc/ttytype|awk '{print $1}'|head -1`              
   
        LINES=`grep $TTYPE /usr/lib/screen.cfg|awk -F: '{print $2}'`       
   
        CLEAR=`grep $TTYPE /usr/lib/screen.cfg|awk -F: '{print $3}'`       
   
        BOFF=`grep $TTYPE /usr/lib/screen.cfg|awk -F: '{print $4}'`        
   
        REV=`grep $TTYPE /usr/lib/screen.cfg|awk -F: '{print $5}'`         
   
        ROFF=`grep $TTYPE /usr/lib/screen.cfg|awk -F: '{print $6}'`        
   
        BOTTOM=`grep $TTYPE /usr/lib/screen.cfg|awk -F: '{print $7}'`      
   
        export LINES CLEAR BOFF REV ROFF BOTTOM ;                          
   
        }                                                                  
   
                                                                           
   
cycleterms() {                                                             
   
        for t in $TERMS                                                    
   
        do                                                                 
   
#               settings $t                                                
   
#               echo "${BOTTOM}${REV}\07${MESSAGE} ${ROFF}\c" > /dev/$t    
   
#               sleep 5                                                    
   
#               echo "${BOTTOM}                                            
    
  \c" > /dev/$t                                                            
    
#               synblip puts "tty" before $t because "ps" doesn't, whereas
"who"
 does.                                                                     
    
# 2-24-97: SCO-OSR5's ps -ef _does_ print "ttyxxx" in full, so "tty" should
be
# omitted in OSR5 versions.  Better yet, make the script intelligent enough
to
# figure the version out on it's own.
                /usr/bin/blip.sh tty$t $MESSAGE &                          
    
        done ;                                                             
    
        }                                                                  
    
                                                                           
    
if [ "$*" ]                                                                
    
then                                                                       
    
        MESSAGE="$*"                                                       
    
else                                                                       
    
        echo "Error: You must supply a message to display."                
    
        sleep 2                                                            
    
        exit 15                                                            
    
fi                                                                         
    
                                                                           
    
terms2hit                                                                  
    
cycleterms                                                                 
    
--- end /usr/local/bin/synblip ---

Hope these are helpful!  They're really quite messy (I think) as scripts
go.  It's almost embarrasing to look back at my earlier scripting.  It
worked but was not elegant.



Scot


-- 
Scot Harkins (KA5KDU) | Systems Administrator, Thurman Ind, Bothell, WA
North Bend, WA        | Native Texan.  Proud daddy and husband!
scoth@wolfenet.com    | SCA: Ld. Scot MacFin, herald at large, An Tir
scoth@scn.org/msn.com | URL <http://www.wolfenet.com/~scoth>


