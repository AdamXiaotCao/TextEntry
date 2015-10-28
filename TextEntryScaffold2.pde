import java.util.*;
import java.util.Map.Entry;


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
final String[] characters  = {"␣ DEL", "abc","def","ghi","jkl","mno","pqrs","tuv","wxyz"};
final float targetX = 70;
final float targetY = 50;
final float enteredX = 70;
final float enteredY = 70;
String currentWord = "";
final int DPIofYourDeviceScreen = 165; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
char[] currentChars = new char[4];
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
//start of trie
class Trie {

    protected final Map<Character, Trie> children;
    protected String value;
    protected boolean terminal = false;

    public Trie() {
        this(null);
    }

    private Trie(String value) {
        this.value = value;
        children = new HashMap<Character, Trie>();
    }

    protected void add(char c) {
        String val;
        if (this.value == null) {
            val = Character.toString(c);
        } else {
            val = this.value + c;
        }
        children.put(c, new Trie(val));
    }

    public void insert(String word) {
        if (word == null) {
            throw new IllegalArgumentException("Cannot add null to a Trie");
        }
        Trie node = this;
        for (char c : word.toCharArray()) {
            if (!node.children.containsKey(c)) {
                node.add(c);
            }
            node = node.children.get(c);
        }
        node.terminal = true;
    }

    public String find(String word) {
        Trie node = this;
        for (char c : word.toCharArray()) {
            if (!node.children.containsKey(c)) {
                return "";
            }
            node = node.children.get(c);
        }
        return node.value;
    }

    public Collection<String> autoComplete(String prefix) {
        Trie node = this;
        for (char c : prefix.toCharArray()) {
            if (!node.children.containsKey(c)) {
                return Collections.emptyList();
            }
            node = node.children.get(c);
        }
        return node.allPrefixes();
    }

    protected Collection<String> allPrefixes() {
        List<String> results = new ArrayList<String>();
        if (this.terminal) {
            results.add(this.value);
        }
        for (Entry<Character, Trie> entry : children.entrySet()) {
            Trie child = entry.getValue();
            Collection<String> childPrefixes = child.allPrefixes();
            results.addAll(childPrefixes);
        }
        return results;
    }
}

//end of trie
Button leftSuggestButton;
Button rightSuggestButton;
ArrayList<Button> buttons;
ArrayList<Button> cButtons;
// ArrayList<String> possibleWords;
BufferedReader reader;
Trie prefixTrie;
void readWords(){
  reader = createReader("count_1w.txt");
  String line = null;
  try{
    while ((line = reader.readLine()) != null) {
      String[] splitted = line.split("\\s+");
      prefixTrie.insert(splitted[0]);
    }
  }catch(IOException e){
    e.printStackTrace();
  }
}

void updateCurrentButton(){
  if(currentWord.length() > 1){
    leftSuggestButton.cs = "";
    rightSuggestButton.cs = "";
    Collection<String> suggestted = prefixTrie.autoComplete(currentWord);
    Iterator<String> it = suggestted.iterator();
    String suggesttedW = "";
    System.out.println("currentword is "+ currentWord);
    System.out.println("suggested");
    while(it.hasNext()){
      suggesttedW = it.next();
      if(suggesttedW.length() > currentWord.length()){
        if(leftSuggestButton.cs.equals("")){
          leftSuggestButton.cs = suggesttedW;
        }else if (rightSuggestButton.cs.equals("")){
          rightSuggestButton.cs = suggesttedW;
        }else{
          break;
        }
      }
    }
    System.out.println("suggesttedW is "+ suggesttedW);
  }else if (currentWord.length() == 0){
    leftSuggestButton.cs = "the";
    rightSuggestButton.cs = "of";
  }else{
    leftSuggestButton.cs = "";
    rightSuggestButton.cs = "";
  }
}
//You can modify anything in here. This is just a basic implementation.
void setup()
{
  prefixTrie = new Trie();
  // possibleWords = new ArrayList<String>();
  readWords();
  System.out.println("Done with reading words");
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases)); //randomize the order of the phrases
  buttons = new ArrayList<Button>();
  cButtons = new ArrayList<Button>();
  orientation(LANDSCAPE); //can also be LANDSCAPE -- sets orientation on android device
  size(1000, 1000); //Sets the size of the app. You may want to modify this to your device. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("Arial", 16)); //set the font to arial 24
  noStroke(); //my code doesn't use any strokes.
  int count = 0;
  leftSuggestButton = new Button(keyBoardCenterX, keyBoardCenterY, sizeOfInputArea/2, sizeOfInputArea/4,"");
  rightSuggestButton = new Button(keyBoardCenterX+sizeOfInputArea/2, keyBoardCenterY, sizeOfInputArea/2, sizeOfInputArea/4,"");
  for (int j = 0; j < 3; j ++){
    for (int i = 0; i < 3; i ++){
        String chars = characters[count];
        buttons.add(new Button(keyBoardCenterX + (sizeOfInputArea / 3 ) * i, keyBoardCenterY + (sizeOfInputArea/4) * j + sizeOfInputArea/4, sizeOfInputArea/3, sizeOfInputArea/4, chars));
        count++;
    }
  }
  for (int i = 0; i < 3; i++){
    cButtons.add(new Button(keyBoardCenterX + (sizeOfInputArea/3) * i, keyBoardCenterY+ (sizeOfInputArea/3), sizeOfInputArea/3, sizeOfInputArea/3, ""));
  }
  //manually put one extra button below those three just in case
  cButtons.add(new Button(keyBoardCenterX + (sizeOfInputArea/3), keyBoardCenterY + 2*(sizeOfInputArea /3 ), sizeOfInputArea/3, sizeOfInputArea/3,""));
  //TODO add auto completion
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
    text("Entered: " + currentTyped + "_", enteredX, enteredY); //draw what the user has entered thus far
    fill(124,252,0);
    rect(nextButtonX, nextButtonY, nextButtonSize, nextButtonSize/2); //drag next button
    fill(0);
    text("NEXT > ", nextButtonX + 20, nextButtonY + 20); //draw next label
    fill(169,169,169);
    rect(nextButtonX, nextButtonY + nextButtonSize, nextButtonSize, nextButtonSize/2);
    //fill(255);
    //text("PREV < ", nextButtonX + 20, nextButtonY + nextButtonSize + 20);

    if (selectCharacter){
      // draw 3*1 + 1 grid
      for (int i = 0; i < cButtons.size(); i++){

        Button b = cButtons.get(i);
        if(!b.currentButton){
          fill(255, 255, 204);
        }else{
          fill(127,255,0);
        }
        rect(b.buttonX, b.buttonY, b.buttonWidth, b.buttonHeight);
        fill(0);
        text(b.cs, b.buttonX + sizeOfInputArea/6, b.buttonY + sizeOfInputArea/6);
      }
    }else{

    //drawing the 9*9 grid
      if(!leftSuggestButton.currentButton){
        fill(255, 255, 204);
      }else{
        fill(127,255,0);
      }
      rect(leftSuggestButton.buttonX, leftSuggestButton.buttonY, leftSuggestButton.buttonWidth-1, leftSuggestButton.buttonHeight);
      fill(0);
      textAlign(CENTER);
      text(leftSuggestButton.cs, leftSuggestButton.buttonX + 20, leftSuggestButton.buttonY + 20);

      if(!rightSuggestButton.currentButton){
        fill(255, 255, 204);
      }else{
        fill(127,255,0);
      }
      rect(rightSuggestButton.buttonX, rightSuggestButton.buttonY, rightSuggestButton.buttonWidth, rightSuggestButton.buttonHeight);
      fill(0);
      textAlign(CENTER);
      text(rightSuggestButton.cs, rightSuggestButton.buttonX + 20, rightSuggestButton.buttonY + 20);

      for (Button b : buttons){
          if (!b.currentButton){
            fill(255, 255, 204);
          }else{
            fill(127,255,0);
          }
          rect(b.buttonX, b.buttonY, b.buttonWidth, b.buttonHeight); //draw left red button
          fill(0,0,0);
          textAlign(CENTER);
          text(b.cs,b.buttonX + sizeOfInputArea/6 - 5, b.buttonY + sizeOfInputArea/6);
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
  // if()
  //need two stages
  //if in characterSelection mode,
  //display three-four button based on which one is selection
  //else
  if(selectCharacter){
    //update character button
    for (Button cb: cButtons){
      if (didMouseClick(cb.buttonX, cb.buttonY, cb.buttonWidth, cb.buttonHeight)){
        cb.currentButton = true;
      }else{
          // fill(255, 255, 204);
          // rect(b.buttonX,b.buttonY,b.buttonWidth,b.buttonHeight);
        cb.currentButton = false;
      }
    }
  }else{
    //update number pad button
    if(didMouseClick(leftSuggestButton.buttonX, leftSuggestButton.buttonY, leftSuggestButton.buttonWidth, leftSuggestButton.buttonHeight)){
      leftSuggestButton.currentButton = true;
      rightSuggestButton.currentButton = false;
      for (Button b: buttons){
        b.currentButton = false;
      }
    }else if (didMouseClick(rightSuggestButton.buttonX, rightSuggestButton.buttonY, rightSuggestButton.buttonWidth, rightSuggestButton.buttonHeight)){
      leftSuggestButton.currentButton = false;
      rightSuggestButton.currentButton = true;
      for (Button b: buttons){
        b.currentButton = false;
      }
    }
    else{
      leftSuggestButton.currentButton = false;
      rightSuggestButton.currentButton = false;
      for (Button b : buttons){
        if (didMouseClick(b.buttonX, b.buttonY, b.buttonWidth, b.buttonHeight)){
          b.currentButton = true;
        }else{
            // fill(255, 255, 204);
            // rect(b.buttonX,b.buttonY,b.buttonWidth,b.buttonHeight);
          b.currentButton = false;
        }
      }
    }
  }
}
void mousePressed(){
  if (didMouseClick(nextButtonX, nextButtonY, nextButtonX + nextButtonSize, nextButtonY + nextButtonSize/2)) //check if click is in next button
  {
    currentWord = "";
    leftSuggestButton.currentButton = false;
    rightSuggestButton.currentButton = false;
    nextTrial(); //if so, advance to next trial
  }

}
void mouseReleased(){
  //need two stages
  //if in characterSelection mode,
  //add character to the
  if (startTime!= 0){
    if(selectCharacter){
      selectCharacter = false;
      //update the current phrase;
      //add the input
      //need to work on the auto complete
      for (Button b : cButtons){
        if(b.currentButton){
            b.currentButton = false;
          if(b.cs.equals("␣")){
            currentTyped += " ";
            currentWord = "";
            updateCurrentButton();
            //TODO update suggestWord;
          }else if (b.cs.equals("DEL")){
            currentTyped = currentTyped.substring(0, currentTyped.length()-1);
            String[] currentWords = currentTyped.split("\\s+");
            if(currentWords.length>0){
              currentWord = currentWords[currentWords.length-1];
            }else{
              currentWord = "";
            }
            updateCurrentButton();
            //TODO update suggestWord
          }else{
            String c = b.cs;
            currentWord += c;
            updateCurrentButton();
            currentTyped += c;
          }
        }
      }

    }else{
      if (leftSuggestButton.currentButton && (leftSuggestButton.cs.length() > 0)){

        currentTyped += leftSuggestButton.cs.substring(currentWord.length());
        currentTyped += " ";
        currentWord = "";
        updateCurrentButton();
      }else if (rightSuggestButton.currentButton && (rightSuggestButton.cs.length() > 0)){
        currentTyped += rightSuggestButton.cs.substring(currentWord.length());
        currentTyped += " ";
        currentWord = "";
        updateCurrentButton();
      }
      for (Button b: buttons){
        if(b.currentButton){
          selectCharacter = true;
          b.currentButton = false;
          if(b.cs.equals("␣ DEL")){
            cButtons.get(0).cs = "␣";
            cButtons.get(1).cs = "DEL";
            cButtons.get(2).cs = "";
            cButtons.get(3).cs = "";
          }else{
            char[] chars = b.cs.toCharArray();
            //prepare the cbuttons
            for(int i = 0; i < chars.length; i++){
              Button cb = cButtons.get(i);
              cb.cs = String.valueOf(chars[i]);
            }
            if (chars.length < cButtons.size()){
              for (int i = chars.length; i< cButtons.size(); i++){
                cButtons.get(i).cs = "";
              }
            }
          }
        }
      }
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
    System.out.println("WPM: " + (lettersEnteredTotal/5.5f)/((finishTime - startTime)/60000f)); //output
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
// //TODO
// prevTrial(){
//
// }



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