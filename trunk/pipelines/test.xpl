<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline type="atom:re-write_links"
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
	
	<!--<p:import href="foo.xml"/>-->
	
	<p:serialization port="result" indent="true" omit-xml-declaration="false" 
		method="xml" encoding="utf-8" media-type="application/xml"/>
	
	<p:identity name="feed"/>
	
	<!--<p:for-each name="feed-links">
		<p:output port="result" sequence="true"/>
		
		<p:iteration-source select="/*/atom:link"/>
		<p:add-attribute match="/atom:link" attribute-name="href">
			<p:with-option name="attribute-value" select="replace(/atom:link/@href, 'atomserver', 'atomstore/atomserver')"/>
		</p:add-attribute>
	</p:for-each>-->
	
<!--	<p:add-attribute match="//atom:link" attribute-name="href" attribute-value="foo:bar"/>-->
	
	<p:add-attribute match="//atom:link" attribute-name="href">
		<p:with-option name="attribute-value" select="name()"/>
	</p:add-attribute>
	
	<!--<p:delete match="/atom:feed/atom:link">
		<p:input port="source">
			<p:pipe port="result" step="feed"/>
		</p:input>
	</p:delete>-->
	
	<!--<p:insert name="feed1" match="/atom:feed/atom:entry" position="first-child">
		<p:input port="insertion" sequence="true">
			<p:inline>
				<bar/>
			</p:inline>
		</p:input>
	</p:insert>-->
	
</p:pipeline>
