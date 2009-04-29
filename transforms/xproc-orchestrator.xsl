<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform
		xmlns:err="http://www.w3.org/ns/xproc-error"
		xmlns:hp="http://code.google.com/p/half-pipe/"
		xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:saxon="http://saxon.sf.net/"
		xmlns:smil="http://www.w3.org/ns/SMIL30"
		xmlns:xhtml="http://www.w3.org/1999/xhtml"
		xmlns:xproc="http://www.w3.org/ns/xproc"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:XSLT="http://www.w3.org/1999/XSL/Transform/output"
		exclude-result-prefixes="hp saxon xhtml xproc xs xsl"
		version="2.0">
	
	<xsl:import href="xproc-parser.xsl"/>
	<xsl:include href="xproc-common.xsl"/>
	
	<xsl:output method="xml" indent="yes" encoding="UTF-8" media-type="application/xml"
			saxon:indent-spaces="4"/>
	<xsl:output name="debug" method="xml" indent="yes" encoding="UTF-8" media-type="application/xml"
			saxon:indent-spaces="4"/>
	
	<xsl:param name="MODE" select="''" as="xs:string?"/>
	
	
	<xsl:namespace-alias stylesheet-prefix="XSLT" result-prefix="xsl"/>
	
	
	<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:dcterms="http://purl.org/dc/terms/">
		<rdf:Description rdf:about="$Source: $">
			<dcterms:creator>Philip A. R. Fennell</dcterms:creator>
			<dcterms:hasVersion>$Revision: $</dcterms:hasVersion>
			<dcterms:dateSubmitted>$Date: $</dcterms:dateSubmitted>
			<dcterms:format>text/xsl</dcterms:format>
			<dcterms:title>XProc Compiler</dcterms:title>
			<dcterms:description>XProc Pipeline Orchestrator</dcterms:description>
		</rdf:Description>
	</rdf:RDF>
	
	<xsl:strip-space elements="*"/>
	
	
	
	
	<!-- Returns the compiled version of the passed XProc pipeline document. -->
	<xsl:function name="xproc:orchestrate" as="element()*">
		<xsl:param name="pipelineDoc" as="document-node()"/>
		<xsl:param name="mode" as="xs:string?"/>
		<xsl:variable name="parsedPipeline" select="xproc:parse($pipelineDoc)" as="element()"/>
		
		<hp:job-bag>
			<xsl:if test="$mode = 'debug'">
				<xsl:copy-of select="$parsedPipeline"/>
			</xsl:if>
			<hp:orchestration>
				<xsl:apply-templates select="$parsedPipeline" mode="xproc:compile"/>
			</hp:orchestration>
		</hp:job-bag>
	</xsl:function>
	
	
	
	
	<!-- Driver template. -->
	<xsl:template match="/">
		<!-- Expand the pipeline to its full canonical form. -->
		<xsl:variable name="parsedPipeline" as="element()">
			<xsl:apply-templates select="/" mode="xproc:parse"/>
		</xsl:variable>
		
		<xsl:if test="$MODE = 'debug'">
			<xsl:result-document format="debug" href="../debug/parsed-pipeline.xml">
				<xsl:copy-of select="$parsedPipeline/*"/>
			</xsl:result-document>
		</xsl:if>
		
		<!-- Orchestrate the expanded pipeline into an executable transform. -->
		<xsl:variable name="orchestration" as="element()">
			<hp:orchestration>
				<xsl:apply-templates select="$parsedPipeline" mode="xproc:orchestrate"/>
			</hp:orchestration>
		</xsl:variable>
		
		<xsl:copy-of select="$orchestration/*"/>
	</xsl:template>
	
	
	
	
	
	
	<!-- === Pipeline Orchestration (xproc:orchestrate). ========================= -->
	
	<xsl:template match="hp:parsed-pipeline" mode="xproc:orchestrate">
		<smil:timesheet>
			
		</smil:timesheet>
	</xsl:template>
	
</xsl:transform>