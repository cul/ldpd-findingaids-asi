function addToCart() {
  const cart = JSON.parse(localStorage.getItem('cart'));
  cart.push({ name: `new_name${Math.random()}`, collection: 'newCollection', readingRoom: 'newReadingRoom' });
  localStorage.setItem('cart', JSON.stringify(cart));
}
