// Snake Game for WeaveOS
// Written in Swift-like syntax

let GRID_SIZE = 20
let CELL_SIZE = 18

var snake = [{ x: 10, y: 10 }]
var food = { x: 15, y: 15 }
var direction = { x: 1, y: 0 }
var gameOver = false
var score = 0
var gameStarted = false

func generateFood() {
    var newFood
    repeat {
        newFood = {
            x: Math.floor(Math.random() * GRID_SIZE),
            y: Math.floor(Math.random() * GRID_SIZE)
        }
    } while (snake.some(seg => seg.x == newFood.x && seg.y == newFood.y))
    food = newFood
}

func resetGame() {
    snake = [{ x: 10, y: 10 }]
    generateFood()
    direction = { x: 1, y: 0 }
    gameOver = false
    score = 0
    gameStarted = true
}

func handleKeyDown(e) {
    if (!gameStarted && !gameOver) {
        gameStarted = true
        return
    }
    if (gameOver) return

    switch (e.key) {
        case "ArrowUp", "w":
            if (direction.y != 1) direction = { x: 0, y: -1 }
        case "ArrowDown", "s":
            if (direction.y != -1) direction = { x: 0, y: 1 }
        case "ArrowLeft", "a":
            if (direction.x != 1) direction = { x: -1, y: 0 }
        case "ArrowRight", "d":
            if (direction.x != -1) direction = { x: 1, y: 0 }
    }
}

func gameLoop() {
    if (!gameStarted || gameOver) return

    let head = snake[0]
    let newHead = { x: head.x + direction.x, y: head.y + direction.y }

    // Check collision with walls
    if (newHead.x < 0 || newHead.x >= GRID_SIZE || newHead.y < 0 || newHead.y >= GRID_SIZE) {
        gameOver = true
        return
    }

    // Check collision with self
    if (snake.some(seg => seg.x == newHead.x && seg.y == newHead.y)) {
        gameOver = true
        return
    }

    snake.unshift(newHead)

    // Check food collision
    if (newHead.x == food.x && newHead.y == food.y) {
        score = score + 1
        generateFood()
    } else {
        snake.pop()
    }
}

func render() {
    print("Snake Game - Score: " + score)
}
