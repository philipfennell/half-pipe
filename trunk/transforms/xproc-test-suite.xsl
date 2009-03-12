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
			<dcterms:title>XProc Test Suite</dcterms:title>
			<dcterms:description>Driver transform for the XProc Test Suite.</dcterms:description>
		</rdf:Description>
	</rdf:RDF>
	
	<xsl:strip-space elements="*"/>
	
	
	
	<xsl:template match="/">
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
		
		<xsl:variable name="sourceDoc" as="document-node()">
			<xsl:document>
				<xsl:copy-of select="t:test/t:input[@port = 'source']/*"/>
			</xsl:document>
		</xsl:variable>
		
		<xsl:variable name="resultDoc" as="document-node()">
			<xsl:document>
				<xsl:copy-of select="t:test/t:output[@port = 'result']/*"/>
			</xsl:document>
		</xsl:variable>
		
		<xsl:variable name="compiledTransform" select="saxon:compile-stylesheet($compiledPipeline)"/>
		
		<xsl:variable name="pipelineResult" select="saxon:transform($compiledTransform, $sourceDoc)" as="document-node()"/>
		
		<t:result title="{t:test/t:title}"><xsl:value-of select="if (deep-equal($pipelineResult, $resultDoc)) then 'PASS' else 'FAIL'"/></t:result>
		
	</xsl:template>
	
	
	
	
	<!-- Generate test report document. -->
	<xsl:template match="/" mode="xproc:test-report">
		<test-report xmlns="http://xproc.org/ns/testreport">
			<title>XProc Test Results for XML Calabash</title>
			<date>2009-03-06T16:36:39</date>
			<processor>
				<name>XML Calabash</name>
				<vendor>Norman Walsh</vendor>
				<vendor-uri>http://xmlcalabash.com/</vendor-uri>
				<version>0.9.5b</version>
				<language>en_US</language>
				<xproc-version>1.0</xproc-version>
				<xpath-version>2.0</xpath-version>
				<psvi-supported>false</psvi-supported>
			</processor>
			
			<test-suite>
				<title>Required tests</title>
				
				<pass uri="http://tests.xproc.org/tests/required/add-attribute-001.xml">
					<title>Test p:add-attribute #001</title>
				</pass>
				
				<fail uri="http://tests.xproc.org/tests/required/rename-003.xml">
					<title>Test rename-003</title>
					<expected>&lt;doc xmlns:test2="http://test2.com" xmlns:t="http://xproc.org/ns/testsuite" xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" test2:foo="value"/&gt;</expected>
					<actual>&lt;doc xmlns:p="http://www.w3.org/ns/xproc" xmlns:test2="http://test2.com" xmlns:t="http://xproc.org/ns/testsuite" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:test="http://test.com" test2:foo="value2"/&gt;</actual>
				</fail>
			</test-suite>
		</test-report>
	</xsl:template>
	
</xsl:transform>