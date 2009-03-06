<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform
		xmlns:app="http://www.w3.org/2007/app"
		xmlns:atom="http://www.w3.org/2005/Atom"
		xmlns:c="http://www.w3.org/ns/xproc-step"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		version="2.0">

	<xsl:output method="xml" indent="yes" encoding="UTF-8" media-type="application/xml"/>
	
	<xsl:param name="SERVICE_URI" select="'http://192.168.192.10:8080/atomserver/v1/'" as="xs:string"/>
	<xsl:param name="COLLECTION" select="'test/atom-6/'" as="xs:string"/>

	<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dcterms="http:purl.org/dc/terms/">
		<rdf:Description rdf:about="$Source: $">
			<dcterms:creator>Philip A. R. Fennell</dcterms:creator>
			<dcterms:hasVersion>$Revision: $</dcterms:hasVersion>
			<dcterms:dateSubmitted>$Date: $</dcterms:dateSubmitted>
			<dcterms:rights>Copyright 2009, British Broadcasting Corporation, All Rights Reserved.</dcterms:rights>
			<dcterms:format>text/xsl</dcterms:format>
			<dcterms:description>Converts Atom feed into a sequence of XProc c:request elements.</dcterms:description>
		</rdf:Description>
	</rdf:RDF>
	
	<xsl:template match="/atom:feed">
		<c:requests>
			<xsl:apply-templates/>
		</c:requests>
	</xsl:template>
	
	<xsl:template match="atom:entry">
		<c:request method="PUT" href="{concat($SERVICE_URI, $COLLECTION, substring-after(atom:id, 'urn:uuid:'))}">
			<c:body content-type="{atom:content/@type}"><xsl:copy-of select="."/></c:body>
		</c:request>
	</xsl:template>
	
</xsl:transform>
