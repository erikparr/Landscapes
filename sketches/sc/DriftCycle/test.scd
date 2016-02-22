s = Server.local;
SynthDef(\singrain, {arg freq, amp, dur, envbus;
	OffsetOut.ar(0,
		Pan2.ar(
			SinOsc.ar(freq, 0, amp) *
				EnvGen.kr(Env.sine(dur, amp), doneAction: 2) *
				In.kr(envbus),
			Rand.new(-1.0, 1.0)
		)
	) // read off the overall env control of the ProcMod
}).load(s);


v={
// create a new proc mod, and assign a function to it
a = ProcMod.new(Env([0, 1, 0], [1, 1], \sin, 1), server: s);
a.function_({arg group, envbus, server;
	Task({
		inf.do({
			// start a new synth... run it inside this ProcMod's group,
			// and read control values off the envbus
				// s.sendMsg(\s_new, \singrain, s.nextNodeID, 0, group,
				// \freq, 440.rrand(1760), \amp, 0.1, \dur, 5, \envbus, envbus);
				Synth(\singrain, [\freq, 440.rrand(1760), \amp, 0.1, \dur, 5, \envbus, envbus]);
			0.5.wait;
			})
		});
	});

// play it
};
t={
	"gonna do somethin".postln;
};

r=Routine{
	t.value();
	2.wait;
	w=v.value(); //must create a new instance of procmod so it can be called in a routine
	w.play;
};
r.play;
// change the amp
a.amp_(2);
// change the lag
a.lag_(0.5);
// change the amp again
a.amp_(5);
// release it
a.release;