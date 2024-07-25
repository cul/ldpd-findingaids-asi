import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import debounce from 'lodash.debounce';
import Button from 'react-bootstrap/Button';
import Table from 'react-bootstrap/Table';
import RequestCartStorage from '../RequestCartStorage';

const debouncedPersistRequestCartNote = debounce((note) => {
  window.updateCartNote(note);
}, 250);

function RequestCart({ submissionMode, header }) {
  const loginMethod = new URLSearchParams(window.location.search).get('login_method');

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [items, setItems] = useState(RequestCartStorage.getItems());
  const [note, setNote] = useState(RequestCartStorage.getRequestCartNote());
  // const aeonBaseUrl = document.getElementById('request-cart-widget').getAttribute('data-aeon-base-url');
  // const aeonLogonUrl = `${aeonBaseUrl}/logon`;
  const csrfTokenParamName = document.querySelector('meta[name="csrf-param"]').getAttribute('content');
  const csrfTokenValue = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  const handleRequestCartChangeEvent = (e) => {
    setNote(e.detail.cartData.note);
    setItems([...e.detail.cartData.items]);
  };

  const handleNoteChange = (e) => {
    setNote(e.target.value);
  };

  const renderHiddenCartItemFormValues = () => {
    const elements = [];
    items.forEach((item) => {
      elements.push(<input key={item.id} type="hidden" name="ids[]" value={item.id} />);
    });
    return elements;
  };

  useEffect(() => {
    RequestCartStorage.init();
    window.addEventListener('requestCartChange', handleRequestCartChangeEvent);
    return () => {
      window.removeEventListener('requestCartChange', handleRequestCartChangeEvent);
    };
  }, []);

  useEffect(() => {
    // When the note changes, persist the change with a debounced function (so we don't persist data on every key press)
    debouncedPersistRequestCartNote(note);
  }, [note]);

  return (
    <div className="request-cart d-flex flex-column h-100">
      {header}
      <div className="flex-fill">
        <Table responsive>
          <thead className="table-light">
            <tr>
              <th className="ps-4 align-middle">Collection Name</th>
              <th className="align-middle">Item Name</th>
              <th className="align-middle">Reading Room Location</th>
              <th className="pe-4"><span className="sr-only">Actions</span></th>
            </tr>
          </thead>
          <tbody>
            {
              items.length > 0 && items.map((item) => (
                <tr key={item.id} data-id={item.id}>
                  <td className="ps-4">{item.collectionName}</td>
                  <td>{item.itemName}</td>
                  <td>{item.readingRoomLocation}</td>
                  <td className="pe-4 text-end align-middle">
                    <Button size="sm" variant="secondary" onClick={() => { window.removeFromCart(item.id); }}>
                      Remove
                    </Button>
                  </td>
                </tr>
              ))
            }
            {
              items.length === 0 && (
                <tr><td colSpan={4}>Your cart is empty.</td></tr>
              )
            }
          </tbody>
        </Table>
      </div>
      <div>
        {
          items.length > 0 && (
            <form
              method="POST"
              action={submissionMode === 'create' ? '/aeon_request/create' : '/aeon_request/select_account'}
              data-turbo="false"
            >
              <textarea
                placeholder="Notes to special collections staff"
                rows="3"
                maxLength={256}
                className="w-100 form-control mb-1"
                value={note}
                onChange={handleNoteChange}
              />
              <input type="hidden" name={csrfTokenParamName} value={csrfTokenValue} />
              {
                loginMethod && (
                  <input type="hidden" name="login_method" value={loginMethod} />
                )
              }
              {
                renderHiddenCartItemFormValues()
              }
              <Button
                type="submit"
                variant="primary"
                className="w-100 mb-3"
                onClick={(e) => {
                  e.preventDefault();
                  window.updateCartNote(note);
                  e.target.closest('form').submit();
                  setIsSubmitting(true);
                }}
                disabled={isSubmitting}
              >
                {
                  isSubmitting
                    ? (
                      'Submitting...'
                    )
                    : (
                      `Request ${items.length} ${items.length === 1 ? 'Item' : 'Items'}`
                    )
                }
              </Button>
            </form>
          )
        }
      </div>
    </div>
  );
}

RequestCart.propTypes = {
  submissionMode: PropTypes.oneOf(['select_account', 'create']).isRequired,
  header: PropTypes.element,
};

RequestCart.defaultProps = {
  header: null,
};

export default RequestCart;
