class Main {

	public inline static var build_id : String = BuildID.get();
    public function new() {
    	//example 1
        //trace( 'running build ${build_id}' );

        //example 2
        //trace (FileNames.flag_1_config__png);

        var test = new ProfilerTest();
        test.run();
        Profiler.printProfiles();
    }

        //called automatically as the entry point
    static function main() {
        new Main();
    }
}