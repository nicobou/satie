//c# Example (LookAtPointEditor.cs)
using UnityEngine;
using UnityEditor;
using System.Text;
using System.IO; 
using System.Collections;
using System.Collections.Generic;

[CustomEditor(typeof(aqkSeqSelector))]
[CanEditMultipleObjects]
public class aqkSeqSelectorEditor : Editor 
{
  //  SerializedProperty lookAtPoint;
    SerializedProperty sequenceName;


    private List<string> sequenceNames = new List<string>();
    private string streamingAssetsSubDir =  "midi/pitchSequences";



    public string[] options; // = new string[]; // {"Cube", "Sphere", "Plane"};
    public int index = 0;

    void Start()
    {
        // foreach(string s in  sequenceNames);
    }

    void OnEnable()
    {
       // lookAtPoint = serializedObject.FindProperty("lookAtPoint");
        sequenceName = serializedObject.FindProperty("sequenceName");
 
        int i = 0;

        string streamingAssetPath = Application.streamingAssetsPath + "/" + streamingAssetsSubDir ;

        sequenceNames.Clear();
          

        DirectoryInfo dir = new DirectoryInfo(streamingAssetPath);
        FileInfo[] info = dir.GetFiles("*.mid.txt");

  
        foreach (FileInfo f in info) 
        {
            // Debug.Log("SEQUNAME: " + f.Name);
            sequenceNames.Add(f.Name);
        }
            // Debug.Log("midiCVSfile: " + f.Name);  

        options = new string[sequenceNames.Count];

        foreach (string s in sequenceNames) 
        {
            options[i++] = s;
        }

        if (sequenceNames.Count == 0)
            Debug.LogError("aqkSeqSelectorEditor; no pitch sequence files found in STREAMINGASSETS/midi/pitchSequences");
 
    }
     
    public override void OnInspectorGUI()
    {
        serializedObject.Update();
       // EditorGUILayout.PropertyField(lookAtPoint);
        EditorGUILayout.PropertyField(sequenceName);
        serializedObject.ApplyModifiedProperties();
        // EditorGUILayout.LabelField("note sequences");


//        if (lookAtPoint.vector3Value.y > (target as aquaKhoria).transform.position.y)
//        {
//         }
//        if (lookAtPoint.vector3Value.y < (target as aquaKhoria).transform.position.y)
//        {
//            EditorGUILayout.LabelField("(Below this object)");
//        }
        index = EditorGUILayout.Popup("browse sequences", index, options);
        if (GUILayout.Button("set sequence",  GUILayout.Width(100)))
        {
            (target as aqkSeqSelector).sequenceName = streamingAssetsSubDir+"/"+options[index];

        }
        
    }
}