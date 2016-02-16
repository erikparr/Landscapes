~synth1 = CtkSynthDef (\synth1, {arg buf, rtBus, dur, gate=1, mstr=1;
	var in, comp,env;
	in = PlayBuf .ar(1, buf, BufRateScale.kr(buf), loop:1, doneAction:2);
	comp = Compander.ar(in, in, 0.5, 0.3, 0.01, 0.002, 0.01);
	env = EnvGen.ar(Env([0, 1, 1, 0, 0], [0.05, 0.9, 0.049, 0.001], \sin, 3, 0), gate, timeScale: dur, doneAction:2);
	Out.ar(rtBus, comp * env);



	});

~synth2 = CtkSynthDef (\synth2, {arg amp=1, inbus, outbus, dur;
	var in, comp, env;
	// in = Limiter.ar(In.ar(inbus), 0.5, 0.1);
	in = In.ar(inbus);
	env = EnvGen.ar(Env([0, 1, 1, 0], [0.3,0.4,0.3], \sin), doneAction:2, timeScale: dur);
	// comp = GVerb.ar(Resonz.ar(in, frq, bw),100,5);

	Out.ar(outbus, Pan2 .ar( in*env, 0));
	// Out.ar(outbus, PanAz .ar(2, Limiter.ar(amp*comp*env*0.3, 0.8, 1), Line.kr(-1.rrand(0.0), 0.rrand(1.0), dur)));
	});

SynthDef(\singrain, {arg outbus, freq, amp, dur;
	OffsetOut.ar(outbus,
		Pan2.ar(
			SinOsc.ar(freq, 0, amp) *
				EnvGen.kr(Env.sine(dur, amp), doneAction: 2),
			Rand.new(-1.0, 1.0)
		)
	) // read off the overall env control of the ProcMod
}).load(s);
