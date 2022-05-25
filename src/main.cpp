#include <iostream>

#include "GitHash.hpp"

int main() {
    std::cout << GitHash::branch << '\n';
    std::cout << GitHash::sha1 << '\n';
    std::cout << GitHash::shortSha1 << '\n';
    std::cout << GitHash::dirty << '\n';
    std::cout << GitHash::shortSha1 << (GitHash::dirty ? "-dirty" : "") << '\n';

    return 0;
}
