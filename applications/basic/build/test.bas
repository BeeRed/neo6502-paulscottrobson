	rem
	rem 		"Stress test file system. A bit."
	rem 	
	repeat
	file$ = "test"+str$(rand(8))
	pos = &1000+rand(&200)
	size = rand(&2100)+1
	print file$,pos,size
	save file$,pos,size
	poke &8000+size,&AA
	load file$,&8000
	error = 0
	'
	for i = 0 to size-1
		if peek(pos+i) <> peek(&8000+i) then print i,peek(pos+i),peek(&8000+i):error = 1
	next
	if peek(&8000+size) <> &AA then print "Overflow":error = 1
	until error