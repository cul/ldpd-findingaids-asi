import { CartItem, RequestCartChangeEvent } from './cart-types';

declare global {
  interface Window {
    showCart: () => void;
    addToCart: (recordData: CartItem) => void;
    updateCartNote: (note: string) => void;
    removeFromCart: (id: string) => void;
    clearCart: () => void;
    handleAddToCartButtonClick: (buttonElement: HTMLElement) => void;
  }

  interface WindowEventMap {
    requestCartChange: RequestCartChangeEvent;
  }
}
