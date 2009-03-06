<?xml version="1.0" encoding="UTF-8"?>
<p:library 
		xmlns:as="http://services.bbc.co.uk/atomstore"
		xmlns:c="http://www.w3.org/ns/xproc-step"
		xmlns:cx="http://xmlcalabash.com/ns/extensions"
		xmlns:dcterms="http://purl.org/dc/terms/"
		xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:xhtml="http://www.w3.org/1999/xhtml"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xml:base="..">
		
	<p:documentation>
		<xhtml:h1>Core Library</xhtml:h1>
		<xhtml:p>Forge XProc XML pipeline processing library</xhtml:p>
	</p:documentation>
		
	<p:declare-step type="as:re-write_links">
		<p:documentation>
			<xhtml:h2>Re-write Atom(Pub) links</xhtml:h2>
			<xhtml:p>Replicates the structure of the source Atom(Pub) document and transforms link URIs according to a RegExp and replacement string.</xhtml:p>
			<xhtml:p>The <xhtml:code>pattern</xhtml:code> and <xhtml:code>replacement</xhtml:code> step options pass the RegExp pattern and replacement string that are applied to the links that are to be re-written,</xhtml:p>
		</p:documentation>
		
		<!-- Port declarations. -->
		<p:input port="source"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result"/>
		
		<!-- Step option declarations. -->
		<p:option name="pattern"/>
		<p:option name="replacement"/>
		
		<p:xslt name="url_re-write" version="2.0">
			<p:with-param name="PATTERN" select="$pattern"/>
			<p:with-param name="REPLACEMENT" select="$replacement"/>
			
			<p:input port="source"/>
			<p:input port="parameters" kind="parameter"/>
			<p:input port="stylesheet">
				<p:document href="transforms/rewrite_links.xsl"/>
			</p:input>
		</p:xslt>
	</p:declare-step>
	
	
	<p:declare-step type="as:xml-to-json">
		<p:documentation>
			<xhtml:h2>XML to JSON</xhtml:h2>
			<xhtml:p>Transforms an arbitrary XML document into JSON.</xhtml:p>
		</p:documentation>
		
		<p:input port="source"/>
		<p:output port="result"/>
		
		<p:xslt name="serialize-as-json" version="2.0">
			<p:input port="source"/>
			<p:input port="parameters">
				<p:empty/>
			</p:input>
			<p:input port="stylesheet">
				<p:document href="transforms/xml-to-json.xsl"/>
			</p:input>
		</p:xslt>
	</p:declare-step>
	
</p:library>
