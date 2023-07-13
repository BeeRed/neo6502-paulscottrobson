REM
REM
'
'"Star Trek"
'
CALL initialise()
CALL newsector()
CALL shortrange()
REPEAT
CALL command()
UNTIL 0
'
'"Set up everything"
'
PROC initialise()
klingons=0
stardate=RAND(200)+200
energy=3000:shields=0
torpedoes=15:startdate=stardate
DIM galaxy(7,7),quadrant(7,7)
FOR x1=0 TO 7
FOR y1=0 TO 7
newk=0:IF RAND(4)<>1 THEN newk=RAND(3)+1
news=0:IF RAND(7)=1 THEN news=1
galaxy(x1,y1)=newk*100+news*10+RAND(5)+1
klingons=klingons+newk
NEXT:NEXT
gx=RAND(8):gy=RAND(8)
qx=RAND(8):qy=RAND(8)
ENDPROC
'
'"create a new sector"
'
PROC newsector()
FOR x1=0 TO 7:FOR y1=0 TO 7
quadrant(x1,y1)=0
NEXT:NEXT
qx=qx AND 7:qy=qy AND 7
gx=gx AND 7:gy=gy AND 7
quadrant(qx,qy)=4
n=galaxy(gx,gy)MOD 10
c=3:CALL addquadrant()
n=galaxy(gx,gy)DIV 10 MOD 10
c=2:CALL addquadrant()
n=galaxy(gx,gy)DIV 100
khere=n
c=-200:CALL addquadrant()
ENDPROC
'
'"Add n obj of type c to quad"
'
PROC addquadrant()
WHILE n>0
REPEAT
x1=RAND(8):y1=RAND(8)
UNTIL quadrant(x1,y1)=0
quadrant(x1,y1)=c
n=n-1
WEND
ENDPROC
'
'"Short range scan"
'
PROC shortrange()
condition=1
IF khere>0 THEN condition=2
IF quadrant((qx-1)AND 7,qy)=2 THEN condition=3
IF quadrant((qx+1)AND 7,qy)=2 THEN condition=3
IF condition=3 THEN energy=3:shields=0:torpedoes=15
FOR y1=0 TO 7
FOR x1=0 TO 7
u=quadrant(x1,y1)
IF u=0 THEN PRINT" . ";
IF u<0 THEN PRINT"+++";
IF u=2 THEN PRINT"<O>";
IF u=3 THEN PRINT" * ";
IF u=4 THEN PRINT"-O-";
NEXT
PRINT" ";
IF y1=1 THEN PRINT"s.date ";stardate;
IF y1=2 THEN PRINT"alert  ";MID$("greenred  dock ",condition*5-4,5);
IF y1=3 THEN PRINT"energy ";energy;
IF y1=4 THEN PRINT"torp   ";torpedoes;
IF y1=5 THEN PRINT"shield ";shields;
IF y1=6 THEN PRINT"enemy  ";klingons;
PRINT:NEXT
ENDPROC
'
'"Do one command"
'
PROC command()
INPUT"Command? ";b
IF b=1 THEN CALL helm()
IF b=2 THEN CALL longrange()
IF b=3 THEN CALL phasers()
IF b=4 THEN CALL torpedoes()
IF b=5 THEN CALL shields()
IF b=6 THEN CALL shortrange()
IF b=7 THEN CALL resign()
ENDPROC
'
PROC helm()
ENDPROC
'
PROC longrange()
ENDPROC
'
PROC phasers()
ENDPROC
'
PROC torpedoes()
ENDPROC
'
PROC shields()
ENDPROC
'
PROC resign()
ENDPROC
