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

export interface RequestCartChangeEvent extends CustomEvent {
  detail: {
    cartData: CartData;
  };
}
