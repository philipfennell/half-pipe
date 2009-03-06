<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="atom:re-write_links"
	xmlns:as="http://atomserver.org/namespaces/1.0/"
	xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:cx="http://xmlcalabash.com/ns/extensions"
	xmlns:os="http://a9.com/-/spec/opensearch/1.1/"
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:pxp="http://exproc.org/proposed/steps"
	xmlns:test="http://www.test.bbc.co.uk/"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-inline-prefixes="atom c cx p pxp test xs"
	name="re-write_links">
	
	<p:input port="source"/>
	<p:output port="result"/>
	
	<p:serialization port="result" indent="true" omit-xml-declaration="false" 
		method="xml" encoding="utf-8" media-type="application/xml"/>
	
	<p:identity name="feed"/>
	
	<p:for-each name="feed-links">
		<p:output port="result" sequence="true"/>
		
		<p:iteration-source select="/*/atom:link"/>
		<p:add-attribute match="/atom:link" attribute-name="href">
			<p:with-option name="attribute-value" select="replace(/atom:link/@href, 'atomserver', 'atomstore/atomserver')"/>
		</p:add-attribute>
	</p:for-each>
	
	<p:delete match="/atom:feed/atom:link">
		<p:input port="source">
			<p:pipe port="result" step="feed"/>
		</p:input>
	</p:delete>
	
	<p:insert name="feed1" match="/atom:feed" position="first-child">
		<p:input port="insertion" sequence="true">
			<p:pipe port="result" step="feed-links"/>
		</p:input>
	</p:insert>
	
	<p:for-each name="entries">
		<p:output port="result" sequence="true"/>
		
		<p:iteration-source select="/atom:feed/atom:entry"/>
		
		<p:identity name="entry"/>
		
		<p:for-each name="entry-links">
			<p:output port="result" sequence="true"/>
			
			<p:iteration-source select="/*/atom:link"/>
			<p:add-attribute match="/atom:link" attribute-name="href">
				<p:with-option name="attribute-value" select="replace(/atom:link/@href, 'atomserver', 'atomstore/atomserver')"/>
			</p:add-attribute>
		</p:for-each>
		
		<p:delete name="remove-links" match="/atom:entry/atom:link">
			<p:input port="source">
				<p:pipe port="result" step="entry"/>
			</p:input>
		</p:delete>
		
		<p:insert match="/atom:entry" position="first-child">
			<p:input port="source">
				<p:pipe port="result" step="remove-links"/>
			</p:input>
			<p:input port="insertion" sequence="true">
				<p:pipe port="result" step="entry-links"/>
			</p:input>
		</p:insert>
	</p:for-each>
	
	<p:delete name="remove_entries" match="/atom:feed/atom:entry">
		<p:input port="source">
			<p:pipe port="result" step="feed1"/>
		</p:input>
	</p:delete>
	
	<p:insert name="feed2" match="/atom:feed" position="last-child">
		<p:input port="source">
			<p:pipe port="result" step="remove_entries"/>
		</p:input>
		<p:input port="insertion" sequence="true">
			<p:pipe port="result" step="entries"/>
		</p:input>
	</p:insert>
	
</p:declare-step>
