// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

/*
string tempvar = 'Enter_your_name_here';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);
*/


/*The below code 
is used to write 
and print the
welcome message.*/

string message = 'Welcome to VS Code';
system.debug('The message in VS Code is ::::' +message);

//DataTypes and Variables

Boolean codingIsFun;


codingIsFun = true;














Boolean codingIsBoring = false;
String websiteILove = 'salesforce.com';
String number1 = '100';
Integer anotherNumber1 = number1 + 100;
system.debug('The integer Variable :::::: Number :::::' +number1 );
system.debug('The integer Variable :::::: Another Number :::::' +anotherNumber1 );
Decimal rupeeValue = 86.44;


Object randomValue = 'Apex Code';

string textValue = (string) randomValue;





final integer DISCOUNT = 10;


DISCOUNT = 100;

system.debug('Discount Value::::: '+DISCOUNT);

string name = 'salesforce';
system.debug('First Assigned Value to Name ::::: '+ name);
name = 'apex';
system.debug('Changed Value of Name ::::: '+name);






//Expression Operators

integer totalSandwich = 5;
integer kids = 2;
integer breakfastCost = totalSandwich/kids ;

system.debug('BSandwich for each Kid::::: '+breakfastCost);





Integer totalTrees = 12;
Integer totalTrees += 5;

totalTrees = totalTrees + 5;








Integer sandwichesCost = 10;
Intger sandwichesCost *= 5;





Integer cokes = 10;
cokes = cokes + 1;
cokes += 1;

cokes--;



Integer pepsi = 5;
Integer cokes = 6;

Boolean areTheyEqual = pepsi == cokes;

system.debug('Are they Equal:::::???? '+areTheyEqual );






String myName = 'salesforce';
String myBrotherName = 'SALESFORCE';

Boolean result = myName.equalsIgnoreCase(myBrotherName);
Boolean result2 = 'salesforce'.equals('SALESFORCE');

system.debug('Case is Ingored +++++++'+result);
system.debug('Case is not ignored++++++ '+result2);
