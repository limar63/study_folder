package main

import (
	"github.com/rthornton128/goncurses"
	"log"
	"math/rand"
	"time"
	"os"
	"fmt"
	"errors"
)

var stdscr *goncurses.Window

var err error

var snake_length int

var snake_head *Snake_piece

var snake_tail *Snake_piece

var x_app int

var y_app int

var x_change int

var y_change int

var x_limit int

var y_limit int

var x int																							//current head x

var y int																							//current head y


func apple_create() (int, int) {
    rand.Seed(time.Now().UnixNano())
	x_res := rand.Intn(x_limit + 1 - 0) + 0
	y_res := rand.Intn(y_limit + 1 - 0) + 0
	check := false
	current_piece := snake_head
	for current_piece.next != nil {
		if current_piece.X == x_res && current_piece.Y == y_res {
			check = true
		}
		current_piece = current_piece.next
	}
	if check == true {
		return apple_create()
	} else {
		return x_res, y_res
	}
}


/*type Snake_body struct {
	length int
	head *Snake_piece
	tail *Snake_piece
}*/

type Snake_piece struct {
	X int
	Y int
	next *Snake_piece
}

func add_as_head(x_cord int, y_cord int) {
	if snake_length == 0 {
		snake_head = &Snake_piece{x_cord, y_cord, nil}
		snake_tail = snake_head
	} else {
		old_head := snake_head
		snake_head = &Snake_piece{x_cord, y_cord, old_head
		}
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

func getting_input() (int, int) {
	a := stdscr.GetChar()
	if a == goncurses.KEY_TAB {
		goncurses.End()
		fmt.Println("Game over!")
		os.Exit(0)
	} else if a == goncurses.KEY_RIGHT && x_change != -1 {
		x_change = 1
		y_change = 0
	} else if a == goncurses.KEY_LEFT && x_change != 1 {
		x_change = -1
		y_change = 0
	} else if a == goncurses.KEY_DOWN && y_change != -1 {
		x_change = 0
		y_change = 1
	} else if a == goncurses.KEY_UP && y_change != 1 {
		x_change = 0
		y_change = -1
	}
	return x_change, y_change
}

func moving_and_drawing() {
	x = x + x_change
	if x > x_limit {
		x = 0
	} else if x < 0 {
		x = x_limit
	}
	y = y + y_change
	if y > y_limit {
		y = 0
	} else if y < 0 {
		y = y_limit
	}
	add_as_head(x, y)
	stdscr.MovePrint(snake_head.Y, snake_head.X, "#")
	current_part := snake_head.next
	for current_part != nil {
		if snake_head.X == current_part.X && snake_head.Y == current_part.Y {
			goncurses.End()
			fmt.Println("Game over!")
			os.Exit(0)
		}
		current_part = current_part.next
	}
	if snake_head.X == x_app && snake_head.Y == y_app {
		x_app, y_app = apple_create()
		stdscr.MovePrint(y_app, x_app, "@")
	} else {
		stdscr.MovePrint(y_app, x_app, "@")
		stdscr.MovePrint(snake_tail.Y, snake_tail.X, " ")
		cut_the_tail()
	}
	stdscr.Refresh()
}

/*func print_snake(array [][]int) {
	for i: = 0; i < len(array); i++ {
		stdscr.MovePrint(array[i][0], array[i][2], "#")
	}
}*/

func main() {

	stdscr, err = goncurses.Init()
	if err != nil {
		log.Fatal("init", err)
	}
	defer goncurses.End()

	/*x,y := 10, 10
	stdscr.Move(5, 5)
	stdscr.Print("Hello, World!")
	stdscr.MovePrint(x, y, "Press any key to continue")*/
	goncurses.Cursor(0)
	goncurses.Echo(false)
	x_limit = 10 																						//limit for x axis, placeholder version
	y_limit = 10 																						//limit for y axis, placeholder version
	x = 0 																								//current head x position
	y = 0 																								//current head y position
	x_change = 0 																						//variable which changes the movement with user key input x axis
	y_change = 1 																						//variable which changes the movement with user key input y axis																				//variable for half delay settings
	add_as_head(x, y)
	x_app, y_app = apple_create()																		//creating apple
	stdscr.MovePrint(y_app, x_app, "@")
	goncurses.HalfDelay(10)
	stdscr.Keypad(true)
	for true {
		moving_and_drawing()
		x_change, y_change = getting_input()
		stdscr.MovePrint(5, 15, snake_head.X, " snake head x")
		stdscr.MovePrint(6, 15, snake_head.Y, " snake head y")
		stdscr.MovePrint(7, 15, x_app, " x_app")
		stdscr.MovePrint(8, 15, y_app, " y_app")
		stdscr.MovePrint(9, 15, snake_length, " length")
		
	}
	goncurses.End() 
	/*goncurses.HalfDelay(33)	
	stdscr.Clear()
	stdscr.Refresh()
	stdscr.Print("Hello, World!")
	stdscr.GetChar()*/
	
}
