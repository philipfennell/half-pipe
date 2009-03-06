<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform
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
			<dcterms:title>XInclude Processor</dcterms:title>
			<dcterms:description>An XSLT 2.0 partial Implementation of the W3C's XML Inclusions (XInclude).</dcterms:description>
		</rdf:Description>
	</rdf:RDF>
	
	<xsl:output method="xml" indent="yes" encoding="UTF-8" media-type="application/xml"
		saxon:indent-spaces="4"/>
	
	<xsl:strip-space elements="*"/>
	
	<xsl:template match="/">
		<xsl:apply-templates select="*|text()" mode="xi:include"/>
	</xsl:template>
	
	<xsl:template match="/" mode="xi:include">
		<xsl:document>
			<xsl:apply-templates select="*|text()" mode="xi:include"/>
		</xsl:document>
	</xsl:template>
	
	<xsl:template match="*" mode="xi:include">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="*|text()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="text()" mode="xi:include">
		<xsl:value-of select="normalize-space(.)"/>
	</xsl:template>
	
	<xsl:template match="xi:include[@parse = 'xml']" mode="xi:include">
		<xsl:variable name="includeDoc" as="document-node()">
			<xsl:choose>
				<xsl:when test="doc-available(@href)">
					<xsl:apply-templates select="doc(@href)" mode="xi:include"/>
					<!--<xsl:copy-of select="doc(@href)"/>-->
				</xsl:when>
				<xsl:when test="xi:fallback">
					<xsl:copy-of select="xi:fallback/*"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message>[XSLT] Document not found and no fall-back supplied for: <xsl:value-of select="@href"/></xsl:message>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="xpointer" select="@xpointer"/>
		
		<xsl:for-each select="$includeDoc">
			<xsl:copy-of select="saxon:evaluate($xpointer)"/>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="xi:include" mode="xi:include">
		<xsl:message terminate="yes">XInclude parse type '<xsl:value-of select="@parse"/>' is not supported.</xsl:message>
	</xsl:template>
	
</xsl:transform>