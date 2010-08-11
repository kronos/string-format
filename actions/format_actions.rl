%%{
  machine format;

	action emit {
		str.append(p, 1);
	}

	action clear {
    std::cout << "clear" << std::endl;
		flags = 0;
		width = 0;
		prec = 0;
    type = 0;
    arg  = 0;
    star_num = 0;
    position = 0;
    precision = -1;
	}

  # action finish_ok {
  # }
  # action finish_err {
  #   printf("EOF IN FORMAT\n");
  # }
  # action err_char {
  #   printf("ERROR ON CHAR: 0x%x\n", fc );
  # }

  action done {
    return String::create(state, str.c_str());
  }

  action flags_space {
    flags |= SPACE_FLAG;
  }

  action flags_position {
    if (flags & POSITION_FLAG) {
      ss << "value given twice - ";
      ss << position;
      ss << '$';
      std::string error = ss.str();
      ss.clear();
      Exception::argument_error(state, error.c_str());
    } else {
      flags |= POSITION_FLAG;
    }
  }

  action flags_alternative {
    flags |= ALTERNATIVE_FLAG;
  }

  action flags_minus {
    flags |= MINUS_FLAG;
  }

  action flags_plus {
    flags |= PLUS_FLAG;
  }

  action flags_zero {
    flags |= ZERO_FLAG;
  }

  action star_arg {
    flags |= STAR_ARG_FLAG;
  }

  action flags_star {
    if (flags & STAR_FLAG) {
      Exception::argument_error(state, "width given twice");
    } else {
      flags |= STAR_FLAG;
    }
  }

  action width_flag {
    flags |= WIDTH_FLAG;
  }

  action width_arg_flag {
    flags &= ~WIDTH_FLAG;
    flags |=  WIDTH_ARG_FLAG;
  }

  action check_star {
    if (flags & STAR_FLAG) {
      fnext no_width;
    } else  if (fc != '*') {
      fhold;
    }
  }

  action precision_arg_flag {
    flags |= PRECISION_ARG_FLAG;
    flags &= ~PRECISION_STAR_FLAG;
  }

  action precision_star_flag {
    flags |= PRECISION_STAR_FLAG;
  }

  action zero_precision {
    precision = 0;
  }

  action precision_flag {
    flags |= PRECISION_FLAG;
  }

  action fetch_arg_width_precision {
    width_present = (flags & WIDTH_EXISTS_FLAG) != 0;
    precision_present = (flags & PRECISION_EXISTS_FLAG) != 0;

    if(flags & POSITION_FLAG) {
      arg = args->get(state, position);
    }

    if(width_present) {
      retrieve_width(tmp);
      width = int_value;
    }

    if (precision_present) {
      retrieve_precision(tmp);
      precision = int_value;
    }

    if((flags & POSITION_FLAG) == 0) {
      retrieve_arg(arg);
    }

    fhold;
  }

  action position_num  { position  = 10 * position + (fc-'0'); }
  action width_num     { width     = 10 * width + (fc-'0'); }
	action precision_num { precision = 10 * precision + (fc-'0'); }

  action b {}
}%%