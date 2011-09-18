About
=====

This project provides a Flash plug-in for reporting plays to comScore. It can be used out-of-the-box or as a jumping off point for customizing your analytics plug-in. By setting up an XML file, you can tie the aspects of your videos to your comScore IDs. 

Setup
=====

There are two methods to getting your plug-in ready. The recommended option is to modify the `comscore_map.xml` file to match your needs and then compile your own SWF. That sounds scarier than it really is. All you need is a copy of FlashBuilder (and you can get a free trial from Adobe if need be) and you can follow the instructions below. However, if you're really averse to that or just want to get something up and running quickly, you can pass in your comScore map XML file as a URL parameter (there are a few different options for how to pass that in - see below). Please note that by doing it this way, you're introducing the risk of latency. If the file doesn't load up in time and the video starts, the tracking methods will not have initialized properly and information may not be tracked for that viewing. With that in mind, please make sure that if you're going to use this method to host the XML file on a CDN to mitigate the risk of latency.


Recommended: Creating Your Custom SWF
-------------------------------------
If you want to eliminate latency problems by compiling your own SWF, or if you want to make modifications to the SWF/codebase, follow these steps:

1.	Import the project into either FlexBuilder or FlashBuilder. Go to File > Import... > and under General choose "Existing Projects into Workspace." Choose the location of the project you downloaded from the [GitHub project page](https://github.com/BrightcoveOS/comScore-SWF).

2.	Modify the `comscore_map.xml` file inside the assets folder to match your needs. See below for more instructions.

3.	Compile the SWF by using "Export Release Build..." under the Projects menu to get an optimized file size.

4.	Upload the SWF to a server that's URL addressable and make note of the URL.

5.	Log in to your Brightcove account.

6.	Edit your Brightcove player and add the URL under the "plugins" tab and save your player changes.


Optional: Using the Existing SWF 
--------------------------------
If you don't want to compile your own SWF, follow these steps (please keep in mind potential latency issues - see above):

1.	Choose the latest download from the [GitHub project's downloads page](https://github.com/BrightcoveOS/comScore-SWF/downloads).

2.	Upload both the SWF file and `comscore_map.xml` file to a server that's URL addressable; make note of those URLs.

3.	At this stage you can add the reference to your comScore map XML file in one of a few ways:

	*	**Recommended**: Add `?comscoreMap=http://mydomain.com/my-comscore-map.xml` to the URL of the SWF file (http://mydomain.com/my-comscore-map.xml will be replaced with the location of your comScore map XML file). For example, `http://mydomain.com/OmnitureSWF.swf?comscoreMap=http://mydomain.com/my-comscore-map.xml`
	
	*	Instead of using the above recommended method, you could specify a parameter in the JavaScript publishing code for the player.
		`<param name="comscoreMap" value="http://mydomain.com/my-comscore-map.xml" />`
		You could also use this method to override the XML file specified with the above method.
		
	*	It's doubtful you'll use this option for anything other than testing, but you can also pass in your comScore map XML file as a parameter to the URL of the page. Similar to the recommended option, you would append `?comscoreMap=http://mydomain.com/my-comscore-map.xml` to the current URL in the browser's address bar. This option will override the above two methods if either or both are being used.

4.	Log in to your Brightcove account.

5.	Edit your Brightcove player and add the URL under the "plugins" tab.

6.	Save your player changes.


Setting Up Your comScore Map XML File 
-----------------------------------
Included in each zip on the [project's downloads page](https://github.com/BrightcoveOS/comScore-SWF/downloads) is a sample `comscore_map.xml` file. If you're using the recommended setup option above, *do not* change the name of the file or change its location from the assets folder. Otherwise, the name of the file can be changed. You can see in the example file how the different sections comScore cares about are broken up into Genres, Content Producers, Locations and Shows (technically, all are optional but provide as much detail as you can). Make sure to specify what custom field to look at for each section (except Locations) - you can see this specified in the attribute of each major section. The custom field name that you use should be the same as the "internal name" automatically created when you specify your custom field. You can find that name by looking in the 'Video Fields' section in your account settings in Brightcove.

At this point, you should specify each ID provided by comScore with its corresponding match. For instance, if you have a piece of content provided by Reuters, you would want to specify the comScore ID for that in the `contentProducers` section. For the `locations` section, you'll want to specify the domain name to check. This will usually be mydomain.com, for instance. Just the name of the domain and the top-level domain being used (.com, .net, .org, etc.). Please don't specify the entire URL of a page of the location to be checked. 

To review that your content is being dispatched correctly, please use a tool such as Charles or Fiddler to see the traffic go over the wire when the video/ad content starts playing back. If you have any questions or need support, please post on the Open Source forums.