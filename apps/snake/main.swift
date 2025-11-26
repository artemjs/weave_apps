// Snake Game for WeaveOS

const App = () => {
  const [snake, setSnake] = useState([{ x: 10, y: 10 }]);
  const [food, setFood] = useState({ x: 15, y: 15 });
  const [direction, setDirection] = useState({ x: 1, y: 0 });
  const [gameOver, setGameOver] = useState(false);
  const [score, setScore] = useState(0);
  const [gameStarted, setGameStarted] = useState(false);
  const directionRef = useRef(direction);

  const GRID_SIZE = 20;
  const CELL_SIZE = 18;

  useEffect(() => { directionRef.current = direction; }, [direction]);

  const generateFood = useCallback((currentSnake) => {
    let newFood;
    do {
      newFood = { x: Math.floor(Math.random() * GRID_SIZE), y: Math.floor(Math.random() * GRID_SIZE) };
    } while (currentSnake.some(seg => seg.x === newFood.x && seg.y === newFood.y));
    return newFood;
  }, []);

  const resetGame = useCallback(() => {
    const initialSnake = [{ x: 10, y: 10 }];
    setSnake(initialSnake);
    setFood(generateFood(initialSnake));
    setDirection({ x: 1, y: 0 });
    directionRef.current = { x: 1, y: 0 };
    setGameOver(false);
    setScore(0);
    setGameStarted(true);
  }, [generateFood]);

  useEffect(() => {
    const handleKeyDown = (e) => {
      if (!gameStarted && !gameOver) { setGameStarted(true); return; }
      if (e.key === ' ' || e.key === 'Escape') { e.preventDefault(); return; }
      if (gameOver) return;
      const currentDir = directionRef.current;
      let newDir = currentDir;
      switch (e.key) {
        case 'ArrowUp': case 'w': if (currentDir.y !== 1) newDir = { x: 0, y: -1 }; break;
        case 'ArrowDown': case 's': if (currentDir.y !== -1) newDir = { x: 0, y: 1 }; break;
        case 'ArrowLeft': case 'a': if (currentDir.x !== 1) newDir = { x: -1, y: 0 }; break;
        case 'ArrowRight': case 'd': if (currentDir.x !== -1) newDir = { x: 1, y: 0 }; break;
      }
      if (newDir !== currentDir) setDirection(newDir);
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [gameStarted, gameOver]);

  useEffect(() => {
    if (!gameStarted || gameOver) return;
    const speed = Math.max(50, 150 - score * 2);
    const gameLoop = setInterval(() => {
      setSnake(currentSnake => {
        const head = currentSnake[0];
        const newHead = { x: head.x + directionRef.current.x, y: head.y + directionRef.current.y };
        if (newHead.x < 0 || newHead.x >= GRID_SIZE || newHead.y < 0 || newHead.y >= GRID_SIZE) { setGameOver(true); return currentSnake; }
        if (currentSnake.some(seg => seg.x === newHead.x && seg.y === newHead.y)) { setGameOver(true); return currentSnake; }
        const newSnake = [newHead, ...currentSnake];
        if (newHead.x === food.x && newHead.y === food.y) {
          setScore(s => s + 1);
          setFood(generateFood(newSnake));
        } else { newSnake.pop(); }
        return newSnake;
      });
    }, speed);
    return () => clearInterval(gameLoop);
  }, [gameStarted, gameOver, food, score, generateFood]);

  return React.createElement('div', { style: { height: '100%', display: 'flex', flexDirection: 'column', background: 'linear-gradient(135deg, #0a0a12, #1a1a2e)', color: '#fff', fontFamily: 'system-ui' } },
    React.createElement('div', { style: { padding: '12px 16px', display: 'flex', justifyContent: 'space-between', borderBottom: '1px solid rgba(255,255,255,0.1)' } },
      React.createElement('span', { style: { color: 'rgba(255,255,255,0.6)' } }, 'Score: ', React.createElement('span', { style: { color: '#4ade80', fontWeight: 600 } }, score)),
      React.createElement('button', { onClick: resetGame, style: { padding: '6px 14px', borderRadius: '8px', background: 'rgba(255,255,255,0.1)', border: 'none', color: '#fff', cursor: 'pointer' } }, 'New Game')
    ),
    React.createElement('div', { style: { flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '20px' } },
      React.createElement('div', { style: { position: 'relative', width: GRID_SIZE * CELL_SIZE, height: GRID_SIZE * CELL_SIZE, background: 'rgba(0,0,0,0.4)', borderRadius: '12px', border: '2px solid rgba(255,255,255,0.1)' } },
        snake.map((seg, i) => React.createElement('div', { key: i, style: { position: 'absolute', left: seg.x * CELL_SIZE, top: seg.y * CELL_SIZE, width: CELL_SIZE - 2, height: CELL_SIZE - 2, margin: 1, borderRadius: i === 0 ? '6px' : '4px', background: i === 0 ? 'linear-gradient(135deg, #4ade80, #22c55e)' : 'rgba(74, 222, 128, 0.8)', boxShadow: i === 0 ? '0 0 10px rgba(74, 222, 128, 0.5)' : 'none' } })),
        React.createElement('div', { style: { position: 'absolute', left: food.x * CELL_SIZE, top: food.y * CELL_SIZE, width: CELL_SIZE - 2, height: CELL_SIZE - 2, margin: 1, borderRadius: '50%', background: 'linear-gradient(135deg, #ef4444, #dc2626)', boxShadow: '0 0 12px rgba(239, 68, 68, 0.6)' } }),
        !gameStarted && !gameOver && React.createElement('div', { style: { position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', background: 'rgba(0,0,0,0.7)', borderRadius: '10px' } },
          React.createElement('div', { style: { fontSize: '48px', marginBottom: '16px' } }, '🐍'),
          React.createElement('div', { style: { fontSize: '24px', fontWeight: 600, marginBottom: '8px' } }, 'Snake'),
          React.createElement('div', { style: { fontSize: '14px', color: 'rgba(255,255,255,0.6)' } }, 'Press any key to start')
        ),
        gameOver && React.createElement('div', { style: { position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', background: 'rgba(0,0,0,0.8)', borderRadius: '10px' } },
          React.createElement('div', { style: { fontSize: '28px', fontWeight: 600, marginBottom: '8px', color: '#ef4444' } }, 'Game Over'),
          React.createElement('div', { style: { fontSize: '18px', marginBottom: '20px' } }, 'Score: ', React.createElement('span', { style: { color: '#4ade80', fontWeight: 600 } }, score)),
          React.createElement('button', { onClick: resetGame, style: { padding: '12px 28px', borderRadius: '12px', background: 'linear-gradient(135deg, #4ade80, #22c55e)', border: 'none', color: '#000', fontSize: '16px', fontWeight: 600, cursor: 'pointer' } }, 'Play Again')
        )
      )
    )
  );
};
