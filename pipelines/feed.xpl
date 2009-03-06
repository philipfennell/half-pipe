<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline 
		xmlns:app="http://www.w3.org/2007/app"
		xmlns:as="http://services.bbc.co.uk/atomstore"
		xmlns:c="http://www.w3.org/ns/xproc-step"
		xmlns:cx="http://xmlcalabash.com/ns/extensions"
		xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		name="process-feed">
	
	<p:import href="forge_lib.xpl"/>
	
	<as:re-write_links pattern="atomserver" replacement="atomstore/atomserver"/>
	
</p:pipeline>
