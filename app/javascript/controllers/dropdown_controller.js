// app/javascript/controllers/dropdown_controller.js
import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['menu'];

  connect() {
    this.isOpen = false;
  }

  toggle() {
    this.isOpen = !this.isOpen;
    this.menuTarget.classList.toggle('hidden', !this.isOpen);
  }
}
