// Clicker Game for WeaveOS

const App = () => {
  const [clicks, setClicks] = useState(0);
  const [clickPower, setClickPower] = useState(1);
  const [autoClickers, setAutoClickers] = useState(0);
  const [multiplier, setMultiplier] = useState(1);
  const [totalClicks, setTotalClicks] = useState(0);
  const [particles, setParticles] = useState([]);

  // Auto clicker effect
  useEffect(() => {
    if (autoClickers === 0) return;
    const interval = setInterval(() => {
      setClicks(c => c + autoClickers);
      setTotalClicks(t => t + autoClickers);
    }, 1000);
    return () => clearInterval(interval);
  }, [autoClickers]);

  // Remove particles after animation
  useEffect(() => {
    if (particles.length === 0) return;
    const timeout = setTimeout(() => {
      setParticles(p => p.slice(1));
    }, 500);
    return () => clearTimeout(timeout);
  }, [particles]);

  const handleClick = (e) => {
    const gain = clickPower * multiplier;
    setClicks(c => c + gain);
    setTotalClicks(t => t + gain);

    // Add particle effect
    const rect = e.currentTarget.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    setParticles(p => [...p, { id: Date.now(), x, y, value: gain }]);
  };

  const upgrades = [
    { id: 'power', name: 'Click Power', desc: '+1 per click', cost: Math.floor(10 * Math.pow(1.5, clickPower - 1)), effect: () => setClickPower(p => p + 1) },
    { id: 'auto', name: 'Auto Clicker', desc: '+1 per second', cost: Math.floor(50 * Math.pow(1.8, autoClickers)), effect: () => setAutoClickers(a => a + 1) },
    { id: 'multi', name: 'Multiplier', desc: 'x2 all clicks', cost: Math.floor(500 * Math.pow(3, multiplier - 1)), effect: () => setMultiplier(m => m * 2) },
  ];

  const buyUpgrade = (upgrade) => {
    if (clicks >= upgrade.cost) {
      setClicks(c => c - upgrade.cost);
      upgrade.effect();
    }
  };

  const formatNumber = (num) => {
    if (num >= 1e9) return (num / 1e9).toFixed(1) + 'B';
    if (num >= 1e6) return (num / 1e6).toFixed(1) + 'M';
    if (num >= 1e3) return (num / 1e3).toFixed(1) + 'K';
    return num.toString();
  };

  const btnStyle = { padding: '12px 24px', borderRadius: '12px', border: 'none', cursor: 'pointer', fontSize: '14px', fontWeight: 600, transition: 'all 0.2s' };

  return React.createElement('div', {
    style: {
      height: '100%',
      display: 'flex',
      flexDirection: 'column',
      background: 'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
      color: '#fff',
      fontFamily: 'system-ui',
      overflow: 'hidden'
    }
  },
    // Header with stats
    React.createElement('div', {
      style: {
        padding: '20px',
        textAlign: 'center',
        borderBottom: '1px solid rgba(255,255,255,0.1)',
        background: 'rgba(0,0,0,0.2)'
      }
    },
      React.createElement('div', { style: { fontSize: '14px', color: 'rgba(255,255,255,0.5)', marginBottom: '8px' } }, 'TOTAL CLICKS'),
      React.createElement('div', { style: { fontSize: '42px', fontWeight: 700, background: 'linear-gradient(135deg, #f093fb, #f5576c)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' } }, formatNumber(clicks)),
      React.createElement('div', { style: { display: 'flex', justifyContent: 'center', gap: '24px', marginTop: '12px', fontSize: '12px', color: 'rgba(255,255,255,0.4)' } },
        React.createElement('span', null, '⚡ ', clickPower * multiplier, '/click'),
        React.createElement('span', null, '🤖 ', autoClickers, '/sec'),
        React.createElement('span', null, '✨ x', multiplier)
      )
    ),

    // Main click area
    React.createElement('div', {
      style: {
        flex: 1,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        position: 'relative',
        overflow: 'hidden'
      }
    },
      // Click button
      React.createElement('button', {
        onClick: handleClick,
        style: {
          width: '180px',
          height: '180px',
          borderRadius: '50%',
          border: 'none',
          background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
          boxShadow: '0 10px 40px rgba(102, 126, 234, 0.4), inset 0 -5px 20px rgba(0,0,0,0.2)',
          cursor: 'pointer',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          fontSize: '64px',
          transition: 'transform 0.1s, box-shadow 0.1s',
          position: 'relative',
          zIndex: 1
        },
        onMouseDown: (e) => { e.currentTarget.style.transform = 'scale(0.95)'; },
        onMouseUp: (e) => { e.currentTarget.style.transform = 'scale(1)'; },
        onMouseLeave: (e) => { e.currentTarget.style.transform = 'scale(1)'; }
      }, '👆'),

      // Particles
      particles.map(p => React.createElement('div', {
        key: p.id,
        style: {
          position: 'absolute',
          left: '50%',
          top: '50%',
          transform: 'translate(-50%, -50%)',
          fontSize: '24px',
          fontWeight: 700,
          color: '#4ade80',
          pointerEvents: 'none',
          animation: 'floatUp 0.5s ease-out forwards',
          textShadow: '0 0 10px rgba(74, 222, 128, 0.5)'
        }
      }, '+', p.value))
    ),

    // Upgrades shop
    React.createElement('div', {
      style: {
        padding: '16px',
        borderTop: '1px solid rgba(255,255,255,0.1)',
        background: 'rgba(0,0,0,0.3)'
      }
    },
      React.createElement('div', { style: { fontSize: '12px', color: 'rgba(255,255,255,0.4)', marginBottom: '12px', textTransform: 'uppercase', letterSpacing: '1px' } }, 'Upgrades'),
      React.createElement('div', { style: { display: 'flex', gap: '10px', overflowX: 'auto', paddingBottom: '8px' } },
        upgrades.map(upgrade => {
          const canBuy = clicks >= upgrade.cost;
          return React.createElement('button', {
            key: upgrade.id,
            onClick: () => buyUpgrade(upgrade),
            disabled: !canBuy,
            style: {
              ...btnStyle,
              minWidth: '140px',
              background: canBuy ? 'linear-gradient(135deg, rgba(74, 222, 128, 0.2), rgba(74, 222, 128, 0.1))' : 'rgba(255,255,255,0.05)',
              border: canBuy ? '1px solid rgba(74, 222, 128, 0.3)' : '1px solid rgba(255,255,255,0.1)',
              color: canBuy ? '#4ade80' : 'rgba(255,255,255,0.3)',
              opacity: canBuy ? 1 : 0.6,
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'flex-start',
              gap: '4px'
            }
          },
            React.createElement('span', { style: { fontSize: '13px' } }, upgrade.name),
            React.createElement('span', { style: { fontSize: '10px', opacity: 0.7 } }, upgrade.desc),
            React.createElement('span', { style: { fontSize: '12px', marginTop: '4px' } }, '💰 ', formatNumber(upgrade.cost))
          );
        })
      )
    ),

    // CSS for animation
    React.createElement('style', null, `
      @keyframes floatUp {
        0% { opacity: 1; transform: translate(-50%, -50%) translateY(0); }
        100% { opacity: 0; transform: translate(-50%, -50%) translateY(-60px); }
      }
    `)
  );
};
