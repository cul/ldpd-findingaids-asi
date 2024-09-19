const REQUEST_CART_LOCAL_STORAGE_KEY = 'requestCart';
// const ARCHIVED_REQUEST_CART_LOCAL_STORAGE_KEY = 'archivedRequestCart';
const initialCartData = { items: [], note: '' };

/**
 * A static class that wraps local storage for Request Cart features.
 */
export default class RequestCartStorage {
  static init() {
    const cartData = this.getCartData();
    this.dispatchCartChangeEvent(cartData);
  }

  static dispatchCartChangeEvent(cartData) {
    window.dispatchEvent(new CustomEvent('requestCartChange', { detail: { cartData } }));
  }

  static persistCartData(cartData) {
    localStorage.setItem(REQUEST_CART_LOCAL_STORAGE_KEY, JSON.stringify(cartData));
    this.dispatchCartChangeEvent(cartData);
  }

  static getCartData() {
    return JSON.parse(localStorage.getItem(REQUEST_CART_LOCAL_STORAGE_KEY)) || initialCartData;
  }

  static getRequestCartNote() {
    return this.getCartData().note;
  }

  static setRequestCartNote(note) {
    const cartData = this.getCartData();
    cartData.note = note;
    this.persistCartData(cartData);
  }

  static addItem(id, collectionName, itemName, readingRoomLocation, containerInfo) {
    const cartData = this.getCartData();

    const newItem = {
      id,
      collectionName,
      itemName,
      readingRoomLocation,
      containerInfo,
    };

    // Check for identical existing item.  If found, skip adding this duplicate.
    const existingItem = cartData.items.find((el) => newItem.id === el.id);
    if (existingItem) { return; }

    cartData.items.push(newItem);
    this.persistCartData(cartData);
  }

  static containsItem(id) {
    const cartData = this.getCartData();
    return cartData.items.find((item) => id === item.id);
  }

  static removeItem(id) {
    const cartData = this.getCartData();

    const indexOfItemToRemove = cartData.items.findIndex((el) => el.id === id);
    cartData.items.splice(indexOfItemToRemove, 1);
    this.persistCartData(cartData);
  }

  static clearCart() {
    this.persistCartData(initialCartData);
  }

  static getItems() {
    return this.getCartData().items;
  }

  // static archiveCartData() {
  //   localStorage.setItem(REQUEST_CART_LOCAL_STORAGE_KEY, JSON.stringify(this.getCartData()));
  //   this.clearCart();
  // }

  // static getArchivedCartData() {
  //   return JSON.parse(localStorage.getItem(ARCHIVED_REQUEST_CART_LOCAL_STORAGE_KEY)) || initialCartData;
  // }
}
