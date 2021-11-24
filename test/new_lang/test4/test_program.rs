#[path = "../../out/rust/splashkit.rs"]
mod splashkit;
use splashkit::*;

fn main() {
  
  let mut i : i32 = 10;
  let mut f : f32 = 1.11;
  let mut d : f64 = 2.22;
  let mut sh : i16 = -3;
  let mut ush : u16 = 4;
  let mut l : i64 = 5;
  let mut ch : char = 'a';
  let mut uch : u8 = 66;
  let mut b : bool = true;
  let mut ui : u32 = 50;

  println!("i is {}", i);
  println!("get and update {} now {}", get_and_update_int(&mut i), i);

  println!("i is {}", i);
  update_int(&mut i);
  println!("Updated int: {}", i);

  println!("ui is {}", ui);
  update_uint(&mut ui);
  println!("Updated ui: {}", ui);

  println!("f is {}", f);
  update_float(&mut f);
  println!("Updated ui: {}", f);

  // print!(ui, end=" ")
  // update_uint(ui)
  // print!("Updated uint: ", ui)

  // print!(sh, end=" ")
  // update_short(sh)
  // print!("Updated short int: ", sh)

  // print!(ush, end=" ")
  // update_ushort(ush)
  // print!("Updated short int: ", ush)

  // print!(f, end=" ")
  // update_float(f)
  // print!("Updated float: ", f)

  // print!(d, end=" ")
  // update_double(d)
  // print!("Updated double: ", d)

  // print!(l, end=" ")
  // update_long(l)
  // print!("Updated long: ", l)

  // print!(ch, end=" ")
  // update_char(ch)
  // print!("Updated char: ", ch)

  // print!(uch, end=" ")
  // update_uchar(uch)
  // print!("Updated char: ", uch)

  // print!(b, end=" ")
  // update_bool(b)
  // print!("Updated bool: ", b)
}