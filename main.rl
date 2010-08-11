%%{
  machine format;
}%%

#include "vm/config.h"

#include "vm.hpp"
#include "object_utils.hpp"
#include "on_stack.hpp"

#include "builtin/array.hpp"
#include "builtin/exception.hpp"
#include "builtin/float.hpp"
#include "builtin/module.hpp"
#include "builtin/object.hpp"
#include "builtin/string.hpp"

#include <sstream>

namespace rubinius {
  #define SPACE_FLAG          1
  #define POSITION_FLAG       2
  #define ALTERNATIVE_FLAG    4
  #define PLUS_FLAG           8
  #define MINUS_FLAG          16
  #define ZERO_FLAG           32
  #define STAR_FLAG           64

  #define WIDTH_FLAG          128
  #define WIDTH_ARG_FLAG      256
  #define PRECISION_FLAG      512
  #define PRECISION_ARG_FLAG  1024
  #define PRECISION_STAR_FLAG 2048

  #define WIDTH_EXISTS_FLAG (WIDTH_FLAG | WIDTH_ARG_FLAG | STAR_FLAG)
  #define PRECISION_EXISTS_FLAG (PRECISION_ARG_FLAG | PRECISION_STAR_FLAG | PRECISION_FLAG)
  #define BITS_LONG   (RBX_SIZEOF_LONG * 8)

  #define CONVERT_INTEGER(T, v, m, b, n)    \
    if((n)->fixnum_p()) {                   \
      v = (T)STRIP_FIXNUM_TAG(n);           \
    } else {                                \
      Bignum* big = as<Bignum>(n);          \
      big->verify_size(state, b);           \
      v = big->m();                         \
    }

  #define CONVERT_TO_INT(n)   CONVERT_INTEGER(int, int_value, to_int, BITS_LONG, n)

  #define retrieve_arg(var)                                         \
    if (arg_position >= args->size()) {                             \
      Exception::argument_error(state, "you ran out of arguments"); \
    } else {                                                        \
      var = args->get(state, arg_position++);                       \
    }                                                               \

  #define retrieve_width(var)               \
    flag = true;                            \
    if (flags & WIDTH_FLAG) {               \
      int_value = width;                    \
      flag = false;                         \
    } else {                                \
      if (flags & WIDTH_ARG_FLAG) {         \
        var = args->get(state, position);   \
      } else {                              \
        retrieve_arg(var);                  \
      }                                     \
    }                                       \
    if(flag) {                              \
      CONVERT_TO_INT(var);                  \
      if(int_value < 0) {                   \
        int_value = -int_value;             \
        flags |= MINUS_FLAG;                \
      }                                     \
    }                                       \

  #define retrieve_precision(var)         \
    flag = (flags & PRECISION_FLAG) == 0; \
    if(flags & PRECISION_ARG_FLAG) {      \
      var = args->get(state, precision);  \
    } else {                              \
      if (flag) {                         \
        retrieve_arg(var);                \
      } else {                            \
        int_value = precision;            \
      }                                   \
    }                                     \
    if(flag) {                            \
      CONVERT_TO_INT(var);                \
    }                                     \

  String* String::format(STATE, Array* args) {
    bool flag = false;
    bool width_present = false;
    bool precision_present = false;
    int flags = 0;
    int width = 0;
    int prec = 0;
    int type = 0;
    int star_num = 0;
    int position = 0;
    int precision = 0;
    int int_value = 0;
    unsigned arg_position = 0;
    Object* arg, *tmp = NULL;

    std::stringstream ss;
    std::string str("");

    // Ragel-specific variables
    const char *p  = c_str();
    const char *pe = p + size();
    const char *eof = pe;
    int cs;

    %%{
      include "format.rl";
    }%%

    if(format_first_final && format_error && format_en_main){// && format_en_main_fmt_spec_precision) {
      // do nothing
    }

    return force_as<String>(Primitives::failure());
  }
}