#include <_string.h>
#include <stdio.h>
#include "main.h"
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
enum terrain {LAND, WATER, COAST};
struct province {
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
    int plnum;
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
struct move {
    struct piece p;
    struct province dst;
};
struct support_move {
    struct piece p;
    struct move supported;
};
struct support_hold {
    struct piece p_supporter;
    struct piece p_supported;
};
struct convoy {
    struct piece p;
    struct move mv;
};
struct hold {
    struct piece p;
};
// Use stresp to parse orders
int main(int argc, char** argv){
    char* province_names[5] = {"abc","def","ghi","jkl","mno"}; //generate province names
    // generate this from parsing a file or something also
    struct province p0 = {true, COAST, 1};
    struct province p1 = {false, WATER, 1};
    struct province p2 = {true, LAND, 1};
    struct province p3 = {false, COAST, 1};
    struct province p4 = {true, LAND, 1};
    struct province plist[5] = {p0, p1, p2, p3, p4};

    // read a list of orders separated by newlines
    char* move_order = (char *)malloc(50);
    fgets(move_order, 50, stdin);
    char *argvec[5];
    int len = 0;
    for(int i = 0; i < 5; i++){
        char* orig_str = strsep(&move_order, " ");
        argvec[i] = orig_str;
        len++;
        if(move_order == NULL){
            break;
        }
    }
    for(int j = 0; j < len; j++){
        printf("%s\n", argvec[j]);
    }
    return 0;
}
