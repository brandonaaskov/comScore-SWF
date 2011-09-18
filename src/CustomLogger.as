package
{
	import com.brightcove.api.modules.ExperienceModule;
	
	public class CustomLogger
	{
		private static const _instance:CustomLogger = new CustomLogger();
		private var _experienceModule:ExperienceModule;
		
		public function CustomLogger()
		{
			if(_instance) throw new Error("Please use the instance property to access the CustomLogger." );
		}
		
		public static function get instance():CustomLogger 
		{
			return _instance;
		}
		
		public function set experienceModule(pExperienceModule:ExperienceModule):void
		{
			_experienceModule = pExperienceModule;
		}
		
		public function debug(text:String):void
		{
			var debugStatement:String = "comScore-SWF: " + text;
			(_experienceModule) ? _experienceModule.debug(debugStatement) : trace(debugStatement);
		}
	}
}