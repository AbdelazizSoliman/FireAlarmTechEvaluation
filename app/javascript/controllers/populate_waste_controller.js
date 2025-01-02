import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = [
    'dotShippingDescription',
    'processingCode',
    'wasteType',
    'containerType',
    'vendor',
    'mxiCost',
    'clientCost',
    'wasteCommonName',
  ];

  populate(event) {
    const selectedId = event.target.value;

    // Fetch the disposal cost data
    fetch(`/disposal_costs/${selectedId}.json`)
      .then((response) => response.json())
      .then((data) => {
        // Populate the related fields with the data
        this.dotShippingDescriptionTarget.value = data.dot_shipping_description;
        this.processingCodeTarget.value = data.processing_code;
        this.wasteTypeTarget.value = data.waste_type;
        this.wasteCommonNameTarget.value = data.waste_common_name;

        // Populate container type dropdown with options
        // this.populateContainers(data.disposal_containers);
        this.populateDropdown(
          this.containerTypeTarget,
          data.disposal_containers,
          'Select a container'
        );
        this.populateDropdown(
          this.vendorTarget,
          data.vendors,
          'Select a vendor'
        );
      })
      .catch((error) =>
        console.error('Error fetching disposal cost data:', error)
      );
  }

  populateDropdown(targetElement, items, defaultText = 'Select an option') {
    // Check if items is an array, if not, make it an array
    if (!Array.isArray(items)) {
      console.log('Expected array but got:', typeof items);
      return;
    }

    // Clear existing options in the target dropdown
    targetElement.innerHTML = '';

    // Add a default option
    const defaultOption = document.createElement('option');
    defaultOption.text = defaultText;
    defaultOption.value = '';
    targetElement.add(defaultOption);

    // Add options dynamically based on the items array
    items.forEach((item) => {
      const option = document.createElement('option');
      option.text = item.name || item.company_name || 'Unnamed'; // Adjust based on the expected data structure
      option.value = item.name || item.company_name;

      // Optionally set custom data attributes
      if (item.cost) option.dataset.cost = item.cost;
      if (item.charge) option.dataset.charge = item.charge;

      targetElement.add(option);
    });
  }

  // New method to populate cost and charge
  populateCostAndCharge(event) {
    const selectedOption = event.target.selectedOptions[0];

    const cost = selectedOption.dataset.cost;
    const charge = selectedOption.dataset.charge;

    // Update the mxiCost and clientCost fields
    this.mxiCostTarget.value = cost;
    this.clientCostTarget.value = charge;
  }
}
