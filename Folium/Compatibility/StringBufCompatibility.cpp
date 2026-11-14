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

#include <cstdarg>
#include <cstdio>
#include <cstdlib>
#include <sstream>
#include <string>

std::string folium_legacy_stringbuf_str(const std::basic_stringbuf<char>& buffer)
    __asm__("__ZNKSt3__115basic_stringbufIcNS_11char_traitsIcEENS_9allocatorIcEEE3strEv");

std::string folium_legacy_stringbuf_str(const std::basic_stringbuf<char>& buffer) {
    return buffer.str();
}

// libc++ hardening added __libcpp_verbose_abort after iOS 14. The prebuilt
// cores reference it through the SDK headers, but iOS 14's libc++.1.dylib does
// not export it. Keep the fatal-abort behaviour under the legacy mangled name.
[[noreturn]] void folium_legacy_verbose_abort(const char* format, ...)
    __asm__("__ZNSt3__122__libcpp_verbose_abortEPKcz");

[[noreturn]] void folium_legacy_verbose_abort(const char* format, ...) {
    va_list arguments;
    va_start(arguments, format);
    vfprintf(stderr, format, arguments);
    va_end(arguments);
    fputc('\n', stderr);
    fflush(stderr);
    abort();
}
