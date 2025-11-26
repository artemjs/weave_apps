// Clock App for WeaveOS

const App = () => {
  const [time, setTime] = useState(new Date());
  const [mode, setMode] = useState('clock');
  const [stopwatchTime, setStopwatchTime] = useState(0);
  const [stopwatchRunning, setStopwatchRunning] = useState(false);
  const [timerTime, setTimerTime] = useState(300);
  const [timerRunning, setTimerRunning] = useState(false);

  useEffect(() => {
    const interval = setInterval(() => setTime(new Date()), 1000);
    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    if (!stopwatchRunning) return;
    const interval = setInterval(() => setStopwatchTime(t => t + 10), 10);
    return () => clearInterval(interval);
  }, [stopwatchRunning]);

  useEffect(() => {
    if (!timerRunning || timerTime <= 0) return;
    const interval = setInterval(() => {
      setTimerTime(t => {
        if (t <= 1) { setTimerRunning(false); return 0; }
        return t - 1;
      });
    }, 1000);
    return () => clearInterval(interval);
  }, [timerRunning, timerTime]);

  const formatStopwatch = (ms) => {
    const mins = Math.floor(ms / 60000);
    const secs = Math.floor((ms % 60000) / 1000);
    const centis = Math.floor((ms % 1000) / 10);
    return String(mins).padStart(2, '0') + ':' + String(secs).padStart(2, '0') + '.' + String(centis).padStart(2, '0');
  };

  const formatTimer = (secs) => {
    const mins = Math.floor(secs / 60);
    const s = secs % 60;
    return String(mins).padStart(2, '0') + ':' + String(s).padStart(2, '0');
  };

  const btnStyle = { padding: '8px 16px', borderRadius: '8px', border: 'none', cursor: 'pointer', fontSize: '14px' };

  return React.createElement('div', { style: { height: '100%', display: 'flex', flexDirection: 'column', background: 'linear-gradient(135deg, #0a0a12, #1a1a2e)', color: '#fff', fontFamily: 'system-ui' } },
    React.createElement('div', { style: { display: 'flex', gap: '8px', padding: '16px', borderBottom: '1px solid rgba(255,255,255,0.1)' } },
      ['clock', 'stopwatch', 'timer'].map(m => React.createElement('button', { key: m, onClick: () => setMode(m), style: { ...btnStyle, background: mode === m ? 'rgba(255,255,255,0.15)' : 'transparent', color: mode === m ? '#fff' : 'rgba(255,255,255,0.5)' } }, m.charAt(0).toUpperCase() + m.slice(1)))
    ),
    React.createElement('div', { style: { flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '40px' } },
      mode === 'clock' && React.createElement('div', { style: { textAlign: 'center' } },
        React.createElement('div', { style: { fontSize: '64px', fontWeight: 200, fontFamily: 'monospace' } }, time.toLocaleTimeString()),
        React.createElement('div', { style: { fontSize: '18px', color: 'rgba(255,255,255,0.5)', marginTop: '16px' } }, time.toLocaleDateString(undefined, { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }))
      ),
      mode === 'stopwatch' && React.createElement('div', { style: { textAlign: 'center' } },
        React.createElement('div', { style: { fontSize: '56px', fontFamily: 'monospace', marginBottom: '24px' } }, formatStopwatch(stopwatchTime)),
        React.createElement('div', { style: { display: 'flex', gap: '12px' } },
          React.createElement('button', { onClick: () => setStopwatchRunning(!stopwatchRunning), style: { ...btnStyle, background: stopwatchRunning ? '#ef4444' : '#22c55e', color: '#fff' } }, stopwatchRunning ? 'Stop' : 'Start'),
          React.createElement('button', { onClick: () => { setStopwatchRunning(false); setStopwatchTime(0); }, style: { ...btnStyle, background: 'rgba(255,255,255,0.1)', color: '#fff' } }, 'Reset')
        )
      ),
      mode === 'timer' && React.createElement('div', { style: { textAlign: 'center' } },
        React.createElement('div', { style: { fontSize: '56px', fontFamily: 'monospace', marginBottom: '24px', color: timerTime === 0 ? '#ef4444' : '#fff' } }, formatTimer(timerTime)),
        React.createElement('div', { style: { display: 'flex', gap: '12px', marginBottom: '20px' } },
          React.createElement('button', { onClick: () => setTimerRunning(!timerRunning), style: { ...btnStyle, background: timerRunning ? '#ef4444' : '#22c55e', color: '#fff' } }, timerRunning ? 'Pause' : 'Start'),
          React.createElement('button', { onClick: () => { setTimerRunning(false); setTimerTime(300); }, style: { ...btnStyle, background: 'rgba(255,255,255,0.1)', color: '#fff' } }, 'Reset')
        ),
        React.createElement('div', { style: { display: 'flex', gap: '8px' } },
          [60, 180, 300, 600].map(secs => React.createElement('button', { key: secs, onClick: () => { setTimerTime(secs); setTimerRunning(false); }, style: { ...btnStyle, background: 'rgba(255,255,255,0.1)', color: '#fff' } }, secs < 60 ? secs + 's' : (secs / 60) + 'm'))
        )
      )
    )
  );
};
