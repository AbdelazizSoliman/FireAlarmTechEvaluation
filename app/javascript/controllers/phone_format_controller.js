import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['input'];

  connect() {
    this.inputTarget.addEventListener(
      'input',
      this.formatPhoneNumber.bind(this)
    );
  }

  formatPhoneNumber(event) {
    let input = event.target.value.replace(/\D/g, '');
    if (input.length > 10) {
      input = input.substring(0, 10);
    }
    let formatted = '';
    if (input.length > 0) {
      formatted += `+1 `;
    }
    if (input.length > 0) {
      formatted += `(${input.substring(0, 3)}`;
    }
    if (input.length >= 4) {
      formatted += `) ${input.substring(3, 6)}`;
    }
    if (input.length >= 7) {
      formatted += `-${input.substring(6, 10)}`;
    }
    this.inputTarget.value = formatted;
  }
}
