use std::collections::HashMap;
fn main() {
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
}
