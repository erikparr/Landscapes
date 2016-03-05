var  eventScore, ctkGroup, proc, pitchEnv, outBus=0, ampCtrl,procPlay, remoteIP, scPort,playOsc, ampOsc, proc0;
ctkGroup = CtkGroup.play(addAction: \tail, target:0, server:s);
ampCtrl = CtkControl.play(initVal: 0.1);

		// basic Example.
		pitchEnv = Tendency.new(
			Env([0.5, 10, 0.5], [10, 2], \sin),
			Env([0.4, 5.0, 0.4], [10, 2], \sin));

remoteIP = "169.254.210.147";
scPort = 57120;
n = NetAddr(remoteIP, scPort); // always receives remotely from port 57120


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

procPlay= {arg amp, numChans, outBus, id, group;
	var procPlay;

proc = ProcMod.new(	Env([0, 1, 0], [1, 1], \sin, 1), amp, numChans, outBus, id, group, server: s);
proc.function_({arg group, envbus, server,pm;
	var grainDur,note1, pitch;
	grainDur = 0.5;

	Task({
		inf.do({
			pitch = 220.rrand(440);
			note1 = ~synth2.note( target:group )
			.freq_(pitch)
			.freq2_(pitch*1.1.rrand(2.1))
			.gldur_(grainDur*0.5.rrand(1))
			.amp_(ampCtrl)
			.dur_(pitchEnv[proc.now]).play;
			(grainDur*0.2).wait;
		})
	});
});
	proc.releaseFunc_({
		id.post; " is free".postln;
		ctkGroup.release;
		s.freeAll
	})

};
s.queryAllNodes;
	proc0 = procPlay.(
		ampCtrl,
		2, //num chans
		0,
		\testproc,
		ctkGroup
);
	playOsc = OSCFunc({arg msg; if(msg[1]==1,{proc0.play;},{proc0.release; s.queryAllNodes;})}, '/1/toggle1'); // create the
ampOsc = OSCFunc({arg msg; ampCtrl.set(msg[1])}, '/1/fader1'); // create the
// // procPlay.play;
// eventScore = Routine{
// 	proc = procPlay.(
// 		ampCtrl,
// 		2, //num chans
// 		0,
// 		\testproc,
// 		ctkGroup
// 	);
// 	proc.play;
// 	// "playing".postln;
// 	// s.queryAllNodes;
// 	5.wait;
// 	proc.release;
// 	"---".postln;
// 	// 20.wait;
// };
// y=eventScore.play;
// // s.freeAll
// // s.queryAllNodes;
