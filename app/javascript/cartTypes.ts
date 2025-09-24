declare global {
  interface Window {
    showCart: () => void;
    addToCart: (recordData: CartItem) => void;
    updateCartNote: (note: string) => void;
    removeFromCart: (id: string) => void;
    clearCart: () => void;
  }

  // Custom event for when the request cart changes (items added/removed, note changed)
  interface WindowEventMap {
    requestCartChange: RequestCartChangeEvent;
  }
}

export interface RequestCartChangeEvent extends CustomEvent {
  detail: {
    cartData: CartData;
  };
}

export interface CartItem {
  id: string;
  collectionName: string;
  itemName: string;
  readingRoomLocation: string;
  containerInfo: string;
}

export interface CartData {
  items: CartItem[];
  note: string;
}
