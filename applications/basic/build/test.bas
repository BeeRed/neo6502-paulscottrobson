1 list
10    REM
20    REM"Star Trek, originally by I.L.Powell"
30    REM
40    klingons=0
50    stardate=RAND(200)+200
60    energy=3000
70    torpedoes=50
80    shields=0
90    start=stardate
92    DIM galaxy(8,8),sector(8,8)
95    '
96    '"Set up sectors"
97    '
100   FOR x1=0 TO 7
101   FOR y1=0 TO 7
103   x=0:y=0
110   IF RAND(10)<7 THEN x=RAND(3)+1
120   IF RAND(100)>88 THEN y=1
130   z=RAND(5)+1
140   galaxy(x1,y1)=x*100+y*10+z
145   klingons=klingons+x
150   NEXT:NEXT
160   qx=RAND(8):qy=RAND(8)
170   ax=RAND(8):ay=RAND(8)
175   '
176   '"Set up current sector"
177   '
180   qx=qx AND 7:qy=qy AND 7
190   z=galaxy(qx,qy)
210   x=z DIV 100:z=z-x*100
220   y=z DIV 10:z=z-y*10
230   FOR x1=0 TO 7:FOR y1=0 TO 7
233   sector(x1,y1)=0
235   NEXT:NEXT
237   sector(ax,ay)=4
240   WHILE z>0
241   c1=3:CALL putobj()
242   z=z-1
243   WEND
250   IF y<>0 THEN c1=2:CALL putobj()
260   x1=x
310   WHILE x>0
311   c1=-200:CALL putobj()
312   x1=x1-1
313   WEND
340   '
341   '"short range scan"
342   '
350   condition=1
360   IF x<>0 THEN condition=2
690   END
695   '
700   PROC putobj()
710   REPEAT
720   x1=RAND(8):y1=RAND(8)
730   UNTIL sector(x1,y1)=0
740   sector(x1,y1)=c1
750   ENDPROC
