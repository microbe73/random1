#include<string.h>
#include<stdio.h>
#include<stdlib.h>
struct textnode {
    char* str;
    int score;
};
#define MAX_SCORE 1000000
struct textnode check_match(char* search, char* given, int len_s, int len_g){
    int i = 0;
    int j = 0;
    int prev_match = 0;
    int score = 0;
    for (j = 0; j < len_g; j++) {
        if (i < len_s - 1){
            // Escape sequences
            if(search[i] == '\\') {
                if(search[i+1] == '*'){
                    score += j - prev_match;
                    prev_match = j;
                    i += 2;
                }
                if(search[i+1] == '\\' && given[j] == '\\'){
                    score += j - prev_match;
                    prev_match = j;
                    i += 2;
                }
                if(search[i+1] == 'd' && given[j] >= 48 && given[j] <= 57){
                    score += j - prev_match;
                    prev_match = j;
                    i += 2;
                }
            }
            else if (search[i] == given[j]) {
                score += j - prev_match;
                prev_match = j;
                i++;
            }
        }
        else{
            if (search[i] == given[j]) {
                    score += j - prev_match;
                    prev_match = j;
                    i++;
            }
        }
    }
    char* str = (char*)malloc(len_g + 1);
    strlcpy(str, given, len_g + 1);
    if( i >= len_s){
        struct textnode t =  {str, score};
        return t;
    }
    else{
        struct textnode t = {str, MAX_SCORE};
        return t;
    }
}
int comp_score (const void* t1, const void* t2){
    struct textnode* T1 = (struct textnode*)t1;
    struct textnode* T2 = (struct textnode*)t2;
    return T1->score > T2->score;
}
void printt(struct textnode t){
    printf("String: %s", t.str);
    printf("Score: %d\n", t.score);
}
void match_on(char* match_with, char* fname, int max_matches){
    FILE* f = fopen(fname, "r");
    char buffer[256];
    struct textnode matched[max_matches];
    int num_matches = 0;
    while (1) {
        char* test_str = fgets(buffer, 256, f);
        if (test_str == 0){
            break;
        }
        struct textnode t = check_match(match_with, buffer, strlen(match_with),
                                        strlen(buffer));
        if (t.score != MAX_SCORE){
            matched[num_matches] = t;
            num_matches++;
        };
        if (num_matches == max_matches){
            break;
        }
    }
    qsort(matched, num_matches, sizeof(struct textnode), comp_score);
    printf("Total matches found: %d\n", num_matches);
    for(int i = 0; i < num_matches; i++){
        printt(matched[i]);
        printf("\n");
        free(matched[i].str);
    }
    fclose(f);
}
int main(int argc, char** argv){
    switch (argc) {
        case 1:
            printf("No pattern given");
            return 1;
        case 2:
            match_on(argv[1], "test.txt", 10);
            break;
        case 3:
            match_on(argv[1], argv[2], 10);
            break;
        default:
            match_on(argv[1], argv[2], atoi(argv[3]));
            break;
    }
    return 0;
}
