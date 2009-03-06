<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:saxon="http://saxon.sf.net/"
	xmlns:xi="http://www.w3.org/2001/XInclude"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:XSLT="http://www.w3.org/1999/XSL/Transform/output"
	exclude-result-prefixes="saxon xi xsl"
	version="2.0">
	
	<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:dcterms="http://purl.org/dc/terms/">
		<rdf:Description rdf:about="$Source: $">
			<dcterms:creator>Philip A. R. Fennell</dcterms:creator>
			<dcterms:hasVersion>$Revision: $</dcterms:hasVersion>
			<dcterms:dateSubmitted>$Date: $</dcterms:dateSubmitted>
			<dcterms:format>text/xsl</dcterms:format>
			<dcterms:title>Error-code extractor</dcterms:title>
			<dcterms:description>Extracts error-code definitions from the W3C's XProc recommendation document.</dcterms:description>
		</rdf:Description>
	</rdf:RDF>
	
	<xsl:output method="xml" indent="yes" encoding="UTF-8" media-type="application/xml"
			saxon:indent-spaces="4"/>
	
	<xsl:strip-space elements="*"/>
	
	<xsl:template match="/">
		<xsl:apply-templates select="*" mode="error-codes"/>
	</xsl:template>
	
	<xsl:template match="dl" mode="error-codes">
		<xsl:apply-templates select="dt" mode="error-codes"/>
	</xsl:template>
	
	<xsl:template match="dt" mode="error-codes">
		
	</xsl:template>
	
</xsl:transform>