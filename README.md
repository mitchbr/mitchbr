# Mitchell Brown on GitHub
Welcome to my GitHub! I have a few fun projects I have been working on which you can view here. I am currently a software engineer at Vacasa in Portland, OR.

# Current Projects
## Grocery List App
https://github.com/mitchbr/grocery_list_app

My most mature project, I use this to manage all of my grocery trips. It is built in Flutter, which provides me the flexibility to build for most systems, including web, Android and iOS. 

This project has seen many evolutions and plenty of experimenting. Originally, I was building it as an Android app with a SQLite backend. However, I wanted recipes to be more easlity shareable, so I began building out an AWS API. I got a PoC up and running, but realized there would be some costs involved (RDS, API Gateway, and S3 lose free tier status after one year). It was likely my costs would be very low, but free always beats cheap, so I transitioned to Flutter Firestore. 

The free tier on Firestore was well within reason for me, with up to 50k reads, 20k writes, and 1 GiB stored data per day. I was quite confident I would never surpass this limit, and there would be no incurred costs if I did, so I thought it would be worth it. Some notes on Firestore:
- The Flutter Firestore package uses Flutter's StreamBuilder, which is great, but required some heavy refactoring from previous APIs. Previously, I had a two-tiered architecture; UI and Data. However, Streambuilders really need to be combined with UI components, so much of my tiering was collapsed. I'm not the biggest fan of how my code is structured now, and would really prefer to break it back out to more distinct tiers.
- I'm not the biggest fan of the way I retrieve data from Firestore. I believe there are more intelligent functions I can write, but I found at the time the easiest thing to do was grab way too much data, then filter and process on the frontend. This really goes against some principals I have with client/server interactions. I believe the frontned should be able to make a request that enables the backend to serve up exactly the resources the frontend needs, and the frontend should need to do little to no computing after.

All this to say, I am currently experimenting with self-hosting an API on a raspberry pi 5. The status of this project changes every day, and I hope to have some more tangible work to show for it soon.

Currently, I am running the app as a PWA on my devices. Originally, I ran an Android app, but have sinced purchased an iPhone. I can build for iOS, but I run into the problem of needing to pay for an Apple developer account to make it downloadable to my devices (And I don't want to jailbreak). The Apple developer account isn't insanely expensive by any means, but again, free always beats cheap, so I've stuck to a PWA.

The app is available at the below URL, and you can sign in with the user `mitchbr`. This is my test user, so you won't break anything! I haven't implemented any sort of sing-in or other security. Frankly, I'm not trying to open this project up for others except close family/friends to use, so I don't mind it being a bit insecure. Maybe I'll build or look into better auth someday.
https://mitchbr.github.io/grocery_list_web/#/


# LinkedIn
Let's connect on [LinkedIn](https://www.linkedin.com/in/mitchbr/)!
