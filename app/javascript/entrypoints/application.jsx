import React from 'react';
import { createRoot } from 'react-dom/client';
import '@hotwired/turbo-rails';
import '@github/auto-complete-element';
import { RequestCart } from '../components/RequestCart';

// To see this message, add the following to the `<head>` section in your
// views/layouts/application.html.erb
//
//    <%= vite_client_tag %>
//    <%= vite_javascript_tag 'application' %>
// console.log('Vite ⚡️ Rails')

// If using a TypeScript entrypoint file:
//     <%= vite_typescript_tag 'application' %>
//
// If you want to use .jsx or .tsx, add the extension:
//     <%= vite_javascript_tag 'application.jsx' %>

// console.log('Visit the guide for more information: ', 'https://vite-ruby.netlify.app/guide/rails')

// Example: Load Rails libraries in Vite.
//

// import "@hotwired/turbo"

//
// import ActiveStorage from '@rails/activestorage'
// ActiveStorage.start()
//
// // Import all channels.
// const channels = import.meta.globEager('./**/*_channel.js')

// Example: Import a stylesheet in app/frontend/index.css
// import '~/index.css'

const container = document.getElementById('cart-widget');
if (container) {
  const root = createRoot(container);
  // eslint-disable-next-line no-console
  console.log('rendering cart');
  root.render(<RequestCart />); // or some other better name for the component
}
