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
	<xsl:import href="xproc-tester.xsl"/>
	<xsl:include href="xproc-common.xsl"/>
	
	<xsl:output method="xml" indent="yes" encoding="UTF-8" media-type="application/xml"
			saxon:indent-spaces="4"/>
	
	<xsl:output name="escapedMarkup" omit-xml-declaration="yes" method="xml" 
			indent="yes" encoding="UTF-8" media-type="application/xml"
			saxon:indent-spaces="4"/>
	
	
	
	
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
		<xsl:variable name="implementationDoc" select="doc('xproc-steps.xsl')" as="document-node()"/>
		<xsl:variable name="implementedSteps" select="for $name in distinct-values($implementationDoc//xsl:template[@hp:implemented = 'true']/@match) return substring-after($name, ':')" as="xs:string*"/>
		
		
		<xsl:variable name="sortedTests" as="element()*">
			<xsl:apply-templates select="t:test[starts-with(@href, 'required')]" mode="t:sort">
				<xsl:with-param name="implementedSteps" select="$implementedSteps"/>
				<xsl:sort select="@href"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="t:test[starts-with(@href, 'optional')]" mode="t:sort">
				<xsl:with-param name="implementedSteps" select="$implementedSteps"/>
				<xsl:sort select="@href"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="t:test[starts-with(@href, 'extension')]" mode="t:sort">
				<xsl:with-param name="implementedSteps" select="$implementedSteps"/>
				<xsl:sort select="@href"/>
			</xsl:apply-templates>
		</xsl:variable>
		
		<test-report xmlns="http://xproc.org/ns/testreport">
			<title>XProc Test Results for Half-pipe</title>
			<date><xsl:value-of select="current-dateTime()"/></date>
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
				<xsl:apply-templates select="$sortedTests" mode="#current"/>
			</test-suite>
		</test-report>
	</xsl:template>
	
	
	
	
	<!-- Copies t:test nodes and inserts a hp:test="true". -->
	<xsl:template match="t:test" mode="t:sort">
		<xsl:param name="implementedSteps" as="xs:string*"/>
		
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:if test="for $stepName in $implementedSteps return if (starts-with(substring-after(@href, '/'), $stepName)) then true() else ()">
				<xsl:attribute name="t:test" select="'true'"/>
			</xsl:if>
			<xsl:copy-of select="* | text()"/>
		</xsl:copy>
	</xsl:template>
	
	
	
	
	<!-- Matches non-testable step tests, and mark them as 'fail' and 'Not Supoorted'. -->
	<xsl:template match="t:test[@t:test = 'true']" mode="t:report">
		<xsl:variable name="testDoc" select="t:testDocument(@href)" as="document-node()"/>
		
		<xsl:apply-templates select="$testDoc/t:test" mode="t:test">
			<xsl:with-param name="href" select="@href" as="xs:string" tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>
	
	
	
	
	<!-- Matches testable steps tests. -->
	<xsl:template match="t:test" mode="t:report">
		<xsl:variable name="testDoc" select="t:testDocument(@href)" as="document-node()"/>
		
		<fail uri="http://tests.xproc.org/tests/{@href}">
			<title><xsl:value-of select="$testDoc/t:test/t:title"/></title>
			<message>Not Supported</message>
		</fail>
	</xsl:template>
	
	
	
	
	<!--  -->
	<xsl:function name="t:testDocument" as="document-node()">
		<xsl:param name="href" as="xs:string"/>
		<xsl:variable name="testDocURI" select="xs:anyURI(concat('../tests/', $href))" as="xs:anyURI"/>
		
		<xsl:copy-of select="if (doc-available($testDocURI)) then doc($testDocURI) else ()"/>
	</xsl:function>
	
</xsl:transform>