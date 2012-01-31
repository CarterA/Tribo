# Tribo #

-----
This project is unfinished, and will likely remain in an unfinished state for a considerable amount of time. That said, I use it myself and find it...workable. Your mileage may vary.   

-----

Tribo is one of an increasing number of static blogging engines. A static blogging engine is simply a blogging system that generates a set of static HTML files that can then be served by any self-respecting web server. This differs from traditional blogging engines like WordPress in that no code needs to be run on the server apart from the web server process itself. Static engines are considerably faster and more efficient than dynamic engines, but that comes with a penalty: they are more difficult to update.  

This project doesn't solve that problem. There is no web-based control panel for you to post with, and there is no "cloud" integration. Tribo takes a specially formatted set of files on your computer, does some magic, and generates a set of static HTML files which you can then publish to almost any server. That's it.  

It seems like most programming languages have a static blogging engine written in them, but Objective-C is sadly not among them. Objective-C may not seem like an ideal candidate for the job: it is a compiled language, has significant platform lock-in, and did I mention that it is a compiled language? Well, as is becoming a theme here, this project does not address those issues. I chose to write Tribo in Objective-C for a very simple reason: I like Objective-C, and I want my blogging engine to be written in a language that I am extremely comfortable with. I imagine that Tribo will appeal most to other Objective-C developers, as they will hopefully feel comfortable hacking on it and making it work in just the right way.  

That said, remember when I said that this project is incomplete? Here is a short list of the major things that still need to be done. Feel free to fork the project and implement any of them:

- Publishing. The app should be able to publish the generated site to any FTP server. An option to deploy to GitHub Pages would also be nice. Possibilities for implementing this include using ConnectionKit, which I haven't looked at in a while, or wrapping Rsync with an `NSTask`.
- New site creation. A document-based app should really be able to create new documents. This may go along with making the Tribo format into a package/bundle instead of just a folder, but I'm still not sure I want to go that route.
- Bare-bones Markdown editor. It seems like a bit of a cop-out to just say "edit posts in your favorite Markdown editor!" since the best ones aren't free. This is a big project though, so I'm keeping my eye out for an embeddable editor that I could just drop in (I know that's a lot to ask, but hey!).
- iCloud syncing. If I go the package route I described before, then the packages could be synced between computers via iCloud. This also brings up the next point...
- iOS companion app. One of the benefits of a pure-Obj-C/C engine is that the generator side of the app should compile out-of-the-box for iOS. A basic UI to match the current Mac app would be trivial to make, but the need for a Markdown editor is even greater here. The system for using external editors on iOS is really awkward, and I would never want to use the app if it deferred the most important part of the experience to an unknown third-party.


I'll write a bit about the architecture of the app at a later date. Thanks for your interest!