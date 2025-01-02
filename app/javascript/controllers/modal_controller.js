// app/javascript/controllers/modal_controller.js

import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['modal'];

  connect() {
    // No need to add a listener for background clicks anymore
  }

  close(event) {
    // Check if the event is triggered by a button, then remove the modal
    if (event && event.currentTarget.tagName === 'BUTTON') {
      this.modalTarget.remove();
    }
  }
}
