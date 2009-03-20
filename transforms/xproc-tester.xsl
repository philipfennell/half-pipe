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
	
	<xsl:import href="half-pipe.xsl"/>
	
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
		
		<!-- Marshal the input document(s) together -->
		<xsl:variable name="inputDocs" as="document-node()*">
			<xsl:apply-templates select="t:input[@port = 'source']" mode="t:input"/>
		</xsl:variable>
		
		<xsl:variable name="expectedDocs" as="document-node()*">
			<xsl:apply-templates select="t:output[@port = 'result']" mode="t:output"/>
		</xsl:variable>
		
		<xsl:variable name="inputPorts" as="element()">
			<hp:inputs>
				<xsl:apply-templates select="t:input" mode="input-ports"/>
			</hp:inputs>
		</xsl:variable>
		
		<xsl:variable name="actualDocs" as="document-node()*">
			<xsl:sequence select="xproc:process($pipelineDoc, $inputPorts, $MODE)"/>
		</xsl:variable>
				
		<xsl:if test="$MODE = 'debug'">
			<xsl:result-document format="debug" href="../../debug/actual.xml">
				<xsl:copy-of select="$actualDocs" copy-namespaces="no"/>
			</xsl:result-document>
		</xsl:if>
		
		<xsl:choose>
			<xsl:when test="@error = name($actualDocs/*)">
				<pass xmlns="http://xproc.org/ns/testreport" uri="http://tests.xproc.org/tests/{$href}">
					<title><xsl:value-of select="t:title"/></title>
				</pass>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="deep-equal($actualDocs, $expectedDocs)">
						<pass xmlns="http://xproc.org/ns/testreport" uri="http://tests.xproc.org/tests/{$href}">
							<title><xsl:value-of select="t:title"/></title>
						</pass>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="$actualDocs" mode="t:failed">
							<xsl:with-param name="href" select="$href" as="xs:string?"/>
							<xsl:with-param name="title" select="t:title" as="xs:string"/>
							<xsl:with-param name="expectedDocs" select="$expectedDocs" as="document-node()+"/>
							<xsl:with-param name="actualDocs" select="$actualDocs" as="document-node()*"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	
	
	
	<!--  -->
	<xsl:template match="t:input" mode="input-ports">
		<xsl:element name="{upper-case(@port)}">
			<xsl:copy-of select="*"/>
		</xsl:element>
	</xsl:template>
	
	
	
	
	<!-- Expected document in a t:document. -->
	<xsl:template match="t:input[@port = 'source']/t:document" mode="t:input">
		<xsl:document>
			<xsl:copy-of select="*"/>
		</xsl:document>
	</xsl:template>
	
	
	
	
	<!-- Expected document. -->
	<xsl:template match="t:input[@port = 'source'][not(t:document)]" mode="t:input">
		<xsl:document>
			<xsl:copy-of select="*"/>
		</xsl:document>
	</xsl:template>
	
	
	
	
	<!-- Expected document in a t:document. -->
	<xsl:template match="t:output[@port = 'result']/t:document" mode="t:output">
		<xsl:document>
			<xsl:copy-of select="*"/>
		</xsl:document>
	</xsl:template>
	
	
	
	
	<!-- Expected document. -->
	<xsl:template match="t:output[@port = 'result'][not(t:document)]" mode="t:output">
		<xsl:document>
			<xsl:copy-of select="*"/>
		</xsl:document>
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
	
	
	
	
	<!-- Generate a fail when an hp:error message is encountered. -->
	<xsl:template match="/err:*" mode="t:failed" priority="1">
		<xsl:param name="href" as="xs:string?"/>
		<xsl:param name="title" as="xs:string"/>
		<xsl:param name="actualDocs" as="document-node()+"/>
		<fail xmlns="http://xproc.org/ns/testreport" uri="http://tests.xproc.org/tests/required/{$href}">
			<title><xsl:value-of select="$title"/></title>
			<error><xsl:value-of select="name($actualDocs/*)"/></error>
			<message><xsl:value-of select="text()"/></message>
		</fail>
	</xsl:template>
	
	
	
	
	<!-- Where the expected and actual documents don't match, generate a fail 
		 and embedded the two documents as examples. -->
	<xsl:template match="/*" mode="t:failed">
		<xsl:param name="href" as="xs:string?"/>
		<xsl:param name="title" as="xs:string"/>
		<xsl:param name="expectedDocs" as="document-node()+"/>
		<xsl:param name="actualDocs" as="document-node()+"/>
		<fail xmlns="http://xproc.org/ns/testreport" uri="http://tests.xproc.org/tests/required/{$href}">
			<title><xsl:value-of select="$title"/></title>
			<expected>
				<xsl:sequence select="for $doc in $expectedDocs return saxon:serialize($doc, 'escapedMarkup')"/>
			</expected>
			<actual>
				<xsl:sequence select="for $doc in $actualDocs return saxon:serialize($doc, 'escapedMarkup')"/>
			</actual>
		</fail>
	</xsl:template>
	
</xsl:transform>