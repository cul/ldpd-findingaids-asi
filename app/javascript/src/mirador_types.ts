export interface MiradorConfig {
  id: string;
  window: WindowConfig;
  windows: MiradorWindow[];
  workspace: {
    showZoomControls: boolean;
  };
  workspaceControlPanel: {
    enabled: boolean;
  };
  miradorDownloadPlugin: {
    restrictDownloadOnSizeDefinition: boolean;
  };
  translations: {
    en: {
      openCompanionWindow_citation: string;
    };
  };
}

export interface ViewConfig {
  defaultView: string;
  views: Array<{
    key: string;
    behaviors?: string[];
  }>;
  allowTopCollectionButton?: boolean;
}

export interface Canvas {
  id: string;
}

interface WindowConfig {
  allowClose: boolean;
  allowFullscreen: boolean;
  allowMaximize: boolean;
  panels: {
    info: boolean;
    canvas: boolean;
  };
  canvasLink: CanvasLinkConfig;
  defaultView: string;
  views: Array<{
    key: string;
    behaviors?: string[];
  }>;
  allowTopCollectionButton?: boolean;
}

interface CanvasLinkConfig {
  active: boolean;
  enabled: boolean;
  singleCanvasOnly: boolean;
  providers: unknown[];
  getCanvasLink: (manifestId: string, canvases: Canvas[]) => string;
}

interface MiradorWindow {
  manifestId: string;
  canvasId: string | null;
}
