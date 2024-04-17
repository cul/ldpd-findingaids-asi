import React from 'react';

const makeCartItem = (itemName, collection, readingRoom) => {
  return {
    'name': itemName,
    'collection': collection,
    'readingRoom': readingRoom
  }
}

// const cart = [
//   makeCartItem('Item 1', 'Collection 1', 'Room 1'),
//   makeCartItem('Item 2', 'Collection 2', 'Room 2'),
//   makeCartItem('Item 3', 'Collection 3', 'Room 3'),
//   makeCartItem('Item 4', 'Collection 4', 'Room 4'),
//   makeCartItem('Item 5', 'Collection 5', 'Room 5'),
//   makeCartItem('Item 6', 'Collection 6', 'Room 6')
// ]

const cart = JSON.parse(localStorage.getItem('cart'))

const RequestCart = () => {
  return (
    <div>
      <h1>Cart</h1>
      <p>Cart stuff goes here!</p>
      <table className='table'>
        <thead>
          <tr>
            <th>Item Name</th>
            <th>Collection Name</th>
            <th>Reading Room Location</th>
          </tr>
        </thead>
        <tbody>
            {cart.map((cartItem) => {
              return (
                <tr key={cartItem.name}>
                  <td>{cartItem.name}</td>
                  <td>{cartItem.collection}</td>
                  <td>{cartItem.readingRoom}</td>
                </tr>
              )
            })}
        </tbody>
      </table>
    </div>
  );
}
