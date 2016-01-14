
	// custom method
	~sheefa.readPitches = {  | self, csvmidifilePath |

		var pitchList = List.new();
		var seqName = csvmidifilePath.split.last;
		var file = File(csvmidifilePath.standardizePath,"rb");


		//postf("file % length:  %\n", ~csvmidifile, g.length);

		file.do({
			var value, event;


			value = file.getLine();
			//value.postln;

			if (value.contains("Note_on_c"),
				{
					//"found Note_on_c".postln;

					event = value.split($,);

					pitchList.add(event[4].asInt);
			});

		});

		file.close;

		if (pitchList.size > 0,
			{

				postf("% pitches read from file %\n", pitchList.size,  ~csvmidifile);

				// add sequence to dictionary
				~sheefa_pitchSequences.removeAt(~seqName.asSymbol);
				~sheefa_pitchSequences.put(~seqName.asSymbol, pitchList);
				~sheefa_pitchSequences[~seqName.asSymbol];

				//(~mpa);

			},//else
			{
				warn("no pitches found in file: "++~csvmidifile);
		});
	};



























~dir = "/Users/zack/Dropbox/Unity3D/projects_unity5/balljamDemoSATIE_2015_unity5/Assets/StreamingAssets/midi/pitchSequences";

// ~dir = thisProcess.nowExecutingPath.dirname;
~myPitchSequences = Dictionary.new();



~csvmidifile = "bjGroove.mid.mid.txt";

//~csvmidifile = "cigars.mid.txt" ;

~seqName = ~csvmidifile;

~csvmidifilePath = ~dir++"/"++~csvmidifile;

~csvmidifilePath.split.last

~mpa = List.new();
g = File(~csvmidifilePath.standardizePath,"rb");
postf("file % length:  %\n", ~csvmidifile, g.length);

g.do({
	var value, event;


    value = g.getLine();
	//value.postln;

	if (value.contains("Note_on_c"),
		{
			//"found Note_on_c".postln;

			event = value.split($,);

			~mpa.add(event[4].asInt);
	});

});

g.close;


if (~mpa.size > 0,
	{

		postf("% pitches read from file %\n", ~mpa.size,  ~csvmidifile);

		// add sequence to dictionary
		~myPitchSequences.removeAt(~seqName.asSymbol);
		~myPitchSequences.put(~seqName.asSymbol, ~mpa);
		~myPitchSequences[~seqName.asSymbol];

		//(~mpa);

},//else
	{
		warn("no pitches found in file: "++~csvmidifile);
		post

});




g.length;
g.position;

g.seek(0);
~pitch=g.getLine();
~pitch.contains("Note_on_c");
~event = ~pitch.split($,);
~event[4]

g.getInt8;

g.inspect;


~pitch.asInt;



