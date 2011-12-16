package com.brightcove.opensource
{
	public class VideoSegment
	{
		private var _startTime:Number;
		private var _endTime:Number;
		private var _keyValuePairs:String;
		
		public var adWatched:Boolean;
		
		public function VideoSegment(startTime:Number, endTime:Number, keyValuePairs:String)
		{
			_startTime = startTime;
			_endTime = endTime;
			_keyValuePairs = keyValuePairs;
		}
		
		public function get startTime():Number
		{
			return _startTime;
		}
		
		public function get endTime():Number
		{
			return _endTime;
		}
		
		public function get keyValues():String
		{
			return _keyValuePairs;
		}
	}
}