package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strconv"
)

type list_node struct {
	value    interface{}
	next     *list_node
	is_empty bool
}

const (
	Stack_color      = "\033[1;33m%s\033[0m"
	Expression_color = "\033[1;31m%s\033[0m"
)

type fractions struct {
	numerator   int64
	denominator int64
}

type map_list struct {
	list_pointer *list_node
}

var fun_map map[string]map_list

func Abs(x int64) int64 {
	if x < 0 {
		return -x
	}
	return x
}

func del_to_potential_fracts(numer int64, denomin int64) interface{} {
	check := numer / denomin
	if check*denomin == numer {
		return check
	} else {
		if numer < 0 {
			if denomin > 0 {
				return fractions{numer, denomin}
			} else {
				return fractions{(-1) * numer, (-1) * denomin}
			}
		} else {
			if denomin < 0 {
				return fractions{(-1) * numer, (-1) * denomin}
			} else {
				return fractions{numer, denomin}
			}
		}
	}
}

func fraction_optimizer(fraction fractions) interface{} {
	a := fraction.numerator
	b := fraction.denominator
	for b != 0 {
		t := b
		b = a % b
		a = t
	}
	a = Abs(a)
	b = fraction.denominator / a
	a = fraction.numerator / a
	if a < 0 && b < 0 {
		a = (-1) * a
		b = (-1) * b
	}
	if b == 1 {
		return a
	} else {
		return fractions{a, b}
	}
}

func fraction_functions(first_el interface{}, second_el interface{}, fun string) interface{} {
	first_type := fmt.Sprintf("%T", first_el)
	second_type := fmt.Sprintf("%T", second_el)
	result := fractions{1, 1}
	var first_num int64
	var first_denom int64
	var second_num int64
	var second_denom int64
	if first_type == "main.fractions" {
		first_num = first_el.(fractions).numerator
		first_denom = first_el.(fractions).denominator
	} else {
		first_num = first_el.(int64)
		var temp int64
		temp = 1
		first_denom = temp
	} //can be optimized by going through the logic that if one element is not fraction, then second one is 100% fraction
	if second_type == "main.fractions" {
		second_num = second_el.(fractions).numerator
		second_denom = second_el.(fractions).denominator
	} else {
		second_num = second_el.(int64)
		var temp int64
		temp = 1
		second_denom = temp
	}
	if fun == "+" {
		result.numerator = first_num*second_denom + second_num*first_denom
		result.denominator = first_denom * second_denom
	} else if fun == "-" {
		result.numerator = first_num*second_denom - second_num*first_denom
		result.denominator = first_denom * second_denom
	} else if fun == "*" {
		result.numerator = first_num * second_num
		result.denominator = first_denom * second_denom
	} else if fun == "/" {
		result.numerator = first_num * second_denom
		result.denominator = second_num * first_denom
	} else if fun == "<" {
		if first_num != second_num {
			return first_num < second_num
		} else {
			return (first_num * second_denom) < (second_num * first_denom)
		}
	} else if fun == ">" {
		if first_num != second_num {
			return first_num > second_num
		} else {
			return (first_num * second_denom) > (second_num * first_denom)
		}
	} else if fun == "<=" {
		if first_num > second_num {
			return false
		} else if first_num < second_num {
			return true
		} else {
			return (first_num * second_denom) <= (second_num * first_denom)
		}
	} else if fun == ">=" {
		if first_num < second_num {
			return false
		} else if first_num > second_num {
			return true
		} else {
			return (first_num * second_denom) >= (second_num * first_denom)
		}
	} else if fun == "=" {
		if first_num != second_num {
			return false
		} else {
			return first_num == second_num
		}
	} else if fun == "!=" {
		if first_num != second_num {
			return true
		} else {
			return first_num != second_num
		}
	}
	return fraction_optimizer(result)
}

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
			} else if res, _ := regexp.MatchString(`(?m)[-+]?([0-9]+[+]|)[0-9]+[/][0-9]+`, elem.(string)); res {
				re := regexp.MustCompile(`[0-9]+`)
				matches := re.FindAllString(elem.(string), -1)
				if len(matches) == 3 {
					y, _ := strconv.ParseInt(matches[1], 10, 64)
					z, _ := strconv.ParseInt(matches[2], 10, 64)
					x, _ := strconv.ParseInt(matches[0], 10, 64)
					if elem.(string)[:1] == "-" {
						x = x * (-1)
						y = y * (-1)
					}
					stack = append(stack, fractions{x*z + y, z})
				} else {
					x, _ := strconv.ParseInt(matches[0], 10, 64)
					y, _ := strconv.ParseInt(matches[1], 10, 64)
					if elem.(string)[:1] == "-" {
						x = x * (-1)
					}
					stack = append(stack, fractions{x, y})
				}
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

func print_string_forming(slice []interface{}) string {
	result := ""
	for _, elem := range slice {
		el_type := fmt.Sprintf("%T", elem)
		if el_type == "string" {
			result = fmt.Sprintf("%s %s", result, elem.(string))
		} else if el_type == "int64" {
			result = fmt.Sprintf("%s %s", result, strconv.FormatInt(elem.(int64), 10))
		} else if el_type == "*main.list_node" {
			result = fmt.Sprintf("%s [%s]", result, print_string_forming(linked_list_unpacking(elem.(*list_node))))
		} else if el_type == "main.fractions" {
			var temp string
			if Abs(elem.(fractions).numerator) > elem.(fractions).denominator {
				x := elem.(fractions).numerator / elem.(fractions).denominator
				y := Abs(elem.(fractions).numerator % elem.(fractions).denominator)
				z := elem.(fractions).denominator
				temp = fmt.Sprintf(" %v+%v/%v", x, y, z)
			} else {
				x := elem.(fractions).numerator
				y := elem.(fractions).denominator
				temp = fmt.Sprintf(" %v/%v", x, y)
			}
			result = fmt.Sprintf("%s %s", result, temp)
		}
	}
	if len(result) > 1 && result[:1] == " " {
		return result[1:]
	} else {
		return result
	}
}

func string_rewrite(expr string, stack string) (string, string) {
	expr = fmt.Sprintf(Expression_color, expr)
	stack = fmt.Sprintf(Stack_color, stack)
	result := fmt.Sprintf("%s %s", stack, expr)
	i := 0
	separating_line := ""
	for i < len(result) {
		separating_line = fmt.Sprintf("%s_", separating_line)
		i++
	}
	return result, separating_line
}

func expr_eval(expr_slice []interface{}) ([]interface{}, bool) {
	stack := []interface{}{}
	fmt.Println()
	line, separator := string_rewrite(print_string_forming(expr_slice), print_string_forming(stack))
	fmt.Println(line)
	fmt.Println(separator)
	fmt.Println()
	for len(expr_slice) != 0 {
		el_type := fmt.Sprintf("%T", expr_slice[0])
		if el_type == "int64" || el_type == "*main.list_node" || expr_slice[0] == "#t" || expr_slice[0] == "#f" || el_type == "main.fractions" || (expr_slice[0].(string)[:1] == ":" && len(expr_slice[0].(string)) > 1) {
			stack = append(stack, expr_slice[0])
		} else if val, ok := fun_map[expr_slice[0].(string)]; ok {
			unpacked_list := linked_list_unpacking(val.list_pointer)
			expr_slice = append(unpacked_list, expr_slice[1:]...)
			continue
		} else if expr_slice[0] == "+" {
			//fmt.Println("Got a +")
			if len(stack) < 2 {
				return []interface{}{"Missing stack elements for \"+\" function"}, false
			}
			x_type := fmt.Sprintf("%T", stack[len(stack)-1])
			y_type := fmt.Sprintf("%T", stack[len(stack)-2])
			if x_type == "string" || y_type == "string" {
				return []interface{}{"\"+\" function works only with numbers"}, false
			} else if x_type == "main.fractions" || y_type == "main.fractions" {
				x := stack[len(stack)-1]
				y := stack[len(stack)-2]
				stack = stack[:len(stack)-2]
				stack = append(stack, fraction_functions(y, x, "+"))
			} else {
				x := stack[len(stack)-1].(int64)
				y := stack[len(stack)-2].(int64)
				result := y + x
				stack = stack[:len(stack)-2] //Can be optimized by cutting only 1 piece of slice and adding changing the new last piece of slice to the needed result instead of cutting 2 pieces and appending the result
				stack = append(stack, result)
			}
			line, separator = string_rewrite(print_string_forming(expr_slice[1:]), print_string_forming(stack))
			fmt.Println(line)
			fmt.Println(separator)
			fmt.Println()
		} else if expr_slice[0] == "-" {
			//fmt.Println("Got a -")
			if len(stack) < 2 {
				return []interface{}{"Missing stack elements for \"-\" function"}, false
			}
			x_type := fmt.Sprintf("%T", stack[len(stack)-1])
			y_type := fmt.Sprintf("%T", stack[len(stack)-2])
			if x_type == "string" || y_type == "string" {
				return []interface{}{"\"-\" function works only with numbers"}, false
			} else if x_type == "main.fractions" || y_type == "main.fractions" {
				x := stack[len(stack)-1]
				y := stack[len(stack)-2]
				stack = stack[:len(stack)-2]
				stack = append(stack, fraction_functions(y, x, "-"))
			} else {
				x := stack[len(stack)-1].(int64)
				y := stack[len(stack)-2].(int64)
				result := y - x
				stack = stack[:len(stack)-2] //Can be optimized by cutting only 1 piece of slice and adding changing the new last piece of slice to the needed result instead of cutting 2 pieces and appending the result
				stack = append(stack, result)
			}
			line, separator = string_rewrite(print_string_forming(expr_slice[1:]), print_string_forming(stack))
			fmt.Println(line)
			fmt.Println(separator)
			fmt.Println()
		} else if expr_slice[0] == "*" {
			//fmt.Println("Got a *")
			if len(stack) < 2 {
				return []interface{}{"Missing stack elements for \"*\" function"}, false
			}
			x_type := fmt.Sprintf("%T", stack[len(stack)-1])
			y_type := fmt.Sprintf("%T", stack[len(stack)-2])
			if x_type == "string" || y_type == "string" {
				return []interface{}{"\"*\" function works only with numbers"}, false
			} else if x_type == "main.fractions" || y_type == "main.fractions" {
				x := stack[len(stack)-1]
				y := stack[len(stack)-2]
				stack = stack[:len(stack)-2]
				stack = append(stack, fraction_functions(y, x, "*"))
			} else {
				x := stack[len(stack)-1].(int64)
				y := stack[len(stack)-2].(int64)
				result := y * x
				stack = stack[:len(stack)-2] //Can be optimized by cutting only 1 piece of slice and adding changing the new last piece of slice to the needed result instead of cutting 2 pieces and appending the result
				stack = append(stack, result)
			}
			line, separator = string_rewrite(print_string_forming(expr_slice[1:]), print_string_forming(stack))
			fmt.Println(line)
			fmt.Println(separator)
			fmt.Println()
		} else if expr_slice[0] == "/" {
			if len(stack) < 2 {
				return []interface{}{"Missing stack elements for \"/\" function"}, false
			}
			x_type := fmt.Sprintf("%T", stack[len(stack)-1])
			y_type := fmt.Sprintf("%T", stack[len(stack)-2])
			var zerocheck int64
			zerocheck = 0
			if stack[len(stack)-1] == zerocheck {
				return []interface{}{"You can't divide by zero"}, false
			} else if x_type == "main.fractions" || y_type == "main.fractions" {
				x := stack[len(stack)-1]
				y := stack[len(stack)-2]
				stack = stack[:len(stack)-2]
				stack = append(stack, fraction_functions(y, x, "/"))
			} else if x_type == "int64" && y_type == "int64" {
				x := stack[len(stack)-1].(int64)
				y := stack[len(stack)-2].(int64)
				result := del_to_potential_fracts(y, x)
				stack = stack[:len(stack)-2] //Can be optimized by cutting only 1 piece of slice and adding changing the new last piece of slice to the needed result instead of cutting 2 pieces and appending the result
				stack = append(stack, result)
			} else {
				return []interface{}{"\"/\" function works only with numbers"}, false
			}
			line, separator = string_rewrite(print_string_forming(expr_slice[1:]), print_string_forming(stack))
			fmt.Println(line)
			fmt.Println(separator)
			fmt.Println()
		} else if expr_slice[0] == "car" {

			if len(stack) < 1 {
				return []interface{}{"Car requires at least 1 element inside stack"}, false
			}
			stack_type := fmt.Sprintf("%T", stack[len(stack)-1])
			if stack_type != "*main.list_node" { //checking that the last element in stack is list pointer
				return []interface{}{"Car only works with lists"}, false
			} else if stack[len(stack)-1].(*list_node).is_empty == true { //checking that it is not an empty list
				return []interface{}{"Can't car an empty list"}, false
			} else {
				x := stack[len(stack)-1].(*list_node).value
				x_type := fmt.Sprintf("%T", x)
				result := ":"
				if x_type == "string" {
					result = result + x.(string)
					stack = stack[:len(stack)-1]
					stack = append(stack, result)
				} else {
					stack = stack[:len(stack)-1]
					stack = append(stack, x)
				}

			}
			line, separator = string_rewrite(print_string_forming(expr_slice[1:]), print_string_forming(stack))
			fmt.Println(line)
			fmt.Println(separator)
			fmt.Println()
		} else if expr_slice[0] == "cdr" {
			if len(stack) < 1 {
				return []interface{}{"Cdr requires at least 1 element inside stack"}, false
			}
			stack_type := fmt.Sprintf("%T", stack[len(stack)-1])
			if stack_type != "*main.list_node" { //checking that the last element in stack is list pointer
				return []interface{}{"Cdr only works with lists"}, false
			} else {
				x := stack[len(stack)-1].(*list_node).next
				stack = stack[:len(stack)-1]
				stack = append(stack, x)
			}
			line, separator = string_rewrite(print_string_forming(expr_slice[1:]), print_string_forming(stack))
			fmt.Println(line)
			fmt.Println(separator)
			fmt.Println()
		} else if expr_slice[0] == "cons" {
			if len(stack) < 2 {
				return []interface{}{"Cons requires at least 2 elements inside stack"}, false
			}
			stack_type := fmt.Sprintf("%T", stack[len(stack)-1])
			if stack_type != "*main.list_node" { //checking that the last element in stack is list pointer
				return []interface{}{"Cons requires a second element to be a list"}, false
			} else {
				x := stack[len(stack)-1].(*list_node)
				y := stack[len(stack)-2]
				y_type := fmt.Sprintf("%T", y)
				stack = stack[:len(stack)-2]
				if y_type == "string" && y.(string)[:1] == ":" && len(y.(string)) > 1 {
					y = y.(string)[1:]
				}
				new_list_head := &list_node{y, x, false}
				stack = append(stack, new_list_head)
			}
			line, separator = string_rewrite(print_string_forming(expr_slice[1:]), print_string_forming(stack))
			fmt.Println(line)
			fmt.Println(separator)
			fmt.Println()
		} else if expr_slice[0] == "null?" {
			if len(stack) < 1 {
				return []interface{}{"null? requires at least 1 element inside stack"}, false
			}
			stack_type := fmt.Sprintf("%T", stack[len(stack)-1])
			if stack_type != "*main.list_node" || stack[len(stack)-1].(*list_node).is_empty == false { //checking that the last element in stack is list pointer
				stack = stack[:len(stack)-1]
				stack = append(stack, "#f")
			} else {
				stack = stack[:len(stack)-1]
				stack = append(stack, "#t")
			}
			line, separator = string_rewrite(print_string_forming(expr_slice[1:]), print_string_forming(stack))
			fmt.Println(line)
			fmt.Println(separator)
			fmt.Println()
		} else if expr_slice[0] == "dup" {
			if len(stack) == 0 {
				return []interface{}{"Dup needs an element in stack to copy"}, false
			} else {
				x := stack[len(stack)-1]
				stack = append(stack, x)
			}
			line, separator = string_rewrite(print_string_forming(expr_slice[1:]), print_string_forming(stack))
			fmt.Println(line)
			fmt.Println(separator)
			fmt.Println()
		} else if expr_slice[0] == "pop" {
			if len(stack) == 0 {
				return []interface{}{"Pop needs an element in stack to copy"}, false
			} else {
				stack = stack[:len(stack)-1]
			}
			line, separator = string_rewrite(print_string_forming(expr_slice[1:]), print_string_forming(stack))
			fmt.Println(line)
			fmt.Println(separator)
			fmt.Println()
		} else if expr_slice[0] == "swap" {
			if len(stack) < 2 {
				return []interface{}{"Swap requires at least 2 elements in stack to copy"}, false
			} else {
				x := stack[len(stack)-1]
				y := stack[len(stack)-2]
				stack = stack[:len(stack)-2]
				stack = append(stack, x, y)
			}
			line, separator = string_rewrite(print_string_forming(expr_slice[1:]), print_string_forming(stack))
			fmt.Println(line)
			fmt.Println(separator)
			fmt.Println()
		} else if expr_slice[0] == "<" {
			if len(stack) < 2 {
				return []interface{}{"Comparison requires at least 2 elements in stack"}, false
			} else {
				x := stack[len(stack)-1]
				y := stack[len(stack)-2]
				xtype := fmt.Sprintf("%T", x)
				ytype := fmt.Sprintf("%T", y)
				stack = stack[:len(stack)-2]
				if (xtype == "string" && ytype == "string") || (xtype != "string" && ytype != "string") {
					if xtype == "int64" && ytype == "int64" {
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
					} else {
						if fraction_functions(y, x, "<") == true {
							stack = append(stack, "#t")
						} else {
							stack = append(stack, "#f")
						}
					}
				} else {
					return []interface{}{"Comparison requires top 2 elements to be both numbers or string"}, false
				}
			}
			line, separator = string_rewrite(print_string_forming(expr_slice[1:]), print_string_forming(stack))
			fmt.Println(line)
			fmt.Println(separator)
			fmt.Println()
		} else if expr_slice[0] == ">" {
			if len(stack) < 2 {
				return []interface{}{"Comparison requires at least 2 elements in stack"}, false
			} else {
				x := stack[len(stack)-1]
				y := stack[len(stack)-2]
				xtype := fmt.Sprintf("%T", x)
				ytype := fmt.Sprintf("%T", y)
				stack = stack[:len(stack)-2]
				if (xtype == "string" && ytype == "string") || (xtype != "string" && ytype != "string") {
					if xtype == "int64" && ytype == "int64" {
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
					} else {
						if fraction_functions(y, x, ">") == true {
							stack = append(stack, "#t")
						} else {
							stack = append(stack, "#f")
						}

					}
				} else {
					return []interface{}{"Comparison requires top 2 elements to be both numbers or string"}, false
				}
			}
			line, separator = string_rewrite(print_string_forming(expr_slice[1:]), print_string_forming(stack))
			fmt.Println(line)
			fmt.Println(separator)
			fmt.Println()
		} else if expr_slice[0] == "<=" {
			if len(stack) < 2 {
				return []interface{}{"Comparison requires at least 2 elements in stack"}, false
			} else {
				x := stack[len(stack)-1]
				y := stack[len(stack)-2]
				xtype := fmt.Sprintf("%T", x)
				ytype := fmt.Sprintf("%T", y)
				stack = stack[:len(stack)-2]
				if (xtype == "string" && ytype == "string") || (xtype != "string" && ytype != "string") {
					if xtype == "int64" && ytype == "int64" {
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
					} else {
						if fraction_functions(y, x, "<=") == true {
							stack = append(stack, "#t")
						} else {
							stack = append(stack, "#f")
						}

					}
				} else {
					return []interface{}{"Comparison requires top 2 elements to be both numbers or string"}, false
				}
			}
			line, separator = string_rewrite(print_string_forming(expr_slice[1:]), print_string_forming(stack))
			fmt.Println(line)
			fmt.Println(separator)
			fmt.Println()
		} else if expr_slice[0] == ">=" {
			if len(stack) < 2 {
				return []interface{}{"Comparison requires at least 2 elements in stack"}, false
			} else {
				x := stack[len(stack)-1]
				y := stack[len(stack)-2]
				xtype := fmt.Sprintf("%T", x)
				ytype := fmt.Sprintf("%T", y)
				stack = stack[:len(stack)-2]
				if (xtype == "string" && ytype == "string") || (xtype != "string" && ytype != "string") {
					if xtype == "int64" && ytype == "int64" {
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
					} else {
						if fraction_functions(y, x, ">=") == true {
							stack = append(stack, "#t")
						} else {
							stack = append(stack, "#f")
						}

					}
				} else {
					return []interface{}{"Comparison requires top 2 elements to be both numbers or string"}, false
				}
			}
			line, separator = string_rewrite(print_string_forming(expr_slice[1:]), print_string_forming(stack))
			fmt.Println(line)
			fmt.Println(separator)
			fmt.Println()
		} else if expr_slice[0] == "=" {
			if len(stack) < 2 {
				return []interface{}{"Equal requires at least 2 elements in stack"}, false
			} else {
				x := stack[len(stack)-1]
				y := stack[len(stack)-2]
				xtype := fmt.Sprintf("%T", x)
				ytype := fmt.Sprintf("%T", y)
				stack = stack[:len(stack)-2]
				if (xtype == "string" && ytype == "string") || (xtype != "string" && ytype != "string") {
					if xtype == "int64" && ytype == "int64" {
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
					} else {
						if fraction_functions(y, x, "=") == true {
							stack = append(stack, "#t")
						} else {
							stack = append(stack, "#f")
						}

					}
				} else {
					return []interface{}{"Comparison requires top 2 elements to be both numbers or string"}, false
				}
			}
			line, separator = string_rewrite(print_string_forming(expr_slice[1:]), print_string_forming(stack))
			fmt.Println(line)
			fmt.Println(separator)
			fmt.Println()
		} else if expr_slice[0] == "!=" {
			if len(stack) < 2 {
				return []interface{}{"Not equal requires at least 2 elements in stack"}, false
			} else {
				x := stack[len(stack)-1]
				y := stack[len(stack)-2]
				xtype := fmt.Sprintf("%T", x)
				ytype := fmt.Sprintf("%T", y)
				stack = stack[:len(stack)-2]
				if (xtype == "string" && ytype == "string") || (xtype != "string" && ytype != "string") {
					if xtype == "int64" && ytype == "int64" {
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
					} else {
						if fraction_functions(y, x, "!=") == true {
							stack = append(stack, "#t")
						} else {
							stack = append(stack, "#f")
						}

					}
				} else {
					return []interface{}{"Comparison requires top 2 elements to be both numbers or string"}, false
				}
			}
			line, separator = string_rewrite(print_string_forming(expr_slice[1:]), print_string_forming(stack))
			fmt.Println(line)
			fmt.Println(separator)
			fmt.Println()
		} else if expr_slice[0] == "ifte" {
			if len(stack) < 3 {
				return []interface{}{"ifte requires at least 3 elements in stack"}, false
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
			line, separator = string_rewrite(print_string_forming(expr_slice), print_string_forming(stack))
			fmt.Println(line)
			fmt.Println(separator)
			fmt.Println()
		} else if expr_slice[0] == "branch" {
			if len(stack) < 1 {
				return []interface{}{"branch requires at least 1 elements in stack"}, false
			} else if stack[len(stack)-3] != "#t" && stack[len(stack)-3] != "#f" {
				return []interface{}{"branch requires a bool to be the last element in stack"}, false
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
				line, separator = string_rewrite(print_string_forming(expr_slice), print_string_forming(stack))
				fmt.Println(line)
				fmt.Println(separator)
				fmt.Println()
				continue //we've cut the te 8 lines above or so, so, we need to skip the slicing
			}
		} else if expr_slice[0] == "define" {
			stack_type := fmt.Sprintf("%T", stack[len(stack)-1])
			if len(stack) < 1 {
				return []interface{}{"missing stack element for define function"}, false
			} else if stack_type != "*main.list_node" { //checking that the last element in stack is list pointer
				return []interface{}{"define only works with list for function body"}, false
			}
			x := stack[len(stack)-1].(*list_node)
			y := x.value
			list_head_type := fmt.Sprintf("%T", y)
			if list_head_type != "string" {
				return []interface{}{"define requires first element of the list to be string to be a function name"}, false
			}
			x = x.next
			stack = stack[:len(stack)-1] //Can be optimized by cutting only 1 piece of slice and adding changing the new last piece of slice to the needed result instead of cutting 2 pieces and appending the result
			fun_map[y.(string)] = map_list{x}
			creation_message := fmt.Sprintf("Function %s has been defined", y.(string))
			stack = append(stack, creation_message)
			line, separator = string_rewrite(print_string_forming(expr_slice[1:]), print_string_forming(stack))
			fmt.Println(line)
			fmt.Println(separator)
			fmt.Println()
		} else if expr_slice[0] == "dip" {
			if len(stack) < 2 {
				return []interface{}{"null? requires at least 1 element inside stack"}, false
			}
			x := stack[len(stack)-1]
			stack_type := fmt.Sprintf("%T", x)
			if stack_type != "*main.list_node" { //checking that the last element in stack is list pointer
				return []interface{}{"dip requires the highest stack element to be list"}, false
			} else {
				y := stack[len(stack)-2]
				stack = stack[:len(stack)-2]
				temp_slice := linked_list_unpacking(x.(*list_node))
				temp_slice = append(temp_slice, y)
				expr_slice = append(temp_slice, expr_slice[1:]...)
				line, separator = string_rewrite(print_string_forming(expr_slice), print_string_forming(stack))
				fmt.Println(line)
				fmt.Println(separator)
				fmt.Println()
				continue
			}
		} else if expr_slice[0] == "popd" {
			x := stack[len(stack)-1]
			stack = stack[:len(stack)-2]
			stack = append(stack, x)
			line, separator = string_rewrite(print_string_forming(expr_slice[1:]), print_string_forming(stack))
			fmt.Println(line)
			fmt.Println(separator)
			fmt.Println()
		} else if expr_slice[0] == "uncons" {
			if len(stack) < 1 {
				return []interface{}{"Uncons requires at least 1 element inside stack"}, false
			}
			stack_type := fmt.Sprintf("%T", stack[len(stack)-1])
			if stack_type != "*main.list_node" { //checking that the last element in stack is list pointer
				return []interface{}{"Uncons only works with lists"}, false
			} else if stack[len(stack)-1].(*list_node).is_empty == true { //checking that it is not an empty list
				return []interface{}{"Can't uncons an empty list"}, false
			} else {
				x_type := fmt.Sprintf("%T", stack[len(stack)-1].(*list_node).value)
				if x_type == "string" {
					x := ":" + stack[len(stack)-1].(*list_node).value.(string)[:1]
					y := stack[len(stack)-1].(*list_node).next
					stack = stack[:len(stack)-1]
					stack = append(stack, x, y)
				} else {
					x := stack[len(stack)-1].(*list_node).value
					y := stack[len(stack)-1].(*list_node).next
					stack = stack[:len(stack)-1]
					stack = append(stack, x, y)
				}
			}
			line, separator = string_rewrite(print_string_forming(expr_slice[1:]), print_string_forming(stack))
			fmt.Println(line)
			fmt.Println(separator)
			fmt.Println()
		} else if expr_slice[0] == "i" {
			if len(stack) < 1 {
				return []interface{}{"i requires at least 1 element inside stack"}, false
			}
			stack_type := fmt.Sprintf("%T", stack[len(stack)-1])
			if stack_type != "*main.list_node" { //checking that the last element in stack is list pointer
				return []interface{}{"i only works with lists"}, false
			}
			x := stack[len(stack)-1].(*list_node)
			stack = stack[:len(stack)-1]
			temp_slice := linked_list_unpacking(x)
			expr_slice = append(temp_slice, expr_slice[1:]...)
			line, separator = string_rewrite(print_string_forming(expr_slice), print_string_forming(stack))
			fmt.Println(line)
			fmt.Println(separator)
			fmt.Println()
			continue
		} else if expr_slice[0] == "dip2" {
			if len(stack) < 3 {
				return []interface{}{"null? requires at least 1 element inside stack"}, false
			}
			x := stack[len(stack)-1]
			stack_type := fmt.Sprintf("%T", x)
			if stack_type != "*main.list_node" { //checking that the last element in stack is list pointer
				return []interface{}{"dip requires the highest stack element to be list"}, false
			} else {
				y := stack[len(stack)-2]
				z := stack[len(stack)-3]
				stack = stack[:len(stack)-3]
				temp_slice := linked_list_unpacking(x.(*list_node))
				temp_slice = append(temp_slice, y, z)
				expr_slice = append(temp_slice, expr_slice[1:]...)
				line, separator = string_rewrite(print_string_forming(expr_slice), print_string_forming(stack))
				fmt.Println(line)
				fmt.Println(separator)
				fmt.Println()
				continue
			}
		} else {
			temp_res := fmt.Sprintf("Unknown command \"%s\"", expr_slice[0])
			return []interface{}{temp_res}, false
		}
		expr_slice = expr_slice[1:]
	}
	if len(stack) != 0 {
		return stack, true
	} else {
		return []interface{}{"Stack is empty! Can't return a first element from an empty stack"}, false
	}

}

func main_function() {
	reader := bufio.NewReader(os.Stdin)
	for true {
		fmt.Print("Nano-Joy: ")
		text, _ := reader.ReadString('\n')
		test_res, _ := parse(tokenize(text[:len(text)-1]))
		result, err_check := expr_eval(test_res)
		if err_check == false {
			fmt.Println("Exception:", result)
		}
	}
}

func main() {
	fun_map = make(map[string]map_list)
	main_function()
}
