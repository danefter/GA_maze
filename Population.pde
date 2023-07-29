// Dan Jensen gr17

import java.util.Arrays;

class Population {
   
   Individual[] individuals;
   int bestIndividualNo;
   int worstIndividualNo;
   int gen = 1;
   int maxSteps = 10000;
   float fitnessSum = 0;
   Individual bestIndividual;
   Individual worstIndividual;
   boolean allDone = false;
   float finalTime;
   int finishedIndividuals = 0;

    // Class constructor, creates an array of individuals with the given size, all starting from the same position
    Population(int size, PVector startPos) {
        time = millis();
        individuals = new Individual[size];
        for(int i = 0; i < individuals.length; i++) {
            individuals[i] = new Individual(startPos); 
        }
    }
    
    //ADJUSTED
   // Updates all individuals in the population
   // GA tries to optimize so maxSteps determine death
   void updateIndividuals() {
      for(int i = 0; i < individuals.length; i++) {
         if(individuals[i].chromosome.steps > maxSteps && strategy == GA) {
            individuals[i].dead = true; 
         } else {
           individuals[i].update(); 
         }
      }
    }

   
   // Displays all individuals in the population
   void showIndividuals() {
      for(int i = 1; i < individuals.length; i++) {
         individuals[i].show(); 
      }
      individuals[0].show();
   }
   
   //ADJUSTED
   // Finds the individual with the best fitness score
   void setBestIndividual() {
      float max = 0;
      int maxIndex = 0;
      for(int i = 0; i < individuals.length; i++) {
         if(individuals[i].fitness > max) {
            max = individuals[i].fitness;
            maxIndex = i;
         }
      }
      bestIndividualNo = maxIndex;
      bestIndividual = individuals[bestIndividualNo];
      println("Gen: "+gen+" Best Fitness: "+bestIndividual.fitness *100000);      
      // GA tries to optimize so maxSteps determine death
      if (individuals[bestIndividualNo].reachedFinish && individuals[bestIndividualNo].chromosome.steps < maxSteps){
        maxSteps = individuals[bestIndividualNo].chromosome.steps;
      }
   }
   
   //ADDED
   // Finds the individual with the worst fitness score
   void setWorstIndividual() {
      float max = bestIndividual.fitness;
      int minIndex = 0;
      for(int i = 0; i < individuals.length; i++) {
         if(individuals[i].fitness < max) {
            max = individuals[i].fitness;
            minIndex = i;
         }
      }
      worstIndividualNo = minIndex;
      worstIndividual = individuals[worstIndividualNo];
      println("Gen: "+gen+" Worst Fitness: "+ worstIndividual.fitness *100000);  
   }
   
   
   
   //ADDED
   //Check for final time
   void checkFinished(){
       int finished = 0;
       for(int i = 0; i < individuals.length; i++) {
            if(individuals[i].reachedFinish){
               finished++;       
           }      
          }
          if(finished >= individuals.length/2) {
            finishedIndividuals = finished;
            finalTime = millis();
            allDone = true;
            maxGenerations = gen;
      }
      if (pop.gen >= maxGenerations){
          allDone = true;
          finalTime = millis();
      }
   }
   
   // Checks if all individuals have either died or reached the finish
   boolean checkDone() {
      for(int i = 0; i < individuals.length; i++) {
         if(!individuals[i].dead && !individuals[i].reachedFinish)
           return false;  
      }
      return true;
   }
   
   //ADJUSTED
   // Selects the individuals to be part of the next generation
   void runNaturalSelection() {
      printOptions();
      println("****** Press SPACE to restart ******");
      Individual[] newIndividuals = new Individual[individuals.length];
      setBestIndividual();
      setWorstIndividual();
      adjustCrossover();
      adjustDiversity(); 
      calculateFitnessSum(); 
      newIndividuals[0] = individuals[bestIndividualNo].clone(bestIndividual.pos);
      newIndividuals[0].isBest = true;
      for(int i = 1; i < individuals.length; i++) {
         Individual parent = selectIndividual();
         newIndividuals[i] = crossover(bestIndividual, parent);
      }
      individuals = newIndividuals.clone();
      gen+=1;
   }
   
   // Selects an individual for reproduction based on fitness score
   // Variant of roulette-wheel selection
   Individual selectIndividual() {
      float  rand = random(fitnessSum);
      float runningSum = 0;
      for(int i = 0; i < individuals.length; i++) {
         runningSum += individuals[i].fitness;
         if(runningSum > rand)
           return individuals[i];
      }
      return individuals[0];
   }
   
   
      //ADDED
   //Adjust the fitness if ilocal optima found
   void adjustTemp(){
     if (crossoverRate > 0) { // IF NOT SET FOR STOCHASTIC BEAM
       if (bestIndividual.atLocalOptimum()) {
         avoidPoint = bestIndividual.pos;
         if (adjustmentValue > 0.01) {
              adjustmentValue -= 0.01;
          }      
       }
       if (!bestIndividual.atLocalOptimum()){
            if (strategy == GA) avoidPoint = worstIndividual.pos;
            if (adjustmentValue < 1){
            adjustmentValue += 0.01;}
       }
       }
     }
     
    //ADDED
   //Adjust the mutation if more individuals are simply following the best individual
   void adjustDiversity(){
     int lackOfDiversity = 0;
     for(int i = 0; i < individuals.length; i++) {
         if ((PVector.dist(individuals[i].pos, bestIndividual.pos) <= PVector.dist(individuals[i].pos, worstIndividual.pos)) && !individuals[i].reachedFinish) lackOfDiversity++;
      }
        if (lackOfDiversity >= individuals.length*mutationRate && mutationRate < 1){ 
            mutationRate += 0.01;
            // UNIFORM MUTATION OPERATOR promotes higher randomization of genes
            if (mutationRate >= 0.25) {mutate = UNIFORMMUTATE;}  
        }
        else if (lackOfDiversity < individuals.length*mutationRate && mutationRate > 0.01){               
                mutationRate -= 0.01;
                //SWAP MUTATION OPERATOR promotes randomization through swap, most genes may remain unchanged
                if (mutationRate < 0.25) {mutate = SWAPMUTATE;}        
          }
     }
     
     //ADDED
   //Adjust the crossover if more individuals at local optimum
     void adjustCrossover(){
       if (crossoverRate > 0) { // IF NOT SET FOR STOCHASTIC BEAM
       int optima = 0;
     for(int i = 0; i < individuals.length-1; i++) {
         if (individuals[i].atLocalOptimum() && !individuals[i].reachedFinish) optima++;
      }
        if (optima > individuals.length*crossoverRate && crossoverRate > 0.01) {
              crossoverRate -= 0.01;
              adjustTemp();
              //UNIFORM OPERATOR will promote higher randomization, as genetic material is shared uniformly
              if (crossoverRate < 0.25) {crossover = UNIFORM;} 
          }
       else if (optima < individuals.length*crossoverRate && crossoverRate < 1){ 
            crossoverRate += 0.01;    
            //SINGLE POINT RELATIVE OPERATOR will keep slightly less of the genetic material of the bestIndividual, splitting exactly in half
            if (crossoverRate >= 0.25 && crossoverRate <= 0.5) {crossover = SINGLERELATIVE;}  
            //SINGLE POINT FIXED OPERATOR will keep more of the genetic material of the bestIndividual, promoting following by splitting at a random point
            if (crossoverRate > 0.5) {crossover = SINGLEFIXED;}  
       }
       }
     }
     
   // Mutates the chromosomes of all individuals
   void mutate() {
      for(int i = 0; i < individuals.length; i++) {
         individuals[i].chromosome.mutate();
      }
   }
   
   // Calculates the sum of the fitness scores of all individuals
   void calculateFitnessSum() {
     for(int i = 0; i < individuals.length; i++) {
         fitnessSum += individuals[i].fitness; 
      }
   }
   
   // Calculates the fitness score of all individuals
   void calculateFitness() {
      for(int i = 0; i < individuals.length; i++) {
         individuals[i].calculateFitness(); 
      }
   }
   
   //ADDED
   // Performs crossover between two parents to produce a child, based on crossover rate
   Individual crossover(Individual p1, Individual p2){
      float rand = random(1);
      if (rand <= crossoverRate && crossoverRate > 0) {
       switch (crossover){
         case 0:
           return crossoverFixed(p1,  p2);
         case 1:
           return crossoverRelative(p1, p2);
         case 2:
           return crossoverUniform(p1, p2);          
       }
      }
      //Return best individual if GA and no crossover
      if (strategy == GA && rand > crossoverRate){
        Individual i = new Individual();
        i.chromosome = p1.chromosome.clone();
        return i;
      }
      if (crossoverRate == 0){ //SET FOR STOCHASTIC BEAM
      return p2.clone(p1.pos);} //return random individual with best as starting point
      
      return p1.clone(p1.pos); //return best individual with best final point as starting point
   }
   
   //ADDED
   // Performs fixed single-point crossover
   Individual crossoverFixed(Individual p1, Individual p2){
     
     //Individuals start at death position
     Individual offspring = p1.clone(p1.pos);
     
     //If using GA, individuals start at start position
     if (strategy == GA){
       offspring = new Individual(originalStartPos);}
      
      // Random point for crossover.
      int randp1 = (int)random(p1.getChromosomeLength());
      
      // Copy genes from p1 up to the crossover point
       for(int i = 0; i < randp1; i++) {
         offspring.chromosome.genes[i] = p1.chromosome.genes[i].copy(); 
      }
      
      // Copy genes from p2 from the crossover point
      for(int i = randp1; i < p1.getChromosomeLength(); i++) {
         offspring.chromosome.genes[i] = p2.chromosome.genes[i].copy(); 
      }
      return offspring;
   }
   
   //ADDED
   // Performs relative single-point crossover
   Individual crossoverRelative(Individual p1, Individual p2){
     //Individuals start at death position
     Individual offspring = p1.clone(p1.pos);
     
     //If using GA, individuals start at start position
     if (strategy == GA){
       offspring = new Individual(originalStartPos);}
      
    // Relative point for crossover.
    int crossPoint = p1.getChromosomeLength() / 2;
    // Copy genes from p1 up to the crossover point
    for(int i = 0; i < crossPoint; i++) {
      offspring.chromosome.genes[i] = p1.chromosome.genes[i].copy(); 
    }
    // Copy genes from p2 from the crossover point
    for(int i = crossPoint; i < p1.getChromosomeLength(); i++) {
      offspring.chromosome.genes[i] = p2.chromosome.genes[i].copy(); 
    }  
    return offspring;
  }

  //ADDED
  // Performs uniform crossover
  Individual crossoverUniform(Individual p1, Individual p2) {
      //Individuals start at death position
     Individual offspring = p1.clone(p1.pos);
     
     //If using GA, individuals start at start position
     if (strategy == GA){
       offspring = new Individual(originalStartPos);}
      
     // Loop through each gene in the chromosome
    for (int i = 0; i < p1.getChromosomeLength(); i++) {
        // Randomly choose genes from either p1 or p2
        // If the random number is less than 0.5, take the gene from p1
        // otherwise, take the gene from p2
        if (random(1) < 0.5) {
            offspring.chromosome.genes[i] = p1.chromosome.genes[i].copy();
        } else {
            offspring.chromosome.genes[i] = p2.chromosome.genes[i].copy();
        }
    } 
    return offspring;
    }

}
