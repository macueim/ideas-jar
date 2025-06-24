function ideasApp() {
  return {
    ideas: [],
    searchQuery: '',
    showModal: false,
    form: { content: '', is_voice: false },
    editIndex: null,

    init() {
      this.fetchIdeas();
    },

    async fetchIdeas() {
      try {
        const response = await fetch('https://ideas-jar.onrender.com/ideas');
        if (response.ok) {
          this.ideas = await response.json();
        } else {
          console.error('Failed to fetch ideas');
        }
      } catch (error) {
        console.error('Error fetching ideas:', error);
      }
    },

    filteredIdeas() {
      return this.ideas.filter(i => i.content.toLowerCase().includes(this.searchQuery.toLowerCase()));
    },

    openModal() {
      this.editIndex = null;
      this.form = { content: '', is_voice: false };
      this.showModal = true;
    },

    editIdea(idea) {
      this.editIndex = this.ideas.findIndex(i => i.id === idea.id);
      this.form = { content: idea.content, is_voice: idea.is_voice };
      this.showModal = true;
    },

    async deleteIdea(id) {
      try {
        const response = await fetch(`https://ideas-jar.onrender.com/ideas/${id}`, {
          method: 'DELETE',
        });

        if (response.ok) {
          this.ideas = this.ideas.filter(i => i.id !== id);
        } else {
          console.error('Failed to delete idea');
        }
      } catch (error) {
        console.error('Error deleting idea:', error);
      }
    },

    async submitIdea() {
      try {
        if (this.editIndex !== null) {
          // Update existing idea
          const id = this.ideas[this.editIndex].id;
          const response = await fetch(`https://ideas-jar.onrender.com/ideas/${id}`, {
            method: 'PUT',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify(this.form),
          });

          if (response.ok) {
            const updatedIdea = await response.json();
            this.ideas[this.editIndex] = updatedIdea;
          } else {
            console.error('Failed to update idea');
          }
        } else {
          // Create new idea
          const response = await fetch('https://ideas-jar.onrender.com/ideas', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify(this.form),
          });

          if (response.ok) {
            const newIdea = await response.json();
            this.ideas.unshift(newIdea);
          } else {
            console.error('Failed to create idea');
          }
        }
        this.closeModal();
      } catch (error) {
        console.error('Error submitting idea:', error);
      }
    },

    closeModal() {
      this.showModal = false;
    },

    formatDate(date) {
      const d = new Date(date);
      const now = new Date();
      const diff = Math.floor((now - d) / (1000 * 60 * 60 * 24));
      if (diff === 0) return 'Today';
      if (diff === 1) return 'Yesterday';
      if (diff < 7) return `${diff} days ago`;
      return d.toLocaleDateString();
    },
  }
}
