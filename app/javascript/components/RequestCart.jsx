import React, { useEffect, useState } from 'react';
import Offcanvas from 'react-bootstrap/Offcanvas';
import Button from 'react-bootstrap/Button';
import Table from 'react-bootstrap/Table';
// import removeFromCart from '../../assets/javascripts/cart.js';

// const makeCartItem = (itemName, collection, readingRoom) => ({
//   name: itemName,
//   collection,
//   readingRoom,
// });

// const cart = [
//   makeCartItem('Item 1', 'Collection 1', 'Room 1'),
//   makeCartItem('Item 2', 'Collection 2', 'Room 2'),
//   makeCartItem('Item 3', 'Collection 3', 'Room 3'),
//   makeCartItem('Item 4', 'Collection 4', 'Room 4'),
//   makeCartItem('Item 5', 'Collection 5', 'Room 5'),
//   makeCartItem('Item 6', 'Collection 6', 'Room 6')
// ]

const cart = JSON.parse(localStorage.getItem('cart')) || [];

function removeFromCart(toRemove) {
  const newCart = JSON.parse(localStorage.getItem('cart')) || [];
  newCart.filter((item) => (item.name !== toRemove.name || item.collection !== toRemove.collection));
  localStorage.setItem('cart', JSON.stringify(newCart));
}

function RequestCart() {
  const [show, setShow] = useState(false);

  const hideCart = () => setShow(false);
  const showCart = () => setShow(true);

  useEffect(() => {
    window.addEventListener('showCart', showCart);
    return () => {
      window.removeEventListener('showCart', showCart);
    };
  });

  return (
    <div className="request-cart">
      <Offcanvas className="w-50" show={show} onHide={hideCart} placement="end" scroll>
        <Offcanvas.Header closeButton>
          <Offcanvas.Title>Request Cart</Offcanvas.Title>
        </Offcanvas.Header>
        <Offcanvas.Body>
          <Table>
            <thead>
              <tr>
                <th>Item Name</th>
                <th>Collection Name</th>
                <th>Reading Room Location</th>
              </tr>
            </thead>
            <tbody>
              {cart.map((cartItem) => (
                <tr key={cartItem.name}>
                  <td>{cartItem.name}</td>
                  <td>{cartItem.collection}</td>
                  <td>{cartItem.readingRoom}</td>
                  <td>
                    <Button onClick={removeFromCart(cartItem)}>
                      Remove
                    </Button>
                  </td>
                </tr>
              ))}
            </tbody>
          </Table>
        </Offcanvas.Body>
      </Offcanvas>
    </div>
  );
}

export default RequestCart;
