s.boot;
s.meter;
s.plotTree;
s.reboot;

/***********************************************************************************************************************

Usage Instructions:

- Download TouchOSC for your mobile phone
- Copy the "Drum_Machine.touchosc" file in your mobile phone and load the layout within the app
- In alternative, download the gui editor from https://hexler.net/products/touchosc, load "Drum_Machine.touchosc" within the gui editor and use the sync function
- Inside TouchOSC app settings, put the host ip, 57120 as output port, 7771 as input port
- Take note of you mobile ip address, and modify ~receiverIP variable (below under Parameters)
- Boot SuperCollider Server
- Execute the block code below while the mobile gui is loaded
- Start playing with the Drum Machine!

***********************************************************************************************************************/


(

// ================ Routing & Effects Definitions ================ //

// master volume
SynthDef(\masterVolume, {
	arg inBus, outBus,
	masterVol = 1;

	var signal,fx;

	signal = In.ar(inBus, 2);

	fx = signal * masterVol;

	ReplaceOut.ar(outBus, fx);
}).add;


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
		damp: damp,
		mul: 0.7
	);

	Out.ar(outBus, fx);
}).add;


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
		decaytime: feed*time,
		mul: 1
	);

	Out.ar(outBus, {fx}.dup);
}).add;


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


// filter
SynthDef(\filter, {
		arg inBus, outBus,
	    cutoff = 5000;
	var signal, fx;

	signal = In.ar(inBus, 2);

	fx = BLowPass4.ar(signal, cutoff, 0.275);


	ReplaceOut.ar(outBus, fx);
}).add;

// ================  Sound Definitions  ================ //

// Kick
SynthDef(\kick, {
	arg outBus, reverbFxBus, delayFxBus,
	    vol = 1.0, pan = 0.5, reverbSendAmount = 0.0, delaySendAmount = 0.0, pitch = 1, mute = 0;

    var body, bodyFreq, bodyAmp;
    var pop, popFreq, popAmp;
    var click, clickAmp;
    var snd;

    // body starts midrange, quickly drops down to low freqs, and trails off
    bodyFreq = EnvGen.ar(Env([261, 120, 51], [0.035, 0.08], curve: \exp));
    bodyAmp = EnvGen.ar(Env.linen(0.005, 0.1, 0.3), doneAction: 2);
    body = SinOsc.ar(bodyFreq * pitch ) * bodyAmp;
    // pop sweeps over the midrange
    popFreq = XLine.kr(750, 261, 0.02);
    popAmp = EnvGen.ar(Env.linen(0.001, 0.02, 0.001)) * 0.15;
	pop = SinOsc.ar(popFreq * pitch) * popAmp;
    // click is spectrally rich, covering the high-freq range
    // you can use Formant, FM, noise, whatever
    clickAmp = EnvGen.ar(Env.perc(0.001, 0.01)) * 0.15;
    click = LPF.ar(Formant.ar(910, 4760, 2110), 3140 * pitch) * clickAmp;

    snd = body + pop + click;
	snd = (snd.tanh) * 0.9;

	Out.ar(outBus, Pan2.ar(snd, pan, vol) * (1-mute));
	Out.ar(reverbFxBus, snd * reverbSendAmount * (1-mute));
	Out.ar(delayFxBus, snd * delaySendAmount * (1-mute));

}).add;


// Snare
SynthDef(\snare, {
	arg outBus, reverbFxBus, delayFxBus,
	    vol = 1.0, pan = 0.5, reverbSendAmount = 0.0, delaySendAmount = 0.0, pitch = 1, mute = 0;

    var pop, popAmp, popFreq;
    var noise, noiseAmp;
    var snd;

	// pop makes a click coming from very high frequencies
    // slowing down a little and stopping in mid-to-low
    popFreq = EnvGen.ar(Env([3261, 410, 160], [0.005, 0.01], curve: \exp));
    popAmp = EnvGen.ar(Env.perc(0.001, 0.11)) * 0.7;
    pop = SinOsc.ar(popFreq * pitch) * popAmp;
    // bandpass-filtered white noise
    noiseAmp = EnvGen.ar(Env.perc(0.001, 0.15), doneAction: 2);
    noise = BPF.ar(WhiteNoise.ar, 810 * pitch, 1.6) * noiseAmp;

    snd = (pop + noise) * 0.85;

	Out.ar(outBus, Pan2.ar(snd, pan, vol) * (1-mute));
	Out.ar(reverbFxBus, snd * reverbSendAmount * (1-mute));
	Out.ar(delayFxBus, snd * delaySendAmount * (1-mute));

}).add;


// Clap
SynthDef(\clap, {
	arg outBus, reverbFxBus, delayFxBus,
	    vol = 1.0, pan = 0.5, reverbSendAmount = 0.0, delaySendAmount = 0.0, pitch = 1, mute = 0;

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
    noise1 = HPF.ar(noise1, 600 * pitch);
    noise1 = LPF.ar(noise1, XLine.kr(7200, 4000, 0.03) * pitch);
    noise1 = BPF.ar(noise1, 1620 * pitch, 3);

    // noise 2 - 1 longer single
    env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, 0.18], [0, -4]), doneAction:2);

    noise2 = WhiteNoise.ar(env2);
    noise2 = HPF.ar(noise2, 1000 * pitch);
    noise2 = LPF.ar(noise2, 7600 * pitch);
    noise2 = BPF.ar(noise2, 1230 * pitch, 0.7, 0.7);
    snd = noise1 + noise2;
    snd = snd * 2;
    snd = snd.softclip;

	Out.ar(outBus, Pan2.ar(snd, pan, vol) * (1-mute));
	Out.ar(reverbFxBus, snd * reverbSendAmount * (1-mute));
	Out.ar(delayFxBus, snd * delaySendAmount * (1-mute));

}).add;


// Closed Hat
SynthDef(\closedhat, {
	arg outBus, reverbFxBus, delayFxBus,
	    vol = 1.0, pan = 0.5, reverbSendAmount = 0.0, delaySendAmount = 0.0, pitch = 1, mute = 0;


    var click, clickAmp;
    var noise, noiseAmp;
    var snd;

    // noise -> resonance -> expodec envelope
    noiseAmp = EnvGen.ar(Env.perc(0.001, 0.3, curve: -8), doneAction: 2);
    noise = Mix(BPF.ar(ClipNoise.ar, [4010, 4151] * pitch, [0.15, 0.56], [1.0, 0.6])) * 0.7 * noiseAmp;

    snd = noise * 0.9;

	Out.ar(outBus, Pan2.ar(snd, pan, vol) * (1-mute));
	Out.ar(reverbFxBus, snd * reverbSendAmount * (1-mute));
	Out.ar(delayFxBus, snd * delaySendAmount * (1-mute));

}).add;


// Open Hat
SynthDef(\openhat, {
	arg outBus, reverbFxBus, delayFxBus,
	    vol = 1.0, pan = 0.5, reverbSendAmount = 0.0, delaySendAmount = 0.0, pitch = 1, mute = 0;

    var hatosc, hatenv, hatnoise, snd ;

    hatnoise = {LPF.ar(WhiteNoise.ar(1),6000 * pitch)};
    hatosc = {HPF.ar(hatnoise,2000 * pitch)};
    hatenv = {Line.ar(1, 0, 0.3, doneAction: 2)};

    snd = (hatosc * hatenv) * 0.8;

	Out.ar(outBus, Pan2.ar(snd, pan, vol) * (1-mute));
	Out.ar(reverbFxBus, snd * reverbSendAmount * (1-mute));
	Out.ar(delayFxBus, snd * delaySendAmount * (1-mute));

}).add;



// ================ Parameters  ================ //


// global

~receiverIP = "192.168.1.155"; //change this with the actual IP of your mobile phone

~localAddress = NetAddr.new("127.0.0.1", 57120);
~receivingAddr = NetAddr.new(~receiverIP, 7771);

~bpm = 120;


~tempo = TempoClock(~bpm/120);


~masterVolume = 0.75;



// kick
~kickVolume = 1;
~kickPan = 0;
~kickDelaySend = 0;
~kickReverbSend = 0;
~kickPitch = 1;
~kickMute = 0;



// snare
~snareVolume = 1;
~snarePan = 0;
~snareDelaySend = 0;
~snareReverbSend = 0;
~snarePitch = 1;
~snareMute = 0;



// clap
~clapVolume = 1;
~clapPan = 0;
~clapDelaySend = 0;
~clapReverbSend = 0;
~clapPitch = 1;
~clapMute = 0;



// closed hat
~closedHatVolume = 1;
~closedHatPan = 0;
~closedHatDelaySend = 0;
~closedHatReverbSend = 0;
~closedHatPitch = 1;
~closedHatMute = 0;



// open hat
~openHatVolume = 1;
~openHatPan = 0;
~openHatDelaySend = 0;
~openHatReverbSend = 0;
~openHatPitch = 1;
~openHatMute = 0;




// delay
~delayTime = 0.3;
~delayFeedback = 2;



// reverb
~reverbDamp = 0.5;
~reverbDecay = 0.7;




// bitCrusher
~bitCrusherDist = -10;


// filter
~filterCutoff = 16000;


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




~mVolume = Synth(\masterVolume,
	[\inbus, 0,
	\outBus, 0,
	\masterVol, ~masterVolume],
	~master);



// ================       FX       ================ //



~reverb = Synth(\reverb,
	[\inBus, ~reverbAux,
	\outBus, 0,
		\damp, ~reverbDamp,
		\decay, ~reverbDecay],
	~effects);





~delay = Synth(\delay,
	[\inBus, ~delayAux,
	\outBus, 0,
		\time, ~delayTime,
		\feed, ~delayFeedback],
	~effects);




~bitCrusher = Synth(\bitCrusher,
	[\inBus, ~preFx,
	\outBus, 0,
		\dist, ~bitCrusherDist],
	~effects);




~filter = Synth(\filter,
	[\inBus, 0,
	\outBus, 0,
		\cutoff, ~filterCutoff],
	~master);



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
			\reverbSendAmount, ~kickReverbSend,
			\pitch, ~kickPitch,
			\mute, ~kickMute],
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
			\reverbSendAmount, ~snareReverbSend,
			\pitch, ~snarePitch,
			\mute, ~snareMute],
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
			\reverbSendAmount, ~clapReverbSend,
			\pitch, ~clapPitch,
			\mute, ~clapMute],
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
			\reverbSendAmount, ~closedHatReverbSend,
			\pitch, ~closedHatPitch,
			\mute, ~closedHatMute],
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
			\reverbSendAmount, ~openHatReverbSend,
			\pitch, ~openHatPitch,
			\mute, ~openHatMute],
		~drums);
};


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
		~bpm = round(msg[1]).asInteger;
		~tempo = TempoClock(~bpm/120);
		~receivingAddr.sendMsg('/sequencer/bpm_label', ~bpm);


		// stopping the sequencer
		~localAddress.sendMsg("/sequencer/play", 0);
		~receivingAddr.sendMsg('/sequencer/play', 0);

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

// kick mute
OSCdef.new(
	\setKickMute,
	{
		|msg|
		~kickMute = msg[1];
	},
	'/mix/mute/1/1'
);

// snare mute
OSCdef.new(
	\setSnareMute,
	{
		|msg|
		~snareMute = msg[1];
	},
	'/mix/mute/1/2'
);

// clap mute
OSCdef.new(
	\setClapMute,
	{
		|msg|
		~clapMute = msg[1];
	},
	'/mix/mute/1/3'
);

// closed hat mute
OSCdef.new(
	\setClosedHatMute,
	{
		|msg|
		~closedHatMute = msg[1];
	},
	'/mix/mute/1/4'
);

// open hat mute
OSCdef.new(
	\setOpenHatMute,
	{
		|msg|
		~openHatMute = msg[1];
	},
	'/mix/mute/1/5'
);


// kick volume
OSCdef.new(
	\setKickVolume,
	{
		|msg|
		~kickVolume = msg[1];
	},
	'/mix/volume/1'
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

// kick pitch
OSCdef.new(
	\setKickPitch,
	{
		|msg|
		~kickPitch = msg[1];
	},
	'/kick/pitch'
);

// snare volume
OSCdef.new(
	\setSnareVolume,
	{
		|msg|
		~snareVolume = msg[1];
	},
	'/mix/volume/2'
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

// snare pitch
OSCdef.new(
	\setSnarePitch,
	{
		|msg|
		~snarePitch = msg[1];
	},
	'/snare/pitch'
);

// clap volume
OSCdef.new(
	\setClapVolume,
	{
		|msg|
		~clapVolume = msg[1];
	},
	'/mix/volume/3'
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

// clap pitch
OSCdef.new(
	\setClapPitch,
	{
		|msg|
		~clapPitch = msg[1];
	},
	'/clap/pitch'
);

// closed hat volume
OSCdef.new(
	\setClosedHatVolume,
	{
		|msg|
		~closedHatVolume = msg[1];
	},
	'/mix/volume/4'
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

// closed hat pitch
OSCdef.new(
	\setClosedHatPitch,
	{
		|msg|
		~closedHatPitch = msg[1];
	},
	'/closedHat/pitch'
);

// open hat volume
OSCdef.new(
	\setOpenHatVolume,
	{
		|msg|
		~openHatVolume = msg[1];
	},
	'/mix/volume/5'
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

// open hat pitch
OSCdef.new(
	\setOpenHatPitch,
	{
		|msg|
		~openHatPitch = msg[1];
	},
	'/openHat/pitch'
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
		~delayTime = msg[1];
		~delay.set(\time, msg[1]);
	},
	'/fx/time'
);

// delay feedback
OSCdef.new(
	\setDelayFeedback,
	{
		|msg|
		~delayFeedback = msg[1];
		~delay.set(\feed, msg[1]);
	},
	'/fx/feedback'
);

// bitcrusher dist
OSCdef.new(
	\setBitCrusherDist,
	{
		|msg|
		~bitCrusherDist = msg[1];
		~bitCrusher.set(\dist, msg[1]);
	},
	'/mix/crush'
);

// filter cutoff
OSCdef.new(
	\seFilterCutoff,
	{
		|msg|
		var cutoffMapping = ((2)**((msg[1]+1)*7)+222).clip(350, 16000);
		~filterCutoff = msg[1];
		~filter.set(\cutoff, cutoffMapping);
	},
	'/mix/cutoff'
);



// >>    initial GUI setters     << //


~receivingAddr.sendMsg('sequencer/bpm', ~bpm);
~receivingAddr.sendMsg('/sequencer/bpm_label', round(~bpm).asInteger);
~receivingAddr.sendMsg('mix/masterVolume', ~masterVolume);

~receivingAddr.sendMsg('mix/volume/1', ~kickVolume);
~receivingAddr.sendMsg('kick/pan', ~kickPan);
~receivingAddr.sendMsg('kick/delay', ~kickDelaySend);
~receivingAddr.sendMsg('kick/reverb', ~kickReverbSend);
~receivingAddr.sendMsg('kick/pitch', ~kickPitch);
~receivingAddr.sendMsg('mix/mute/1/1', ~kickMute);

~receivingAddr.sendMsg('mix/volume/2', ~snareVolume);
~receivingAddr.sendMsg('snare/pan', ~snarePan);
~receivingAddr.sendMsg('snare/delay', ~snareDelaySend);
~receivingAddr.sendMsg('snare/reverb', ~snareReverbSend);
~receivingAddr.sendMsg('snare/pitch', ~snarePitch);
~receivingAddr.sendMsg('mix/mute/1/2', ~snareMute);

~receivingAddr.sendMsg('mix/volume/3', ~clapVolume);
~receivingAddr.sendMsg('clap/pan', ~clapPan);
~receivingAddr.sendMsg('clap/delay', ~clapDelaySend);
~receivingAddr.sendMsg('clap/reverb', ~clapReverbSend);
~receivingAddr.sendMsg('clap/pitch', ~clapPitch);
~receivingAddr.sendMsg('mix/mute/1/3', ~clapMute);

~receivingAddr.sendMsg('mix/volume/4', ~closedHatVolume);
~receivingAddr.sendMsg('closedHat/pan', ~closedHatPan);
~receivingAddr.sendMsg('closedHat/delay', ~closedHatDelaySend);
~receivingAddr.sendMsg('closedHat/reverb', ~closedHatReverbSend);
~receivingAddr.sendMsg('closedHat/pitch', ~closedHatPitch);
~receivingAddr.sendMsg('mix/mute/1/4', ~closedHatMute);

~receivingAddr.sendMsg('mix/volume/5', ~openHatVolume);
~receivingAddr.sendMsg('openHat/pan', ~openHatPan);
~receivingAddr.sendMsg('openHat/delay', ~openHatDelaySend);
~receivingAddr.sendMsg('openHat/reverb', ~openHatReverbSend);
~receivingAddr.sendMsg('openHat/pitch', ~openHatPitch);
~receivingAddr.sendMsg('mix/mute/1/5', ~openHatMute);

~receivingAddr.sendMsg('fx/time', ~delayTime);
~receivingAddr.sendMsg('fx/feedback', ~delayFeedback);

~receivingAddr.sendMsg('fx/damp', ~reverbDamp);
~receivingAddr.sendMsg('fx/decay', ~reverbDecay);

~receivingAddr.sendMsg('mix/crush', ~bitCrusherDist);

~receivingAddr.sendMsg('mix/cutoff', 1); // internal mapping


~receivingAddr.sendMsg('/sequencer/grid/5/1', ~kickPattern[0]);
~receivingAddr.sendMsg('/sequencer/grid/5/2', ~kickPattern[1]);
~receivingAddr.sendMsg('/sequencer/grid/5/3', ~kickPattern[2]);
~receivingAddr.sendMsg('/sequencer/grid/5/4', ~kickPattern[3]);
~receivingAddr.sendMsg('/sequencer/grid/5/5', ~kickPattern[4]);
~receivingAddr.sendMsg('/sequencer/grid/5/6', ~kickPattern[5]);
~receivingAddr.sendMsg('/sequencer/grid/5/7', ~kickPattern[6]);
~receivingAddr.sendMsg('/sequencer/grid/5/8', ~kickPattern[7]);

~receivingAddr.sendMsg('/sequencer/grid/4/1', ~snarePattern[0]);
~receivingAddr.sendMsg('/sequencer/grid/4/2', ~snarePattern[1]);
~receivingAddr.sendMsg('/sequencer/grid/4/3', ~snarePattern[2]);
~receivingAddr.sendMsg('/sequencer/grid/4/4', ~snarePattern[3]);
~receivingAddr.sendMsg('/sequencer/grid/4/5', ~snarePattern[4]);
~receivingAddr.sendMsg('/sequencer/grid/4/6', ~snarePattern[5]);
~receivingAddr.sendMsg('/sequencer/grid/4/7', ~snarePattern[6]);
~receivingAddr.sendMsg('/sequencer/grid/4/8', ~snarePattern[7]);

~receivingAddr.sendMsg('/sequencer/grid/3/1', ~clapPattern[0]);
~receivingAddr.sendMsg('/sequencer/grid/3/2', ~clapPattern[1]);
~receivingAddr.sendMsg('/sequencer/grid/3/3', ~clapPattern[2]);
~receivingAddr.sendMsg('/sequencer/grid/3/4', ~clapPattern[3]);
~receivingAddr.sendMsg('/sequencer/grid/3/5', ~clapPattern[4]);
~receivingAddr.sendMsg('/sequencer/grid/3/6', ~clapPattern[5]);
~receivingAddr.sendMsg('/sequencer/grid/3/7', ~clapPattern[6]);
~receivingAddr.sendMsg('/sequencer/grid/3/8', ~clapPattern[7]);

~receivingAddr.sendMsg('/sequencer/grid/2/1', ~closedHatPattern[0]);
~receivingAddr.sendMsg('/sequencer/grid/2/2', ~closedHatPattern[1]);
~receivingAddr.sendMsg('/sequencer/grid/2/3', ~closedHatPattern[2]);
~receivingAddr.sendMsg('/sequencer/grid/2/4', ~closedHatPattern[3]);
~receivingAddr.sendMsg('/sequencer/grid/2/5', ~closedHatPattern[4]);
~receivingAddr.sendMsg('/sequencer/grid/2/6', ~closedHatPattern[5]);
~receivingAddr.sendMsg('/sequencer/grid/2/7', ~closedHatPattern[6]);
~receivingAddr.sendMsg('/sequencer/grid/2/8', ~closedHatPattern[7]);

~receivingAddr.sendMsg('/sequencer/grid/1/1', ~openHatPattern[0]);
~receivingAddr.sendMsg('/sequencer/grid/1/2', ~openHatPattern[1]);
~receivingAddr.sendMsg('/sequencer/grid/1/3', ~openHatPattern[2]);
~receivingAddr.sendMsg('/sequencer/grid/1/4', ~openHatPattern[3]);
~receivingAddr.sendMsg('/sequencer/grid/1/5', ~openHatPattern[4]);
~receivingAddr.sendMsg('/sequencer/grid/1/6', ~openHatPattern[5]);
~receivingAddr.sendMsg('/sequencer/grid/1/7', ~openHatPattern[6]);
~receivingAddr.sendMsg('/sequencer/grid/1/8', ~openHatPattern[7]);

~receivingAddr.sendMsg('/sequencer/play', 0);


)

