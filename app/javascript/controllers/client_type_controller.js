import { Controller } from '@hotwired/stimulus';

/*
 * Usage
 * =====
 *
 * add data-controller="client-type" to common ancestor
 *
 * Actions:
 * data-action="client-type#toggle"
 *
 * Targets:
 * data-client-type-target="newClientForm existingClientForm btnWrapper modalHeader"
 *
 */
export default class extends Controller {
  static targets = ['newClientForm', 'existingClientForm', 'btnWrapper', 'modalHeader'];

  toggle(event) {
    // Prevent default link or button behavior
    event.preventDefault();

    // Get the client type (new or existing) from the button's data attribute
    const clientType = event.target.dataset.clientType;

    // Hide both forms initially and the button wrapper
    this.newClientFormTarget.classList.add('hidden');
    this.existingClientFormTarget.classList.add('hidden');
    this.btnWrapperTarget.classList.add('hidden');
    this.modalHeaderTarget.classList.add('hidden');

    // Show the correct form based on the selected client type
    if (clientType === 'new') {
      this.newClientFormTarget.classList.remove('hidden');
    } else if (clientType === 'existing') {
      this.existingClientFormTarget.classList.remove('hidden');
    }
  }
}
