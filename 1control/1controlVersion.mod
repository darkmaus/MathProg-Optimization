
/* Data about network */

/* set of Nodes */


set N ;  
param procdelay {N}, >0 ; /* Process delay of the nodes */
param costN {N}, >0 ; /* Cost of the node */


/* reading data from table*/
table node_data_table IN "CSV" "data_nodes.csv":
N <- [NODE_NAME], procdelay~procdelay, costN~costN;


/* set of Controllers */
set C ;
param nameC {C}, symbolic ;
param weightC {C}, >0 ; /* Weight of the controller */
param costC {C} , >0 ; /* Cost of the controller */

/* set of NFV */
set NF ;
param nameNF {NF}, symbolic ;
param costNF {NF}, >0 ; /* Cost of the NFV */


/* set of links with dimen 2 source&destination */
set L, dimen 2 ;  
param capacity {L}, >=0; 	/* Capacity of the link */
param weight {L}, >=0; 		/* Weight of the link */
param delay {L}, >0; 		/* We put some delay in a link */
param bwcontrol {L}, >0; 		/* Bandwidth of the traffic control */


/* reading data from table*/
table link_data_table IN "CSV" "data_links.csv":
L <- [FROM,TO], capacity~capacity, weight~weight, delay~delay, bwcontrol~bwcontrol;


/* Data about traffic demand */
set dd;
param source{dd}, symbolic, in N; 	/* source */
param destination{dd}, symbolic, in N; 	/* destination */ 
param step {dd};
param demand{dd}; 			/* traffic demand */
param dweight{dd};			/* weight demmand*/

/* reading data from table*/
table demand_data_table IN "CSV" "data_demand.csv":
dd <- [DEMAND_NUMBER], source~source, destination~destination, demand~demand, dweight~dweight;

/* Decision Variables */
var y{L} >=0, binary ; /*  */
var f{L,dd},  >=0, binary;

param w, symbolic := "camino.csv";


/* OBJECTIVE FUNCTION */

minimize COST: sum{(i,j) in L} ( y[i,j] * ( delay[i,j] + procdelay[i] ) ) ;


s.t. FLOW_CONSERVATION{i in N,  k in dd: i not in C}:
   sum{(j,i) in L: j not in C} f[j,i,k] + (if i = source[k] then 1)  =
   sum{(i,j) in L: j not in C} f[i,j,k] + (if i = destination[k] then 1);


s.t. PASS_THROUGH_NF{k in dd}:
   sum{(i,j) in L: i in NF || j in NF}f[j,i,k] = 2;
 
/* Capacity constraint */
s.t. CAPACITY{(i,j) in L}:
    sum{k in dd}f[i,j,k]*demand[k] <= y[i,j]*capacity[i,j] ;

/* Bandwidth control constraint */
s.t. BWC{(i,j) in L}:
    sum{k in dd}f[i,j,k]*(demand[k] + bwcontrol[i,j] ) <= y[i,j]*capacity[i,j] ;

############################################################################
solve;
printf "		*** Total cost: %d \n\n", COST;
printf "\n";

for {k in dd}{
	printf "Used links in demand %d  (%s--%s):\n", k,source[k],destination[k];
	printf "%s,", source[k] >> w;
	for {(i,j) in L: i != j  &&  f[i,j,k]!=0 }{
		 printf "				%s -- %s \n", i, j;
		printf "%s,", i >> w;
		
  } 
printf "%s,", destination[k] >> w;
printf "\n" >> w;
printf "\n";
}
printf "\n";
/*printf "	Total delay of the total paths (delay and process delay):\n";
printf "			%d", sum{(i,j) in L} ( y[i,j] * ( delay[i,j] + procdelay[i] ) ) ;
#printf "weight\n";
#printf "%d", sum{(i,j) in L} ( y[i,j] * ( weight[i,j]) ) ;
#printf "\n";
#printf "%d", sum{(i,j) in L, k in dd} (y[i,j]*dweight[k]) ;
printf "\n";
printf "\n";
printf "\n";
printf "	Sum of the nodes that has to cross the flow: \n";
printf "			%d", sum{(i,j) in L} (y[i,j]*costN[i]) ;
printf "\n";
printf "\n";
printf "\n";
printf "	Total network inversion:\n";
printf "			%d", sum{ i in N} (costN[i]) ;
printf "\n";
printf "\n";
printf "\n";
printf "	Total network cost(media): \n";
printf "			%d", sum{ i in N} ((costN[i])/5) ;
printf "\n";
*/
printf "\n";
############################################################################
/* INPUT DATA, values for the parameters. */
data;

set C:= CONTROL, CONTROL2, CONTROL3;
set NF:= NFV, NFV2, NFV3;

end ;

