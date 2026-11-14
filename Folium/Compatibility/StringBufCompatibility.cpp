//
//  StringBufCompatibility.cpp
//  Folium
//
//  Some prebuilt C++ libraries in the app were built against an older libc++
//  and reference basic_stringbuf::str() with the pre-ref-qualifier mangling.
//  iOS 14's libc++ and the newer SDK headers only provide str() const&, so the
//  old symbol remains undefined and dyld aborts before main. Export the legacy
//  symbol as a C function and forward it to the current implementation.
//

#include <sstream>
#include <string>

extern "C" std::string folium_legacy_stringbuf_str(const std::basic_stringbuf<char>& buffer)
    __asm__("__ZNKSt3__115basic_stringbufIcNS_11char_traitsIcEENS_9allocatorIcEEE3strEv");

extern "C" std::string folium_legacy_stringbuf_str(const std::basic_stringbuf<char>& buffer) {
    return buffer.str();
}
