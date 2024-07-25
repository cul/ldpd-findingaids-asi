declare global {
  interface Window {
    showCart: () => void;
    addToCart: (recordData: RequestCartItem) => void;
  }
}


export interface RequestCartItem {
  collectionName: string;
  itemName?: string;
  readingRoomLocation?: string;
}
