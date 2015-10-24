import java.util.Arrays;
import java.util.Collections;
import java.util.ArrayList;

String[] phrases; //contains all of the phrases
int totalTrialNum = 4; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final float centerX = 157.5;//320 * 480
final float centerY = 77.5;
final float keyBoardCenterX = centerX;
final float keyBoardCenterY = centerY;
final float nextButtonX = 350;
final float nextButtonY = 70;
final float nextButtonSize = 100;
final String[] characters  = {"␣ <-", "abc","def","ghi","jkl","mno","pqrs","tuv","wxyz"};
final float targetX = 70;
final float targetY = 50;
final float enteredX = 70;
final float enteredY = 70;

final int DPIofYourDeviceScreen = 165; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
                                      //http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
boolean selectCharacter = false;
//Variables for my silly implementation. You can delete this:
char currentLetter = 'a';
class Button{
  float buttonX;
  float buttonY;
  float buttonWidth;
  float buttonHeight;
  String cs;
  boolean currentButton = false;
  public Button(float buttonX, float buttonY, float buttonWidth, float buttonHeight, String cs){
    this.buttonX = buttonX;
    this.buttonY = buttonY;
    this.buttonWidth = buttonWidth;
    this.buttonHeight = buttonHeight;
    this.cs = cs;
  }
}
ArrayList<Button> buttons;
ArrayList<Button> cButtons
//You can modify anything in here. This is just a basic implementation.
void setup()
{
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases)); //randomize the order of the phrases
  buttons = new ArrayList<Button>();
  cButtons = new ArrayList<Button>();
  orientation(LANDSCAPE); //can also be LANDSCAPE -- sets orientation on android device
  size(1000, 1000); //Sets the size of the app. You may want to modify this to your device. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("Arial", 16)); //set the font to arial 24
  noStroke(); //my code doesn't use any strokes.
  int count = 0;
  for (int j = 0; j < 3; j ++){
    for (int i = 0; i < 3; i ++){
        String chars = characters[count];
        buttons.add(new Button(keyBoardCenterX + (sizeOfInputArea / 3 ) * i, keyBoardCenterY + (sizeOfInputArea/3) * j, sizeOfInputArea/3, sizeOfInputArea/3, chars));
        count++;
    }
  }
  for (int i = 0; i < 3; i++){
    cButtons.add(new Button(keyBoardCenterX + (sizeOfInputArea/3) * i), keyBoardCenterY+ (sizeOfInputArea/3), sizeOfInputArea/3, sizeOfInputArea/3, ""));
  }
  //manually put one extra button below those three just in case
  cButtons.add(new CButton(keyBoardCenterX + (sizeOfInputArea/3), keyBoardCenterY + (sizeOfInputArea /3 ), sizeOfInputArea/3, sizeOfInputArea/3));
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(0); //clear background

 // image(watch,-200,200);
  fill(100);
  rect(centerX, centerY, sizeOfInputArea, sizeOfInputArea); //input area should be 2" by 2"

  if (finishTime!=0)
  {
    fill(255);
    textAlign(CENTER);
    text("Finished", centerX, centerY);
    return;
  }

  if (startTime==0 & !mousePressed)
  {
    fill(255);
    textAlign(CENTER);
    text("Click to start time!", centerX, centerY); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    //you will need something like the next 10 lines in your code. Output does not have to be within the 2 inch area!
    textAlign(LEFT); //align the text left
    fill(128);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 20); //draw the trial count
    fill(255);
    text("Target:   " + currentPhrase, targetX, targetY); //draw the target string
    text("Entered:  " + currentTyped, enteredX, enteredY); //draw what the user has entered thus far
    fill(124,252,0);
    rect(nextButtonX, nextButtonY, nextButtonSize, nextButtonSize/2); //drag next button
    fill(0);
    text("NEXT > ", nextButtonX + 20, nextButtonY + 20); //draw next label
    fill(169,169,169);
    rect(nextButtonX, nextButtonY + nextButtonSize, nextButtonSize, nextButtonSize/2);
    fill(255);
    text("PREV < ", nextButtonX + 20, nextButtonY + nextButtonSize + 20);

    //drawing the 9*9 grid
    if (selectCharacter){
      for (CButton b : cButtons){
        fill(255, 255, 204);
        rect(b.buttonX, b.buttonY, b.buttonWidth, b.buttonHeight);
        fill(0);
        text(b.character, b.buttonX + sizeOfInputArea/6, b.buttonY + sizeOfInputArea/6);
      }
    }else{
      for (Button b : buttons){
          if (!b.currentButton){
            fill(255, 255, 204);
          }else{
            fill(127,255,0);
          }
          rect(b.buttonX, b.buttonY, b.buttonWidth, b.buttonHeight); //draw left red button
          fill(0,0,0);
          text(b.cs,b.buttonX + sizeOfInputArea/6, b.buttonY + sizeOfInputArea/6);
      }
    }
    // fill(0, 255, 0);
    // rect(200+sizeOfInp utArea/2, 200+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2); //draw right green button
  }

}

boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}


void mouseDragged()
{
  if()
  //need two stages
  //if in characterSelection mode,
  //display three-four button based on which one is selection
  //else

  for (Button b : buttons){
    if (didMouseClick(b.buttonX, b.buttonY, b.buttonWidth, b.buttonHeight)){
      b.currentButton = true;
    }else{
        // fill(255, 255, 204);
        // rect(b.buttonX,b.buttonY,b.buttonWidth,b.buttonHeight);
      b.currentButton = false;
    }
  }
  // if (didMouseClick(200, 200+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2)) //check if click in left button
  // {
  //   currentLetter --;
  //   if (currentLetter<'_') //wrap around to z
  //     currentLetter = 'z';
  // }
  //
  // if (didMouseClick(200+sizeOfInputArea/2, 200+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2)) //check if click in right button
  // {
  //   currentLetter ++;
  //   if (currentLetter>'z') //wrap back to space (aka underscore)
  //     currentLetter = '_';
  // }
  //
  // if (didMouseClick(200, 200, sizeOfInputArea, sizeOfInputArea/2)) //check if click occured in letter area
  // {
  //   if (currentLetter=='_') //if underscore, consider that a space bar
  //     currentTyped+=" ";
  //   else if (currentLetter=='`' & currentTyped.length()>0) //if `, treat that as a delete command
  //     currentTyped = currentTyped.substring(0, currentTyped.length()-1);
  //   else if (currentLetter!='`') //if not any of the above cases, add the current letter to the typed string
  //     currentTyped+=currentLetter;
  // }

  //You are allowed to have a next button outside the 2" area
}
void mousePressed(){
  if (didMouseClick(nextButtonX, nextButtonY, nextButtonX + nextButtonSize, nextButtonY + nextButtonSize/2)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }

}
void mouseReleased(){
  //need two stages
  //if in characterSelection mode,
  //add character to the

  for (Button b: button){
    if(b.currentButton){
      selectCharacter = true;

      b.currentButton = false;
    }

  }
}


void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

    if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.length();
    lettersEnteredTotal+=currentTyped.length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output
    System.out.println("WPM: " + (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f)); //output
    System.out.println("==================");
    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  }
  else
  {
    currTrialNum++; //increment trial number
  }

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}




//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}
