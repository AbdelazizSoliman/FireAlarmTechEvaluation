import { Controller } from '@hotwired/stimulus';
import SlimSelect from 'slim-select';
import 'slim-select/styles';

export default class extends Controller {
  static targets = ['rows', 'selectedContainerList'];

  connect() {
    this.selectedIds = [];
    this.initializeSelectedIds();
    this.initializeSlimSelect();
  }

  initializeSelectedIds() {
    const existingIds = document
      .getElementById('disposal_container_ids')
      .value.split(',');
    this.selectedIds = existingIds.filter((id) => id);
  }

  initializeSlimSelect() {
    this.slimSelect = new SlimSelect({
      select: '#container-multiselect',
      showSearch: true,
      settings: {
        allowDeselect: true,
      },
      onChange: (info) => {
        this.addRow(info);
      },
    });

    this.element
      .querySelector('#container-multiselect')
      .addEventListener('change', this.addRow.bind(this));
  }

  addRow(info) {
    const containerId = info.value;
    const containerName = info.text;

    if (containerId && !this.selectedIds.includes(containerId)) {
      // Add tag-like input
      const tag = document.createElement('div');
      tag.classList.add(
        'flex',
        'items-center',
        'bg-red-100',
        'border',
        'border-red-200',
        'text-red-600',
        'px-2',
        'py-1',
        'rounded-full',
        'mr-1',
        'mb-1'
      );
      tag.setAttribute('data-multiselect-id', containerId);
      tag.innerHTML = `
        ${containerName}
        <button type="button" class="ml-2 text-red-600" data-action="multiselect#removeTag" data-multiselect-id="${containerId}">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M10 9.293l3.293-3.293a1 1 0 011.414 0l.086.086a1 1 0 010 1.414L11.414 10l3.293 3.293a1 1 0 01.086 1.32l-.086.086a1 1 0 01-1.414 0L10 11.414l-3.293 3.293a1 1 0 01-1.32.086l-.086-.086a1 1 0 010-1.414L8.586 10 5.293 6.707a1 1 0 01-.086-1.32l.086-.086a1 1 0 011.414 0L10 8.586z" clip-rule="evenodd" />
          </svg>
        </button>
      `;
      this.selectedContainerListTarget.appendChild(tag);

      // Add detailed input row
      const row = document.createElement('div');
      row.classList.add(
        'bg-gray-100',
        'border',
        'rounded',
        'p-4',
        'flex',
        'items-center',
        'space-x-4',
        'mt-2'
      );
      row.setAttribute('data-multiselect-id', containerId);
      row.innerHTML = `
        <span class="text-red-600">${containerName}</span>
        <label class="flex items-center">
          MXI Cost: $
          <input type="number" name="disposal_cost[disposal_containers_attributes][${containerId}][mxi_cost]" class="ml-2 border rounded py-1 px-2" required>
        </label>
        <label class="flex items-center">
          Client Charge: $
          <input type="number" name="disposal_cost[disposal_containers_attributes][${containerId}][client_charge]" class="ml-2 border rounded py-1 px-2" required>
        </label>
        <input type="hidden" name="disposal_cost[disposal_containers_attributes][${containerId}][name]" value="${containerName}">
        <input type="hidden" name="disposal_cost[disposal_containers_attributes][${containerId}][_destroy]" value="false">
      `;
      this.rowsTarget.appendChild(row);

      this.selectedIds.push(containerId);
      document.getElementById('disposal_container_ids').value =
        this.selectedIds.join(',');

      // Remove the selected option from Slim Select
      this.slimSelect.set('');
    }
  }

  removeTag(event) {
    const containerId = event.currentTarget.getAttribute('data-multiselect-id');

    // Remove tag
    const tag = this.selectedContainerListTarget.querySelector(
      `[data-multiselect-id="${containerId}"]`
    );
    if (tag) {
      tag.remove();
    }

    // Remove corresponding detailed input row
    const row = this.rowsTarget.querySelector(
      `[data-multiselect-id="${containerId}"]`
    );
    if (row) {
      row.remove();
    }

    // Update selectedIds
    this.selectedIds = this.selectedIds.filter((id) => id !== containerId);
    document.getElementById('disposal_container_ids').value =
      this.selectedIds.join(',');
  }
}
