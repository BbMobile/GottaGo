GottaGo
=======

**What is it?**

GottaGo is a bathroom availability service developed for the Blackboard Mobile Summer 2013 Hackathon by Collin Allen, Eric Littlejohn, and Joe Taylor. The status of bathrooms is indicated by LED lights on the wall outside the bathroom as well as on the GottaGo status website available on the Blackboard Mobile internal network. It serves as a highly visible set of places to check to see if your walk to the bathroom is a worthwhile one.

**Why do this?**

In an office with a 9-to-1 person-to-toilet ratio, the probability that you'll approach the bathroom with both rooms occupied is very high, and it happens to many folks throughout the day. Do you return to your seat and try again a random amount of time later? Someone might grab the next availability before you. Do you wait by the bathroom? It might still be a while. Very first-world problems, all of which can be solved with first-world technology.

**How does it work?**

Each bathroom door jamb has a microswitch installed, and that switch gets triggered when the door is locked. The state of the switch gets sent via a network-connected [Arduino](http://arduino.cc) to a [Node.js](https://github.com/joyent/node)/[MongoDB](https://github.com/mongodb/mongo)/[AngularJS](https://github.com/angular/angular.js) app to display the status on the internal network.

**Want to hack on GottaGo?**

Node.js code is in the root of the repo.

* The Node.js code can be deployed to the app server and run with [forever](https://github.com/nodejitsu/forever) or just by doing `node app.js`
* MongoDB must also be running on the app server for event logging and analytics

Arduino code is at `arduino/gotta_go/gotta_go.ino`, and can be uploaded via the Arduino IDE.

* Adjust the MAC address and floor for each Arduino you install
* HTTP requests are logged via the Serial Monitor in the Arduino IDE

OS X menu bar status monitor code is at `osx/GottaGo/`.

* [rbenv](https://github.com/sstephenson/rbenv) is useful but not required for keeping Ruby gems separate from OS X system gems
* Install the [CocoaPods](http://cocoapods.org/) Ruby gem: `gem install cocoapods`
* From the `osx/GottaGo/` directory containing the `Podfile`, install dependncies: `pod install`
* Build the OS X app: `make`
* Copy the app to `/Applications`
* Launch it at startup by adding it to System Preferences → Users and Groups → _Your User_ → Login Items
