package main

import (
	"bufio"
	"fmt"
	"os"
	"reflect"
	"strconv"
	"strings"
)

var int_checker int64

func byteInSlice(a byte, list []byte) bool {
	for _, b := range list {
		if b == a {
			return true
		}
	}
	return false
}

func tokenize(line string) []interface{} {
	slice := strings.Fields(line)
	result := []interface{}{}
	for _, elem := range slice {
		if res, err := strconv.ParseInt(elem, 10, 64); err == nil {
			result = append(result, res)
		} else {
			result = append(result, elem)
		}
	}
	return result
}

/*
func tokenize(line string) []string {
	word_holder := ""
	tokens := []string{}
	separators := [7]byte{40, 41, 43, 45, 47, 42, 110}
	for i := 0; i < len(line); i++ {
		if byteInSlice(line[i], separators[:]) {
			if word_holder == "" {
				tokens = append(tokens, string(line[i]))
			} else {
				tokens = append(tokens, word_holder)
				word_holder = ""
				tokens = append(tokens, string(line[i]))
			}
		} else if line[i] == ' ' {
			if word_holder != "" {
				tokens = append(tokens, word_holder)
				word_holder = ""
			}
		} else {
			word_holder += string(line[i])
		}
	}
	if word_holder != "" {
		tokens = append(tokens, word_holder)
	}
	return tokens
}
*/

func calculate(slice []interface{}) (interface{}, bool) {
	stack := []interface{}{}
	for i := 0; i < len(slice); i++ {
		fmt.Println("stack is ", stack)
		if reflect.TypeOf(slice[i]) == reflect.TypeOf(int_checker) {
			fmt.Println("Got a number")
			stack = append(stack, slice[i])
		} else if slice[i] == "+" {
			fmt.Println("Got a +")
			if len(stack) < 2 {
				return "Missing stack elements for \"+\" function", false
			}
			x := stack[len(stack)-1].(int64)
			y := stack[len(stack)-2].(int64)
			result := y + x
			stack = stack[:len(stack)-2] //Can be optimized by cutting only 1 piece of slice and adding changing the new last piece of slice to the needed result instead of cutting 2 pieces and appending the result
			stack = append(stack, result)
		} else if slice[i] == "-" {
			fmt.Println("Got a -")
			if len(stack) < 2 {
				return "Missing stack elements for \"-\" function", false
			}
			x := stack[len(stack)-1].(int64)
			y := stack[len(stack)-2].(int64)
			result := y - x
			fmt.Println("Stack before cutting is", stack)
			stack = stack[:len(stack)-2] //Can be optimized by cutting only 1 piece of slice and adding changing the new last piece of slice to the needed result instead of cutting 2 pieces and appending the result
			fmt.Println("Stack after cutting is", stack)
			stack = append(stack, result)
			fmt.Println("Stack after adding result is", stack)
		} else if slice[i] == "*" {
			fmt.Println("Got a *")
			if len(stack) < 2 {
				return "Missing stack elements for \"*\" function", false
			}
			x := stack[len(stack)-1]
			y := stack[len(stack)-2]
			result := y.(int64) * x.(int64)
			stack = stack[:len(stack)-2] //Can be optimized by cutting only 1 piece of slice and adding changing the new last piece of slice to the needed result instead of cutting 2 pieces and appending the result
			stack = append(stack, result)
		} else if slice[i] == "/" {
			fmt.Println("Got a /")
			if len(stack) < 2 {
				return "Missing stack elements for \"/\" function", false
			} else if stack[len(stack)-1] == 0 {
				return "You can't divide by zero", false
			}
			x := stack[len(stack)-1]
			y := stack[len(stack)-2]
			result := y.(int64) / x.(int64)
			stack = stack[:len(stack)-2] //Can be optimized by cutting only 1 piece of slice and adding changing the new last piece of slice to the needed result instead of cutting 2 pieces and appending the result
			stack = append(stack, result)
		} /*else if slice[i] == "n" {
			fmt.Println("Got a negative", slice[i], reflect.TypeOf(slice[i]))
			if reflect.TypeOf(slice[i]) != reflect.TypeOf(int_checker) {
				return "Only a number can be negative", false
			} else {
				x := stack[len(stack)-1].(int64) * (-1)
				stack = stack[:len(stack)-1] //Can be optimized to change cutting and appending to just changing the last element to needed value
				stack = append(stack, x)
			}
		}*/
	}
	return stack[0], true
}

func main_function() {
	reader := bufio.NewReader(os.Stdin)
	for true {
		fmt.Print("Nano-Joy: ")
		text, _ := reader.ReadString('\n')
		fmt.Println("TEXT IS ", text)
		result, err_check := calculate(tokenize(text))
		if err_check == false {
			fmt.Println("Exception: ", result)
		} else {
			fmt.Println(result)
		}
	}
}

func main() {
	main_function()
}
