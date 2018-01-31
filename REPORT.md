# REPORT

**Application name:** Triviapp  
**Student name:** Rob Dekker  
**Student ID:** 11020067  

## A short description of the application
Challenge your friends every single week of the year with this application! Triviapp is a game where players are able to compete with eachother   
by answering questions from the Open Trivia Database. In order to make this a fair "fight", all players will get the same questions per day.  

**Screenshot**  
<img src="doc/" alt="screenshot" width="230" height="400">

## Technical design

### Overview
Opening the application for the first time will lead you (ofcourse) to the Login screen. New users will have to fill in  
a form in order to create a new account. It's also possible (and easier) to create a new account with Facebook login. When a user is logged in, the Home screen will be presented. Here is presented some information about the user itself and about eventually available questions to answer. From the Home screen, the user is able to navigate to the leaderboards and his/her profile with the Tab Bar. It's also possible to directly start the quiz with the daily questions fetched from the API. The user has to answer all questions in order to see their score. There are two different leaderboards, one for the daily top players and one for the weekly top players. From the leaderboards, it is possible to view information of other accounts by clicking on them (such as their current level).  

