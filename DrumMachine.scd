s.boot;
s.meter;
s.plotTree;
s.reboot;
s.quit;


// ================ Parameters  ================ //
(
// global
~bpm = 120;
~tempo = TempoClock(~bpm/120);
~sendingPortNumber = 9067;
~sendingAddress = NetAddr.new("127.0.0.1", ~sendingPortNumber);
~masterVolume = 1; // todo: setter

// kick
~kickVolume = 1;
~kickPan = 0.5;
~kickDelaySend = 0;
~kickReverbSend = 0;
~kickPitch = 60;

// snare
~snareVolume = 1;
~snarePan = 0.5;
~snareDelaySend = 0;
~snareReverbSend = 0;
~snarePitch = 200;

// clap
~clapVolume = 1;
~clapPan = 0.5;
~clapDelaySend = 0;
~clapReverbSend = 0;

// closed hat
~closedHatVolume = 1;
~closedHatPan = 0.5;
~closedHatDelaySend = 0;
~closedHatReverbSend = 0;

// open hat
~openHatVolume = 1;
~openHatPan = 0.5;
~openHatDelaySend = 0;
~openHatReverbSend = 0;

// delay
~delayTime = 0.4;
~delayFeedback = 0.2;

// reverb
~reverbTime = 0.8;

// compressor
~compressorMix = 0;
~compressorThreshold = 0;
~compressorAttack = 0.02;
~compressorRelease = 0.2;
~compressorRatio = 2; // 1:2

// patterns
~kickPattern = [0, 0, 0, 0, 0, 0, 0, 0];
~snarePattern = [0, 0, 0, 0, 0, 0, 0, 0];
~clapPattern = [0, 0, 0, 0, 0, 0, 0, 0];
~openHatPattern = [0, 0, 0, 0, 0, 0, 0, 0];
~closedHatPattern = [0, 0, 0, 0, 0, 0, 0, 0];



// ================    OSC     ================ //

// debug
// OSCFunc.trace(true); // Turn posting on
// OSCFunc.trace(false); // Turn posting off
// ~sendingAddress.sendMsg('/test');



// ================    triggers     ================ //



// kick trigger
OSCdef.new(
	\kickTrigger,
	{
		|msg|
		Synth(\kick,
			[\outBus, ~preFx,
				\reverbFxBus, ~reverbAux,
				\delayFxBus, ~delayAux,
				\vol, ~kickVolume,
				\pan, ~kickPan,
				\delaySendAmount, ~kickDelaySend,
				\reverbSendAmount, ~kickReverbSend],
			~drums);
	},
	'/trigger/kick'
);


// snae trigger
OSCdef.new(
	\snareTrigger,
	{
		|msg|
		Synth(\snare,
			[\outBus, ~preFx,
				\reverbFxBus, ~reverbAux,
				\delayFxBus, ~delayAux,
				\vol, ~snareVolume,
				\pan, ~snarePan,
				\delaySendAmount, ~snareDelaySend,
				\reverbSendAmount, ~snareReverbSend],
			~drums);

	},
	'/trigger/snare'
);


// clap trigger
OSCdef.new(
	\clapTrigger,
	{
		|msg|
		Synth(\clap,
			[\outBus, ~preFx,
				\reverbFxBus, ~reverbAux,
				\delayFxBus, ~delayAux,
				\vol, ~clapVolume,
				\pan, ~clapPan,
				\delaySendAmount, ~clapDelaySend,
				\reverbSendAmount, ~clapReverbSend],
			~drums);

	},
	'/trigger/clap'
);

// closedHat trigger
OSCdef.new(
	\closedHatTrigger,
	{
		|msg|
	Synth(\closedhat,
			[\outBus, ~preFx,
				\reverbFxBus, ~reverbAux,
				\delayFxBus, ~delayAux,
				\vol, ~closedHatVolume,
				\pan, ~closedHatPan,
				\delaySendAmount, ~closedHatDelaySend,
				\reverbSendAmount, ~closedHatReverbSend],
			~drums);

	},
	'/trigger/closedHat'
);

// openHat trigger
OSCdef.new(
	\openHatTrigger,
	{
		|msg|
		Synth(\openhat,
			[\outBus, ~preFx,
				\reverbFxBus, ~reverbAux,
				\delayFxBus, ~delayAux,
				\vol, ~openHatVolume,
				\pan, ~openHatPan,
				\delaySendAmount, ~openHatDelaySend,
				\reverbSendAmount, ~openHatReverbSend],
			~drums);

	},
	'/trigger/openHat'
);


// ================    setter     ================ //

// bpm
OSCdef.new(
	\setBpm,
	{
		|msg|
		~bpm = msg[1];
		~tempo = TempoClock(~bpm/120);
	},
	'/bpm'
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

// kick pitch TODO
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

// TODO: EFFECT OSC


// ================    Utilities    ================ //

// converts 0/1 array into a duration representation
~convert2duration = {
	|array|
	var arrayCopy = Array.newFrom(array);
	arrayCopy.do({
		|value, index|
		if(
			value == 0,
			{arrayCopy[index] = Rest(1/4)},
			{arrayCopy[index] = 1/4}
		)
	})
};

// debug
// ~kickPattern;
// ~convert2duration.value(~kickPattern);


// ================     Routing     ================ //

// groups
~drums = Group.new;
~effects = Group.new(~drums, \addAfter);
~master = Group.new(~effects, \addAfter);

// main route
~preFx = Bus.audio(s, 2);
~postFx = Bus.audio(s, 2);


// fx send
~reverbAux = Bus.audio(s, 2);
~delayAux = Bus.audio(s, 2);
~auxBus = Bus.audio(s, 2);

// channel mixer to output
SynthDef(\channelMix, {
	arg masterVol = 1,
	    outBus, chanBus, auxBus;

	var chan1, chan2, aux1, aux2;

	chan1 = In.ar(chanBus, 1);
	chan2 = In.ar(chanBus, 2);
	aux1 = In.ar(auxBus, 1);
	aux2 = In.ar(auxBus, 2);

		//ReplaceOut.ar(
	//	outBus,
//		[Mix.ar([in1[0], in2[0]]), Mix.ar([in1[1], in2[1]]) ] * masterVol)

	Out.ar(
		outBus,
		[Mix.ar([chan1, aux1]), Mix.ar([chan2, aux2])] * masterVol)
}).add;

// link mixer with the buses
~mixer = Synth(\channelMix,
	[\outBus, 0,
	\chanBus, ~postFx,
	\auxBus, ~auxBus,
	\masterVol, ~masterVolume],
	~master,
	\addToTail);



// ================       FX       ================ //

// Reverb
SynthDef(\reverb, {
	arg outBus, inBus,
		decay = 3.0, tail = 0.01, level = 1;
	var signal, fx;

	signal = In.ar(inBus, 1);

	16.do({signal = AllpassC.ar(
		in: signal,
		maxdelaytime: 0.04,
		delaytime: Rand(tail, 0.04),
		decaytime: decay)});

	fx = signal * level;

	Out.ar(outBus, {fx}.dup);
}).add;

~reverb = Synth(\reverb,
	[\inBus, ~reverbAux,
	\outBus, ~auxBus,
		\tail, ~reverbTail,
		\decay, ~reverbDecay,
		\level, ~reverbLevel],
	~effects);

// Delay
SynthDef(\delay, {
	arg inBus, outBus,
		time = 0.5, feed = 1, level = 1;
	var signal, fx;

	signal = In.ar(inBus, 1);

	fx = CombC.ar(
		in: signal,
		maxdelaytime: 5,
		delaytime: time,
		decaytime: feed) * level;

	Out.ar(outBus, {fx}.dup);
}).add;

~delay = Synth(\delay,
	[\inBus, ~delayAux,
	\outBus, ~auxBus,
		\time, ~delayTime,
		\feed, ~delayFeedback,
		\level, ~delayLevel],
	~effects);

// Compressor
SynthDef(\compressor, {
	arg inBus, outBus,
	    threshold = 0.5, ratio = 1, attack = 0.01, release = 0.01, mix = 0.5;
	var signal, fx;

	signal = In.ar(inBus, 1);

	fx = Compander.ar(
		in: signal,
		control: signal,
		thresh: threshold,
		slopeAbove: ratio,
		clampTime: attack,
		relaxTime: release
	);

	Out.ar(outBus, signal * (1-mix));
	Out.ar(outBus, fx * mix);
}).add;

~compressor = Synth(\compressor,
	[\inBus, ~preFx,
	\outBus, ~postFx,
		\threshold, ~compressorThreshold,
		\ratio, ~compressorRatio,
		\attack, ~compressorAttack,
		\release, ~compressorRelease,
		\mix, ~compressorMix],
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
    hatenv = {Line.ar(1, 0, 0.3)};

    snd = (hatosc * hatenv);

	Out.ar(outBus, Pan2.ar(snd, pan, vol));
	Out.ar(reverbFxBus, snd * reverbSendAmount);
	Out.ar(delayFxBus, snd * delaySendAmount);

}).add;


)
