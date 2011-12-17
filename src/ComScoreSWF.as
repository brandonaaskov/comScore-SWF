/**
 * Brightcove comScore-SWF (16 DECEMBER 2011)
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
	import com.brightcove.api.APIModules;
	import com.brightcove.api.CustomModule;
	import com.brightcove.api.dtos.VideoCuePointDTO;
	import com.brightcove.api.dtos.VideoDTO;
	import com.brightcove.api.events.AdEvent;
	import com.brightcove.api.events.CuePointEvent;
	import com.brightcove.api.events.MediaEvent;
	import com.brightcove.api.modules.APIModule;
	import com.brightcove.api.modules.AdvertisingModule;
	import com.brightcove.api.modules.CuePointsModule;
	import com.brightcove.api.modules.ExperienceModule;
	import com.brightcove.api.modules.VideoPlayerModule;
	import com.brightcove.opensource.ConfigurationMap;
	import com.brightcove.opensource.VideoSegment;
	import com.comscore.ComScore;
	
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.navigateToURL;
	import flash.sensors.Accelerometer;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import mx.core.mx_internal;
	
	public class ComScoreSWF extends CustomModule
	{
		private var _experienceModule:ExperienceModule;
		private var _videoPlayerModule:VideoPlayerModule;
		private var _advertisingModule:AdvertisingModule;
		private var _cuePointsModule:CuePointsModule;
		private var _comScore:ComScore;
		private var _comScoreMap:ConfigurationMap;
		
		private var _mediaComplete:Boolean = true;
		private var _videoWasWatched:Boolean = false;
		private var _adComplete:Boolean = false;
		private var _videoSegments:Array = new Array();
		
		public function ComScoreSWF()
		{
			trace('@project ComScoreSWF');
			trace('@author Brandon Aaskov (Brightcove)');
			trace('@lastModified 12.16.11 1929 EST');
			trace('@version 2.0.2');
			
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			
			/*		
			KNOWN ISSUES:
			- on replay, ad tracks as post-roll
			*/
		}
		
		override protected function initialize():void
		{
			_experienceModule = player.getModule(APIModules.EXPERIENCE) as ExperienceModule;
			CustomLogger.instance.experienceModule = _experienceModule;
			
			_videoPlayerModule = player.getModule(APIModules.VIDEO_PLAYER) as VideoPlayerModule;
			_videoPlayerModule.addEventListener(MediaEvent.CHANGE, onMediaChange);
			_videoPlayerModule.addEventListener(MediaEvent.PLAY, onMediaPlay);
			_videoPlayerModule.addEventListener(MediaEvent.PROGRESS, onMediaProgress);
			_videoPlayerModule.addEventListener(MediaEvent.COMPLETE, onMediaComplete);
			
			_advertisingModule = player.getModule(APIModules.ADVERTISING) as AdvertisingModule;
			if(_advertisingModule)
			{	
				_advertisingModule.addEventListener(AdEvent.AD_START, onAdStart);
				_advertisingModule.addEventListener(AdEvent.AD_COMPLETE, onAdComplete);
			}
			
			_cuePointsModule = player.getModule(APIModules.CUE_POINTS) as CuePointsModule;
			_cuePointsModule.addEventListener(CuePointEvent.CUE, onCuePoint);
			
			var fileURL:String = getParamValue('comscoreMap');
			_comScoreMap = new ConfigurationMap();
			_comScoreMap.addEventListener(Event.COMPLETE, onMappingComplete);
			_comScoreMap.load(fileURL);
		}
		
		//------------------------------------------------------------------------------------------------- EVENT LISTENERS
		private function onMappingComplete(pEvent:Event):void
		{
			CustomLogger.instance.debug('Mapping Complete');
			_comScore = new ComScore(_comScoreMap, _experienceModule);
			setupForNewVideo();
			
			if(!_mediaComplete && _videoPlayerModule.isPlaying()) //the video already started, but we missed the chance to fire the beacon
			{
				_comScore.sendBeacon();
			}
		}
		
		private function onMediaChange(pEvent:MediaEvent):void
		{
			setupForNewVideo();
		}
		
		private function onMediaPlay(pEvent:MediaEvent):void
		{
			if(_comScoreMap.mappingComplete && _mediaComplete)
			{
				if(!_comScore)
				{
					_comScore = new ComScore(_comScoreMap, _experienceModule);
				}
				
				setupForNewVideo();
				CustomLogger.instance.debug("Sending video start beacon");
				_comScore.sendBeacon();
			}
			else if(!_comScoreMap.mappingComplete && _mediaComplete)
			{
				CustomLogger.instance.debug("Mapping was not completed in time. Will fire the beacon once it's complete.");
			}
			
			_mediaComplete = false;
		}
		
		private function onMediaProgress(pEvent:MediaEvent):void
		{
			if(_comScoreMap.mappingComplete && !_mediaComplete && _adComplete)
			{
				//at some point midway through the video
				_comScore.isPreRollAd = false;
				_comScore.isMidRollAd = false;
				_comScore.isPostRollAd = false;
				_adComplete = false;
				
				CustomLogger.instance.debug("Sending content beacon after mid-roll ad.");
				_comScore.sendBeacon();
			}
			
			if(!_videoWasWatched)
			{
				_videoWasWatched = true;
			}
			
			if(_comScore.videoSegments && _comScore.videoSegments.length > 0)
			{
				checkForCurrentSegment(pEvent.position);
			}
		}
		
		private function onMediaComplete(pEvent:MediaEvent):void
		{
			_mediaComplete = true;
		}
		
		private function onAdStart(pEvent:AdEvent):void
		{
			if(_comScore)
			{
				if(_mediaComplete && _videoWasWatched)
				{
					CustomLogger.instance.debug('post-roll');
					_comScore.isPostRollAd = true;
				}
				else if(!_mediaComplete && _videoWasWatched)
				{
					CustomLogger.instance.debug('mid-roll');
					_comScore.isMidRollAd = true;
				}
				else if(_mediaComplete && !_videoWasWatched)
				{
					CustomLogger.instance.debug('pre-roll');
					_comScore.isPreRollAd = true;
				}
				
				CustomLogger.instance.debug("Sending ad beacon.");
				_comScore.sendBeacon();
			}
		}
		
		private function onAdComplete(pEvent:AdEvent):void
		{
			//only setting the ad complete flag if we just watched a midroll ad
			if(!_mediaComplete)
			{
				CustomLogger.instance.debug('Setting Ad Complete to True');
				_adComplete = true;
			}
		}
		
		private function onCuePoint(pEvent:CuePointEvent):void
		{
			if(pEvent.cuePoint.type == 0)
			{
				for(var i:uint = 0; i < _comScore.videoSegments.length; i++)
				{
					var videoSegment:VideoSegment = _comScore.videoSegments[i];
					
					if(pEvent.cuePoint.time == videoSegment.startTime)
					{
//						videoSegment.adWatched = true;
						_comScore.currentSegment = i + 1;
					}
				}
			}
		}
		//-------------------------------------------------------------------------------------------------

		
		
		
		//------------------------------------------------------------------------------------------------- HELPER FUNCTIONS
		private function setupForNewVideo():void
		{
			//set up some stuff for the current video before we send the first beacon
			getAdCuePoints();
			_videoWasWatched = false;
			_comScore.isPreRollAd = false;
			_comScore.isMidRollAd = false;
			_comScore.isPostRollAd = false;
			_comScore.currentVideo = _videoPlayerModule.getCurrentVideo();
			_comScore.currentSegment = 1;
		}
		
		private function checkForCurrentSegment(pCurrentPosition:Number):void
		{
			for(var i:uint = 0; i < _comScore.videoSegments.length; i++)
			{
				var videoSegment:VideoSegment = _comScore.videoSegments[i];
				
				if(videoSegment.startTime > pCurrentPosition)
				{
					_comScore.currentSegment = i;
					break;
				}
			}
		}
		
		private function getAdCuePoints():void
		{
			var currentVideo:VideoDTO = _videoPlayerModule.getCurrentVideo();
			
			if(currentVideo)
			{
				var cuePoints:Array = _cuePointsModule.getCuePoints(currentVideo.id);
				
				if(cuePoints)
				{
					var videoSegments:Array = new Array();
					
					for(var i:uint = 0; i < cuePoints.length; i++)
					{
						var cuePoint:VideoCuePointDTO = cuePoints[i];
						var isPostRoll:Boolean = (cuePoint.name && (cuePoint.name.toLowerCase() == "post-roll")) ? true : false;
						
						//we don't want to include the postroll cue point because that doesn't represent the beginning of a new segment
						if(cuePoint.type == 0 && !isPostRoll)
						{
							var endTime:Number;
							
							if((i + 1) == cuePoints.length)
							{
								endTime = currentVideo.length / 1000;
							}
							else
							{
								endTime = VideoCuePointDTO(cuePoints[i+1]).time;
							}
							
							var metadata:String = (cuePoint.metadata) ? cuePoint.metadata.toString() : "";
							videoSegments.push(new VideoSegment(cuePoint.time, endTime, metadata));
						}
					}
					
					_comScore.videoSegments = videoSegments;
				}
				else
				{
					_comScore.videoSegments = new Array(new VideoSegment(0, _videoPlayerModule.getCurrentVideo().length, ''));
				}
			}
		}
		
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
		//-------------------------------------------------------------------------------------------------
	}
}