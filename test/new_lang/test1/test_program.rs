// #[link(name = "SplashKit")]
// extern "C" { pub fn __sklib__say_yay () ; }

// fn say_yay() {
//   unsafe {
//     __sklib__say_yay();
//   }
// }

#[path = "../../out/rust/splashkit.rs"]
mod splashkit;
use splashkit::say_yay;

fn main() {
  say_yay();
}