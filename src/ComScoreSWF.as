/**
 * Brightcove comScore-SWF (18 SEPTEMBER 2011)
 *
 * REFERENCES:
 *	 Website: http://opensource.brightcove.com
 *	 Source: http://github.com/brightcoveos
 *
 * AUTHORS:
 *	 Brandon Aaskov <baaskov@brightcove.com>
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the “Software”),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, alter, merge, publish, distribute,
 * sublicense, and/or sell copies of the Software, and to permit persons to
 * whom the Software is furnished to do so, subject to the following conditions:
 *   
 * 1. The permission granted herein does not extend to commercial use of
 * the Software by entities primarily engaged in providing online video and
 * related services.
 *  
 * 2. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT ANY WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, SUITABILITY, TITLE,
 * NONINFRINGEMENT, OR THAT THE SOFTWARE WILL BE ERROR FREE. IN NO EVENT
 * SHALL THE AUTHORS, CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY WHATSOEVER, WHETHER IN AN ACTION OF
 * CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
 * THE SOFTWARE OR THE USE, INABILITY TO USE, OR OTHER DEALINGS IN THE SOFTWARE.
 *  
 * 3. NONE OF THE AUTHORS, CONTRIBUTORS, NOR BRIGHTCOVE SHALL BE RESPONSIBLE
 * IN ANY MANNER FOR USE OF THE SOFTWARE.  THE SOFTWARE IS PROVIDED FOR YOUR
 * CONVENIENCE AND ANY USE IS SOLELY AT YOUR OWN RISK.  NO MAINTENANCE AND/OR
 * SUPPORT OF ANY KIND IS PROVIDED FOR THE SOFTWARE.
 */

package
{
	import com.brightcove.IDMapping;
	import com.brightcove.api.APIModules;
	import com.brightcove.api.CustomModule;
	import com.brightcove.api.dtos.VideoDTO;
	import com.brightcove.api.events.AdEvent;
	import com.brightcove.api.events.MediaEvent;
	import com.brightcove.api.modules.APIModule;
	import com.brightcove.api.modules.AdvertisingModule;
	import com.brightcove.api.modules.ExperienceModule;
	import com.brightcove.api.modules.VideoPlayerModule;
	import com.comscore.ComScore;
	
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.Security;
	
	import mx.core.mx_internal;
	
	public class ComScoreSWF extends CustomModule
	{
		private var _experienceModule:ExperienceModule;
		private var _videoPlayerModule:VideoPlayerModule;
		private var _advertisingModule:AdvertisingModule;
		private var _comScore:ComScore;
		private var _comScoreMap:IDMapping;
		
		private var _mediaComplete:Boolean = true;
		private var _currentVideo:VideoDTO;
		
		public function ComScoreSWF()
		{
			trace('@project ComScoreSWF');
			trace('@author Brandon Aaskov (Brightcove)');
			trace('@lastModified 10.03.11 1045 EST');
			trace('@version 0.9.1');
			
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
		}
		
		override protected function initialize():void
		{
			_experienceModule = player.getModule(APIModules.EXPERIENCE) as ExperienceModule;
			CustomLogger.instance.experienceModule = _experienceModule;
			
			var fileURL:String = getParamValue('comscoreMap');
			_comScoreMap = new IDMapping(fileURL);
			_comScoreMap.addEventListener(Event.COMPLETE, onMappingComplete);
			
			_videoPlayerModule = player.getModule(APIModules.VIDEO_PLAYER) as VideoPlayerModule;
			_videoPlayerModule.addEventListener(MediaEvent.PLAY, onMediaPlay);
			_videoPlayerModule.addEventListener(MediaEvent.COMPLETE, onMediaComplete);	
			
			if(_advertisingModule)
			{	
				_advertisingModule.addEventListener(AdEvent.AD_START, onAdStart);
			}
		}
		
		private function onMappingComplete(pEvent:Event):void
		{
			_comScore = new ComScore(_videoPlayerModule.getCurrentVideo(), _comScoreMap, _experienceModule.getExperienceURL());
			
			if(!_mediaComplete) //the video already started, but we missed the chance to fire the beacon
			{
				_comScore.sendBeacon();
			}
		}
		
		private function onAdStart(pEvent:Object):void
		{
			_comScore.adBeacon = true;
			CustomLogger.instance.debug("Sending ad beacon.");
			_comScore.sendBeacon();
			_comScore.adBeacon = false;
		}
		
		private function onMediaPlay(pEvent:MediaEvent):void
		{
			if(_comScoreMap.mappingComplete && _mediaComplete)
			{
				CustomLogger.instance.debug("Sending video start beacon");
				
				if(!_comScore)
				{
					_comScore = new ComScore(_videoPlayerModule.getCurrentVideo(), _comScoreMap, _experienceModule.getExperienceURL());
				}
				
				_comScore.sendBeacon();
			}
			else if(!_comScoreMap.mappingComplete && _mediaComplete)
			{
				CustomLogger.instance.debug("Mapping was not completed in time. Will fire the beacon once it's complete.");
			}
			
			_mediaComplete = false;
		}
		
		private function onMediaComplete(pEvent:MediaEvent):void
		{
			_mediaComplete = true;
		}
		
//		private function debug(pMessage:String):void
//		{
//			var message:String = 'comScore-SWF: ' + pMessage;
//			
//			(_experienceModule) ? _experienceModule.debug(message) : trace(message);
//		}
		
		private function getParamValue(key:String):String
		{
			//1: check url params for the value
			var url:String = _experienceModule.getExperienceURL();
			if(url.indexOf("?") !== -1)
			{
				var urlParams:Array = url.split("?")[1].split("&");
				for(var i:uint = 0; i < urlParams.length; i++)
				{
					var keyValuePair:Array = urlParams[i].split("=");
					if(keyValuePair[0] == key)
					{
						CustomLogger.instance.debug("Found URL param for " + key);
						return keyValuePair[1];
					}
				}
			}
			
			//2: check player params for the value
			var playerParam:String = _experienceModule.getPlayerParameter(key);
			if(playerParam)
			{
				CustomLogger.instance.debug("Found player parameter for " + key);
				return playerParam;
			}
			
			//3: check plugin params for the value
			var pluginParams:Object = LoaderInfo(this.root.loaderInfo).parameters;
			for(var param:String in pluginParams)
			{
				if(param == key)
				{
					CustomLogger.instance.debug("Found plugin param for " + key);
					return pluginParams[param];
				}
			}
			
			return null;
		}
	}
}