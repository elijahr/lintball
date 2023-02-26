
#![allow(clippy::stable_sort_primitive)]

use std::cmp::Reverse;

fn unnecessary_sort_by() {
    fn id(x: isize) -> isize {
        x
    }
    let mut vec: Vec<isize> = vec![3, 6, 1, 2, 5];
    // Forward examples
    vec.sort_by(|a, b| a.cmp(b));
    vec.sort_unstable_by(|a, b| a.cmp(b));
    vec.sort_by(|a, b| (a + 5).abs().cmp(&(b + 5).abs()));
    vec.sort_unstable_by(|a, b| id(-a).cmp(&id(-b)));
}

fn main() {
    unnecessary_sort_by();
}
