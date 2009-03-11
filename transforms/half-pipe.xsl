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
	
	<xsl:import href="xproc-compiler.xsl"/>
	<xsl:include href="xproc-common.xsl"/>
	
	<xsl:output method="xml" indent="yes" encoding="UTF-8" media-type="application/xml"
			saxon:indent-spaces="4"/>
	<xsl:output name="debug" method="xml" indent="yes" encoding="UTF-8" media-type="application/xml"
			saxon:indent-spaces="4"/>
	
	<xsl:param name="MODE" select="''" as="xs:string"/>
	
	
	<xsl:namespace-alias stylesheet-prefix="XSLT" result-prefix="xsl"/>
	
	
	<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:dcterms="http://purl.org/dc/terms/">
		<rdf:Description rdf:about="$Source: $">
			<dcterms:creator>Philip A. R. Fennell</dcterms:creator>
			<dcterms:hasVersion>$Revision: $</dcterms:hasVersion>
			<dcterms:dateSubmitted>$Date: $</dcterms:dateSubmitted>
			<dcterms:format>application/xslt+xml</dcterms:format>
			<dcterms:title>Half-pipe</dcterms:title>
			<dcterms:description>An XSLT 2.0 Implementation of the W3C's XML Pipeline Language (XProc).</dcterms:description>
		</rdf:Description>
	</rdf:RDF>
	
	<xsl:strip-space elements="*"/>
	
	
	
	<xsl:template match="/">
		<!-- Expand the pipeline to its full canonical form. -->
		<xsl:variable name="parsedPipeline" as="document-node()">
			<xsl:document>
				<xsl:apply-templates select="*" mode="xproc:parse"/>
			</xsl:document>
		</xsl:variable>
		
		<xsl:if test="$MODE = 'debug'">
			<xsl:result-document format="debug" href="../debug/expandedPipeline.xml">
				<xsl:copy-of select="$parsedPipeline"/>
			</xsl:result-document>
		</xsl:if>
		
		<!-- Compile the expanded pipeline into an executable transform. -->
		<xsl:variable name="compiledPipeline" as="document-node()">
			<xsl:document>
				<xsl:apply-templates select="$parsedPipeline" mode="xproc:compile"/>
			</xsl:document>
		</xsl:variable>
		
		<xsl:if test="$MODE = 'debug'">
			<xsl:result-document format="debug" href="../debug/compiledPipeline.xsl">
				<xsl:copy-of select="$compiledPipeline"/>
			</xsl:result-document>
		</xsl:if>
		
		<xsl:copy-of select="$compiledPipeline"/>
	</xsl:template>
	
</xsl:transform>