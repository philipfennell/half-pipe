<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform
		xmlns:err="http://www.w3.org/ns/xproc-error"
		xmlns:hp="http://code.google.com/p/half-pipe/"
		xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:t="http://xproc.org/ns/testsuite"
		xmlns:saxon="http://saxon.sf.net/"
		xmlns:xhtml="http://www.w3.org/1999/xhtml"
		xmlns:xproc="http://www.w3.org/ns/xproc"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:XSLT="http://www.w3.org/1999/XSL/Transform/output"
		exclude-result-prefixes="err hp saxon xhtml xproc xs xsl"
		version="2.0">
	
	<xsl:import href="xproc-compiler.xsl"/>
	<xsl:include href="xproc-common.xsl"/>
	
	<xsl:output method="xml" indent="yes" encoding="UTF-8" media-type="application/xml"
			saxon:indent-spaces="4"/>
	
	<xsl:output name="escapedMarkup" omit-xml-declaration="yes" method="xml" 
			indent="yes" encoding="UTF-8" media-type="application/xml"
			saxon:indent-spaces="4"/>
	
	<xsl:output name="debug" method="xml" indent="yes" encoding="UTF-8" media-type="application/xml"
			saxon:indent-spaces="4"/>
	
	<xsl:param name="MODE" select="''" as="xs:string"/>
	
	
	<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:dcterms="http://purl.org/dc/terms/">
		<rdf:Description rdf:about="$Source: $">
			<dcterms:creator>Philip A. R. Fennell</dcterms:creator>
			<dcterms:hasVersion>$Revision: $</dcterms:hasVersion>
			<dcterms:dateSubmitted>$Date: $</dcterms:dateSubmitted>
			<dcterms:format>application/xslt+xml</dcterms:format>
			<dcterms:title>XProc Test Suite</dcterms:title>
			<dcterms:description>Driver transform for individual XProc Test Suite tests.</dcterms:description>
		</rdf:Description>
	</rdf:RDF>
	
	<xsl:strip-space elements="*"/>
	
	
	
	
	<!--  -->
	<xsl:template match="/">
		<xsl:apply-templates select="t:test" mode="t:test"/>
	</xsl:template>
	
	
	
	
	<!-- Generates a test result for each test. -->
	<xsl:template match="t:test" mode="t:test">
		<xsl:param name="href" as="xs:string?"/>
		
		<!-- Expand the pipeline to its full canonical form. -->
		<xsl:variable name="pipelineDoc" as="document-node()">
			<xsl:document>
				<xsl:copy-of select="t:pipeline/*"/>
			</xsl:document>
		</xsl:variable>
		
		<!-- Compile the expanded pipeline into an executable transform. -->
		<xsl:variable name="compiledPipeline" select="xproc:compile($pipelineDoc)" as="document-node()"/>
		
		<xsl:variable name="inputDoc" as="document-node()">
			<xsl:document>
				<xsl:copy-of select="t:input[@port = 'source']/*"/>
			</xsl:document>
		</xsl:variable>
		
		<xsl:variable name="outputDoc" as="document-node()">
			<xsl:document>
				<xsl:copy-of select="t:output[@port = 'result']/*"/>
			</xsl:document>
		</xsl:variable>
		
		<xsl:variable name="compiledTransform" select="saxon:compile-stylesheet($compiledPipeline)"/>
		
		<xsl:variable name="pipelineResult" select="saxon:transform($compiledTransform, $inputDoc)" as="document-node()"/>
		
		<xsl:choose>
			<xsl:when test="deep-equal($pipelineResult, $outputDoc)">
				<pass xmlns="http://xproc.org/ns/testreport" uri="http://tests.xproc.org/tests/{$href}">
					<title><xsl:value-of select="t:title"/></title>
				</pass>
			</xsl:when>
			<xsl:otherwise>
				<fail uri="http://tests.xproc.org/tests/required/{$href}">
					<title><xsl:value-of select="t:title"/></title>
					<expected>
						<xsl:sequence select="saxon:serialize($outputDoc, 'escapedMarkup')"/>
					</expected>
					<actual>
						<xsl:sequence select="saxon:serialize($pipelineResult, 'escapedMarkup')"/>
					</actual>
				</fail>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:transform>