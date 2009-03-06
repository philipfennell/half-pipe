<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform
		xmlns="http://www.w3.org/2005/Atom"
		xmlns:app="http://www.w3.org/2007/app"
		xmlns:atom="http://www.w3.org/2005/Atom"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		version="2.0">

	<xsl:output method="xml" indent="yes" encoding="UTF-8" media-type="application/atom+xml"/>

	<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dcterms="http:purl.org/dc/terms/">
		<rdf:Description rdf:about="$Source: $">
			<dcterms:creator>Philip A. R. Fennell</dcterms:creator>
			<dcterms:hasVersion>$Revision: $</dcterms:hasVersion>
			<dcterms:dateSubmitted>$Date: $</dcterms:dateSubmitted>
			<dcterms:rights>Copyright 2009, British Broadcasting Corporation, All Rights Reserved.</dcterms:rights>
			<dcterms:format>text/xsl</dcterms:format>
			<dcterms:description>Re-write links in Atom Service, Feed and Entry documents.</dcterms:description>
		</rdf:Description>
	</rdf:RDF>
	
	<xsl:param name="PATTERN" as="xs:string"/>
	<xsl:param name="REPLACEMENT" as="xs:string"/>
	
	
	<!-- Root -->
	<xsl:template match="/">
		<xsl:apply-templates mode="rewrite"/>
	</xsl:template>
	
	
	
	
	<!-- Re-write AtomPub link URLs. -->
	<xsl:template match="app:*/@href" mode="rewrite">
		<xsl:attribute name="href" select="atom:transform-uri(current())"/>
	</xsl:template>
	
	
	
	
	<!-- Re-write Atom(Pub) Category scheme URLs. -->
	<xsl:template match="app:*/@scheme | atom:*/@scheme" mode="rewrite">
		<xsl:attribute name="scheme" select="atom:transform-uri(current())"/>
	</xsl:template>
	
	
	
	
	<!-- Re-write Atom link URLs. -->
	<xsl:template match="atom:link/@href" mode="rewrite">
		<xsl:attribute name="href" select="atom:transform-uri(current())"/>
	</xsl:template>
	
	
	
	
	<!-- Re-write category scheme URLs. -->
	<xsl:template match="atom:category/@scheme" mode="rewrite">
		<xsl:attribute name="scheme" select="atom:transform-uri(current())"/>
	</xsl:template>
	
	
	
	
	<!-- Re-write icon and log URLs. -->
	<xsl:template match="atom:icon | atom:logo" mode="rewrite">
		<xsl:copy>
			<xsl:value-of select="atom:transform-uri(text())"/>
		</xsl:copy>
	</xsl:template>
	
	
	
	
	<!-- Re-write content URLs. -->
	<xsl:template match="atom:content/@src" mode="rewrite">
		<xsl:attribute name="src" select="atom:transform-uri(current())"/>
	</xsl:template>
	
	
	
	
	<!-- Replicate elements, there attributes and children. -->
	<xsl:template match="element()" mode="#all">
		<xsl:copy>
			<xsl:apply-templates select="attribute() | element() | text()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	
	
	
	<!-- Replicate attributes. -->
	<xsl:template match="attribute()" mode="#all">
		<xsl:copy-of select="current()"/>
	</xsl:template>
	
	
	
	
	<!-- URL transformer. -->
	<xsl:function name="atom:transform-uri" as="xs:string">
		<xsl:param name="uri" as="xs:string"/>
		<xsl:value-of select="atom:transform-uri($uri, $PATTERN, $REPLACEMENT)"/>
	</xsl:function>
	
	
	
	
	<!-- URL transformer. -->
	<xsl:function name="atom:transform-uri" as="xs:string">
		<xsl:param name="uri" as="xs:string"/>
		<xsl:param name="pattern" as="xs:string?"/>
		<xsl:param name="replacement" as="xs:string?"/>
		<xsl:value-of select="replace($uri, $pattern, $replacement)"/>
	</xsl:function>

</xsl:transform>
