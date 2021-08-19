#[path = "../../out/rust/splashkit.rs"]
mod splashkit;
use splashkit::*;

fn main() {
  println!("{}", get_int());
  println!("{}", get_int_with_initial_value(1));
  println!("{}", get_uint(2));
  println!("{}", get_short(3));
  println!("{}", get_ushort(4));
  println!("{}", get_float(5.55));
  println!("{}", get_double(6.66));
  println!("{}", get_long(7));
  println!("{}", get_char('A'));
  println!("{}", get_uchar('a'));
  println!("{}", get_bool(true));
  println!("{}", get_bool(false));
}
