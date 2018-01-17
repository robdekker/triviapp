# My personal style guide

* Use consistent variable names, start each new word in the variable name with a capital letter (camelcase), like ```isValidEmail```. Don't make them too long.
* Name outlet after his type. For example, an outlet for a text field where you have to fill in your email will be called ```emailTextField```  
and an outlet for a label where the username will be presented will be called ```usernameLabel```.
* Name actions after his role. For example, an action for clicking the sign up button will be called ```signUpButtonTapped```.
* According to the lines above: give the same base name to outlets, actions and methods that share the same meaning.
* Use compiler inferred context to write shorter, clear code. Use ```.black``` instead of ```UIColor.black```.
* Unused (dead) code, including Xcode template code and placeholder comments should be removed.
* Method braces and other braces (if/else/switch/while etc.) always open on the same line as the statement but close on a new line.
* Parentheses around conditionals are not required and should be omitted.
