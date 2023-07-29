// Dan Jensen gr17

import java.util.ArrayList;

class Individual {
  PVector pos, vel, acc, start;
  PVector lastPosition = new PVector(0, 0);
  int stagnation = 0;
  
  float r = 6;
  boolean dead = false;
  boolean reachedFinish = false;
  boolean isBest = false;
  float fitness;
  // Genetic information
  Chromosome chromosome;
  
  //ADJUSTED
  // Constructor for OPTIMALGA
  // Creates a new individual at the provided start position
  Individual(PVector startPos) {
    start = startPos.copy();
    pos = startPos.copy();    
    vel = new PVector(0,0);
    acc = new PVector(0,0);
    chromosome = new Chromosome(500);
  }

  //ADDED
  // Constructor for GA
  // Creates a new individual at the original start position
  Individual() {
      start = originalStartPos.copy();
      pos = originalStartPos.copy();    
      vel = new PVector(0,0);
      acc = new PVector(0,0);
      chromosome = new Chromosome(500);
      finish = new PVector(435, 790);
  }

  //ADJUSTED
  // Check if the individual has collided with any wall
  boolean checkCollisions() {
    for (Wall wall: walls){
      if(wall.checkCollision(pos.x+r,pos.y+r) || wall.checkCollision(pos.x-r,pos.y+r) || wall.checkCollision(pos.x+r,pos.y-r) || wall.checkCollision(pos.x-r,pos.y-r)){
        return true;
      }
    }
    return false;
  }
 
  //ADJUSTED
  // Check if the individual has exited the area
  boolean checkExit(){
    if((pos.x-r <= 0 || pos.x+r >= width || pos.y+r >= height || pos.y-r <= 0) && !checkReachedFinish()){
      return true;
    }
    return false;
  }
  
  //ADJUSTED
  // Correct the individual's position if it collides with a wall
  void fixCollision() {
    for (Wall wall: walls){
      if(wall.checkCollision(pos.x+r,pos.y+r)){
        pos.set(pos.x-r, pos.y-r);
      } 
      if(wall.checkCollision(pos.x-r,pos.y+r)){
        pos.set(pos.x+r, pos.y-r);
      }
      if(wall.checkCollision(pos.x+r,pos.y-r)){
        pos.set(pos.x-r, pos.y+r);
      }
      if(wall.checkCollision(pos.x-r,pos.y-r)){
        pos.set(pos.x+r, pos.y+r);
      }
    }
  }
  
  //ADJUSTED
  // Check if the individual has reached the finish point
  boolean checkReachedFinish() {
    if (PVector.dist(pos, finish)<= 15) { 
      return true;
    }
    return false;
  }
  
  //ADJUSTED
  // Moves the individual according to its genes
  void move() { 
    if(chromosome.steps < chromosome.genes.length && (strategy == OPTIMALGA || (strategy == GA && !isBest))) {
      acc = chromosome.genes[chromosome.steps];
      chromosome.steps++;
    } else {
      dead = true; 
    }
    vel.add(acc);
    vel.limit(5);
    PVector oldPos = pos.copy();
    pos.add(vel);
    if (PVector.dist(oldPos, pos) < 1 && !reachedFinish) {
      stagnation++;
  }  
  lastPosition = pos.copy();
  }


  // Show the individual on the screen
  void show() {
    rectMode(CENTER);
    if(isBest)
      fill(0,255,0);
    else
      fill(255,0,0);
    ellipse(pos.x + r, pos.y + r, r * 2, r * 2);
  }

  //ADJUSTED
  // Update the individual's position, and check if it has died or reached the finish
  void update() {
    if(!dead && !reachedFinish) {
      move();
      if(checkCollisions() || checkExit()) {
        fixCollision();
        dead = true; 
      }  
      if(checkReachedFinish()) {
        reachedFinish = true; 
        println("reached finish");
        finishedIndividuals++;
        println("finished");
      }
    }
  }

  //ADJUSTED
  // Create a clone of this individual at a specified position
  Individual clone(PVector p) {
    Individual clone = new Individual(p);
    clone.chromosome = chromosome.clone();
    return clone;
  }

   //ADDED
   boolean atLocalOptimum(){
       float distToGoal = PVector.dist(pos, finish);
       float distFromStart = PVector.dist(start, finish);
       float distFromPosToAvoid = PVector.dist(avoidPoint, finish);
       if ((distFromStart < distToGoal || distFromStart < distFromPosToAvoid) && stagnation > 0 && PVector.dist(pos, finish) >= 10 && PVector.dist(pos, originalStartPos) >= 20 && !reachedFinish ){
           return true;
       }
       return false;
   }

  //ADJUSTED
  // Calculate the fitness of this individual based on its distance to the finish and the number of steps taken
  void calculateFitness() {
  float distToGoal = PVector.dist(pos, finish);
  float distFromOrgStart = PVector.dist(pos, originalStartPos);
  float distFromAvoidPoint = PVector.dist(pos, avoidPoint);
  float distFromStart = PVector.dist(pos, start);
  // If the individual reached the finish, give it a high fitness score
  if(reachedFinish && strategy == GA) {
    fitness = chromosome.steps*chromosome.steps * distFromOrgStart; 
  }
  if(reachedFinish && strategy != GA) {
    fitness = pop.gen*pop.gen * distFromOrgStart; 
  }
  else if(reachedFinish) {
    fitness = 1.0/((distFromOrgStart*distToGoal)/(pop.gen*adjustmentValue*adjustmentValue)); 
  }
  else {
    if (atLocalOptimum()){
    // Calculate the fitness based on its distance to the finish and from start
    if (distFromStart >= distFromAvoidPoint){
      fitness = 1.0/((distToGoal*distToGoal)/(distFromStart*adjustmentValue*adjustmentValue)); 
    }
    // Calculate the fitness based on its distance to the finish and from avoided point
    else {
      fitness = 1.0/((distToGoal*distToGoal)/(distFromAvoidPoint*adjustmentValue*adjustmentValue)); 
    }
    }
    else {
      fitness = 1.0/((distToGoal*distToGoal)/(distFromOrgStart*adjustmentValue*adjustmentValue));
    }        
  }
  if (stagnation > 0) {
      fitness /= stagnation;
    }
}

  //ADDED
  // Get the length of the chromosome array
  int getChromosomeLength(){
    return this.chromosome.genes.length;
  }
}
