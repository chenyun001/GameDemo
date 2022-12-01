using UnityEngine;
using System.Collections;
using UnityEditor;
using UnityEditorInternal;
using System;
using MyGame;
using UnityEngine.UI;

[CustomEditor(typeof(TestList))]
public class TestListEditor : Editor
{
    private ReorderableList m_colors;

    private void OnEnable()
    {
        m_colors = new ReorderableList(serializedObject, serializedObject.FindProperty("bindVariables"), true, true, true, true);
        //绘制元素
        m_colors.drawElementCallback = (Rect rect, int index, bool selected, bool focused) =>
        {
            //serializedproperty itemdata = m_colors.serializedproperty.getarrayelementatindex(index);
            //rect.y += 2;
            //rect.height = editorguiutility.singlelineheight;
            //editorgui.propertyfield(rect, itemdata, guicontent.none);


            Debug.Log("indexindex...................=" + index);
            var element = m_colors.serializedProperty.GetArrayElementAtIndex(index);
            rect.y += 2;
            var half = rect.width / 2;
            var nameProperty = element.FindPropertyRelative("name");
            var valueProperty = element.FindPropertyRelative("value");
            EditorGUI.BeginChangeCheck();
            EditorGUI.PropertyField(new Rect(rect.x, rect.y, half, EditorGUIUtility.singleLineHeight), valueProperty, GUIContent.none);
            if (EditorGUI.EndChangeCheck())
            {
                if (nameProperty.stringValue == "")
                {

                    nameProperty.stringValue = GenVariableName(valueProperty.objectReferenceValue);
                }
            }
            EditorGUI.PropertyField(new Rect(rect.x + half, rect.y, half, EditorGUIUtility.singleLineHeight), nameProperty, GUIContent.none);


        };
        //绘制表头
        m_colors.drawHeaderCallback = (Rect rect) =>
        {
            GUI.Label(rect, "Colors");
        };
        //当移除元素时回调
        m_colors.onRemoveCallback = (ReorderableList list) =>
        {
            //弹出一个对话框
            if (EditorUtility.DisplayDialog("警告", "是否确定删除该颜色", "是", "否"))
            {
                //当点击“是”
                ReorderableList.defaultBehaviours.DoRemoveButton(list);
            }
        };
        //添加按钮回调
        m_colors.onAddCallback = (ReorderableList list) =>
        {
            if (list.serializedProperty != null)
            {
                list.serializedProperty.arraySize++;
                list.index = list.serializedProperty.arraySize - 1;
                SerializedProperty itemData = list.serializedProperty.GetArrayElementAtIndex(list.index);
                itemData.colorValue = Color.red;
            }
            else
            {
                ReorderableList.defaultBehaviours.DoAddButton(list);
            }
        };
        //鼠标抬起回调
        m_colors.onMouseUpCallback = (ReorderableList list) =>
        {
            Debug.Log("MouseUP");
        };
        //当选择元素回调
        m_colors.onSelectCallback = (ReorderableList list) =>
        {
            //打印选中元素的索引
            Debug.Log(list.index);
        };
    }

    public override void OnInspectorGUI()
    {
        EditorGUILayout.Space();
        serializedObject.Update();
        m_colors.DoLayoutList();
        serializedObject.ApplyModifiedProperties();
    }

    //获取名字
    protected virtual string GenVariableName(UnityEngine.Object obj)
    {
        if (obj == null) return "";
        string suffix = "";
        if (obj is Button)
            suffix = "btn_";
        else if (obj is Slider)
            suffix = "slider_";
        else if (obj is Toggle)
            suffix = "toggle_";
        else if (obj is Text)
            suffix = "txt_";
        else if (obj is Image)
            suffix = "image_";
        else if (obj is InputField)
            suffix = "inputfield_";
        else if (obj is Scrollbar)
            suffix = "scrollbar";
        string name = suffix + obj.name;
        name = name.Replace(" ", "");
        name = name.Replace("(", "");
        name = name.Replace(")", "");
        return name;
    }
}