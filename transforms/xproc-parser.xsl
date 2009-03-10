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
			<dcterms:format>text/xsl</dcterms:format>
			<dcterms:title>Half-pipe XProc Parser</dcterms:title>
			<dcterms:description>Pipeline Parser (xproc:parse).</dcterms:description>
		</rdf:Description>
	</rdf:RDF>
	
	<xsl:strip-space elements="*"/>
	
	
	<xsl:template match="/" >
		<xsl:apply-templates select="*" mode="xproc:parse"/>
	</xsl:template>
	
	
	
	
	<!--  -->
	<xsl:template match="/xproc:pipeline|/xproc:declare-step" mode="xproc:parse">
		<xsl:copy>
			<xsl:namespace name="hp" select="'http://code.google.com/p/half-pipe/'"/>
			<xsl:namespace name="saxon" select="'http://saxon.sf.net/'"/>
			<xsl:namespace name="xproc" select="'http://www.w3.org/ns/xproc'"/>
			<xsl:namespace name="xsl" select="'http://www.w3.org/1999/XSL/Transform'"/>
			
			<xsl:copy-of select="@*"/>
			
			<xsl:apply-templates select="*" mode="#current">
				<xsl:with-param name="baseURI" select="if (@xml:base) then resolve-uri(@xml:base, base-uri(root())) else base-uri(root())" as="xs:anyURI?" tunnel="yes"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
	
	
	
	<!--  -->
	<xsl:template match="xproc:import" mode="xproc:parse">
		<xsl:param name="baseURI" as="xs:anyURI?" tunnel="yes"/>
		<xsl:variable name="resourceURI" select="resolve-uri(@href, $baseURI)" as="xs:anyURI"/>
		
		<xsl:apply-templates select="if (doc-available($resourceURI)) then doc($resourceURI) else hp:error('err:XS0052', $resourceURI)" mode="#current"/>
	</xsl:template>
	
	
	
	
	<!-- Ignore documentation. -->
	<xsl:template match="xproc:documentation" mode="xproc:parse"/>
	
	
	
	
	<!--  -->
	<xsl:template match="xproc:add-attribute | xproc:add-xml-base | xproc:count | xproc:delete | hp:error | xproc:filter | xproc:for-each | xproc:identity | xproc:insert | xproc:label-elements | xproc:load | xproc:log | xproc:make-absolute-uris | xproc:namespace-rename | xproc:pack | xproc:rename | xproc:replace | xproc:store | xproc:string-replace | xproc:unwrap | xproc:wrap | xproc:wrap-sequence | xproc:xinclude | xproc:xslt" mode="xproc:parse">
		<xsl:copy>
			<xsl:attribute name="name" select="generate-id()"/>
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="hp:step" select="'true'"/>
			
			<!--<xsl:if test="not(xproc:input[@port = 'source'])">
				<p:input port="source">
				<p:pipe port="result" step="{(preceding-sibling::xproc:*[1]/@name, generate-id(preceding-sibling::xproc:*[1]))[1]}"/>
				</p:input>
				</xsl:if>-->
			
			<xsl:apply-templates select="xproc:* | text()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	
	
	
	<!-- Replicate XProc elements, attributes and the elements descendants. -->
	<xsl:template match="xproc:*" mode="xproc:parse">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="* | text()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	
	
	
	<!-- Ignore any elements not in the XProc namespace. -->
	<xsl:template match="*" mode="xproc:parse">
		<xsl:copy-of select="."/>
	</xsl:template>
</xsl:transform>