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
		exclude-result-prefixes="saxon xhtml xproc xs xsl XSLT"
		version="2.0">
	
	<xsl:include href="xproc-common.xsl"/>
	
	<xsl:output method="xml" indent="yes" encoding="UTF-8" media-type="application/xml"
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
			<dcterms:title>XProc Parser</dcterms:title>
			<dcterms:description>XProc Pipeline Parser.</dcterms:description>
		</rdf:Description>
	</rdf:RDF>
	
	<xsl:strip-space elements="*"/>
	
	
	
	
	<!-- Returns the parsed version of the passed XProc pipeline document. -->
	<xsl:function name="xproc:parse" as="document-node()">
		<xsl:param name="pipelineDoc" as="document-node()"/>
		<!-- Might want a mode parameter. -->
		
		<xsl:variable name="parse1" as="document-node()">
			<xsl:document>
				<xsl:apply-templates select="$pipelineDoc" mode="xproc:parse1"/>
			</xsl:document>
		</xsl:variable>
		
		<xsl:document>
			<xsl:apply-templates select="$parse1" mode="xproc:parse"/>
		</xsl:document>
	</xsl:function>
	
	
	
	
	<!-- Generates the parsed version of the source XProc pipeline document. -->
	<xsl:template match="/" mode="#default xproc:parse">
		<xsl:variable name="parse1" as="element()">
			<xsl:apply-templates select="*" mode="xproc:parse1"/>
		</xsl:variable>
		<xsl:apply-templates select="$parse1" mode="xproc:parse2"/>
	</xsl:template>
	
	
	
	
	<!-- Replicate the non-step elements without adding names. -->
	<xsl:template match="p:data | p:document | p:documentation | p:empty | 
						 p:import | p:inline | xproc:input | 
						 p:iteration-source | p:library | p:log | p:option | 
						 xproc:output | p:pipe | p:pipeinfo | 
						 xproc:serialization | p:variable | p:viewport-source | 
						 p:with-option | p:with-param" 
				mode="xproc:parse1">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="* | text()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
		
	
	
	
	<!-- Add name attribute (with generated name) and a 'step' tag. -->
	<xsl:template match="xproc:*" mode="xproc:parse1">
		<xsl:copy>
			<xsl:attribute name="name" select="generate-id()"/>
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="hp:step" select="'true'"/>
			
			<xsl:apply-templates select="* | text()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	
	
	
	<!--  -->
	<xsl:template match="/xproc:pipeline|/xproc:declare-step" mode="xproc:parse1">
		<p:declare-step>
			<xsl:namespace name="hp" select="'http://code.google.com/p/half-pipe/'"/>
			<xsl:namespace name="saxon" select="'http://saxon.sf.net/'"/>
			<xsl:namespace name="xproc" select="'http://www.w3.org/ns/xproc'"/>
			<xsl:namespace name="xsl" select="'http://www.w3.org/1999/XSL/Transform'"/>
			
			<xsl:copy-of select="@*"/>
			
			<!-- Ensure source/result ports are declared. -->
			<xsl:if test="not(xproc:input[@port = 'source'])">
				<p:input port="source"/>
			</xsl:if>
			<xsl:if test="not(xproc:output[@port = 'result'])">
				<p:output port="result"/>
			</xsl:if>
			
			<xsl:apply-templates select="*" mode="#current">
				<xsl:with-param name="baseURI" select="if (@xml:base) then resolve-uri(@xml:base, base-uri(root())) else base-uri(root())" as="xs:anyURI?" tunnel="yes"/>
			</xsl:apply-templates>
		</p:declare-step>
	</xsl:template>
	
	
	
	
	<!--  -->
	<xsl:template match="xproc:import" mode="xproc:parse1">
		<xsl:param name="baseURI" as="xs:anyURI?" tunnel="yes"/>
		<xsl:variable name="resourceURI" select="resolve-uri(@href, $baseURI)" as="xs:anyURI"/>
		
		<xsl:apply-templates select="if (doc-available($resourceURI)) then doc($resourceURI) else hp:error('err:XS0052', $resourceURI)" mode="#current"/>
	</xsl:template>
	
	
	
	
	<!-- Ignore documentation. -->
	<xsl:template match="xproc:documentation" mode="xproc:parse2"/>
	
	
	
	
	<!--  -->
	<xsl:template match="xproc:*[@hp:step = 'true']" mode="xproc:parse2">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			
			<xsl:if test="not(xproc:input[@port = 'source'])">
				<xsl:choose>
					<xsl:when test="preceding-sibling::xproc:*[@hp:step = 'true']">
						<p:input port="source">
							<p:pipe port="result" step="{(preceding-sibling::xproc:*[@hp:step = 'true'][1]/@name, generate-id(preceding-sibling::xproc:*[@hp:step = 'true'][1]))[1]}"/>
						</p:input>
					</xsl:when>
					<xsl:otherwise>
						<p:input port="source"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="not(xproc:output[@port = 'result'])">
				<p:output port="result"/>
			</xsl:if>
			
			<xsl:apply-templates select="* | text()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	
	
	
	<!-- Replicate XProc elements, attributes and the elements descendants. -->
	<xsl:template match="xproc:*" mode="xproc:parse2">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="* | text()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	
	
	
	<!-- Ignore any elements not in the XProc namespace. -->
	<xsl:template match="*" mode="xproc:parse1 xproc:parse2">
		<xsl:copy-of select="."/>
	</xsl:template>
	
</xsl:transform>