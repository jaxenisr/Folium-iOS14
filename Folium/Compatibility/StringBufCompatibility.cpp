//
//  StringBufCompatibility.cpp
//  Folium
//
//  iOS 14's libc++ does not export basic_stringbuf::str(). The app is linked
//  against a newer libc++ that leaves it undefined, so dyld aborts before main.
//  Provide the out-of-line member here so the symbol resolves inside the app.
//

#include <sstream>
#include <string>

namespace std {
inline namespace __1 {

template <>
basic_string<char, char_traits<char>, allocator<char>>
basic_stringbuf<char, char_traits<char>, allocator<char>>::str() const {
    using string_type = basic_string<char, char_traits<char>, allocator<char>>;

    if (this->pbase() != nullptr && this->pptr() != nullptr) {
        return string_type(this->pbase(), this->pptr());
    }

    if (this->eback() != nullptr && this->egptr() != nullptr) {
        return string_type(this->eback(), this->egptr());
    }

    return string_type();
}

} // namespace __1
} // namespace std
