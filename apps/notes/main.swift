// Notes App for WeaveOS

const App = () => {
  const [notes, setNotes] = useState(() => {
    const saved = localStorage.getItem('weaveOS_notes');
    if (saved) {
      try { return JSON.parse(saved); } catch { return []; }
    }
    return [{ id: 1, title: 'Welcome', content: 'Start writing your notes here!', created: Date.now() }];
  });
  const [activeId, setActiveId] = useState(notes[0]?.id || null);
  const [search, setSearch] = useState('');

  useEffect(() => {
    localStorage.setItem('weaveOS_notes', JSON.stringify(notes));
  }, [notes]);

  const addNote = () => {
    const newNote = { id: Date.now(), title: 'New Note', content: '', created: Date.now() };
    setNotes([newNote, ...notes]);
    setActiveId(newNote.id);
  };

  const deleteNote = (id) => {
    const updated = notes.filter(n => n.id !== id);
    setNotes(updated);
    if (activeId === id) setActiveId(updated[0]?.id || null);
  };

  const updateNote = (id, field, value) => {
    setNotes(notes.map(n => n.id === id ? { ...n, [field]: value } : n));
  };

  const filtered = notes.filter(n =>
    n.title.toLowerCase().includes(search.toLowerCase()) ||
    n.content.toLowerCase().includes(search.toLowerCase())
  );
  const activeNote = notes.find(n => n.id === activeId);

  const sidebarStyle = { width: '240px', borderRight: '1px solid rgba(255,255,255,0.1)', display: 'flex', flexDirection: 'column' };
  const noteItemStyle = (isActive) => ({ padding: '12px 16px', cursor: 'pointer', borderBottom: '1px solid rgba(255,255,255,0.05)', background: isActive ? 'rgba(255,255,255,0.1)' : 'transparent' });
  const btnStyle = { padding: '8px 16px', borderRadius: '8px', border: 'none', cursor: 'pointer', fontSize: '14px', background: 'rgba(255,255,255,0.1)', color: '#fff' };

  return React.createElement('div', { style: { height: '100%', display: 'flex', background: 'linear-gradient(135deg, #0a0a12, #1a1a2e)', color: '#fff', fontFamily: 'system-ui' } },
    React.createElement('div', { style: sidebarStyle },
      React.createElement('div', { style: { padding: '16px', borderBottom: '1px solid rgba(255,255,255,0.1)' } },
        React.createElement('input', {
          type: 'text',
          placeholder: 'Search notes...',
          value: search,
          onChange: (e) => setSearch(e.target.value),
          style: { width: '100%', padding: '10px 14px', borderRadius: '8px', border: 'none', background: 'rgba(255,255,255,0.1)', color: '#fff', fontSize: '14px', outline: 'none', boxSizing: 'border-box' }
        })
      ),
      React.createElement('div', { style: { flex: 1, overflow: 'auto' } },
        filtered.map(note => React.createElement('div', {
          key: note.id,
          onClick: () => setActiveId(note.id),
          style: noteItemStyle(note.id === activeId)
        },
          React.createElement('div', { style: { fontWeight: 500, marginBottom: '4px', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' } }, note.title || 'Untitled'),
          React.createElement('div', { style: { fontSize: '12px', color: 'rgba(255,255,255,0.5)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' } }, note.content.slice(0, 50) || 'No content')
        ))
      ),
      React.createElement('div', { style: { padding: '16px', borderTop: '1px solid rgba(255,255,255,0.1)' } },
        React.createElement('button', { onClick: addNote, style: { ...btnStyle, width: '100%', background: 'linear-gradient(135deg, #6366f1, #8b5cf6)' } }, '+ New Note')
      )
    ),
    React.createElement('div', { style: { flex: 1, display: 'flex', flexDirection: 'column', padding: '20px' } },
      activeNote ? React.createElement(React.Fragment, null,
        React.createElement('div', { style: { display: 'flex', gap: '12px', marginBottom: '16px' } },
          React.createElement('input', {
            type: 'text',
            value: activeNote.title,
            onChange: (e) => updateNote(activeNote.id, 'title', e.target.value),
            placeholder: 'Note title...',
            style: { flex: 1, padding: '12px 16px', borderRadius: '8px', border: 'none', background: 'rgba(255,255,255,0.1)', color: '#fff', fontSize: '18px', fontWeight: 500, outline: 'none' }
          }),
          React.createElement('button', { onClick: () => deleteNote(activeNote.id), style: { ...btnStyle, background: 'rgba(239, 68, 68, 0.2)', color: '#ef4444' } }, 'Delete')
        ),
        React.createElement('textarea', {
          value: activeNote.content,
          onChange: (e) => updateNote(activeNote.id, 'content', e.target.value),
          placeholder: 'Start writing...',
          style: { flex: 1, padding: '16px', borderRadius: '8px', border: 'none', background: 'rgba(255,255,255,0.05)', color: '#fff', fontSize: '15px', lineHeight: 1.6, resize: 'none', outline: 'none', fontFamily: 'system-ui' }
        }),
        React.createElement('div', { style: { marginTop: '12px', fontSize: '12px', color: 'rgba(255,255,255,0.4)' } },
          'Created: ' + new Date(activeNote.created).toLocaleString()
        )
      ) : React.createElement('div', { style: { flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'rgba(255,255,255,0.4)' } },
        React.createElement('div', { style: { textAlign: 'center' } },
          React.createElement('div', { style: { fontSize: '48px', marginBottom: '16px' } }, '📝'),
          React.createElement('div', null, 'Select a note or create a new one')
        )
      )
    )
  );
};
