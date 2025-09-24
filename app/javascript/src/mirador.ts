import Mirador from '@columbia-libraries/mirador';
import { __CLIENT_INTERNALS_DO_NOT_USE_OR_WARN_USERS_THEY_CANNOT_UPGRADE as ReactSharedInternalsClient } from 'react';
import { MiradorConfig, Canvas, ViewConfig } from '../types.ts';

function loadMirador(): void {
  const miradorDiv = document.getElementById('mirador');
  if (!miradorDiv) return;

  const manifestUrl = miradorDiv.dataset.manifest;
  if (manifestUrl) {
    const numChildren = miradorDiv.dataset['num-children'];

    const getStartCanvas = (queryParams: URLSearchParams): string | null => {
      const canvasParam = queryParams.get('canvas');
      if (canvasParam) {
        const canvases = canvasParam.split(',');
        const canvas = canvases[0];
        return canvas.startsWith('../') ? manifestUrl.replace('/manifest', canvas.slice(2)) : canvas;
      }
      return null;
    };

    const startCanvas = getStartCanvas(new URL(document.location.href).searchParams);

    const viewConfig: ViewConfig = {
      defaultView: 'single',
      views: [
        { key: 'single', behaviors: ['individuals'] },
        { key: 'book', behaviors: ['paged'] },
        { key: 'scroll', behaviors: ['continuous'] },
        { key: 'gallery', behaviors: ['continuous', 'individuals', 'paged', 'unordered'] },
      ],
    };

    if (numChildren && numChildren === '1') {
      viewConfig.views = [{ key: 'single' }];
      viewConfig.defaultView = 'single';
    }

    const culMiradorPlugins: any[] = [...Mirador.culPlugins.downloadDialogPlugin]
      .concat([...Mirador.culPlugins.viewXmlPlugin])
      .concat([...Mirador.culPlugins.citationsSidebarPlugin])
      .concat([...Mirador.culPlugins.videojsPlugin])
      .concat([...Mirador.culPlugins.canvasRelatedLinksPlugin])
      .concat([...Mirador.culPlugins.hintingSideBar])
      .concat([...Mirador.culPlugins.viewerNavigation])
      .concat([...Mirador.culPlugins.nativeObjectViewerPlugin]);

    const foldersAttValue = miradorDiv.dataset.useFolders as 'true' | 'false';
    const useFolders = Boolean(foldersAttValue) && !foldersAttValue.match(/false/i);

    if (useFolders) {
      culMiradorPlugins.push(...Mirador.culPlugins.collectionFoldersPlugin);
      viewConfig.allowTopCollectionButton = true;
    }

    ReactSharedInternalsClient.actQueue = null;

    const miradorConfig: MiradorConfig = {
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
          getCanvasLink: (manifestId: string, canvases: Canvas[]): string => {
            const baseUri = window.location.href.replace(window.location.search, '');
            const isManifest = (canvas: Canvas): boolean => canvas.id.startsWith(manifestId.replace('/manifest', ''));
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
    };

    Mirador.viewer(miradorConfig, culMiradorPlugins);
  }
}

export default loadMirador;