import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["optionalFields", "toggleIcon"];

  toggleOptional() {
    this.optionalFieldsTarget.classList.toggle("hidden");
    this.toggleIconTarget.classList.toggle("rotate-180");
  }
}
