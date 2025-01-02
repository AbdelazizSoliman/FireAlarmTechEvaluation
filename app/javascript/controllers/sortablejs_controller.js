import Sortable from 'sortablejs';

document.addEventListener('turbo:load', () => {
  const el = document.getElementById('sortable');
  if (el) {
    Sortable.create(el, {
      animation: 150,
      onEnd: function (evt) {
        const itemEl = evt.item;
        const order = Array.from(el.children).map((child, index) => {
          return { id: child.dataset.id, position: index + 1 };
        });

        // Send the new order to your Rails backend
        fetch('/disposal_costs/sort', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document
              .querySelector('meta[name="csrf-token"]')
              .getAttribute('content'),
          },
          body: JSON.stringify({ order: order }),
        }).then((response) => {
          if (response.ok) {
            console.log('Order saved');
          } else {
            console.error('Error saving order');
          }
        });
      },
    });
  }
});
