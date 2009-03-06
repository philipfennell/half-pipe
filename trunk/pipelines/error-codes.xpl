<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:cx="http://xmlcalabash.com/ns/extensions"
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:pxp="http://exproc.org/proposed/steps"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xml:base="../"
	exclude-inline-prefixes="c cx p pxp xs"
	name="error-codes">
	
	<p:serialization port="result" indent="true" omit-xml-declaration="false" 
		method="xml" encoding="utf-8" media-type="application/xhtml+xml"/>
	
	<p:load href="resources/xproc_error-codxes.xml"/>
	
	<p:xinclude/>
</p:pipeline>
