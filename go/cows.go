package main

import (
    "fmt"
    "math/rand"
	"time"
	"strconv"
)


/*
func main_check(given_string string, result string) (bool, int, int) {
	if given_string == result {
		return true, 4, 4
	} else {
		after_given := ""
		after_result := ""
		cows := 0
		bulls := 0
		for i := 0; i < len(given_string); i++ {
			if given_string[i] == result[i] {
				bulls++
			} else {
				after_given = after_given + given_string[i:i + 1]
				after_result = after_result + result[i:i + 1]
			}
		}
		for i := 0; i < len(after_given); i++ {
			for j := 0; j < len(after_result); j++ {
				if after_given[i] == after_result[j] {
					fmt.Println("cowing")
					cows++
					after_result = after_result[0:j] + after_result[j+1: len(after_result)]
					j = 5
				}
			}
		}
		return false, cows, bulls
	}
}*/

func bull_check(given_string string, result string) (int) {
	bulls := 0
	if given_string == result {
		return 4
	} else {
		for i := 0; i < len(given_string); i++ {
			if given_string[i] == result[i] {
				bulls++
			}
		}
		return bulls
	}
}

func cow_check(given_string string, result string) (int) {
	cows := 0
	result_copy := result
	for i := 0; i < len(given_string); i++ {
		for j:= 0; j < len(result_copy); j++ {
			if given_string[i] == result_copy[j] {
				cows++
				result_copy = result_copy[0:j] + result_copy[j + 1:len(result_copy)]
				j = len(result_copy)
			}
		}
	}
	return cows
}

func main() {
	rand.Seed(time.Now().UnixNano())
    min := 0
    max := 10000
    rightAnswer := fmt.Sprintf("%04d\n", strconv.Itoa(rand.Intn(max - min + 1) + min))[11:15]
	fmt.Println(rightAnswer)
	check := false
	for check == false {
		fmt.Print("Enter number: ")
    	var input string
		fmt.Scanln(&input)
		fmt.Println()
		bull_res := bull_check(input, rightAnswer)
		if bull_res == 4 {
			fmt.Println("YOU GOT IT RIGHT!")
			check = true		
		} else {
			cows_res := cow_check(input, rightAnswer)
			fmt.Println("Wrong answer, you got ", cows_res - bull_res, " amount of cows and ", bull_res, " amount of bulls")
		}
	}
}

