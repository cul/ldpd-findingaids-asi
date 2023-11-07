import VideoJSViewerComponent, { VideoJSViewer } from './components/VideoJSViewer';

const VideoJsPlugin = [
  {
    component: VideoJSViewerComponent,
    mode: "wrap",
    name: "VideoJSViewer",
    target: "VideoViewer",
  },
];

export { VideoJSViewerComponent };
export default VideoJsPlugin;