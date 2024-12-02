// ~/~ begin <<docs/day01.md#rust/src/bin/day01.rs>>[init]
use std::io;
use std::num::{ParseIntError};
use itertools::Itertools;

#[derive(Debug)]
enum Error {
    IO(io::Error),
    ParseInt(ParseIntError)
}

fn read_integer_pair(line: &str) -> Result<Vec<u32>, Error> {
    line.split(' ').map(|x| x.parse::<u32>()).collect::<Result<Vec<u32>, _>>().map_err(Error::ParseInt)
}

fn main() -> Result<(), io::Error> {
    let input: Vec<Vec<u32>> = io::stdin().lines().map(read_integer_pair).collect::<Result<Vec<_>, _>>()?;
    println!("{:?}", input);
    Ok(())
}
// ~/~ end
