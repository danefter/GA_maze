// Dan Jensen gr17

class Chromosome {
   // Genes, represented as vectors
   PVector[] genes;

   // Number of steps taken
   int steps = 0;
  
   // Constructor for Chromosome
   // Creates a new chromosome with a certain size and random genes
   Chromosome(int size) {
     genes = new PVector[size];
     randomize();
   }
   
   // Assigns each gene a random vector
   void randomize() { 
      for(int i = 0; i < genes.length; i++) {
         float randomAngle = random(2*PI); 
         genes[i] = PVector.fromAngle(randomAngle);
      }
   }
   
   // Creates a copy of this chromosome
   Chromosome clone() {
      Chromosome clone = new Chromosome(genes.length);
      for(int i = 0; i < genes.length; i++) {
         clone.genes[i] = genes[i].copy(); 
      }
      return clone;
   }
   
   //ADDED
   // Performs crossover between two parents to produce a child, based on crossover rate
   void mutate(){
      if (mutate == UNIFORMMUTATE){
          mutateUniform();
      }
      else{
        mutateSwap();
      }
   }
   
   
   // Mutates the chromosome using uniform mutaion
   void mutateUniform() {
    for (int i = 0; i < genes.length; i++) {
      float rand = random(1);
      if (rand < mutationRate) {
        float randomAngle = random(2*PI);
        genes[i] = PVector.fromAngle(randomAngle);
      }
    }
  }
  
  // Mutates the chromosome using swap mutaion
  void mutateSwap() {
    for (int i = 0; i < genes.length; i++) {
        float rand = random(1);
        if (rand < mutationRate) {
            // Choose a second index different from i
            int index2 = i;
            while (index2 == i) {
                index2 = (int)random(genes.length);
            }          
            // Swap genes[i] and genes[index2]
            PVector temp = genes[i];
            genes[i] = genes[index2];
            genes[index2] = temp;
        }
    }
}
}
