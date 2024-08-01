import React from 'react';
import { createRoot } from 'react-dom/client';
import RequestCartApp from './components/RequestCartApp';
import InlineRequestCartApp from './components/InlineRequestCartApp';
import RequestCartStorage from './RequestCartStorage';

// Define some global event dispatching functions that will allow us to send data to the cart app
// from inside or outside of a React context.
window.showCart = () => {
  window.dispatchEvent(new CustomEvent('showCart', {}));
};

window.addToCart = (recordData) => {
  const {
    id, collectionName, itemName, readingRoomLocation,
  } = recordData;
  RequestCartStorage.addItem(id, collectionName, itemName, readingRoomLocation);
  window.showCart();
};

window.removeFromCart = (id) => {
  RequestCartStorage.removeItem(id);
};

window.updateCartNote = (note) => {
  RequestCartStorage.setRequestCartNote(note);
};

window.clearCart = () => {
  RequestCartStorage.clearCart();
};

// Handle cart button clicks
window.handleAddToCartButtonClick = (buttonElement) => {
  const id = buttonElement.getAttribute('data-id');
  if (RequestCartStorage.containsItem(id)) {
    window.removeFromCart(id);
  } else {
    window.addToCart({
      id: buttonElement.getAttribute('data-id'),
      collectionName: buttonElement.getAttribute('data-collection-name'),
      itemName: buttonElement.getAttribute('data-item-name'),
      readingRoomLocation: buttonElement.getAttribute('data-reading-room-location'),
    });
  }
};

function refreshAddToCartButtons() {
  document.querySelectorAll('.add-to-cart-button')?.forEach((buttonElement) => {
    const id = buttonElement.getAttribute('data-id');
    const buttonTextElement = buttonElement.querySelector('.button-text');
    if (RequestCartStorage.containsItem(id)) {
      buttonTextElement.innerHTML = buttonElement.getAttribute('data-remove-from-cart-text');
      buttonElement.classList.remove('btn-primary');
      buttonElement.classList.add('btn-outline-primary');
    } else {
      buttonTextElement.innerHTML = buttonElement.getAttribute('data-add-to-cart-text');
      buttonElement.classList.remove('btn-outline-primary');
      buttonElement.classList.add('btn-primary');
    }
  });
}

// Handle cart change events
function onRequestCartChange(e) {
  const { items } = e.detail.cartData;
  // Update any cart count indicators on the page
  document.querySelectorAll('.request-cart-item-count')?.forEach((el) => {
    // eslint-disable-next-line no-param-reassign
    el.innerHTML = items.length;
  });
  // Update the state of any add-to-cart buttons on the page
  refreshAddToCartButtons();
}

// Setup and cleanup

let mainCartReactRoot;
let inlineCartReactRoot;

function setup() {
  const mainCartContainerElement = document.getElementById('request-cart-widget');
  const inlineCartContainerElement = document.getElementById('inline-request-cart-widget');
  if (mainCartContainerElement) {
    if (!mainCartReactRoot) { mainCartReactRoot = createRoot(mainCartContainerElement); }
    mainCartReactRoot.render(<RequestCartApp />);
  }
  if (inlineCartContainerElement) {
    if (!inlineCartReactRoot) { inlineCartReactRoot = createRoot(inlineCartContainerElement); }
    inlineCartReactRoot.render(<InlineRequestCartApp />);
  }
  window.addEventListener('requestCartChange', onRequestCartChange);

  document.querySelectorAll('.show-cart-button').forEach((el) => {
    el.addEventListener('click', window.showCart);
  });

  // On submission form page
  if (document.getElementById('aeon-submission-form')) {
    // // Clear cart
    // window.clearCart();
    // // And submit the form shortly after
    // setTimeout(() => {
    //   document.getElementById('aeon-submission-form').submit();
    // }, 500);
  }
}

function cleanup() {
  if (mainCartReactRoot) {
    mainCartReactRoot.unmount();
    mainCartReactRoot = null;
  }
  if (inlineCartReactRoot) {
    inlineCartReactRoot.unmount();
    inlineCartReactRoot = null;
  }
  window.removeEventListener('requestCartChange', onRequestCartChange);

  document.querySelectorAll('.show-cart-button').forEach((el) => {
    el.removeEventListener('click', window.showCart);
  });
}

// Set up cart functionality after a turbo:load event.
document.addEventListener('turbo:load', setup);
// Clean up cart functionality before a turbo:before-render event.
document.addEventListener('turbo:before-render', cleanup);

// The handler below is for making sure that we refresh
document.addEventListener('turbo:frame-load', (e) => {
  const turboFrameElement = e.target;
  // If a frame is loaded and it contains an .add-to-cart-button element,
  // refresh the state of all .add-to-cart-button elements on the page.
  if (turboFrameElement.querySelector('.add-to-cart-button')) {
    refreshAddToCartButtons();
  }
});
