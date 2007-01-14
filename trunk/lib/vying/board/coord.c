#include "ruby.h"
#include "coord.h"

/* Coord method definitions */

VALUE coord_initialize( VALUE self, VALUE x, VALUE y ) {
  rb_iv_set( self, "@x", x );
  rb_iv_set( self, "@y", y );
}

VALUE coord_x( VALUE self ) {
  rb_iv_get( self, "@x" );
}

VALUE coord_y( VALUE self ) {
  rb_iv_get( self, "@y" );
}

VALUE coord_class_subscript( int argc, VALUE *argv, VALUE self ) {
  if( argc == 2 && FIXNUM_P(argv[0]) && FIXNUM_P(argv[1]) ) {
    return rb_funcall( Coord, rb_intern("new"), 2, argv[0], argv[1] );
  }
  else if( argc == 1 ) {
    return rb_funcall( Coord, rb_intern("new"), 2,  
                       rb_funcall( argv[0], rb_intern("x"), 0 ),
                       rb_funcall( argv[0], rb_intern("y"), 0 ) );
  }
  else {
    VALUE ary = rb_ary_new2( argc );
    int i;
    for( i = 0; i < argc; i++ ) {
      rb_ary_push( ary, 
        rb_funcall( Coord, rb_intern("new"), 2, 
                    rb_funcall( argv[i], rb_intern("x"), 0 ),
                    rb_funcall( argv[i], rb_intern("y"), 0 ) ) );
    }
    return ary;
  }

  return Qnil;
}

VALUE coord_hash( VALUE self ) {
  VALUE ary = rb_ary_new3( 2, coord_x( self ), coord_y( self ) );
  return rb_funcall( ary, rb_intern( "hash" ), 0 );
}

VALUE coord_equals( VALUE self, VALUE obj ) {
  if( rb_respond_to( obj, rb_intern("x") ) && 
      rb_respond_to( obj, rb_intern("y") ) &&
      coord_x( self ) == rb_funcall( obj, rb_intern("x"), 0 ) &&
      coord_y( self ) == rb_funcall( obj, rb_intern("y"), 0 ) ) {
    return Qtrue;
  }
  return Qfalse;
}

VALUE coord_addition( VALUE self, VALUE obj ) {
  return rb_funcall( Coord, rb_intern("new"), 2,
    INT2NUM(NUM2INT(coord_x(self))+NUM2INT(rb_funcall(obj,rb_intern("x"),0))),
    INT2NUM(NUM2INT(coord_y(self))+NUM2INT(rb_funcall(obj,rb_intern("y"),0))));
}

VALUE coord_direction_to( VALUE self, VALUE obj ) {
  int dx = NUM2INT(coord_x(self))-NUM2INT(rb_funcall( obj, rb_intern("x"), 0 ));
  int dy = NUM2INT(coord_y(self))-NUM2INT(rb_funcall( obj, rb_intern("y"), 0 ));

  if( dx == 0 ) {
    if( dy > 0 ) {
      return ID2SYM(rb_intern("n"));
    }
    else if( dy < 0 ) {
      return ID2SYM(rb_intern("s"));
    }
  }
  else if( dy == 0 ) {
    if( dx > 0 ) {
      return ID2SYM(rb_intern("w"));
    }
    else if( dx < 0 ) {
      return ID2SYM(rb_intern("e"));
    }
  }
  else if( dx == dy ) {
    if( dx < 0 && dy < 0 ) {
      return ID2SYM(rb_intern("se"));
    }
    else if( dx > 0 && dy > 0 ) {
      return ID2SYM(rb_intern("nw"));
    }
  }
  else if( -dx == dy ) {
    if( dx > 0 && dy < 0 ) {
      return ID2SYM(rb_intern("sw"));
    }
    else if( dx < 0 && dy > 0 ) {
      return ID2SYM(rb_intern("ne"));
    }
  }

  return Qnil;
}

