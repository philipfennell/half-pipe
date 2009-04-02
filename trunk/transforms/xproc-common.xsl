<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform
		xmlns:err="http://www.w3.org/ns/xproc-error"
		xmlns:hp="http://code.google.com/p/half-pipe/"
		xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:saxon="http://saxon.sf.net/"
		xmlns:t="http://xproc.org/ns/testsuite"
		xmlns:xhtml="http://www.w3.org/1999/xhtml"
		xmlns:xproc="http://www.w3.org/ns/xproc"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:XSLT="http://www.w3.org/1999/XSL/Transform/output"
		exclude-result-prefixes="saxon t xhtml xproc xsl"
		version="2.0">
	
	<xsl:output name="xml" method="xml" indent="yes" encoding="UTF-8" media-type="application/xml"
			saxon:indent-spaces="4"/>
	
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
	
	
	
	
	<!-- Wrapper function for saxon:serialize. 
		 Returns a string representation of the passed document. -->
	<xsl:function name="hp:serialize" as="xs:string?">
		<xsl:param name="document" as="node()"/>
		<xsl:param name="format" as="xs:string"/>
		
		<xsl:value-of select="saxon:serialize($document, 'xml')"/>
	</xsl:function>
	
	
	<!-- Wrapper function for saxon:compile-stylesheet.
		 Returns the compile transform. -->
	<xsl:function name="hp:compile-transform">
		<xsl:param name="transformDoc" as="document-node()"/>
		
		<xsl:sequence select="saxon:compile-stylesheet($transformDoc)"/>
	</xsl:function>
	
	
	<!-- Wrapper function for saxon:transform. 
		 Returns the result. -->
	<xsl:function name="hp:transform" as="document-node()?">
		<xsl:param name="compiledTransform"/>
		<xsl:param name="source" as="document-node()*"/>
		
		<xsl:sequence select="saxon:transform($compiledTransform, $source)"/>
	</xsl:function>
	
	
	<!-- Wrapper function for saxon:transform. 
		 Returns the result. -->
	<xsl:function name="hp:transform" as="document-node()?">
		<xsl:param name="compiledTransform"/>
		<xsl:param name="source" as="document-node()*"/>
		<xsl:param name="parameters" as="item()*"/>
		
		<xsl:sequence select="saxon:transform($compiledTransform, $source, $parameters)"/>
	</xsl:function>
	
	
	<!-- Wrapper function for saxon:evaluate(xs:string). 
		 Returns the result of evaluating the XPath expression with 
		 respect to the context node. -->
	<xsl:function name="hp:evaluate" as="item()*">
		<xsl:param name="contextNode" as="node()"/>
		<xsl:param name="xpathExpression" as="xs:string?"/>
		
		<xsl:for-each select="$contextNode">
			<xsl:value-of select="saxon:evaluate($xpathExpression)"/>
		</xsl:for-each>
	</xsl:function>
	
	
	<!-- Wrapper function for saxon:parse(xs:string).
		 Returns a parsed XML document. -->
	<xsl:function name="hp:parse" as="document-node()*">
		<xsl:param name="string" as="xs:string?"/>
		<xsl:sequence select="saxon:parse($string)"/>
	</xsl:function>
	
	
	<!-- Wrapper function for saxon:path(). 
		 Returns the XPath location path of the context node. -->
	<xsl:function name="hp:path" as="xs:string?">
		<xsl:param name="contextNode" as="node()"/>
		<xsl:for-each select="$contextNode">
			<xsl:value-of select="saxon:path()"/>
		</xsl:for-each>
	</xsl:function>
	
	
	
	
	<!-- Returns an XSLT transform with a new namespace to allow it to be 
		embedded in the result transform. -->
	<xsl:function name="hp:embedStylesheet" as="element()">
		<xsl:param name="stylesheetDoc" as="element()"/>
		<xsl:apply-templates select="$stylesheetDoc" mode="hp:changeNS">
			<xsl:with-param name="sourceNS" select="'http://www.w3.org/1999/XSL/Transform'" as="xs:string" tunnel="yes"/>
			<xsl:with-param name="targetNS" select="'http://www.w3.org/1999/XSL/Transform/embedded'" as="xs:string" tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:function>
	
	<!-- Returns an embedded XSLT transform in its correct namespace.  -->
	<xsl:function name="hp:extractStylesheet" as="document-node()">
		<xsl:param name="stylesheet" as="element()"/>
		
		<xsl:document>
			<xsl:apply-templates select="$stylesheet" mode="hp:changeNS">
				<xsl:with-param name="sourceNS" select="'http://www.w3.org/1999/XSL/Transform/embedded'" as="xs:string" tunnel="yes"/>
				<xsl:with-param name="targetNS" select="'http://www.w3.org/1999/XSL/Transform'" as="xs:string" tunnel="yes"/>
			</xsl:apply-templates>
		</xsl:document>
	</xsl:function>
	
	<!-- Changes a document fragments elements that match the source namespace 
		to the target namespace. -->
	<xsl:template match="*" mode="hp:changeNS">
		<xsl:param name="sourceNS" as="xs:string" tunnel="yes"/>
		<xsl:param name="targetNS" as="xs:string" tunnel="yes"/>
		
		<xsl:choose>
			<xsl:when test="namespace-uri() = $sourceNS">
				<xsl:element name="{local-name()}" namespace="{$targetNS}">
					<xsl:copy-of select="@*"/>
					<xsl:apply-templates select="* | text()" mode="#current"/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:copy-of select="@*" copy-namespaces="no"/>
					<xsl:apply-templates select="* | text()" mode="#current"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	
	
	
	
	<!-- Returns the parent directory URI. -->
	<xsl:function name="hp:baseURI" as="xs:string">
		<xsl:param name="contextNode"/>
		
		<xsl:value-of select="concat(string-join(reverse(subsequence(reverse(tokenize(base-uri($contextNode), '/')), 2)), '/'), '/')"/>
	</xsl:function>
	
	
	
	
	<!-- Displays the error message for the passed error code on stdout and terminates the transformation. -->
	<xsl:function name="hp:error" as="element()">
		<xsl:param name="errorCode" as="xs:string"/>
		<xsl:param name="arg" as="xs:string*"/>
		<xsl:variable name="errorMessage" select="concat($arg, ' - ', hp:getErrorMessage($errorCode))"/>
		
		<xsl:message terminate="no">[XProc][<xsl:value-of select="$errorCode"/>][FATAL] <xsl:value-of select="$errorMessage"/></xsl:message>
		<xsl:element name="{$errorCode}" namespace="http://www.w3.org/ns/xproc-error"><xsl:value-of select="$errorMessage"/></xsl:element>
	</xsl:function>
	
	
	
	
	<!-- Displays the error message on stdout and terminates the transformation. -->
	<xsl:function name="t:error">
		<xsl:param name="arg" as="xs:string*"/>
		<xsl:param name="message" as="xs:string"/>
		
		<xsl:message terminate="yes">[XProc][TestSuite][FATAL] <xsl:value-of select="$arg"/> - <xsl:value-of select="$message"/></xsl:message>
	</xsl:function>
	
	
	
	
	<!-- Returns the error message text for the passed error code. -->
	<xsl:function name="hp:getErrorMessage" as="xs:string">
		<xsl:param name="errorCode" as="xs:string"/>
		<xsl:variable name="errorCodesURI" select="'../docs/error-codes.xml'"/>
		<xsl:variable name="errorCodesDoc" select="if (doc-available($errorCodesURI)) then doc($errorCodesURI) else ()" as="document-node()?"/>
		
		<xsl:value-of select="$errorCodesDoc//xhtml:dt[xhtml:code/text() = $errorCode]/following-sibling::xhtml:dd[1]/xhtml:p[1]"/>
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
			<XSLT:apply-templates select="*|text()|comment()|processing-instruction()" mode="#current"/>
		</XSLT:copy>
	</xsl:template>
	
	
	
	
	<!-- Returns the name of the preceding step (in document order) or 'source' 
		if there are no preceding steps.. -->
	<xsl:function name="hp:precedingStepName" as="xs:string">
		<xsl:param name="contextNode" as="element()"/>
		<xsl:variable name="precedingStep" select="$contextNode/preceding-sibling::xproc:*[@hp:step][1]"/>
		
		<xsl:sequence select="if ($precedingStep) then $precedingStep/@name else $contextNode/ancestor::xproc:declare-step/@name"/>
	</xsl:function>
	
	
	
	
	<!-- Returns '*' for sequence = true, otherwise '?'. -->
	<xsl:function name="hp:sequenceQualifier" as="xs:string">
		<xsl:param name="port" as="element()?"/>
		<xsl:value-of select="if ($port/@sequence = 'true') then '*' else '?'"/>
	</xsl:function>
	
</xsl:transform>