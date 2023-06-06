# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		makedoc.py
#		Purpose :	Make HTML documentation
#		Date :		6th June 2023
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,re 

# *******************************************************************************************
#
#									Document Elements
#
# *******************************************************************************************

class Element(object):
	def __init__(self,text):
		self.text = text 

class TitleElement(Element):
	def render(self):
		print("<h1 style=\"background-color:cyan;\"><center>"+self.text+"</center></h1>")

class BodyElement(Element):
	def render(self):
		print("<div>"+self.text+"</div>")

class CodeElement(Element):
	def render(self):
	 	print("<center><i><b>"+self.text+"</b></i></center")

class NewLineElement(Element):
	def render(self):
		print("<br />")

# *******************************************************************************************
#
#									Single document item
#
# *******************************************************************************************

class Documentation(object):
	def __init__(self,name):
		self.key = name.strip().lower()
		self.elements = [ TitleElement(name) ]

	def getKey(self):
		return self.key 

	def append(self,e):
		reject = False
		if isinstance(e,NewLineElement) and isinstance(self.elements[-1],NewLineElement):
			reject = True
		if isinstance(e,BodyElement) and isinstance(self.elements[-1],BodyElement):
			reject = True		
			self.elements[-1].text = (self.elements[-1].text+" "+e.text).replace("  ","")
		if not reject:
			self.elements.append(e)

	def render(self):
		for e in self.elements:
			e.render()

if __name__ == '__main__':
	docObjects = {}
	currentObject = None
	for root,dirs,files in os.walk("src"):
		for f in [x for x in files if x.endswith(".asm")]:
			inDoc = False 
			for s in open(root+os.sep+f).readlines():
				if s.startswith(";:"):
					m = re.match("^\\;\\:\\s*\\[(.*)\\]",s)
					assert m is not None,"Bad start "+s
					do = Documentation(m.group(1).strip().lower())
					docObjects[do.getKey()] = do
					inDoc = True
					currentObject = do
				elif inDoc:
					if s.startswith(";"):
						s = s[1:].strip()
						newLineFollows = False 
						if s.endswith("\\"):
							s = s[:-1]
							newLineFollows = True 
						for s in re.split("(\\{.*?\\})",s):
							if s.startswith("{"):
								currentObject.append(NewLineElement(""))
								currentObject.append(CodeElement(s[1:-1].strip()))
								currentObject.append(NewLineElement(""))
							else:
								currentObject.append(BodyElement(s))
							if newLineFollows:
								currentObject.append(NewLineElement(""))

					else:
						inDoc = False 

	keys = [x for x in docObjects.keys()]
	keys.sort()
	print("<html><head></head><body>")
	for k in keys:
		docObjects[k].render()
	print("</body></html>")