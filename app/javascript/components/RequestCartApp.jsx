import React, { useEffect, useState } from 'react';
import Offcanvas from 'react-bootstrap/Offcanvas';
import RequestCartStorage from '../RequestCartStorage';
import RequestCart from './RequestCart';

function RequestCartApp() {
  const [show, setShow] = useState(false);

  const hideCart = () => setShow(false);
  const showCart = () => setShow(true);

  const handleShowCartEvent = () => {
    showCart();
  };

  useEffect(() => {
    RequestCartStorage.init();
    window.addEventListener('showCart', handleShowCartEvent);
    return () => {
      window.removeEventListener('showCart', handleShowCartEvent);
    };
  });

  return (
    <div>
      <Offcanvas id="cart-offcanvas" show={show} onHide={hideCart} placement="end" scroll>
        <Offcanvas.Header closeButton>
          <Offcanvas.Title>
            Request Cart
            {' '}
            <i className="fa fa-cart-shopping" />
          </Offcanvas.Title>
        </Offcanvas.Header>
        <Offcanvas.Body>
          <RequestCart
            submissionMode="select_account"
// eslint-disable-next-line
            header={<div className="mb-3">Ready to view these items in the reading room? Click &quot;Request&quot; to log in and schedule an appointment.</div>}
            onSubmit={() => { window.location.href = '/aeon_request/select_account'; }}
          />
        </Offcanvas.Body>
      </Offcanvas>
    </div>
  );
}

export default RequestCartApp;
