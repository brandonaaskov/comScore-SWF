About
=====

This project provides a Flash plug-in for reporting plays to comScore. It can be used out-of-the-box or as a jumping off point for customizing your analytics plug-in. By setting up an XML file, you can tie the aspects of your videos to your comScore IDs. However, an XML file is not required if your custom fields are setup in a specific way. 

Setup
=====

There are three methods to getting your plug-in ready. The recommended option is to modify the `comscore_map.xml` file to match your needs and then compile your own SWF. That sounds scarier than it really is. All you need is a copy of FlashBuilder (and you can get a free trial from Adobe if need be) and you can follow the instructions below. The second option is to customize your custom fields so that they match up with what comScore is expecting. This is easier to do when first setting up your content in Video Cloud. If you make the internal name of your custom field c3, c4, or c6 (those are the only three values that need to be setup), then the plugin SWF will not require an XML file. You can simply comment out the XML in the `comscore_map.xml` file and compile your SWF from there.

However, if you're really averse to that or just want to get something up and running quickly, you can pass in your comScore map XML file as a URL parameter (there are a few different options for how to pass that in - see below). Please note that by doing it this way, you're introducing the risk of latency. If the file doesn't load up in time and the video starts, the tracking methods will not have initialized properly and information may not be tracked for that viewing. With that in mind, please make sure that if you're going to use this method to host the XML file on a CDN to mitigate the risk of latency.


Recommended: Creating Your Custom SWF
-------------------------------------
If you want to eliminate latency problems by compiling your own SWF, or if you want to make modifications to the SWF/codebase, follow these steps:

1.  Import the project into either FlexBuilder or FlashBuilder. Go to File > Import... > and under General choose "Existing Projects into Workspace." Choose the location of the project you downloaded from the [GitHub project page](https://github.com/BrightcoveOS/comScore-SWF).

2.  Modify the `comscore_map.xml` file inside the assets folder to match your needs. See below for more instructions.

3.  Compile the SWF by using "Export Release Build..." under the Projects menu to get an optimized file size.

4.  Upload the SWF to a server that's URL addressable and make note of the URL.

5.  Log in to your Brightcove account.

6.  Edit your Brightcove player and add the URL under the "plugins" tab and save your player changes.


Optional: Using the Existing SWF 
--------------------------------
If you don't want to compile your own SWF, follow these steps (please keep in mind potential latency issues - see above):

1.  Choose the latest ComScoreSWF.swf from the bin-release folder.

2.  Upload both the SWF file and `comscore_map.xml` file to a server that's URL addressable; make note of those URLs.

3.  At this stage you can add the reference to your comScore map XML file in one of a few ways:

  * **Recommended**: Add `?comscoreMap=http://mydomain.com/my-comscore-map.xml` to the URL of the SWF file (http://mydomain.com/my-comscore-map.xml will be replaced with the location of your comScore map XML file). For example, `http://mydomain.com/OmnitureSWF.swf?comscoreMap=http://mydomain.com/my-comscore-map.xml`
  
  * Instead of using the above recommended method, you could specify a parameter in the JavaScript publishing code for the player.
    `<param name="comscoreMap" value="http://mydomain.com/my-comscore-map.xml" />`
    You could also use this method to override the XML file specified with the above method.
    
  * It's doubtful you'll use this option for anything other than testing, but you can also pass in your comScore map XML file as a parameter to the URL of the page. Similar to the recommended option, you would append `?comscoreMap=http://mydomain.com/my-comscore-map.xml` to the current URL in the browser's address bar. This option will override the above two methods if either or both are being used.

4.  Log in to your Brightcove account.

5.  Edit your Brightcove player and add the URL under the "plugins" tab.

6.  Save your player changes.


Setting Up Your comScore Map XML File 
-----------------------------------
Included in the project is a sample `comscore_map.xml` file in the assets folder. If you're using the recommended setup option above, *do not* change the name of the file or change its location from the assets folder. Otherwise, the name of the file can be changed. You can see in the example file how the different C-Values are setup to link to properties on the video. The custom field name that you use should be the same as the "internal name" automatically created when you specify your custom field. You can find that name by looking in the 'Video Fields' section in your account settings in Brightcove.

To review that your content is being dispatched correctly, please use a tool such as Charles or Fiddler to see the traffic go over the wire when the video/ad content starts playing back. If you have any questions or need support, please post on the Open Source forums.


Known Issues 
------------
1.  When replaying a video after it's completed, if a pre-roll ad plays back, it reports as a post-roll ad.


Current Supported Data Binding Fields
=====================================
If you want to use data-binding, make sure to surround the below values with curly braces. You can even bind multiple fields for the same C-Value. See the `comscore_map.xml` sample file for an example. When data-binding to custom fields, you'll be using the internal name gets automatically created when you make the custom field. If you're unsure what that internal name is, please check the 'Video Fields' section under your account settings in the Brightcove Studio.

Experience Data-Bindings
------------------------
* experience.playerName : The name of the player the plugin is currently being server from.
* experience.url : The current URL of the page. This may not be available if using the HTML embed code.
* experience.id : The ID of the player.
* experience.publisherID : The ID of the publisher to which the media item belongs.
* experience.referrerURL : The url of the referrer page where the player is loaded. 
* experience.userCountry : The country the user is coming from.

Video Data-Bindings
-------------------
* video.adKeys : Key/value pairs appended to any ad requests during media's playback.
* video.customFields['customfieldname'] : Publisher-defined fields for media. 'customfieldname' would be the internal name of the custom field you wish to use.
* video.displayName : Name of media item in the player.
* video.economics : Flag indicating if ads are permitted for this media item.
* video.id : Unique Brightcove ID for the media item.
* video.length : The duration on the media item in milliseconds.
* video.lineupId : The ID of the media collection (ie playlist) in the player containing the media, if any.
* video.linkText : The text for a related link for the media item.
* video.linkURL : The URL for a related link for the media item.
* video.longDescription : Longer text description of the media item.
* video.publisherId : The ID of the publisher to which the media item belongs.
* video.referenceId : Publisher-defined ID for the media item.
* video.shortDescription : Short text description of the media item.
* video.thumbnailURL : URL of the thumbnail image for the media item.shortDescription : Short text description of the media item.
*	video.thumbnailURL : URL of the thumbnail image for the media item.