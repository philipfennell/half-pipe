Half-pipe
=========


Things to do
------------

*	Documentation modes required to:
		+	Extract implemented steps from transform.
		+	Visualise pipeline (XHTML|SVG representations).

*	Implement compile-and-run mode.

*	Implement running modes:
		+	debug	=>	Dump intermediate step on the file-system.
		+	trace	=>	Output trace message to stdout.
		+	expand	=>	Only expand the pipeline.
		+	compile	=>	Only create the executable transform.

*	Test Driven Development
		+	Write test pipelines
		*	Write test Schematron schemata
		*	Write XProc pipeline to execute/validate tests.




Things that have been done
--------------------------

*	Extract error codes/messages from recommendation:
		+	<http://www.w3.org/TR/xproc/#app.static-errors>
		+	<http://www.w3.org/TR/xproc/#app.dynamic-errors>
		+	<http://www.w3.org/TR/xproc/#app.step-errors>
		
		> pipeline -oresult=results\error-codes.xml pipelines\error-codes.xpl
