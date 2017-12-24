var  eventScore, ctkgroup, proc, pitchEnv, outBus=0, ampCtrl,procPlay,oscPlay, ofOsc, blobPlay;
var remoteIP, scPort,playOsc, ampOsc, proc0,numSpeakers, bufWood;
var durEnv, numDays, daysDir, daySpeak, oscOut;
ampCtrl = CtkControl.play(initVal: 0.1);
ctkgroup = CtkGroup.play(server:s);
numSpeakers = 100;
oscOut = NetAddr("127.0.0.1", 8000); // 57120 is sclang default port, 8000 is our OF port

SynthDef(\tones, {arg dur, freq, freq2, gldur, amp , attack = 0.01,del;
	var osc, inamp, env, envgen;
	amp = amp.dbamp;
	// Scale amplitude by number of concurrent oscillators
	amp = amp;
	// Use a linear glissando to move from freq1 to freq2 in 'gldur' seconds
	osc = SinOsc.ar(Line.kr(freq, freq2, gldur), 0, 1);
	// Create a new envelop with variable attack and long decay
	env = Env.new([0.0000000002, amp, 0.0000000002], [attack, dur - attack],'exponential');
	envgen = EnvGen.kr(env, doneAction:2);
	Out.ar(0, DelayL.ar(osc*envgen),1.0,del);
}).load(s);

SynthDef (\playbuf1, {arg buf, rtBus, dur, playrate, delTime;
	var in, comp,env;
	in = PlayBuf .ar(2, buf, BufRateScale.kr(buf),rate:playrate);
	env = EnvGen.ar(Env([0, 1, 1, 0], [dur*0.1, dur*0.8, dur*0.1], \sin), doneAction:2);
	comp = DelayL.ar( Compander.ar(in, in, 0.5, 0.3, 0.01, 0.002, 0.01),0.5,delTime);
	Out.ar(rtBus, in * env);
}).load(s);


~playbuf = CtkSynthDef (\playbuf, {arg buf, rtBus, dur, playrate, delTime;
	var in, comp,env;
	in = PlayBuf .ar(2, buf, BufRateScale.kr(buf),rate:playrate);
	env = EnvGen.ar(Env([0, 1, 1, 0], [dur*0.1, dur*0.8, dur*0.1], \sin), doneAction:2);
	comp = DelayL.ar( Compander.ar(in, in, 0.5, 0.3, 0.01, 0.002, 0.01),0.5,delTime);
	Out.ar(rtBus, comp * env);
});

numDays = 7;
daysDir = "/Users/erikparr/Documents/_Projects/Landscapes/snd/days/";
~dayBufs = Array.newClear(numDays);
numDays.do{arg i; var sndpath;
	sndpath = daysDir ++ "/0"++i++".wav";
	~dayBufs[i] = CtkBuffer (sndpath, bufnum:i).load(sync: true);
};
bufWood = CtkBuffer ("/Users/erikparr/Documents/_Projects/Landscapes/snd/random/block2.wav", bufnum:i).load(sync: true);


// bus1env = CtkControl.lfo(LFNoise2, 0.1, 0.01, 0.5).play;

// basic Example.
// g = Tendency.new(1760.0, 440.0, Env([0.01, 2.0], [10], \sin), Env([0.01, 2.0], [10], 		\sin)).asStream(\betaRand);

durEnv = Tendency.new(
	Env([0.5, 1, 0.1,0.01,1], [30, 20,5,10], \sin),
	Env([0.1, 0.5, 0.01,0.001,0.5], [30, 20,5,10], \sin)).asStream(\betaRand);

remoteIP = "169.254.210.147";
scPort = 57120;
m = NetAddr("localhost", scPort);
n = NetAddr("localhost", 8000); // always receives remotely from port 57120
// oscPlay = Routine({arg solenoidID, playMode, isActive, nodeID;
// ofOsc = OSCFunc({arg msg; msg.postln;
// 	~playbuf.note( target:ctkgroup, addAction:\tail )
// 	.buf_(bufWood)
// 	.rtBus_(0)
// 	.delTime_(0.01.rrand(0.5))
// 	.dur_(bufWood.duration)
// 	.playrate_(0.5.rrand(1.25)).play;
//
// }, '/OF'); // create the


// ofOsc = OSCFunc.new({arg msg; msg.postln;
// 	if(msg[2]==1){
// 		// oscPlay.value(msg[1],msg[2],msg[3],msg[4])
// 		oscPlay = Task({arg solenoidID, playMode, isActive, nodeID;
// 			var buf, oscID, count, note,p1,p2,p3,ranDur,ranFreq, ranDel,i1;
// 			count = 0;
// 			oscID=0;
//
// 			ranFreq = 220.rrand(1200);
// 			ranDel = 0.4.rrand(1.0);
// 			ranDel.wait;
// 			i1=1.0;
// 			p1 = Pseq([0.5*i1, 2.0*i1], inf).asStream;
// 			p2 = Pseq([0.25, 0.25,0.25], inf).asStream;
// 			p3 = Pseq([0.25,0.25,5.0], inf).asStream;
// 			if(msg[4]==1){ranDur=p1};
// 			if(msg[4]==2){ranDur=p2};
// 			if(msg[4]==3){ranDur=p3};
// 			inf.do({
// 				note = ~playbuf.note( target:ctkgroup, addAction:\tail )
// 				.buf_(bufWood)
// 				.rtBus_(0)
// 				.dur_(bufWood.duration)
// 				.playrate_(1).play;
//
// 				// n.sendMsg("/SC",oscID);
// 				// solenoidID.postln;
// 				ranDur.next.wait;
// 			});
// 		}).play;
//
// 	}{
// 	oscPlay.stop;};
//
// }, '/OF'); // create the
//msg[0] = address
//msg[1] = playmode
//msg[2] = isActive
//msg[3] = nodeID
//msg[4...] = solenoidID(s)

blobPlay = OSCFunc.new({arg msg;
	var numSolenoids, solenoidArray;
	msg.postln;
		if(msg[1]==2){
						~playbuf.note( target:ctkgroup, addAction:\tail )
				.buf_(bufWood)
				.rtBus_(0)
				.dur_(bufWood.duration)
				.playrate_(1).play;

	};
	if(msg[1]==1){
		// oscPlay.value(msg[1],msg[2],msg[3],msg[4])
		numSolenoids = msg.size-4;
		solenoidArray = Array.fill(numSolenoids, { arg i; msg[i+4]});
		oscPlay = Task({arg solenoidID, playMode, isActive, nodeID;
			var buf, oscID, count, note,p1,p2,p3,ranDur,ranFreq, ranDel,i1;
			count = 0;
			oscID=0;

			ranFreq = 220.rrand(1200);
			ranDel = 0.4.rrand(1.0);
			ranDel.wait;
			i1=0.5;
			p1 = Pseq([0.5*i1, 2.0*i1], inf).asStream;
			p2 = Pseq([0.25*i1, 0.25*i1,0.25*i1], inf).asStream;
			p3 = Pseq([0.25,0.25,5.0], inf).asStream;
			ranDur = p2;
			if(msg[3]==1){ranDur=p1};
			if(msg[3]==2){ranDur=p2};
			if(msg[3]==3){ranDur=p3};
			inf.do({

				note = ~playbuf.note( target:ctkgroup, addAction:\tail )
				.buf_(bufWood)
				.rtBus_(0)
				.dur_(bufWood.duration)
				.playrate_(1).play;

				oscOut.sendMsg("/SC",solenoidArray[count]);
				// oscOut.sendMsg("/SC",1);
				// solenoidID.postln;
				ranDur.next.wait;
				count=(count+1)%solenoidArray.size;
			});
		}).play;

	}{
		oscPlay.stop;};

}, '/OF'); // create the

//
// procPlay = Task({
// 	var oscID, count, note;
// 	count = 0;
// 	oscID=0;
//
// 	// inf.do({
// 	// 	note = ~playbuf.note( target:ctkgroup, addAction:\tail )
// 	// 	.buf_(bufWood)
// 	// 	.rtBus_(0)
// 	// 	.dur_(bufWood.duration)
// 	// 	.playrate_(0.5.rrand(1.25)).play;
// 	//
// 	// 	n.sendMsg("/oscID",oscID);
// 	// 	count=(count+1)%numDays;
// 	// 	oscID=0.rrand(numSpeakers);
// 	// 	oscID.postln;
// 	// 	(durEnv.next).wait;
// 	// })
// });


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
		dayTimer.postln;
		1.wait;
	});
});

// n.sendMsg("/OF",  1,1,1,2);
// n.sendMsg("/OF",  0,0,1,1);


// eventScore = Routine{
// 	procPlay.play;
// 	daySpeak.play;
// 	// "playing".postln;
// 	// s.queryAllNodes;
// 	1000.wait;
// 	procPlay.stop;
// 	daySpeak.stop;
// 	"---".postln;
// 	// 20.wait;
// };
// y=eventScore.play;
// // s.freeAll
// // s.queryAllNodes;
