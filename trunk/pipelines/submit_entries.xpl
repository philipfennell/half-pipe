<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline 
		xmlns:app="http://www.w3.org/2007/app"
		xmlns:atom="http://www.w3.org/2005/Atom"
		xmlns:c="http://www.w3.org/ns/xproc-step"
		xmlns:cx="http://xmlcalabash.com/ns/extensions"
		xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:pxp="http://exproc.org/proposed/steps"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xml:base=".."
		exclude-inline-prefixes="app atom c cx p pxp xs"
		name="submit-entries">
	
	<p:import href="lib/library-1.0.xpl"/>
	
	<p:serialization port="result" indent="true" omit-xml-declaration="false" 
			method="xml" encoding="utf-8" media-type="application/xml"/>
	
	
	
	
	<p:declare-step name="get-uuid" type="app:uuid">
		<p:documentation/>
		<p:input port="source"/>
		<p:output port="result" sequence="true"/>
		<p:string-replace match="/*" replace="concat('urn:uuid:', /atom:entry/atom:content/*/@uuid)"/>
		<p:wrap-sequence wrapper="atom:id"/>
	</p:declare-step>
	
	
	
	
	
	
	<!-- === Atom Feed from ZIP files. ===================================== -->
	
	<cx:unzip href="data/Infax-subset.zip" content-type="application/xml"/>
	
	<p:for-each name="make-entries">
		<p:iteration-source select="/c:zipfile/c:file"/>
		
		 <cx:message>
			<p:with-option name="message" select="/c:file/@name"/>
		</cx:message>
		
		<cx:unzip href="data/Infax-subset.zip" content-type="application/xml">
			<p:with-option name="file" select="/c:file/@name"/>
		</cx:unzip>
		
		<p:add-attribute match="/*" attribute-name="uuid">
			<p:with-option name="attribute-value" select="concat(/c:file/@name, '-', current-dateTime())"/>
		</p:add-attribute>
		<p:uuid match="/*/@uuid" version="4"/>
		
		<p:wrap-sequence wrapper="atom:content"/>	
		<p:add-attribute match="/atom:content" attribute-name="type" attribute-value="application/xml"/>
		<p:wrap-sequence name="entry-wrapper" wrapper="atom:entry"/>
		
		<app:uuid name="ermm"/>
		
		<p:insert name="insert-uuid" match="//atom:entry" position="first-child">
			<p:input port="source">
				<p:pipe step="entry-wrapper" port="result"/>
			</p:input>
			<p:input port="insertion">
				<p:pipe step="ermm" port="result"/>
			</p:input>
		</p:insert>
	</p:for-each>
	
	<p:wrap-sequence wrapper="atom:feed"/>
	
	
	

	
	
	<!-- === Send Atom entries to an Atom store. =========================== -->
	
	<p:xslt name="entry-to-request" version="2.0">
		<p:input port="source" sequence="true"/>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
		<p:input port="stylesheet">
			<p:document href="transforms/entry_to_request.xsl"/>
		</p:input>
	</p:xslt>
	
	<p:for-each>
		<p:iteration-source select="/c:requests/c:request"/>
		
		<cx:message>
			<p:with-option name="message" select="/c:request/@href"/>
		</cx:message>
		
		<p:http-request indent="true" method="xml" media-type="application/xml"/>
	</p:for-each>
	
	<p:wrap-sequence wrapper="c:responses"/>
	
</p:pipeline>
