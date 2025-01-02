// app/javascript/controllers/alerts_controller.js
import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['alert'];

  connect() {
    this.autoHide();
  }

  autoHide() {
    setTimeout(() => {
      this.alertTargets.forEach((alert) => {
        alert.style.display = 'none';
      });
    }, 3000);
  }

  hide(event) {
    event.target.closest('.alert').style.display = 'none';
  }
}
