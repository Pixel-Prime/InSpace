# Welcome to InSpace

**InSpace** is a personal *iOS* project created to demonstrate the integration of various platform features and capabilities in *Swift*. This project is made possible thanks to the [NASA Open APIs](https://api.nasa.gov/) project, which provides access to an incredibly rich source of decades-long exploration, research, and mission data.

This app utilises one of these APIs, the venerable **NASA Image and Video Library**, to display a wealth of photos and videos relating to an enormous array of scientific and astronomical topics.

# Current capabilities

Whilst this project is still undergoing continued improvement, the following features can already be found in the latest build:

- Demonstration of storyboard-based app layout (working off of a **UINavigationController** base)
	> For convenience, all app screens are developed within the **Main** storyboard, with the exception of instances where a UITableViewCell has been created for custom cell layouts
- Networking protocol use for feed download and local storage
- Data modelling for feed compatibility (using the built-in *JSONUtility* API)
- Robust, asynchronous media downloading using a combination of in-memory and disk caching to support both smooth interface responsiveness and offline capabilities.
- Interface animations to provide better visual feedback for some app activities
- Various convenience wrappers to allow easier and less-cluttered creation of rich *UITextView* content using *NSAttributedString*s.
- Dyanamic embedding of native video playback for supported media items from the NASA feed.
- Search functionality to pull in user-selected topics from the feed.


# License details

This project is currently licensed under **Creative Commons Attribution Non-Derivatives Non-Commercial International 4.0**. Please see [this page](https://creativecommons.org/licenses/by-nc-nd/4.0/) for a detailed breakdown of this license.

In summary, you are free to **copy** and **redistribute** this project and its code in any medium or format, but appropriate credit and attribution must be given to the original author. You must also provide a link to this license.

This project is also **not to be used** for commercial purposes, and if the project is modified, remixed or altered in any way the modified version **must not be distributed**.

This license does not affect the rights of **fair use**. Please see the above link to the license for more details.
