package com.comscore
{
	public class ComScoreEntry
	{
		private var _customFieldName:String;
		private var _name:String
		private var _id:Number;
		
		public function ComScoreEntry(customFieldName:String, name:String, id:Number)
		{
			_customFieldName = customFieldName;
			_name = name;
			_id = id;
		}
		
		public function get customFieldName():String
		{
			return _customFieldName;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function get id():Number
		{
			return _id;
		}
	}
}