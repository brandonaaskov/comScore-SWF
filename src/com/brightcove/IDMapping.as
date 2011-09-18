package com.brightcove
{
	import com.comscore.ComScoreEntry;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	public class IDMapping extends EventDispatcher
	{
		private var _comScoreXML:XML;
		private var _publisherID:String;
		private var _shows:Array = new Array();
		private var _genres:Array = new Array();
		private var _contentProducers:Array = new Array();
		private var _locations:Array = new Array();
		private var _genresCustomFieldName:String;
		private var _locationsCustomFieldName:String;
		private var _contentProducersCustomFieldName:String;
		private var _showsCustomFieldName:String;
		
		public var mappingComplete:Boolean = false;
		
		[Embed(source="../assets/comscore_map.xml", mimeType="application/octet-stream")]
		private var ComScoreMapXML:Class;
		
		public function IDMapping(pFileName:String = null)
		{
			if(pFileName)
			{
				CustomLogger.instance.debug("File String is: " + pFileName);
				requestXML(pFileName);
			}
			else
			{
				var byteArray:ByteArray = (new ComScoreMapXML()) as ByteArray;
				var bytes:String = byteArray.readUTFBytes(byteArray.length);
				_comScoreXML = new XML(bytes);
				_comScoreXML.ignoreWhitespace = true;
				
				mapXMLFile();
			}
		}
		
		public function getPublisherID():String
		{
			return _publisherID;
		}
		
		public function getShows():Array
		{
			return _shows;
		}
		
		public function getGenres():Array
		{
			return _genres;
		}
		
		public function getContentProducers():Array
		{
			return _contentProducers;
		}
		
		public function getLocations():Array
		{
			return _locations;
		}
		
		private function onResponse(pEvent:Event):void //once XML loads
		{
			_comScoreXML = new XML(pEvent.target.data);
			mapXMLFile();
		}
		
		private function mapXMLFile():void
		{
			_publisherID = _comScoreXML.publisher.@id;
			
			mapSection(_comScoreXML.genres, _genres);
			mapSection(_comScoreXML.contentProducers, _contentProducers);
			mapSection(_comScoreXML.locations, _locations);
			
			if(XMLList(_comScoreXML.shows).length() > 0)
			{
				mapSection(_comScoreXML.shows, _shows);
			}
			
			mappingComplete = true;
			dispatchEvent(new Event(Event.COMPLETE, true));
		}
		
		private function mapSection(pSection:XMLList, pStorageArray:Array):void
		{	
			var customFieldName:String = String(pSection.@customFieldName).toLowerCase();
			CustomLogger.instance.debug("Custom Field Name: " + customFieldName);
			
			switch(String(pSection.localName()).toLowerCase())
			{
				case 'genres':
					_genresCustomFieldName = customFieldName;
					break;
				case 'shows':
					_showsCustomFieldName = customFieldName;
					break;
				case 'contentproducers':
					_contentProducersCustomFieldName = customFieldName;
					break;
				case 'locations':
					_locationsCustomFieldName = customFieldName;
					break;
			}
			
			for(var i:uint = 0; i < pSection.children().length(); i++)
			{
				var childElement:XML = pSection.children()[i];
				
				pStorageArray.push(new ComScoreEntry(
					customFieldName, 
					String(childElement.@name).toLowerCase(), 
					String(childElement.@id)
				));
			}
		}
		
		private function requestXML(pFileURL:String):void
		{	
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onResponse);
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.load(new URLRequest(pFileURL));
		}
		
		public function getCustomFieldName(pComScoreSection:String):String
		{
			switch(pComScoreSection.toLowerCase())
			{
				case 'genres':
					return _genresCustomFieldName;
					break;
				case 'shows':
					return _showsCustomFieldName;
					break;
				case 'contentproducers':
					return _contentProducersCustomFieldName;
					break;
				case 'locations':
					return _locationsCustomFieldName;
					break;
			}
			
			return null;
		}
	}
}