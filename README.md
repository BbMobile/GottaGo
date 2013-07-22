GottaGo
=======

When you gotta go, you _GottaGo_

**What is it?**

GottaGo is a bathroom availability service developed for the Blackboard Mobile Summer 2013 Hackathon by Collin Allen, Eric Littlejohn, and Joe Taylor. The status of bathrooms is indicated by LED lights on the wall outside the bathroom as well as on the GottaGo status website at [gottago.medu.com](http://gottago.medu.com). It serves as a highly visible set of places to check to see if your walk to the bathroom is a worthwhile one.

**Why do this?**

In an office with a 9-to-1 person-to-toilet ratio, the probability that you'll approach the bathroom with both rooms occupied is very high, and it happens to many folks throughout the day. Do you return to your seat and try again a random amount of time later? Someone might grab the next availability before you. Do you wait by the bathroom? It might still be a while. Very first-world problems, all of which can be solved with first-world technology.

**How does it work?**

Each bathroom door jamb has a microswitch installed, and that switch gets triggered when the door is locked. The state of the switch gets sent via a network-connected [Arduino](http://arduino.cc) to a Node.js/MongoDB/AngularJS app to display the status on the internal network.

**Want to hack on GottaGo?**

The Node.js code is in the root of the repo, and the Arduino code is at `arduino/gotta_go/gotta_go.ino`.

* The Node.js code can be deployed to gottago.medu.com, where a `gottago` service is running Node.js via [forever](https://github.com/nodejitsu/forever)
* The Arduino code can be uploaded to the wall-mounted Arduino via USB, and HTTP requests are logged via the Serial Monitor in the Arduino IDE