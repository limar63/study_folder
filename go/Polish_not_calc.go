package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
)

type list_node struct {
	value    interface{}
	next     *list_node
	is_empty bool
}

type map_list struct {
	list_pointer *list_node
}

var fun_map map[string]map_list

func linked_list_unpacking(list *list_node) []interface{} {
	result := []interface{}{}
	length := 0
	for list.is_empty != true {
		result = append(result, list.value)
		list = list.next
		length++
	}
	return result
}

func tokenize(line string) []interface{} {
	word_holder := ""
	tokens := []interface{}{}
	for _, elem := range line {
		if string(elem) == "[" || string(elem) == "]" {
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

func parse(tokenized_slice []interface{}) ([]interface{}, bool) {
	stack := []interface{}{}
	for _, elem := range tokenized_slice {
		if elem != "]" {
			if res, err := strconv.ParseInt(elem.(string), 10, 64); err == nil {
				stack = append(stack, res)
			} else {
				stack = append(stack, elem)
			}
		} else {
			list_pointer := &list_node{nil, nil, true} //creating the empty list
			for len(stack) != 0 && stack[len(stack)-1] != "[" {
				x := stack[len(stack)-1]
				stack = stack[:len(stack)-1]
				temp := list_pointer
				list_pointer = &list_node{x, temp, false}
			}
			if len(stack) != 0 {
				stack = stack[:len(stack)-1]
			} else {
				exc := []interface{}{"Missing opening brakets"}
				return exc, false
			}
			stack = append(stack, list_pointer)
		}
	}
	return stack, true
}

func calculate(expr_slice []interface{}) (interface{}, bool) {
	stack := []interface{}{}
	for len(expr_slice) != 0 {
		el_type := fmt.Sprintf("%T", expr_slice[0])
		fmt.Println("Stack is ", stack, "Expr slice is", expr_slice, "also ", el_type)
		if el_type == "int64" || el_type == "*main.list_node" || expr_slice[0] == "#t" || expr_slice[0] == "#f" {
			stack = append(stack, expr_slice[0])
		} else if val, ok := fun_map[expr_slice[0].(string)]; ok {
			unpacked_list := linked_list_unpacking(val.list_pointer)
			expr_slice = append(unpacked_list, expr_slice[1:]...)
			fmt.Println("Current stack is ", stack, "Expr slice is", expr_slice, "also ", el_type)
			continue
		} else if expr_slice[0] == "+" {
			//fmt.Println("Got a +")
			if len(stack) < 2 {
				return "Missing stack elements for \"+\" function", false
			}
			x := stack[len(stack)-1].(int64)
			y := stack[len(stack)-2].(int64)
			result := y + x
			stack = stack[:len(stack)-2] //Can be optimized by cutting only 1 piece of slice and adding changing the new last piece of slice to the needed result instead of cutting 2 pieces and appending the result
			stack = append(stack, result)
		} else if expr_slice[0] == "-" {
			//fmt.Println("Got a -")
			if len(stack) < 2 {
				return "Missing stack elements for \"-\" function", false
			}
			x := stack[len(stack)-1].(int64)
			y := stack[len(stack)-2].(int64)
			result := y - x
			//fmt.Println("Stack before cutting is", stack)
			stack = stack[:len(stack)-2] //Can be optimized by cutting only 1 piece of slice and adding changing the new last piece of slice to the needed result instead of cutting 2 pieces and appending the result
			//fmt.Println("Stack after cutting is", stack)
			stack = append(stack, result)
			//fmt.Println("Stack after adding result is", stack)
		} else if expr_slice[0] == "*" {
			//fmt.Println("Got a *")
			if len(stack) < 2 {
				return "Missing stack elements for \"*\" function", false
			}
			x := stack[len(stack)-1].(int64)
			y := stack[len(stack)-2].(int64)
			result := y * x
			stack = stack[:len(stack)-2] //Can be optimized by cutting only 1 piece of slice and adding changing the new last piece of slice to the needed result instead of cutting 2 pieces and appending the result
			stack = append(stack, result)
		} else if expr_slice[0] == "/" {
			//fmt.Println("Got a /")
			if len(stack) < 2 {
				return "Missing stack elements for \"/\" function", false
			} else if stack[len(stack)-1] == 0 {
				return "You can't divide by zero", false
			}
			x := stack[len(stack)-1].(int64)
			y := stack[len(stack)-2].(int64)
			result := y / x
			stack = stack[:len(stack)-2] //Can be optimized by cutting only 1 piece of slice and adding changing the new last piece of slice to the needed result instead of cutting 2 pieces and appending the result
			stack = append(stack, result)
		} else if expr_slice[0] == "car" {
			stack_type := fmt.Sprintf("%T", stack[len(stack)-1])
			fmt.Println("IT IS", stack_type)
			if len(stack) < 1 {
				return "Car requires at least 1 element inside stack", false
			} else if stack_type != "*main.list_node" { //checking that the last element in stack is list pointer
				return "Car only works with lists", false
			} else if stack[len(stack)-1].(*list_node).is_empty == true { //checking that it is not an empty list
				return "Can't car an empty list", false
			} else {
				x := stack[len(stack)-1].(*list_node).value
				stack = stack[:len(stack)-1]
				stack = append(stack, x)
			}
		} else if expr_slice[0] == "cdr" {
			stack_type := fmt.Sprintf("%T", stack[len(stack)-1])
			if len(stack) < 1 {
				return "Cdr requires at least 1 element inside stack", false
			} else if stack_type != "*main.list_node" { //checking that the last element in stack is list pointer
				return "Cdr only works with lists", false
			} else {
				x := stack[len(stack)-1].(*list_node).next
				stack = stack[:len(stack)-1]
				stack = append(stack, x)
			}
		} else if expr_slice[0] == "cons" {
			stack_type := fmt.Sprintf("%T", stack[len(stack)-1])
			if len(stack) < 2 {
				return "Cons requires at least 2 elements inside stack", false
			} else if stack_type != "*main.list_node" { //checking that the last element in stack is list pointer
				return "Cons requires a second element to be a list", false
			} else {
				x := stack[len(stack)-1].(*list_node)
				y := stack[len(stack)-2]
				new_list_head := &list_node{y, x, false}
				stack = stack[:len(stack)-2]
				stack = append(stack, new_list_head)
			}
		} else if expr_slice[0] == "null?" {
			stack_type := fmt.Sprintf("%T", stack[len(stack)-1])
			if len(stack) < 1 {
				return "null? requires at least 1 element inside stack", false
			} else if stack_type != "*main.list_node" || stack[len(stack)-1].(*list_node).is_empty == false { //checking that the last element in stack is list pointer
				stack = stack[:len(stack)-1]
				stack = append(stack, "#f")
			} else {
				stack = stack[:len(stack)-1]
				stack = append(stack, "#t")
			}
		} else if expr_slice[0] == "dup" {
			if len(stack) == 0 {
				return "Dup needs an element in stack to copy", false
			} else {
				x := stack[len(stack)-1]
				stack = append(stack, x)
			}
		} else if expr_slice[0] == "pop" {
			if len(stack) == 0 {
				return "Pop needs an element in stack to copy", false
			} else {
				stack = stack[:len(stack)-1]
			}
		} else if expr_slice[0] == "swap" {
			if len(stack) < 2 {
				return "Swap requires at least 2 elements in stack to copy", false
			} else {
				x := stack[len(stack)-1]
				y := stack[len(stack)-2]
				stack = stack[:len(stack)-2]
				stack = append(stack, x, y)
			}
		} else if expr_slice[0] == "<" {
			if len(stack) < 2 {
				return "Comparison requires at least 2 elements in stack", false
			} else {
				x := stack[len(stack)-1]
				y := stack[len(stack)-2]
				xtype := fmt.Sprintf("%T", x)
				ytype := fmt.Sprintf("%T", y)
				stack = stack[:len(stack)-2]
				if xtype != ytype {
					return "Comparison requires top 2 elements to be of the same type", false
				} else {
					if xtype == "int64" {
						if y.(int64) < x.(int64) {
							stack = append(stack, "#t")
						} else {
							stack = append(stack, "#f")
						}
					} else if xtype == "string" {
						if y.(string) < x.(string) {
							stack = append(stack, "#t")
						} else {
							stack = append(stack, "#f")
						}
					}
				}
			}
		} else if expr_slice[0] == ">" {
			if len(stack) < 2 {
				return "Comparison requires at least 2 elements in stack", false
			} else {
				x := stack[len(stack)-1]
				y := stack[len(stack)-2]
				xtype := fmt.Sprintf("%T", x)
				ytype := fmt.Sprintf("%T", y)
				stack = stack[:len(stack)-2]
				if xtype != ytype {
					return "Comparison requires top 2 elements to be of the same type", false
				} else {
					if xtype == "int64" {
						if y.(int64) > x.(int64) {
							stack = append(stack, "#t")
						} else {
							stack = append(stack, "#f")
						}
					} else if xtype == "string" {
						if y.(string) > x.(string) {
							stack = append(stack, "#t")
						} else {
							stack = append(stack, "#f")
						}
					}
				}
			}
		} else if expr_slice[0] == "<=" {
			if len(stack) < 2 {
				return "Comparison requires at least 2 elements in stack", false
			} else {
				x := stack[len(stack)-1]
				y := stack[len(stack)-2]
				xtype := fmt.Sprintf("%T", x)
				ytype := fmt.Sprintf("%T", y)
				stack = stack[:len(stack)-2]
				if xtype != ytype {
					return "Comparison requires top 2 elements to be of the same type", false
				} else {
					if xtype == "int64" {
						if y.(int64) <= x.(int64) {
							stack = append(stack, "#t")
						} else {
							stack = append(stack, "#f")
						}
					} else if xtype == "string" {
						if y.(string) <= x.(string) {
							stack = append(stack, "#t")
						} else {
							stack = append(stack, "#f")
						}
					}
				}
			}
		} else if expr_slice[0] == ">=" {
			if len(stack) < 2 {
				return "Comparison requires at least 2 elements in stack", false
			} else {
				x := stack[len(stack)-1]
				y := stack[len(stack)-2]
				xtype := fmt.Sprintf("%T", x)
				ytype := fmt.Sprintf("%T", y)
				stack = stack[:len(stack)-2]
				if xtype != ytype {
					return "Comparison requires top 2 elements to be of the same type", false
				} else {
					if xtype == "int64" {
						if y.(int64) >= x.(int64) {
							stack = append(stack, "#t")
						} else {
							stack = append(stack, "#f")
						}
					} else if xtype == "string" {
						if y.(string) >= x.(string) {
							stack = append(stack, "#t")
						} else {
							stack = append(stack, "#f")
						}
					}
				}
			}
		} else if expr_slice[0] == "=" {
			if len(stack) < 2 {
				return "Equal requires at least 2 elements in stack", false
			} else {
				x := stack[len(stack)-1]
				y := stack[len(stack)-2]
				xtype := fmt.Sprintf("%T", x)
				ytype := fmt.Sprintf("%T", y)
				stack = stack[:len(stack)-2]
				if xtype != ytype {
					return "Comparison requires top 2 elements to be of the same type", false
				} else {
					if xtype == "int64" {
						if y.(int64) == x.(int64) {
							stack = append(stack, "#t")
						} else {
							stack = append(stack, "#f")
						}
					} else if xtype == "string" {
						if y.(string) == x.(string) {
							stack = append(stack, "#t")
						} else {
							stack = append(stack, "#f")
						}
					}
				}
			}
		} else if expr_slice[0] == "/=" {
			if len(stack) < 2 {
				return "Not equal requires at least 2 elements in stack", false
			} else {
				x := stack[len(stack)-1]
				y := stack[len(stack)-2]
				xtype := fmt.Sprintf("%T", x)
				ytype := fmt.Sprintf("%T", y)
				stack = stack[:len(stack)-2]
				if xtype != ytype {
					return "Comparison requires top 2 elements to be of the same type", false
				} else {
					if xtype == "int64" {
						if y.(int64) != x.(int64) {
							stack = append(stack, "#t")
						} else {
							stack = append(stack, "#f")
						}
					} else if xtype == "string" {
						if y.(string) != x.(string) {
							stack = append(stack, "#t")
						} else {
							stack = append(stack, "#f")
						}
					}
				}
			}
		} else if expr_slice[0] == "ifte" {
			if len(stack) < 3 {
				return "ifte requires at least 3 elements in stack", false
			} else {
				x := stack[len(stack)-1]
				y := stack[len(stack)-2]
				z := stack[len(stack)-3].(*list_node)
				stack = stack[:len(stack)-3]
				//stack = append(stack, y, x)
				temp_slice := []interface{}{y, x, "branch"}
				temp_slice = append(temp_slice, expr_slice[1:]...)
				expr_slice = append(linked_list_unpacking(z), temp_slice...)
				continue //we've cut the ifte 2 lines above, so, we need to skip the slicing
			}
		} else if expr_slice[0] == "branch" {
			if len(stack) < 1 {
				return "branch requires at least 1 elements in stack", false
			} else if stack[len(stack)-3] != "#t" && stack[len(stack)-3] != "#f" {
				return "branch requires a bool to be the last element in stack", false
			} else {
				x := stack[len(stack)-1].(*list_node)
				y := stack[len(stack)-2].(*list_node)
				z := stack[len(stack)-3].(string)
				stack = stack[:len(stack)-3]
				expr_slice = expr_slice[1:]
				temp_slice := []interface{}{}
				if z == "#t" {
					temp_slice = linked_list_unpacking(y)
				} else {
					temp_slice = linked_list_unpacking(x)
				}
				expr_slice = append(temp_slice, expr_slice...)
				continue //we've cut the te 8 lines above or so, so, we need to skip the slicing
			}
		} else if expr_slice[0] == "define" {
			stack_type := fmt.Sprintf("%T", stack[len(stack)-1])
			if len(stack) < 1 {
				return "missing stack element for define function", false
			} else if stack_type != "*main.list_node" { //checking that the last element in stack is list pointer
				return "define only works with list for function body", false
			}
			x := stack[len(stack)-1].(*list_node)
			y := x.value
			list_head_type := fmt.Sprintf("%T", y)
			if list_head_type != "string" {
				return "define requires first element of the list to be string to be a function name", false
			}
			x = x.next
			stack = stack[:len(stack)-1] //Can be optimized by cutting only 1 piece of slice and adding changing the new last piece of slice to the needed result instead of cutting 2 pieces and appending the result
			fun_map[y.(string)] = map_list{x}
			creation_message := fmt.Sprintf("Function %s has been defined", y.(string))
			stack = append(stack, creation_message)
		}
		expr_slice = expr_slice[1:]
	}
	return stack[0], true
}

func main_function() {
	reader := bufio.NewReader(os.Stdin)
	for true {
		fmt.Print("Nano-Joy: ")
		text, _ := reader.ReadString('\n')
		test_res, _ := parse(tokenize(text[:len(text)-1]))
		result, err_check := calculate(test_res)
		if err_check == false {
			fmt.Println("Exception:", result)
		} else {
			fmt.Println(result)
		}
	}
}

func main() {
	fun_map = make(map[string]map_list)
	main_function()
}
