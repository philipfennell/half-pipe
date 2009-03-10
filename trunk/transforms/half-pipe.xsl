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
			<dcterms:format>text/xsl</dcterms:format>
			<dcterms:title>Half-pipe</dcterms:title>
			<dcterms:description>An XSLT 2.0 Implementation of the W3C's XML Pipeline Language (XProc).</dcterms:description>
		</rdf:Description>
	</rdf:RDF>
	
	<xsl:strip-space elements="*"/>
	
	
	
	
	<!--  -->
	<xsl:template match="/">
		<!-- Expand the pipeline to its full canonical form. -->
		<xsl:variable name="expandedPipeline" as="document-node()">
			<xsl:document>
				<xsl:apply-templates select="*" mode="xproc:expand"/>
			</xsl:document>
		</xsl:variable>
		
		<xsl:if test="$MODE = 'debug'">
			<xsl:result-document format="debug" href="../debug/expandedPipeline.xml">
				<xsl:copy-of select="$expandedPipeline"/>
			</xsl:result-document>
		</xsl:if>
		
		<!-- Compile the expanded pipeline into an executable transform. -->
		<xsl:variable name="compiledPipeline" as="document-node()">
			<xsl:document>
				<xsl:apply-templates select="$expandedPipeline" mode="xproc:compile"/>
			</xsl:document>
		</xsl:variable>
		
		<xsl:if test="$MODE = 'debug'">
			<xsl:result-document format="debug" href="../debug/compiledPipeline.xsl">
				<xsl:copy-of select="$compiledPipeline"/>
			</xsl:result-document>
		</xsl:if>
		
		
		<xsl:copy-of select="$compiledPipeline"/>
	</xsl:template>
	
	
	
	
	
	
	<!-- === Pipeline Expansion (xproc:expand). ============================ -->
	
	<!--  -->
	<xsl:template match="/xproc:pipeline|/xproc:declare-step" mode="xproc:expand">
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
	<xsl:template match="xproc:import" mode="xproc:expand">
		<xsl:param name="baseURI" as="xs:anyURI?" tunnel="yes"/>
		<xsl:variable name="resourceURI" select="resolve-uri(@href, $baseURI)" as="xs:anyURI"/>
		
		<xsl:apply-templates select="if (doc-available($resourceURI)) then doc($resourceURI) else hp:error('err:XS0052', $resourceURI)" mode="#current"/>
	</xsl:template>
	
	
	
	
	<!-- Ignore documentation. -->
	<xsl:template match="xproc:documentation" mode="xproc:expand"/>
	
	
	
	
	<!--  -->
	<xsl:template match="xproc:add-attribute | xproc:add-xml-base | xproc:count | xproc:delete | hp:error | xproc:filter | xproc:for-each | xproc:identity | xproc:insert | xproc:label-elements | xproc:load | xproc:log | xproc:make-absolute-uris | xproc:namespace-rename | xproc:pack | xproc:rename | xproc:replace | xproc:store | xproc:string-replace | xproc:unwrap | xproc:wrap | xproc:wrap-sequence | xproc:xinclude | xproc:xslt" mode="xproc:expand">
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
	<xsl:template match="xproc:*" mode="xproc:expand">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="* | text()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	
	
	
	<!-- Replicate attributes. -->
	<!--<xsl:template match="attribute()" mode="xproc:expand">
		<xsl:copy-of select="."/>
	</xsl:template>-->
	
	
	
	
	<!-- Ignore any elements not in the XProc namespace. -->
	<xsl:template match="*" mode="xproc:expand">
		<xsl:copy-of select="."/>
	</xsl:template>
	
	
	
	
	
	
	<!-- === Pipeline Compilation (xproc:compile). ========================= -->
	
	<xsl:template match="/" mode="xproc:compile">
		<XSLT:transform version="2.0">
			<xsl:variable name="contextNode" select="*"/>
			
			<!-- Add namespace declarations from the source pipeline. -->
			<xsl:for-each select="in-scope-prefixes(*)">
				<xsl:namespace name="{.}" select="namespace-uri-for-prefix(., $contextNode)"/>
			</xsl:for-each>
			
			<!-- Ensure only the necessary namespace prefixes appear in the result. -->
			<xsl:attribute name="exclude-result-prefixes" select="in-scope-prefixes(*)"/>
			
			<!-- Process the serialization definition.
				 Note: this problem wont help much in this context as the host 
				 XSLT will control the final serialization.-->
			<xsl:apply-templates select="/*/xproc:serialization" mode="xproc:serialize"/>
			
			<XSLT:output encoding="UTF-8" indent="yes" media-type="application/xml" method="xml" name="xproc:log"/>
			<XSLT:output encoding="UTF-8" indent="yes" media-type="application/xml" method="xml" name="hp:debug"/>
			
			<XSLT:strip-space elements="*"/>
			
			<!-- Start compiling the pipeline. -->
			<xsl:apply-templates select="*" mode="#current"/>
		</XSLT:transform>
	</xsl:template>
	
	
	
	
	<!-- Create the output serialization properties. -->
	<xsl:template match="xproc:serialization" mode="xproc:serialize">
		<XSLT:output>
			<xsl:apply-templates select="@* except (@port)" mode="#current"/>
			<!--<xsl:attribute name="name" select="../@name"/>-->
		</XSLT:output>
	</xsl:template>
	
	<xsl:template match="@indent | @omit-xml-declaration" mode="xproc:serialize">
		<xsl:attribute name="{name()}" select="if (. = 'true') then 'yes' else 'no'"/>
	</xsl:template>
	
	<xsl:template match="attribute()" mode="xproc:serialize">
		<xsl:attribute name="{name()}" select="."/>
	</xsl:template>
	
	
	
	
	<!-- Creates the root template for the compiled transform. -->
	<xsl:template match="xproc:pipeline | xproc:declare-step" mode="xproc:compile">
			
		<XSLT:variable name="source" as="document-node()" hp:input="source">
			<XSLT:document>
				<hp:job-bag>
					<hp:input port="source">
						<XSLT:sequence select="/"/>
					</hp:input>
					<hp:output port="result">
						<XSLT:sequence select="/"/>
					</hp:output>
				</hp:job-bag>
			</XSLT:document>
		</XSLT:variable>
		
		<!-- Declare the pipeline steps as global variable so that their output
			 port can be accessed from any step. -->
		<xsl:apply-templates select="*" mode="xproc:pipe"/>
		
		<XSLT:template match="/">
			<xsl:apply-templates select="xproc:log" mode="xproc:log"/>
			
			<XSLT:apply-templates select="${xproc:*[last()]/@name}" mode="xproc:result" hp:output="result"/>
		</XSLT:template>
		
		<!-- Send the result of the last step to the result of the transform. 
			 If debug is on then write the final job-bag to the 'debug' directory.-->
		<XSLT:template match="hp:job-bag" mode="xproc:result">
			<xsl:if test="$MODE = 'debug'">
				<XSLT:result-document href="../debug/job-bag.xml" format="hp:debug">
					<XSLT:sequence select="."/>
				</XSLT:result-document>
			</xsl:if>
			
			<XSLT:sequence select="hp:output[@port = 'result']/*"/>
			<XSLT:apply-templates select="*" mode="#current"/>
		</XSLT:template>
		
		<!-- Outputs the result of the named port to a URI. -->
		<XSLT:template match="hp:job-bag/hp:log" mode="xproc:result">
			<XSLT:result-document hp:port="{@name}" href="{{@href}}" format="xproc:log">
				<XSLT:sequence select="*"/>
			</XSLT:result-document>
		</XSLT:template>
		
		<!-- Ignore text nodes in this mode. -->
		<XSLT:template match="text()" mode="xproc:result"/>
		
		
		<!-- Build the step processing templates called by the processing sequence above. -->
		<xsl:apply-templates select="* except(xproc:library, xproc:pipeline)" mode="xproc:step"/>
	</xsl:template>
	
	
	
	
	
	
	
	
	
	<!-- Don't create a variable for xproc:log steps, as a temporary tree, the 
		 xsl:result-document won't work. -->
	<!--	<xsl:template match="xproc:log" mode="xproc:pipe"/>-->
	
	
	
	
	<!-- Creates a variable to hold the results of the p:identity step. -->
	<xsl:template match="xproc:log" mode="xproc:pipe">
		<XSLT:variable name="{@name}" as="document-node(){hp:sequenceQualifier(xproc:output)}"
			hp:step="{name()}">
			
			<!-- Implement port selection. -->
			<xsl:variable name="inputPort" select="'result'"/>
			
			<XSLT:document>
				<hp:job-bag>
					<hp:input port="source">
						<XSLT:sequence select="${hp:precedingStepName(current())}/hp:job-bag/hp:output[@port = '{$inputPort}']/*"/>
					</hp:input>
					<hp:output port="result">
						<XSLT:sequence select="${hp:precedingStepName(current())}/hp:job-bag/hp:output[@port = '{$inputPort}']/*"/>
					</hp:output>
					<!-- Insert xproc:log nodes. -->
					<XSLT:apply-templates select="${hp:precedingStepName(current())}/hp:job-bag/hp:output[@port = '{$inputPort}']/*" mode="{name()}-{@name}"/>
				</hp:job-bag>
			</XSLT:document>
		</XSLT:variable>
	</xsl:template>
		
	
	
	
	<!-- Creates a variable to hold the results of the p:identity step. -->
	<xsl:template match="xproc:*" mode="xproc:pipe">
		<XSLT:variable name="{@name}" as="document-node(){hp:sequenceQualifier(xproc:output)}"
				hp:step="{name()}">
			
			<!-- Implement port selection. -->
			<xsl:variable name="inputPort" select="'result'"/>
			
			<XSLT:document>
				<hp:job-bag>
					<hp:input port="source">
						<XSLT:sequence select="${hp:precedingStepName(current())}/hp:job-bag/hp:output[@port = '{$inputPort}']/*"/>
					</hp:input>
					<hp:output port="result">
						<XSLT:apply-templates select="${hp:precedingStepName(current())}/hp:job-bag/hp:output[@port = '{$inputPort}']/*" mode="{name()}-{@name}"/>
					</hp:output>
				</hp:job-bag>
			</XSLT:document>
		</XSLT:variable>
	</xsl:template>
	
	
	
	
	<!-- Creates an identity transform for the p:identity step. -->
	<xsl:template match="xproc:identity" mode="xproc:step">
		<xsl:call-template name="hp:identityTransform"/>
	</xsl:template>
	
	
	
	
	<!-- Deletes (ignores) nodes that are matching the 'match' XPath expression. -->
	<xsl:template match="xproc:delete" mode="xproc:step">
		<XSLT:template match="{@match}" mode="{name()}-{@name}"/>
		<xsl:call-template name="hp:identityTransform"/>
	</xsl:template>
	
	
	
	
	<!-- Inserts the new node with respect to the matching node(s) and 
		 according to the position declaration. -->
	<xsl:template match="xproc:insert" mode="xproc:step" priority="2">
		<XSLT:template match="{@match}" mode="{name()}-{@name}">
			<xsl:next-match>
				<xsl:with-param name="insertionNodes" as="element()*">
					<xsl:apply-templates select="p:input[@port = 'insertion']/*" mode="xproc:insert"/>
				</xsl:with-param>
			</xsl:next-match>
		</XSLT:template>
		<xsl:call-template name="hp:identityTransform"/>
	</xsl:template>
	
	
	<!-- Extracts content from an in-line document declaration. -->
	<xsl:template match="p:input[@port = 'insertion']/p:inline" mode="xproc:insert">
		<xsl:copy-of select="*"/>
	</xsl:template>
	
	
	<!-- Extracts content from an external document declaration. -->
	<xsl:template match="p:input[@port = 'insertion']/p:document" mode="xproc:insert">
		<xsl:variable name="resourceURI" select="resolve-uri(@href)"/>
		<xsl:copy-of select="if (doc-available($resourceURI)) then doc($resourceURI) else hp:error('err:XD0002', $resourceURI)"/>
	</xsl:template>
	
	
	<!-- Insert as the 'first child' of matching node(s). -->
	<xsl:template match="xproc:insert[@position = 'first-child']" mode="xproc:step">
		<xsl:param name="insertionNodes" as="element()*"/>
		
		<XSLT:copy copy-namespaces="no">
			<XSLT:copy-of select="@*"/>
			<xsl:sequence select="$insertionNodes"/>
			<XSLT:apply-templates select="*|text()" mode="#current"/>
		</XSLT:copy>
	</xsl:template>
	
	
	<!-- Insert as the 'last child' of matching node(s). -->
	<xsl:template match="xproc:insert[@position = 'last-child']" mode="xproc:step">
		<xsl:param name="insertionNodes" as="element()*"/>
		
		<XSLT:copy copy-namespaces="no">
			<XSLT:copy-of select="@*"/>
			<XSLT:apply-templates select="*|text()" mode="#current"/>
			<xsl:sequence select="$insertionNodes"/>
		</XSLT:copy>
	</xsl:template>
	
	
	<!-- Insert 'before' matching node(s). -->
	<xsl:template match="xproc:insert[@position = 'before']" mode="xproc:step">
		<xsl:param name="insertionNodes" as="element()*"/>
		
		<xsl:sequence select="$insertionNodes"/>
		<xsl:call-template name="hp:deepCopy"/>
	</xsl:template>
	
	
	<!-- Insert 'after' matching node(s). -->
	<xsl:template match="xproc:insert[@position = 'after']" mode="xproc:step">
		<xsl:param name="insertionNodes" as="element()*"/>
		
		<xsl:call-template name="hp:deepCopy"/>
		<xsl:sequence select="$insertionNodes"/>
	</xsl:template>
	
	
	
	
	<!-- Adds an attribute to the matching node(s). -->
	<xsl:template match="xproc:add-attribute" mode="xproc:step">
		<XSLT:template match="{@match}" mode="{name()}-{@name}">
			<XSLT:copy copy-namespaces="no">
				<XSLT:copy-of select="@*"/>
				<XSLT:attribute name="{@attribute-name}">
					<xsl:apply-templates select="(@attribute-value, p:with-option[@name = 'attribute-value']/@select)[1]" mode="xproc:add-attribute"/>
				</XSLT:attribute>
				<XSLT:apply-templates select="*|text()" mode="#current"/>
			</XSLT:copy>
		</XSLT:template>
		<xsl:call-template name="hp:identityTransform"/>
	</xsl:template>
	
	<!-- Takes the value of the 'attribute-value' attribute. -->
	<xsl:template match="@attribute-value" mode="xproc:add-attribute">
		<xsl:attribute name="select" select="concat('''', ., '''')"/>
	</xsl:template>
	
	<!-- Evaluates the XPath expression of the select attribute. -->
	<xsl:template match="@select" mode="xproc:add-attribute">
		<XSLT:value-of select="saxon:evaluate('{.}')"/>
	</xsl:template>
	
	
	
	
	<!--  -->
	<xsl:template match="xproc:log" mode="xproc:step">
		<XSLT:template match="*" mode="{name()}-{@name}">
			<hp:log href="{@href}">
				<XSLT:copy-of select="." copy-namespaces="no"/>
			</hp:log>
		</XSLT:template>
	</xsl:template>
	
	
	
	
	<!--  -->
	<!--<xsl:template match="xproc:for-each" mode="xproc:compile">
		<XSLT:variable name="{@name}" as="element(){hp:sequenceQualifier(xproc:output)}">
			<XSLT:for-each select="{xproc:iteration-source/@select}">
				<XSLT:copy>
					<XSLT:copy-of select="@*"/>
					
					<xsl:apply-templates select="*|text()" mode="#current"/>
				</XSLT:copy>
			</XSLT:for-each>
		</XSLT:variable>
	</xsl:template>-->
	
	
	
	
	<xsl:template match="xproc:serialization" mode="xproc:compile xproc:pipe xproc:step"/>
	
	
	<!-- Ignore library elements in these modes. -->
	<xsl:template match="xproc:library" mode="xproc:pipe xproc:step"/>
		
	
	
	
	
	
	<!-- === Pipeline Utility Functions/Templates. ========================= -->
	
	<!-- Boiler-plate identity transform -->
	<xsl:template name="hp:identityTransform">
		<XSLT:template match="*" mode="{name()}-{@name}">
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
		<xsl:param name="outputElement" as="element()?"/>
		<xsl:value-of select="if ($outputElement/@sequence = 'true') then '*' else '?'"/>
	</xsl:function>
	
	
	
	
	<!-- Displays the error message for the passed error code on stdout and terminates the transformation. -->
	<xsl:function name="hp:error">
		<xsl:param name="errorCode" as="xs:string"/>
		<xsl:param name="arg" as="xs:string"/>
		
		<xsl:message terminate="yes">[XProc][<xsl:value-of select="$errorCode"/>][FATAL] <xsl:value-of select="$arg"/> - <xsl:value-of select="hp:getErrorMessage($errorCode)"/></xsl:message>
	</xsl:function>
	
	
	
	
	<!-- Returns the error message text for the passed error code. -->
	<xsl:function name="hp:getErrorMessage" as="xs:string">
		<xsl:param name="errorCode" as="xs:string"/>
		<xsl:variable name="errorCodesURI" select="'../docs/error-codes.xml'"/>
		<xsl:variable name="errorCodesDoc" select="if (doc-available($errorCodesURI)) then doc($errorCodesURI) else ()" as="document-node()?"/>
		
		<xsl:value-of select="$errorCodesDoc//xhtml:dt[xhtml:code = $errorCode]/following-sibling::xhtml:dd[1]/xhtml:p[1]"/>
	</xsl:function>
	
</xsl:transform>