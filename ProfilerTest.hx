package ;

//@:build(Profiler.profile())
class ProfilerTest {
    public function new() {
    }

    public function run() {
        Profiler.startProfile('ProfilerTest', 'run');
        var x:Float = 0;
        for(i in 0...100000000)
            x += Math.sqrt(Math.random());
        Profiler.endProfile('ProfilerTest', 'run');
        return x;
    }
}
