
#![allow(clippy::stable_sort_primitive)]



fn unnecessary_sort_by() {
    fn id(x: isize) -> isize {
        x
    }
    let mut vec: Vec<isize> = vec![3, 6, 1, 2, 5];
    // Forward examples
    vec.sort();
    vec.sort_unstable();
    vec.sort_by_key(|a| (a + 5).abs());
    vec.sort_unstable_by_key(|a| id(-a));
}

fn main() {
    unnecessary_sort_by();
}
