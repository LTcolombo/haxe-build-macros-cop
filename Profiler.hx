import haxe.macro.Printer;
import haxe.macro.Context;
import haxe.macro.ExprTools;
import haxe.macro.Expr;
import haxe.macro.Type.ClassType;
import haxe.Timer;
import haxe.ds.StringMap;

using haxe.macro.ExprTools;

typedef MethodProfile = {
    var calls:Int;
    var startTime:Float;
    var elapsedTime:Float;
}

class Profiler {

#if macro
/**
	 * An internal tool for determining the fully-qualified-name of a class
	 * @param	cls	a macro classtype
	 * @return the fully-qualified-name of the class
	 */
    private static function getFullClassName(cls:ClassType):String {
        return (cls.pack.length > 0 ? cls.pack.join(".") + "." : "") + cls.name;
    }

    private static var lastWasReturn:Bool = false;
    private static var clsName:String = "";
    private static var methodName:String = "";

/**
	 * This is a recursive function which will tunnel into a function's expressions and replace any
	 * occurrances of a return expression with a custom profiling return expressions
	 * @param	expr	the expression to recursively search through
	 * @return	the transformed expression
	 */

    private static function remapReturn(expr:Expr):Expr {
        lastWasReturn = false;
        switch(expr.expr)
        {
            case EReturn(retExpr):
                {
                    lastWasReturn = true;
                    if (retExpr == null) {
                        return macro {
                            Profiler.endProfile($v { clsName }, $v { methodName });
                            return;
                        };
                    }
                    else {
                        return macro {
                            var ___tempProfilingReturnValue = ${retExpr};
                            Profiler.endProfile($v { clsName }, $v { methodName });
                            return ___tempProfilingReturnValue;
                        };
                    }
                }

            case _:
                return ExprTools.map(expr, remapReturn);
        }
    }

/**
	 * This function, when used in a build macro, will inject profiling code at the beginning
	 * and ending of each function. Call using a build macro such as:
		 * @:build(Profiler.profile())
		 * class SomeClass {
		 * ...
		 * }
	 */

    macro public static function profile():Array<Field> {
// get the fields of the class
        var fields:Array<Field> = Context.getBuildFields();

        var printer:Printer = new Printer();

// and the fully qualified class name
        clsName = getFullClassName(Context.getLocalClass().get());

// loop through each field to find the methods
        for (field in fields) {
            switch(field.kind)
            {
// yay, found a method!
                case FFun(func):
                    {
// get the name of the method
                        methodName = field.name;

// prepend the start code to the function
                        func.expr = macro {
                        Profiler.startProfile($v { clsName }, $v { methodName } );
                        $ { func.expr };
                        };

// start the recursive expression transformation
                        lastWasReturn = false;
                        func.expr = remapReturn(func.expr);
                        if (!lastWasReturn) {
                            func.expr = macro {
                            $ { func.expr };
                            Profiler.endProfile($v { clsName }, $v { methodName } );
                            return;
                            }
                        }
                    }

// skip properties and variables
                default: { };
            }
        }

        return fields;
    }
#end

    private static var profiles:StringMap<StringMap<MethodProfile>> = new StringMap<StringMap<MethodProfile>>();

/**
	 * Reset all the profiling information. Doing this before reading / printing the information will
	 * cause all the data collected since the beginning (or last reset) to be lost
	 */

    public static function reset() {
        profiles = new StringMap<StringMap<MethodProfile>>();
    }

/**
	 * Called at the start of a function to record when in time the method was called. This must always
	 * be called BEFORE an endProfile() call is made
	 * @param	className	the fully-qualified class name of the method's class
	 * @param	methodName	the name of the method being profiled
	 */

    public static function startProfile(className:String, methodName:String) {
// make sure the profiles exist
        if (!profiles.exists(className))
            profiles.set(className, new StringMap<MethodProfile>());
        if (!profiles.get(className).exists(methodName))
            profiles.get(className).set(methodName, { calls: 0, startTime: 0, elapsedTime: 0 });

        profiles.get(className).get(methodName).calls++;
        profiles.get(className).get(methodName).startTime = Timer.stamp();
    }

/**
	 * Called at the end of a function to calculate the method's execution time. This must always
	 * be called AFTER a startProfile() call
	 * @param	className	the fully-qualified class name of the method's class
	 * @param	methodName	the name of the method being profiled
	 */

    public static function endProfile(className:String, methodName:String) {
        var t:Float = Timer.stamp();

        if (!profiles.exists(className) || !profiles.get(className).exists(methodName))
            throw "EndProfile was called on a function that was never started!";

        profiles.get(className).get(methodName).elapsedTime += t - profiles.get(className).get(methodName).startTime;
    }

/**
	 * Just a utility function to print the profiling data, separated by class.
	 */

    public static function printProfiles():Void {
        var totalTime:Float = 0;
        for (className in profiles.keys()) {
            var classTime:Float = 0;
            trace(className + ":");
            for (methodName in profiles.get(className).keys()) {
                trace("  ." + methodName + ": " + profiles.get(className).get(methodName).elapsedTime + "s (" + profiles.get(className).get(methodName).calls + " calls)");
                classTime += profiles.get(className).get(methodName).elapsedTime;
            }
            trace("  ---");
            trace("  " + classTime + "s");
            totalTime += classTime;
        }

        trace("");
        trace("Total time: " + totalTime + "s");
    }
}