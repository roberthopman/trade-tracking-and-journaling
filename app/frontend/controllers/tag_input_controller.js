import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "tagsList", "hiddenInput", "suggestions"];
  static values = { tags: Array, available: Array };

  connect() {
    this.selectedTags = this.tagsValue || [];
    this.renderTags();
    this.renderSuggestions();
  }

  addTag(event) {
    if (event.key === "Enter" || event.key === ",") {
      event.preventDefault();
      const tagName = this.inputTarget.value.trim();

      if (tagName && !this.selectedTags.includes(tagName)) {
        this.selectedTags.push(tagName);
        this.inputTarget.value = "";
        this.renderTags();
        this.updateHiddenInput();
      }
    }
  }

  removeTag(event) {
    // Get the button element (might be clicking on SVG or path inside)
    const button = event.target.closest("button");
    const tagName = button.dataset.tagName;
    this.selectedTags = this.selectedTags.filter((t) => t !== tagName);
    this.renderTags();
    this.updateHiddenInput();
    this.renderSuggestions();
  }

  selectSuggestion(event) {
    const tagName = event.target.dataset.tagName;
    if (!this.selectedTags.includes(tagName)) {
      this.selectedTags.push(tagName);
      this.renderTags();
      this.updateHiddenInput();
      this.renderSuggestions();
    }
  }

  renderTags() {
    this.tagsListTarget.innerHTML = this.selectedTags
      .map(
        (tag) => `
      <span class="inline-flex items-center gap-1 px-2 py-1 bg-blue-100 text-blue-800 rounded-md text-sm">
        ${tag}
        <button type="button"
                data-tag-name="${tag}"
                data-action="click->tag-input#removeTag"
                class="hover:text-blue-900">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </span>
    `,
      )
      .join("");
  }

  updateHiddenInput() {
    this.hiddenInputTarget.value = this.selectedTags.join(",");
  }

  renderSuggestions() {
    if (!this.hasSuggestionsTarget || !this.availableValue) return;

    const availableTags = this.availableValue.filter(
      (tag) => !this.selectedTags.includes(tag),
    );

    if (availableTags.length === 0) {
      this.suggestionsTarget.innerHTML = "";
      return;
    }

    this.suggestionsTarget.innerHTML = `
      <div class="text-xs text-gray-600 mb-1">Click to add existing tags:</div>
      <div class="flex flex-wrap gap-1">
        ${availableTags
          .map(
            (tag) => `
          <button type="button"
                  data-tag-name="${tag}"
                  data-action="click->tag-input#selectSuggestion"
                  class="inline-flex items-center px-2 py-1 bg-gray-100 text-gray-700 rounded-md text-xs hover:bg-gray-200">
            ${tag}
          </button>
        `,
          )
          .join("")}
      </div>
    `;
  }
}
