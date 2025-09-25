import React from 'react';
import { createRoot, Root } from 'react-dom/client';
import RequestCartApp from './components/request-cart/RequestCartApp';
import InlineRequestCartApp from './components/request-cart/InlineRequestCartApp';
import RequestCartStorage from './RequestCartStorage.ts';
import { RequestCartChangeEvent } from './cart-types.ts';

// Define some global event dispatching functions that will allow us to send data to the cart app
// from inside or outside of a React context.
window.showCart = () => {
  window.dispatchEvent(new CustomEvent('showCart', {}));
};

window.addToCart = (recordData) => {
  const {
    id, collectionName, itemName, readingRoomLocation, containerInfo,
  } = recordData;
  RequestCartStorage.addItem(id, collectionName, itemName, readingRoomLocation, containerInfo);
  window.showCart();
};

window.removeFromCart = (id: string) => {
  RequestCartStorage.removeItem(id);
};

window.updateCartNote = (note: string) => {
  RequestCartStorage.setRequestCartNote(note);
};

window.clearCart = () => {
  RequestCartStorage.clearCart();
};

// Handle cart button clicks
window.handleAddToCartButtonClick = (buttonElement) => {
  const id = buttonElement.getAttribute('data-id');
  if (!id) return;

  if (RequestCartStorage.containsItem(id)) {
    window.removeFromCart(id);
  } else {
    const collectionName = buttonElement.getAttribute('data-collection-name')!;
    const itemName = buttonElement.getAttribute('data-item-name')!;
    const readingRoomLocation = buttonElement.getAttribute('data-reading-room-location')!;
    const containerInfo = buttonElement.getAttribute('data-container-info')!;

    window.addToCart({
      id,
      collectionName,
      itemName,
      readingRoomLocation,
      containerInfo,
    });
  }
};

function refreshAddToCartButtons() {
  document.querySelectorAll('.add-to-cart-button')?.forEach((buttonElement) => {
    const id = buttonElement.getAttribute('data-id');
    const buttonTextElement = buttonElement.querySelector('.button-text');

    if (!id || !buttonTextElement) return;

    if (RequestCartStorage.containsItem(id)) {
      const removeText = buttonElement.getAttribute('data-remove-from-cart-text')!;
      buttonTextElement.innerHTML = removeText;
      buttonElement.classList.remove('btn-primary');
      buttonElement.classList.add('btn-outline-primary');
    } else {
      buttonTextElement.innerHTML = buttonElement.getAttribute('data-add-to-cart-text')!;
      buttonElement.classList.remove('btn-outline-primary');
      buttonElement.classList.add('btn-primary');
    }
  });
}

// Handle cart change events
function onRequestCartChange(e: RequestCartChangeEvent) {
  const { items } = e.detail.cartData;
  // Update any cart count indicators on the page
  document.querySelectorAll('.request-cart-item-count')?.forEach((el) => {
    // eslint-disable-next-line no-param-reassign
    el.innerHTML = items.length.toString();
  });
  // Update the state of any add-to-cart buttons on the page
  refreshAddToCartButtons();
}

// Setup and cleanup
let mainCartReactRoot: Root | null = null;
let inlineCartReactRoot: Root | null = null;

function setup() {
  const mainCartContainerElement = document.getElementById('request-cart-widget');
  const inlineCartContainerElement = document.getElementById('inline-request-cart-widget');

  if (mainCartContainerElement) {
    mainCartReactRoot ||= createRoot(mainCartContainerElement);
    mainCartReactRoot.render(<RequestCartApp />);
  }

  if (inlineCartContainerElement) {
    inlineCartReactRoot ||= createRoot(inlineCartContainerElement);
    inlineCartReactRoot.render(<InlineRequestCartApp />);
  }

  window.addEventListener('requestCartChange', onRequestCartChange);
  document.querySelectorAll('.show-cart-button').forEach((el) => {
    el.addEventListener('click', window.showCart);
  });

  // On submission form page
  const aeonForm = document.getElementById('aeon-submission-form') as HTMLFormElement;
  if (aeonForm) {
    window.clearCart();
    setTimeout(() => aeonForm.submit(), 500);
  }
}

function cleanup() {
  mainCartReactRoot?.unmount();
  mainCartReactRoot = null;
  inlineCartReactRoot?.unmount();
  inlineCartReactRoot = null;

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
  const turboFrameElement = e.target as HTMLElement;
  // If a frame is loaded and it contains an .add-to-cart-button element,
  // refresh the state of all .add-to-cart-button elements on the page.
  if (turboFrameElement?.querySelector('.add-to-cart-button')) {
    refreshAddToCartButtons();
  }
});
