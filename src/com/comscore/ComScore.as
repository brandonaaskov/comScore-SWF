package com.comscore
{
	import com.brightcove.api.dtos.VideoDTO;
	import com.brightcove.api.modules.ExperienceModule;
	import com.brightcove.opensource.ConfigurationMap;
	import com.brightcove.opensource.DataBinder;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class ComScore
	{	
		private var _map:ConfigurationMap;
		private var _binder:DataBinder = new DataBinder();
		private var _experienceModule:ExperienceModule;
		
		private var _currentVideo:VideoDTO;
		private var _videoSegments:Array = new Array();
		private var _currentSegment:uint;
		
		private var _isPreRollAd:Boolean = false;
		private var _isMidRollAd:Boolean = false;
		private var _isPostRollAd:Boolean = false;
		
		public function ComScore(map:ConfigurationMap, experienceModule:ExperienceModule)
		{
			_map = map;
			_experienceModule = experienceModule;
		}
		
		public function sendBeacon():void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			loader.addEventListener(Event.COMPLETE, onComplete);
			
			loader.load(new URLRequest(getComScoreURL()));
		}
		
		private function getComScoreURL():String
		{	
			var rootURL:String = "http://b.scorecardresearch.com/p?";
			
			var params:Array = new Array(
				'cv=2.0',
				'C1=1',
				'C2=' + _map.clientID,
				'C3=' + encodeURIComponent(_binder.getValue(_map.getCValue(3), _experienceModule, _currentVideo)),
				'C4=' + encodeURIComponent(_binder.getValue(_map.getCValue(4), _experienceModule, _currentVideo)),
				'C5=' + getContentTypeValue(),
				'C6=' + encodeURIComponent(_binder.getValue(_map.getCValue(6), _experienceModule, _currentVideo)),
				'C7=' + encodeURIComponent(_experienceModule.getExperienceURL()),
				'C8=' + encodeURIComponent(_currentVideo.displayName),
				'C9=' + encodeURIComponent(_experienceModule.getReferrerURL()),
				'C10=' + getSegmentsValue(),
				'rn=' + new Date().time
			);
			
			return rootURL + params.join('&');
		}
		
		private function getContentTypeValue():String //for the C5 value
		{
			if(_isPreRollAd)
			{
				return '09';
			}
			else if(_isMidRollAd)
			{
				return '11';
			}
			else if(_isPostRollAd)
			{
				return '10';
			}
			
			//not an ad
			if(_videoSegments.length > 0)
			{
				return '03';
			}
			else
			{
				return '02';
			}
		}
		
		private function getSegmentsValue():String
		{
			return _currentSegment + '-' + _videoSegments.length;
		}
		
		private function onIOError(pEvent:IOErrorEvent):void
		{
			CustomLogger.instance.debug("Beacon Call Failed (IO Error): "+pEvent.text);
		}
		
		private function onSecurityError(pEvent:SecurityErrorEvent):void
		{
			CustomLogger.instance.debug("Beacon Call Failed (Security Error): "+pEvent.text);
		}
		
		private function onComplete(pEvent:Event):void
		{
			CustomLogger.instance.debug("Beacon Sent Successfully");
		}
		
		public function set videoSegments(pSegments:Array):void
		{
			_videoSegments = pSegments;
		}
		
		public function get videoSegments():Array
		{
			return _videoSegments;
		}
		
		public function set currentVideo(pVideo:VideoDTO):void
		{
			_currentVideo = pVideo;
		}
		
		public function set currentSegment(pSegmentNumber:uint):void
		{
			_currentSegment = pSegmentNumber;
		}
		
		public function set isPreRollAd(pToggle:Boolean):void
		{
			_isPreRollAd = pToggle;
			_isMidRollAd = false;
			_isPostRollAd = false;
		}
		
		public function set isMidRollAd(pToggle:Boolean):void
		{
			_isPreRollAd = false;
			_isMidRollAd = pToggle;
			_isPostRollAd = false;
		}
		
		public function set isPostRollAd(pToggle:Boolean):void
		{
			_isPreRollAd = false;
			_isMidRollAd = false;
			_isPostRollAd = pToggle;
		}
	}
}