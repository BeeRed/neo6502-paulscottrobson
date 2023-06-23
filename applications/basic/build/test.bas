.10 print "Hello World"
.12 gosub 100
.20 stop
.100 print "In subroutine"
.110 gosub 200
.120 gosub 200
.130 print "Exit"
.140 return
.200 print "In 200"
.210 return