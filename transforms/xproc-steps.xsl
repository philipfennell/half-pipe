<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform
		xmlns:c="http://www.w3.org/ns/xproc-step"
		xmlns:err="http://www.w3.org/ns/xproc-error"
		xmlns:hp="http://code.google.com/p/half-pipe/"
		xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:saxon="http://saxon.sf.net/"
		xmlns:xproc="http://www.w3.org/ns/xproc"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:XSLT="http://www.w3.org/1999/XSL/Transform/output"
		exclude-result-prefixes="c"
		version="2.0">
	
	
	<xsl:namespace-alias stylesheet-prefix="XSLT" result-prefix="xsl"/>
	
	
	<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:dcterms="http://purl.org/dc/terms/">
		<rdf:Description rdf:about="$Source: $">
			<dcterms:creator>Philip A. R. Fennell</dcterms:creator>
			<dcterms:hasVersion>$Revision: $</dcterms:hasVersion>
			<dcterms:dateSubmitted>$Date: $</dcterms:dateSubmitted>
			<dcterms:format>text/xsl</dcterms:format>
			<dcterms:title>XProc Steps</dcterms:title>
			<dcterms:description>Currently implemented XProc steps.</dcterms:description>
		</rdf:Description>
	</rdf:RDF>

	<!-- Extracts content from an in-line document declaration. -->
	<xsl:template match="p:input/p:inline" mode="xproc:input">
		<xsl:copy-of select="*"/>
	</xsl:template>
	
	
	<!-- Extracts content from an external document declaration. -->
	<xsl:template match="p:input/p:document" mode="xproc:input">
		<xsl:variable name="resourceURI" select="resolve-uri(@href)"/>
		<xsl:copy-of select="if (doc-available($resourceURI)) then doc($resourceURI) else hp:error('err:XD0002', $resourceURI)"/>
	</xsl:template>
	
	
	
	
	<!-- Creates input port parameters for step templates. -->
	<xsl:template match="p:input" mode="xproc:step-inputs">
		<XSLT:param name="input-{@port}" as="document-node(){hp:sequenceQualifier(.)}" tunnel="yes"/>
	</xsl:template>
	
	
	
	
	<!-- Ignore input elements in this mode. -->
	<xsl:template match="p:input" mode="xproc:step" priority="12" hp:implemented="true"/>
	
	
	
	
	<!-- Ignore output elements in this mode. -->
	<xsl:template match="p:output" mode="xproc:step" priority="12"/>
	
	
	
	
	<!-- Catch-all to ensure errors propergate through the pipeline to the end. -->
	<xsl:template match="xproc:*" mode="xproc:step" priority="10">
		<XSLT:template match="err:*" mode="{name()}-{@name}" priority="10">
			<XSLT:copy-of select="."/>
		</XSLT:template>
		
		<xsl:next-match/>
	</xsl:template>
	
	
	
	
	<!-- Creates an identity transform for the p:identity step. -->
	<xsl:template match="xproc:identity" mode="xproc:step" hp:implemented="true">
		<XSLT:template match="*" mode="{name()}-{@name}">
			<XSLT:copy-of select="."/>
		</XSLT:template>
	</xsl:template>
	
	
	
	
	<!-- Deletes (ignores) nodes that are matching the 'match' XPath expression. -->
	<xsl:template match="xproc:delete" mode="xproc:step" hp:implemented="true">
		<XSLT:template match="{@match}" mode="{name()}-{@name}"/>
		<xsl:call-template name="hp:identityTransform"/>
	</xsl:template>
	
	
	
	
	<!-- Inserts the new node with respect to the matching node(s) and 
		according to the position declaration. -->
	<xsl:template match="xproc:insert" mode="xproc:step" priority="2" hp:implemented="true">
		<XSLT:template match="{@match}" mode="{name()}-{@name}">
			<xsl:next-match>
				<xsl:with-param name="insertionNodes" as="element()*">
					<xsl:apply-templates select="p:input[@port = 'insertion']/*" mode="xproc:input"/>
				</xsl:with-param>
			</xsl:next-match>
		</XSLT:template>
		<xsl:call-template name="hp:identityTransform"/>
	</xsl:template>
	
	
	<!-- Insert as the 'first child' of matching node(s). -->
	<xsl:template match="xproc:insert[@position = 'first-child']" mode="xproc:step">
		<xsl:apply-templates select="p:input" mode="xproc:step-inputs"/>
		
		<XSLT:copy copy-namespaces="no">
			<XSLT:copy-of select="@*"/>
			<XSLT:sequence select="$input-insertion"/>
			<XSLT:apply-templates select="*|text()" mode="#current"/>
		</XSLT:copy>
	</xsl:template>
	
	
	<!-- Insert as the 'last child' of matching node(s). -->
	<xsl:template match="xproc:insert[@position = 'last-child']" mode="xproc:step">
		<xsl:apply-templates select="p:input" mode="xproc:step-inputs"/>
		
		<XSLT:copy copy-namespaces="no">
			<XSLT:copy-of select="@*"/>
			<XSLT:apply-templates select="*|text()" mode="#current"/>
			<XSLT:sequence select="$input-insertion"/>
		</XSLT:copy>
	</xsl:template>
	
	
	<!-- Insert 'before' matching node(s). -->
	<xsl:template match="xproc:insert[@position = 'before']" mode="xproc:step">
		<xsl:apply-templates select="p:input" mode="xproc:step-inputs"/>
		
		<XSLT:sequence select="$input-insertion"/>
		<xsl:choose>
			<xsl:when test="matches(@match, 'processing-instruction\(.*\)|comment\(\)')">
				<XSLT:copy-of select="."/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="hp:deepCopy"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<!-- Insert 'after' matching node(s). -->
	<xsl:template match="xproc:insert[@position = 'after']" mode="xproc:step">
		<xsl:apply-templates select="p:input" mode="xproc:step-inputs"/>
		
		<xsl:choose>
			<xsl:when test="matches(@match, 'processing-instruction\(.*\)|comment\(\)')">
				<XSLT:copy-of select="."/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="hp:deepCopy"/>
			</xsl:otherwise>
		</xsl:choose>
		<XSLT:sequence select="$input-insertion"/>
	</xsl:template>
	
	
	
	
	<!-- Adds an attribute to the matching node(s). -->
	<xsl:template match="xproc:add-attribute" mode="xproc:step" hp:implemented="true">
		<XSLT:template match="{@match}" mode="{name()}-{@name}">
			<XSLT:copy copy-namespaces="no">
				<XSLT:copy-of select="@*"/>
				<XSLT:attribute>
					<xsl:apply-templates select="(@attribute-value, p:with-option[@name = 'attribute-value'])[1]" mode="xproc:add-attribute"/>
					<xsl:apply-templates select="(@attribute-name, p:with-option[@name = 'attribute-name'])[1]" mode="xproc:add-attribute"/>
				</XSLT:attribute>
				<XSLT:apply-templates select="*|text()" mode="#current"/>
			</XSLT:copy>
		</XSLT:template>
		<xsl:call-template name="hp:identityTransform"/>
	</xsl:template>
	
	<!-- Takes the value of the 'attribute-value' or 'attribute-name' attribute. -->
	<xsl:template match="@attribute-name" mode="xproc:add-attribute">
		<xsl:attribute name="name" select="."/>
	</xsl:template>
	
	<!-- Takes the value of the 'attribute-value' or 'attribute-name' attribute. -->
	<xsl:template match="@attribute-value" mode="xproc:add-attribute">
		<xsl:attribute name="select" select="concat('''', ., '''')"/>
	</xsl:template>
	
	<!-- Evaluates the XPath expression of the select attribute. -->
	<xsl:template match="p:with-option[@name = 'attribute-value']" mode="xproc:add-attribute">
		<XSLT:value-of select="saxon:evaluate('{@select}')"/>
	</xsl:template>
	
	<!-- Evaluates the XPath expression of the select attribute. -->
	<xsl:template match="p:with-option[@name = 'attribute-name']" mode="xproc:add-attribute">
		<xsl:variable name="attributeName" select="saxon:evaluate(@select)" as="xs:string"/>
		<xsl:variable name="namespacePrefix" select="substring-before($attributeName, ':')" as="xs:string?"/>
		<xsl:attribute name="name" select="$attributeName"/>
		<xsl:if test="$namespacePrefix">
			<xsl:attribute name="namespace" select="namespace-uri-for-prefix($namespacePrefix, ..)"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="text()" mode="xproc:add-attribute"/>
	
	
	
	
	<!-- Generates a log instruction. -->
	<xsl:template match="xproc:log" mode="xproc:xstep" hp:implemented="false">
		<XSLT:template match="*" mode="{name()}-{@name}">
			<hp:log href="{@href}">
				<XSLT:copy-of select="." copy-namespaces="no"/>
			</hp:log>
		</XSLT:template>
	</xsl:template>
	
	
	<!-- The 'template-name' option is not supported. -->
	<xsl:template match="xproc:xslt[@template-name]" mode="xproc:step">
		<XSLT:template match="/" mode="{name()}-{@name}">
			<err:HP0002>The <xsl:value-of select="name()"/> step option 'template-name' is not supported.</err:HP0002>
		</XSLT:template>
	</xsl:template>
	
	
	<!-- The 'initial-mode' option is not supported. -->
	<xsl:template match="xproc:xslt[@initial-mode]" mode="xproc:step">
		<XSLT:template match="/" mode="{name()}-{@name}">
			<err:HP0002>The <xsl:value-of select="name()"/> step option 'initial-mode' is not supported.</err:HP0002>
		</XSLT:template>
	</xsl:template>
	
	
	<!-- Checks the version requested and that supported match before transforming. -->
	<xsl:template match="xproc:xslt[@version]" mode="xproc:step">
		<XSLT:template match="/" mode="{name()}-{@name}">
			<xsl:apply-templates select="p:input" mode="xproc:step-inputs"/>
			<XSLT:choose>
				
				<XSLT:when test="number('{@version}') = number($input-stylesheet/xsl:*/@version)">
					<XSLT:variable name="compiledTransform" select="saxon:compile-stylesheet($input-stylesheet)"/>
					<XSLT:copy-of select="saxon:transform($compiledTransform, .)"/>
				</XSLT:when>
				<XSLT:otherwise>
					<XSLT:copy-of select="hp:error('err:XC0038', 'XSLT Version {@version} is not supported')"/>
				</XSLT:otherwise>
			</XSLT:choose>
		</XSLT:template>
	</xsl:template>
	
	
	
	
	<!-- Transforms the input source port using the passed stylesheet. -->
	<xsl:template match="xproc:xslt" mode="xproc:step" hp:implemented="true">
		<XSLT:template match="/" mode="{name()}-{@name}">
			<xsl:apply-templates select="p:input" mode="xproc:step-inputs"/>
			<XSLT:variable name="compiledTransform" select="saxon:compile-stylesheet($input-stylesheet)"/>
			<XSLT:copy-of select="saxon:transform($compiledTransform, .)"/>
		</XSLT:template>
	</xsl:template>
	
	
	
	
	<!-- Wraps the context node in a container element. -->
	<xsl:template match="xproc:wrap-sequence[@group-adjacent]" mode="xproc:step">
		<XSLT:template match="/hp:documents" mode="{name()}-{@name}">
			<err:HP0002>The <xsl:value-of select="name()"/> step option 'group-adjacent' is not supported.</err:HP0002>
		</XSLT:template>
	</xsl:template>
	
	
	<!-- Wraps the context node in a container element. -->
	<xsl:template match="xproc:wrap-sequence" mode="xproc:step" hp:implemented="true">
		<XSLT:template match="/" mode="{name()}-{@name}">
			<XSLT:element name="{@wrapper}">
				<XSLT:copy-of select="." copy-namespaces="no"/>
			</XSLT:element>
		</XSLT:template>
	</xsl:template>
	
	
	
	
	<!-- Counts the number of documents in the source input sequence.  -->
	<xsl:template match="xproc:count" mode="xproc:step" hp:implemented="false">
		<XSLT:template match="/" mode="{name()}-{@name}">
			<XSLT:param name="input-source" as="document-node()*"/>
			<XSLT:variable name="limit" select="{if (@limit) then @limit else 0}" as="xs:integer"/>
			<XSLT:variable name="count" select="count($input-source/*)" as="xs:integer"/>
			<c:result><XSLT:value-of select="if ($limit gt 0) then (if ($count le $limit) then $count else $limit) else $count"/></c:result>
		</XSLT:template>
	</xsl:template>
	
	
	
	
	<!-- Guard template, creates an identity transform that allows the step to 
		have no effect on the input. Basically, the step is ignored if it is 
		not supported. -->
	<xsl:template match="xproc:*" mode="xproc:step">
		<xsl:message>[XProc][Compiler] Step '<xsl:value-of select="saxon:path()"/>' is not supported. It will be ignored at run-time.</xsl:message>
		
		<XSLT:template match="/" mode="{name()}-{@name}">
			<err:HP0001>The step '<xsl:value-of select="name()"/>' is not supported.</err:HP0001>
		</XSLT:template>
	</xsl:template>
	
	
	
	
	<!--  -->
	<!--<xsl:template match="xproc:for-each" mode="xproc:compile" hp:implemented="false">
		<XSLT:variable name="{@name}" as="element(){hp:sequenceQualifier(xproc:output)}">
		<XSLT:for-each select="{xproc:iteration-source/@select}">
		<XSLT:copy>
		<XSLT:copy-of select="@*"/>
		
		<xsl:apply-templates select="*|text()" mode="#current"/>
		</XSLT:copy>
		</XSLT:for-each>
		</XSLT:variable>
	</xsl:template>-->

</xsl:transform>