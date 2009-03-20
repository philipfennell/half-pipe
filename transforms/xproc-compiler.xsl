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
		exclude-result-prefixes="hp saxon xhtml xproc xs xsl"
		version="2.0">
	
	<xsl:import href="xproc-parser.xsl"/>
	<xsl:include href="xproc-common.xsl"/>
	
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
			<dcterms:title>XProc Compiler</dcterms:title>
			<dcterms:description>XProc Pipeline Compiler</dcterms:description>
		</rdf:Description>
	</rdf:RDF>
	
	<xsl:strip-space elements="*"/>
	
	
	
	
	<!-- Returns the compiled version of the passed XProc pipeline document. -->
	<xsl:function name="xproc:compile" as="document-node()">
		<xsl:param name="pipelineDoc" as="document-node()"/>
		<!-- Might want a mode parameter. -->
		
		<xsl:document>
			<xsl:apply-templates select="xproc:parse($pipelineDoc)" mode="xproc:compile"/>
		</xsl:document>
	</xsl:function>
	
	
	
	
	<!-- Driver template. -->
	<xsl:template match="/">
		<!-- Expand the pipeline to its full canonical form. -->
		<xsl:variable name="parsedPipeline" as="document-node()">
			<xsl:document>
				<xsl:apply-templates select="/" mode="xproc:parse"/>
			</xsl:document>
		</xsl:variable>
		
		<xsl:if test="$MODE = 'debug'">
			<xsl:result-document format="debug" href="../debug/expandedPipeline.xml">
				<xsl:copy-of select="$parsedPipeline"/>
			</xsl:result-document>
		</xsl:if>
		
		<!-- Compile the expanded pipeline into an executable transform. -->
		<xsl:variable name="compiledPipeline" as="document-node()">
			<xsl:document>
				<xsl:apply-templates select="$parsedPipeline" mode="xproc:compile"/>
			</xsl:document>
		</xsl:variable>
		
		<xsl:if test="$MODE = 'debug'">
			<xsl:result-document format="debug" href="../debug/compiledPipeline.xsl">
				<xsl:copy-of select="$compiledPipeline"/>
			</xsl:result-document>
		</xsl:if>
		
		<xsl:copy-of select="$compiledPipeline"/>
	</xsl:template>
	
	
	
	
	
	
	<!-- === Pipeline Compilation (xproc:compile). ========================= -->
	
	<xsl:template match="/" mode="xproc:compile">
		<XSLT:transform version="2.0">
			<xsl:variable name="contextNode" select="*"/>
			
			<xsl:namespace name="err" select="'http://www.w3.org/ns/xproc-error'"/>
			<xsl:namespace name="xproc" select="'http://www.w3.org/ns/xproc'"/>
			<xsl:namespace name="xs" select="'http://www.w3.org/2001/XMLSchema'"/>
			
			<!-- Add namespace declarations from the source pipeline. -->
			<xsl:for-each select="in-scope-prefixes(*)">
				<xsl:namespace name="{.}" select="namespace-uri-for-prefix(., $contextNode)"/>
			</xsl:for-each>
			
			<!-- Ensure only the necessary namespace prefixes appear in the result. -->
			<xsl:attribute name="exclude-result-prefixes" select="(in-scope-prefixes(*), 'hp xs xsl')"/>
			
			<xsl:attribute name="xml:base" select="hp:baseURI(.)"/>
			
			<!-- Include common functions and templates. -->
			<XSLT:import href="../transforms/xproc-common.xsl"/>
			
			<!-- Process the serialization definition.
				 Note: this problem wont help much in this context as the host 
				 XSLT will control the final serialization.-->
			<xsl:apply-templates select="/*/xproc:serialization" mode="xproc:serialize"/>
			
			<XSLT:output encoding="UTF-8" indent="yes" media-type="application/xml" method="xml" name="xproc:log"/>
			<XSLT:output encoding="UTF-8" indent="yes" media-type="application/xml" method="xml" name="hp:debug"/>
			
			<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
					xmlns:dcterms="http://purl.org/dc/terms/">
				<rdf:Description>
					<dcterms:creator>Half-pipe</dcterms:creator>
					<dcterms:created><xsl:value-of select="current-dateTime()"/></dcterms:created>
					<dcterms:format>application/xslt+xml</dcterms:format>
					<dcterms:title><xsl:value-of select="/p:pipeline/@name"/></dcterms:title>
					<dcterms:description>Compiled transform that implements its source pipeline.</dcterms:description>
					<!--<dcterms:source rdf:resource="{resolve-uri(base-uri(*))}"/>-->
				</rdf:Description>
			</rdf:RDF>
			
			<XSLT:strip-space elements="*"/>
			
			<!-- Generate port parameters. -->
			<xsl:for-each select="*/xproc:input">
				<XSLT:param name="{upper-case(@port)}" as="item()*"/>
			</xsl:for-each>
			
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
			
		<XSLT:variable name="{(@name, 'source')[1]}" as="document-node()" hp:input="source">
			<XSLT:document>
				<hp:job-bag>
					<xsl:apply-templates select="(xproc:input, xproc:output)" mode="xproc:pipe-ports"/>
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
		
	
	
	
	<!-- Ignore input and output ports in this mode. -->
	<xsl:template match="p:input | p:output" mode="xproc:pipe"/>
	
	
	
	
	<!-- Parameter input takes its content from the named parameter port. -->
	<xsl:template match="p:input[@kind = 'parameter']" mode="xproc:pipe-ports">
		<hp:input port="{@port}">
			<XSLT:sequence select="$PARAMETERS/*"/>
		</hp:input>
	</xsl:template>
	
	
	<!-- Source input port takes SOURCE port (parameter) or the document root as its content. -->
	<xsl:template match="p:input[@port = 'source']" mode="xproc:pipe-ports">
		<hp:input port="{@port}">
			<XSLT:sequence select="($SOURCE, /)[1]"/>
		</hp:input>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="p:input" mode="xproc:pipe-ports">
		<hp:input port="{@port}">
			<XSLT:sequence select="saxon:parse(${upper-case(@port)})"/>
		</hp:input>
	
	</xsl:template>
	
	
	<!-- Result port takes source port as its content. -->
	<xsl:template match="p:output" mode="xproc:pipe-ports">
		<hp:output port="{@port}">
			<XSLT:sequence select="($SOURCE, /)[1]"/>
		</hp:output>
	</xsl:template>
	
	
	
	
	<!-- Creates a variable to hold the results of the p:identity step. -->
	<xsl:template match="xproc:*" mode="xproc:pipe">
		<XSLT:variable name="{@name}" as="document-node(){hp:sequenceQualifier(xproc:output[@port = 'result'])}"
				hp:step="{name()}">
			
			<!-- Implement port selection. -->
			<xsl:variable name="inputPort" select="'result'"/>
			
			<XSLT:document>
				
				<xsl:for-each select="xproc:input">
					<XSLT:variable name="input-{@port}" as="document-node(){hp:sequenceQualifier(.)}">
						<XSLT:document>
							<xsl:apply-templates select="." mode="xproc:pipe-input"/>
						</XSLT:document>
					</XSLT:variable>
				</xsl:for-each>
				
				<hp:job-bag>
					<xsl:for-each select="xproc:input">
						<hp:input port="{@port}">
							<XSLT:sequence select="$input-{@port}"/>
						</hp:input>
					</xsl:for-each>
					
					<hp:output port="result">
						<XSLT:apply-templates select="$input-source" mode="{name()}-{@name}">
							<xsl:for-each select="xproc:input">
								<XSLT:with-param name="input-{@port}" select="$input-{@port}" as="document-node(){hp:sequenceQualifier(.)}" tunnel="yes"/>
							</xsl:for-each>
						</XSLT:apply-templates>
					</hp:output>
					
					<!-- Insert xproc:log nodes, if required. -->
					<xsl:if test="local-name() = 'log'">
						<XSLT:apply-templates select="${(/*/@name, hp:precedingStepName(current()))[1]}/hp:job-bag/hp:output[@port = '{$inputPort}']/*" mode="{name()}-{@name}"/>
					</xsl:if>
					
					<!-- Copy los from the preceding step. -->
					<XSLT:sequence select="${(/*/@name, hp:precedingStepName(current()))[1]}/hp:job-bag/hp:log"/>
				</hp:job-bag>
			</XSLT:document>
		</XSLT:variable>
	</xsl:template>
	
	
	
	
	<!-- Generate input port(s) that definine inline, document or pipe sources. -->
	<xsl:template match="xproc:input[*]" mode="xproc:pipe-input">
		<xsl:apply-templates select="*" mode="#current"/>
	</xsl:template>
	
	
	<!-- No content for the port. -->
	<xsl:template match="xproc:empty" mode="xproc:pipe-input"/>
	
	
	<!-- Copy the in-line content. -->
	<xsl:template match="xproc:inline" mode="xproc:pipe-input">
		<xsl:apply-templates select="* | text()" mode="xproc:inline"/>
	</xsl:template>
	
	
	<!-- Copy elements, their attributes and children. -->
	<xsl:template match="element()" mode="xproc:inline">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="* | text() | comment() | processing-instruction()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- Copy comments. -->
	<xsl:template match="comment()" mode="xproc:inline">
		<XSLT:comment><xsl:value-of select="."/></XSLT:comment>
	</xsl:template>
	
	<!-- Copy processing instructions. -->
	<xsl:template match="processing-instruction()" mode="xproc:inline">
		<XSLT:processing-instruction name="{name()}"><xsl:value-of select="."/></XSLT:processing-instruction>
	</xsl:template>
	
	
	<!-- Generate code to retrieve the referenced XML document at run-time. -->
	<xsl:template match="xproc:document" mode="xproc:pipe-input">
		<XSLT:variable name="resourceURI" select="resolve-uri(xs:anyURI('{@href}'))" as="xs:anyURI"/>
		<XSLT:copy-of select="if (doc-available($resourceURI)) then doc($resourceURI) else hp:error('err:XD0002', $resourceURI)"/>
	</xsl:template>
	
	
	<!-- Generate code to retrieve the referenced XML document at run-time. -->
	<xsl:template match="xproc:data" mode="xproc:pipe-input">
		<XSLT:variable name="resourceURI" select="resolve-uri(xs:anyURI('{@href}'))" as="xs:anyURI"/>
		<XSLT:element name="{(@wrapper, 'c:data')[1]}">
			<XSLT:copy-of select="if (unparsed-text-available($resourceURI)) then unparsed-text($resourceURI) else hp:error('err:XD0029', $resourceURI)"/>	
		</XSLT:element>
	</xsl:template>
	
	
	<!-- Generate code to embed content from the result port of the previous step. -->
	<xsl:template match="xproc:pipe" mode="xproc:pipe-input">
		<XSLT:sequence select="${@step}/hp:job-bag/hp:*[@port = '{@port}']/*"/>
	</xsl:template>
	
	
	<!-- Generate code to embed content from the result port of the previous step. -->
	<xsl:template match="xproc:input" mode="xproc:pipe-input">
		<XSLT:sequence select="${(/*/@name, hp:precedingStepName(current()))[1]}/hp:job-bag/hp:output[@port = 'result']{if (@select) then @select else '/*'}"/>
	</xsl:template>
	
	
	
	
	
	
	<!-- === Pipeline Steps. =============================================== -->
	
	
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
		<XSLT:template match="hp:error" mode="{name()}-{@name}" priority="10">
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
	
	
	
	
	<!--  -->
	<xsl:template match="xproc:xslt" mode="xproc:step" hp:implemented="false">
		<XSLT:template match="*" mode="{name()}-{@name}">
			<xsl:apply-templates select="p:input" mode="xproc:step-inputs"/>
			<XSLT:variable name="compiledTransform" select="saxon:compile-stylesheet($input-stylesheet)"/>
			<XSLT:copy-of select="saxon:transform($compiledTransform, .)"/>
		</XSLT:template>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="xproc:xslt[@version]" mode="xproc:step">
		<XSLT:template match="*" mode="{name()}-{@name}">
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
	
	
	
	
	<!-- Guard template, creates an identity transform that allows the step to 
		 have no effect on the input. Basically, the step is ignored if it is 
		 not supported. -->
	<xsl:template match="xproc:*" mode="xproc:step">
		<xsl:message>[XProc][Compiler] Step '<xsl:value-of select="saxon:path()"/>' is not supported. It will be ignored at run-time.</xsl:message>
		
		<XSLT:template match="/" mode="{name()}-{@name}">
			<hp:error>The step '<xsl:value-of select="name()"/>' is not supported.</hp:error>
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
	
	
	
	
	<!-- Ignore serialization elements in these modes. -->
	<xsl:template match="xproc:serialization" mode="xproc:compile xproc:pipe xproc:step"/>
	
	
	
	
	<!-- Ignore library elements in these modes. -->
	<xsl:template match="xproc:library" mode="xproc:pipe xproc:step"/>
	
</xsl:transform>