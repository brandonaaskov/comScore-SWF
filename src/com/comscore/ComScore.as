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
				_showID = getComScoreID(pMap.getShows(), pVideo.customFields[pMap.getCustomFieldName('shows')]);
				_genreID = getComScoreID(pMap.getGenres(), pVideo.customFields[pMap.getCustomFieldName('genres')]);
				_contentProducerID = getComScoreID(pMap.getContentProducers(), pVideo.customFields[pMap.getCustomFieldName('contentproducers')]);
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
			for each(var item:ComScoreEntry in pItems)
			{
				CustomLogger.instance.debug('Item to find is: ' + pItemToFind.toLowerCase() + ' and Item Name is: ' + item.name.toLowerCase());
				
				if(pItemToFind && item.name && (item.name.toLowerCase() == pItemToFind.toLowerCase())) 
				{
					if(item.id) 
					{
						CustomLogger.instance.debug('Item ID is: ' + item.id);
						return item.id;
					}
				}
			}
			return null;
		}
		
		private function getDomainName(pLocation:String):String
		{
			var topLevelDomain:String;
			var domainSplit:Array = pLocation.split('/');
			var topLevelDomainIndex:uint;
			
			for(var i:uint = 0; i < domainSplit.length; i++)
			{
				var domainItem:String = domainSplit[i];
				if(domainItem.length > 1 && domainItem.indexOf('http') == -1)
				{
					topLevelDomainIndex = i;
					break;
				}
			}
			
			CustomLogger.instance.debug('TOP LEVEL DOMAIN: ' + domainSplit[topLevelDomainIndex]);
			
			return domainSplit[topLevelDomainIndex];
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