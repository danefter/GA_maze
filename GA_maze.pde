// Dan Jensen gr17

import java.util.HashSet;
// Maze image
PImage mazeImg; 

//***SET CROSSOVERRATE TO 0 FOR STOCHASTIC BEAM***//

// Mutation and crossover rates for the genetic algorithm
float mutationRate = 0.5; // Chance that any vector in the chromosome gets mutated
float crossoverRate = 0.5; // Chance that any chromosome gets crossover

Population pop;
boolean wallsMade;
boolean mazeOver = false;

HashSet<Wall> walls = new HashSet<>();
PVector finish = new PVector(435, 790);

int maxGenerations = 100;
int finishedIndividuals;

// Constants for different crossover operators
final int SINGLEFIXED = 0;
final int SINGLERELATIVE = 1;
final int UNIFORM = 2;
int crossover = 1;

// Constants for different mutation operators
final int UNIFORMMUTATE = 0;
final int SWAPMUTATE = 1;
int mutate = 1;

// Constants for different strategies
final int GA = 0;
final int OPTIMALGA = 1;
final int STOCHASTIC = 2; //SET TO THIS FOR STOCHASTIC BEAM
int strategy = 1;

// Parameter for the fitness function
// How much the population values distance from start or center
// versus how much distance towards the goal is valued
// to avoid local optima 
float adjustmentValue = 0.01;


// Starting position for GA the individuals in the population
PVector gaStartPos = new PVector(350, 600);

// Starting position for the individuals in the population
PVector originalStartPos = new PVector(350, 10);


// Point to avoid for learning
PVector avoidPoint = originalStartPos;

//Time to for maze completion
float time;

  void setup() {
    size(800, 795);
    frameRate(100);
    smooth();
    noStroke();
    mazeImg = loadImage("maze1.png");
    makeWalls();
    printOptions();
    if (strategy == GA) {originalStartPos = gaStartPos;}
    println("****** Press SPACE to start ******");
  }


  void printOptions(){
    println("****** SET CROSSOVERRATE TO 0 FOR STOCHASTIC BEAM ******");
    println("****** Press 1, 2, or 3 to change crossover operator ******");
    println("****** Press 4 or 5 to change mutation operator ******");
    println("****** Press 6 for GA or 7 for \"OPTIMAL GA\" strategy ******");
    println("****** Press UP or DOWN to adjust mutation rate ******");
    println("****** Press LEFT or RIGHT to adjust crossover rate ******");
    println("****** Press Z or X to adjust fitness value: ******");    
  }

  //Continue next generations recursively
  void draw() {  
    image(mazeImg, 0, 0);
    drawWalls();
    if (pop != null && ((strategy != GA && !pop.allDone) || strategy == GA)){  
      update();
      pop.checkFinished();
    }        
    if (pop != null && pop.allDone && strategy != GA){
     text("Finish time: "+ ((pop.finalTime - time)/1000) +" seconds", width-300,height-30);
     text("Finished Individuals: "+pop.finishedIndividuals, 100, height-30);
   }
   ellipse(finish.x,finish.y, 10, 10);
   fill(255,0,0);
  }
  
  void update(){   
      if(!pop.checkDone()) {
          pop.updateIndividuals();
          pop.showIndividuals();
      } else {
          pop.calculateFitness();
          pop.runNaturalSelection();
          pop.mutate();
      }
      showData();
    }



  //ADDED
  void keyPressed() {  
        switch (key){
          case 49:
             crossover = 0;
             break;
         case 50:
             crossover = 1;
             break;
          case 51:
             crossover = 2;
             break;
          case 52:
             mutate = 0;
             break;
          case 53:
             mutate = 1;
             break;
          case 54:
             strategy = 0;
             break;
         case 55:
             strategy = 1;
             break;
         }
         switch (keyCode){
         case DOWN:
             mutationRate -= 0.05;
             if (mutationRate <= 0) mutationRate = 0;
             break;
         case UP:
             mutationRate += 0.05;
             if (mutationRate >= 1)  mutationRate = 1;
             break;
         case LEFT:
             crossoverRate -= 0.05;
             if (crossoverRate <= 0) crossoverRate = 0;
             break;
         case RIGHT:
             crossoverRate += 0.05;
             if (crossoverRate >= 1)  crossoverRate = 1;
             break;
         case 90:
             if (adjustmentValue > 1) {adjustmentValue -= 1;}
             if (adjustmentValue <= 1) {adjustmentValue -= 0.005;}
             if (adjustmentValue <= 0){adjustmentValue = 0.001;}
             break;
         case 88:
             if (adjustmentValue > 1)  {adjustmentValue += 1;}
             if (adjustmentValue <= 1)  {adjustmentValue += 0.005;}
             if (adjustmentValue >= 10){adjustmentValue = 10;}
             break;   
         case 32:
             pop = new Population(50, originalStartPos);
             break;
         }
  }

  //ADJUSTED
  void showData() {
     textSize(14);
     fill(0);
     textAlign(LEFT);
     textSize(20);
     textAlign(RIGHT);
     text("Crossover Rate: "+crossoverRate, width-250,25);
     text("Mutation Rate: "+mutationRate, width-250,45);
     text("Crossover: " + getCrossover(), width-50,25);
     text("Mutation: " + getMutation(), width-50,45);
     if (strategy == GA){ text("Max Steps: "+pop.maxSteps, width-100, height-20);}
     if (strategy != GA){ text("Max Generations: "+ maxGenerations, width-100, height-20);}
     textAlign(LEFT);
     text("Individuals: "+pop.individuals.length, 100, height-20);
     text("Temperature Value: "+(adjustmentValue), 50,25);
     text("Generation: "+pop.gen, 50,45);
     text("Strategy: "+getStrategy(), 50,65);
  }

  //ADJUSTED
  void makeWalls() {
    for (int i = 0; i <= 800; i++) {
      for (int j = 0; j <= 800; j++) {
        int mazeVal = int(brightness(mazeImg.get(i, j)));
        if (mazeVal == 0) {
          Wall wall = new Wall(10, 10, i, j);
          walls.add(wall);
        }
      }
    }
    }
  
  //ADDED
  void drawWalls() {
      for (Wall wall: walls){
          fill(0,0,255);
          rect(wall.X, wall.Y, wall.W, wall.H);
      }
  }   
    
   //ADDED
   String getCrossover(){
       switch (crossover){
         case 0:
           return "Fixed";
         case 1:
           return "Relative";
         case 2:
           return "Uniform";
         default:
           return "Fixed";
       }
   }
   
   //ADDED
   // Shows strategy
   String getStrategy(){
       if (strategy == GA) {return "GA";}
       if (strategy == OPTIMALGA && crossoverRate == 0) {return "Stochastic Beam";}
       return "Optimal GA";      
   }
   
   //ADDED
   // Shows mutation operator
   String getMutation(){
       if (mutate == UNIFORMMUTATE) {return "Uniform";}
       return "Swap";
   }
   
