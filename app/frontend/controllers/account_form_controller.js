import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["templateSelect", "nameField"];

  connect() {
    this.templateData = this.buildTemplateData();
  }

  buildTemplateData() {
    const data = {};
    const options = this.templateSelectTarget.querySelectorAll("option");

    options.forEach((option) => {
      if (option.value) {
        // Extract template name from the option text
        // Format is "#ID - NAME (FIRM NAME)"
        const text = option.text;
        const match = text.match(/#\d+ - (.+?) \(/);
        if (match) {
          data[option.value] = match[1];
        }
      }
    });

    return data;
  }

  updateName() {
    const templateId = this.templateSelectTarget.value;
    if (templateId && this.templateData[templateId]) {
      this.nameFieldTarget.value = this.templateData[templateId];
    }
  }
}
