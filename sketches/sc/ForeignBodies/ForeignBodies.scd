var procGrain, eventScore, ctkgroup, proc, pitchEnv;
ctkgroup = CtkGroup.play(server:s);

		// basic Example.
		pitchEnv = Tendency.new(
			Env([0.5, 10, 0.5], [10, 2], \sin),
			Env([0.4, 5.0, 0.4], [10, 2], \sin));

~synth2 =	CtkSynthDef(\tones, {arg dur, freq, freq2, gldur, amp , attack = 0.01;
	var osc, inamp, env, envgen;
	amp = amp.dbamp;
	// Scale amplitude by number of concurrent oscillators
	amp = amp/11;
	// Use a linear glissando to move from freq1 to freq2 in 'gldur' seconds
	osc = SinOsc.ar(Line.kr(freq, freq2, gldur), 0, 1);
	// Create a new envelop with variable attack and long decay
	env = Env.new([0.0000000002, amp, 0.0000000002], [attack, dur - attack],'exponential');
	envgen = EnvGen.kr(env, doneAction:2);
	Out.ar(0, osc*envgen);
	});


procGrain = {
	"procGrain playing".postln;
	proc = ProcMod.new(Env([0, 1, 0], [1, 1], \sin, 1), server: s);

	proc.function_({arg group, routebus, server;
		var grainDur,note1, pitch;
		grainDur = 0.5;
		Task({
			inf.do({

				pitch = 220.rrand(440);
				note1 = ~synth2.note( target:ctkgroup, addAction:\tail )
				.freq_(pitch)
				.freq2_(pitch*1.1.rrand(2.1))
				.gldur_(grainDur*0.5.rrand(1))
				.amp_(0.1.rrand(1))
				.dur_(pitchEnv[proc.now]).play;
				(grainDur*0.2).wait;
			})
		});
	});
};

eventScore = Routine{
	var proc1;
	proc1 = procGrain.value(); //must create a new instance of procmod so it can be called in a routine
	proc1.play;
	"playing".postln;
	30.wait;
	proc1.release(5);
	// 20.wait;
};
// y=eventScore.play;

//-------
// proc = ProcMod.new(Env([0, 1, 0], [1, 1], \sin, 1), server: s);
// p.function_({arg group, envbus, server,pm;
// 	var grainDur,note1, pitch;
// 	grainDur = 0.5;
//
// 	Task({
// 		inf.do({
// 			pitch = 220.rrand(440);
// 			note1 = ~synth2.note( target:ctkgroup, addAction:\tail )
// 			.freq_(pitch)
// 			.freq2_(pitch*1.1.rrand(2.1))
// 			.gldur_(grainDur*0.5.rrand(1))
// 			.amp_(0.1.rrand(1))
// 			.dur_(pitchEnv[p.now]).play;
// 			(grainDur*0.2).wait;
// 		})
// 	});
// });
// p.play;
// p.release;