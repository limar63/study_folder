package main

import (
	"errors"
	"fmt"
)

type Snake_piece struct {
	X    int
	Y    int
	next *Snake_piece
}

var snake_length int

var snake_head *Snake_piece

var snake_tail *Snake_piece

func add_as_head(x_cord int, y_cord int) {
	if snake_length == 0 {
		snake_head = &Snake_piece{x_cord, y_cord, nil}
		snake_tail = snake_head
	} else {
		old_head := snake_head
		snake_head = &Snake_piece{x_cord, y_cord, old_head}
		snake_head.next = old_head
	}
	snake_length++
}

func cut_the_tail() {
	if snake_length <= 1 {
		panic(errors.New("Snek has 1 or less bodyparts to delete, you can't do that"))
	} else {
		next_thing := snake_head
		for next_thing.next.next != nil {
			next_thing = next_thing.next
		}
		next_thing.next = nil
		snake_tail = next_thing
	}
	snake_length = snake_length - 1
}

func main() {
	add_as_head(1, 5)
	var current_element *Snake_piece = snake_head
	for current_element != nil {
		fmt.Println(current_element.X, current_element.Y)
		current_element = current_element.next
	}
	fmt.Println("head is ", snake_head, "tail is", snake_tail)
	fmt.Println("#")
	add_as_head(2, 5)
	current_element = snake_head
	for current_element != nil {
		fmt.Println(current_element.X, current_element.Y)
		current_element = current_element.next
	}
	fmt.Println("head is ", snake_head, "tail is", snake_tail)
	fmt.Println("#")
	add_as_head(3, 5)
	current_element = snake_head
	for current_element != nil {
		fmt.Println(current_element.X, current_element.Y)
		current_element = current_element.next
	}
	fmt.Println("head is ", snake_head, "tail is", snake_tail)
	fmt.Println("#")
	cut_the_tail()
	current_element = snake_head
	for current_element != nil {
		fmt.Println(current_element.X, current_element.Y)
		current_element = current_element.next
	}
	fmt.Println("head is ", snake_head, "tail is", snake_tail)
	fmt.Println("#")
	cut_the_tail()
	current_element = snake_head
	for current_element != nil {
		fmt.Println(current_element.X, current_element.Y)
		current_element = current_element.next
	}
	fmt.Println("head is ", snake_head, "tail is", snake_tail)

}
