import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "accountCheckbox",
    "pnlInput",
    "thresholdInput",
    "selectedCount",
    "submitButton",
    "accountRow",
  ];

  connect() {
    this.updateSelectedCount();
  }

  toggleAccount(event) {
    const checkbox = event.target;
    const accountRow = checkbox.closest(
      '[data-quick-trade-target="accountRow"]',
    );
    const pnlInput = accountRow.querySelector(
      '[data-quick-trade-target="pnlInput"]',
    );
    const thresholdInput = accountRow.querySelector(
      '[data-quick-trade-target="thresholdInput"]',
    );

    if (checkbox.checked) {
      // Enable P&L and threshold inputs, focus on P&L
      pnlInput.disabled = false;
      if (thresholdInput) thresholdInput.disabled = false;
      pnlInput.focus();
      accountRow.classList.add("bg-blue-50", "border-blue-200");
    } else {
      // Disable P&L and threshold inputs, clear P&L value
      pnlInput.disabled = true;
      pnlInput.value = "";
      if (thresholdInput) thresholdInput.disabled = true;
      accountRow.classList.remove("bg-blue-50", "border-blue-200");
    }

    this.updateSelectedCount();
    this.updateSubmitButton();
  }

  selectAll() {
    let firstInput = null;
    this.accountCheckboxTargets.forEach((checkbox, index) => {
      if (!checkbox.checked) {
        checkbox.checked = true;
        const accountRow = checkbox.closest(
          '[data-quick-trade-target="accountRow"]',
        );
        const pnlInput = accountRow.querySelector(
          '[data-quick-trade-target="pnlInput"]',
        );
        const thresholdInput = accountRow.querySelector(
          '[data-quick-trade-target="thresholdInput"]',
        );

        // Enable P&L and threshold inputs
        pnlInput.disabled = false;
        if (thresholdInput) thresholdInput.disabled = false;
        accountRow.classList.add("bg-blue-50", "border-blue-200");

        // Store first input for later focus
        if (index === 0) {
          firstInput = pnlInput;
        }
      }
    });

    this.updateSelectedCount();
    this.updateSubmitButton();

    // Focus on the first input field
    if (firstInput) {
      firstInput.focus();
    }
  }

  clearAll() {
    this.accountCheckboxTargets.forEach((checkbox) => {
      if (checkbox.checked) {
        checkbox.checked = false;
        this.toggleAccount({ target: checkbox });
      }
    });
  }

  updateSelectedCount() {
    const selectedCount = this.accountCheckboxTargets.filter(
      (cb) => cb.checked,
    ).length;
    this.selectedCountTarget.textContent = selectedCount;
  }

  updateSubmitButton() {
    const hasSelection = this.accountCheckboxTargets.some((cb) => cb.checked);
    const hasValidPnL = this.pnlInputTargets.some(
      (input) => !input.disabled && input.value.trim() !== "",
    );

    this.submitButtonTarget.disabled = !(hasSelection && hasValidPnL);

    if (this.submitButtonTarget.disabled) {
      this.submitButtonTarget.classList.add("opacity-50", "cursor-not-allowed");
    } else {
      this.submitButtonTarget.classList.remove(
        "opacity-50",
        "cursor-not-allowed",
      );
    }
  }

  // Listen for changes in P&L inputs to update submit button state
  pnlInputChanged() {
    this.updateSubmitButton();
  }
}
