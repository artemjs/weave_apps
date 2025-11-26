// Tetris - Classic block stacking game
// WeaveOS App

const COLS = 10;
const ROWS = 20;
const BLOCK_SIZE = 24;

const PIECES = [
  { shape: [[1,1,1,1]], color: '#00f0f0' },           // I
  { shape: [[1,1],[1,1]], color: '#f0f000' },         // O
  { shape: [[0,1,0],[1,1,1]], color: '#a000f0' },     // T
  { shape: [[1,0,0],[1,1,1]], color: '#f0a000' },     // L
  { shape: [[0,0,1],[1,1,1]], color: '#0000f0' },     // J
  { shape: [[0,1,1],[1,1,0]], color: '#00f000' },     // S
  { shape: [[1,1,0],[0,1,1]], color: '#f00000' },     // Z
];

const App = () => {
  const [board, setBoard] = useState(() =>
    Array(ROWS).fill(null).map(() => Array(COLS).fill(null))
  );
  const [piece, setPiece] = useState(null);
  const [piecePos, setPiecePos] = useState({ x: 0, y: 0 });
  const [score, setScore] = useState(0);
  const [lines, setLines] = useState(0);
  const [level, setLevel] = useState(1);
  const [gameOver, setGameOver] = useState(false);
  const [isPaused, setIsPaused] = useState(false);
  const [nextPiece, setNextPiece] = useState(null);
  const gameRef = useRef(null);

  const getRandomPiece = useCallback(() => {
    const idx = Math.floor(Math.random() * PIECES.length);
    return { ...PIECES[idx], shape: PIECES[idx].shape.map(row => [...row]) };
  }, []);

  const rotatePiece = useCallback((shape) => {
    const rows = shape.length;
    const cols = shape[0].length;
    const rotated = Array(cols).fill(null).map(() => Array(rows).fill(0));
    for (let r = 0; r < rows; r++) {
      for (let c = 0; c < cols; c++) {
        rotated[c][rows - 1 - r] = shape[r][c];
      }
    }
    return rotated;
  }, []);

  const isValidMove = useCallback((shape, posX, posY, currentBoard) => {
    for (let r = 0; r < shape.length; r++) {
      for (let c = 0; c < shape[r].length; c++) {
        if (shape[r][c]) {
          const newX = posX + c;
          const newY = posY + r;
          if (newX < 0 || newX >= COLS || newY >= ROWS) return false;
          if (newY >= 0 && currentBoard[newY][newX]) return false;
        }
      }
    }
    return true;
  }, []);

  const placePiece = useCallback((currentBoard, currentPiece, pos) => {
    const newBoard = currentBoard.map(row => [...row]);
    for (let r = 0; r < currentPiece.shape.length; r++) {
      for (let c = 0; c < currentPiece.shape[r].length; c++) {
        if (currentPiece.shape[r][c]) {
          const y = pos.y + r;
          const x = pos.x + c;
          if (y >= 0 && y < ROWS && x >= 0 && x < COLS) {
            newBoard[y][x] = currentPiece.color;
          }
        }
      }
    }
    return newBoard;
  }, []);

  const clearLines = useCallback((currentBoard) => {
    let cleared = 0;
    const newBoard = currentBoard.filter(row => {
      const isFull = row.every(cell => cell !== null);
      if (isFull) cleared++;
      return !isFull;
    });
    while (newBoard.length < ROWS) {
      newBoard.unshift(Array(COLS).fill(null));
    }
    return { newBoard, cleared };
  }, []);

  const spawnPiece = useCallback(() => {
    const newPiece = nextPiece || getRandomPiece();
    const startX = Math.floor((COLS - newPiece.shape[0].length) / 2);
    const startY = 0;

    if (!isValidMove(newPiece.shape, startX, startY, board)) {
      setGameOver(true);
      return;
    }

    setPiece(newPiece);
    setPiecePos({ x: startX, y: startY });
    setNextPiece(getRandomPiece());
  }, [board, nextPiece, getRandomPiece, isValidMove]);

  const moveDown = useCallback(() => {
    if (!piece || gameOver || isPaused) return;

    const newY = piecePos.y + 1;
    if (isValidMove(piece.shape, piecePos.x, newY, board)) {
      setPiecePos(prev => ({ ...prev, y: newY }));
    } else {
      const newBoard = placePiece(board, piece, piecePos);
      const { newBoard: clearedBoard, cleared } = clearLines(newBoard);

      setBoard(clearedBoard);
      if (cleared > 0) {
        const points = [0, 100, 300, 500, 800][cleared] * level;
        setScore(prev => prev + points);
        setLines(prev => {
          const newLines = prev + cleared;
          if (newLines >= level * 10) {
            setLevel(l => l + 1);
          }
          return newLines;
        });
      }

      setPiece(null);
    }
  }, [piece, piecePos, board, gameOver, isPaused, isValidMove, placePiece, clearLines, level]);

  const moveLeft = useCallback(() => {
    if (!piece || gameOver || isPaused) return;
    if (isValidMove(piece.shape, piecePos.x - 1, piecePos.y, board)) {
      setPiecePos(prev => ({ ...prev, x: prev.x - 1 }));
    }
  }, [piece, piecePos, board, gameOver, isPaused, isValidMove]);

  const moveRight = useCallback(() => {
    if (!piece || gameOver || isPaused) return;
    if (isValidMove(piece.shape, piecePos.x + 1, piecePos.y, board)) {
      setPiecePos(prev => ({ ...prev, x: prev.x + 1 }));
    }
  }, [piece, piecePos, board, gameOver, isPaused, isValidMove]);

  const rotate = useCallback(() => {
    if (!piece || gameOver || isPaused) return;
    const rotated = rotatePiece(piece.shape);
    if (isValidMove(rotated, piecePos.x, piecePos.y, board)) {
      setPiece(prev => ({ ...prev, shape: rotated }));
    }
  }, [piece, piecePos, board, gameOver, isPaused, rotatePiece, isValidMove]);

  const hardDrop = useCallback(() => {
    if (!piece || gameOver || isPaused) return;
    let newY = piecePos.y;
    while (isValidMove(piece.shape, piecePos.x, newY + 1, board)) {
      newY++;
    }
    setPiecePos(prev => ({ ...prev, y: newY }));
  }, [piece, piecePos, board, gameOver, isPaused, isValidMove]);

  const resetGame = useCallback(() => {
    setBoard(Array(ROWS).fill(null).map(() => Array(COLS).fill(null)));
    setPiece(null);
    setScore(0);
    setLines(0);
    setLevel(1);
    setGameOver(false);
    setIsPaused(false);
    setNextPiece(getRandomPiece());
  }, [getRandomPiece]);

  useEffect(() => {
    if (!nextPiece) {
      setNextPiece(getRandomPiece());
    }
  }, [nextPiece, getRandomPiece]);

  useEffect(() => {
    if (!piece && !gameOver && nextPiece) {
      spawnPiece();
    }
  }, [piece, gameOver, nextPiece, spawnPiece]);

  useEffect(() => {
    if (gameOver || isPaused) return;
    const speed = Math.max(100, 1000 - (level - 1) * 100);
    const interval = setInterval(moveDown, speed);
    return () => clearInterval(interval);
  }, [moveDown, gameOver, isPaused, level]);

  useEffect(() => {
    const handleKeyDown = (e) => {
      if (e.key === 'ArrowLeft') moveLeft();
      else if (e.key === 'ArrowRight') moveRight();
      else if (e.key === 'ArrowDown') moveDown();
      else if (e.key === 'ArrowUp') rotate();
      else if (e.key === ' ') hardDrop();
      else if (e.key === 'p' || e.key === 'P') setIsPaused(p => !p);
      else if (e.key === 'r' || e.key === 'R') resetGame();
    };

    const el = gameRef.current;
    if (el) {
      el.addEventListener('keydown', handleKeyDown);
      el.focus();
    }
    return () => el?.removeEventListener('keydown', handleKeyDown);
  }, [moveLeft, moveRight, moveDown, rotate, hardDrop, resetGame]);

  const renderBoard = () => {
    const display = board.map(row => [...row]);
    if (piece) {
      for (let r = 0; r < piece.shape.length; r++) {
        for (let c = 0; c < piece.shape[r].length; c++) {
          if (piece.shape[r][c]) {
            const y = piecePos.y + r;
            const x = piecePos.x + c;
            if (y >= 0 && y < ROWS && x >= 0 && x < COLS) {
              display[y][x] = piece.color;
            }
          }
        }
      }
    }
    return display;
  };

  const displayBoard = renderBoard();

  return React.createElement('div', {
    ref: gameRef,
    tabIndex: 0,
    style: {
      height: '100%',
      background: 'linear-gradient(135deg, #1a1a2e 0%, #16213e 100%)',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      padding: '16px',
      color: '#fff',
      fontFamily: 'system-ui',
      outline: 'none',
    }
  },
    React.createElement('h2', {
      style: { margin: '0 0 12px 0', fontSize: '20px', color: '#00f0f0' }
    }, 'TETRIS'),

    React.createElement('div', {
      style: { display: 'flex', gap: '20px', alignItems: 'flex-start' }
    },
      // Game board
      React.createElement('div', {
        style: {
          display: 'grid',
          gridTemplateColumns: `repeat(${COLS}, ${BLOCK_SIZE}px)`,
          gridTemplateRows: `repeat(${ROWS}, ${BLOCK_SIZE}px)`,
          gap: '1px',
          background: '#0f0f23',
          padding: '4px',
          borderRadius: '8px',
          border: '2px solid #333',
        }
      },
        displayBoard.flat().map((cell, i) =>
          React.createElement('div', {
            key: i,
            style: {
              width: BLOCK_SIZE,
              height: BLOCK_SIZE,
              background: cell || '#1a1a2e',
              borderRadius: '3px',
              boxShadow: cell ? 'inset 2px 2px 4px rgba(255,255,255,0.3), inset -2px -2px 4px rgba(0,0,0,0.3)' : 'none',
            }
          })
        )
      ),

      // Side panel
      React.createElement('div', {
        style: {
          display: 'flex',
          flexDirection: 'column',
          gap: '12px',
          minWidth: '120px',
        }
      },
        // Next piece
        React.createElement('div', {
          style: {
            background: 'rgba(255,255,255,0.05)',
            padding: '12px',
            borderRadius: '8px',
          }
        },
          React.createElement('div', {
            style: { fontSize: '11px', color: '#888', marginBottom: '8px' }
          }, 'NEXT'),
          nextPiece && React.createElement('div', {
            style: {
              display: 'grid',
              gridTemplateColumns: `repeat(${nextPiece.shape[0].length}, 16px)`,
              gap: '1px',
            }
          },
            nextPiece.shape.flat().map((cell, i) =>
              React.createElement('div', {
                key: i,
                style: {
                  width: 16,
                  height: 16,
                  background: cell ? nextPiece.color : 'transparent',
                  borderRadius: '2px',
                }
              })
            )
          )
        ),

        // Stats
        React.createElement('div', {
          style: {
            background: 'rgba(255,255,255,0.05)',
            padding: '12px',
            borderRadius: '8px',
          }
        },
          React.createElement('div', { style: { fontSize: '11px', color: '#888' } }, 'SCORE'),
          React.createElement('div', { style: { fontSize: '18px', fontWeight: 'bold', color: '#f0f000' } }, score),
          React.createElement('div', { style: { fontSize: '11px', color: '#888', marginTop: '8px' } }, 'LINES'),
          React.createElement('div', { style: { fontSize: '16px', fontWeight: 'bold' } }, lines),
          React.createElement('div', { style: { fontSize: '11px', color: '#888', marginTop: '8px' } }, 'LEVEL'),
          React.createElement('div', { style: { fontSize: '16px', fontWeight: 'bold', color: '#00f000' } }, level)
        ),

        // Controls
        React.createElement('div', {
          style: {
            background: 'rgba(255,255,255,0.05)',
            padding: '12px',
            borderRadius: '8px',
            fontSize: '10px',
            color: '#666',
          }
        },
          React.createElement('div', null, 'Arrow keys: Move'),
          React.createElement('div', null, 'Up: Rotate'),
          React.createElement('div', null, 'Space: Drop'),
          React.createElement('div', null, 'P: Pause'),
          React.createElement('div', null, 'R: Restart')
        ),

        // Buttons
        React.createElement('div', {
          style: { display: 'flex', flexDirection: 'column', gap: '8px' }
        },
          React.createElement('button', {
            onClick: () => setIsPaused(p => !p),
            style: {
              padding: '8px',
              background: isPaused ? '#f0a000' : 'rgba(255,255,255,0.1)',
              border: 'none',
              borderRadius: '6px',
              color: '#fff',
              cursor: 'pointer',
              fontSize: '12px',
            }
          }, isPaused ? 'RESUME' : 'PAUSE'),
          React.createElement('button', {
            onClick: resetGame,
            style: {
              padding: '8px',
              background: 'rgba(255,255,255,0.1)',
              border: 'none',
              borderRadius: '6px',
              color: '#fff',
              cursor: 'pointer',
              fontSize: '12px',
            }
          }, 'RESTART')
        )
      )
    ),

    // Game over overlay
    gameOver && React.createElement('div', {
      style: {
        position: 'absolute',
        inset: 0,
        background: 'rgba(0,0,0,0.8)',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        gap: '16px',
      }
    },
      React.createElement('div', {
        style: { fontSize: '32px', fontWeight: 'bold', color: '#f00' }
      }, 'GAME OVER'),
      React.createElement('div', {
        style: { fontSize: '18px' }
      }, `Score: ${score}`),
      React.createElement('button', {
        onClick: resetGame,
        style: {
          padding: '12px 24px',
          background: '#00f0f0',
          border: 'none',
          borderRadius: '8px',
          color: '#000',
          cursor: 'pointer',
          fontSize: '16px',
          fontWeight: 'bold',
        }
      }, 'PLAY AGAIN')
    ),

    // Paused overlay
    isPaused && !gameOver && React.createElement('div', {
      style: {
        position: 'absolute',
        inset: 0,
        background: 'rgba(0,0,0,0.7)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
      }
    },
      React.createElement('div', {
        style: { fontSize: '28px', fontWeight: 'bold', color: '#f0a000' }
      }, 'PAUSED')
    )
  );
};
