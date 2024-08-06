// import Mirador from 'mirador';

// Below, we're explicitly importing '@mui/material/styles/styled' to guarantee that the "styled_default()" function
// is available for Mirador code that calls it later on.  We need to make sure that when our JS is split up into
// chunks, the chunk containing '@mui/material/styles/styled' is available.
// See: https://github.com/vitejs/vite/issues/12423#issuecomment-2080351394
// eslint-disable-next-line import/no-extraneous-dependencies
import '@mui/material/styles/styled';

import Mirador from '@columbia-libraries/mirador/dist/es/src';
import miradorDownloadPlugins from '@columbia-libraries/mirador/dist/es/src/culPlugins/mirador-downloaddialog';
import canvasRelatedLinksPlugin from '@columbia-libraries/mirador/dist/es/src/culPlugins/mirador-canvasRelatedLinks';
import citationSidebar from '@columbia-libraries/mirador/dist/es/src/culPlugins/mirador-citations';
import hintingSidebar from '@columbia-libraries/mirador/dist/es/src/culPlugins/mirador-hinting-sidebar';
import videoJSPlugin from '@columbia-libraries/mirador/dist/es/src/culPlugins/mirador-videojs';
import viewXmlPlugin from '@columbia-libraries/mirador/dist/es/src/culPlugins/mirador-viewXml';

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
