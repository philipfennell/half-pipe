<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" name="pipeline">
	<p:input port="source"/>
	<p:input port="style"/>
	<p:input port="parameters" kind="parameter"/>
	<p:output port="result"/>
	
	<p:foo/>
	<p:xslt version="1.0">
		<p:input port="source">
			<p:pipe step="pipeline" port="source"/>
		</p:input>
		<p:input port="stylesheet">
			<p:pipe step="pipeline" port="style"/>
<!--			<p:document href="../examples/xslt.xsl"/>-->
		</p:input>
	</p:xslt>
	
</p:declare-step>