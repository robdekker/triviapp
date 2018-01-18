# Day 1 (monday 15-01)
* Created a login screen and fixed email/password authentication. 
* Provided proper error alerts at login screen.
* Sign up function is also active. Signing up a new account will send user data to the database, all attributes of a profile are set now.
* Started working on Facebook Login authentication.
* The design of the login screen is inspirated by the login screen below (found on Google Images)

<img src="doc/processbook_image1.jpg" alt="login screen inspiration" width="230" height="400">

# Day 2 (tuesday 16-01)
* Set up the tab bar controller with the different views; home, leaderboard and profile.
* Created a ProfileViewController for the current user to check his/her personal info. This info is retrieved from the realtime database of Firebase.
* Facebook Login authentication successfully implemented. Managed to retrieve Facebook profile picture. Still need to fix saving user data at the Firebase database when facebook account is created.
* Failed to load the top 10 users (both daily & weekly) with scores from the user database.
* Failed to push all changes to github, tried for a couple of hours to fix it.

# Day 3 (wednesday 17-01)
* Finally managed to push all files to github, but still some kind of bug (submodule).
* Updated my process book on github.
* Made a style guide and pushed it to my github repository.
* Pushed all changes to github, still some little bug that needs to be fixed.
* Managed to load the daily AND weekly top 10 users(!) with their scores (descending) from the user database.
* Started to work on saving user data when new account is created with Facebook login.

## Things I still want to implement in my app:
* UIImagePicker to change profile picture
