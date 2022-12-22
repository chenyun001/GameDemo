//=========================================
//Author: 洪金敏
//Email: jonny.hong91@gmail.com
//Create Date: 2020-09-17 14:54:13
//Description: 
//=========================================

using System;

namespace MailingJoy.Core
{
	public class SingletonBase<T>
	{
		private static T _instance;

		public static T Instance
		{
			get
			{
				if (_instance == null)
				{
					_instance = Activator.CreateInstance<T>();
				}

				return _instance;
			}
		}
	}
}