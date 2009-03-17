<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform
	xmlns:hp="http://code.google.com/p/half-pipe/"
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:saxon="http://saxon.sf.net/"
	xmlns:t="http://xproc.org/ns/testsuite"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:xproc="http://www.w3.org/ns/xproc"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:XSLT="http://www.w3.org/1999/XSL/Transform/output"
	exclude-result-prefixes="saxon xhtml xproc xsl"
	version="2.0">
	
	
	<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:dcterms="http://purl.org/dc/terms/">
		<rdf:Description rdf:about="$Source: $">
			<dcterms:creator>Philip A. R. Fennell</dcterms:creator>
			<dcterms:hasVersion>$Revision: $</dcterms:hasVersion>
			<dcterms:dateSubmitted>$Date: $</dcterms:dateSubmitted>
			<dcterms:format>application/xslt+xml</dcterms:format>
			<dcterms:title>Half-pipe Utility functions and templates</dcterms:title>
			<dcterms:description>Pipeline functions and templates common to the parser, compiler and processor.</dcterms:description>
		</rdf:Description>
	</rdf:RDF>
	
	
	
	
	
	
	<!-- Returns the parent directory URI. -->
	<xsl:function name="hp:baseURI" as="xs:string">
		<xsl:param name="contextNode"/>
		
		<xsl:value-of select="concat(string-join(reverse(subsequence(reverse(tokenize(base-uri($contextNode), '/')), 2)), '/'), '/')"/>
	</xsl:function>
	
	
	
	
	<!-- Displays the error message for the passed error code on stdout and terminates the transformation. -->
	<xsl:function name="hp:error" as="element()">
		<xsl:param name="errorCode" as="xs:string"/>
		<xsl:param name="arg" as="xs:string"/>
		<xsl:variable name="errorMessage" select="concat($arg, ' - ', hp:getErrorMessage($errorCode))"/>
		
		<xsl:message terminate="no">[XProc][<xsl:value-of select="$errorCode"/>][FATAL] <xsl:value-of select="$errorMessage"/></xsl:message>
		<hp:error code="{$errorCode}"><xsl:value-of select="$errorMessage"/></hp:error>
	</xsl:function>
	
	
	
	
	<!-- Displays the error message on stdout and terminates the transformation. -->
	<xsl:function name="t:error">
		<xsl:param name="arg" as="xs:string"/>
		<xsl:param name="message" as="xs:string"/>
		
		<xsl:message terminate="yes">[XProc][TestSuite][FATAL] <xsl:value-of select="$arg"/> - <xsl:value-of select="$message"/></xsl:message>
	</xsl:function>
	
	
	
	
	<!-- Returns the error message text for the passed error code. -->
	<xsl:function name="hp:getErrorMessage" as="xs:string">
		<xsl:param name="errorCode" as="xs:string"/>
		<xsl:variable name="errorCodesURI" select="'../docs/error-codes.xml'"/>
		<xsl:variable name="errorCodesDoc" select="if (doc-available($errorCodesURI)) then doc($errorCodesURI) else ()" as="document-node()?"/>
		
		<xsl:value-of select="$errorCodesDoc//xhtml:dt[xhtml:code = $errorCode]/following-sibling::xhtml:dd[1]/xhtml:p[1]"/>
	</xsl:function>
	
	
	
	
	<!-- Boiler-plate identity transform -->
	<xsl:template name="hp:identityTransform">
		<xsl:param name="message" as="element()*"/>
		
		<XSLT:template match="*" mode="{name()}-{@name}">
			<xsl:copy-of select="$message"/>
			<xsl:call-template name="hp:deepCopy"/>
		</XSLT:template>
	</xsl:template>
	
	
	
	
	<!-- Boiler-plate 'deep' node cloning (node, its attributes and descendants). -->
	<xsl:template name="hp:deepCopy">
		<XSLT:copy copy-namespaces="no">
			<XSLT:copy-of select="@*"/>
			<XSLT:apply-templates select="*|text()" mode="#current"/>
		</XSLT:copy>
	</xsl:template>
	
	
	
	
	<!-- Returns the name of the preceding step (in document order) or 'source' 
		if there are no preceding steps.. -->
	<xsl:function name="hp:precedingStepName" as="xs:string">
		<xsl:param name="contextNode" as="element()"/>
		<xsl:variable name="precedingStep" select="$contextNode/preceding-sibling::xproc:*[@hp:step][1]"/>
		
		<xsl:sequence select="if ($precedingStep) then $precedingStep/@name else 'source'"/>
	</xsl:function>
	
	
	
	
	<!-- Returns '*' for sequence = true, otherwise '?'. -->
	<xsl:function name="hp:sequenceQualifier" as="xs:string">
		<xsl:param name="port" as="element()?"/>
		<xsl:value-of select="if ($port/@sequence = 'true') then '*' else '?'"/>
	</xsl:function>
	
</xsl:transform>