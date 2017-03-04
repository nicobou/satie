using UnityEngine;
using System.Text;
using System.IO; 
using System.Collections;
using System.Collections.Generic;

public class NoteEvent {
    public int time;
    public int channel;
    public int pitch;
    public int vel;
    // custom fields
    public int track;
    public float elevationOffset;
    public bool elevationInvert;
    public float headingOffset;
    public bool headingInvert;
    public Color color;
    public int presetNo;
}


public class PitchEvent {
    public int time;
    //public int channel;
    public int pitch;
    //public int vel;

 }

public class PitchEventList {
    public string name = "";
    public List <PitchEvent> plist = new List<PitchEvent>();
    
}

public class btinfo {
    public float force;
    public int trainLength;
    public string pitchFile;
}

public class  zkMidifileReader : MonoBehaviour {
    
    
    public bool keysEnabled = false;
    public string filename = "";

    public btinfo balltrainInfo = new btinfo();

    public float pitchSequenceIncrement = 1;


    [HideInInspector]
    public List<NoteEvent> events = new List<NoteEvent>();
  
 
    public List <string> MidiPitchFiles = new List<string>();


    public List <PitchEventList> MidiPitchSequences = new List<PitchEventList>();
    


    //private poseCapture poseCaptureCS;

    private PitchEventList currentPitchSequence;
    private int currentPitchSequenceLen = 0;
    private float currentPitchSequenceIndex = 0;
    private float currentBassRegister = 48;    // this holds the most recent low (< 60) pitch, transposed -12, of the playing sequence

    private static  zkMidifileReader _instance = null;
    
    
    public static zkMidifileReader Instance { get { return _instance; } }
    

    void Awake()
    {
        if (_instance != null) 
    {
            Debug.LogWarning("zkMidifileReader.Awake: multiple instances of zkMidifileReader not allowed, duplicate instance found in:" + transform.name);
        return;
    }
    // else
        _instance = this;    // force singleton
    }


    // Use this for initialization
    void Start () {
        // Load();
        loadMidiCVSfiles();
    }
    
    
    void Update () 
    {
        if (keysEnabled)
        {
            if (Input.GetKeyDown("d"))
            {
                //Debug.Log("event count:" + events.Count);
                foreach (NoteEvent e in events)
                    Debug.Log("zkMidifileReader: adding noteEvent:  time:" + e.time + "  channel:" + e.channel + "   pitch:" + e.pitch + 
                              "   vel:" + e.vel + "   track:" + e.track + "   elevationInvert:" + e.elevationInvert + 
                              "   headingInvert:" + e.headingInvert + "   elevationOffset:" + e.elevationOffset + 
                              "   headingOffset:" + e.headingOffset + "  presetNo =" + e.presetNo + "   color:" + e.color );

                Debug.Log("\t\t\tzkMidifileReader: force:" +  balltrainInfo.force + "  trainLength=" + balltrainInfo.trainLength + "   pitchFile:" + balltrainInfo.pitchFile);
            }
            if (Input.GetKeyDown("n"))
            {
                getNextMidiPitch(false);
            }
            if (Input.GetKeyDown("l"))
            {
                setMidiPitchSequence("camel");
                //loadMidiCVSfiles();
               // LoadPitchSequence("prelude1.mid.txt");
            }
        }

    }

    // OSC SINGLE SLIDER ITEM   
    // float_arg0:  value 
    public void setPitchSeqIncrement( ArrayList args )   // expecting (float)index    (float)state <optional>
    {
        if (args.Count !=1)
        {
            Debug.LogError("zkMidifileReader.setPitchSeqIncrement: bad arg. count");
            return;
        }
        float value = (float)args [0];
        setPitchSeqIncrement(value);
    }
    
    public void setPitchSeqIncrement ( float value )
    {
        if (value < 0)
            value = 0;
        pitchSequenceIncrement = value;
    }


    public bool loadMidiFile (string fname)
    {
        bool result;
        filename = fname;
        return Load();
    }


    bool loadMidiCVSfiles()
    {
        int i = 0;
 
        string streamingAssetPath = Application.streamingAssetsPath + "/midi/pitchSequences";

        MidiPitchFiles.Clear();
        clearMidiPitches();


        DirectoryInfo dir = new DirectoryInfo(streamingAssetPath);
        FileInfo[] info = dir.GetFiles("*.mid.txt");

        string seqName;

        foreach (FileInfo f in info) 
        {

            if (LoadPitchSequence(f.Name))
            {
                MidiPitchFiles.Add(f.Name);
                setMidiPitchSequence(f.Name);
            }
           // Debug.Log("midiCVSfile: " + f.Name);  
        }

        if (  MidiPitchSequences.Count < 1 )
        {
            Debug.LogWarning("zkMidifileReader.loadMidiCVSfiles:  failed to locate midiCVS files:  *.mid.txt in :" + streamingAssetPath);
            return false;
        }
        // else 
        Debug.Log("zkMidifileReader.loadMidiCVSfiles:  " + MidiPitchSequences.Count + " files loaded");
        return true;
    }


    // returns -1 if not found
    public bool setMidiPitchSequence(string fname)
    {
        int i = 0;
        foreach (PitchEventList p in MidiPitchSequences)
        {
            if (p.name.Contains(fname))
            {
                // Debug.Log("zkMidifileReader.setMidiPitchSequence: found file: " + p.name + " at index: " + i);

                currentPitchSequence = p;
                currentPitchSequenceLen = currentPitchSequence.plist.Count;
                currentPitchSequenceIndex = 0;
                
                Debug.Log("zkMidifileReader.setMidiPitchSequence:  setting pitch sequence from file: " + currentPitchSequence.name + "  NOTE COUNT: " + currentPitchSequenceLen );


                return (true);
            }
            else i++;
        }
        // else 
        Debug.LogWarning("zkMidifileReader.setMidiPitchSequence: name: " + fname + " not matched");

        return false;
    }


//    public void setMidiPitchSequence( int index)
//    {
//        int sequencCount = MidiPitchSequences.Count; 
//        if (sequencCount < 1)
//        {
//            currentPitchSequenceLen = 0;
//            return;
//        }
//        if ( index < 0  || index > sequencCount - 1 ) 
//        {
//            Debug.LogWarning("zkMidifileReader.setMidiPitchSequence: index out of range");
//            index = 0;
//        }
//        // else 
//
//        currentPitchSequence = MidiPitchSequences[index];
//        currentPitchSequenceLen = currentPitchSequence.plist.Count;
//        currentPitchSequenceIndex = 0;
//    
//        Debug.Log("zkMidifileReader.setMidiPitchSequence:  setting pitches from file: " + currentPitchSequence.name + "  NOTE COUNT: " + currentPitchSequenceLen );
//    
//    }


    public float getNextMidiPitch(bool bassRegisterFlag)
    {
        if (currentPitchSequenceLen > 0)
        {
            int index = (int)(currentPitchSequenceIndex + .5);
            float pitch = currentPitchSequence.plist[index].pitch; 

            //Debug.Log("zkMidifileReader.getNextMidiPitch pitch: " + currentPitchSequence.plist[currentPitchSequenceIndex].pitch + " baseReg= " + bassRegisterFlag );
            currentPitchSequenceIndex = ( currentPitchSequenceIndex + pitchSequenceIncrement) % (currentPitchSequenceLen-1);
            if (pitch < 62) 
                currentBassRegister = pitch - 12;
            if (bassRegisterFlag) 
                return currentBassRegister;
            else
                return pitch;
        }
        else return (24);   // have to return something... make it noticible 
    }





    void clearMidiPitches()
    {
        foreach (PitchEventList pl in MidiPitchSequences) 
        {
            pl.plist.Clear();
            pl.name="";
        }
        MidiPitchSequences.Clear();
        currentPitchSequenceLen = 0;
    }


    // read in a midi csv file;  of the format:
    //  1, 1000, Note_on_c, 0, 69, 71    
    private bool LoadPitchSequence(string midiCVSfname)
    {

        PitchEventList pitchList = new PitchEventList();
        List<PitchEvent> pitches = new List<PitchEvent>();

        string streamingAssetPath = Application.streamingAssetsPath + "/midi/pitchSequences";
        
        var filePath = System.IO.Path.Combine(streamingAssetPath, midiCVSfname);
        
        if (filePath.Equals(""))
        {
            Debug.LogError("zkMidifileReader.LoadPitchSequence: file not found");
            return (false);
        }
        
       //  Debug.Log("zkMidifileReader.LoadPitchSequence:  reading: " + filePath);
        
        
        //        foreach (NoteEvent e in events)
        //        {
        //            Destroy(e);
        //        }
        //pitches.Clear();
        
        // Handle any problems that might arise when reading the text

 
        try
        {
            string line;
            int currentTrack = -1;
     
            // Create a new StreamReader, tell it which file to read and what encoding the file
            // was saved as
            StreamReader theReader = new StreamReader(filePath, Encoding.Default);
            
            // Immediately clean up the reader after this block of code is done.
            // You generally use the "using" statement for potentially memory-intensive objects
            // instead of relying on garbage collection.
            // (Do not confuse this with the using directive for namespace at the 
            // beginning of a class!)
            using (theReader)
            {
                // While there's lines left in the text file, do this:
                do
                {
                    line = theReader.ReadLine();
                    
                    if (line != null)
                    {
                        // Do whatever you need to do with the text line, it's a string now
                        // In this example, I split it into arguments based on comma
                        // deliniators, then send that array to DoStuff()
                        string[] entries = line.Split(',');
                        //Debug.Log("zkMidifileReader.Load: line = " + line); 
                        
                        if (!int.TryParse(entries [0], out currentTrack))
                            continue;
                        
                        if ( true ) //   no need to ignore lower tracks..   currentTrack > (int) 1) // ignore header 0, and conductor track 1
                        {
                            
                            
                            if (entries.Length > 2)
                            {
                                if ( entries[2].Contains("Note_off_c") )
                                {
                                    continue;
                                }
                                else if ( entries[2].Contains("Note_on_c"))
                                {
                                    int time ;
                                    int pitch ;
                                    int channel ;
                                    int vel ;
                                    
                                    if (!int.TryParse(entries [1], out time))
                                        continue;
                                    if (!int.TryParse(entries [3], out channel))
                                        continue;
                                    if (!int.TryParse(entries [4], out pitch))
                                        continue;
                                    if (!int.TryParse(entries [5], out vel))
                                        continue;

                                    //if (channel == 10) Debug.Log("CHANNEL 10 FOUND in; "+midiCVSfname);

                                    PitchEvent p = new PitchEvent();
                                    p.time = time;
                                    //p.channel = channel;
                                    p.pitch = pitch;
                                    //p.vel = vel;

                                    //Debug.Log("zkMidifileReader.Load: adding : track " + currentTrack + " elevation " + currentElevationOffset + " heading " + currentHeadingOffset);
                                    pitches.Add(p);
                                }
                            }
                        }
                    }
                } while (line != null);
                
                // Done reading, close the reader and return true to broadcast success    
                theReader.Close();
                pitches.Sort((ps1, ps2) => ps1.time.CompareTo(ps2.time));   // sort pitches in order

                pitchList.name = midiCVSfname;
               
                foreach (PitchEvent p in pitches)
                {
                    pitchList.plist.Add( p );
                    //Debug.Log("pitch: " +  p.pitch);
                }
                // Debug.Log("MidiPitches[" + MidiPitchSequences.Count + "] adding  SEQUENCE: " +  pitchList.name + "  with itemCount =  " + pitchList.plist.Count); 
                MidiPitchSequences.Add( pitchList);

                return true;
            }
         }
        // If anything broke in the try block, we throw an exception with information
        // on what didn't work
        catch (System.Exception  e)
        {
            Debug.LogException( e);
            return false;
        }
        
    }




    // USED FOR META-LEVEL EVENT GENERATION
    // read in a midi csv file;  of the format:
    //  1, 1000, Note_on_c, 0, 69, 71    
    private bool Load()
    {
        string streamingAssetPath = Application.streamingAssetsPath + "/midi/controlSequences";
        
        var filePath = System.IO.Path.Combine(streamingAssetPath, filename);
        
        if (filePath.Equals(""))
        {
            Debug.LogError("zkMidifileReader.Load: file not found");
            return (false);
        }
        
        //Debug.Log("zkMidifileReader.start:  file found: " + filePath);
        
        
        //        foreach (NoteEvent e in events)
        //        {
        //            Destroy(e);
        //        }
        events.Clear();
        
        // Handle any problems that might arise when reading the text
        try
        {
            float force = 6.2f;
            int trainLen = 24;
            string pitchFile;
            int currentTrack = -1;
            bool currentElevationInvert = false;
            bool currentHeadingInvert = false;
            float currentElevationOffset = 0f;
            float currentHeadingOffset = 0f;
           int currentPreset = 1;
            Color currentColor = Color.white;
            string color="";


            // generate fikename using the sequence name, minus the ".mid" part
            string tmpStr = filename.Remove(filename.Length-8);  // take offf   ".mid.txt"

         
            pitchFile = tmpStr + ".pitch.txt"; 
            //Debug.Log("************pitchFile= " + pitchFile);


            string line;
            // Create a new StreamReader, tell it which file to read and what encoding the file
            // was saved as
            StreamReader theReader = new StreamReader(filePath, Encoding.Default);
            
            // Immediately clean up the reader after this block of code is done.
            // You generally use the "using" statement for potentially memory-intensive objects
            // instead of relying on garbage collection.
            // (Do not confuse this with the using directive for namespace at the 
            // beginning of a class!)
            using (theReader)
            {
                // While there's lines left in the text file, do this:
                do
                {
                    line = theReader.ReadLine();
                    
                    if (line != null)
                    {
                        // Do whatever you need to do with the text line, it's a string now
                        // In this example, I split it into arguments based on comma
                        // deliniators, then send that array to DoStuff()
                        string[] entries = line.Split(',');
                        //Debug.Log("zkMidifileReader.Load: line = " + line); 
                        
                        if (!int.TryParse(entries [0], out currentTrack))
                            continue;
                        
                        if (currentTrack > (int) 1) // ignore header 0, and conductor track 1
                        {
                            
                            
                            if (entries.Length > 2)
                            {
                                if ( entries[2].Contains("Note_off_c") )
                                {
                                    continue;
                                }
                                else if ( entries[2].Contains("Text_t")) // look for track meta info and set up "current" state
                                {
                                    string valueString = entries[3].Substring(2, entries[3].Length - 3);  // remove quote padding
                                    
                                    string[] words = valueString.Split(' ');
                                    int intval;
                                    float floatval;


                                    if (valueString.Contains("color"))
                                    {

                                        //Debug.Log("zkMidifileReader.Load: parsed color =  " + valueString + "  words.Lngth = :" + words.Length);

                                        if (words.Length < 2)   // no color item here, ignore
                                        {
                                            Debug.LogWarning("zkMidifileReader.Load:  bad value in text item:" + valueString);
                                            continue;
                                        }

                                        color = words[1];  // for some reason it puts the second word in a third string...

                                        if (color.Contains("red")) currentColor = Color.red;
                                        else if (color.Contains("green")) currentColor = Color.green;
                                        else if (color.Contains("blue")) currentColor = Color.blue;
                                        else if (color.Contains("white")) currentColor = Color.white;
                                        else if (color.Contains("yellow")) currentColor = Color.yellow;
                                        else 
                                        {
                                            Debug.LogWarning("zkMidifileReader.Load:  color not recognized: " + color);
                                            continue;
                                        }
                                    }
                                    else if (valueString.Contains ("heading") || valueString.Contains ("elevation"))
                                    {

                                        if (words.Length < 2)      // no value here, ignore item  
                                        {
                                            Debug.LogWarning("zkMidifileReader.Load:  bad value in text item:" + valueString);
                                            continue;
                                        }

                                        //Debug.Log("--------------WORDS: " + words[0]);

                                        if (words[0].Contains("headingInvert"))
                                        {
                                            if (!int.TryParse(words [1], out intval))
                                                continue;
                                            currentHeadingInvert = ( intval > 0 ) ? true:false;
                                        }
                                        else if (words[0].Contains("elevationInvert"))
                                        {
                                            if (!int.TryParse(words [1], out intval))
                                                continue;
                                            currentElevationInvert = ( intval > 0 ) ? true:false;
                                        }
                                        else if (words[0].Contains("headingOffset"))
                                        {
                                            if (!float.TryParse(words [1], out floatval))
                                                continue;
                                            currentHeadingOffset = floatval;
                                        }
                                        else if (words[0].Contains("elevationOffset"))
                                        {
                                            if (!float.TryParse(words [1], out floatval))
                                                continue;
                                            currentElevationOffset = floatval;
                                        }
                                        else 
                                            Debug.LogWarning("zkMidifileReader.Load:  unrecognized text item:" + valueString);
                                    }
                                    else if (valueString.Contains ("force"))
                                    {
                                       
                                        if (words.Length < 2 )  
                                        {
                                            Debug.LogWarning("zkMidifileReader.Load:  missing value in text item:" + valueString);
                                            continue;
                                        }
                                        if (float.TryParse(words [1], out floatval))
                                        {
                                              force = floatval;
                                        }
                                        else  Debug.LogWarning("zkMidifileReader.Load:  bad value in text item:" + valueString);
                                        continue;
                                    }
                                    else if (valueString.Contains ("count"))
                                    {
                                       
                                        if (words.Length < 2 )  
                                        {
                                            Debug.LogWarning("zkMidifileReader.Load:  missing value in text item:" + valueString);
                                            continue;
                                        }
                                        if (int.TryParse(words [1], out intval))
                                        {
                                            trainLen = intval;
                                           
                                        }
                                        else  Debug.LogWarning("zkMidifileReader.Load:  bad value in text item:" + valueString);
                                        continue;
                                    }
                                    else if (valueString.Contains ("pitchFile"))   // allow for optional overwrite here
                                    {
                                        
                                        if (words.Length < 2 )  
                                        {
                                            Debug.LogWarning("zkMidifileReader.Load:  missing value in text item:" + valueString);
                                            continue;
                                        }
                                         pitchFile = words [2];
                                        continue;
                                    }

                                }
                                else if ( entries[2].Contains("Program_c")) // look for track meta info and set up "current" state
                                {
                                    if (!int.TryParse(entries [4], out currentPreset))
                                    {
                                        break;
                                        Debug.LogWarning("zkMidifileReader.Load: bad program change event in line:" + line); 
                                    }
                                }
                                else if ( entries[2].Contains("Note_on_c"))
                                {
                                    int time ;
                                    int pitch ;
                                    int channel ;
                                    int vel ;
                                    
                                    if (!int.TryParse(entries [1], out time))
                                        continue;
                                    if (!int.TryParse(entries [3], out channel))
                                        continue;
                                    if (!int.TryParse(entries [4], out pitch))
                                        continue;
                                    if (!int.TryParse(entries [5], out vel))
                                        continue;
                                    
                                    NoteEvent e = new NoteEvent();
                                    e.time = time;
                                    e.channel = channel;
                                    e.pitch = pitch;
                                    e.vel = vel;
                                    
                                    e.track = currentTrack;
                                    e.elevationInvert =  (currentElevationInvert) ? true:false;
                                    e.headingInvert = (currentHeadingInvert) ? true:false;
                                    e.headingOffset = currentHeadingOffset;
                                    e.elevationOffset = currentElevationOffset;
                                    e.color = currentColor;
                                    e.presetNo = currentPreset;

                                    //Debug.Log("zkMidifileReader.Load: adding : track " + currentTrack + " elevation " + currentElevationOffset + " heading " + currentHeadingOffset);
                                    events.Add(e);
                                }
                            }
                        }
                    }
                } while (line != null);
                
                // Done reading, close the reader and return true to broadcast success    
                theReader.Close();
                balltrainInfo.force = force;
                balltrainInfo.trainLength = trainLen;
                balltrainInfo.pitchFile = pitchFile;
                events.Sort((ps1, ps2) => ps1.time.CompareTo(ps2.time));  // reorder sequence by times
                return true;
            }
            
            
        }
        // If anything broke in the try block, we throw an exception with information
        // on what didn't work
        catch (System.Exception  e)
        {
            Debug.LogException( e);
            return false;
        }
        
    }
    
    //  entries:   1, 1000, Note_on_c, 0, 69, 71   
    void getNoteOn( string[] entries)
    {
        int time ;
        int pitch ;
        int channel ;
        int vel ;
        
        if (!int.TryParse(entries [1], out time))
            return;
        if (!int.TryParse(entries [3], out channel))
            return;
        if (!int.TryParse(entries [4], out pitch))
            return;
        if (!int.TryParse(entries [5], out vel))
            return;
        
        NoteEvent e = new NoteEvent();
        e.time = time;
        e.channel = channel;
        e.pitch = pitch;
        e.vel = vel;
        
        events.Add(e);
        
        //Debug.Log("getNoteOn: adding noteEvent:  time:" + e.time + "  channel:" + e.channel + "   pitch:" + e.pitch + "   vel:" + e.vel);
        
    }
}

