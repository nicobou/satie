/*
	Created by Carl Emil Carlsen.
	Copyright 2016 Sixth Sensor.
	All rights reserved.
	http://sixthsensor.dk
*/

using UnityEditor;
using UnityEngine;

namespace OscSimpl
{
	[CustomPropertyDrawer( typeof( OscMapping ) )]
	public class OscMappingDrawer : PropertyDrawer
	{
		public const int removeButtonWidth = 25;
		public const int fieldHeight = 16;
		public const int drawerPaddingTop = 3;
		public const int fieldPaddingHorisontal = 2;
		public const int bottomMargin = 0;
		const int typeEnumWidth = 110;
		const int fieldPaddingVertical = 1;
		
		
		public override float GetPropertyHeight( SerializedProperty property, GUIContent label )
		{
			SerializedProperty type = property.FindPropertyRelative( "type" );
			SerializedProperty foldoutHandlers = property.FindPropertyRelative( "foldoutHandlers" );

			// Address, type, remove line
			float height = drawerPaddingTop + fieldHeight + fieldPaddingVertical;

			// Handlers foldout
			height += drawerPaddingTop + fieldHeight + fieldPaddingVertical;
			if( foldoutHandlers.boolValue )
			{
				// Runtime
				SerializedProperty runtimeHandlernames = property.FindPropertyRelative( "runtimeMethodLabels" );
				height += ( fieldHeight + fieldPaddingVertical ) * runtimeHandlernames.arraySize;
				// Editor
				SerializedProperty handler = GetHandler( property, type.enumValueIndex );
				height += EditorGUI.GetPropertyHeight( handler );
			}
			
			return height + bottomMargin;
		}
		
		
		public override void OnGUI( Rect rect, SerializedProperty property, GUIContent label )
		{
			// Using BeginProperty / EndProperty on the parent property means that
			// prefab override logic works on the entire property.
			EditorGUI.BeginProperty( rect, label, property );
			
			// Get properties
			SerializedProperty type = property.FindPropertyRelative( "type" );
			SerializedProperty address = property.FindPropertyRelative( "address" );
			SerializedProperty handler = GetHandler( property, type.enumValueIndex );
			SerializedProperty runtimeMethodLabels = property.FindPropertyRelative( "runtimeMethodLabels" );
			SerializedProperty editorMethodCount = property.FindPropertyRelative( "editorMethodCount" );
			SerializedProperty foldoutHandlers = property.FindPropertyRelative( "foldoutHandlers" );
			
			rect.y += drawerPaddingTop;
			
			// Store positioning
			float beginX = rect.x;
			float fullWidth = rect.width;
			float indent = rect.x - EditorGUI.IndentedRect( rect ).x;
			
			// Address field
			rect.xMin += 4;
			rect.height = fieldHeight;
			rect.width -= typeEnumWidth + fieldPaddingHorisontal + removeButtonWidth + fieldPaddingHorisontal;
			EditorGUI.BeginChangeCheck();
			string newString = EditorGUI.TextField( rect, address.stringValue );
			if( EditorGUI.EndChangeCheck() ){
				address.stringValue = newString;
			}
			
			// OSC Message type popup
			rect.x += rect.width + fieldPaddingHorisontal + indent; 
			rect.width = typeEnumWidth - indent - fieldPaddingHorisontal;
			EditorGUI.BeginChangeCheck();
			int newEnumIndex = (int) (OscMessageType) EditorGUI.EnumPopup( rect, (OscMessageType) type.enumValueIndex );
			if( EditorGUI.EndChangeCheck() ){
				type.enumValueIndex = newEnumIndex;
			}
			
			// Next line
			rect.y += fieldHeight + fieldPaddingVertical;
			
			rect.x = beginX;
			rect.width = fullWidth;
			rect = EditorGUI.IndentedRect( rect );
			
			// Handlers foldout
			int handlerCount = runtimeMethodLabels.arraySize + editorMethodCount.intValue;
			foldoutHandlers.boolValue = EditorGUI.Foldout( rect, foldoutHandlers.boolValue, "Handlers (" + handlerCount  + ")" );
			rect.y += fieldHeight + fieldPaddingVertical;
			if( foldoutHandlers.boolValue )
			{
				// Runtime
				for( int n=0; n<runtimeMethodLabels.arraySize; n++ )
				{
					SerializedProperty methodName = runtimeMethodLabels.GetArrayElementAtIndex( n );
					EditorGUI.LabelField( rect, methodName.stringValue + " (Runtime)");
					rect.y += fieldHeight + fieldPaddingVertical;
				}
				// Editor
				rect.xMin += 16; // Cosmetics
				rect.xMax -= 1;
				EditorGUI.PropertyField( rect, handler );
				rect.y += EditorGUI.GetPropertyHeight( handler );
			}
			
			EditorGUI.EndProperty ();
		}
		
		
		SerializedProperty GetHandler( SerializedProperty property, int typeIndex )
		{
			switch( typeIndex ){
			case 0: return property.FindPropertyRelative( OscMessageType.OscMessage + "Handler" );
			case 1: return property.FindPropertyRelative( OscMessageType.Float + "Handler" );
			case 2: return property.FindPropertyRelative( OscMessageType.Double + "Handler" );
			case 3: return property.FindPropertyRelative( OscMessageType.Int + "Handler" );
			case 4: return property.FindPropertyRelative( OscMessageType.Long + "Handler" );
			case 5: return property.FindPropertyRelative( OscMessageType.String + "Handler" );
			case 6: return property.FindPropertyRelative( OscMessageType.Char + "Handler" );
			case 7: return property.FindPropertyRelative( OscMessageType.Bool + "Handler" );
			case 8: return property.FindPropertyRelative( OscMessageType.Color + "Handler" );
			case 9: return property.FindPropertyRelative( OscMessageType.Blob + "Handler" );
			case 10: return property.FindPropertyRelative( OscMessageType.TimeTag + "Handler" );
			case 11: return property.FindPropertyRelative( OscMessageType.ImpulseNullEmpty + "Handler" );
			}
			return null;
		}
	}
}