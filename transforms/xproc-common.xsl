<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform
	xmlns:hp="http://code.google.com/p/half-pipe/"
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:saxon="http://saxon.sf.net/"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:xproc="http://www.w3.org/ns/xproc"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:XSLT="http://www.w3.org/1999/XSL/Transform/output"
	exclude-result-prefixes="saxon xhtml xproc xsl"
	version="2.0">
	
	
	<xsl:output method="xml" indent="yes" encoding="UTF-8" media-type="application/xml"
		saxon:indent-spaces="4"/>
	<xsl:output name="debug" method="xml" indent="yes" encoding="UTF-8" media-type="application/xml"
		saxon:indent-spaces="4"/>
	
	
	<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:dcterms="http://purl.org/dc/terms/">
		<rdf:Description rdf:about="$Source: $">
			<dcterms:creator>Philip A. R. Fennell</dcterms:creator>
			<dcterms:hasVersion>$Revision: $</dcterms:hasVersion>
			<dcterms:dateSubmitted>$Date: $</dcterms:dateSubmitted>
			<dcterms:format>text/xsl</dcterms:format>
			<dcterms:title>Half-pipe Utility functions and templates</dcterms:title>
			<dcterms:description>Pipeline functions and templates common to the parser, compiler and processor.</dcterms:description>
		</rdf:Description>
	</rdf:RDF>
	
	<xsl:strip-space elements="*"/>
	
	
	
	
	
	
	
	<!-- Displays the error message for the passed error code on stdout and terminates the transformation. -->
	<xsl:function name="hp:error">
		<xsl:param name="errorCode" as="xs:string"/>
		<xsl:param name="arg" as="xs:string"/>
		
		<xsl:message terminate="yes">[XProc][<xsl:value-of select="$errorCode"/>][FATAL] <xsl:value-of select="$arg"/> - <xsl:value-of select="hp:getErrorMessage($errorCode)"/></xsl:message>
	</xsl:function>
	
	
	
	
	<!-- Returns the error message text for the passed error code. -->
	<xsl:function name="hp:getErrorMessage" as="xs:string">
		<xsl:param name="errorCode" as="xs:string"/>
		<xsl:variable name="errorCodesURI" select="'../docs/error-codes.xml'"/>
		<xsl:variable name="errorCodesDoc" select="if (doc-available($errorCodesURI)) then doc($errorCodesURI) else ()" as="document-node()?"/>
		
		<xsl:value-of select="$errorCodesDoc//xhtml:dt[xhtml:code = $errorCode]/following-sibling::xhtml:dd[1]/xhtml:p[1]"/>
	</xsl:function>
	
</xsl:transform>