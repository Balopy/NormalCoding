//
//  main.c
//  Structure
//
//  Created by 王春龙 on 2019/11/16.
//  Copyright © 2019 王春龙. All rights reserved.
//

#include <stdio.h>
#include <time.h>

double functionX(int n, double a[], double x)  {
    
    int i;
    double p = a[0];
    for (i=0; i<n; i++) {
        p += (a[i] * pow(x, i));
    }
    return p;
}

clock_t start, stop;

double duration;

int main(int argc, const char * argv[]) {
    
    double p[100];
    
    for (int i = 0; i < 100; i ++) {
        p[i] = double(i)
    }
    functionX(10, &p, 10);
    
    return 0;
}
