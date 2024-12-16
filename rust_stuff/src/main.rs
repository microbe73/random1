fn main() {
    let x = 5;
    let y = x + 1;
    {
        let x = y * 2;
        println!("The value of x in the inner scope is: {x}");
    }
    println!("The value of x is: {y}");
}
