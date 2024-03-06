#include <iostream>

#include "GitHash.hpp"

int main() {
    std::cout << "Branch:     " << GitHash::branch << '\n';
    std::cout << "Sha1:       " << GitHash::sha1 << '\n';
    std::cout << "Short sha1: " << GitHash::shortSha1 << '\n';
    std::cout << "Dirty?      " << GitHash::dirty << '\n';
    std::cout << "Combined:   " << GitHash::shortSha1 << (GitHash::dirty ? "-dirty" : "") << '\n';

    return 0;
}
