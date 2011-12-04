package com.comscore
{
	import com.brightcove.IDMapping;
	import com.brightcove.api.dtos.VideoDTO;
	import com.brightcove.api.modules.ExperienceModule;
	import com.brightcove.opensource.ConfigurationMap;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class ComScore
	{	
		public var adBeacon:Boolean = false;
		
		private var _map:ConfigurationMap;
		private var _experienceModule:ExperienceModule;
		
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
				"cv=2.0",
				"C3=" + _map.getCValue(3),
				"C4=" + _map.getCValue(4),
				"C6=" + _map.getCValue(6)
			);
			
			params.push("rn=" + new Date().time);
			
			return rootURL + params.join('&');
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
			CustomLogger.instance.debug("Beacon Sent");
		}
	}
}