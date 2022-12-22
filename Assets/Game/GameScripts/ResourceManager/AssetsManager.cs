//=========================================
//Author: 洪金敏
//Create Date: 2019/01/03 15:46:38
//Description: 
//=========================================

using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using MailingJoy.Core;
using Spine.Unity;
#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;
using UnityEngine.U2D;
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;
using UnityEngine.UI;
using XLua;


namespace MyGame
{
	/// <summary>
	///  资源管理器
	/// </summary>
	[LuaCallCSharp]
	public class AssetsManager : SingletonBase<AssetsManager>
	{
		[Obsolete]
		public void LoadAsset<T>(string address, Action<T> action) where T : UnityEngine.Object
		{
			var go = Resources.Load<T>(address);
			action?.Invoke(go);
		}


		public AsyncOperationHandle<T> GetAsset<T>(string address, Action<T, object[]> completeHandler = null,
			params object[] param)
		{
			var handle = Addressables.LoadAssetAsync<T>(address);
			handle.Completed += handler =>
			{
				if (handler.Status == AsyncOperationStatus.Succeeded)
				{
					completeHandler?.Invoke(handler.Result, param);
				}
			};
			return handle;
		}

		public AsyncOperationHandle GetAsset(string address, Action<object, object[]> completeHandler = null,
			params object[] param)
		{
			return GetAsset<object>(address, completeHandler, param);
		}

		public AsyncOperationHandle<IList<T>> GetAssets<T>(List<string> keys, Action<T> completeHandler = null,
			Action<AsyncOperationHandle<IList<T>>> allCompleteHandler = null)
		{
			var handle =
				Addressables.LoadAssetsAsync<T>(keys, asset => { completeHandler?.Invoke(asset); },
					Addressables.MergeMode.Intersection);
			if (allCompleteHandler != null)
			{
				handle.Completed += allCompleteHandler;
			}

			return handle;
		}

		public AsyncOperationHandle<IList<object>> GetAssets(List<string> keys, Action<object> completeHandler = null,
			Action<AsyncOperationHandle<IList<object>>> allCompleteHandler = null)
		{
			return GetAssets<object>(keys, completeHandler, allCompleteHandler);
		}

		[LuaCallCSharp]
		public AsyncOperationHandle LoadSpriteFromAtlas(string atlas, string spriteId,
			Action<Sprite> completeHandler)
		{	
			var handle = Addressables.LoadAssetAsync<Sprite>($"{atlas}[{spriteId}]");
			handle.Completed += handler =>
			{
				if (handler.Status == AsyncOperationStatus.Succeeded)
				{
					var sprite = handler.Result;
					completeHandler?.Invoke(sprite);
				}
				else
				{
					Debug.LogError(atlas + "    图集中不存在    " + spriteId);
					completeHandler?.Invoke(null);
				}
			};
			return handle;
		}
		
		[LuaCallCSharp]
		public AsyncOperationHandle LoadSprite(string atlas, 
			Action<Sprite> completeHandler)
		{	
			var handle = Addressables.LoadAssetAsync<Sprite>($"{atlas}");
			handle.Completed += handler =>
			{
				if (handler.Status == AsyncOperationStatus.Succeeded)
				{
					var sprite = handler.Result;
					completeHandler?.Invoke(sprite);
				}
				else
				{
					Debug.LogError(atlas + "    图不存在    " + atlas);
					completeHandler?.Invoke(null);
				}
			};
			return handle;
		}
		
		[LuaCallCSharp]
		public AsyncOperationHandle LoadPrefab( string assetName,Transform transform,
			Action<GameObject> completeHandler)
		{
			var handle = Addressables.InstantiateAsync($"{assetName}",transform);
			handle.Completed += handler =>
			{
				if (handler.Status == AsyncOperationStatus.Succeeded)
				{
					var gameObject = handler.Result;
					completeHandler?.Invoke(gameObject);
				}
				else
				{
					Debug.LogError("    资源不存在    " + assetName);
					completeHandler?.Invoke(null);
				}
			};
			return handle;
		}

		//[LuaCallCSharp]
		//public AsyncOperationHandle LoadSpine(int skinId, Transform transform,
		//	Action<GameObject> completeHandler)
		//{
		//	AnimationDataContext.GetSkinById(skinId,out var assetName,out string skeletonSkin,out string prefab);
		//	var handle = SpineManager.Instance.GetSpineDataFromAb(assetName,"", skeletonData =>
		//	{
		//		var skeletonGraphic =
		//			SkeletonGraphic.NewSkeletonGraphicGameObject(skeletonData, transform, null);
		//		skeletonGraphic.transform.localPosition = Vector3.zero;
		//		skeletonGraphic.startingLoop = true;
		//		skeletonGraphic.Initialize(false);
		//		completeHandler?.Invoke(skeletonGraphic.gameObject);
		//	});
		//	return handle;
		//}
		/// <summary>
		/// 获取spine SkeletonDataAsset
		/// </summary>
		/// <param name="skinId"></param>
		/// <param name="transform"></param>
		/// <param name="completeHandler"></param>
		/// <returns></returns>
		//[LuaCallCSharp]
		//public AsyncOperationHandle LoadSpineSkeletonData(int skinId, Transform transform,
		//	Action<SkeletonDataAsset> completeHandler)
		//{
		//	AnimationDataContext.GetSkinById(skinId,out var assetName,out string skeletonSkin,out string prefab);
		//	var handle = SpineManager.Instance.GetSpineDataFromAb(assetName,"", skeletonData =>
		//	{
		//		completeHandler?.Invoke(skeletonData);
		//	});
		//	return handle;
		//}

		[LuaCallCSharp]
		public void Release(AsyncOperationHandle handle)
		{
			Addressables.Release(handle);
		}
	}
}