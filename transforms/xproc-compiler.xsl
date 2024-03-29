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
	<xsl:include href="xproc-steps.xsl"/>
	
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
			<dcterms:description>XProc Pipeline Compiler</dcterms:description>
		</rdf:Description>
	</rdf:RDF>
	
	<xsl:strip-space elements="*"/>
	
	
	
	
	<!-- Returns the compiled version of the passed XProc pipeline document. -->
	<xsl:function name="xproc:compile" as="element()*">
		<xsl:param name="pipelineDoc" as="document-node()"/>
		<xsl:param name="mode" as="xs:string?"/>
		<xsl:variable name="parsedPipeline" select="xproc:parse($pipelineDoc)" as="element()"/>
		
		<hp:job-bag>
			<xsl:if test="$mode = 'debug'">
				<xsl:copy-of select="$parsedPipeline"/>
			</xsl:if>
			<hp:compiled-pipeline>
				<xsl:apply-templates select="$parsedPipeline" mode="xproc:compile"/>
			</hp:compiled-pipeline>
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
		
		<!-- Compile the expanded pipeline into an executable transform. -->
		<xsl:variable name="compiledPipeline" as="element()">
			<hp:compiled-pipeline>
				<xsl:apply-templates select="$parsedPipeline" mode="xproc:compile"/>
			</hp:compiled-pipeline>
		</xsl:variable>
		
		<xsl:copy-of select="$compiledPipeline/*"/>
	</xsl:template>
	
	
	
	
	
	
	<!-- === Pipeline Compilation (xproc:compile). ========================= -->
	
	<xsl:template match="hp:parsed-pipeline" mode="xproc:compile">
		<XSLT:transform version="2.0">
			<xsl:variable name="contextNode" select="*"/>
			
			<xsl:namespace name="err" select="'http://www.w3.org/ns/xproc-error'"/>
			<xsl:namespace name="hp" select="'http://code.google.com/p/half-pipe/'"/>
			<xsl:namespace name="xproc" select="'http://www.w3.org/ns/xproc'"/>
			<xsl:namespace name="xs" select="'http://www.w3.org/2001/XMLSchema'"/>
			<xsl:namespace name="p" select="'http://www.w3.org/ns/xproc'"/>
			
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
			<xsl:apply-templates select="xproc:serialization" mode="xproc:serialize"/>
			
			<XSLT:output encoding="UTF-8" indent="yes" media-type="application/xml" method="xml" name="xproc:log"/>
			<XSLT:output encoding="UTF-8" indent="yes" media-type="application/xml" method="xml" name="hp:debug"/>
			
			<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
					xmlns:dcterms="http://purl.org/dc/terms/">
				<rdf:Description>
					<dcterms:creator>Half-pipe</dcterms:creator>
					<dcterms:created><xsl:value-of select="current-dateTime()"/></dcterms:created>
					<dcterms:format>application/xslt+xml</dcterms:format>
					<dcterms:title><xsl:value-of select="p:declare-step/@name"/></dcterms:title>
					<dcterms:description>Compiled transform that implements its source pipeline.</dcterms:description>
					<!--<dcterms:source rdf:resource="{resolve-uri(base-uri(.))}"/>-->
				</rdf:Description>
			</rdf:RDF>
			
			<XSLT:strip-space elements="*"/>
			
			<!-- Generate port parameters. -->
			<xsl:for-each select="*/xproc:input">
				<XSLT:param name="{upper-case(@port)}" as="item()*"/>
			</xsl:for-each>
			
			<!-- Start compiling the pipeline. -->
			<xsl:apply-templates select="*" mode="#current"/>
			
			<XSLT:template match="comment() | processing-instruction()" mode="{for $step in .//*[@hp:step = 'true'] return concat(name($step), '-', $step/@name, '')}">
				<XSLT:copy-of select="."/>
			</XSLT:template>
			
			<!-- #all -->
			<XSLT:template match="hp:documents[hp:document/err:*]" mode="{for $step in .//*[@hp:step = 'true'] return concat(name($step), '-', $step/@name, '')}" priority="10">
				<XSLT:copy-of select="*"/>
			</XSLT:template>
			
			<XSLT:template match="hp:documents" mode="{for $step in .//*[@hp:step = 'true'] return concat(name($step), '-', $step/@name, '')}" priority="1">
				<XSLT:variable name="documents" as="document-node()*">
					<XSLT:for-each select="hp:document">
						<XSLT:document>
							<XSLT:copy-of select="*"/>
						</XSLT:document>
					</XSLT:for-each>
				</XSLT:variable>
				<XSLT:for-each select="$documents">
					<hp:document>
						<XSLT:apply-templates select="." mode="#current"/>
					</hp:document>
				</XSLT:for-each>
			</XSLT:template>
		</XSLT:transform>
	</xsl:template>
	
	
	
	
	<!-- Create the output serialization properties. -->
	<xsl:template match="xproc:serialization" mode="xproc:serialize">
		<XSLT:output>
			<xsl:apply-templates select="@* except (@port)" mode="#current"/>
		</XSLT:output>
	</xsl:template>
	
	<xsl:template match="@indent | @omit-xml-declaration" mode="xproc:serialize">
		<xsl:attribute name="{name()}" select="if (. = 'true') then 'yes' else 'no'"/>
	</xsl:template>
	
	<xsl:template match="attribute()" mode="xproc:serialize">
		<xsl:attribute name="{name()}" select="."/>
	</xsl:template>
	
	
	
	
	<!-- Creates the root template for the compiled transform. -->
	<xsl:template match="xproc:declare-step" mode="xproc:compile">
			
		<XSLT:variable name="{@name}" as="document-node()" hp:input="source">
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
				<XSLT:result-document href="debug/job-bag.xml" format="hp:debug">
					<XSLT:sequence select="."/>
				</XSLT:result-document>
			</xsl:if>
			
			<XSLT:sequence select="hp:output[@port = 'result']/*"/>
			<XSLT:apply-templates select="*" mode="#current"/>
		</XSLT:template>
		
		<!-- Outputs the result of the named port to a URI. -->
		<XSLT:template match="hp:log" mode="xproc:result">
			<XSLT:result-document hp:port="{@name}" href="{{@href}}" format="xproc:log">
				<XSLT:sequence select="*"/>
			</XSLT:result-document>
		</XSLT:template>
		
		<!-- Outputs the aggregated step results. -->
		<XSLT:template match="hp:trace" mode="xproc:result">
			<XSLT:result-document href="debug/trace.xml" format="xproc:log">
				<XSLT:copy>
					<XSLT:sequence select="*"/>
					<hp:step name="result">
						<XSLT:copy-of select="../hp:output/*"/>
					</hp:step>
				</XSLT:copy>
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
			<XSLT:sequence select="if ($SOURCE) then $SOURCE else /hp:documents/*"/>
		</hp:input>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="p:input" mode="xproc:pipe-ports">
		<hp:input port="{@port}">
			<XSLT:sequence select="hp:parse(${upper-case(@port)})"/>
		</hp:input>
	</xsl:template>
	
	
	<!-- Result port takes source port as its content. -->
	<xsl:template match="p:output" mode="xproc:pipe-ports">
		<hp:output port="{@port}">
			<XSLT:sequence select="if ($SOURCE) then $SOURCE else /hp:documents/*"/>
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
					<XSLT:variable name="input-{@port}" as="element(){hp:sequenceQualifier(.)}">
						<hp:documents>
							<xsl:apply-templates select="." mode="xproc:pipe-input"/>
						</hp:documents>
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
							<xsl:apply-templates select="." mode="xproc:pipe-output"/>
						</XSLT:apply-templates>
					</hp:output>
					
					<!-- Insert xproc:log nodes, if required. -->
					<xsl:if test="local-name() = 'log'">
						<XSLT:apply-templates select="${(ancestor::hp:parsed-pipeline[1]/*/@name, hp:precedingStepName(current()))[1]}/hp:job-bag/hp:output[@port = '{$inputPort}']/*" mode="{name()}-{@name}"/>
					</xsl:if>
					
					<hp:trace>
						<!-- Copy trace from the preceding step. -->
						<XSLT:sequence select="${(hp:precedingStepName(current()), ancestor::hp:parsed-pipeline[1]/*/@name)[1]}/hp:job-bag/hp:trace/*"/>
						<hp:step name="{(hp:precedingStepName(current()), ancestor::hp:parsed-pipeline[1]/*/@name)[1]}">
							<XSLT:copy-of select="${(hp:precedingStepName(current()), ancestor::hp:parsed-pipeline[1]/*/@name)[1]}/hp:job-bag/hp:output[@port = 'result']"/>
						</hp:step>
					</hp:trace>
					
					<!-- Copy logs from the preceding step. -->
					<XSLT:sequence select="${(hp:precedingStepName(current()), ancestor::hp:parsed-pipeline[1]/*/@name)[1]}/hp:job-bag/hp:log"/>
				</hp:job-bag>
			</XSLT:document>
		</XSLT:variable>
	</xsl:template>
	
	
	
	
	<!-- Generate input port(s) that definine inline, document or pipe sources. -->
	<xsl:template match="xproc:input[@port = 'stylesheet'][*]" mode="xproc:pipe-input" priority="2">
		<xsl:apply-templates select="*" mode="xproc:port-stylesheet"/>
	</xsl:template>
	
	
	<!-- Copy the in-line stylesheet. -->
	<xsl:template match="xproc:inline" mode="xproc:port-stylesheet">
		<hp:document>
			<xsl:copy-of select="hp:embedStylesheet(*)"/>
		</hp:document>
	</xsl:template>
	
	
	<!-- Generate input port(s) that definine inline, document or pipe sources. -->
	<xsl:template match="xproc:input[*]" mode="xproc:pipe-input">
		<xsl:apply-templates select="*" mode="#current"/>
	</xsl:template>
	
	
	<!-- No content for the port. -->
	<xsl:template match="xproc:empty" mode="xproc:pipe-input"/>
	
	
	<!-- Copy the in-line content. -->
	<xsl:template match="xproc:inline" mode="xproc:pipe-input">
		<hp:document>
			<xsl:apply-templates select="* | text()" mode="xproc:inline"/>
		</hp:document>
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
	<xsl:template match="xproc:document" mode="xproc:pipe-input xproc:port-stylesheet">
		<XSLT:variable name="resourceURI" select="resolve-uri(xs:anyURI('{@href}'))" as="xs:anyURI"/>
		<hp:document>
			<XSLT:copy-of select="if (doc-available($resourceURI)) then doc($resourceURI) else hp:error('err:XD0002', $resourceURI)"/>
		</hp:document>
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
	<xsl:template match="xproc:pipe" mode="xproc:port-stylesheet">
		<hp:document>
			<XSLT:sequence select="${@step}/hp:job-bag/hp:*[@port = '{@port}']/*"/>
		</hp:document>
	</xsl:template>
	
	
	<!-- Generate code to embed content from the result port of the previous step. -->
	<xsl:template match="xproc:input" mode="xproc:pipe-input">
		
		<!-- Need a for-each that applies the select expression to the contents
			 of each hp:document. -->
		
		<XSLT:for-each select="${(ancestor::hp:parsed-pipeline[1]/*/@name, hp:precedingStepName(current()))[1]}/hp:job-bag/hp:output[@port = 'result']/*">
			<hp:document>
				<XSLT:copy-of select="{if (@select) then if (starts-with(@select, '/')) then substring-after(@select, '/') else @select else '*'}"/>
			</hp:document>
		</XSLT:for-each>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="xproc:input[@port = 'stylesheet'][xproc:inline]" mode="xproc:pipe-output" priority="2">
		<XSLT:with-param name="input-{@port}" select="hp:extractStylesheet($input-{@port})" as="document-node(){hp:sequenceQualifier(.)}" tunnel="yes"/>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="xproc:input" mode="xproc:pipe-output">
		<XSLT:with-param name="input-{@port}" select="$input-{@port}" as="element(){hp:sequenceQualifier(.)}" tunnel="yes"/>
	</xsl:template>
	
	
	
	
	
	
	<!-- === Pipeline Steps. =============================================== -->
	
	
	<!--<xsl:template match="xproc:declare-step" mode="xproc:step">
		<XSLT:template match="/" mode="{name()}-{@name}">
			
		</XSLT:template>
	</xsl:template>-->
	
	
	
	
	<!-- Ignore serialization elements in these modes. -->
	<xsl:template match="xproc:serialization" mode="xproc:compile xproc:pipe xproc:step"/>
	
	
	
	
	<!-- Ignore library elements in these modes. -->
	<xsl:template match="xproc:library" mode="xproc:pipe xproc:step"/>
	
</xsl:transform>