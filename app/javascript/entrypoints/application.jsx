import React from 'react';
import { createRoot } from 'react-dom/client';
import Mirador from '@columbia-libraries/mirador/dist/es/src';
import miradorDownloadPlugins from '@columbia-libraries/mirador/dist/es/src/culPlugins/mirador-downloaddialog';
import canvasRelatedLinksPlugin from '@columbia-libraries/mirador/dist/es/src/culPlugins/mirador-canvasRelatedLinks';
import citationSidebar from '@columbia-libraries/mirador/dist/es/src/culPlugins/mirador-citations';
import hintingSidebar from '@columbia-libraries/mirador/dist/es/src/culPlugins/mirador-hinting-sidebar';
import videoJSPlugin from '@columbia-libraries/mirador/dist/es/src/culPlugins/mirador-videojs';
import viewXmlPlugin from '@columbia-libraries/mirador/dist/es/src/culPlugins/mirador-viewXml';
import '@hotwired/turbo-rails';
import 'bootstrap';
import '@github/auto-complete-element';
import 'blacklight-frontend';
import RequestCart from '../components/RequestCart';
import '../autocomplete-setup';

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

// Set up the cart widget react app
let cartReactRoot = null;
document.addEventListener('turbo:load', () => {
  const container = document.getElementById('cart-widget');
  if (container) {
    if (!cartReactRoot) { cartReactRoot = createRoot(container); }
    cartReactRoot.render(<RequestCart />);
  }
});
// Make sure to clean up the cart widget react app before any turbo render, so we dont introduce memory leaks.
document.addEventListener('turbo:before-render', () => {
  if (cartReactRoot) {
    cartReactRoot.unmount();
    cartReactRoot = null;
  }
});

// Define global showCart() function, which will allow us to trigger cart display from anywhere in the app,
// even outside of a React context.
window.showCart = () => {
  window.dispatchEvent(new CustomEvent('showCart', {}));
};

const flattenPluginConfigs = (...plugins) => plugins.reduce((acc, curr) => acc.concat([...curr]), []);

function initMirador() {
  const miradorDiv = document.querySelector('#mirador');
  if (!miradorDiv) return;
  const manifestUrl = miradorDiv.dataset.manifest;
  if (!manifestUrl) return;

  Mirador.viewer(
    {
      id: 'mirador',
      window: {
        allowClose: false,
        allowFullscreen: true,
        panels: {
          info: true,
          canvas: true,
        },
      },
      windows: [
        {
          manifestId: manifestUrl,
        },
      ],
      workspace: {
        showZoomControls: true,
      },
      workspaceControlPanel: {
        enabled: false,
      },
      miradorDownloadPlugin: {
        restrictDownloadOnSizeDefinition: true,
      },
    },
    flattenPluginConfigs(
      hintingSidebar,
      miradorDownloadPlugins,
      viewXmlPlugin,
      citationSidebar,
      videoJSPlugin,
      canvasRelatedLinksPlugin,
    ),
  );
}

document.addEventListener('turbo:load', initMirador);
