import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['tabContent'];

  connect() {
    // Initial hash handling on page load
    this.checkHash();

    // Listen for hash changes
    window.addEventListener('hashchange', this.checkHash.bind(this));
  }

  disconnect() {
    // Clean up the event listener when the controller is disconnected
    window.removeEventListener('hashchange', this.checkHash.bind(this));
  }

  checkHash() {
    const hash = window.location.hash.substring(1); // Remove the `#`
    console.log('hash', hash);
    if (hash) {
      this.activateTab(hash);
    } else {
      this.activateTab('general'); // Default to the general tab if no hash
    }
  }

  switchTab(event) {
    const targetTab = event.currentTarget.dataset.tab;
    this.activateTab(targetTab);
  }

  activateTab(targetTab) {
    // Show the target tab content and hide others
    this.tabContentTargets.forEach((element) => {
      if (element.dataset.tabsTabContent === targetTab) {
        element.classList.remove('hidden');
      } else {
        element.classList.add('hidden');
      }
    });

    // Update button styles to reflect active tab
    this.element.querySelectorAll('button').forEach((button) => {
      if (button.dataset.tab === targetTab) {
        button.classList.replace('bg-gray-200', 'bg-red-700');
        button.classList.replace('text-gray-600', 'text-white');
      } else {
        button.classList.replace('bg-red-700', 'bg-gray-200');
        button.classList.replace('text-white', 'text-gray-600');
      }
    });

    // Update the URL hash without reloading the page
    history.pushState(null, null, `#${targetTab}`);
  }
}
