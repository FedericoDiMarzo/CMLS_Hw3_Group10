s.boot;
s.meter;
s.plotTree;
s.reboot;

// ================ Parameters  ================ //

(

// global
~bpm = 120;
~tempo = TempoClock(~bpm/120);
~sendingAddress = NetAddr.new("127.0.0.1", 57120);
~masterVolume = 0.5;

// kick
~kickVolume = 1;
~kickPan = 0;
~kickDelaySend = 0;
~kickReverbSend = 0;

// snare
~snareVolume = 1;
~snarePan = 0;
~snareDelaySend = 0;
~snareReverbSend = 0;

// clap
~clapVolume = 1;
~clapPan = 0;
~clapDelaySend = 0;
~clapReverbSend = 0;

// closed hat
~closedHatVolume = 1;
~closedHatPan = 0;
~closedHatDelaySend = 0;
~closedHatReverbSend = 0;

// open hat
~openHatVolume = 1;
~openHatPan = 0;
~openHatDelaySend = 0;
~openHatReverbSend = 0;

// delay
~delayTime = 0.3;
~delayFeedback = 2;

// reverb
~reverbDamp = 0.5;
~reverbDecay = 0.7;

// bitCrusher
~bitCrusherDist = 9;

// patterns
~kickPattern = [0, 0, 0, 0, 0, 0, 0, 0];
~snarePattern = [0, 0, 0, 0, 0, 0, 0, 0];
~clapPattern = [0, 0, 0, 0, 0, 0, 0, 0];
~closedHatPattern = [0, 0, 0, 0, 0, 0, 0, 0];
~openHatPattern = [0, 0, 0, 0, 0, 0, 0, 0];


// players
~kickPlayer = 0;
~snarePlayer = 0;
~clapPlayer = 0;
~closedHatPlayer = 0;
~openHatPlayer = 0;


// ================     Routing     ================ //

// groups
~drums = Group.new;
~effects = Group.new(~drums, \addAfter);
~master = Group.new(~effects, \addAfter);

// main route
~preFx = Bus.audio(s, 2);


// fx send
~reverbAux = Bus.audio(s, 2);
~delayAux = Bus.audio(s, 2);
~auxBus = Bus.audio(s, 2);


SynthDef(\masterVolume, {
	arg inBus, outBus,
	masterVol = 1;

	var signal,fx;

	signal = In.ar(inBus, 2);

	fx = signal * masterVol;

	ReplaceOut.ar(outBus, fx);
}).add;

~mVolume = Synth(\masterVolume,
	[\inbus, 0,
	\outBus, 0,
	\masterVol, ~masterVolume],
	~master);



// ================       FX       ================ //

// Reverb
SynthDef(\reverb, {
	arg outBus, inBus,
		decay = 0.5, damp = 0.5;
	var signal, fx;

	signal = In.ar(inBus, 2);

	fx = FreeVerb2.ar(
		in: signal[0],
		in2: signal[1],
		mix: 1,
		room: decay,
		damp: damp);

	Out.ar(outBus, fx);
}).add;

~reverb = Synth(\reverb,
	[\inBus, ~reverbAux,
	\outBus, 0,
		\damp, ~reverbDamp,
		\decay, ~reverbDecay],
	~effects);



// Delay
SynthDef(\delay, {
	arg inBus, outBus,
		time = 0.5, feed = 1;
	var signal, fx;

	signal = In.ar(inBus, 2);

	fx = CombC.ar(
		in: signal,
		maxdelaytime: 10,
		delaytime: time,
		decaytime: feed*time);

	Out.ar(outBus, {fx}.dup);
}).add;

~delay = Synth(\delay,
	[\inBus, ~delayAux,
	\outBus, 0,
		\time, ~delayTime,
		\feed, ~delayFeedback],
	~effects);


// bitCrusher
SynthDef(\bitCrusher, {
	arg inBus, outBus,
	    dist = -5;
	var signal, fx, mix = 0.5;

	signal = In.ar(inBus, 2);

	fx = signal.round(2**(dist));

	Out.ar(outBus, signal * (1-mix));
	Out.ar(outBus, fx * mix);
}).add;

~bitCrusher = Synth(\bitCrusher,
	[\inBus, ~preFx,
	\outBus, 0,
		\dist, ~bitCrusherDist],
	~effects);


// ================     Sounds     ================ //

// Kick
SynthDef(\kick, {
	arg outBus, reverbFxBus, delayFxBus,
	    vol = 1.0, pan = 0.5, reverbSendAmount = 0.0, delaySendAmount = 0.0;

    var body, bodyFreq, bodyAmp;
    var pop, popFreq, popAmp;
    var click, clickAmp;
    var snd;

    // body starts midrange, quickly drops down to low freqs, and trails off
    bodyFreq = EnvGen.ar(Env([261, 120, 51], [0.035, 0.08], curve: \exp));
    bodyAmp = EnvGen.ar(Env.linen(0.005, 0.1, 0.3), doneAction: 2);
    body = SinOsc.ar(bodyFreq) * bodyAmp;
    // pop sweeps over the midrange
    popFreq = XLine.kr(750, 261, 0.02);
    popAmp = EnvGen.ar(Env.linen(0.001, 0.02, 0.001)) * 0.15;
    pop = SinOsc.ar(popFreq) * popAmp;
    // click is spectrally rich, covering the high-freq range
    // you can use Formant, FM, noise, whatever
    clickAmp = EnvGen.ar(Env.perc(0.001, 0.01)) * 0.15;
    click = LPF.ar(Formant.ar(910, 4760, 2110), 3140) * clickAmp;

    snd = body + pop + click;
	snd = (snd.tanh);

	Out.ar(outBus, Pan2.ar(snd, pan, vol));
	Out.ar(reverbFxBus, snd * reverbSendAmount);
	Out.ar(delayFxBus, snd * delaySendAmount);

}).add;



// Snare
SynthDef(\snare, {
	arg outBus, reverbFxBus, delayFxBus,
	    vol = 1.0, pan = 0.5, reverbSendAmount = 0.0, delaySendAmount = 0.0;

    var pop, popAmp, popFreq;
    var noise, noiseAmp;
    var snd;

	// pop makes a click coming from very high frequencies
    // slowing down a little and stopping in mid-to-low
    popFreq = EnvGen.ar(Env([3261, 410, 160], [0.005, 0.01], curve: \exp));
    popAmp = EnvGen.ar(Env.perc(0.001, 0.11)) * 0.7;
    pop = SinOsc.ar(popFreq) * popAmp;
    // bandpass-filtered white noise
    noiseAmp = EnvGen.ar(Env.perc(0.001, 0.15), doneAction: 2);
    noise = BPF.ar(WhiteNoise.ar, 810, 1.6) * noiseAmp;

    snd = (pop + noise) * 1.3;

	Out.ar(outBus, Pan2.ar(snd, pan, vol));
	Out.ar(reverbFxBus, snd * reverbSendAmount);
	Out.ar(delayFxBus, snd * delaySendAmount);

}).add;


// Clap
SynthDef(\clap, {
	arg outBus, reverbFxBus, delayFxBus,
	    vol = 1.0, pan = 0.5, reverbSendAmount = 0.0, delaySendAmount = 0.0;

	var env1, env2, snd, noise1, noise2;

    // noise 1 - 4 short repeats
    env1 = EnvGen.ar(
        Env.new(
            [0, 1, 0, 0.9, 0, 0.7, 0, 0.5, 0],
            [0.001, 0.009, 0, 0.008, 0, 0.01, 0, 0.03],
            [0, -3, 0, -3, 0, -3, 0, -4]
        )
    );

    noise1 = WhiteNoise.ar(env1);
    noise1 = HPF.ar(noise1, 600);
    noise1 = LPF.ar(noise1, XLine.kr(7200, 4000, 0.03));
    noise1 = BPF.ar(noise1, 1620, 3);

    // noise 2 - 1 longer single
    env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, 0.18], [0, -4]), doneAction:2);

    noise2 = WhiteNoise.ar(env2);
    noise2 = HPF.ar(noise2, 1000);
    noise2 = LPF.ar(noise2, 7600);
    noise2 = BPF.ar(noise2, 1230, 0.7, 0.7);
    snd = noise1 + noise2;
    snd = snd * 2;
    snd = snd.softclip;

	Out.ar(outBus, Pan2.ar(snd, pan, vol));
	Out.ar(reverbFxBus, snd * reverbSendAmount);
	Out.ar(delayFxBus, snd * delaySendAmount);

}).add;


// Closed Hat
SynthDef(\closedhat, {
	arg outBus, reverbFxBus, delayFxBus,
	    vol = 1.0, pan = 0.5, reverbSendAmount = 0.0, delaySendAmount = 0.0;


    var click, clickAmp;
    var noise, noiseAmp;
    var snd;

    // noise -> resonance -> expodec envelope
    noiseAmp = EnvGen.ar(Env.perc(0.001, 0.3, curve: -8), doneAction: 2);
    noise = Mix(BPF.ar(ClipNoise.ar, [4010, 4151], [0.15, 0.56], [1.0, 0.6])) * 0.7 * noiseAmp;

    snd = noise;

	Out.ar(outBus, Pan2.ar(snd, pan, vol));
	Out.ar(reverbFxBus, snd * reverbSendAmount);
	Out.ar(delayFxBus, snd * delaySendAmount);

}).add;


// Open Hat
SynthDef(\openhat, {
	arg outBus, reverbFxBus, delayFxBus,
	    vol = 1.0, pan = 0.5, reverbSendAmount = 0.0, delaySendAmount = 0.0;

    var hatosc, hatenv, hatnoise, snd ;

    hatnoise = {LPF.ar(WhiteNoise.ar(1),6000)};
    hatosc = {HPF.ar(hatnoise,2000)};
    hatenv = {Line.ar(1, 0, 0.3, doneAction: 2)};

    snd = (hatosc * hatenv);

	Out.ar(outBus, Pan2.ar(snd, pan, vol));
	Out.ar(reverbFxBus, snd * reverbSendAmount);
	Out.ar(delayFxBus, snd * delaySendAmount);

}).add;



// ================    Triggering Sounds    ================ //

// kick trigger function
~triggerKick = {
	Synth(\kick,
		[\outBus, ~preFx,
			\reverbFxBus, ~reverbAux,
			\delayFxBus, ~delayAux,
			\vol, ~kickVolume,
			\pan, ~kickPan,
			\delaySendAmount, ~kickDelaySend,
			\reverbSendAmount, ~kickReverbSend],
		~drums);
};



// snare trigger
~triggerSnare = {
	Synth(\snare,
		[\outBus, ~preFx,
			\reverbFxBus, ~reverbAux,
			\delayFxBus, ~delayAux,
			\vol, ~snareVolume,
			\pan, ~snarePan,
			\delaySendAmount, ~snareDelaySend,
			\reverbSendAmount, ~snareReverbSend],
		~drums);
};



// clap trigger
~triggerClap = {
	Synth(\clap,
		[\outBus, ~preFx,
			\reverbFxBus, ~reverbAux,
			\delayFxBus, ~delayAux,
			\vol, ~clapVolume,
			\pan, ~clapPan,
			\delaySendAmount, ~clapDelaySend,
			\reverbSendAmount, ~clapReverbSend],
		~drums);
};


// closedHat trigger
~triggerClosedHat = {
	Synth(\closedhat,
		[\outBus, ~preFx,
			\reverbFxBus, ~reverbAux,
			\delayFxBus, ~delayAux,
			\vol, ~closedHatVolume,
			\pan, ~closedHatPan,
			\delaySendAmount, ~closedHatDelaySend,
			\reverbSendAmount, ~closedHatReverbSend],
		~drums);
};


// openHat trigger
~triggerOpenHat = {
	Synth(\openhat,
		[\outBus, ~preFx,
			\reverbFxBus, ~reverbAux,
			\delayFxBus, ~delayAux,
			\vol, ~openHatVolume,
			\pan, ~openHatPan,
			\delaySendAmount, ~openHatDelaySend,
			\reverbSendAmount, ~openHatReverbSend],
		~drums);
};

// ================    Sequencing    ================ //





// ================    OSC     ================ //

// debug
// OSCFunc.trace(true); // Turn posting on
// OSCFunc.trace(false); // Turn posting off
// ~sendingAddress.sendMsg('/test');



// >>    triggers     << //

// kick trigger
OSCdef.new(
	\kickTrigger,
	{
		|msg|
		if(msg[1]==1,
			{~triggerKick.value});
	},
	'/trigger/multiTrigger/1/1'
);


// snare trigger
OSCdef.new(
	\snareTrigger,
	{
		|msg|
		if(msg[1]==1,
			{~triggerSnare.value});

	},
	'/trigger/multiTrigger/1/2'
);


// clap trigger
OSCdef.new(
	\clapTrigger,
	{
		|msg|
		if(msg[1]==1,
			{~triggerClap.value});

	},
	'/trigger/multiTrigger/1/3'
);

// closedHat trigger
OSCdef.new(
	\closedHatTrigger,
	{
		|msg|
		if(msg[1]==1,
			{~triggerClosedHat.value});

	},
	'/trigger/multiTrigger/1/4'
);

// openHat trigger
OSCdef.new(
	\openHatTrigger,
	{
		|msg|
		if(msg[1]==1,
			{~triggerOpenHat.value});

	},
	'/trigger/multiTrigger/1/5'
);


// >>    sequencer     << //

~startTask = {
	arg tempo, triggerFunction, pattern;
	Task({
		var i = 0;
		loop {
			inf.do({
				if(pattern.wrapAt(i) == 1, {
					triggerFunction.value;
				});
				i = i + 1;
				0.25.wait;
			});
		}
	}).play(tempo, true);
};

// sequencer play-stop
OSCdef.new(
	\sequencerPlay,
	{
		|msg|
		// converting patterns
		if(
			msg[1] == 1,
			{ // play
				~kickTask = ~startTask.value(~tempo, ~triggerKick, ~kickPattern);
				~snareTask = ~startTask.value(~tempo, ~triggerSnare, ~snarePattern);
				~clapTask = ~startTask.value(~tempo, ~triggerClap, ~clapPattern);
				~closedHatTask = ~startTask.value(~tempo, ~triggerClosedHat, ~closedHatPattern);
				~openHatTask = ~startTask.value(~tempo, ~triggerOpenHat, ~openHatPattern);
			},

			{ // stop
				~kickTask.stop;
				~snareTask.stop;
				~clapTask.stop;
				~closedHatTask.stop;
				~openHatTask.stop;
			}
		)


	},
	'/sequencer/play'
);

// >>    grid     << //

// grid5_1
OSCdef.new(
	\setGrid_5_1,
	{
		|msg|
		~kickPattern[0] = msg[1];
	},
	'/sequencer/grid/5/1'
);

// grid5_2
OSCdef.new(
	\setGrid_5_2,
	{
		|msg|
		~kickPattern[1] = msg[1];
	},
	'/sequencer/grid/5/2'
);

// grid5_3
OSCdef.new(
	\setGrid_5_3,
	{
		|msg|
		~kickPattern[2] = msg[1];
	},
	'/sequencer/grid/5/3'
);

// grid5_4
OSCdef.new(
	\setGrid_5_4,
	{
		|msg|
		~kickPattern[3] = msg[1];
	},
	'/sequencer/grid/5/4'
);

// grid5_5
OSCdef.new(
	\setGrid_5_5,
	{
		|msg|
		~kickPattern[4] = msg[1];
	},
	'/sequencer/grid/5/5'
);

// grid5_6
OSCdef.new(
	\setGrid_5_6,
	{
		|msg|
		~kickPattern[5] = msg[1];
	},
	'/sequencer/grid/5/6'
);

// grid5_7
OSCdef.new(
	\setGrid_5_7,
	{
		|msg|
		~kickPattern[6] = msg[1];
	},
	'/sequencer/grid/5/7'
);

// grid5_8
OSCdef.new(
	\setGrid_5_8,
	{
		|msg|
		~kickPattern[7] = msg[1];
	},
	'/sequencer/grid/5/8'
);



//snare//

// grid4_1
OSCdef.new(
	\setGrid_4_1,
	{
		|msg|
		~snarePattern[0] = msg[1];
	},
	'/sequencer/grid/4/1'
);

// grid4_2
OSCdef.new(
	\setGrid_4_2,
	{
		|msg|
		~snarePattern[1] = msg[1];
	},
	'/sequencer/grid/4/2'
);

// grid4_3
OSCdef.new(
	\setGrid_4_3,
	{
		|msg|
		~snarePattern[2] = msg[1];
	},
	'/sequencer/grid/4/3'
);

// grid4_4
OSCdef.new(
	\setGrid_4_4,
	{
		|msg|
		~snarePattern[3] = msg[1];
	},
	'/sequencer/grid/4/4'
);

// grid4_5
OSCdef.new(
	\setGrid_4_5,
	{
		|msg|
		~snarePattern[4] = msg[1];
	},
	'/sequencer/grid/4/5'
);

// grid4_6
OSCdef.new(
	\setGrid_4_6,
	{
		|msg|
		~snarePattern[5] = msg[1];
	},
	'/sequencer/grid/4/6'
);

// grid4_7
OSCdef.new(
	\setGrid_4_7,
	{
		|msg|
		~snarePattern[6] = msg[1];
	},
	'/sequencer/grid/4/7'
);

// grid4_8
OSCdef.new(
	\setGrid_4_8,
	{
		|msg|
		~snarePattern[7] = msg[1];
	},
	'/sequencer/grid/4/8'
);


//clap//

// grid3_1
OSCdef.new(
	\setGrid_3_1,
	{
		|msg|
		~clapPattern[0] = msg[1];
	},
	'/sequencer/grid/3/1'
);

// grid3_2
OSCdef.new(
	\setGrid_3_2,
	{
		|msg|
		~clapPattern[1] = msg[1];
	},
	'/sequencer/grid/3/2'
);

// grid3_3
OSCdef.new(
	\setGrid_3_3,
	{
		|msg|
		~clapPattern[2] = msg[1];
	},
	'/sequencer/grid/3/3'
);

// grid3_4
OSCdef.new(
	\setGrid_3_4,
	{
		|msg|
		~clapPattern[3] = msg[1];
	},
	'/sequencer/grid/3/4'
);

// grid3_5
OSCdef.new(
	\setGrid_3_5,
	{
		|msg|
		~clapPattern[4] = msg[1];
	},
	'/sequencer/grid/3/5'
);

// grid3_6
OSCdef.new(
	\setGrid_3_6,
	{
		|msg|
		~clapPattern[5] = msg[1];
	},
	'/sequencer/grid/3/6'
);

// grid3_7
OSCdef.new(
	\setGrid_3_7,
	{
		|msg|
		~clapPattern[6] = msg[1];
	},
	'/sequencer/grid/3/7'
);

// grid3_8
OSCdef.new(
	\setGrid_3_8,
	{
		|msg|
		~clapPattern[7] = msg[1];
	},
	'/sequencer/grid/3/8'
);



// closed hat //

// grid2_1
OSCdef.new(
	\setGrid_2_1,
	{
		|msg|
		~closedHatPattern[0] = msg[1];
	},
	'/sequencer/grid/2/1'
);

// grid2_2
OSCdef.new(
	\setGrid_2_2,
	{
		|msg|
		~closedHatPattern[1] = msg[1];
	},
	'/sequencer/grid/2/2'
);

// grid2_3
OSCdef.new(
	\setGrid_2_3,
	{
		|msg|
		~closedHatPattern[2] = msg[1];
	},
	'/sequencer/grid/2/3'
);

// grid2_4
OSCdef.new(
	\setGrid_2_4,
	{
		|msg|
		~closedHatPattern[3] = msg[1];
	},
	'/sequencer/grid/2/4'
);

// grid2_5
OSCdef.new(
	\setGrid_2_5,
	{
		|msg|
		~closedHatPattern[4] = msg[1];
	},
	'/sequencer/grid/2/5'
);

// grid2_6
OSCdef.new(
	\setGrid_2_6,
	{
		|msg|
		~closedHatPattern[5] = msg[1];
	},
	'/sequencer/grid/2/6'
);

// grid2_7
OSCdef.new(
	\setGrid_2_7,
	{
		|msg|
		~closedHatPattern[6] = msg[1];
	},
	'/sequencer/grid/2/7'
);

// grid2_8
OSCdef.new(
	\setGrid_2_8,
	{
		|msg|
		~closedHatPattern[7] = msg[1];
	},
	'/sequencer/grid/2/8'
);


// open hat //


// grid1_1
OSCdef.new(
	\setGrid_1_1,
	{
		|msg|
		~openHatPattern[0] = msg[1];
	},
	'/sequencer/grid/1/1'
);

// grid1_2
OSCdef.new(
	\setGrid_1_2,
	{
		|msg|
		~openHatPattern[1] = msg[1];
	},
	'/sequencer/grid/1/2'
);

// grid1_3
OSCdef.new(
	\setGrid_1_3,
	{
		|msg|
		~openHatPattern[2] = msg[1];
	},
	'/sequencer/grid/1/3'
);

// grid1_4
OSCdef.new(
	\setGrid_1_4,
	{
		|msg|
		~openHatPattern[3] = msg[1];
	},
	'/sequencer/grid/1/4'
);

// grid1_5
OSCdef.new(
	\setGrid_1_5,
	{
		|msg|
		~openHatPattern[4] = msg[1];
	},
	'/sequencer/grid/1/5'
);

// grid1_6
OSCdef.new(
	\setGrid_1_6,
	{
		|msg|
		~openHatPattern[5] = msg[1];
	},
	'/sequencer/grid/1/6'
);

// grid1_7
OSCdef.new(
	\setGrid_1_7,
	{
		|msg|
		~openHatPattern[6] = msg[1];
	},
	'/sequencer/grid/1/7'
);

// grid1_8
OSCdef.new(
	\setGrid_1_8,
	{
		|msg|
		~openHatPattern[7] = msg[1];
	},
	'/sequencer/grid/1/8'
);





// >>    setters     << //

// master volume
OSCdef.new(
	\setMasterVolume,
	{
		|msg|
		~masterVolume = msg[1];
		~mVolume.set(\masterVol, msg[1]);
	},
	'/mix/masterVolume'
);

// bpm
OSCdef.new(
	\setBpm,
	{
		|msg|
		~bpm = msg[1];
		~tempo = TempoClock(~bpm/120);

		// stopping the sequencer
		~sendingAddress.sendMsg("/sequencer/play", 0)
	},
	'/sequencer/bpm'
);

// master volume
OSCdef.new(
	\masterVolume,
	{
		|msg|
		~masterVolume = msg[1];
		~mixer.set(\masterVol, msg[1]);
	},
	'/masterVolume'
);

// kick volume
OSCdef.new(
	\setKickVolume,
	{
		|msg|
		~kickVolume = msg[1];
	},
	'/kick/volume'
);

// kick pan
OSCdef.new(
	\setKickPan,
	{
		|msg|
		~kickPan = msg[1];
	},
	'/kick/pan'
);

// kick delay send
OSCdef.new(
	\setKickDelay,
	{
		|msg|
		~kickDelaySend = msg[1];
	},
	'/kick/delay'
);

// kick reverb send
OSCdef.new(
	\setKickReverb,
	{
		|msg|
		~kickReverbSend = msg[1];
	},
	'/kick/reverb'
);

// snare volume
OSCdef.new(
	\setSnareVolume,
	{
		|msg|
		~snareVolume = msg[1];
	},
	'/snare/volume'
);

// snare pan
OSCdef.new(
	\setSnarePan,
	{
		|msg|
		~snarePan = msg[1];
	},
	'/snare/pan'
);

// snare delay send
OSCdef.new(
	\setSnareDelay,
	{
		|msg|
		~snareDelaySend = msg[1];
	},
	'/snare/delay'
);

// snare reverb send
OSCdef.new(
	\setSnareReverb,
	{
		|msg|
		~snareReverbSend = msg[1];
	},
	'/snare/reverb'
);

// clap volume
OSCdef.new(
	\setClapVolume,
	{
		|msg|
		~clapVolume = msg[1];
	},
	'/clap/volume'
);

// clap pan
OSCdef.new(
	\setClapPan,
	{
		|msg|
		~clapPan = msg[1];
	},
	'/clap/pan'
);

// clap delay send
OSCdef.new(
	\setClapDelay,
	{
		|msg|
		~clapDelaySend = msg[1];
	},
	'/clap/delay'
);

// clap reverb send
OSCdef.new(
	\setClapReverb,
	{
		|msg|
		~clapReverbSend = msg[1];
	},
	'/clap/reverb'
);

// closed hat volume
OSCdef.new(
	\setClosedHatVolume,
	{
		|msg|
		~closedHatVolume = msg[1];
	},
	'/closedHat/volume'
);

// closed hat pan
OSCdef.new(
	\setClosedHatPan,
	{
		|msg|
		~closedHatPan = msg[1];
	},
	'/closedHat/pan'
);

// closed hat delay send
OSCdef.new(
	\setClosedHatDelay,
	{
		|msg|
		~closedHatDelaySend = msg[1];
	},
	'/closedHat/delay'
);

// closed hat reverb send
OSCdef.new(
	\setClosedHatReverb,
	{
		|msg|
		~closedHatReverbSend = msg[1];
	},
	'/closedHat/reverb'
);

// open hat volume
OSCdef.new(
	\setOpenHatVolume,
	{
		|msg|
		~openHatVolume = msg[1];
	},
	'/openHat/volume'
);

// open hat pan
OSCdef.new(
	\setOpenHatPan,
	{
		|msg|
		~openHatPan = msg[1];
	},
	'/openHat/pan'
);

// open hat send
OSCdef.new(
	\setOpenHatDelay,
	{
		|msg|
		~openHatDelaySend = msg[1];
	},
	'/openHat/delay'
);

// open hat send
OSCdef.new(
	\setOpenHatReverb,
	{
		|msg|
		~openHatReverbSend = msg[1];
	},
	'/openHat/reverb'
);

// reverb damping
OSCdef.new(
	\setReverbDamping,
	{
		|msg|
		~reverbDamp = msg[1];
		~reverb.set(\damp, msg[1]);
	},
	'/fx/damping'
);

// reverb damping
OSCdef.new(
	\setReverbDecay,
	{
		|msg|
		~reverbDecay = msg[1];
		~reverb.set(\decay, msg[1]);
	},
	'/fx/decay'
);

// delay time
OSCdef.new(
	\setDelayTime,
	{
		|msg|
		~delayTime= msg[1];
		~delay.set(\time, msg[1]);

	},
	'/fx/time'
);

// delay feedback
OSCdef.new(
	\setDelayFeedback,
	{
		|msg|
		~delayFeedback= msg[1];
		~delay.set(\feed, msg[1]);
	},
	'/fx/feedback'
);

// bitcrusher dist
OSCdef.new(
	\setBitCrusherDist,
	{
		|msg|
		~bitCrusherDist= msg[1];
		~bitCrusher.set(\dist, msg[1]);
	},
	'/mix/crush'
);



)
