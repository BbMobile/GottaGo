GottaGo
=======

When you gotta go you _GottaGo_.

**What is It?**

GottaGo is a bathroom availability monitoring system created for the Summer 2013 BbMobile Hackathon by Collin Allen, Eric Littlejohn, and Joe Taylor. It works by keeping track of door locks and reporting the current states to a server at http://gottago.medu.com.

**How Does it Work?**

It's powered by an Arduino that monitors a switch inside each bathroom door lock, as well as a app server running Node.js and MongoDB. The Arduino does an HTTP POST to the app server whenever the door is locked or unlocked, and the state is then reflected in lights on the wall near the bathroom as well as the GottaGo web site.

**Hacking**

If you'd like to hack on this project, the app server code lives in the root of this repo, and the Arduino code can be uploaded to the blue Arduino on the bathroom wall via USB. The Arduino code lives at `arduino/gotta_go/gotta_go.ino` and when running while connected, it will dump out debug information in the Serial Monitor in the Arduino IDE.
