package main

import (
	"github.com/rthornton128/goncurses"
	"log"
	"math/rand"
	"time"
	"os"
	"fmt"
)

func apple_create(x_cords int, y_cords int, x_max int, y_max int, snake_b Snake_body) (int, int) {
    rand.Seed(time.Now().UnixNano())
	x_res := rand.Intn(x_max + 1 - 0) + 0
	y_res := rand.Intn(y_max + 1 - 0) + 0
	check := false
	current_piece := 
	while 
	for i := 0; i < snake_b.length; i++ {
		if x_res == snake_b[i].X && y_res == snake_b[i].Y {
			check = true
		}
	}
	if check == true {
		return apple_create(x_cords, y_cords, x_max, y_max, snake_b)
	} else {
		return x_res, y_res
	}
}


type Snake_body struct {
	length int
	head *snake_piece
	tail *snake_piece
}

type Snake_piece struct {
	X int
	Y int
	next *snake_piece
}

func (snake *Snake_body) add_as_head(new_part *Snake_piece) {
	if snake.length == 0 {
		snake.head = new_part
		snake.tail = new_part
	} else {
		old_head := snake.head
		snake.head = new_part
		new_part.next = old_head
	}
	snake.length++
}

func (snake *Snake_body) cut_the_tail() {
	if snake.length <= 1 {
		panic(errors.New("Snek has 1 or less bodyparts to delete, you can't do that"))
	} else {
		next_thing := snake.head
		while next_thing.next.next != nil {
			next_thing = next_thing.next
		}
		next_thing.next = nil
	}
	snake.length = snake.length - 1
}

/*func print_snake(array [][]int) {
	for i: = 0; i < len(array); i++ {
		stdscr.MovePrint(array[i][0], array[i][2], "#")
	}
}*/

func main() {

	stdscr, err := goncurses.Init()
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
	x_limit := 12
	y_limit := 30
	x := 0
	y := 0
	x_change := 0
	y_change := 1
	half_del_val := 10
	snake_body := []snake_piece{{0, 0}}
	x_app, y_app := apple_create(x, y, x_limit, y_limit, snake_body)
	stdscr.MovePrint(x_app, y_app, "@")
	goncurses.HalfDelay(half_del_val)
	stdscr.Keypad(true)
	for true {
		for i := 0; i < len(snake_body) - 1; i++ {
			if x == snake_body[i].X && y == snake_body[i].Y {
				goncurses.End()
				fmt.Println("Game over!")
				os.Exit(0) 
			}
		}
		if snake_body[len(snake_body) - 1].X == x_app && snake_body[len(snake_body) - 1].Y == y_app {
			x_app, y_app = apple_create(x, y, x_limit, y_limit, snake_body)
			stdscr.MovePrint(x_app, y_app, "@")
			half_del_val = half_del_val / 10 * 9 
			goncurses.HalfDelay(half_del_val)
		} else {
			stdscr.MovePrint(snake_body[0].X, snake_body[0].Y, " ")
			snake_body = snake_body[1:]
		}
		stdscr.Refresh()
		
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
		snake_body = append(snake_body, snake_piece{x, y})
		stdscr.MovePrint(snake_body[len(snake_body) - 1].X, snake_body[len(snake_body) - 1].Y, "#")
		a := stdscr.GetChar()
	if a == goncurses.KEY_TAB {
			break
		} else if a == goncurses.KEY_RIGHT && y_change != -1 {
			x_change = 0
			y_change = 1
		} else if a == goncurses.KEY_LEFT && y_change != 1 {
			x_change = 0
			y_change = -1
		} else if a == goncurses.KEY_DOWN && x_change != -1 {
			x_change = 1
			y_change = 0
		} else if a == goncurses.KEY_UP && x_change != 1 {
			x_change = -1
			y_change = 0
		}

	}
	goncurses.End() 
	/*goncurses.HalfDelay(33)
	stdscr.Clear()
	stdscr.Refresh()
	stdscr.Print("Hello, World!")
	stdscr.GetChar()*/
	
}
