var  eventScore, ctkgroup, proc, pitchEnv, outBus=0, ampCtrl,procPlay;
var remoteIP, scPort,playOsc, ampOsc, proc0,numSpeakers, block;
var durEnv, numDays, daysDir, daySpeak;
ampCtrl = CtkControl.play(initVal: 0.1);
ctkgroup = CtkGroup.play(server:s);
numSpeakers = 36;


~playbuf = CtkSynthDef (\playbuf, {arg buf, rtBus, dur, playrate;
	var in, comp,env;
	in = PlayBuf .ar(2, buf, BufRateScale.kr(buf),rate:playrate);
	env = EnvGen.ar(Env([0, 1, 1, 0], [dur*0.1, dur*0.8, dur*0.1], \sin), doneAction:2);
	comp = Compander.ar(in, in, 0.5, 0.3, 0.01, 0.002, 0.01);
	Out.ar(rtBus, comp * env);
});

numDays = 7;
daysDir = "/Users/erikparr/Documents/_Projects/Landscapes/snd/days/";
~dayBufs = Array.newClear(numDays);
numDays.do{arg i; var sndpath;
	sndpath = daysDir ++ "/0"++i++".wav";
	~dayBufs[i] = CtkBuffer (sndpath, bufnum:i).load(sync: true);
};

block = CtkBuffer ("/Users/erikparr/Documents/_Projects/Landscapes/snd/random/block2.wav", bufnum:i).load(sync: true);

// bus1env = CtkControl.lfo(LFNoise2, 0.1, 0.01, 0.5).play;

// basic Example.
// g = Tendency.new(1760.0, 440.0, Env([0.01, 2.0], [10], \sin), Env([0.01, 2.0], [10], 		\sin)).asStream(\betaRand);

durEnv = Tendency.new(
	Env([0.05, 1, 0.1], [20, 20], \sin),
	Env([0.01, 0.5, 0.01], [20, 20], \sin)).asStream(\betaRand);

remoteIP = "169.254.210.147";
scPort = 57120;
n = NetAddr("localhost", 8000); // always receives remotely from port 57120


procPlay = Task({
	var oscID, count, note;
	count = 0;
	oscID=0;

	inf.do({
		note = ~playbuf.note( target:ctkgroup, addAction:\tail )
		.buf_(block)
		.rtBus_(0)
		.dur_(block.duration)
		.playrate_(0.5.rrand(1.25)).play;

		n.sendMsg("/oscID",oscID);
		count=(count+1)%numDays;
		oscID=0.rrand(numSpeakers);
		oscID.postln;
		(durEnv.next).wait;
	})
});

daySpeak = Task({var note, dayTimer,dayCount;
	dayCount= 0;
	dayTimer = BeatSched.new;
	inf.do({
		if(dayTimer.time>5.0){
	dayTimer.time=0.0;
		note = ~playbuf.note( target:ctkgroup, addAction:\tail )
		.buf_(~dayBufs[dayCount])
		.rtBus_(0)
		.dur_(~dayBufs[dayCount].duration)
		.playrate_(1).play;
		dayCount = (dayCount+1)%numDays;
		};
1.wait;
	});
});

eventScore = Routine{
	procPlay.play;
	daySpeak.play;
	// "playing".postln;
	// s.queryAllNodes;
	1000.wait;
	procPlay.stop;
	daySpeak.stop;
	"---".postln;
	// 20.wait;
};
y=eventScore.play;
// // s.freeAll
// // s.queryAllNodes;
