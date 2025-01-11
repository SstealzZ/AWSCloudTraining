const config = {
    apiUrl: "http://127.0.0.1:8000/notes", // API URL
};

// Récupérer toutes les notes
async function fetchNotes() {
    const response = await fetch(config.apiUrl);
    const notes = await response.json();
    const container = document.getElementById("notesContainer");
    container.innerHTML = notes.map(note =>
        `<div class="note">
            <h3>${note.title}</h3>
            <p>${note.content}</p>
            <button onclick="deleteNote(${note.id})">Supprimer</button>
        </div>`
    ).join("");
}

// Ajouter une note
document.getElementById("noteForm").addEventListener("submit", async (e) => {
    e.preventDefault();
    const title = document.getElementById("title").value;
    const content = document.getElementById("content").value;
    await fetch(config.apiUrl, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ title, content })
    });
    fetchNotes();
});

// Supprimer une note
async function deleteNote(id) {
    await fetch(`${config.apiUrl}/${id}`, { method: "DELETE" });
    fetchNotes();
}

// Charger les notes au démarrage
fetchNotes();
