package com.comscore
{
	import com.brightcove.IDMapping;
	import com.brightcove.api.dtos.VideoDTO;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class ComScore
	{
		private var _publisherID:String;
		private var _genreID:String;
		private var _showID:String;
		private var _locationID:String;
		private var _contentProducerID:String;
		private static const _embedID:String = "8000000";
		
		public var adBeacon:Boolean = false;
		
		public function ComScore(pVideo:VideoDTO, pMap:IDMapping, pLocation:String)
		{
			if(pVideo)
			{
				_publisherID = pMap.getPublisherID();
				_locationID = getComScoreID(pMap.getLocations(), getDomainName(pLocation)) || _embedID;
				_showID = getComScoreID(pMap.getShows(), pMap.getCustomFieldName('shows'));
				_genreID = getComScoreID(pMap.getGenres(), pMap.getCustomFieldName('genres'));
				_contentProducerID = getComScoreID(pMap.getContentProducers(), pMap.getCustomFieldName('contentproducers'));
			}
		}
		
		public function sendBeacon():void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			loader.addEventListener(Event.COMPLETE, onComplete);
			
			loader.load(new URLRequest(getComScoreURL()));
		}
		
		private function getComScoreID(pItems:Array, pItemToFind:String):String
		{
			for each(var item:Object in pItems)
			{
				if(pItemToFind && item.name && (item.name.toLowerCase() == pItemToFind.toLowerCase())) 
				{
					if(item.id) 
					{
						return item.id;
					}
				}
			}
			return null;
		}
		
		private function getDomainName(pLocation:String):String
		{
			var domainName:String;
			var urlPieces:Array = pLocation.split('/');
			for(var i:uint = 0; i < urlPieces.length; i++)
			{
				if(urlPieces[i] == "http:")
				{
					CustomLogger.instance.debug("Domain Name Returned is " + urlPieces[i+2]);
					return urlPieces[i+2];
				}
				else throw new Error("URL being parsed didn't start with http:// as expected");
			}
			return domainName;
		}
		
		private function getComScoreURL():String
		{	
			var rootURL:String = "http://beacon.securestudies.com/scripts/beacon.dll?";
			var genreID:String = (!adBeacon) ? "02" + _genreID : "01" + _genreID;
			
			var params:Array = new Array(
				"C1=1",
				"C2=" + _publisherID
			);
			
			if(_contentProducerID)
			{
				params.push("C3=" + _contentProducerID);
			}
			if(_locationID)
			{
				params.push("C4=" + _locationID);
			}
			if(_genreID)
			{
				params.push("C5=" + genreID);
			}
			if(_showID)
			{
				params.push("C6=" + _showID);
			}
			
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