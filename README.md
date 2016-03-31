# haxe-build-macros-cop

## macros introduction

Macro is about syntax-transformation.
http://haxe.org/manual/macro.html

Depending on the stage they are executed at, there are 3 types of macros.

## expression macros
..are normal functions which are executed as soon as they are typed. Which means the expression they return can be used as a constant value for static initialisation.
Defined with **macro** function prefix.
*Example: BuildID*

## initialisation macros
Called from command line using **--macro callExpr(args)** 
The most obvious benefit is the access to filesystem.
*Example:JsonValidator*

## build macros
Used for type building.
Can access to class fields thought context. 
Shoould return the array of expressions, which would build the class the macro is being used upon.

*Example:Profiler*
*Example:ForFoop*
*Example:FileNameReader*

# Links 
http://nadako.tumblr.com/post/77106860013/using-haxe-macros-as-syntax-tolerant
http://blog.stroep.nl/2014/01/haxe-macros/
http://yal.cc/haxe-some-cleaner-c-style-for-loops/
https://gist.github.com/FuzzyWuzzie/412e2109a5f5fbcf12e1
