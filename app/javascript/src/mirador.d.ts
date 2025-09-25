interface MiradorViewer {
  viewer: (config: any, plugins?: any[]) => void;
  culPlugins: {
    downloadDialogPlugin: any[];
    viewXmlPlugin: any[];
    citationsSidebarPlugin: any[];
    videojsPlugin: any[];
    canvasRelatedLinksPlugin: any[];
    hintingSideBar: any[];
    viewerNavigation: any[];
    nativeObjectViewerPlugin: any[];
    collectionFoldersPlugin: any[];
  };
}

declare module '@columbia-libraries/mirador' {
  const Mirador: MiradorViewer;
  export default Mirador;
}
