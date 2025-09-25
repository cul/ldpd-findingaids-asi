import { CartItem, CartData } from './cart-types.ts';

const REQUEST_CART_LOCAL_STORAGE_KEY = 'requestCart';
const initialCartData: CartData = { items: [], note: '' };

/**
 * A static class that wraps local storage for Request Cart features.
 */
export default class RequestCartStorage {
  static init(): void {
    const cartData = this.getCartData();
    this.dispatchCartChangeEvent(cartData);
  }

  static dispatchCartChangeEvent(cartData: CartData): void {
    window.dispatchEvent(new CustomEvent('requestCartChange', { detail: { cartData } }));
  }

  static persistCartData(cartData: CartData): void {
    localStorage.setItem(REQUEST_CART_LOCAL_STORAGE_KEY, JSON.stringify(cartData));
    this.dispatchCartChangeEvent(cartData);
  }

  static getCartData(): CartData {
    const storedData = localStorage.getItem(REQUEST_CART_LOCAL_STORAGE_KEY);
    return storedData ? JSON.parse(storedData) : initialCartData;
  }

  static getRequestCartNote(): string {
    return this.getCartData().note;
  }

  static setRequestCartNote(note: string): void {
    const cartData = this.getCartData();
    cartData.note = note;
    this.persistCartData(cartData);
  }

  static addItem(id: string, collectionName: string, itemName: string, readingRoomLocation: string, containerInfo: string): void {
    const cartData = this.getCartData();

    const newItem: CartItem = {
      id,
      collectionName,
      itemName,
      readingRoomLocation,
      containerInfo,
    };

    // Check for identical existing item. If found, skip adding this duplicate.
    const existingItem = cartData.items.find((el) => newItem.id === el.id);
    if (existingItem) { return; }

    cartData.items.push(newItem);
    this.persistCartData(cartData);
  }

  static containsItem(id: string): CartItem | undefined {
    const cartData = this.getCartData();
    return cartData.items.find((item) => id === item.id);
  }

  static removeItem(id: string): void {
    const cartData = this.getCartData();

    const indexOfItemToRemove = cartData.items.findIndex((el) => el.id === id);
    cartData.items.splice(indexOfItemToRemove, 1);
    this.persistCartData(cartData);
  }

  static clearCart(): void {
    this.persistCartData(initialCartData);
  }

  static getItems(): CartItem[] {
    return this.getCartData().items;
  }
}
