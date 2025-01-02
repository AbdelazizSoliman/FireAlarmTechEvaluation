import { Controller } from 'stimulus';
import TomSelect from 'tom-select';

export default class extends Controller {
  connect() {
    this.initializeTomSelect();
  }

  disconnect() {
    this.destroyTomSelect();
  }

  initializeTomSelect() {
    if (!this.element) return;

    this.select = new TomSelect(this.element, {
      sortField: {
        field: 'text',
        direction: 'asc',
      },
      ...this.optionsValue, // Spread other potential options passed via data attributes
    });
  }

  destroyTomSelect() {
    if (this.select) {
      this.select.destroy();
    }
  }
}
