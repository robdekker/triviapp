![Design document](https://github.com/robdekker/triviapp/blob/master/doc/Design%20document%20sketch.png)

## A list of database tables and fields (and their types)  
When you create a new user, you will have to fill in some information in order to create a new account. The following information will be asked and pushed to Firebase:
* Username (String, restriction that it is not previously used)
* Email (String, RegEx restriction that it will be in the form example@example.com)
* Password (String, minimum of 6 characters)  

At the same time, a database table “Users” needs to be created so that users can also see information about other users. The following information is pushed to this database table:
* Username (String)
* Total daily score (Int)
* Total weekly score (Int)
* Level (Int)
* Daily & weekly rank? (Int) (Not sure if I have to put this in the database, because you will assign a rank to a user based on the total daily/weekly score)
* Fetched questions ([String])
* Total times won (Int)  

The questions will be fetched from the API of https://opentdb.com/, so these need not to be stored in the database.  
When a user gives the correct answer to a question, he/she receives a point and the total daily and weekly score of the user will be updated in the database.  
Maybe I will implement something so that users will not get the same questions over and over again. I will have to save all questions that a user has fetched from the API or use something like a “Session Token”, I’m not sure if this is possible.

## A list of APIs and frameworks or plugins that you will be using to provide functionality in your app  
As stated above, questions will be fetched from https://opentdb.com/. Here I can set different configurations per call like the amount of questions, the category (24 in total), the difficulty (easy, medium or hard) and the type of answers (true/false or multiple choice). It’s also possible to ask the user which category they want. The API has a total of 5617 questions. I don’t know if this will be a sufficient amount, but 
