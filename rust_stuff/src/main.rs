use std::{cmp::max, vec};

fn max_number<T>(v: &[T], n: T) -> T
where
    T: std::cmp::Ord + std::clone::Clone,
{
    match v {
        [] => n,
        [fst, rest @ ..] => max_number(rest, max(fst.clone(), n)),
    }
}
struct Point<T> {
    x: T,
    y: T,
}
impl Point<f32> {
    fn distance_from_origin(&self) -> f32 {
        (self.x.powi(2) + self.y.powi(2)).sqrt()
    }
}
pub trait Summary {
    fn summarize(&self) -> String;
}
pub struct NewsArticle {
    pub headline: String,
    pub location: String,
    pub author: String,
    pub content: String,
}

impl Summary for NewsArticle {
    fn summarize(&self) -> String {
        format!("{}, by {} ({})", self.headline, self.author, self.location)
    }
}

pub struct Tweet {
    pub username: String,
    pub content: String,
    pub reply: bool,
    pub retweet: bool,
}

impl Summary for Tweet {
    fn summarize(&self) -> String {
        format!("{}: {}", self.username, self.content)
    }
}
pub fn notify(item: &impl Summary) {
    println!("Breaking news! {}", item.summarize());
}
fn main() {
    let number_list = vec![34, 50, 17, 49, 1, 73, 42];
    let max_num = max_number(&number_list, 0);
    let float_point = Point { x: 1.3, y: 5.7 };
    let point_dist = float_point.distance_from_origin();
    println!("{max_num}, {point_dist}")
}

/*
    let mut scores = HashMap::new();

    scores.insert(String::from("Blue"), 10);
    scores.insert(String::from("Yellow"), 50);
    let _field_name = String::from("Favorite color");
    let _field_value = String::from("Blue");

    let mut hmap = HashMap::new();
    let mut nums = vec![5, 2, 6, 81, 2, 4, 9];
    nums.sort();
    println!("{nums:?}");
    let length = nums.len();
    if length % 2 == 0 {
        let med = (&nums[(length / 2) - 1] + nums[length / 2]) / 2;
        println!("{med}");
    }
    if length % 2 == 1 {
        let med = &nums[(length - 1) / 2];
        println!("Median: {med}");
    }
    for num in &nums {
        let key = num.to_string();
        let val = hmap.get(&key).copied();
        match val {
            Some(n) => hmap.insert(key, n + 1),
            None => hmap.insert(key, 1),
        };
    }
    let mut max = 0;
    let mut mode = 0;
    for num in &nums {
        let key = num.to_string();
        let val = hmap.get(&key).copied();
        match val {
            Some(n) => {
                if n > max {
                    mode = *num;
                    max = n;
                }
            }
            None => max = 0,
        }
    }
    println!("Mode: {mode}");
*/
