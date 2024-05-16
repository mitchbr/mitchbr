# Mitchell Brown on GitHub
Welcome to my GitHub! I have a few fun projects I have been working on which you can view here. I am currently a software engineer at Vacasa in Portland, OR.

Let's connect on [LinkedIn](https://www.linkedin.com/in/mitchbr/)!

# Current Projects
## Grocery List App
https://github.com/mitchbr/grocery_list_app

My most mature project, I use this to manage all of my grocery trips. It is built in Flutter, which provides me the flexibility to build for most systems, including web, Android and iOS. 

This project has seen many evolutions and plenty of experimenting. Originally, I was building it as an Android app with a SQLite backend. However, I wanted recipes to be more easlity shareable, so I began building out an AWS API. I got a PoC up and running, but realized there would be some costs involved (RDS, API Gateway, and S3 lose free tier status after one year). It was likely my costs would be very low, but free always beats cheap, so I transitioned to Flutter Firestore. 

The free tier on Firestore was well within reason for me, with up to 50k reads per day, 20k writes per day, and 1 GiB stored data. I was quite confident I would never surpass this limit, so I thought it would be worth it. Some notes on Firestore:
- The Flutter Firestore package uses Flutter's StreamBuilder, which is great, but required some heavy refactoring from previous APIs. Previously, I had a two-tiered architecture; UI and Data. However, Streambuilders really need to be combined with UI components, so much of my tiering was collapsed. I'm not the biggest fan of how my code is structured now, and would really prefer to break it back out to more distinct tiers.
- I'm not the biggest fan of the way I retrieve data from Firestore. I believe there are more intelligent functions I can write, but I found at the time the easiest thing to do was grab way too much data, then filter and process on the frontend. This really goes against some principals I have with client/server interactions. I believe the frontned should be able to make a request that enables the backend to serve up exactly the resources the frontend needs, and the frontend should need to do little to no computing after.

All this to say, I am currently experimenting with self-hosting an API on a raspberry pi 5. The status of this project changes every day, and I hope to have some more tangible work to show for it soon.

Currently, I am running the app as a Progressive Web App (PWA) on my devices. Originally, I ran an Android app, but have sinced purchased an iPhone. I can build for iOS, but I run into the problem of needing to pay for an Apple developer account to make it downloadable to my devices (And I don't want to jailbreak). The Apple developer account isn't insanely expensive by any means, but again, free always beats cheap, so I've stuck to a PWA.

The app is available at the below URL, and you can sign in with the user `mitchbr`. This is my test user, so you won't break anything! I haven't implemented any sort of sing-in or other security. Frankly, I'm not trying to open this project up for others except close family/friends to use, so I don't mind it being a bit insecure. Better auth would still be nice, especially once the API is hosted on my raspberry pi, but isn't something I'm prioritizing now.
https://mitchbr.github.io/grocery_list_web/#/

## Block Puller
https://github.com/mitchbr/BlockPullApp

While this repo contains the start of a react native app, the Arduino code is contained in the `/arduino/ble_scale` directory.

A quick diversion from web apps, I decided I wanted to try out a fun Arduino project. The goal of this project was to clone a rock climbing training tool called a [tindeq progressor](https://tindeq.com/product/progressor/). What this progessor does is read force data and transmit via bluetooth low enegery (BLE). This tool, paired with something like a [Tension Block](https://tensionclimbing.com/product/the-block-2/), enables me to have highly precise data when it comes to training my finger muscles, a key part of training for rock climbing.

With bluetooth transmission, I hope to someday pull that data into an iOS app and have a more rich experience, such as having built-in timers and force goals (Ie pull 100 lbs for 10 seconds). However, I've found some challenges with developing iOS apps that require bluetooth. As it turns out, I can't build web apps to use bluetooth, because the iOS webkit engine doesn't have bluetooth. An interesting thing with iOS is that _all_ browsers run on webkit, including chrome, so there is no way around this. I could build a native iOS app, but that requires the aforementioned Apple developer account. I'm more motivated to get the account, but it's on the backburner while I work on other things. For now I just use a simple iOS app that allows me to interface with BLE devices.

## StickieDB
Frontend: https://github.com/mitchbr/sticker_app

Backend: https://github.com/mitchbr/sticker_api

My most recent project, this is where I have begun developing an API PoC (And related Flutter app) which will be the first to be hosted on the raspberry pi. The API is built using Python's FastAPI, and I plan to use a MongoDB NoSQL database. The choice for NoSQL is admittedly quite simple; I don't use it day-to-day and want to get more hands on with it. 

Much of this is still in development but what I can say is I'm experimenting with many new things:
1. Self-hosting an API and learning how to serve it up publicly
2. HTTPS; something that's always been abstracted by AWS, I'm currently looking into obtaining certificates and enabling this API to be HTTPS.
3. Standing up a local database. Again, something always handled using AWS or the serverless framework. This may even involve doing my own docker containers from scratch, TBD.

