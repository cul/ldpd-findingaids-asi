import '@hotwired/turbo-rails';
import 'bootstrap';
import '@github/auto-complete-element';
import 'blacklight-frontend';

import React from 'react';
import { createRoot } from 'react-dom/client';
import Mirador from '@columbia-libraries/mirador/dist/es/src';
import miradorDownloadPlugins from '@columbia-libraries/mirador/dist/es/src/culPlugins/mirador-downloaddialog';
import canvasRelatedLinksPlugin from '@columbia-libraries/mirador/dist/es/src/culPlugins/mirador-canvasRelatedLinks';
import citationSidebar from '@columbia-libraries/mirador/dist/es/src/culPlugins/mirador-citations';
import hintingSidebar from '@columbia-libraries/mirador/dist/es/src/culPlugins/mirador-hinting-sidebar';
import videoJSPlugin from '@columbia-libraries/mirador/dist/es/src/culPlugins/mirador-videojs';
import viewXmlPlugin from '@columbia-libraries/mirador/dist/es/src/culPlugins/mirador-viewXml';

import '../main.scss';
import '../autocomplete-setup';
import '../request-cart-setup';

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

document.addEventListener('DOMContentLoaded', initMirador);
