# Introduction #

Half-pipe is a modular set of XSLT transforms that can be combined in a number of useful ways. There is an XProc pipeline parser that is used to generate a canonical form of the pipeline definition that then makes life easier for the compiler. The compiler imports the parser and uses the result of the compiler to generate the compiled pipeline, an XSLT transform. The processor imports the compiler, and therefore, indirectly, the parser. The individual and test-suite runners import the processor.

During the development process and for diagnosing problems with pipelines, it is possible to run the parser and the compiler separately from their parent transforms in order to see what is going on underneath.

# Pipeline Tasks #

## Parsing ##

## Compiling ##

## Processing ##

## Testing ##

### Individual Tests ###

### Test Suite ###

## Debugging ##