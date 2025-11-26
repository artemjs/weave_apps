// Notes App for WeaveOS
// Written in Swift-like syntax

var notes = []
var activeNoteId = nil
var searchQuery = ""

func loadNotes() {
    let saved = localStorage.getItem("weaveOS_notes")
    if (saved) {
        notes = JSON.parse(saved)
    } else {
        notes = [{
            id: 1,
            title: "Welcome",
            content: "Start writing your notes here!",
            created: Date.now()
        }]
    }
    if (notes.length > 0) {
        activeNoteId = notes[0].id
    }
}

func saveNotes() {
    localStorage.setItem("weaveOS_notes", JSON.stringify(notes))
}

func addNote() {
    let newNote = {
        id: Date.now(),
        title: "New Note",
        content: "",
        created: Date.now()
    }
    notes.unshift(newNote)
    activeNoteId = newNote.id
    saveNotes()
}

func deleteNote(id) {
    notes = notes.filter(n => n.id != id)
    if (activeNoteId == id) {
        activeNoteId = notes.length > 0 ? notes[0].id : nil
    }
    saveNotes()
}

func updateNote(id, title, content) {
    for note in notes {
        if (note.id == id) {
            note.title = title
            note.content = content
        }
    }
    saveNotes()
}

func setActiveNote(id) {
    activeNoteId = id
}

func setSearchQuery(query) {
    searchQuery = query
}

func getFilteredNotes() {
    let q = searchQuery.toLowerCase()
    return notes.filter(n =>
        n.title.toLowerCase().includes(q) ||
        n.content.toLowerCase().includes(q)
    )
}

func getActiveNote() {
    return notes.find(n => n.id == activeNoteId)
}

func render() {
    print("Notes App - " + notes.length + " notes")
}

// Initialize
loadNotes()
