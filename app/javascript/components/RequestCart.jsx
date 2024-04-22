import { Sidebar, Menu, MenuItem } from 'react-pro-sidebar';
import React from 'react';

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

const cart = JSON.parse(localStorage.getItem('cart'));

function RequestCart() {
  return (
    // <Sidebar>
    //   <Menu>
    //     <MenuItem component={<h1>Cart</h1>} />
    //     <MenuItem component={<p>Cart stuff goes here!</p>} />
    //     <MenuItem component={
    //       (
    //         <table className="table">
    //           <thead>
    //             <tr>
    //               <th>Item Name</th>
    //               <th>Collection Name</th>
    //               <th>Reading Room Location</th>
    //             </tr>
    //           </thead>
    //           <tbody>
    //             {cart.map((cartItem) => (
    //               <tr key={cartItem.name}>
    //                 <td>{cartItem.name}</td>
    //                 <td>{cartItem.collection}</td>
    //                 <td>{cartItem.readingRoom}</td>
    //               </tr>
    //             ))}
    //           </tbody>
    //         </table>
    //       )
    //     }
    //     />
    //   </Menu>
    // </Sidebar>
    <div id="app" style={({ height: '100vh' }, { display: 'flex' })}>
      <Sidebar rtl closeOnClick style={{ height: '100vh' }}>
        <Menu>
          <MenuItem
            style={
              ({ textAlign: 'center' }, { display: 'flex', flexDirection: 'row-reverse' })
            }
          >
            {' '}
            <h2>Cart</h2>
          </MenuItem>
          <MenuItem>
            <table className="table">
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
                  </tr>
                ))}
              </tbody>
            </table>
          </MenuItem>
        </Menu>
      </Sidebar>
      <main>
        <h1 style={{ color: 'white', marginLeft: '5rem' }}>
          React-Pro-Sidebar
        </h1>
      </main>
    </div>
  );
}

export default RequestCart;
