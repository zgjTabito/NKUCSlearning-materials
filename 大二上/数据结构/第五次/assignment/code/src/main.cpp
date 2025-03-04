#include <iostream>
#include <vector>
#include <unordered_map>
#include <algorithm>

using namespace std;



int main() {
    int N, M, K;
    cin >> N >> M >> K;

    unordered_map<int, int> mp;
    for (int i = 0; i < N; ++i) {
        int x = 0;
        int ct = 0;
        for (int j = 0; j < M; ++j) {
            int a = 0;
            cin >> a;
            x=x << 1;
            x += a;
            if (a == 0)ct++;
        }
        if (K>=ct && ct % 2 == K % 2)
        {
            if (mp.find(x) == mp.end())
                mp[x] = 1;
            else
                mp[x]++;
        }
        
    }
    int maxct=0;
    for (auto i = mp.begin();i != mp.end();i++)
        maxct = maxct > i->second ? maxct : i->second;
    cout << maxct;
    
   

    return 0;
}
