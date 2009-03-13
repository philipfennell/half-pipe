<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform
		xmlns="http://xproc.org/ns/testreport"
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
	
	<xsl:output name="escapedMarkup" omit-xml-declaration="yes" method="xml" indent="yes" encoding="UTF-8" media-type="application/xml"/>
	
	<xsl:param name="MODE" select="''" as="xs:string"/>
	
	<xsl:namespace-alias stylesheet-prefix="XSLT" result-prefix="xsl"/>
	
	
	<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:dcterms="http://purl.org/dc/terms/">
		<rdf:Description rdf:about="$Source: $">
			<dcterms:creator>Philip A. R. Fennell</dcterms:creator>
			<dcterms:hasVersion>$Revision: $</dcterms:hasVersion>
			<dcterms:dateSubmitted>$Date: $</dcterms:dateSubmitted>
			<dcterms:format>application/xslt+xml</dcterms:format>
			<dcterms:title>XProc Test Suite</dcterms:title>
			<dcterms:description>Driver transform for the XProc Test Suite.</dcterms:description>
		</rdf:Description>
	</rdf:RDF>
	
	<xsl:strip-space elements="*"/>
	
	
	
	
	<!--  -->
	<xsl:template match="/">
		<xsl:apply-templates select="*" mode="t:report"/>
	</xsl:template>
	
	
	
	
	<!-- Generate test report document. -->
	<xsl:template match="t:test-suite" mode="t:report">
		<xsl:variable name="implementationDoc" select="doc('xproc-compiler.xsl')" as="document-node()"/>
		<xsl:variable name="implementedSteps" select="for $name in distinct-values($implementationDoc//xsl:template[@mode = 'xproc:step']/@match) return substring-after($name, ':')" as="xs:string*"/>
		
		<test-report xmlns="http://xproc.org/ns/testreport">
			<title>XProc Test Results for Half-pipe</title>
			<date>2009-03-06T16:36:39</date>
			<processor>
				<name>Half-pipe</name>
				<vendor>Philip Fennell</vendor>
				<vendor-uri>http://code.google.com/p/half-pipe/</vendor-uri>
				<version>0.1.1</version>
				<language>en_GB</language>
				<xproc-version>1.0</xproc-version>
				<xpath-version>2.0</xpath-version>
				<psvi-supported>false</psvi-supported>
			</processor>
			<test-suite>
				<title><xsl:value-of select="t:title"/></title>
				<xsl:apply-templates select="t:test" mode="#current">
					<xsl:with-param name="type" select="'required'" as="xs:string"/>
					<xsl:with-param name="implementedSteps" select="$implementedSteps" as="xs:string*" tunnel="yes"/>
					<xsl:sort select="@href"/>
				</xsl:apply-templates>
			</test-suite>
		</test-report>
	</xsl:template>
	
	
	
	
	<!-- Iterates over the test. -->
	<xsl:template match="t:test" mode="t:report">
		<xsl:param name="type" as="xs:string"/>
		
		<xsl:variable name="testDocURI" select="xs:anyURI(concat('../tests/', $type, '/', @href))" as="xs:anyURI"/>
		<xsl:variable name="testDoc" as="document-node()">
			<xsl:copy-of select="if (doc-available($testDocURI)) then doc($testDocURI) else ()"/>
		</xsl:variable>
		
		<xsl:apply-templates select="$testDoc" mode="t:test">
			<xsl:with-param name="href" select="@href" as="xs:string"/>
		</xsl:apply-templates>
	</xsl:template>
	
	
	
	
	<!-- Generates a test result for each test. -->
	<xsl:template match="/" mode="t:test">
		<xsl:param name="href" as="xs:string"/>
		<xsl:param name="implementedSteps" as="xs:string*" tunnel="yes"/>
		
		<xsl:message>[XSLT] Testing: <xsl:value-of select="$href"/></xsl:message>
		
		<xsl:choose>
			<xsl:when test="for $stepName in $implementedSteps return if (starts-with($href, $stepName)) then true() else ()">
				
				<!-- Expand the pipeline to its full canonical form. -->
				<xsl:variable name="pipelineDoc" as="document-node()">
					<xsl:document>
						<xsl:copy-of select="t:test/t:pipeline/*"/>
					</xsl:document>
				</xsl:variable>
				
				<!-- Compile the expanded pipeline into an executable transform. -->
				<xsl:variable name="compiledPipeline" select="xproc:compile($pipelineDoc)" as="document-node()"/>
				
				<xsl:if test="$MODE = 'debug'">
					<xsl:result-document format="debug" href="../debug/compiledPipeline.xsl">
						<xsl:copy-of select="$compiledPipeline"/>
					</xsl:result-document>
				</xsl:if>
				
				<xsl:variable name="inputDoc" as="document-node()">
					<xsl:document>
						<xsl:copy-of select="t:test/t:input[@port = 'source']/*"/>
					</xsl:document>
				</xsl:variable>
				
				<xsl:variable name="outputDoc" as="document-node()">
					<xsl:document>
						<xsl:copy-of select="t:test/t:output[@port = 'result']/*"/>
					</xsl:document>
				</xsl:variable>
				
				<xsl:variable name="compiledTransform" select="saxon:compile-stylesheet($compiledPipeline)"/>
				
				<xsl:variable name="pipelineResult" select="saxon:transform($compiledTransform, $inputDoc)" as="document-node()"/>
				
				<xsl:choose>
					<xsl:when test="deep-equal($pipelineResult, $outputDoc)">
						<pass xmlns="http://xproc.org/ns/testreport" uri="http://tests.xproc.org/tests/required/{$href}">
							<title><xsl:value-of select="/t:test/t:title"/></title>
						</pass>
					</xsl:when>
					<xsl:otherwise>
						<fail uri="http://tests.xproc.org/tests/required/{$href}">
							<title><xsl:value-of select="/t:test/t:title"/></title>
							<expected>
								<xsl:sequence select="saxon:serialize($outputDoc, 'escapedMarkup')"/>
							</expected>
							<actual>
								<xsl:sequence select="saxon:serialize($pipelineResult, 'escapedMarkup')"/>
							</actual>
						</fail>
					</xsl:otherwise>
				</xsl:choose>
				
			</xsl:when>
			<xsl:otherwise>
				<fail uri="http://tests.xproc.org/tests/required/{$href}">
					<title><xsl:value-of select="/t:test/t:title"/></title>
					<message>Not Supported</message>
				</fail>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:transform>