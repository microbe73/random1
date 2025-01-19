#include <stdio.h>
#include "main.h"
#include <stdbool.h>
enum terrain {LAND, WATER, COAST};
struct province {
    char* name;
    bool sc;
    enum terrain ter;
    int num_coasts;
};
enum ptype {FLEET, ARMY};
struct player {
    int* pl_id;
    int* sc_count;
    char** name;
};
struct piece {
    int pnum;
    struct province loc;
    int coast;
    enum ptype unit;
};
enum adj {ARMY_ONLY, FLEET_ONLY, ALL_UNITS, FLEET_COAST_1, FLEET_COAST_2};
enum season {SPRING, FALL, WINTER, RETREAT};
int num_provs;
struct game {
    struct province* provinces;
    enum adj** adjacency_matrix;
    int num_players;
    enum season szn;
    int year;
};
// Use stresp to parse orders
int main(int argc, char** argv){
    
}
