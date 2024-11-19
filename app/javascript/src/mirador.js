import Mirador from '@columbia-libraries/mirador/dist/es/src';
import miradorDownloadPlugins from '@columbia-libraries/mirador/dist/es/src/culPlugins/mirador-downloaddialog';
import canvasRelatedLinksPlugin from '@columbia-libraries/mirador/dist/es/src/culPlugins/mirador-canvasRelatedLinks';
import citationSidebar from '@columbia-libraries/mirador/dist/es/src/culPlugins/mirador-citations';
import hintingSidebar from '@columbia-libraries/mirador/dist/es/src/culPlugins/mirador-hinting-sidebar';
import videoJSPlugin from '@columbia-libraries/mirador/dist/es/src/culPlugins/mirador-videojs';
import viewerNavigation from '@columbia-libraries/mirador/dist/es/src/culPlugins/mirador-pageIconViewerNavigation';
import viewXmlPlugin from '@columbia-libraries/mirador/dist/es/src/culPlugins/mirador-viewXml';
import collectionFoldersPlugin from
  '@columbia-libraries/mirador/dist/es/src/culPlugins/mirador-selectCollectionFolders';

const flattenPluginConfigs = (...plugins) => plugins.reduce((acc, curr) => acc.concat([...curr]), []);

function loadMirador() {
  const miradorDiv = document.getElementById('mirador');
  if (!miradorDiv) return;

  const manifestUrl = miradorDiv.dataset.manifest;
  if (manifestUrl) {
    const numChildren = miradorDiv.dataset['num-children'] || 1;

    const getStartCanvas = (queryParams) => {
      if (queryParams.get('canvas')) {
        const canvases = queryParams.get('canvas').split(',');
        const canvas = canvases[0];
        return canvas.startsWith('../') ? manifestUrl.replace('/manifest', canvas.slice(2)) : canvas;
      }
      return null;
    };
    const startCanvas = getStartCanvas(new URL(document.location).searchParams);
    const viewConfig = {};
    if (numChildren && numChildren === 1) {
      viewConfig.views = [{ key: 'single' }];
      viewConfig.defaultView = 'single';
    }
    const culMiradorPlugins = flattenPluginConfigs(
      canvasRelatedLinksPlugin,
      citationSidebar,
      hintingSidebar,
      miradorDownloadPlugins,
      videoJSPlugin,
      viewerNavigation,
      viewXmlPlugin,
    );
    const foldersAttValue = miradorDiv.dataset['use-folders'];
    const useFolders = (Boolean(foldersAttValue) && !String.toString(foldersAttValue).match(/false/i));
    if (useFolders) {
      culMiradorPlugins.push(...collectionFoldersPlugin);
      viewConfig.allowTopCollectionButton = true;
      viewConfig.sideBarOpen = true;
    }

    Mirador.viewer(
      {
        id: 'mirador',
        window: {
          allowClose: false,
          allowFullscreen: true,
          allowMaximize: false,
          panels: {
            info: true,
            canvas: true,
          },
          canvasLink: {
            active: true,
            enabled: true,
            singleCanvasOnly: false,
            providers: [],
            getCanvasLink: (manifestId, canvases) => {
              const baseUri = window.location.href.replace(window.location.search, '');
              const isManifest = (canvas) => canvas.id.startsWith(manifestId.replace('/manifest', ''));
              const canvasIndices = canvases.map(
                (canvas) => (isManifest(canvas) ? `../canvas/${canvas.id.split('/').slice(-2).join('/')}` : canvas.id),
              );
              return `${baseUri}?canvas=${canvasIndices.join(',')}`;
            },
          },
          ...viewConfig,
        },
        windows: [
          { manifestId: manifestUrl, canvasId: startCanvas },
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
        translations: {
          en: { openCompanionWindow_citation: 'Citation' },
        },
      },
      culMiradorPlugins,
    );
  }
}

export default loadMirador;
