package com.brightcove.opensource
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	public class ConfigurationMap extends EventDispatcher
	{
		private var _clientID:int;
		private var _c3:String;
		private var _c4:String;
		private var _c6:String;
		
		[Embed(source="../assets/comscore_map.xml", mimeType="application/octet-stream")]
		protected const EventsMap:Class;

		public function ConfigurationMap(xmlFileURL:String = null)
		{
			if(xmlFileURL)
			{
				var request:URLRequest = new URLRequest(xmlFileURL);
				var loader:URLLoader = new URLLoader();
				loader.addEventListener(Event.COMPLETE, onXMLFileLoaded);
				loader.load(request);
			}
			else
			{
				var byteArray:ByteArray = (new EventsMap()) as ByteArray;
				var bytes:String = byteArray.readUTFBytes(byteArray.length);
				var mapXML:XML = new XML(bytes);
				mapXML.ignoreWhitespace = true;
				
				parseMap(mapXML);
				
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		private function onXMLFileLoaded(event:Event):void
		{
			var mapXML:XML = new XML(event.target.data);
			mapXML.ignoreWhitespace = true;
			parseMap(mapXML);
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function parseMap(pMap:XML):void
		{
			_clientID = pMap.clientID;
			
			for(var node:String in pMap.cValues)
			{
				var cValue:XML = pMap.cValues[node];
			
				switch(cValue.@number)
				{
					case 3:
						_c3 = cValue.@value;
					case 4:
						_c4 = cValue.@value;
					case 6:
						_c6 = cValue.@value;
				}
			}
		}
		
		public function getCValue(number:int):String
		{
			switch(number)
			{
				case 3:
					return _c3;
				case 4:
					return _c4;
				case 6:
					return _c6;
			}
			
			return null;
		}
		
		public function get clientID():int
		{
			return _clientID;
		}
	}
}