// g++ -g -O0 -o ex ex.cpp
#include <bits/stdc++.h>
using namespace std;

void hello() {
    int x = 1;
    /*cout << x << endl;*/
    cout << "Hello" << endl;
}

int main(int argc, char* argv[]) {
    for (int i = 0; i < argc; i++) {
        cout << argv[i] << endl;
    }
    vector<int> v(10);
    iota(v.begin(), v.end(), 0);
    string s = "hello world";
    int x;
    cin >> x;
    cout << x << endl;
    hello();
    return 0;
}
