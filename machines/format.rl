%%{
  machine format;

  include "format_actions.rl";
	non_zero_number = [1-9] [0-9]*;
  zero_number = [0-9]+;

  b = 'b' @b;
  flags = (non_zero_number $(position_num,0) $position_num '$' >flags_position
           | ' ' @flags_space
           | '#' @flags_alternative
           | '+' @flags_plus
           | '-' @flags_minus
           | '0' @flags_zero
           | '*' @flags_star (non_zero_number $(position_num,1) $width_num '$' @width_arg_flag)? )+ ;

  width      = [0-9*] >check_star (non_zero_number $width_num '$' @width_arg_flag
                                          | zero_number $width_num >width_flag
                                          | '*' @flags_star) ;

  precision  = no_width: '.' >zero_precision ('*' @precision_star_flag (non_zero_number $precision_num '$' @precision_arg_flag)?
                                               | non_zero_number $precision_num '$' >precision_arg_flag
                                               | zero_number $precision_num >precision_flag);
  directives = [bcdEefGgiopsuXx] >fetch_arg_width_precision b; # | c | d | E | e | f | G | g | i | o | p | s | u | X | x;
  fmt_spec   = '%' @clear flags width precision directives;
  main := ( ([^%] @emit | '%%' @emit | fmt_spec) )* %done;# @/finish_err %/finish_ok $!err_char;

}%%

  %% write data;
  %% write init;
  %% write exec;

// Field |  Conversion
// ------+--------------------------------------------------------------
//   b   | Convert argument as a binary number.
//   c   | Argument is the numeric code for a single character.
//   d   | Convert argument as a decimal number.
//   E   | Equivalent to `e', but uses an uppercase E to indicate
//       | the exponent.
//   e   | Convert floating point argument into exponential notation
//       | with one digit before the decimal point. The precision
//       | determines the number of fractional digits (defaulting to six).
//   f   | Convert floating point argument as [-]ddd.ddd,
//       |  where the precision determines the number of digits after
//       | the decimal point.
//   G   | Equivalent to `g', but use an uppercase `E' in exponent form.
//   g   | Convert a floating point number using exponential form
//       | if the exponent is less than -4 or greater than or
//       | equal to the precision, or in d.dddd form otherwise.
//   i   | Identical to `d'.
//   o   | Convert argument as an octal number.
//   p   | The valuing of argument.inspect.
//   s   | Argument is a string to be substituted. If the format
//       | sequence contains a precision, at most that many characters
//       | will be copied.
//   u   | Treat argument as an unsigned decimal number. Negative integers
//       | are displayed as a 32 bit two's complement plus one for the
//       | underlying architecture; that is, 2 ** 32 + n.  However, since
//       | Ruby has no inherent limit on bits used to represent the
//       | integer, this value is preceded by two dots (..) in order to
//       | indicate a infinite number of leading sign bits.
//   X   | Convert argument as a hexadecimal number using uppercase
//       | letters. Negative numbers will be displayed with two
//       | leading periods (representing an infinite string of
//       | leading 'FF's.
//   x   | Convert argument as a hexadecimal number.
//       | Negative numbers will be displayed with two
//       | leading periods (representing an infinite string of
//       | leading 'ff's.