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
				<xsl:apply-templates select="t:pipeline" mode="t:pipeline"/>
			</xsl:document>
		</xsl:variable>
		
		<!-- Compile the expanded pipeline into an executable transform. -->
		<xsl:variable name="compiledPipeline" select="xproc:compile($pipelineDoc)" as="document-node()"/>
		
		<xsl:if test="$MODE = 'debug'">
			<xsl:result-document format="debug" href="../../debug/compiledPipeline.xsl">
				<xsl:copy-of select="$compiledPipeline"/>
			</xsl:result-document>
		</xsl:if>
		
		<xsl:variable name="inputDoc" as="document-node()">
			<xsl:document>
				<xsl:copy-of select="t:input[@port = 'source']/*"/>
			</xsl:document>
		</xsl:variable>
		
		<xsl:variable name="expectedDoc" as="document-node()">
			<xsl:document>
				<xsl:apply-templates select="t:output" mode="t:output"/>
			</xsl:document>
		</xsl:variable>
		
		<xsl:variable name="compiledTransform" select="saxon:compile-stylesheet($compiledPipeline)"/>
		
		<xsl:variable name="actualDoc" select="saxon:transform($compiledTransform, $inputDoc)" as="document-node()"/>
		
		<xsl:if test="$MODE = 'debug'">
			<xsl:result-document format="debug" href="../../debug/actual.xml">
				<xsl:copy-of select="$actualDoc"/>
			</xsl:result-document>
		</xsl:if>
		
		<xsl:choose>
			<xsl:when test="deep-equal($actualDoc, $expectedDoc)">
				<pass xmlns="http://xproc.org/ns/testreport" uri="http://tests.xproc.org/tests/{$href}">
					<title><xsl:value-of select="t:title"/></title>
				</pass>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="$actualDoc" mode="t:failed">
					<xsl:with-param name="href" select="$href" as="xs:string?"/>
					<xsl:with-param name="title" select="t:title" as="xs:string"/>
					<xsl:with-param name="expectedDoc" select="$expectedDoc" as="document-node()"/>
					<xsl:with-param name="actualDoc" select="$actualDoc" as="document-node()"/>
				</xsl:apply-templates>
			</xsl:otherwise>
			</xsl:choose>
	</xsl:template>
	
	
	
	
	<!-- Expected document in a t:document. -->
	<xsl:template match="t:output[@port = 'result']/t:document" mode="t:output">
		<xsl:copy-of select="*"/>
	</xsl:template>
	
	
	
	
	<!-- Expected document. -->
	<xsl:template match="t:output[@port = 'result'][not(t:document)]" mode="t:output">
		<xsl:copy-of select="*"/>
	</xsl:template>
	
	
	
	
	<!-- Retrieves the pipeline referenced by the href attribute. -->
	<xsl:template match="t:pipeline[@href]" mode="t:pipeline">
		<xsl:variable name="pipelineURI" select="xs:anyURI(concat(hp:baseURI(.), @href))" as="xs:anyURI"/>
		<xsl:message>[XSLT] <xsl:value-of select="resolve-uri($pipelineURI)"/></xsl:message>
		<xsl:copy-of select="if (doc-available($pipelineURI)) then doc($pipelineURI) else t:error($pipelineURI, 'Pipeline could not be loaded.')"/>
	</xsl:template>
	
	
	
	
	<!-- Copies the in-line pipeline document. -->
	<xsl:template match="t:pipeline" mode="t:pipeline">
		<xsl:copy-of select="*"/>
	</xsl:template>
	
	
	
	
	<!--  -->
	<xsl:template match="/hp:error" mode="t:failed" priority="1">
		<xsl:param name="href" as="xs:string?"/>
		<xsl:param name="title" as="xs:string"/>
		<xsl:param name="actualDoc" as="document-node()"/>
		<fail xmlns="http://xproc.org/ns/testreport" uri="http://tests.xproc.org/tests/required/{$href}">
			<title><xsl:value-of select="$title"/></title>
			<error><xsl:value-of select="$actualDoc/hp:error/@code"/></error>
			<message><xsl:value-of select="text()"/></message>
		</fail>
	</xsl:template>
	
	
	
	
	<!--  -->
	<xsl:template match="/*" mode="t:failed">
		<xsl:param name="href" as="xs:string?"/>
		<xsl:param name="title" as="xs:string"/>
		<xsl:param name="expectedDoc" as="document-node()"/>
		<xsl:param name="actualDoc" as="document-node()"/>
		<fail xmlns="http://xproc.org/ns/testreport" uri="http://tests.xproc.org/tests/required/{$href}">
			<title><xsl:value-of select="$title"/></title>
			<expected>
				<xsl:sequence select="saxon:serialize($expectedDoc, 'escapedMarkup')"/>
			</expected>
			<actual>
				<xsl:sequence select="saxon:serialize($actualDoc, 'escapedMarkup')"/>
			</actual>
		</fail>
	</xsl:template>
	
</xsl:transform>