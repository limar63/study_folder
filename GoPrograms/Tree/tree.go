package main

import (
	"bufio"
	"fmt"
	"io/ioutil"
	"os"
	"strconv"
)

type element_struct struct {
	value    string
	depth    int
	position int
}

func reverse_and_struct(s []interface{}) []element_struct {
	res := make([]element_struct, len(s))
	fmt.Println("before is", s)
	for i, elem := range s {
		res[len(s)-1-i] = elem.(element_struct)
	}
	fmt.Println("RES HERE IS", res)
	return res
}

/*
type list_node struct {
	value    interface{}
	next     *list_node
	is_empty bool
}
*/
func file_reading(file_name string) string {
	data, err := ioutil.ReadFile(file_name)
	if err != nil {
		return "File reading error"
	}
	var result string = string(data)[:len(data)-1]
	return result
}

func tokenize(line string) []string {
	word_holder := ""
	var tokens []string
	for _, elem := range line {
		if string(elem) == "(" || string(elem) == ")" {
			if word_holder == "" {
				tokens = append(tokens, string(elem))
			} else {
				tokens = append(tokens, word_holder)
				word_holder = ""
				tokens = append(tokens, string(elem))
			}
		} else if string(elem) == " " {
			if word_holder != "" {
				tokens = append(tokens, word_holder)
				word_holder = ""
			}
		} else {
			word_holder = word_holder + string(elem)
		}
	}
	if word_holder != "" {
		tokens = append(tokens, word_holder)
		word_holder = ""
	}
	return tokens
}

/*
func parse(tokens []string) (*list_node, bool) {
	stack := []interface{}{}
	for _, elem := range tokens {
		fmt.Println("Current element:", elem)
		if elem != ")" {
			if elem != "(" {
				if res, err := strconv.ParseInt(elem, 10, 64); err == nil {
					fmt.Println("Got int")
					stack = append(stack, res)
				} else {
					fmt.Println("Can only work with ints and embedded lists")
					exception_node := &list_node{0, nil, true}
					return exception_node, false
				}
			} else {
				stack = append(stack, elem)
			}
		} else {
			list_pointer := &list_node{0, nil, true} //creating the empty list
			for len(stack) != 0 && stack[len(stack)-1] != "(" {
				x := stack[len(stack)-1]
				stack = stack[:len(stack)-1]
				fmt.Println()
				fmt.Println("x is", x, "stack is", stack)
				temp := list_pointer
				list_pointer = &list_node{x, temp, false}
			}
			if len(stack) != 0 {
				stack = stack[:len(stack)-1]
			} else {
				fmt.Println("Missing opening brakets")
				exception_node := &list_node{0, nil, true}
				return exception_node, false
			}
			stack = append(stack, list_pointer)
		}
	}
	return stack[0].(*list_node), true
}
*/

func output_parse(tokens []string) ([]element_struct, int, int, bool) {
	stack := []interface{}{}
	var depth int = -1
	var max_depth int = 0
	var pos int = 0
	result := []element_struct{}
	for _, elem := range tokens {
		fmt.Println("Current element:", elem)
		if elem != ")" {
			if elem != "(" {
				if _, err := strconv.ParseInt(elem, 10, 64); err == nil {
					stack = append(stack, element_struct{elem, depth, pos})
					pos = pos + 1
				} else {
					var exc []element_struct
					return exc, max_depth, pos, false
				}
			} else {
				stack = append(stack, elem)
				depth = depth + 1
				if max_depth < depth {
					max_depth = depth
				}
			}
		} else {
			temp_stack := []interface{}{}
			for len(stack) != 0 && stack[len(stack)-1] != "(" {
				x := stack[len(stack)-1]
				stack = stack[:len(stack)-1]
				temp_stack = append(temp_stack, x)
			}
			if len(stack) != 0 {
				stack = stack[:len(stack)-1]
				depth = depth - 1
			} else {
				var exc []element_struct
				return exc, max_depth, pos, false
			}
			fmt.Println("Result before is", result)
			result = append(reverse_and_struct(temp_stack), result...)
			fmt.Println("result now ", result)
		}
	}
	fmt.Println("RESULT", result)
	return result, max_depth, pos, true
}

func parse_to_output(struct_slice []element_struct, depth int, pos int) string {
	fmt.Println("doing", depth, pos)
	result := ""
	var i int
	for i = 0; i <= pos; i++ {
		fmt.Println("current i is", i)
		var j int
		for j = 0; j <= depth; j++ {
			fmt.Println("current j is", j)
			result = result + "    "
		}
		result = result + "\n"
	}
	fmt.Println(struct_slice)
	for _, elem := range struct_slice {
		temp := elem.position*elem.depth + elem.position + elem.depth
		fmt.Println("Temp is", temp, "elem_position is depth", elem.position, "pos ", elem.position, elem.value)

		result = result[:temp-1] + elem.value + result[temp:len(result)]
	}
	return result
}

func main() {
	reader := bufio.NewReader(os.Stdin)
	fmt.Println("Input file name (with file format) ")
	text, _ := reader.ReadString('\n')
	result, depth, pos, err := output_parse(tokenize(file_reading(text[:len(text)-1])))
	if err == true {
		fmt.Println(parse_to_output(result, depth, pos))
	}
}
