var eventScore, routeGrain,procGrain,numBuffers, proc, ctkgroup;
numBuffers = 20;
ctkgroup = CtkGroup.play(server:s);

routeGrain = {
	var task, sndpath, folder1, folder2, folder3, folder4;

	folder1 = "/Users/erikparr/Documents/_Projects/Landscapes/snd/test/2";
	folder2 = "/Users/erikparr/Documents/_Projects/Landscapes/snd/test/3";
	folder3 = "/Users/erikparr/Documents/_Projects/Landscapes/snd/test/4";
	folder4 = "/Users/erikparr/Documents/_Projects/Landscapes/snd/test/5";



	task = Task({var numChans;
		numChans=1;
		~bufs1 = Array.newClear(numBuffers);
		~bufs2 = Array.newClear(numBuffers);
		~bufs3 = Array.newClear(numBuffers);
		~bufs4 = Array.newClear(numBuffers);


		~bus1 = Array.newClear(numBuffers);
		~bus2 = Array.newClear(numBuffers);
		~bus3 = Array.newClear(numBuffers);
		~bus4 = Array.newClear(numBuffers);

		numBuffers.do{arg i; ~bus1[i] = CtkAudio .new(numChans, 50+i)}; // 50+ range for virtual busses
		numBuffers.do{arg i; ~bus2[i] = CtkAudio .new(numChans, 60+i)};
		numBuffers.do{arg i; ~bus3[i] = CtkAudio .new(numChans, 70+i)};
		numBuffers.do{arg i; ~bus4[i] = CtkAudio .new(numChans, 80+i)};

		~vBusSynth1 = Array.newClear(numBuffers);
		~vBusSynth2 = Array.newClear(numBuffers);
		~vBusSynth3 = Array.newClear(numBuffers);
		~vBusSynth4 = Array.newClear(numBuffers);

		folder1.postln;
		/////////////preload sound samples//////////////////////////////////////
		numBuffers.do{arg i;

			sndpath = folder1 ++ "/"++i++".wav";
			if(File.exists(sndpath, "r") && SoundFile.openRead(sndpath).notNil){
				sndpath.postln;
				if(~bufs1[i].notNil){~bufs1[i].free;};
				try{
					~bufs1[i] = CtkBuffer (sndpath, bufnum:i).load(sync: true);
				} {"oops".postln; thisProcess.recompile};
				if(~bufs1[i].numChannels ==numChans){
					~vBusSynth1[i] = ~synth1.note(target:ctkgroup, addAction:\head).buf_(~bufs1[i])
					.rtBus_(~bus1[i]).dur_(~bufs1[i].duration).play;
				}{"channel mismatch!!".postln;};
			};
			0.25.wait;
			sndpath = folder2 ++ "/"++i++".wav";
			if(File.exists(sndpath, "r") && SoundFile.openRead(sndpath).notNil){
				sndpath.postln;
				if(~bufs2[i].notNil){~bufs2[i].free;};
				try{
					~bufs2[i] = CtkBuffer (sndpath, bufnum:i+10).load(sync: true);
				} {"oops".postln; thisProcess.recompile};
				if(~bufs2[i].numChannels == numChans){
					~vBusSynth2[i] = ~synth1.note(target:ctkgroup, addAction:\head).buf_(~bufs2[i])
					.rtBus_(~bus2[i]).dur_(~bufs2[i].duration).play;
				}{"channel mismatch!!".postln;};
			};
			0.25.wait;
			sndpath = folder3 ++ "/"++i++".wav";
			if(File.exists(sndpath, "r") && SoundFile.openRead(sndpath).notNil){
				sndpath.postln;
				if(~bufs3[i].notNil){~bufs3[i].free;};
				try{
					~bufs3[i] = CtkBuffer (sndpath, bufnum:i+20).load(sync: true);
				} {"oops".postln; thisProcess.recompile};
				if(~bufs3[i].numChannels == numChans){
					~vBusSynth3[i] = ~synth1.note(target:ctkgroup, addAction:\head).buf_(~bufs3[i])
					.rtBus_(~bus3[i]).dur_(~bufs3[i].duration).play;
					}{"channel mismatch!!".postln;};
			};
			0.25.wait;
		};

		sndpath = folder4 ++ "/"++i++".wav";
		if(File.exists(sndpath, "r") && SoundFile.openRead(sndpath).notNil){
			sndpath.postln;
			if(~bufs4[i].notNil){~bufs4[i].free;};
			try{
				~bufs4[i] = CtkBuffer (sndpath, bufnum:i+30).load(sync: true);
			} {"oops".postln; thisProcess.recompile};
			if(~bufs4[i].numChannels == numChans){
				~vBusSynth4[i] = ~synth1.note(target:ctkgroup, addAction:\head).buf_(~bufs4[i])
				.rtBus_(~bus4[i]).dur_(~bufs4[i].duration).play;
			}{"channel mismatch!!".postln;};
		};
		0.25.wait;
	});
	task.play;
};

procGrain = {
	"procGrain playing".postln;
	proc = ProcMod.new(Env([0, 1, 0], [1, 1], \sin, 1), server: s);

	proc.function_({arg group, routebus, server;
		var grainDur,note1;
		grainDur = 0.01;
		Task({
			inf.do({
				note1 = ~synth2.note( target:ctkgroup, addAction:\tail )
				.inbus_([~bus1[0.rrand(numBuffers-1)],
					~bus2[0.rrand(numBuffers-1)],
					~bus1[0.rrand(numBuffers-1)],
					~bus1[0.rrand(numBuffers-1)]].choose)
				.outbus_(0)
				.amp_(1)
				.dur_(grainDur*1.rrand(15)).play;
				(grainDur*0.2).wait;
			})
		});
	});
};

eventScore = Routine{
	var proc1;
	routeGrain.value();
	1.wait;
	proc1 = procGrain.value(); //must create a new instance of procmod so it can be called in a routine
	proc1.play;
	"playing".postln;
	30.wait;
	proc1.release(5);
	// 20.wait;
};
y=eventScore.play;
