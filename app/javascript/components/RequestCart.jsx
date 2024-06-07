import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import debounce from 'lodash.debounce';
import Button from 'react-bootstrap/Button';
import Table from 'react-bootstrap/Table';
import RequestCartStorage from '../RequestCartStorage';

const debouncedPersistRequestCartNote = debounce((note) => {
  window.updateCartNote(note);
}, 250);

const actionForSubmissionMode = (submissionMode, loginMethod) => {
  const aeonShibDllUrl = document.getElementById('request-cart-widget').getAttribute('data-aeon-shib-dll-url');
  const aeonNonShibDllUrl = document.getElementById('request-cart-widget').getAttribute('data-aeon-non-shib-dll-url');

  if (submissionMode === 'select_account') {
    return '/aeon_request/select_account';
  }

  if (submissionMode === 'aeon') {
    if (loginMethod === 'shib') { return aeonShibDllUrl; }
    if (loginMethod === 'nonshib') { return aeonNonShibDllUrl; }
    throw new Error(`Unknown loginMethod: ${loginMethod}`);
  }

  throw new Error(`Unknown submission mode: ${submissionMode}`);
};

function RequestCart({ header, submissionMode }) {
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

  const renderHiddenFormElementsForAeonSubmission = () => {
    console.log('Aeon form fields rendered.');
    return (
      <input type="hidden" name="Notes" value={note} />
    );
  };

  return (
    <div className="request-cart d-flex flex-column h-100">
      {header}
      <div className="flex-fill">
        <Table responsive>
          <thead className="table-light">
            <tr>
              <th className="ps-4">Collection Name</th>
              <th>Item Name</th>
              <th>Reading Room Location</th>
              <th className="pe-4"><span className="sr-only">Actions</span></th>
            </tr>
          </thead>
          <tbody>
            {
              items.length > 0 && items.map((item) => (
                <tr key={item.id}>
                  <td className="ps-4">{item.collectionName}</td>
                  <td>{item.itemName}</td>
                  <td>{item.readingRoomLocation}</td>
                  <td className="pe-4 text-end">
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
              action={
                actionForSubmissionMode(submissionMode, new URLSearchParams(window.location.search).get('login_method'))
              }
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
              {renderHiddenFormElementsForAeonSubmission()}
              <Button
                type="submit"
                variant="primary"
                className="w-100 mb-3"
                onClick={(e) => {
                  e.preventDefault();
                  window.updateCartNote(note);
                  e.target.closest('form').submit();
                }}
              >
                Request
                {' '}
                {items.length}
                {' '}
                {items.length === 1 ? 'Item' : 'Items'}
              </Button>
            </form>
          )
        }
      </div>
    </div>
  );
}

RequestCart.propTypes = {
  submissionMode: PropTypes.oneOf(['aeon', 'select_account']).isRequired,
  header: PropTypes.element,
};

RequestCart.defaultProps = {
  header: null,
};

export default RequestCart;
