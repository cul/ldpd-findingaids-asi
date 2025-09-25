/* eslint-disable jsx-a11y/control-has-associated-label */
import React, { useEffect, useState } from 'react';
import { Button, Table } from 'react-bootstrap';
import debounce from 'lodash.debounce';
import sortBy from 'lodash.sortby';

import RequestCartStorage from '../../RequestCartStorage';
import { CartItem, RequestCartChangeEvent } from '../../cart-types';

interface RequestCartProps {
  submissionMode: 'select_account' | 'create';
  header?: React.ReactElement;
}

const debouncedPersistRequestCartNote = debounce((note: string) => {
  window.updateCartNote(note);
}, 250);

function RequestCart({ submissionMode, header }: RequestCartProps) {
  const loginMethod = new URLSearchParams(window.location.search).get('login_method');

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [items, setItems] = useState<CartItem[]>(RequestCartStorage.getItems());
  const [note, setNote] = useState<string>(RequestCartStorage.getRequestCartNote());

  const csrfTokenParamName = document.querySelector('meta[name="csrf-param"]')?.getAttribute('content') || '';
  const csrfTokenValue = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '';

  const handleRequestCartChangeEvent = (e: RequestCartChangeEvent) => {
    setNote(e.detail.cartData.note);
    setItems([...e.detail.cartData.items]);
  };

  const handleNoteChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    setNote(e.target.value);
  };

  const renderHiddenCartItemFormValues = (): React.ReactElement[] => {
    const elements: React.ReactElement[] = [];
    items.forEach((item) => {
      elements.push(<input key={item.id} type="hidden" name="ids[]" value={item.id} />);
    });
    elements.push(<input key="note" type="hidden" name="note" value={note} />);
    return elements;
  };

  const renderSubmissionElement = (): React.ReactElement | null => {
    if (items.length === 0) { return null; }
    if (submissionMode === 'create') {
      return (
        <form method="POST" action="/aeon_request/create" data-turbo="false">
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
            onClick={(e: React.MouseEvent<HTMLButtonElement>) => {
              e.preventDefault();
              window.updateCartNote(note);
              (e.target as HTMLElement).closest('form')?.submit();
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
      );
    }

    // Otherwise submission mode is select_account
    return (
      <a href="/aeon_request/select_account" className="btn btn-primary w-100 mb-3">
        {
          isSubmitting
            ? (
              'Submitting...'
            )
            : (
              `Request ${items.length} ${items.length === 1 ? 'Item' : 'Items'}`
            )
        }
      </a>
    );
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

  const cartItemsGroupedByReadingRoomLocation = (
    ungroupedItems: CartItem[],
    groupByField: keyof CartItem,
    sortByFields: (keyof CartItem)[],
  ): CartItem[][] => {
    const groups: CartItem[][] = [];
    const sortedUngroupedItems = sortBy(
      ungroupedItems,
      [groupByField, ...sortByFields],
    );
    let latestGroup: CartItem[] = [];

    for (let i = 0; i < sortedUngroupedItems.length; i += 1) {
      const currentItem = sortedUngroupedItems[i];
      latestGroup.push(currentItem);

      const nextItem = sortedUngroupedItems[i + 1];
      if (currentItem[groupByField] !== nextItem?.[groupByField]) {
        groups.push(latestGroup);
        latestGroup = [];
      }
    }

    return groups;
  };

  return (
    <div className="request-cart d-flex flex-column h-100">
      {header}
      <div className="flex-fill">
        <Table responsive>
          <thead className="table-light">
            <tr>
              <th className="align-middle pe-4">Repository</th>
              <th className="align-middle pe-4">Collection</th>
              <th className="align-middle pe-4">Title</th>
              <th className="align-middle pe-4">Container</th>
              <th className="pe-4"><span className="sr-only">Actions</span></th>
            </tr>
          </thead>
          <tbody>
            {
              items.length > 0
                ? cartItemsGroupedByReadingRoomLocation(
                  items,
                  'readingRoomLocation',
                  ['collectionName', 'containerInfo', 'itemName'],
                ).map((groupedItems) => groupedItems.map((item) => (
                  <tr key={item.id} data-id={item.id}>
                    <td className="pe-4">{item.readingRoomLocation}</td>
                    <td className="pe-4">{item.collectionName}</td>
                    <td className="pe-4">{item.itemName}</td>
                    <td className="pe-4">{item.containerInfo}</td>
                    <td className="pe-4 text-end align-middle">
                      <Button size="sm" variant="secondary" onClick={() => { window.removeFromCart(item.id); }}>
                        <i className="fa fa-x" />
                      </Button>
                    </td>
                  </tr>
                )))
                : (
                  <tr><td colSpan={5}>Your cart is empty.</td></tr>
                )
            }
          </tbody>
        </Table>
      </div>
      <div>
        <textarea
          placeholder="Notes to special collections staff"
          rows={3}
          maxLength={256}
          className="w-100 form-control mb-3"
          value={note}
          onChange={handleNoteChange}
        />
        {renderSubmissionElement()}
      </div>
    </div>
  );
}

export default RequestCart;
