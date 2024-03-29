// RUN: %clang_cc1 -fsyntax-only -verify -Wimplicit-int-conversion -triple x86_64-apple-darwin %s

int test0(long v) {
  return v; // expected-warning {{implicit conversion loses integer precision}}
}

typedef int  int4  __attribute__ ((vector_size(16)));
typedef long long long2 __attribute__((__vector_size__(16)));

int4 test1(long2 a) {
  int4  v127 = a;  // no warning.
  return v127;
}

int test2(long v) {
  return v / 2; // expected-warning {{implicit conversion loses integer precision: 'long' to 'int'}}
}

char test3(short s) {
  return s * 2; // expected-warning {{implicit conversion loses integer precision: 'int' to 'char'}}
}
