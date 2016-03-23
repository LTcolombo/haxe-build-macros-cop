import haxe.Timer;
import haxe.crypto.Md5;

class BuildID {

        /** Generate a unique enough string */
    public static function unique_id() : String {
        return Md5.encode(Std.string( Timer.stamp()*Math.random() ));
    }

        /** Generates a unique string id at compile time only */
    macro public static function get() {
        return macro $v{ unique_id() };
    }

}