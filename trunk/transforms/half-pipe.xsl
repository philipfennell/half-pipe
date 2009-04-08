<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform
		xmlns:err="http://www.w3.org/ns/xproc-error"
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
	<xsl:output name="xml" method="xml" indent="yes" encoding="UTF-8" media-type="application/xml"
		saxon:indent-spaces="4"/>
	
	<xsl:param name="MODE" select="'debug'" as="xs:string"/>
	<xsl:param name="SRC" select="'../examples/test-doc.xml'" as="xs:string?"/>
	
	
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
	
	
	
	
	<!--  -->
	<xsl:template match="/">
		<xsl:variable name="inputPorts" as="element()">
			<hp:inputs>
				<SOURCE>
					<xsl:copy-of select="if (doc-available($SRC)) then doc($SRC) else hp:error('err:XD0002', $SRC)"/>
				</SOURCE>
			</hp:inputs>
		</xsl:variable>
		
		<xsl:copy-of select="xproc:process(., $inputPorts, $MODE)/hp:pipeline-outputs/hp:document/*"/>
	</xsl:template>
	
	
	
	
	<!-- Invokes the pipeline on the source port. -->
	<xsl:function name="xproc:process" as="element()">
		<xsl:param name="pipelineDoc" as="document-node()"/>
		<xsl:param name="inputPorts" as="element()"/>
		<xsl:param name="mode" as="xs:string?"/>
		
		<!-- The source document(s). -->
		<xsl:variable name="sourcePort" as="document-node()">
			<xsl:document>
				<hp:documents>
					<xsl:for-each select="$inputPorts/SOURCE/*">
						<hp:document>
							<xsl:copy-of select="."/>
						</hp:document>
					</xsl:for-each>
				</hp:documents>
			</xsl:document>
		</xsl:variable>
		
		<!-- The other input ports e.g. parameter and/or stylesheet ports. -->
		<xsl:variable name="parameters" as="element()*">
			<xsl:for-each select="$inputPorts/*[local-name() != 'SOURCE']">
				<xsl:copy>
					<xsl:copy-of select="hp:serialize(*, 'xml')"/>
				</xsl:copy>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:variable name="compilerJobBag" as="element()">
			<xsl:copy-of select="xproc:compile($pipelineDoc, $mode)"/>
		</xsl:variable>
		
		<xsl:apply-templates select="$compilerJobBag" mode="hp:compiler_job-bag">
			<xsl:with-param name="sourcePort" select="$sourcePort" as="document-node()" tunnel="yes"/>
			<xsl:with-param name="parameters" select="$parameters" as="element()*" tunnel="yes"/>
			<xsl:with-param name="mode" select="$mode" as="xs:string?" tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:function>
	
	
	
	
	<!-- Copies the job-bag wrapper. -->
	<xsl:template match="hp:job-bag" mode="hp:compiler_job-bag">
		<xsl:param name="sourcePort" as="document-node()" tunnel="yes"/>
		<xsl:param name="parameters" as="element()*" tunnel="yes"/>
		
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<hp:pipeline-inputs>
				<xsl:copy-of select="$sourcePort"/>
			</hp:pipeline-inputs>
			<hp:pipeline-parameters>
				<xsl:copy-of select="$parameters"/>
			</hp:pipeline-parameters>
			<xsl:apply-templates select="*" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- If present, copies the parsed pipeline into the result. -->
	<xsl:template match="hp:parsed-pipeline" mode="hp:compiler_job-bag">
		<xsl:copy-of select="."/>
	</xsl:template>
	
	
	<!-- Inserts the result(s) of the pipeline into the job-bag and, if in debug
		 mode it also copies the compiled pipeline. -->
	<xsl:template match="hp:compiled-pipeline" mode="hp:compiler_job-bag">
		<xsl:param name="sourcePort" as="document-node()" tunnel="yes"/>
		<xsl:param name="parameters" as="element()*" tunnel="yes"/>
		<xsl:param name="mode" as="xs:string?" tunnel="yes"/>
		<xsl:variable name="pipelineTransform" as="document-node()">
			<xsl:document>
				<xsl:copy-of select="*"/>
			</xsl:document>
		</xsl:variable>
		<xsl:variable name="compiledTransform" select="hp:compile-transform($pipelineTransform)"/>
		
		<xsl:if test="$mode = 'debug'">
			<xsl:copy-of select="."/>
		</xsl:if>
		
		<hp:pipeline-outputs>
			<xsl:copy-of select="hp:transform($compiledTransform, $sourcePort, $parameters)/element()"/>
		</hp:pipeline-outputs>
	</xsl:template>
	
</xsl:transform>