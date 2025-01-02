import { Controller } from 'stimulus';
import TomSelect from 'tom-select';

export default class extends Controller {
  static targets = ['containerList'];

  connect() {
    this.initializeTomSelect();
    this.initializeSelectedContainers(); // Handle initial values
  }

  initializeTomSelect() {
    if (!this.element) return;

    this.select = new TomSelect(this.element, {
      create: (input) => this.addNewWasteCategory(input, this.element),
      onItemAdd: (value, item) => this.addContainerRow(value, item),
      onItemRemove: (value) => this.removeContainerRow(value),
      sortField: {
        field: 'text',
        direction: 'asc',
      },
      ...this.optionsValue,
    });
  }

  initializeSelectedContainers() {
    const existingContainersInput = document.getElementById(
      'existing-containers-data'
    );
    const existingContainers = existingContainersInput
      ? JSON.parse(existingContainersInput.value)
      : [];
    console.log('existingContainers', existingContainers);
    existingContainers.forEach((container, index) => {
      this.addContainerRow(
        container.name,
        null,
        container.cost,
        container.charge,
        container.id || index
      );
    });
    const selectElement = document.querySelector('#container-multiselect');
    if (selectElement) {
      Array.from(selectElement.selectedOptions).forEach((option) => {
        const existingContainer = existingContainers.find(
          (c) => c.name === option.value
        );

        console.log('option', option);
        console.log('existingContainer', existingContainer);
        if (existingContainer) {
          this.addExistingContainerRow(existingContainer);
        }
      });
    } else {
      console.error('Multi-select element not found.');
    }
  }
  addExistingContainerRow(existingContainer) {
    console.log('existingContainer...', existingContainer);
    const containerRow = document.createElement('div');
    containerRow.classList.add(
      'flex',
      'justify-between',
      'items-center',
      'bg-gray-100',
      'p-2',
      'mb-2',
      'border',
      'rounded'
    );
    containerRow.setAttribute('data-container-id', existingContainer.name);

    containerRow.innerHTML = `
      <span>Container Name: <span class="text-red-500 font-semibold mx-2">${
        existingContainer.name
      }</span></span>
      <div class="flex items-center">
        <label class="mr-2">Disposal Cost: $</label>
        <input type="number" name="disposal_cost[disposal_containers_attributes][${
          existingContainer.id
        }][cost]" class="border rounded p-1 w-20 text-center" value="${
      existingContainer.cost
    }" />
        <label class="ml-4 mr-2">Disposal Charge: $</label>
        <input type="number" name="disposal_cost[disposal_containers_attributes][${
          existingContainer.id
        }][charge]" class="border rounded p-1 w-20 text-center" value="${
      existingContainer.charge
    }" />
        <input type="hidden" name="disposal_cost[disposal_containers_attributes][${
          existingContainer.id
        }][name]" value="${existingContainer.name}" />
        ${
          existingContainer.id
            ? `<input type="hidden" name="disposal_cost[disposal_containers_attributes][${existingContainer.id}][id]" value="${existingContainer.id}" />`
            : ''
        }
      </div>
    `;

    const containerList = document.querySelector('#containerList');
    if (containerList) {
      containerList.appendChild(containerRow);
    } else {
      console.error('ContainerList is not available.');
    }
  }

  addContainerRow(value, item) {
    if (!item) {
      return;
    }
    const uniqueIndex = new Date().getTime(); // Generate a unique index for each container
    const containerRow = document.createElement('div');
    containerRow.classList.add(
      'flex',
      'justify-between',
      'items-center',
      'bg-gray-100',
      'p-2',
      'mb-2',
      'border',
      'rounded'
    );
    containerRow.setAttribute('data-container-id', value);
    console.log('value', value);
    console.log('uniqueIndex', uniqueIndex);

    containerRow.innerHTML = `
      <span class="text-red-500 font-semibold mr-4">${item.textContent}</span>
      <div class="flex items-center">
        <label class="mr-2">Disposal Cost: $</label>
        <input type="number" name="disposal_cost[disposal_containers_attributes][${uniqueIndex}][cost]" class="border rounded p-1 w-20 text-center" />
        <label class="ml-4 mr-2">Disposal Charge: $</label>
        <input type="number" name="disposal_cost[disposal_containers_attributes][${uniqueIndex}][charge]" class="border rounded p-1 w-20 text-center" />
        <input type="hidden" name="disposal_cost[disposal_containers_attributes][${uniqueIndex}][name]" value="${value}" />
      </div>
    `;

    const containerList = document.querySelector('#containerList');
    if (containerList) {
      containerList.appendChild(containerRow);
    } else {
      console.error('ContainerList is not available.');
    }
  }

  removeContainerRow(value) {
    const containerRow = document.querySelector(
      `#containerList [data-container-id="${value}"]`
    );
    if (containerRow) {
      containerRow.remove();
    } else {
      console.error(`No container row found with id ${value}.`);
    }
  }
}
