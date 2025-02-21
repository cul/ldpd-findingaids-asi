import Mirador from '@columbia-libraries/mirador';

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
    const viewConfig = {
      defaultView: 'single',
      views: [
        { key: 'single', behaviors: ['individuals'] },
        { key: 'book', behaviors: ['paged'] },
        { key: 'scroll', behaviors: ['continuous'] },
        { key: 'gallery', behaviors: ['continuous', 'individuals', 'paged', 'unordered'] },
      ],
    };
    if (numChildren && numChildren === 1) {
      viewConfig.views = [{ key: 'single' }];
      viewConfig.defaultView = 'single';
    }
    const culMiradorPlugins = [...Mirador.culPlugins.downloadDialogPlugin]
      .concat([...Mirador.culPlugins.viewXmlPlugin])
      .concat([...Mirador.culPlugins.citationsSidebarPlugin])
      .concat([...Mirador.culPlugins.videojsPlugin])
      .concat([...Mirador.culPlugins.canvasRelatedLinksPlugin])
      .concat([...Mirador.culPlugins.hintingSideBar])
      .concat([...Mirador.culPlugins.viewerNavigation])
      .concat([...Mirador.culPlugins.nativeObjectViewerPlugin]);
    const foldersAttValue = miradorDiv.dataset['use-folders'];
    const useFolders = (Boolean(foldersAttValue) && !String.toString(foldersAttValue).match(/false/i));
    if (useFolders) {
      culMiradorPlugins.push([...Mirador.culPlugins.collectionFoldersPlugin]);
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
