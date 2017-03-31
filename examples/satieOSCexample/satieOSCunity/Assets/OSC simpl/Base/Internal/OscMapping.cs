/*
	Created by Carl Emil Carlsen.
	Copyright 2016 Sixth Sensor.
	All rights reserved.
	http://sixthsensor.dk
*/

using UnityEngine;
using UnityEngine.Events;
using System.Collections;
using System.Collections.Generic;
using System;

namespace OscSimpl
{
	[Serializable]
	public class OscMapping : ISerializationCallbackReceiver
	{
		public string address;
		
		public OscMessageType type = OscMessageType.OscMessage;
		
		public OscMessageEvent OscMessageHandler = new OscMessageEvent();
		public OscFloatEvent FloatHandler = new OscFloatEvent();
		public OscDoubleEvent DoubleHandler = new OscDoubleEvent();
		public OscIntEvent IntHandler = new OscIntEvent();
		public OscLongEvent LongHandler = new OscLongEvent();
		public OscStringEvent StringHandler = new OscStringEvent();
		public OscCharEvent CharHandler = new OscCharEvent();
		public OscBoolEvent BoolHandler = new OscBoolEvent();
		public OscColorEvent ColorHandler = new OscColorEvent();
		public OscBlobEvent BlobHandler = new OscBlobEvent();
		public OscTimeTagEvent TimeTagHandler = new OscTimeTagEvent();
		public UnityEvent ImpulseNullEmptyHandler = new UnityEvent();

		#region editor_inspector
		
		// We need this because UnityEvent does not allow us to mess UnityActions that are added at runtime.
		public List<System.Reflection.MethodInfo> runtimeMethodInfo;
		
		public List<string> runtimeMethodLabels;
		public int editorMethodCount = 0;
		public bool foldoutHandlers = false;
		
		#endregion
		
		
		public OscMapping()
		{
			runtimeMethodInfo = new List<System.Reflection.MethodInfo>();
			runtimeMethodLabels = new List<string>();
		}
		
		
		public OscMapping( string address, OscMessageType type ) : this()
		{
			this.address = address;
			this.type = type;
		}


		public void Clear()
		{
			OscMessageHandler.RemoveAllListeners();
			FloatHandler.RemoveAllListeners();
			DoubleHandler.RemoveAllListeners();
			IntHandler.RemoveAllListeners();
			LongHandler.RemoveAllListeners();
			StringHandler.RemoveAllListeners();
			CharHandler.RemoveAllListeners();
			BoolHandler.RemoveAllListeners();
			ColorHandler.RemoveAllListeners();
			BlobHandler.RemoveAllListeners();
			TimeTagHandler.RemoveAllListeners();
			ImpulseNullEmptyHandler.RemoveAllListeners();

			runtimeMethodInfo.Clear();
			runtimeMethodLabels.Clear();
		}
		
		
		public void OnBeforeSerialize()
		{
			
		}
		
		
		public void OnAfterDeserialize()
		{
			if( runtimeMethodInfo == null ) runtimeMethodInfo = new List<System.Reflection.MethodInfo>();
			if( runtimeMethodLabels == null ) runtimeMethodLabels = new List<string>();
			
			switch( type ){
			case OscMessageType.OscMessage: editorMethodCount = OscMessageHandler.GetPersistentEventCount(); break;
			case OscMessageType.Float: editorMethodCount = FloatHandler.GetPersistentEventCount(); break;
			case OscMessageType.Double: editorMethodCount = DoubleHandler.GetPersistentEventCount(); break;
			case OscMessageType.Int: editorMethodCount = IntHandler.GetPersistentEventCount(); break;
			case OscMessageType.Long: editorMethodCount = LongHandler.GetPersistentEventCount(); break;
			case OscMessageType.String: editorMethodCount = StringHandler.GetPersistentEventCount(); break;
			case OscMessageType.Char: editorMethodCount = CharHandler.GetPersistentEventCount(); break;
			case OscMessageType.Bool: editorMethodCount = BoolHandler.GetPersistentEventCount(); break;
			case OscMessageType.Color: editorMethodCount = ColorHandler.GetPersistentEventCount(); break;
			case OscMessageType.Blob: editorMethodCount = BlobHandler.GetPersistentEventCount(); break;
			case OscMessageType.TimeTag: editorMethodCount = TimeTagHandler.GetPersistentEventCount(); break;
			case OscMessageType.ImpulseNullEmpty: editorMethodCount = ImpulseNullEmptyHandler.GetPersistentEventCount(); break;
			}
		}
	}
}