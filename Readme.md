# Tribo #

Tribo is a native blogging app for Mac. It features a simple interface for site management, an editor for Markdown content, and a static site generator used to produce the final product. Additionally, it integrates a local preview, complete with automatic refresh, accessible by any device on your local network. Tribo is thus a combination of a blogging client app and a blogging engine, with a dash of a text editor thrown in for good measure. 

At the core of Tribo is an entirely-native static blogging engine. A static blogging engine is a blogging system that generates a set of static HTML files that can then be served by any self-respecting web server. This differs from traditional blogging engines like WordPress in that no dynamic code needs to be run on the server. Static engines are considerably faster and more efficient than dynamic engines, but they comes with a penalty: updating the site requires rebuilding and re-uploading the entire set of files.  

This project doesn't solve that problem. There is no web-based control panel for you to post with, and there is no "cloud" integration. Tribo's engine takes a specially formatted set of files on your computer, does some magic, and generates a set of static HTML files which you can then publish to almost any server. That's it.  

It seems like most programming languages have a static blogging engine written in them, but Objective-C is sadly not among them. Objective-C may not seem like an ideal candidate for the job: it is a compiled language, has significant platform lock-in, and did I mention that it is a compiled language? Well, as is becoming a theme here, this project does not address those issues. I chose to write Tribo in Objective-C for a very simple reason: I like Objective-C, and I want my blogging engine to be written in a language that I am extremely comfortable with. I imagine that Tribo will appeal most to other Objective-C developers, as they will hopefully feel comfortable hacking on it and making it work in just the right way. Writing the engine in Objective-C has the added benefit of making it easy to integrate into a native app for Mac (and eventually iOS).

### Compiling ###

You'll need to venture to the Terminal to get a copy of Tribo. Start by cloning a copy of this repository and pulling in all of the dependencies:

    git clone git://github.com/CarterA/Tribo.git && cd Tribo
    git submodule init && git submodule update

Next, you need to add the included code signing certificate to your default keychain (usually called "login"). The certificate is called "Tribo Open Source Developer.p12" and resides in the App subdirectory of the repository. Opening the file directly should cause Keychain Access to try and add the certificate to your keychain, and will prompt you for the password for the certificate file. Simple continue through the dialog without entering a password, as there isn't one. When asked if you want to trust the certificate, press "Always Trust".  

The included open-source developer certificate allows you to build the app with code signing and sandboxing enabled. Because the certificate is self-signed, it is not valid for use with iCloud or for submission to the Mac App Store. If this all seems a little bit excessive, I encourage you to complain to Apple, not me.  

At this point, you should be ready to open up the Xcode project and try to run the "App" scheme.