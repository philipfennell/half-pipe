<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform
		xmlns:app="http://www.w3.org/2007/app"
		xmlns:as="http://services.bbc.co.uk/atomstore"
		xmlns:atom="http://www.w3.org/2005/Atom"
		xmlns:saxon="http://saxon.sf.net/"
		xmlns:spring="http://www.springframework.org/schema/beans"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		exclude-result-prefixes="saxon xs"
		version="2.0">

    <xsl:output method="xml" indent="yes" encoding="UTF-8" media-type="application/xml"/>

    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            xmlns:dcterms="http://purl.org/dc/terms/">
        <rdf:Description rdf:about="$Source: $">
        	<dcterms:creator>Philip A. R. Fennell</dcterms:creator><!-- $Author: $ -->
            <dcterms:hasVersion>$Revision: $</dcterms:hasVersion>
            <dcterms:dateSubmitted>$Date: $</dcterms:dateSubmitted>
        	<dcterms:rights>Copyright 2009 All Rights Reserved.</dcterms:rights>
        	<dcterms:format>text/xsl</dcterms:format>
        	<dcterms:description>Transforms an APP Service document into an AtomServer Spring Application Context (workspaceBeans.xml) file.</dcterms:description>
        </rdf:Description>
    </rdf:RDF>
	
	
	
	
	
    <xsl:template match="/">
    	<xsl:apply-templates select="app:service" mode="spring:app-context"/>
    </xsl:template>
	
	
	<xsl:template match="app:service" mode="spring:app-context">
		<spring:beans 
				xmlns:a="http://abdera.apache.org"
				xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				xmlns:util="http://www.springframework.org/schema/util"
				xsi:schemaLocation="http://www.springframework.org/schema/beans
						http://www.springframework.org/schema/beans/spring-beans-2.0.xsd
						http://abdera.apache.org
						http://abdera.apache.org/schemas/abdera-spring.xsd
						http://www.springframework.org/schema/util
						http://www.springframework.org/schema/util/spring-util-2.0.xsd">
			
			<xsl:apply-templates select="app:workspace" mode="#current"/>
			
		</spring:beans>
	</xsl:template>
	
	
	<xsl:template match="app:workspace" mode="spring:app-context">
		<bean class="org.atomserver.core.WorkspaceOptions">
			<property name="name" value="{atom:title}"/>
			
			<!-- This property is required when using the PUT method and an SQL persistant store. -->
			<property name="defaultEntryIdGenerator" ref="org.atomserver-entryIdGenerator"/>
			
			<property name="defaultContentStorage" ref="org.atomserver-contentStorage"/>
			
			<!-- This property inserts the os:totalResults element into the feed. -->
			<property name="defaultProducingTotalResultsFeedElement" value="true"/>
			
			<!-- AtomServer has a curious implementation of categories and their management. -->
			<xsl:if test="app:collection/app:categories">
				<property name="defaultProducingEntryCategoriesFeedElement" value="true"/>
				<property name="defaultCategoriesHandler" ref="org.atomserver-entryCategoriesHandler"/>
			</xsl:if>
		</bean>
	</xsl:template>
</xsl:transform>
